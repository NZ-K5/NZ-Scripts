--[[ NZ-HUB (unified)
  Tabs:
    - A-Chassis : thrust / backthrust / wheelie / presets / car fly / body fling / sit on hood
    - Brookhaven: Brookhaven car + player mods (fixed)
    - INF Smile : Infectious Smile map mods (fixed)
    - Backdoor  : backdoor scanner (fixed)
    - Utility   : rejoin / copy job / misc
  Fixes applied:
    - Backdoor: resultItems/backdoorsFound declared BEFORE copy handler (was global-nil bug)
    - Brookhaven: fly-speed boxes overlapped same Y and never updated canvas; now labelled rows.
      Velocity/RotVelocity -> AssemblyLinearVelocity/AssemblyAngularVelocity.
      InfJump via JumpRequest (was `if humanoid.Jump then humanoid.Jump=true` no-op).
      SpeedMultiplier no longer compounds (stores base MaxSpeed).
      Close-confirm destroy wrapped in pcall.
    - INF Smile: fixed `or`/`and` precedence bug that made anti-hack/spears/fire/lasers
      match almost every BasePart. Now parenthesised.
      Seismic loop uses elapsed timer instead of tick()%1 heartbeat hack.
    - A-Chassis: kept logic, reparented into tab page; single blur; single Insert hotkey.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local TeleportService  = game:GetService("TeleportService")
local CoreGui          = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- cleanup old standalone GUIs
pcall(function()
    if _G.__NZHub then _G.__NZHub:Destroy() _G.__NZHub = nil end
    if _G.__NZFly then _G.__NZFly:Destroy() _G.__NZFly = nil end
    if _G.__NZHUB then _G.__NZHUB:Destroy() _G.__NZHUB = nil end
end)
pcall(function()
    local pg = player:FindFirstChild("PlayerGui")
    if pg then
        for _, n in ipairs({ "NZHub", "NZFly", "BackdoorRoot", "ModRoot", "InfectiousRoot", "NZ-HUB" }) do
            local g = pg:FindFirstChild(n)
            if g then g:Destroy() end
        end
    end
end)
for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("BlurEffect") and (v.Name == "_NZBlur" or v.Name == "BlurEffect") then
        -- keep lighting clean; our single blur is named _NZBlur
    end
end
_G.__NZFlyActive = false
_G.__NZFlyStop = nil
_G.__NZFlyHold = { forward = false, back = false, up = false, down = false, left = false, right = false }

--------------------------------------------------------------------
-- SHARED UI STYLE
--------------------------------------------------------------------
local COL_BG       = Color3.fromRGB(18, 19, 24)
local COL_BG_ALT   = Color3.fromRGB(26, 27, 34)
local COL_BORDER   = Color3.fromRGB(48, 50, 62)
local COL_TEXT     = Color3.fromRGB(230, 232, 240)
local COL_TEXT_DIM = Color3.fromRGB(130, 134, 152)
local COL_ACCENT   = Color3.fromRGB(88, 140, 255)
local COL_GREEN    = Color3.fromRGB(72, 196, 120)
local COL_RED      = Color3.fromRGB(214, 78, 78)
local COL_YELLOW   = Color3.fromRGB(230, 190, 90)
local ON_BG, OFF_BG = Color3.fromRGB(20, 60, 30), Color3.fromRGB(40, 20, 20)
local ON_TX, OFF_TX = Color3.fromRGB(100, 255, 100), Color3.fromRGB(255, 100, 100)

local function corner(obj, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = obj; return c
end
local function stroke(obj, col, t)
    local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = obj; return s
end
local function setToggle(btn, on, onText, offText)
    btn.Text = on and (onText or "ON") or (offText or "OFF")
    TweenService:Create(btn, TweenInfo.new(0.18), {
        BackgroundColor3 = on and COL_GREEN or COL_BG_ALT,
        TextColor3 = on and Color3.fromRGB(255, 255, 255) or COL_TEXT_DIM }):Play()
end
local function flashOk(obj)
    local s = nil
    if obj and obj:IsA("UIStroke") then s = obj
    elseif obj then s = obj:FindFirstChildWhichIsA("UIStroke") end
    if not s then return end
    TweenService:Create(s, TweenInfo.new(0.12), { Color = COL_GREEN }):Play()
    task.delay(0.25, function()
        if s and s.Parent then TweenService:Create(s, TweenInfo.new(0.35), { Color = COL_BORDER }):Play() end
    end)
end
local function flashErr(box)
    if not box then return end
    box.TextColor3 = COL_RED
    TweenService:Create(box, TweenInfo.new(0.4), { TextColor3 = COL_TEXT }):Play()
end
local function isAnyTextBoxFocused()
    local ok, f = pcall(function() return UserInputService:GetFocusedTextBox() end)
    return ok and f ~= nil
end

--------------------------------------------------------------------
-- MAIN WINDOW : NZ-HUB
--------------------------------------------------------------------
local WIN_W, WIN_H = 640, 440

local gui = Instance.new("ScreenGui")
gui.Name = "NZ-HUB"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okP = pcall(function() gui.Parent = CoreGui end)
if not okP then gui.Parent = player:WaitForChild("PlayerGui") end
_G.__NZHUB = gui
_G.__NZHub = gui

local blur = Instance.new("BlurEffect")
blur.Name = "_NZBlur"
blur.Size = 6
blur.Parent = Lighting

local main = Instance.new("Frame")
main.Name = "Window"
main.Size = UDim2.new(0, WIN_W, 0, 36)
main.Position = UDim2.new(0.5, -WIN_W / 2, 0.45, -WIN_H / 2)
main.BackgroundColor3 = COL_BG
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
corner(main, 12)
stroke(main, COL_BORDER, 1)

-- title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = COL_BG_ALT
titleBar.BorderSizePixel = 0
titleBar.Parent = main
corner(titleBar, 12)
local under = Instance.new("Frame")
under.Size = UDim2.new(1, 0, 0, 12)
under.Position = UDim2.new(0, 0, 1, -12)
under.BackgroundColor3 = COL_BG_ALT
under.BorderSizePixel = 0
under.Parent = titleBar
local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 3, 0, 16)
accent.Position = UDim2.new(0, 12, 0.5, -8)
accent.BackgroundColor3 = COL_ACCENT
accent.BorderSizePixel = 0
accent.Parent = titleBar
corner(accent, 2)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 22, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NZ-HUB"
title.TextColor3 = COL_TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -32, 0.5, -12)
minBtn.BackgroundColor3 = Color3.fromRGB(38, 39, 48)
minBtn.Text = "-"
minBtn.TextColor3 = COL_TEXT_DIM
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false
minBtn.Parent = titleBar
corner(minBtn, 6)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -60, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(38, 39, 48)
closeBtn.Text = "X"
closeBtn.TextColor3 = COL_TEXT_DIM
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
corner(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function()
    if _G.__NZFlyStop then pcall(_G.__NZFlyStop) end
    if _G.__NZSitStop then pcall(_G.__NZSitStop) end
    if _G.__NZHoldFlingStop then pcall(_G.__NZHoldFlingStop) end
    pcall(function() blur:Destroy() end)
    gui:Destroy()
    _G.__NZHUB, _G.__NZHub, _G.__NZFly = nil, nil, nil
end)

-- drag
do
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -24, 0, 30)
tabBar.Position = UDim2.new(0, 12, 0, 42)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local TAB_DEFS = { "Car Mods", "Brookhaven", "INF Smile", "Backdoor", "Utility" }
local tabBtns, pages = {}, {}
local function createPage(name)
    local pg = Instance.new("ScrollingFrame")
    pg.Name = name
    pg.Size = UDim2.new(1, -24, 1, -84)
    pg.Position = UDim2.new(0, 12, 0, 76)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 4
    pg.ScrollBarImageColor3 = COL_ACCENT
    pg.CanvasSize = UDim2.new(0, 0, 0, 500)
    pg.ScrollingDirection = Enum.ScrollingDirection.Y
    pg.Visible = false
    pg.Parent = main
    return pg
end
for i, name in ipairs(TAB_DEFS) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1 / #TAB_DEFS, -6, 1, 0)
    b.Position = UDim2.new((i - 1) / #TAB_DEFS, (i == 1) and 0 or 3, 0, 0)
    b.BackgroundColor3 = COL_BG_ALT
    b.Text = name
    b.TextColor3 = COL_TEXT_DIM
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = tabBar
    corner(b, 6)
    stroke(b, COL_BORDER, 1)
    tabBtns[name] = b
    pages[name] = createPage(name)
end
local function selectTab(name)
    for n, pg in pairs(pages) do pg.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        if n == name then
            b.BackgroundColor3 = COL_ACCENT; b.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            b.BackgroundColor3 = COL_BG_ALT; b.TextColor3 = COL_TEXT_DIM
        end
    end
end
for n, b in pairs(tabBtns) do b.MouseButton1Click:Connect(function() selectTab(n) end) end
selectTab("Car Mods")

local FULL_H, MIN_H = WIN_H, 36
local minimized = false
local function tweenMain(h)
    TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, WIN_W, 0, h),
    }):Play()
end
task.spawn(function() task.wait(0.05) tweenMain(FULL_H) end)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tweenMain(minimized and MIN_H or FULL_H)
    minBtn.Text = minimized and "+" or "-"
    tabBar.Visible = not minimized
    for _, pg in pairs(pages) do pg.Visible = (not minimized) and (pg == pages["Car Mods"] or pg.Visible) end
    if not minimized then
        -- restore current selection
        for n, pg in pairs(pages) do
            if pg.Visible then selectTab(n) break end
        end
        selectTab("Car Mods")
    end
end)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        minimized = not minimized
        tweenMain(minimized and MIN_H or FULL_H)
        minBtn.Text = minimized and "+" or "-"
        tabBar.Visible = not minimized
    end
end)

-- shared row builders (parented per page)
local function pageLabel(parent, y, text, w)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, w or 150, 0, 22)
    l.Position = UDim2.new(0, 4, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = COL_TEXT_DIM
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end
local function pageBox(parent, y, x, w, def)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0, w or 110, 0, 26)
    b.Position = UDim2.new(0, x or 160, 0, y)
    b.BackgroundColor3 = COL_BG_ALT
    b.Text = tostring(def or "")
    b.TextColor3 = COL_TEXT
    b.PlaceholderColor3 = COL_TEXT_DIM
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = parent
    corner(b, 6)
    local s = stroke(b, COL_BORDER, 1)
    return b, s
end
local function pageApply(parent, y, x, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 64, 0, 26)
    b.Position = UDim2.new(0, x or 278, 0, y)
    b.BackgroundColor3 = COL_ACCENT
    b.Text = text or "Apply"
    b.TextColor3 = COL_TEXT
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 6)
    return b
end
local function pageToggle(parent, y, x, w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w or 80, 0, 26)
    b.Position = UDim2.new(0, x or 160, 0, y)
    b.BackgroundColor3 = OFF_BG
    b.Text = "OFF"
    b.TextColor3 = OFF_TX
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 6)
    return b
end
local function pageWideBtn(parent, y, text, bg)
    local b = Instance.new("TextButton")
    local baseBg = bg or COL_BG_ALT
    b.Size = UDim2.new(0, 220, 0, 30)
    b.Position = UDim2.new(0, 4, 0, y)
    b.BackgroundColor3 = baseBg
    b.Text = text
    b.TextColor3 = COL_TEXT
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 6)
    stroke(b, COL_BORDER, 1)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = COL_ACCENT, TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = baseBg, TextColor3 = COL_TEXT }):Play()
    end)
    return b
end

--------------------------------------------------------------------
-- A-CHASSIS MODULE (Tab: A-Chassis)
--------------------------------------------------------------------
local pageA = pages["Car Mods"]
do
    local MIN_SPEED, MAX_SPEED_SOFT = 2, 400
    local THRUST_CEILING = 1e9
    local FLY_SPEED_DEFAULT, FLY_VERT_DEFAULT = 90, 60

    local state = { currentCar = nil, currentBody = nil, flipState = nil, forwardHeld = false, backHeld = false, keyForward = false, keyBack = false }
    _G.__NZAState = state

    local function getCarFromSeat(seat)
        if not seat then return nil end
        local a = seat
        while a and a.Parent do
            a = a.Parent
            if a:IsA("Model") then return a end
        end
        return nil
    end
    local function getChassisPart(car)
        if not car then return nil end
        for _, name in ipairs({ "Body", "Chassis", "CarBody", "Base", "Drive", "Hull" }) do
            local p = car:FindFirstChild(name, true)
            if p and p:IsA("BasePart") then return p end
        end
        if car.PrimaryPart and car.PrimaryPart:IsA("BasePart") then return car.PrimaryPart end
        local biggest, sz = nil, 0
        for _, d in ipairs(car:GetChildren()) do
            if d:IsA("BasePart") then
                local s = d.Size.X * d.Size.Y * d.Size.Z
                if s > sz then biggest, sz = d, s end
            end
        end
        return biggest
    end
    _G.__NZAChassis = getChassisPart
    local function getCarCenter(car)
        if not car then return nil end
        local mn, mx
        for _, d in ipairs(car:GetDescendants()) do
            if d:IsA("BasePart") then
                local low, high = d.Position - d.Size * 0.5, d.Position + d.Size * 0.5
                if not mn then mn, mx = low, high
                else
                    mn = Vector3.new(math.min(mn.X, low.X), math.min(mn.Y, low.Y), math.min(mn.Z, low.Z))
                    mx = Vector3.new(math.max(mx.X, high.X), math.max(mx.Y, high.Y), math.max(mx.Z, high.Z))
                end
            end
        end
        if not mn then return nil end
        return (mn + mx) * 0.5
    end
    local function getCarBounds(car)
        if not car then return nil, nil end
        local mn, mx
        for _, d in ipairs(car:GetDescendants()) do
            if d:IsA("BasePart") then
                local low, high = d.Position - d.Size * 0.5, d.Position + d.Size * 0.5
                if not mn then mn, mx = low, high
                else
                    mn = Vector3.new(math.min(mn.X, low.X), math.min(mn.Y, low.Y), math.min(mn.Z, low.Z))
                    mx = Vector3.new(math.max(mx.X, high.X), math.max(mx.Y, high.Y), math.max(mx.Z, high.Z))
                end
            end
        end
        if not mn then return nil, nil end
        return (mn + mx) * 0.5, mx - mn
    end
    local function getCarMass(car)
        local ch = getChassisPart(car)
        if not ch then return 0 end
        local ok, m = pcall(function() return (ch.AssemblyRootPart or ch).AssemblyMass end)
        if ok and m and m > 0 then return m end
        local t = 0
        for _, d in ipairs(car:GetDescendants()) do if d:IsA("BasePart") then t = t + d:GetMass() end end
        return t
    end
    local function findThrottleValue()
        local pg = player:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local aci = pg:FindFirstChild("A-Chassis Interface")
        if not aci then return nil end
        local vals = aci:FindFirstChild("Values")
        if not vals then return nil end
        local v = vals:FindFirstChild("Velocity")
        if v and v:IsA("Vector3Value") then return v end
        return nil
    end
    local function getRigType(char)
        if not char then return "R15" end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.RigType == Enum.HumanoidRigType.R6 then return "R6" end
            return "R15"
        end
        return "R15"
    end
    local function getDriverOfCar(car)
        if not car then return nil end
        for _, plr in ipairs(Players:GetPlayers()) do
            local ch = plr.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.SeatPart and getCarFromSeat(hum.SeatPart) == car then return plr end
            end
        end
        return nil
    end
    local function getFrontWheels(car)
        if not car then return nil, nil end
        local wf = car:FindFirstChild("Wheels")
        if not wf then return nil, nil end
        local function res(w)
            if not w then return nil end
            if w:IsA("BasePart") then return w end
            if w:IsA("Model") then
                if w.PrimaryPart then return w.PrimaryPart end
                for _, d in ipairs(w:GetDescendants()) do if d:IsA("BasePart") then return d end end
            end
            return nil
        end
        return res(wf:FindFirstChild("FL")), res(wf:FindFirstChild("FR"))
    end
    local function getRoot()
        local ch = player.Character
        if not ch then return nil, nil end
        return ch, ch:FindFirstChild("HumanoidRootPart")
    end

    -- layout: two columns inside pageA
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -8, 0, 16)
    status.Position = UDim2.new(0, 4, 0, 2)
    status.BackgroundTransparency = 1
    status.Text = "Waiting for vehicle..."
    status.TextColor3 = COL_TEXT_DIM
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = pageA
    local inputState = Instance.new("TextLabel")
    inputState.Size = UDim2.new(1, -8, 0, 14)
    inputState.Position = UDim2.new(0, 4, 0, 18)
    inputState.BackgroundTransparency = 1
    inputState.Text = "Input  -"
    inputState.TextColor3 = COL_TEXT_DIM
    inputState.Font = Enum.Font.Gotham
    inputState.TextSize = 10
    inputState.TextXAlignment = Enum.TextXAlignment.Left
    inputState.Parent = pageA
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -8, 0, 14)
    info.Position = UDim2.new(0, 4, 0, 470)
    info.BackgroundTransparency = 1
    info.Text = ""
    info.TextColor3 = COL_TEXT_DIM
    info.Font = Enum.Font.Gotham
    info.TextSize = 9
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = pageA

    local y0 = 38
    pageLabel(pageA, y0, "Thrust");            local thrustBox, thrustStroke = pageBox(pageA, y0 - 2, 160, 110, 2500);       local thrustApply = pageApply(pageA, y0 - 2, 278)
    pageLabel(pageA, y0 + 32, "Wheelie Force"); local wfBox, wfStroke = pageBox(pageA, y0 + 30, 160, 110, 11000);             local wfApply = pageApply(pageA, y0 + 30, 278)
    pageLabel(pageA, y0 + 64, "Wheelie Delay"); local wdBox, wdStroke = pageBox(pageA, y0 + 62, 160, 110, 0.03);              local wdApply = pageApply(pageA, y0 + 62, 278)
    pageLabel(pageA, y0 + 96, "BackThrust");    local btBox, btStroke = pageBox(pageA, y0 + 94, 160, 110, 2500);              local btApply = pageApply(pageA, y0 + 94, 278)

    local boostBtn = pageToggle(pageA, y0 + 128, 4, 165); boostBtn.Text = "Boost Offline"; boostBtn.TextColor3 = COL_TEXT_DIM; boostBtn.BackgroundColor3 = COL_BG_ALT
    local wheelieBtn = pageToggle(pageA, y0 + 128, 177, 165); wheelieBtn.Text = "Wheelie: Off"; wheelieBtn.TextColor3 = COL_TEXT_DIM; wheelieBtn.BackgroundColor3 = COL_BG_ALT
    local backBtn = pageToggle(pageA, y0 + 160, 4, 338); backBtn.Text = "BackThrust: Off"; backBtn.TextColor3 = COL_TEXT_DIM; backBtn.BackgroundColor3 = COL_BG_ALT

    local PRESETS = {
        Normal = { thrust = 2500, backThrust = 2500, wheelieForce = 11000, wheelieDelay = 0.03 },
        Truck = { thrust = 3250, backThrust = 3250, wheelieForce = 13250, wheelieDelay = 0.03 },
        PublicBus = { thrust = 2500, backThrust = 2500, wheelieForce = 10500, wheelieDelay = 0.01 },
        DragCarWeak = { thrust = 4000, backThrust = 4000, wheelieForce = 11000, wheelieDelay = 0.03 },
        DragCarStrong = { thrust = 4000, backThrust = 4000, wheelieForce = 13980, wheelieDelay = 0.03 },
    }
    local py = y0 + 196
    pageLabel(pageA, py, "Presets")
    py = py + 20
    local presetNames = { "Normal", "Truck", "PublicBus", "DragCarWeak", "DragCarStrong" }
    local presetBtns = {}
    for i, n in ipairs(presetNames) do
        local b = pageWideBtn(pageA, py, n)
        b.Size = UDim2.new(0, 165, 0, 26)
        if i % 2 == 0 then b.Position = UDim2.new(0, 177, 0, py) end
        if i % 2 == 0 then py = py + 30 end
        presetBtns[n] = b
    end
    py = py + 34
    local flySpeedLbl = pageLabel(pageA, py, "Fly Speed")
    local flyBox, flyStroke = pageBox(pageA, py - 2, 160, 110, FLY_SPEED_DEFAULT)
    local flyApply = pageApply(pageA, py - 2, 278)
    py = py + 32
    local flyToggle = pageToggle(pageA, py, 4, 165); flyToggle.Text = "Car Fly: Off"; flyToggle.TextColor3 = COL_TEXT_DIM; flyToggle.BackgroundColor3 = COL_BG_ALT
    local flingBtn = pageToggle(pageA, py, 177, 165); flingBtn.Text = "Body Fling: Off"; flingBtn.TextColor3 = COL_TEXT_DIM; flingBtn.BackgroundColor3 = COL_BG_ALT
    py = py + 32
    pageLabel(pageA, py, "Fly pad (hold, PC + mobile)")
    py = py + 20
    local flyPadDefs = { { "Fwd", "forward" }, { "Back", "back" }, { "Up", "up" }, { "Down", "down" }, { "Left", "left" }, { "Right", "right" } }
    for i, d in ipairs(flyPadDefs) do
        local col, row = (i - 1) % 3, math.floor((i - 1) / 3)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 108, 0, 28)
        b.Position = UDim2.new(0, 4 + col * 114, 0, py + row * 32)
        b.BackgroundColor3 = COL_BG_ALT
        b.Text = d[1]
        b.TextColor3 = COL_TEXT
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Parent = pageA
        corner(b, 6)
        stroke(b, COL_BORDER, 1)
        local key = d[2]
        local function setHold(v)
            _G.__NZFlyHold[key] = v
            TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = v and COL_GREEN or COL_BG_ALT }):Play()
        end
        b.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then setHold(true) end
        end)
        b.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then setHold(false) end
        end)
    end
    py = py + 68
    local clickBtn = pageToggle(pageA, py, 4, 165); clickBtn.Text = "Fling: Click"; clickBtn.TextColor3 = COL_TEXT; clickBtn.BackgroundColor3 = COL_ACCENT
    local holdBtn = pageToggle(pageA, py, 177, 165); holdBtn.Text = "Fling: Hold"; holdBtn.TextColor3 = COL_TEXT_DIM; holdBtn.BackgroundColor3 = COL_BG_ALT
    py = py + 32
    local sitBtn = pageToggle(pageA, py, 4, 165); sitBtn.Text = "Sit"; sitBtn.TextColor3 = COL_TEXT; sitBtn.BackgroundColor3 = COL_BG_ALT
    local stopSitBtn = pageToggle(pageA, py, 177, 165); stopSitBtn.Text = "Stop Sit"; stopSitBtn.TextColor3 = COL_TEXT_DIM; stopSitBtn.BackgroundColor3 = COL_BG_ALT
    py = py + 32
    pageA.CanvasSize = UDim2.new(0, 0, 0, py + 60)

    -- state vars
    local boostEnabled, backEnabled, wheelieEnabled = false, false, false
    local currentThrust, currentBackThrust = 2500, 2500
    local wheelieForceCurrent, wheelieRampUp, wheelieAmount = 11000, 0.03, 0
    local currentFlySpeed, currentFlyVert = FLY_SPEED_DEFAULT, 60
    local activeForce, activeAttach, forceConn, lastChassis = nil, nil, nil, nil
    local wAL, wAR, wFL, wFR, wCachedCar, wLastFind = nil, nil, nil, nil, nil, 0

    local function flashOk(s)
        if not s then return end
        TweenService:Create(s, TweenInfo.new(0.12), { Color = COL_GREEN }):Play()
        task.delay(0.25, function()
            if s and s.Parent then TweenService:Create(s, TweenInfo.new(0.35), { Color = COL_BORDER }):Play() end
        end)
    end
    local function updateInputLabel()
        local f = state.forwardHeld or state.keyForward
        local b = state.backHeld or state.keyBack
        if f and b then inputState.Text = "Input  forward + back"
        elseif f then inputState.Text = "Input  forward"
        elseif b then inputState.Text = "Input  backward"
        else inputState.Text = "Input  -" end
    end
    local function destroyWheelie()
        for _, o in ipairs({ wFL, wFR, wAL, wAR }) do pcall(function() if o then o:Destroy() end end) end
        wFL, wFR, wAL, wAR, wCachedCar = nil, nil, nil, nil, nil
    end
    local function stopThrust()
        if forceConn then forceConn:Disconnect() forceConn = nil end
        pcall(function() if activeForce then activeForce:Destroy() end end) activeForce = nil
        pcall(function() if activeAttach then activeAttach:Destroy() end end) activeAttach = nil
        destroyWheelie()
        lastChassis = nil; wheelieAmount = 0
    end
    local function ensureForce(chassis)
        if activeForce and activeForce.Parent == chassis then return end
        pcall(function() if activeForce then activeForce:Destroy() end end)
        pcall(function() if activeAttach then activeAttach:Destroy() end end)
        activeAttach = Instance.new("Attachment"); activeAttach.Name = "_NZAttach"; activeAttach.Parent = chassis
        activeForce = Instance.new("VectorForce"); activeForce.Name = "_NZForce"
        activeForce.Attachment0 = activeAttach; activeForce.RelativeTo = Enum.ActuatorRelativeTo.World
        activeForce.ApplyAtCenterOfMass = true; activeForce.Force = Vector3.zero; activeForce.Parent = chassis
    end
    local function ensureWheelie(chassis)
        if not wheelieEnabled then return end
        local car = state.currentCar
        if not car then return end
        if wFL and wFL.Parent and wFR and wFR.Parent and wFL.Parent:IsDescendantOf(car) and wFR.Parent:IsDescendantOf(car) then return end
        local now = os.clock()
        if wCachedCar == car and (now - wLastFind) < 1 then return end
        wLastFind, wCachedCar = now, car
        destroyWheelie()
        local fl, fr = getFrontWheels(car)
        local tL, tR = fl or chassis, fr or chassis
        wAL = Instance.new("Attachment"); wAL.Name = "_NZWheelieAttachL"
        wAL.Position = fl and Vector3.zero or Vector3.new(-0.5 * chassis.Size.X, 0, -0.5 * chassis.Size.Z)
        wAL.Parent = tL
        wFL = Instance.new("VectorForce"); wFL.Name = "_NZWheelieForceL"
        wFL.Attachment0 = wAL; wFL.RelativeTo = Enum.ActuatorRelativeTo.World
        wFL.ApplyAtCenterOfMass = false; wFL.Force = Vector3.zero; wFL.Parent = tL
        wAR = Instance.new("Attachment"); wAR.Name = "_NZWheelieAttachR"
        wAR.Position = fr and Vector3.zero or Vector3.new(0.5 * chassis.Size.X, 0, -0.5 * chassis.Size.Z)
        wAR.Parent = tR
        wFR = Instance.new("VectorForce"); wFR.Name = "_NZWheelieForceR"
        wFR.Attachment0 = wAR; wFR.RelativeTo = Enum.ActuatorRelativeTo.World
        wFR.ApplyAtCenterOfMass = false; wFR.Force = Vector3.zero; wFR.Parent = tR
    end
    local function startLoop()
        if forceConn then return end
        forceConn = RunService.Heartbeat:Connect(function(dt)
            if not boostEnabled and not backEnabled then return end
            if _G.__NZFlyActive then return end
            if not state.currentCar or not state.currentCar.Parent then return end
            local chassis = lastChassis
            if not chassis or not chassis.Parent or not chassis:IsDescendantOf(state.currentCar) then
                chassis = getChassisPart(state.currentCar); lastChassis = chassis
            end
            if not chassis then return end
            ensureForce(chassis)
            local fwd = state.forwardHeld or state.keyForward
            local bck = state.backHeld or state.keyBack
            if boostEnabled and fwd and not bck then
                local facing = chassis.CFrame.LookVector
                local flat = Vector3.new(facing.X, 0, facing.Z)
                if flat.Magnitude >= 0.01 then
                    if state.flipState == nil then
                        local tv = findThrottleValue()
                        if tv then
                            local t = tv.Value
                            local ft = Vector3.new(t.X, 0, t.Z)
                            if ft.Magnitude > 0.01 then
                                local wd = (chassis.CFrame:VectorToWorldSpace(ft)).Unit
                                state.flipState = wd:Dot(flat.Unit) < 0
                            end
                        end
                    end
                    if state.flipState == nil then
                        local v = chassis.AssemblyLinearVelocity
                        local vf = Vector3.new(v.X, 0, v.Z)
                        if vf.Magnitude > 5 then state.flipState = vf.Unit:Dot(flat.Unit) < 0 end
                    end
                    if state.flipState == true then flat = -flat end
                    flat = flat.Unit
                    local sp = chassis.AssemblyLinearVelocity.Magnitude
                    local cap = 1
                    if sp > MAX_SPEED_SOFT then cap = math.clamp(1 - (sp - MAX_SPEED_SOFT) / 100, 0, 1) end
                    local str = currentThrust * cap
                    if sp < MIN_SPEED then str = currentThrust * 0.5 end
                    activeForce.Force = flat * str
                end
            elseif backEnabled and bck and not fwd then
                local facing = chassis.CFrame.LookVector
                local flat = Vector3.new(facing.X, 0, facing.Z)
                if flat.Magnitude >= 0.01 then
                    flat = flat.Unit
                    if state.flipState == true then flat = -flat end
                    local sp = chassis.AssemblyLinearVelocity.Magnitude
                    local cap = 1
                    if sp > MAX_SPEED_SOFT then cap = math.clamp(1 - (sp - MAX_SPEED_SOFT) / 100, 0, 1) end
                    local str = currentBackThrust * cap
                    if sp < MIN_SPEED then str = currentBackThrust * 0.5 end
                    activeForce.Force = -flat * str
                end
            else
                if activeForce then activeForce.Force = Vector3.zero end
            end
            if wheelieEnabled then
                ensureWheelie(chassis)
                local sp = chassis.AssemblyLinearVelocity.Magnitude
                if fwd and not bck and sp >= 8 then
                    wheelieAmount = math.min(1, wheelieAmount + dt / math.max(wheelieRampUp, 0.01))
                else
                    wheelieAmount = math.max(0, wheelieAmount - dt * 5)
                end
                local look = chassis.CFrame.LookVector
                local fl2 = Vector3.new(look.X, 0, look.Z)
                if fl2.Magnitude > 0.001 then
                    local pd = math.deg(math.acos(math.clamp(look:Dot(fl2.Unit), -1, 1)))
                    if pd > 55 then wheelieAmount = 0 end
                end
                if wFL and wFL.Parent and wFR and wFR.Parent then
                    local ms = math.clamp(chassis:GetMass() / 1000, 0.3, 20)
                    local s = wheelieForceCurrent * wheelieAmount * ms
                    wFL.Force = Vector3.new(0, s, 0); wFR.Force = Vector3.new(0, s, 0)
                end
            else
                if wFL then wFL.Force = Vector3.zero end
                if wFR then wFR.Force = Vector3.zero end
                wheelieAmount = 0
            end
        end)
    end
    local function refreshLoop()
        if boostEnabled or backEnabled then startLoop() else stopThrust() end
        updateInputLabel()
    end
    local function paintToggle(btn, on, onText, offText)
        btn.Text = on and onText or offText
        TweenService:Create(btn, TweenInfo.new(0.18), {
            BackgroundColor3 = on and COL_GREEN or COL_BG_ALT,
            TextColor3 = on and Color3.fromRGB(255, 255, 255) or COL_TEXT_DIM }):Play()
    end

    boostBtn.MouseButton1Click:Connect(function()
        if not state.currentCar then status.Text = "Sit in a car first"; status.TextColor3 = COL_RED; return end
        boostEnabled = not boostEnabled
        paintToggle(boostBtn, boostEnabled, "Boost Online", "Boost Offline")
        refreshLoop()
    end)
    backBtn.MouseButton1Click:Connect(function()
        if not state.currentCar then status.Text = "Sit in a car first"; status.TextColor3 = COL_RED; return end
        backEnabled = not backEnabled
        paintToggle(backBtn, backEnabled, "BackThrust: On", "BackThrust: Off")
        refreshLoop()
    end)
    wheelieBtn.MouseButton1Click:Connect(function()
        wheelieEnabled = not wheelieEnabled
        paintToggle(wheelieBtn, wheelieEnabled, "Wheelie: On", "Wheelie: Off")
        if not wheelieEnabled then wheelieAmount = 0 end
    end)
    thrustApply.MouseButton1Click:Connect(function()
        local n = tonumber(thrustBox.Text)
        if n and n >= 0 then currentThrust = math.min(n, THRUST_CEILING); thrustBox.Text = tostring(currentThrust); flashOk(thrustStroke) end
    end)
    btApply.MouseButton1Click:Connect(function()
        local n = tonumber(btBox.Text)
        if n and n >= 0 then currentBackThrust = math.min(n, THRUST_CEILING); btBox.Text = tostring(currentBackThrust); flashOk(btStroke) end
    end)
    wfApply.MouseButton1Click:Connect(function()
        local n = tonumber(wfBox.Text)
        if n and n >= 0 then wheelieForceCurrent = math.clamp(n, 0, 500000); wfBox.Text = tostring(wheelieForceCurrent); flashOk(wfStroke) end
    end)
    wdApply.MouseButton1Click:Connect(function()
        local n = tonumber(wdBox.Text)
        if n and n >= 0 then wheelieRampUp = math.clamp(n, 0.01, 10); wdBox.Text = tostring(wheelieRampUp); flashOk(wdStroke) end
    end)
    local function applyPreset(nm)
        local p = PRESETS[nm]; if not p then return end
        currentThrust, currentBackThrust, wheelieForceCurrent, wheelieRampUp = p.thrust, p.backThrust, p.wheelieForce, p.wheelieDelay
        thrustBox.Text, btBox.Text, wfBox.Text, wdBox.Text = tostring(p.thrust), tostring(p.backThrust), tostring(p.wheelieForce), tostring(p.wheelieDelay)
        flashOk(thrustStroke); flashOk(btStroke); flashOk(wfStroke); flashOk(wdStroke)
        info.Text = "Loaded preset: " .. nm; info.TextColor3 = COL_GREEN
    end
    for nm, b in pairs(presetBtns) do b.MouseButton1Click:Connect(function() applyPreset(nm) end) end

    UserInputService.InputBegan:Connect(function(input, gp)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if gp or isAnyTextBoxFocused() then return end
        if input.KeyCode == Enum.KeyCode.W then state.keyForward = true; updateInputLabel() end
        if input.KeyCode == Enum.KeyCode.S then state.keyBack = true; updateInputLabel() end
        local fk = { [Enum.KeyCode.W] = "forward", [Enum.KeyCode.S] = "back", [Enum.KeyCode.A] = "left", [Enum.KeyCode.D] = "right", [Enum.KeyCode.Q] = "up", [Enum.KeyCode.E] = "down" }
        if _G.__NZFlyActive and fk[input.KeyCode] then _G.__NZFlyHold[fk[input.KeyCode]] = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == Enum.KeyCode.W then state.keyForward = false; updateInputLabel() end
        if input.KeyCode == Enum.KeyCode.S then state.keyBack = false; updateInputLabel() end
        local fk = { [Enum.KeyCode.W] = "forward", [Enum.KeyCode.S] = "back", [Enum.KeyCode.A] = "left", [Enum.KeyCode.D] = "right", [Enum.KeyCode.Q] = "up", [Enum.KeyCode.E] = "down" }
        if fk[input.KeyCode] then _G.__NZFlyHold[fk[input.KeyCode]] = false end
    end)

    -- seat detection
    local function onSeated(seat)
        state.currentCar = getCarFromSeat(seat); state.flipState = nil; state.currentBody = nil
        if state.currentCar then
            status.Text = state.currentCar.Name; status.TextColor3 = COL_GREEN
            local ch = getChassisPart(state.currentCar); state.currentBody = ch
            info.Text = ch and ("chassis  " .. ch.Name) or "chassis not found"
        else
            status.Text = "Seated, no car found"; status.TextColor3 = COL_YELLOW
        end
    end
    local function onUnseated()
        state.currentCar, state.currentBody, state.flipState = nil, nil, nil
        status.Text = "Waiting for vehicle..."; status.TextColor3 = COL_TEXT_DIM; info.Text = ""
        if _G.__NZFlyStop then _G.__NZFlyStop() end
    end
    local function bindChar(ch)
        local hum = ch:WaitForChild("Humanoid", 5); if not hum then return end
        hum.Seated:Connect(function(s, seat) if s then onSeated(seat) else onUnseated() end end)
        if hum.SeatPart then onSeated(hum.SeatPart) end
    end
    if player.Character then bindChar(player.Character) end
    player.CharacterAdded:Connect(bindChar)

    -- A-Chassis mobile buttons: FullThrottle / FullBrake
    local hookedBtns = {}
    local function hookGuiBtn(btn, setter)
        if not btn or hookedBtns[btn] then return end
        hookedBtns[btn] = true
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                setter(true); updateInputLabel()
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                setter(false); updateInputLabel()
            end
        end)
    end
    local function hookCarButtons(plr)
        local pg = plr and plr:FindFirstChild("PlayerGui")
        local aci = pg and pg:FindFirstChild("A-Chassis Interface")
        local gauges = aci and aci:FindFirstChild("Gauges")
        local gf = gauges and gauges:FindFirstChild("GUI")
        if gf then
            hookGuiBtn(gf:FindFirstChild("FullThrottle"), function(v) state.forwardHeld = v end)
            hookGuiBtn(gf:FindFirstChild("FullBrake"), function(v) state.backHeld = v end)
        end
    end
    task.spawn(function()
        while gui.Parent do
            task.wait(1)
            pcall(function()
                hookCarButtons(player)
                if state.currentCar then
                    local d = getDriverOfCar(state.currentCar)
                    if d and d ~= player then hookCarButtons(d) end
                end
            end)
        end
    end)

    -- fly (anchored CFrame move)
    local flyConn, flyActive, savedFly = nil, false, nil
    local function collectFly(chassis)
        local car = chassis
        while car and car.Parent and not car:IsA("Model") do car = car.Parent end
        if not car then return { chassis } end
        local parts = {}
        for _, d in ipairs(car:GetDescendants()) do if d:IsA("BasePart") then table.insert(parts, d) end end
        if not table.find(parts, chassis) then table.insert(parts, chassis) end
        return parts
    end
    local function stopFly()
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if not flyActive then return end
        flyActive = false; _G.__NZFlyActive = false
        for k in pairs(_G.__NZFlyHold) do _G.__NZFlyHold[k] = false end
        if state.currentCar and savedFly then
            local ch = getChassisPart(state.currentCar)
            if ch then
                for _, p in ipairs(savedFly.parts) do
                    pcall(function()
                        if p and p.Parent then p.CFrame = savedFly.cframes[p]; p.Anchored = savedFly.anchored[p] end
                    end)
                end
                pcall(function()
                    ch.AssemblyLinearVelocity = savedFly.velocity
                    ch.AssemblyAngularVelocity = savedFly.angular
                end)
            end
        end
        savedFly = nil
        flyToggle.Text = "Car Fly: Off"
        flyToggle.BackgroundColor3 = COL_BG_ALT; flyToggle.TextColor3 = COL_TEXT_DIM
    end
    _G.__NZFlyStop = stopFly
    local function startFly()
        if flyActive or not state.currentCar then return end
        local ch = getChassisPart(state.currentCar); if not ch then return end
        flyActive = true; _G.__NZFlyActive = true
        local parts = collectFly(ch)
        local anch, cf = {}, {}
        for _, p in ipairs(parts) do anch[p] = p.Anchored; cf[p] = p.CFrame end
        savedFly = { parts = parts, anchored = anch, cframes = cf, velocity = ch.AssemblyLinearVelocity, angular = ch.AssemblyAngularVelocity }
        for _, p in ipairs(parts) do pcall(function() p.Anchored = true end) end
        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.Heartbeat:Connect(function(dt)
            if not flyActive then return end
            if not state.currentCar or not state.currentCar.Parent then stopFly() return end
            local h = _G.__NZFlyHold
            local mv = Vector3.zero
            if h.forward then mv = mv + Vector3.new(0, 0, -1) end
            if h.back then mv = mv + Vector3.new(0, 0, 1) end
            if h.right then mv = mv + Vector3.new(1, 0, 0) end
            if h.left then mv = mv - Vector3.new(1, 0, 0) end
            if h.up then mv = mv + Vector3.new(0, 1, 0) end
            if h.down then mv = mv - Vector3.new(0, 1, 0) end
            if mv.Magnitude < 0.001 then return end
            local step = Vector3.zero
            local hor = Vector3.new(mv.X, 0, mv.Z)
            if hor.Magnitude > 0.01 then step = step + hor.Unit * currentFlySpeed * dt end
            if math.abs(mv.Y) > 0.001 then step = step + Vector3.new(0, mv.Y * currentFlyVert * dt, 0) end
            for _, p in ipairs(savedFly.parts) do if p and p.Parent then p.CFrame = p.CFrame + step end end
        end)
    end
    flyApply.MouseButton1Click:Connect(function()
        local n = tonumber(flyBox.Text)
        if n and n >= 1 then
            currentFlySpeed = math.clamp(n, 1, 2000); currentFlyVert = currentFlySpeed * 0.66
            flyBox.Text = tostring(currentFlySpeed); flashOk(flyStroke)
        end
    end)
    flyToggle.MouseButton1Click:Connect(function()
        if flyActive then stopFly()
        else
            if not state.currentCar then status.Text = "Sit in a car first"; status.TextColor3 = COL_RED; return end
            startFly()
            flyToggle.Text = "Car Fly: On"
            flyToggle.BackgroundColor3 = COL_GREEN; flyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)

    -- body fling click/hold + sit
    local flingEnabled, flingMode, flingBusy, flingLast = false, "click", false, 0
    local holdActive, holdTarget, holdReturn, holdConn = false, nil, nil, nil
    local function isCarModel(m)
        if not m:IsA("Model") then return false end
        local c = 0
        for _, d in ipairs(m:GetDescendants()) do if d:IsA("BasePart") then c = c + 1; if c >= 3 then break end end end
        if c < 3 then return false end
        for _, n in ipairs({ "Body", "Chassis", "CarBody", "Base", "Drive", "Hull" }) do
            local p = m:FindFirstChild(n, true)
            if p and p:IsA("BasePart") then return true end
        end
        return false
    end
    local function findCarModel(inst)
        local n = inst
        while n and n.Parent and n ~= Workspace do
            if n:IsA("Model") and isCarModel(n) then return n end
            n = n.Parent
        end
        return nil
    end
    local function massKick(car, dir)
        local ch = getChassisPart(car); if not ch then return end
        local m = getCarMass(car); if not m or m <= 0 then m = 1000 end
        local s = m / 1000
        local h = math.min(180 * s, 2500); local v = math.min(70 * s, 1200)
        pcall(function() ch.AssemblyLinearVelocity = ch.AssemblyLinearVelocity + dir * h + Vector3.new(0, v, 0) end)
    end
    local function doClickFling(car)
        if flingBusy or os.clock() - flingLast < 0.15 then return end
        flingLast = os.clock()
        local cc = getCarCenter(car); if not cc then return end
        local _, root = getRoot(); if not root then return end
        flingBusy = true
        local orig = root.CFrame
        local camP = camera.CFrame.Position
        local toCar = Vector3.new(cc.X - camP.X, 0, cc.Z - camP.Z)
        toCar = toCar.Magnitude < 0.01 and Vector3.new(0, 0, -1) or toCar.Unit
        local push = Vector3.new(cc.X + toCar.X * 6, cc.Y - 1.5, cc.Z + toCar.Z * 6)
        pcall(function() root.CFrame = CFrame.new(push, push + toCar) end)
        massKick(car, toCar)
        local stopAt = os.clock() + 0.20
        local lc
        lc = RunService.Heartbeat:Connect(function()
            if os.clock() >= stopAt then if lc then lc:Disconnect() end return end
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = CFrame.new(push, push + toCar)
            end)
        end)
        task.delay(0.28, function()
            pcall(function() if lc then lc:Disconnect() end end)
            local _, r2 = getRoot()
            if r2 then pcall(function() r2.CFrame = orig; r2.AssemblyLinearVelocity = Vector3.zero; r2.AssemblyAngularVelocity = Vector3.zero end) end
            flingBusy = false
        end)
        info.Text = "Flung " .. car.Name; info.TextColor3 = COL_GREEN
    end
    local function stopHold()
        if holdConn then holdConn:Disconnect() holdConn = nil end
        local _, r = getRoot()
        if r and holdReturn then pcall(function() r.CFrame = holdReturn; r.AssemblyLinearVelocity = Vector3.zero; r.AssemblyAngularVelocity = Vector3.zero end) end
        holdActive, holdTarget, holdReturn = false, nil, nil
    end
    flingBtn.MouseButton1Click:Connect(function()
        flingEnabled = not flingEnabled
        paintToggle(flingBtn, flingEnabled, "Body Fling: On", "Body Fling: Off")
        if not flingEnabled and holdActive then stopHold() end
    end)
    local function paintFlingMode()
        if flingMode == "click" then
            clickBtn.BackgroundColor3 = COL_ACCENT; clickBtn.TextColor3 = COL_TEXT
            holdBtn.BackgroundColor3 = COL_BG_ALT; holdBtn.TextColor3 = COL_TEXT_DIM
        else
            holdBtn.BackgroundColor3 = COL_ACCENT; holdBtn.TextColor3 = COL_TEXT
            clickBtn.BackgroundColor3 = COL_BG_ALT; clickBtn.TextColor3 = COL_TEXT_DIM
        end
    end
    clickBtn.MouseButton1Click:Connect(function() flingMode = "click"; paintFlingMode() end)
    holdBtn.MouseButton1Click:Connect(function() flingMode = "hold"; paintFlingMode() end)

    local sitActive, sitTarget, sitReturn, sitConn, sitTrack, sitObj = false, nil, nil, nil, nil, nil
    local function stopSit()
        if sitConn then sitConn:Disconnect() sitConn = nil end
        if not sitActive then return end
        if sitTrack then pcall(function() sitTrack:Stop(0.1) end) sitTrack = nil end
        if sitObj then pcall(function() sitObj:Destroy() end) sitObj = nil end
        local ch = player.Character
        if ch then
            for _, c in ipairs(ch:GetDescendants()) do if c:IsA("WeldConstraint") and c.Name == "_NZSitWeld" then pcall(function() c:Destroy() end) end end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.PlatformStand = false end) pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
            local r = ch:FindFirstChild("HumanoidRootPart")
            if r and sitReturn then pcall(function() r.CFrame = sitReturn + Vector3.new(0, 2, 0); r.AssemblyLinearVelocity = Vector3.zero; r.AssemblyAngularVelocity = Vector3.zero end) end
        end
        sitActive, sitTarget, sitReturn = false, nil, nil
        sitBtn.Text = "Sit"
        info.Text = "Stood up"; info.TextColor3 = COL_YELLOW
    end
    _G.__NZSitStop = stopSit
    local sitSelecting = false
    sitBtn.MouseButton1Click:Connect(function()
        if sitActive then stopSit() return end
        sitSelecting = not sitSelecting
        sitBtn.Text = sitSelecting and "Sit: Select" or "Sit"
        if sitSelecting then info.Text = "Click a car to sit on it"; info.TextColor3 = COL_YELLOW end
    end)
    stopSitBtn.MouseButton1Click:Connect(function() sitSelecting = false; if sitActive then stopSit() else sitBtn.Text = "Sit" end end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or isAnyTextBoxFocused() then return end
        local isClick = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
        if not isClick then return end
        local pos = input.Position
        -- sit select has priority
        if sitSelecting then
            local ray = camera:ViewportPointToRay(pos.X, pos.Y)
            local pr = RaycastParams.new(); pr.FilterType = Enum.RaycastFilterType.Exclude; pr.FilterDescendantsInstances = { player.Character }
            local hit = Workspace:Raycast(ray.Origin, ray.Direction * 5000, pr)
            if hit then
                local car = findCarModel(hit.Instance)
                if car then
                    sitSelecting = false
                    local _, root = getRoot(); if not root then return end
                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
                    sitReturn = root.CFrame
                    local cc, cs = getCarBounds(car); if not cc then return end
                    local chp = getChassisPart(car); if not chp then return end
                    local fw = chp.CFrame.LookVector; fw = Vector3.new(fw.X, 0, fw.Z)
                    if fw.Magnitude < 0.01 then fw = Vector3.new(0, 0, -1) end; fw = fw.Unit
                    local hood = cc + fw * (cs.Z * 0.35) + Vector3.new(0, cs.Y * 0.35, 0)
                    hum.PlatformStand = true
                    pcall(function() root.CFrame = CFrame.new(hood, hood + fw); root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end)
                    local w = Instance.new("WeldConstraint"); w.Name = "_NZSitWeld"; w.Part0 = root; w.Part1 = chp; w.Parent = root
                    local rig = getRigType(player.Character)
                    sitObj = Instance.new("Animation"); sitObj.AnimationId = (rig == "R6") and "rbxassetid://2506281703" or "rbxassetid://507768375"
                    local an = hum:FindFirstChildOfClass("Animator")
                    if not an then an = Instance.new("Animator"); an.Parent = hum end
                    sitTrack = an:LoadAnimation(sitObj)
                    pcall(function() sitTrack.Looped = true; sitTrack:Play(0.1) end)
                    sitActive, sitTarget = true, car
                    sitBtn.Text = "Sit: On"
                    info.Text = "Sat on " .. car.Name; info.TextColor3 = COL_GREEN
                    if sitConn then sitConn:Disconnect() end
                    sitConn = RunService.Heartbeat:Connect(function()
                        if not sitActive then return end
                        if not sitTarget or not sitTarget.Parent then stopSit() return end
                        local ch2, r2 = getRoot()
                        if not ch2 or not r2 then stopSit() return end
                        local cp2 = getChassisPart(sitTarget)
                        if not cp2 then stopSit() return end
                        if not r2:FindFirstChild("_NZSitWeld") then
                            local w2 = Instance.new("WeldConstraint")
                            w2.Name = "_NZSitWeld"; w2.Part0 = r2; w2.Part1 = cp2; w2.Parent = r2
                        end
                        if not sitTrack or not sitTrack.IsPlaying then
                            local hum2 = ch2:FindFirstChildOfClass("Humanoid")
                            if hum2 and sitObj then
                                local an2 = hum2:FindFirstChildOfClass("Animator")
                                if not an2 then an2 = Instance.new("Animator"); an2.Parent = hum2 end
                                local ok, tr = pcall(function() return an2:LoadAnimation(sitObj) end)
                                if ok and tr then sitTrack = tr; pcall(function() sitTrack.Looped = true; sitTrack:Play(0.1) end) end
                            end
                        end
                    end)
                end
            end
            return
        end
        if not flingEnabled then return end
        local ray = camera:ViewportPointToRay(pos.X, pos.Y)
        local pr = RaycastParams.new(); pr.FilterType = Enum.RaycastFilterType.Exclude; pr.FilterDescendantsInstances = { player.Character }
        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 5000, pr)
        if not hit then return end
        local car = findCarModel(hit.Instance); if not car then return end
        if flingMode == "click" then doClickFling(car)
        else
            if holdActive then return end
            local _, root = getRoot(); if not root then return end
            if not getChassisPart(car) then return end
            holdActive, holdTarget, holdReturn = true, car, root.CFrame
            holdConn = RunService.Heartbeat:Connect(function()
                if not holdActive then return end
                if not holdTarget or not holdTarget.Parent then stopHold() return end
                local _, r = getRoot(); if not r then stopHold() return end
                local cc2 = getCarCenter(holdTarget); if not cc2 then stopHold() return end
                local t = os.clock()
                pcall(function()
                    r.CFrame = CFrame.new(cc2 + Vector3.new(0, 2, 0)) * CFrame.Angles(t * 40, t * 52, t * 68)
                    r.AssemblyLinearVelocity = Vector3.zero; r.AssemblyAngularVelocity = Vector3.zero
                end)
                local chas = getChassisPart(holdTarget)
                if chas then
                    local camP = camera.CFrame.Position
                    local dir = Vector3.new(cc2.X - camP.X, 0, cc2.Z - camP.Z)
                    if dir.Magnitude > 0.01 then
                        dir = dir.Unit
                        local m = getCarMass(holdTarget)
                        local push = math.min(12 * (math.max(m, 1) / 1000), 250)
                        pcall(function() chas.AssemblyLinearVelocity = chas.AssemblyLinearVelocity + dir * push end)
                    end
                end
            end)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        local isClick = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
        if isClick and flingMode == "hold" and holdActive then stopHold() end
    end)
    gui.Destroying:Connect(function() stopThrust(); if holdActive then stopHold() end; if sitActive then stopSit() end end)
end


do
    local pageA = pages["Car Mods"]
    local py = pageA.CanvasSize.Y.Offset + 8
    ----------------------------------------------------------------
    -- Brookhaven car mods (moved here)
    ----------------------------------------------------------------
    pageLabel(pageA, py, "Brookhaven car mods", 200)
    local cmRescan = pageApply(pageA, py - 2, 278, "Find car")
    py = py + 26
    local cmStatus = Instance.new("TextLabel")
    cmStatus.Size = UDim2.new(1, -8, 0, 14); cmStatus.Position = UDim2.new(0, 4, 0, py)
    cmStatus.BackgroundTransparency = 1; cmStatus.Text = "Status: Ready"; cmStatus.TextColor3 = COL_GREEN
    cmStatus.Font = Enum.Font.Gotham; cmStatus.TextSize = 10; cmStatus.TextXAlignment = Enum.TextXAlignment.Left; cmStatus.Parent = pageA
    py = py + 18
    pageLabel(pageA, py, "K-Fly Speed");       local cmKFBox = pageBox(pageA, py - 2, 160, 90, "50");  local cmKFApply = pageApply(pageA, py - 2, 258, "Set"); py = py + 30
    pageLabel(pageA, py, "M-Fly Speed");       local cmMFBox = pageBox(pageA, py - 2, 160, 90, "30");  local cmMFApply = pageApply(pageA, py - 2, 258, "Set"); py = py + 30
    pageLabel(pageA, py, "Jump Height (car)"); local cmJHBox = pageBox(pageA, py - 2, 160, 90, "50");  local cmJHApply = pageApply(pageA, py - 2, 258); py = py + 30
    pageLabel(pageA, py, "Float Height");      local cmFHBox = pageBox(pageA, py - 2, 160, 90, "20");  local cmFHApply = pageApply(pageA, py - 2, 258); py = py + 30
    pageLabel(pageA, py, "Fling Power");       local cmFPBox = pageBox(pageA, py - 2, 160, 90, "500"); local cmFPApply = pageApply(pageA, py - 2, 258, "Set"); py = py + 34
    pageLabel(pageA, py, "Keyboard Fly"); local cmKFly = pageToggle(pageA, py - 2, 160); py = py + 30
    pageLabel(pageA, py, "Mouse Fly");    local cmMFly = pageToggle(pageA, py - 2, 160); py = py + 30
    pageLabel(pageA, py, "Car Float");    local cmFloat = pageToggle(pageA, py - 2, 160); py = py + 30
    pageLabel(pageA, py, "Car Jump (R-Click)"); local cmJump = pageToggle(pageA, py - 2, 160); py = py + 30
    pageLabel(pageA, py, "Car Fling");    local cmFling = pageToggle(pageA, py - 2, 160); py = py + 34
    pageLabel(pageA, py, "Car Mouse Control"); local cmcToggle = pageToggle(pageA, py - 2, 160); py = py + 30
    local cmcScan = pageWideBtn(pageA, py, "Scan Car (sit in car)"); py = py + 34
    pageLabel(pageA, py, "Spin Speed"); local cmSpinBox = pageBox(pageA, py - 2, 160, 90, "90"); local cmSpinApply = pageApply(pageA, py - 2, 258, "Set"); py = py + 34
    local cmBrake = pageWideBtn(pageA, py, "Instant Brake (X)"); py = py + 34
    pageLabel(pageA, py, "Car Scale"); local cmScaleBox = pageBox(pageA, py - 2, 160, 90, "1"); local cmScaleApply = pageApply(pageA, py - 2, 258, "Set"); py = py + 34
    local cmCustom = pageWideBtn(pageA, py, "Car Modded Customization"); py = py + 34
    pageLabel(pageA, py, "TP To Player"); local cmTPBox = pageBox(pageA, py - 2, 160, 90, "Username"); local cmTPApply = pageApply(pageA, py - 2, 258, "TP"); py = py + 30
    pageLabel(pageA, py, "TP To Coords"); local cmCDBox = pageBox(pageA, py - 2, 160, 90, "0, 10, 0"); local cmCDApply = pageApply(pageA, py - 2, 258, "TP"); py = py + 34
    pageA.CanvasSize = UDim2.new(0, 0, 0, py + 60)
    ----------------------------------------------------------------
    -- Brookhaven car-mods logic (UI lives above on pageA)
    ----------------------------------------------------------------
    local cmCar, cmFlySpeed, cmMflySpeed, cmJumpH, cmFloatH, cmFlingPow = nil, 50, 30, 50, 20, 500
    local cmKflyOn, cmMflyOn, cmFloatOn, cmJumpOn, cmFlingOn = false, false, false, false, false
    local cmKflyConn, cmMflyConn, cmFloatConn, cmJumpConn, cmFlingConn = nil, nil, nil, nil, nil
    local function cmCarFromSeat()
        local ch = player.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        if not seat then return nil end
        local a = seat
        while a and a.Parent do
            a = a.Parent
            if a:IsA("Model") then return a end
        end
        return nil
    end
    local function cmFindCar()
        local s = cmCarFromSeat()
        if s then return s end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == player.Name .. "Car" then return v end
        end
        local want = player.Name .. "Car"
        local found = nil
        pcall(function()
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("Model") and v.Name == want then found = v break end
            end
        end)
        return found
    end
    local function cmNeedCar()
        cmCar = (cmCar and cmCar.Parent) and cmCar or cmFindCar()
        if not cmCar then cmStatus.Text = "No car found - sit in car + Find car" cmStatus.TextColor3 = COL_RED return nil end
        return cmCar
    end
    local function cmRoot()
        if not cmCar then return nil end
        return cmCar:FindFirstChild("HumanoidRootPart") or cmCar:FindFirstChildWhichIsA("BasePart")
    end
    local function cmZeroVel(model)
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.AssemblyLinearVelocity = Vector3.zero; p.AssemblyAngularVelocity = Vector3.zero end) end
        end
    end
    local function cmSeatedWarn()
        local ch = player.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then return false end
        cmStatus.Text = "Sit in driver seat for physics mods"
        cmStatus.TextColor3 = COL_YELLOW
        return true
    end
    -- saturated colors only: skip white / black / grey pigments
    local function cmIsNeutral(c)
        local mx = math.max(c.R, c.G, c.B)
        local mn = math.min(c.R, c.G, c.B)
        if mx < 0.12 then return true end
        if mn > 0.85 then return true end
        if (mx - mn) < 0.12 then return true end
        return false
    end
    cmCar = cmFindCar()
    if cmCar then cmStatus.Text = "Car: " .. cmCar.Name else cmStatus.Text = "No car - sit in car + Find car" end
    cmRescan.MouseButton1Click:Connect(function()
        cmCar = cmFindCar()
        if cmCar then cmStatus.Text = "Car: " .. cmCar.Name; cmStatus.TextColor3 = COL_GREEN
        else cmStatus.Text = "No car - sit in car + Find car"; cmStatus.TextColor3 = COL_RED end
    end)
    Workspace.DescendantAdded:Connect(function(d)
        if d:IsA("Model") and d.Name == player.Name .. "Car" then cmCar = d end
    end)
    cmKFApply.MouseButton1Click:Connect(function() local n = tonumber(cmKFBox.Text); if n and n > 0 then cmFlySpeed = n; flashOk(cmKFBox) else flashErr(cmKFBox) end end)
    cmMFApply.MouseButton1Click:Connect(function() local n = tonumber(cmMFBox.Text); if n and n > 0 then cmMflySpeed = n; flashOk(cmMFBox) else flashErr(cmMFBox) end end)
    cmJHApply.MouseButton1Click:Connect(function() if tonumber(cmJHBox.Text) then cmJumpH = tonumber(cmJHBox.Text); flashOk(cmJHBox) else flashErr(cmJHBox) end end)
    cmFHApply.MouseButton1Click:Connect(function() if tonumber(cmFHBox.Text) then cmFloatH = tonumber(cmFHBox.Text); flashOk(cmFHBox) else flashErr(cmFHBox) end end)
    cmFPApply.MouseButton1Click:Connect(function() local n = tonumber(cmFPBox.Text); if n and n > 0 then cmFlingPow = n; flashOk(cmFPBox) else flashErr(cmFPBox) end end)
    cmKFly.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        if cmMflyOn then cmMflyOn = false; setToggle(cmMFly, false); if cmMflyConn then pcall(function() cmMflyConn:Disconnect() end) cmMflyConn = nil end end
        cmKflyOn = not cmKflyOn; setToggle(cmKFly, cmKflyOn)
        if cmKflyConn then pcall(function() cmKflyConn:Disconnect() end) cmKflyConn = nil end
        if cmKflyOn then
            cmSeatedWarn(); cmStatus.Text = "K-Fly ON (WASD + Q/E)"
            cmKflyConn = RunService.Heartbeat:Connect(function()
                if not cmKflyOn or not cmCar or not cmCar.Parent then return end
                local ch = player.Character; if not ch then return end
                local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
                local cr = cmRoot(); if not cr then return end
                local md = hum.MoveDirection
                local vel = Vector3.new(md.X, 0, md.Z) * cmFlySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then vel = vel + Vector3.new(0, cmFlySpeed, 0)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.E) then vel = vel - Vector3.new(0, cmFlySpeed, 0) end
                if vel.Magnitude > 0 then
                    pcall(function() cr.AssemblyLinearVelocity = vel; cr.CFrame = cr.CFrame + vel * 0.016 end)
                end
            end)
        else if cmCar then cmZeroVel(cmCar) end end
    end)
    cmMFly.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        if cmKflyOn then cmKflyOn = false; setToggle(cmKFly, false); if cmKflyConn then pcall(function() cmKflyConn:Disconnect() end) cmKflyConn = nil end end
        cmMflyOn = not cmMflyOn; setToggle(cmMFly, cmMflyOn)
        if cmMflyConn then pcall(function() cmMflyConn:Disconnect() end) cmMflyConn = nil end
        if cmMflyOn then
            cmSeatedWarn(); cmStatus.Text = "M-Fly ON (mouse + Q/E)"
            cmMflyConn = RunService.Heartbeat:Connect(function()
                if not cmMflyOn or not cmCar or not cmCar.Parent then return end
                local cam = Workspace.CurrentCamera; if not cam then return end
                local cr = cmRoot(); if not cr then return end
                local mp = UserInputService:GetMouseLocation()
                local ray = cam:ScreenPointToRay(mp.X, mp.Y)
                local dir = (ray.Origin + ray.Direction * 500 - cr.Position)
                if dir.Magnitude < 0.01 then return end
                dir = dir.Unit
                local hd = Vector3.new(dir.X, 0, dir.Z)
                hd = hd.Magnitude > 0.01 and hd.Unit or Vector3.zero
                local up = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then up = Vector3.new(0, cmMflySpeed, 0)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.E) then up = Vector3.new(0, -cmMflySpeed, 0) end
                local vel = hd * cmMflySpeed + up
                pcall(function() cr.AssemblyLinearVelocity = vel; cr.CFrame = cr.CFrame + vel * 0.016 end)
            end)
        else if cmCar then cmZeroVel(cmCar) end end
    end)
    cmFloat.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        cmFloatOn = not cmFloatOn; setToggle(cmFloat, cmFloatOn)
        if cmFloatConn then pcall(function() cmFloatConn:Disconnect() end) cmFloatConn = nil end
        if cmFloatOn then
            cmSeatedWarn(); cmStatus.Text = "Float ON"
            cmFloatConn = RunService.Heartbeat:Connect(function()
                if not cmFloatOn or not cmCar or not cmCar.Parent then return end
                local cr = cmRoot(); if not cr then return end
                local pr = RaycastParams.new(); pr.FilterType = Enum.RaycastFilterType.Exclude; pr.FilterDescendantsInstances = { cmCar }
                local hit = Workspace:Raycast(cr.Position + Vector3.new(0, 10, 0), Vector3.new(0, -100, 0), pr)
                if hit then
                    local ty = hit.Position.Y + cmFloatH
                    local cy = cr.Position.Y
                    if cy < ty then cr.AssemblyLinearVelocity = Vector3.new(cr.AssemblyLinearVelocity.X, (ty - cy) * 8, cr.AssemblyLinearVelocity.Z)
                    elseif cy > ty + 1 then cr.AssemblyLinearVelocity = Vector3.new(cr.AssemblyLinearVelocity.X, -10, cr.AssemblyLinearVelocity.Z) end
                end
            end)
        end
    end)
    cmJump.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        cmJumpOn = not cmJumpOn; setToggle(cmJump, cmJumpOn)
        if cmJumpConn then pcall(function() cmJumpConn:Disconnect() end) cmJumpConn = nil end
        if cmJumpOn then
            cmSeatedWarn(); cmStatus.Text = "Car Jump ON (Right-Click)"
            cmJumpConn = UserInputService.InputBegan:Connect(function(i)
                if isAnyTextBoxFocused() then return end
                if not cmJumpOn or not cmCar then return end
                if i.UserInputType == Enum.UserInputType.MouseButton2 then
                    local cr = cmRoot()
                    if cr then pcall(function() cr.AssemblyLinearVelocity = Vector3.new(cr.AssemblyLinearVelocity.X, cmJumpH, cr.AssemblyLinearVelocity.Z) end) end
                end
            end)
        end
    end)
    cmFling.MouseButton1Click:Connect(function()
        local ch0 = player.Character
        if not ch0 or not ch0:FindFirstChild("HumanoidRootPart") then cmStatus.Text = "No character"; cmStatus.TextColor3 = COL_RED return end
        cmFlingOn = not cmFlingOn; setToggle(cmFling, cmFlingOn)
        if cmFlingConn then pcall(function() cmFlingConn:Disconnect() end) cmFlingConn = nil end
        if cmFlingOn then
            cmStatus.Text = "Fling ON (near others <20)"
            cmFlingConn = RunService.Heartbeat:Connect(function()
                if not cmFlingOn then return end
                local ch = player.Character; if not ch then return end
                local rp = ch:FindFirstChild("HumanoidRootPart"); if not rp then return end
                for _, op in ipairs(Players:GetPlayers()) do
                    if op ~= player and op.Character then
                        local oc = nil
                        for _, m in ipairs(op.Character:GetChildren()) do if m:IsA("Model") and m.Name:find("Car") then oc = m break end end
                        if not oc then
                            for _, m in ipairs(Workspace:GetChildren()) do
                                if m:IsA("Model") and m.Name == op.Name .. "Car" then oc = m break end
                            end
                        end
                        if oc then
                            local okP, piv = pcall(function() return oc:GetPivot().Position end)
                            if okP and (rp.Position - piv).Magnitude < 20 then
                                local cr = oc:FindFirstChild("HumanoidRootPart") or oc:FindFirstChildWhichIsA("BasePart")
                                if cr then
                                    local dir = (cr.Position - rp.Position)
                                    dir = dir.Magnitude > 0.01 and dir.Unit or Vector3.new(0, 1, 0)
                                    pcall(function() cr.AssemblyLinearVelocity = dir * cmFlingPow + Vector3.new(0, cmFlingPow * 0.3, 0) end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
    cmBrake.MouseButton1Click:Connect(function() if not cmNeedCar() then return end cmZeroVel(cmCar) cmStatus.Text = "Braked" end)
    UserInputService.InputBegan:Connect(function(i, gp)
        if gp or isAnyTextBoxFocused() then return end
        if i.KeyCode == Enum.KeyCode.X then
            if cmNeedCar() then cmZeroVel(cmCar) cmStatus.Text = "Braked (X)" end
        end
    end)
    cmScaleApply.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        local s = tonumber(cmScaleBox.Text)
        if s and s > 0 and s <= 5 then
            for _, p in ipairs(cmCar:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.Size = p.Size * s end) end end
            flashOk(cmScaleBox)
        else flashErr(cmScaleBox) end
    end)
    cmCustom.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        local mats = { "Plastic", "Neon", "Metal", "Wood", "Slate", "Concrete", "DiamondPlate" }
        local ms = mats[math.random(1, #mats)]
        local col = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
        local n = 0
        for _, p in ipairs(cmCar:GetDescendants()) do
            if p:IsA("BasePart") and not cmIsNeutral(p.Color) then
                pcall(function() p.Material = Enum.Material[ms] end)
                p.Color = col
                n = n + 1
            end
        end
        cmStatus.Text = "Recolored " .. n .. " colored parts"
    end)
    cmTPApply.MouseButton1Click:Connect(function()
        local q = string.lower(cmTPBox.Text)
        local t = Players:FindFirstChild(cmTPBox.Text)
        if not t then
            for _, p in ipairs(Players:GetPlayers()) do
                if string.sub(string.lower(p.Name), 1, #q) == q then t = p break end
            end
        end
        if not t then cmStatus.Text = "Player not found"; cmStatus.TextColor3 = COL_RED return end
        local ch = player.Character
        if t.Character and ch then
            local rp = ch:FindFirstChild("HumanoidRootPart")
            local tr = t.Character:FindFirstChild("HumanoidRootPart")
            if rp and tr then rp.CFrame = tr.CFrame + Vector3.new(0, 3, 0); cmStatus.Text = "TP to " .. t.Name end
        end
    end)
    cmCDApply.MouseButton1Click:Connect(function()
        local parts = {}
        for w in cmCDBox.Text:gmatch("[^, ]+") do table.insert(parts, tonumber(w)) end
        if #parts >= 3 and parts[1] and parts[2] and parts[3] then
            local ch = player.Character
            local rp = ch and ch:FindFirstChild("HumanoidRootPart")
            if rp then rp.CFrame = CFrame.new(parts[1], parts[2], parts[3]); cmStatus.Text = "Teleported" end
        else flashErr(cmCDBox) end
    end)
    ----------------------------------------------------------------
    -- Car Mouse Control: scan seated, drive unseated via cursor
    ----------------------------------------------------------------
    local cmcCar, cmcOn, cmcHolding, cmcSpin, cmcLoop = nil, false, false, 90, nil
    cmcScan.MouseButton1Click:Connect(function()
        local ch = player.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        if not seat then cmStatus.Text = "Sit in the car first, then Scan"; cmStatus.TextColor3 = COL_RED return end
        local a = seat
        while a and a.Parent do
            a = a.Parent
            if a:IsA("Model") then
                cmcCar = a
                cmStatus.Text = "Locked " .. a.Name .. " - exit seat, hold Left Click"; cmStatus.TextColor3 = COL_GREEN
                return
            end
        end
        cmStatus.Text = "No car model found"; cmStatus.TextColor3 = COL_RED
    end)
    cmSpinApply.MouseButton1Click:Connect(function()
        local n = tonumber(cmSpinBox.Text)
        if n then cmcSpin = math.clamp(n, -720, 720); cmSpinBox.Text = tostring(cmcSpin); flashOk(cmSpinBox)
        else flashErr(cmSpinBox) end
    end)
    cmcToggle.MouseButton1Click:Connect(function()
        if not cmcCar or not cmcCar.Parent then
            cmStatus.Text = "Scan a car first"; cmStatus.TextColor3 = COL_RED
            cmcOn = false; setToggle(cmcToggle, false)
            return
        end
        if cmKflyOn then cmKflyOn = false; setToggle(cmKFly, false); if cmKflyConn then pcall(function() cmKflyConn:Disconnect() end) cmKflyConn = nil end end
        if cmMflyOn then cmMflyOn = false; setToggle(cmMFly, false); if cmMflyConn then pcall(function() cmMflyConn:Disconnect() end) cmMflyConn = nil end end
        cmcOn = not cmcOn; setToggle(cmcToggle, cmcOn)
        if cmcLoop then pcall(function() cmcLoop:Disconnect() end) cmcLoop = nil end
        if cmcOn then
            cmStatus.Text = "Mouse Control ON - hold Left Click (speed: M-Fly)"
            cmcLoop = RunService.Heartbeat:Connect(function(dt)
                if not cmcOn or not cmcHolding then return end
                if not cmcCar or not cmcCar.Parent then
                    cmcHolding = false
                    cmStatus.Text = "Car lost - Scan again"; cmStatus.TextColor3 = COL_RED
                    return
                end
                local ch = player.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.SeatPart then return end
                local cam = Workspace.CurrentCamera
                if not cam then return end
                local mp = UserInputService:GetMouseLocation()
                local okR, ray = pcall(function() return cam:ScreenPointToRay(mp.X, mp.Y) end)
                if not okR or not ray then return end
                local okP, piv = pcall(function() return cmcCar:GetPivot() end)
                if not okP or not piv then return end
                local dist = (ray.Origin - piv.Position).Magnitude
                if dist < 1 then dist = 30 end
                local target = ray.Origin + ray.Direction * dist
                local toT = target - piv.Position
                local newPos = piv.Position
                if toT.Magnitude > 2 then
                    local stepLen = math.min(cmMflySpeed * dt, toT.Magnitude)
                    newPos = piv.Position + toT.Unit * stepLen
                end
                local rot = piv - piv.Position
                local s = math.rad(cmcSpin) * dt
                local newCF = CFrame.new(newPos) * (rot * CFrame.Angles(s, s, s))
                pcall(function() cmcCar:PivotTo(newCF) end)
                for _, p in ipairs(cmcCar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.AssemblyLinearVelocity = Vector3.zero; p.AssemblyAngularVelocity = Vector3.zero end)
                    end
                end
            end)
        else
            cmcHolding = false
            if cmcCar and cmcCar.Parent then
                for _, p in ipairs(cmcCar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.AssemblyLinearVelocity = Vector3.zero; p.AssemblyAngularVelocity = Vector3.zero end)
                    end
                end
            end
            cmStatus.Text = "Mouse Control OFF"
        end
    end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or isAnyTextBoxFocused() then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if cmcOn and cmcCar and cmcCar.Parent then cmcHolding = true end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then cmcHolding = false end
    end)
end

--------------------------------------------------------------------
-- BROOKHAVEN MODULE (Tab: Brookhaven) [FIXED]
--------------------------------------------------------------------
do
    local page = pages["Brookhaven"]
    local y = 4
    pageLabel(page, y, "Brookhaven Car (name .. 'Car')")
    local bhRescan = pageApply(page, y - 2, 258, "Find car")
    y = y + 22
    -- FIX: each speed row now has its own Y + label (original overlapped same yOff)
    pageLabel(page, y, "MaxSpeed");          local bhSpeedBox = pageBox(page, y - 2, 160, 90, "50");   local bhSpeedApply = pageApply(page, y - 2, 258); y = y + 30
    pageLabel(page, y, "Turbo string");      local bhTurboBox = pageBox(page, y - 2, 160, 90, "TurboEnabled"); local bhTurboApply = pageApply(page, y - 2, 258); y = y + 30
    pageLabel(page, y, "Speed Multiplier");  local bhMultBox = pageBox(page, y - 2, 160, 90, "2");     local bhMultApply = pageApply(page, y - 2, 258); y = y + 34

    pageLabel(page, y, "Noclip");       local bhNoclip = pageToggle(page, y - 2, 160); y = y + 34

    pageLabel(page, y, "Player mods", 200); y = y + 22
    pageLabel(page, y, "Infinite Jump"); local bhInfJ = pageToggle(page, y - 2, 160); y = y + 30
    pageLabel(page, y, "WalkSpeed");  local bhWSBox = pageBox(page, y - 2, 160, 90, "16"); local bhWSApply = pageApply(page, y - 2, 258); y = y + 30
    pageLabel(page, y, "JumpPower");  local bhJPBox = pageBox(page, y - 2, 160, 90, "50"); local bhJPApply = pageApply(page, y - 2, 258); y = y + 34
    local bhRespawn = pageWideBtn(page, y, "Respawn"); y = y + 34
    local bhStatus = Instance.new("TextLabel")
    bhStatus.Size = UDim2.new(1, -8, 0, 16); bhStatus.Position = UDim2.new(0, 4, 0, y)
    bhStatus.BackgroundTransparency = 1; bhStatus.Text = "Status: Ready"; bhStatus.TextColor3 = COL_GREEN
    bhStatus.Font = Enum.Font.Gotham; bhStatus.TextSize = 10; bhStatus.TextXAlignment = Enum.TextXAlignment.Left; bhStatus.Parent = page
    page.CanvasSize = UDim2.new(0, 0, 0, y + 30)

    local bhCar, baseMax = nil, nil
    local noclipOn, infJOn = false, false
    local noclipConns, infJConn, origColl = {}, nil, {}

    local function bhCarFromSeat()
        local ch = player.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        if not seat then return nil end
        local a = seat
        while a and a.Parent do
            a = a.Parent
            if a:IsA("Model") then return a end
        end
        return nil
    end
    local function bhDeepFind()
        local want = player.Name .. "Car"
        local found = nil
        pcall(function()
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("Model") and v.Name == want then found = v break end
            end
        end)
        return found
    end
    local function bhFindCar()
        local viaSeat = bhCarFromSeat()
        if viaSeat then return viaSeat end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == player.Name .. "Car" then return v end
        end
        return bhDeepFind()
    end
    local function bhNeedCar()
        bhCar = (bhCar and bhCar.Parent) and bhCar or bhFindCar()
        if not bhCar then bhStatus.Text = "No car found - sit in car + Find car" bhStatus.TextColor3 = COL_RED return nil end
        return bhCar
    end
    bhCar = bhFindCar()
    if bhCar then bhStatus.Text = "Car: " .. bhCar.Name else bhStatus.Text = "No car - sit in car + Find car" end
    bhRescan.MouseButton1Click:Connect(function()
        bhCar = bhFindCar(); baseMax = nil
        if bhCar then bhStatus.Text = "Car: " .. bhCar.Name; bhStatus.TextColor3 = COL_GREEN
        else bhStatus.Text = "No car - sit in car + Find car"; bhStatus.TextColor3 = COL_RED end
    end)
    local function bhBindSeat(ch)
        local hum = ch:WaitForChild("Humanoid", 5); if not hum then return end
        hum.Seated:Connect(function(s)
            if s then
                task.wait(0.3)
                local c = bhCarFromSeat() or bhFindCar()
                if c then bhCar = c; baseMax = nil; bhStatus.Text = "Car: " .. c.Name; bhStatus.TextColor3 = COL_GREEN end
            end
        end)
    end
    if player.Character then bhBindSeat(player.Character) end
    player.CharacterAdded:Connect(bhBindSeat)
    Workspace.DescendantAdded:Connect(function(d)
        if d:IsA("Model") and d.Name == player.Name .. "Car" then bhCar = d; baseMax = nil end
    end)
    local function bhRoot()
        if not bhCar then return nil end
        return bhCar:FindFirstChild("HumanoidRootPart") or bhCar:FindFirstChildWhichIsA("BasePart")
    end
    local function bhVal(nm)
        if not bhCar then return nil end
        local want = string.lower(nm)
        for _, v in ipairs(bhCar:GetDescendants()) do
            if v.Name and string.lower(v.Name) == want then return v end
        end
        return nil
    end
    local function bhListVals()
        if not bhCar then return "-" end
        local names, seen = {}, {}
        for _, v in ipairs(bhCar:GetDescendants()) do
            if (v:IsA("NumberValue") or v:IsA("StringValue") or v:IsA("IntValue")) and not seen[v.Name] then
                seen[v.Name] = true; table.insert(names, v.Name)
            end
        end
        table.sort(names)
        return (#names > 0) and table.concat(names, ", ") or "(no values)"
    end
    bhNoclip.MouseButton1Click:Connect(function()
        if not bhNeedCar() then return end
        noclipOn = not noclipOn; setToggle(bhNoclip, noclipOn)
        if noclipOn then
            for _, p in ipairs(bhCar:GetDescendants()) do
                if p:IsA("BasePart") then
                    if origColl[p] == nil then origColl[p] = { c = p.CanCollide, t = p.CanTouch } end
                    p.CanCollide, p.CanTouch = false, false
                end
            end
            local hb
            hb = RunService.Heartbeat:Connect(function()
                if not noclipOn then return end
                if not bhCar or not bhCar.Parent then
                    local c = bhFindCar()
                    if not c then return end
                    bhCar, baseMax = c, nil
                    bhStatus.Text = "Car: " .. c.Name; bhStatus.TextColor3 = COL_GREEN
                end
                for _, p in ipairs(bhCar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if origColl[p] == nil then origColl[p] = { c = p.CanCollide, t = p.CanTouch } end
                        if p.CanCollide or p.CanTouch then p.CanCollide, p.CanTouch = false, false end
                    end
                end
            end)
            table.insert(noclipConns, hb)
            bhStatus.Text = "Noclip ON"
        else
            for p, d in pairs(origColl) do pcall(function() p.CanCollide = d.c; p.CanTouch = d.t end) end
            origColl = {}
            for _, c in ipairs(noclipConns) do pcall(function() c:Disconnect() end) end
            noclipConns = {}
        end
    end)
    -- FIX: infinite jump via JumpRequest
    bhInfJ.MouseButton1Click:Connect(function()
        infJOn = not infJOn; setToggle(bhInfJ, infJOn)
        if infJConn then pcall(function() infJConn:Disconnect() end) infJConn = nil end
        if infJOn then
            infJConn = UserInputService.JumpRequest:Connect(function()
                local ch = player.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
            end)
        end
    end)
    bhSpeedApply.MouseButton1Click:Connect(function()
        if not bhNeedCar() then return end
        local v = bhVal("MaxSpeed")
        if v and v:IsA("NumberValue") then
            local n = tonumber(bhSpeedBox.Text); if n then v.Value = n; baseMax = n; bhStatus.Text = "MaxSpeed = " .. n; flashOk(bhSpeedBox) else flashErr(bhSpeedBox) end
        else bhStatus.Text = "MaxSpeed not found (" .. bhListVals() .. ")"; bhStatus.TextColor3 = COL_RED end
    end)
    bhTurboApply.MouseButton1Click:Connect(function()
        if not bhNeedCar() then return end
        local v = bhVal("Turbo")
        if v and v:IsA("StringValue") then v.Value = bhTurboBox.Text; bhStatus.Text = "Turbo set"; flashOk(bhTurboBox)
        else bhStatus.Text = "Turbo not found (" .. bhListVals() .. ")"; bhStatus.TextColor3 = COL_RED end
    end)
    bhMultApply.MouseButton1Click:Connect(function()
        local m = tonumber(bhMultBox.Text)
        if not m then flashErr(bhMultBox) return end
        local v = bhVal("MaxSpeed")
        if v and v:IsA("NumberValue") then
            if not baseMax then baseMax = v.Value end
            v.Value = baseMax * m
            flashOk(bhMultBox)
        else bhStatus.Text = "MaxSpeed value not found in car"; bhStatus.TextColor3 = COL_RED end
    end)
    bhWSApply.MouseButton1Click:Connect(function()
        local ch = player.Character; local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then local n = tonumber(bhWSBox.Text); if n then hum.WalkSpeed = n; flashOk(bhWSBox) else flashErr(bhWSBox) end end
    end)
    bhJPApply.MouseButton1Click:Connect(function()
        local ch = player.Character; local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then
            local n = tonumber(bhJPBox.Text)
            if n then
                pcall(function() hum.JumpPower = n end)
                pcall(function() hum.JumpHeight = n / 2 end)
                flashOk(bhJPBox); bhStatus.Text = "Jump set"
            else flashErr(bhJPBox) end
        end
    end)
    bhRespawn.MouseButton1Click:Connect(function()
        local ch = player.Character; local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end

--------------------------------------------------------------------
-- INF SMILE MODULE (Tab: INF Smile) [FIXED precedence + loop]
--------------------------------------------------------------------
do
    local page = pages["INF Smile"]
    local function isTarget(v, keys)
        if not v.Name then return false end
        local nl = string.lower(v.Name)
        for _, k in ipairs(keys) do if nl:find(k) then return true end end
        return false
    end
    local function isKind(v)
        return v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript")
    end
    local flags = {}
    local stores = {}
    local names = { "Infect", "Kill", "SmileGate", "AntiHack", "Spear", "FireLava", "Weight", "Orb", "BlackHole", "Laser" }
    for _, n in ipairs(names) do flags[n] = false; stores[n] = {} end
    local antiInfOn, dupSad, toolCDOn, toolCDVal, toolLoop, seisConn, seisAcc = false, nil, false, 0, nil, nil, 0

    local y = 4
    pageLabel(page, y, "Infectious Smile map cleanup"); y = y + 22
    local btns = {}
    local defs = {
        { "Infect", "Disable InfectParts" }, { "Kill", "Disable Kill" }, { "SmileGate", "Disable SmileGates" },
        { "AntiHack", "Disable Anti-Hack" }, { "Spear", "Disable Spears" }, { "FireLava", "Disable Fire/Lava" },
        { "Weight", "Disable Weight" }, { "Orb", "Delete Orb" }, { "BlackHole", "Disable BlackHole" }, { "Laser", "Disable Lasers" },
    }
    for _, d in ipairs(defs) do
        pageLabel(page, y, d[2], 170); btns[d[1]] = pageToggle(page, y - 2, 200, 70); y = y + 30
    end
    pageLabel(page, y, "Anti-Infection"); local antiBtn = pageToggle(page, y - 2, 200, 70); y = y + 30
    pageLabel(page, y, "Tool Cooldown"); local cdBox = pageBox(page, y - 2, 160, 60, ""); local cdBtn = pageToggle(page, y - 2, 228, 60); y = y + 30
    pageLabel(page, y, "TP to collector"); local tpBox = pageBox(page, y - 2, 160, 110, ""); y = y + 30
    local tpGo = pageWideBtn(page, y, "TP", COL_ACCENT); tpGo.Size = UDim2.new(0, 90, 0, 26)
    local scanC = pageWideBtn(page, y, "Scan"); scanC.Size = UDim2.new(0, 90, 0, 26); scanC.Position = UDim2.new(0, 100, 0, y)
    y = y + 32
    local tipLbl = Instance.new("TextLabel")
    tipLbl.Size = UDim2.new(1, -8, 0, 16); tipLbl.Position = UDim2.new(0, 4, 0, y)
    tipLbl.BackgroundTransparency = 1; tipLbl.Text = "Keep spamming TP button to get the tool!"; tipLbl.TextColor3 = COL_YELLOW
    tipLbl.Font = Enum.Font.Gotham; tipLbl.TextSize = 10; tipLbl.TextXAlignment = Enum.TextXAlignment.Left; tipLbl.Parent = page
    y = y + 20
    local isStatus = Instance.new("TextLabel")
    isStatus.Size = UDim2.new(1, -8, 0, 32); isStatus.Position = UDim2.new(0, 4, 0, y)
    isStatus.BackgroundTransparency = 1; isStatus.Text = "Status: Ready"; isStatus.TextColor3 = COL_GREEN
    isStatus.Font = Enum.Font.Gotham; isStatus.TextSize = 10; isStatus.TextXAlignment = Enum.TextXAlignment.Left
    isStatus.TextWrapped = true; isStatus.Parent = page
    y = y + 36
    local collLbl = Instance.new("TextLabel")
    collLbl.Size = UDim2.new(1, -8, 0, 40); collLbl.Position = UDim2.new(0, 4, 0, y)
    collLbl.BackgroundTransparency = 1; collLbl.Text = "Collection Models: -"; collLbl.TextColor3 = COL_TEXT_DIM
    collLbl.Font = Enum.Font.Gotham; collLbl.TextSize = 10; collLbl.TextXAlignment = Enum.TextXAlignment.Left
    collLbl.TextYAlignment = Enum.TextYAlignment.Top; collLbl.TextWrapped = true; collLbl.Parent = page
    page.CanvasSize = UDim2.new(0, 0, 0, y + 50)

    local function delItems(found, store)
        for _, v in ipairs(found) do
            if v and v.Parent then table.insert(store, { Item = v, Parent = v.Parent }); pcall(function() v.Parent = nil end) end
        end
    end
    local function resItems(store)
        local c = 0; local rm = {}
        for i, d in ipairs(store) do
            if d and d.Item and not d.Item.Parent then
                pcall(function()
                    d.Item.Parent = (d.Parent and d.Parent.Parent ~= nil) and d.Parent or Workspace
                    c = c + 1; table.insert(rm, i)
                end)
            else table.insert(rm, i) end
        end
        table.sort(rm, function(a, b) return a > b end)
        for _, i in ipairs(rm) do table.remove(store, i) end
        return c
    end
    local function scanFor(key)
        local f = {}
        if key == "Infect" then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    for _, c in ipairs(v:GetDescendants()) do
                        if (c:IsA("Script") or c:IsA("LocalScript") or c:IsA("ModuleScript")) and c.Name and string.lower(c.Name):find("infect") then table.insert(f, v) break end
                    end
                end
                if (v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder")) and v.Name then
                    local nl = string.lower(v.Name)
                    if nl:find("infect") or nl:find("aggressivesmiler") then if not table.find(f, v) then table.insert(f, v) end end
                end
            end
        elseif key == "Kill" then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Folder") and v.Name and string.lower(v.Name) == "killbricks" then table.insert(f, v) end
                if v:IsA("BasePart") and v.Name and string.lower(v.Name) == "killzone" then table.insert(f, v) end
            end
        elseif key == "SmileGate" then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if isKind(v) and v.Name and string.lower(v.Name):find("smilegate") then table.insert(f, v) end
            end
        elseif key == "AntiHack" then
            -- FIXED: parenthesised kind check
            for _, v in ipairs(Workspace:GetDescendants()) do
                if isKind(v) and v.Name and isTarget(v, { "anti", "hack", "anticheat", "cheat", "exploit", "bypass", "security" }) then table.insert(f, v) end
            end
        elseif key == "Spear" then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if isKind(v) and v.Name and isTarget(v, { "spear", "javelin", "lance", "pike", "harpoon" }) then table.insert(f, v) end
            end
        elseif key == "FireLava" then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if isKind(v) and v.Name and isTarget(v, { "fire", "lava", "flame", "burn", "ignite", "molten", "magma", "combust", "pyro" }) then table.insert(f, v) end
            end
        elseif key == "Weight" then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name and string.lower(v.Name):find("weight") then table.insert(f, v) end
            end
        elseif key == "Orb" then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name and string.lower(v.Name) == "orb" then table.insert(f, v) end
            end
        elseif key == "BlackHole" then
            local mf = Workspace:FindFirstChild("Map")
            local sf = mf and mf:FindFirstChild("System")
            local bh = sf and sf:FindFirstChild("BlackHole")
            if bh then table.insert(f, bh) end
        elseif key == "Laser" then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if isKind(v) and v.Name and string.lower(v.Name):find("laser") then table.insert(f, v) end
            end
        end
        return f
    end
    local function toggleKey(key)
        flags[key] = not flags[key]
        setToggle(btns[key], flags[key])
        if flags[key] then
            local f = scanFor(key)
            delItems(f, stores[key])
            isStatus.Text = (#f > 0) and ("Deleted " .. #f .. " (" .. key .. ")") or ("No " .. key .. " found")
            if key == "Weight" then
                if seisConn then pcall(function() seisConn:Disconnect() end) seisConn = nil end
                seisAcc = 0
                seisConn = RunService.Heartbeat:Connect(function(dt)
                    seisAcc = seisAcc + dt
                    if seisAcc >= 1 then seisAcc = 0; delItems(scanFor("Weight"), stores.Weight) end
                end)
            end
        else
            local c = resItems(stores[key])
            isStatus.Text = "Restored " .. c .. " (" .. key .. ")"
            if key == "Weight" and seisConn then pcall(function() seisConn:Disconnect() end) seisConn = nil end
        end
    end
    for k, b in pairs(btns) do
        b.MouseButton1Click:Connect(function() toggleKey(k) end)
        pcall(function() b.TouchTap:Connect(function() toggleKey(k) end) end)
    end

    antiBtn.MouseButton1Click:Connect(function()
        antiInfOn = not antiInfOn; setToggle(antiBtn, antiInfOn)
        if antiInfOn then
            local sad = nil
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name and string.lower(v.Name):find("sadwater") then sad = v break end
            end
            if not sad then isStatus.Text = "No SadWater found!"; setToggle(antiBtn, false); antiInfOn = false; return end
            local cl = sad:Clone(); cl.Name = "SadWater_AntiInfection"; cl.Parent = Workspace
            cl.Size = Vector3.new(2000, 2000, 2000); cl.Position = Vector3.new(0, 0, 0); cl.CastShadow = false
            dupSad = cl
            isStatus.Text = "Anti-Infection ON (" .. sad.Name .. ")"
        else
            if dupSad then pcall(function() dupSad:Destroy() end) dupSad = nil end
            isStatus.Text = "Anti-Infection OFF"
        end
    end)
    local function applyCD(v)
        local c = 0
        for _, cont in ipairs({ player:FindFirstChild("Backpack"), player:FindFirstChild("Inventory"), player:FindFirstChild("Hotbar"), player.Character, player:FindFirstChild("StarterGear") }) do
            if cont then for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") then
                    local cv = t:FindFirstChild("Cooldown")
                    if cv and cv:IsA("NumberValue") then pcall(function() cv.Value = v; c = c + 1 end) end
                end
            end end
        end
        return c
    end
    cdBtn.MouseButton1Click:Connect(function()
        toolCDOn = not toolCDOn; setToggle(cdBtn, toolCDOn)
        if toolLoop then pcall(function() toolLoop:Disconnect() end) toolLoop = nil end
        if toolCDOn then
            local n = tonumber(cdBox.Text)
            if not n then flashErr(cdBox); setToggle(cdBtn, false); toolCDOn = false; isStatus.Text = "Enter a valid number"; return end
            toolCDVal = n
            applyCD(n)
            flashOk(cdBox)
            toolLoop = RunService.Heartbeat:Connect(function() if toolCDOn then applyCD(toolCDVal) end end)
            isStatus.Text = "Tool cooldown locked: " .. n
        else isStatus.Text = "Tool cooldown off" end
    end)
    tpGo.MouseButton1Click:Connect(function()
        local nm = tpBox.Text; if nm == "" then return end
        local tm = nil
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and string.lower(v.Name) == string.lower(nm) then tm = v break end
        end
        if not tm then isStatus.Text = "Model not found"; return end
        local tp = tm.PrimaryPart
        if not tp or not tp:IsA("BasePart") then
            for _, v in ipairs(tm:GetDescendants()) do if v:IsA("BasePart") then tp = v break end end
        end
        local ch = player.Character; local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if tp and hrp then pcall(function() hrp.CFrame = tp.CFrame + Vector3.new(0, 3, 0) end) isStatus.Text = "Teleported to " .. tm.Name end
    end)
    scanC.MouseButton1Click:Connect(function()
        local f = {}
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name and string.lower(v.Name):find("collection") then table.insert(f, v.Name) end
        end
        collLbl.Text = (#f > 0) and ("Collection Models:\n• " .. table.concat(f, "\n• ")) or "Collection Models: None found"
    end)
end

--------------------------------------------------------------------
-- BACKDOOR MODULE (Tab: Backdoor) [FIXED forward-declare bug]
--------------------------------------------------------------------
do
    local page = pages["Backdoor"]
    -- FIX: declare BEFORE copy handler uses them
    local resultItems, backdoorsFound = {}, {}
    local exclusions = { "FireOnServer", "SetDefaultColorOnClient", "TakeControl", "ReleaseControl", "SendToClient", "BroadcastToAll", "UpdateClient", "SyncData", "NetworkEvent", "RemoteCall", "ClientEvent", "ServerEvent", "Replicate", "Dispatch", "TriggerClient", "InvokeServer" }

    local y = 4
    pageLabel(page, y, "Backdoor scanner (Workspace remotes)"); y = y + 22
    local bdStatus = Instance.new("TextLabel")
    bdStatus.Size = UDim2.new(1, -8, 0, 20); bdStatus.Position = UDim2.new(0, 4, 0, y)
    bdStatus.BackgroundTransparency = 1; bdStatus.Text = "System Ready"; bdStatus.TextColor3 = COL_GREEN
    bdStatus.Font = Enum.Font.GothamBold; bdStatus.TextSize = 12; bdStatus.TextXAlignment = Enum.TextXAlignment.Left; bdStatus.Parent = page
    y = y + 24
    local scanBtn = pageWideBtn(page, y, "Start Scan", Color3.fromRGB(20, 60, 40)); y = y + 34
    local stopBtn = pageWideBtn(page, y, "Stop Scan", Color3.fromRGB(60, 20, 25)); y = y + 34
    local copyBtn = pageWideBtn(page, y, "Copy All Results"); y = y + 34
    local clearBtn = pageWideBtn(page, y, "Clear"); y = y + 38
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, -8, 0, 300); listFrame.Position = UDim2.new(0, 4, 0, y)
    listFrame.BackgroundTransparency = 1; listFrame.Parent = page

    local function addResult(text, col)
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(1, 0, 0, 30); fr.Position = UDim2.new(0, 0, 0, #resultItems * 34)
        fr.BackgroundColor3 = Color3.fromRGB(15, 15, 25); fr.BackgroundTransparency = 0.3; fr.Parent = listFrame
        corner(fr, 6)
        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -12, 1, 0); tb.Position = UDim2.new(0, 6, 0, 0)
        tb.Text = text; tb.TextColor3 = col or COL_TEXT; tb.TextSize = 11; tb.Font = Enum.Font.Gotham
        tb.BackgroundTransparency = 1; tb.TextXAlignment = Enum.TextXAlignment.Left; tb.ClearTextOnFocus = false; tb.Parent = fr
        table.insert(resultItems, fr)
    end
    local function clearResults()
        for _, it in ipairs(resultItems) do it:Destroy() end
        resultItems, backdoorsFound = {}, {}
        bdStatus.Text = "System Ready"; bdStatus.TextColor3 = COL_GREEN
    end
    local function isExcluded(nm)
        for _, e in ipairs(exclusions) do if nm:find(e) then return true end end
        return false
    end
    addResult("System initialized", COL_GREEN)
    copyBtn.MouseButton1Click:Connect(function()
        if #resultItems == 0 then return end
        local t = "NZ Backdoor Scan Results\n========================\nTotal: " .. #backdoorsFound .. "\n========================\n\n"
        for _, it in ipairs(resultItems) do
            local tb = it:FindFirstChildWhichIsA("TextBox")
            if tb then t = t .. tb.Text .. "\n" end
        end
        local cb = setclipboard or toclipboard
        if cb then pcall(cb, t) copyBtn.Text = "Copied!"; task.wait(1.2); copyBtn.Text = "Copy All Results" end
    end)
    clearBtn.MouseButton1Click:Connect(clearResults)
    local scanning = false
    scanBtn.MouseButton1Click:Connect(function()
        if scanning then return end
        scanning = true; scanBtn.Text = "Scanning..."
        clearResults(); addResult("Scanning...", COL_TEXT_DIM)
        task.wait(0.3)
        local found = {}
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
                local nm = v.Name
                if not isExcluded(nm) then
                    local ln = string.lower(nm)
                    if ln:find("backdoor") or ln:find("exploit") or ln:find("admin") or ln:find("inject") or ln:find("execute")
                        or ln:find("load") or ln:find("script") or ln:find("run") or ln:find("control") or ln:find("command") or ln:find("hack")
                        or ln:find("exec") or ln:find("module") or ln:find("server") or ln:find("client") or ln:find("network")
                        or ln:find("teleport") or ln:find("give") or ln:find("spawn") or ln:find("delete") or ln:find("remove")
                        or ln:find("kick") or ln:find("ban") or ln:find("mute") or ln:find("unmute") or ln:find("god")
                        or ln:find("fly") or ln:find("noclip") or ln:find("speed") or ln:find("jump") or ln:find("kill")
                        or ln:find("heal") or ln:find("loop") or ln:find("bypass") then
                        table.insert(found, v)
                    end
                end
            end
        end
        clearResults()
        for _, v in ipairs(found) do
            table.insert(backdoorsFound, v)
            addResult("Found: " .. v.Name .. " (" .. v.ClassName .. ")", COL_YELLOW)
        end
        if #found > 0 then
            bdStatus.Text = "Found " .. #found .. " potential backdoors"; bdStatus.TextColor3 = COL_YELLOW
            addResult("Scan complete - " .. #found .. " found", COL_GREEN)
        else
            bdStatus.Text = "No backdoors found"; bdStatus.TextColor3 = COL_GREEN
            addResult("Scan complete - clean", COL_GREEN)
        end
        scanBtn.Text = "Start Scan"; scanning = false
    end)
    stopBtn.MouseButton1Click:Connect(function()
        if scanning then
            scanning = false
            scanBtn.Text = "Start Scan"
            bdStatus.Text = "Scan stopped"
            bdStatus.TextColor3 = COL_YELLOW
            addResult("Scan interrupted", COL_YELLOW)
        end
    end)
    page.CanvasSize = UDim2.new(0, 0, 0, y + 320)
end

--------------------------------------------------------------------
-- UTILITY MODULE (Tab: Utility)
--------------------------------------------------------------------
do
    local page = pages["Utility"]
    local y = 6
    pageLabel(page, y, "Session / server"); y = y + 24
    local rjBtn = pageWideBtn(page, y, "Rejoin Server", COL_ACCENT); y = y + 34
    local rjStatus = Instance.new("TextLabel")
    rjStatus.Size = UDim2.new(1, -8, 0, 16); rjStatus.Position = UDim2.new(0, 4, 0, y)
    rjStatus.BackgroundTransparency = 1; rjStatus.Text = ("Place %d | Job %s"):format(game.PlaceId, game.JobId)
    rjStatus.TextColor3 = COL_TEXT_DIM; rjStatus.Font = Enum.Font.Gotham; rjStatus.TextSize = 10
    rjStatus.TextXAlignment = Enum.TextXAlignment.Left; rjStatus.TextWrapped = true; rjStatus.Parent = page
    y = y + 22
    local copyJob = pageWideBtn(page, y, "Copy JobId"); y = y + 34
    local copyPlace = pageWideBtn(page, y, "Copy PlaceId"); y = y + 34
    local destroyBtn = pageWideBtn(page, y, "Destroy NZ-HUB", Color3.fromRGB(80, 20, 20)); y = y + 40
    pageLabel(page, y, "NZ-HUB unified. Insert = minimize."); y = y + 22
    page.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    rjBtn.MouseButton1Click:Connect(function()
        rjStatus.Text = "Rejoining..."
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
    end)
    copyJob.MouseButton1Click:Connect(function()
        local cb = setclipboard or toclipboard
        if cb then pcall(cb, game.JobId) copyJob.Text = "Copied!" task.wait(1) copyJob.Text = "Copy JobId" end
    end)
    copyPlace.MouseButton1Click:Connect(function()
        local cb = setclipboard or toclipboard
        if cb then pcall(cb, tostring(game.PlaceId)) copyPlace.Text = "Copied!" task.wait(1) copyPlace.Text = "Copy PlaceId" end
    end)
    destroyBtn.MouseButton1Click:Connect(function()
        if _G.__NZFlyStop then pcall(_G.__NZFlyStop) end
        if _G.__NZSitStop then pcall(_G.__NZSitStop) end
        pcall(function() blur:Destroy() end)
        gui:Destroy()
        _G.__NZHUB, _G.__NZHub = nil, nil
    end)
end

print("NZ-HUB loaded: Car Mods / Brookhaven / INF Smile / Backdoor / Utility")
