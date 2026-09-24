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

    end
end
_G.__NZFlyActive = false
_G.__NZFlyStop = nil
_G.__NZFlyHold = { forward = false, back = false, up = false, down = false, left = false, right = false }

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
local function isVehicleModel(m)
    if not m:IsA("Model") then return false end
    local parts, hasSeat, hasWheel = 0, false, false
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("BasePart") then parts = parts + 1 end
        if d:IsA("Seat") or d:IsA("VehicleSeat") then hasSeat = true end
        local nm = d.Name
        if nm == "Wheels" or nm == "FL" or nm == "FR" or nm == "Body" or nm == "Chassis" then hasWheel = true end
        if parts >= 3 and (hasSeat or hasWheel) then return true end
        if parts > 300 then break end
    end
    return false
end

local function findRiddenModelFallback()
    local ch = player.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pp = root.Position
    for _, m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") and isVehicleModel(m) then
            local ok, cf, size = pcall(function() return m:GetBoundingBox() end)
            if ok and cf then
                local rel = cf:PointToObjectSpace(pp)
                if math.abs(rel.X) <= size.X * 0.5 + 2
                    and math.abs(rel.Y) <= size.Y * 0.5 + 3
                    and math.abs(rel.Z) <= size.Z * 0.5 + 2 then
                    return m
                end
            end
        end
    end
    return nil
end

local WIN_W, WIN_H = 640, 440
if isMobile then
    local vp0 = camera.ViewportSize
    WIN_W = math.clamp(vp0.X - 20, 300, 420)
    WIN_H = math.clamp(vp0.Y - 120, 320, 440)
end

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

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -24, 0, 30)
tabBar.Position = UDim2.new(0, 12, 0, 42)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local TAB_DEFS = { "Car Mods", "Brookhaven", "Player", "INF Smile", "Backdoor", "Utility" }
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
    pg.ScrollingDirection = isMobile and Enum.ScrollingDirection.XY or Enum.ScrollingDirection.Y
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
if isMobile then for _, b in pairs(tabBtns) do b.TextSize = 9 end end
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
camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    main.Position = UDim2.new(0.5, -WIN_W / 2, 0.45, -WIN_H / 2)
end)

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

    task.spawn(function()
        while gui.Parent do
            task.wait(1)
            if not state.currentCar then
                local ch = player.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Sit and not hum.SeatPart then
                    local c = findRiddenModelFallback()
                    if c then
                        state.currentCar = c
                        state.flipState = nil
                        local chp = getChassisPart(c)
                        state.currentBody = chp
                        status.Text = c.Name .. " (riding)"
                        status.TextColor3 = COL_GREEN
                        info.Text = chp and ("chassis  " .. chp.Name) or "chassis not found"
                    end
                end
            end
        end
    end)

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

    local flyConn, flyActive = nil, false
    local function stopFly()
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if not flyActive then return end
        flyActive = false; _G.__NZFlyActive = false
        for k in pairs(_G.__NZFlyHold) do _G.__NZFlyHold[k] = false end
        if state.currentCar then
            for _, p in ipairs(state.currentCar:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.AssemblyLinearVelocity = Vector3.zero; p.AssemblyAngularVelocity = Vector3.zero end)
                end
            end
        end
        flyToggle.Text = "Car Fly: Off"
        flyToggle.BackgroundColor3 = COL_BG_ALT; flyToggle.TextColor3 = COL_TEXT_DIM
    end
    _G.__NZFlyStop = stopFly
    local function startFly()
        if flyActive or not state.currentCar then return end
        local ch = getChassisPart(state.currentCar); if not ch then return end
        flyActive = true; _G.__NZFlyActive = true
        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.Heartbeat:Connect(function(dt)
            if not flyActive then return end
            if not state.currentCar or not state.currentCar.Parent then stopFly() return end
            local chas = getChassisPart(state.currentCar)
            if not chas or not chas.Parent then stopFly() return end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local h = _G.__NZFlyHold
            local fwd = cam.CFrame.LookVector
            fwd = Vector3.new(fwd.X, 0, fwd.Z)
            if fwd.Magnitude < 0.01 then fwd = Vector3.new(0, 0, -1) else fwd = fwd.Unit end
            local right = cam.CFrame.RightVector
            right = Vector3.new(right.X, 0, right.Z)
            if right.Magnitude < 0.01 then right = Vector3.new(1, 0, 0) else right = right.Unit end
            local mv = Vector3.zero
            if h.forward then mv = mv + fwd end
            if h.back then mv = mv - fwd end
            if h.right then mv = mv + right end
            if h.left then mv = mv - right end
            local vy = 0
            if h.up then vy = vy + 1 end
            if h.down then vy = vy - 1 end
            if mv.Magnitude < 0.01 and vy == 0 then
                pcall(function()
                    chas.AssemblyLinearVelocity = Vector3.zero
                    chas.AssemblyAngularVelocity = Vector3.zero
                end)
                return
            end
            local vel = Vector3.zero
            if mv.Magnitude > 0.01 then vel = vel + mv.Unit * currentFlySpeed end
            if vy ~= 0 then vel = vel + Vector3.new(0, vy * currentFlyVert, 0) end
            pcall(function()
                chas.AssemblyLinearVelocity = vel
                chas.CFrame = chas.CFrame + vel * math.min(dt, 0.05)
            end)
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

    pageLabel(pageA, py, "Server-Sided Car Mods", 200)
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
    pageLabel(pageA, py, "Fly Up / Down"); local kfUpH, kfDnH = false, false
    local kfUpBtn = pageToggle(pageA, py - 2, 160, 76); kfUpBtn.Text = "Up"; kfUpBtn.TextColor3 = COL_TEXT; kfUpBtn.BackgroundColor3 = COL_BG_ALT
    local kfDnBtn = pageToggle(pageA, py - 2, 242, 76); kfDnBtn.Text = "Down"; kfDnBtn.TextColor3 = COL_TEXT; kfDnBtn.BackgroundColor3 = COL_BG_ALT
    py = py + 30
    local function kfHold(btn, setter)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                setter(true)
                TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = COL_GREEN }):Play()
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                setter(false)
                TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = COL_BG_ALT }):Play()
            end
        end)
    end
    kfHold(kfUpBtn, function(v) kfUpH = v end)
    kfHold(kfDnBtn, function(v) kfDnH = v end)
    pageLabel(pageA, py, "Car Float");    local cmFloat = pageToggle(pageA, py - 2, 160); py = py + 30
    pageLabel(pageA, py, "Car Jump (R-Click)"); local cmJump = pageToggle(pageA, py - 2, 160); py = py + 30
    local cmJumpBtn = pageWideBtn(pageA, py, "JUMP"); py = py + 34
    pageLabel(pageA, py, "Car Fling");    local cmFling = pageToggle(pageA, py - 2, 160); py = py + 34
    pageLabel(pageA, py, "Car Mouse Control"); local cmcToggle = pageToggle(pageA, py - 2, 160); py = py + 30
    local cmcMode = pageWideBtn(pageA, py, "Spin: In-place"); py = py + 34
    pageLabel(pageA, py, "Spin X Y Z"); local cmSpinX = pageBox(pageA, py - 2, 150, 52, "0"); local cmSpinY = pageBox(pageA, py - 2, 208, 52, "90"); local cmSpinZ = pageBox(pageA, py - 2, 266, 52, "0"); local cmSpinApply = pageApply(pageA, py - 2, 324, "Set"); py = py + 30
    pageLabel(pageA, py, "Spin Enabled"); local cmSpinTog = pageToggle(pageA, py - 2, 160); setToggle(cmSpinTog, false); py = py + 30
    local cmDistLbl = pageLabel(pageA, py, "Dist: 0 (B/P)", 200); py = py + 22
    local cmcUp, cmcDown, cmcPull, cmcPush = false, false, false, false
    local mcTouch = { { "Up", "up" }, { "Down", "down" }, { "In", "in" }, { "Out", "out" } }
    for i, d in ipairs(mcTouch) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 80, 0, 28)
        b.Position = UDim2.new(0, 4 + (i - 1) * 86, 0, py)
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
        local function mcSet(v)
            if key == "up" then cmcUp = v
            elseif key == "down" then cmcDown = v
            elseif key == "in" then cmcPull = v
            else cmcPush = v end
            if v then TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = COL_GREEN }):Play()
            else TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = COL_BG_ALT }):Play() end
        end
        b.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then mcSet(true) end
        end)
        b.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then mcSet(false) end
        end)
    end
    py = py + 32
    local cmBrake = pageWideBtn(pageA, py, "Instant Brake (X)"); py = py + 34
    pageLabel(pageA, py, "Car Scale"); local cmScaleBox = pageBox(pageA, py - 2, 160, 90, "1"); local cmScaleApply = pageApply(pageA, py - 2, 258, "Set"); py = py + 30
    pageLabel(pageA, py, "Car Hitbox"); local cmHBBox = pageBox(pageA, py - 2, 160, 90, "1"); local cmHBApply = pageApply(pageA, py - 2, 258, "Set"); py = py + 34
    local cmCustom = pageWideBtn(pageA, py, "Car Modded Customization"); py = py + 34
    pageLabel(pageA, py, "TP To Player"); local cmTPBox = pageBox(pageA, py - 2, 160, 90, "Username"); local cmTPApply = pageApply(pageA, py - 2, 258, "TP"); py = py + 30
    pageLabel(pageA, py, "TP To Coords"); local cmCDBox = pageBox(pageA, py - 2, 160, 90, "0, 10, 0"); local cmCDApply = pageApply(pageA, py - 2, 258, "TP"); py = py + 34
    pageLabel(pageA, py, "Orbit Car"); local cmOrbTog = pageToggle(pageA, py - 2, 160); py = py + 30
    pageLabel(pageA, py, "Orbit Speed"); local cmOrbBox = pageBox(pageA, py - 2, 160, 90, "60"); local cmOrbApply = pageApply(pageA, py - 2, 258, "Set"); py = py + 34
    pageLabel(pageA, py, "Car Noclip"); local cmNoclipBtn = pageToggle(pageA, py - 2, 160); py = py + 30
    pageLabel(pageA, py, "Concrete Solid"); local cmConcTog = pageToggle(pageA, py - 2, 160); py = py + 34
    pageA.CanvasSize = UDim2.new(0, 0, 0, py + 60)

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
        local r = findRiddenModelFallback()
        if r then return r end
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

    local function cmIsNeutral(c)
        local mx = math.max(c.R, c.G, c.B)
        local mn = math.min(c.R, c.G, c.B)
        if mx < 0.2 then return true end
        if mn > 0.8 then return true end
        if (mx - mn) < 0.15 then return true end
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
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) or kfUpH then vel = vel + Vector3.new(0, cmFlySpeed, 0)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.E) or kfDnH then vel = vel - Vector3.new(0, cmFlySpeed, 0) end
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
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) or kfUpH then up = Vector3.new(0, cmMflySpeed, 0)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.E) or kfDnH then up = Vector3.new(0, -cmMflySpeed, 0) end
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
    cmJumpBtn.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        local cr = cmRoot()
        if cr then pcall(function() cr.AssemblyLinearVelocity = Vector3.new(cr.AssemblyLinearVelocity.X, cmJumpH, cr.AssemblyLinearVelocity.Z) end) end
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
    local cmHbMult, cmHbOrig, cmHbCar = 1, {}, nil
    cmHBApply.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        local s = tonumber(cmHBBox.Text)
        if not (s and s >= 0.5 and s <= 10) then flashErr(cmHBBox) return end
        cmHbMult = s
        if cmHbCar ~= cmCar then cmHbCar = cmCar; cmHbOrig = {} end
        for _, p in ipairs(cmCar:GetDescendants()) do
            if p:IsA("BasePart") then
                if cmHbOrig[p] == nil then cmHbOrig[p] = p.Size end
                pcall(function() p.Size = cmHbOrig[p] * cmHbMult end)
            end
        end
        cmHBBox.Text = tostring(cmHbMult); flashOk(cmHBBox)
        cmStatus.Text = "Car hitbox x" .. tostring(cmHbMult); cmStatus.TextColor3 = COL_GREEN
    end)
    cmCustom.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        local mats = { "Plastic", "Neon", "Metal", "Wood", "Slate", "Concrete", "DiamondPlate" }
        local ms = mats[math.random(1, #mats)]
        local col = Color3.fromRGB(255, 0, 0)
        for _ = 1, 25 do
            local c = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
            if not cmIsNeutral(c) then col = c break end
        end
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

    local cmcCar, cmcOn, cmcHolding, cmcLoop = nil, false, false, nil
    local cmcDot, cmcTagT, cmcColChanged = nil, 0, {}
    local cmcAlt = 0
    local cmcSpinX, cmcSpinY, cmcSpinZ = 0, 90, 0
    local cmcOrbit, cmcDist, cmcBase, cmcSpinOn = false, 0, 0, false
    cmSpinTog.MouseButton1Click:Connect(function()
        cmcSpinOn = not cmcSpinOn; setToggle(cmSpinTog, cmcSpinOn)
    end)
    cmSpinApply.MouseButton1Click:Connect(function()
        local nx, ny, nz = tonumber(cmSpinX.Text), tonumber(cmSpinY.Text), tonumber(cmSpinZ.Text)
        if nx and ny and nz then
            cmcSpinX = math.clamp(nx, -720, 720); cmcSpinY = math.clamp(ny, -720, 720); cmcSpinZ = math.clamp(nz, -720, 720)
            cmSpinX.Text, cmSpinY.Text, cmSpinZ.Text = tostring(cmcSpinX), tostring(cmcSpinY), tostring(cmcSpinZ)
            flashOk(cmSpinX); flashOk(cmSpinY); flashOk(cmSpinZ)
        else flashErr(cmSpinX) end
    end)
    cmcMode.MouseButton1Click:Connect(function()
        cmcOrbit = not cmcOrbit
        cmcMode.Text = cmcOrbit and "Spin: Around Cursor" or "Spin: In-place"
        TweenService:Create(cmcMode, TweenInfo.new(0.15), { BackgroundColor3 = COL_ACCENT }):Play()
    end)
    cmcToggle.MouseButton1Click:Connect(function()
        if not cmNeedCar() then
            cmcOn = false; setToggle(cmcToggle, false)
            return
        end
        cmcCar = cmCar
        if cmKflyOn then cmKflyOn = false; setToggle(cmKFly, false); if cmKflyConn then pcall(function() cmKflyConn:Disconnect() end) cmKflyConn = nil end end
        if cmMflyOn then cmMflyOn = false; setToggle(cmMFly, false); if cmMflyConn then pcall(function() cmMflyConn:Disconnect() end) cmMflyConn = nil end end
        if cmOrbOn then cmOrbOn = false; setToggle(cmOrbTog, false); if cmOrbLoop then pcall(function() cmOrbLoop:Disconnect() end) cmOrbLoop = nil end end
        cmcOn = not cmcOn; setToggle(cmcToggle, cmcOn)
        if cmcLoop then pcall(function() cmcLoop:Disconnect() end) cmcLoop = nil end
        if cmcOn then
            cmStatus.Text = "Mouse Control ON - hold Left Click"
            cmcDist = 0; cmDistLbl.Text = "Dist: 0 (B/P)"
            cmcAlt = 0
            if not cmcDot or not cmcDot.Parent then
                pcall(function()
                    if cmcDot then cmcDot:Destroy() end
                    local d = Instance.new("Part")
                    d.Name = "_NZCursorDot"
                    d.Shape = Enum.PartType.Ball
                    d.Size = Vector3.new(0.6, 0.6, 0.6)
                    d.Color = Color3.fromRGB(0, 255, 150)
                    d.Material = Enum.Material.Neon
                    d.Transparency = 1
                    d.Anchored = true
                    d.CanCollide = false
                    d.CanQuery = false
                    d.CanTouch = false
                    d.Parent = Workspace
                    cmcDot = d
                end)
            end
            pcall(function()
                local ps = game:GetService("PhysicsService")
                pcall(function() ps:RegisterCollisionGroup("NZMyCar") end)
                pcall(function() ps:RegisterCollisionGroup("NZOtherCars") end)
                ps:CollisionGroupSetCollidable("NZMyCar", "NZOtherCars", false)
                ps:CollisionGroupSetCollidable("NZMyCar", "Default", true)
                ps:CollisionGroupSetCollidable("NZOtherCars", "Default", true)
            end)
            local function cmcTagCars()
                if not cmcCar or not cmcCar.Parent then return end
                for _, p in ipairs(cmcCar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if cmcColChanged[p] == nil then cmcColChanged[p] = p.CollisionGroup end
                        pcall(function() p.CollisionGroup = "NZMyCar" end)
                    end
                end
                for _, m in ipairs(Workspace:GetDescendants()) do
                    if m:IsA("Model") and m ~= cmcCar and m.Name:find("Car") then
                        for _, p in ipairs(m:GetDescendants()) do
                            if p:IsA("BasePart") then
                                if cmcColChanged[p] == nil then cmcColChanged[p] = p.CollisionGroup end
                                pcall(function() p.CollisionGroup = "NZOtherCars" end)
                            end
                        end
                    end
                end
            end
            cmcTagCars()
            cmcLoop = RunService.Heartbeat:Connect(function(dt)
                if not cmcOn or not cmcHolding then return end
                if not cmcCar or not cmcCar.Parent then
                    cmcHolding = false
                    cmStatus.Text = "Car lost - Scan again"; cmStatus.TextColor3 = COL_RED
                    return
                end
                cmcTagT = cmcTagT + dt
                if cmcTagT >= 3 then cmcTagT = 0 cmcTagCars() end
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
                if cmcPull then cmcDist = math.max(-150, cmcDist - 60 * dt) end
                if cmcPush then cmcDist = math.min(300, cmcDist + 60 * dt) end
                cmDistLbl.Text = "Dist: " .. tostring(math.floor(cmcDist + 0.5)) .. " (B/P)"
                local f1 = {}
                if player.Character then table.insert(f1, player.Character) end
                if cmcDot and cmcDot.Parent then table.insert(f1, cmcDot) end
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Exclude
                rp.FilterDescendantsInstances = f1
                local hit = Workspace:Raycast(ray.Origin, ray.Direction * 2000, rp)
                local selfHit = hit and cmcCar and cmcCar.Parent and hit.Instance:IsDescendantOf(cmcCar)
                local useHit = hit
                if selfHit then
                    local f2 = { cmcCar }
                    if player.Character then table.insert(f2, player.Character) end
                    if cmcDot and cmcDot.Parent then table.insert(f2, cmcDot) end
                    local r2 = RaycastParams.new()
                    r2.FilterType = Enum.RaycastFilterType.Exclude
                    r2.FilterDescendantsInstances = f2
                    useHit = Workspace:Raycast(hit.Position + ray.Direction * 0.5, ray.Direction * 2000, r2)
                end
                local surfHit = useHit and (useHit.Position - ray.Origin).Magnitude <= 1000
                local aim
                if surfHit then
                    aim = useHit.Position
                elseif selfHit then
                    aim = piv.Position
                else
                    local dist = (cmcBase > 0 and cmcBase or (ray.Origin - piv.Position).Magnitude) + cmcDist
                    if dist < 5 then dist = 5 end
                    aim = ray.Origin + ray.Direction * dist
                end
                if cmcDot and cmcDot.Parent then
                    cmcDot.Transparency = 0.3
                    pcall(function() cmcDot.CFrame = CFrame.new(aim) end)
                end
                local target = aim
                if surfHit then
                    local okB, _, bbSize = pcall(function() return cmcCar:GetBoundingBox() end)
                    local hover = (okB and bbSize) and (bbSize.Y * 0.5 + 0.5) or 2
                    target = aim + Vector3.new(0, hover, 0) + ray.Direction * cmcDist
                end
                local vy = (cmcUp and 1 or 0) - (cmcDown and 1 or 0)
                if vy ~= 0 then cmcAlt = math.clamp(cmcAlt + vy * cmMflySpeed * dt, -500, 500) end
                local newPos = target + Vector3.new(0, cmcAlt, 0)
                local rot = piv - piv.Position
                local spinCF = CFrame.new(0, 0, 0)
                if cmcSpinOn then
                    spinCF = CFrame.Angles(math.rad(cmcSpinX) * dt, math.rad(cmcSpinY) * dt, math.rad(cmcSpinZ) * dt)
                end
                local newCF
                if cmcOrbit then
                    local newRel = spinCF * (newPos - target)
                    newPos = target + newRel
                    newCF = CFrame.new(newPos) * (rot * spinCF)
                else
                    newCF = CFrame.new(newPos) * (rot * spinCF)
                end
                pcall(function() cmcCar:PivotTo(newCF) end)
                for _, p in ipairs(cmcCar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.AssemblyLinearVelocity = Vector3.zero; p.AssemblyAngularVelocity = Vector3.zero end)
                    end
                end
            end)
        else
            cmcHolding = false
            for p, g in pairs(cmcColChanged) do pcall(function() p.CollisionGroup = g end) end
            cmcColChanged = {}
            if cmcDot then pcall(function() cmcDot:Destroy() end) cmcDot = nil end
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
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if isAnyTextBoxFocused() then return end
            if input.KeyCode == Enum.KeyCode.Q then cmcUp = true return end
            if input.KeyCode == Enum.KeyCode.E then cmcDown = true return end
            if input.KeyCode == Enum.KeyCode.P then cmcPull = true return end
            if input.KeyCode == Enum.KeyCode.B then cmcPush = true return end
            return
        end
        if gp or isAnyTextBoxFocused() then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if cmcOn and cmcCar and cmcCar.Parent then
                cmcHolding = true
                local cam0 = Workspace.CurrentCamera
                local ok0, piv0 = pcall(function() return cmcCar:GetPivot() end)
                if cam0 and ok0 and piv0 then
                    cmcBase = (cam0.CFrame.Position - piv0.Position).Magnitude
                else cmcBase = 0 end
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Q then cmcUp = false return end
            if input.KeyCode == Enum.KeyCode.E then cmcDown = false return end
            if input.KeyCode == Enum.KeyCode.P then cmcPull = false return end
            if input.KeyCode == Enum.KeyCode.B then cmcPush = false return end
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            cmcHolding = false
            if cmcDot and cmcDot.Parent then cmcDot.Transparency = 1 end
        end
    end)

    local cmOrbOn, cmOrbSpeed, cmOrbLoop = false, 60, nil
    local cmOrbAng, cmOrbRad, cmOrbY, cmOrbRot = 0, 15, 0, CFrame.new(0, 0, 0)
    cmOrbApply.MouseButton1Click:Connect(function()
        local n = tonumber(cmOrbBox.Text)
        if n then cmOrbSpeed = math.clamp(n, -360, 360); cmOrbBox.Text = tostring(cmOrbSpeed); flashOk(cmOrbBox)
        else flashErr(cmOrbBox) end
    end)
    cmOrbTog.MouseButton1Click:Connect(function()
        if not cmNeedCar() then return end
        if cmKflyOn then cmKflyOn = false; setToggle(cmKFly, false); if cmKflyConn then pcall(function() cmKflyConn:Disconnect() end) cmKflyConn = nil end end
        if cmMflyOn then cmMflyOn = false; setToggle(cmMFly, false); if cmMflyConn then pcall(function() cmMflyConn:Disconnect() end) cmMflyConn = nil end end
        if cmcOn then cmcOn = false; setToggle(cmcToggle, false); cmcHolding = false; if cmcLoop then pcall(function() cmcLoop:Disconnect() end) cmcLoop = nil end end
        cmOrbOn = not cmOrbOn; setToggle(cmOrbTog, cmOrbOn)
        if cmOrbLoop then pcall(function() cmOrbLoop:Disconnect() end) cmOrbLoop = nil end
        if cmOrbOn then
            local ch = player.Character
            local rp = ch and ch:FindFirstChild("HumanoidRootPart")
            local okP, piv = pcall(function() return cmCar:GetPivot() end)
            if not rp or not okP or not piv then
                cmStatus.Text = "Need character + car"; cmStatus.TextColor3 = COL_RED
                cmOrbOn = false; setToggle(cmOrbTog, false)
                return
            end
            local off = piv.Position - rp.Position
            cmOrbRad = math.max(Vector3.new(off.X, 0, off.Z).Magnitude, 5)
            cmOrbY = off.Y
            cmOrbAng = math.atan2(off.X, off.Z)
            cmOrbRot = piv - piv.Position
            cmStatus.Text = string.format("Orbit ON (%d/s, R %d)", cmOrbSpeed, math.floor(cmOrbRad + 0.5))
            cmOrbLoop = RunService.Heartbeat:Connect(function(dt)
                if not cmOrbOn then return end
                if not cmCar or not cmCar.Parent then
                    cmOrbOn = false; setToggle(cmOrbTog, false)
                    cmStatus.Text = "Car lost - Find car again"; cmStatus.TextColor3 = COL_RED
                    return
                end
                local ch2 = player.Character
                local rp2 = ch2 and ch2:FindFirstChild("HumanoidRootPart")
                if not rp2 then return end
                cmOrbAng = cmOrbAng + math.rad(cmOrbSpeed) * dt
                local off2 = Vector3.new(math.sin(cmOrbAng) * cmOrbRad, cmOrbY, math.cos(cmOrbAng) * cmOrbRad)
                pcall(function() cmCar:PivotTo(CFrame.new(rp2.Position + off2) * cmOrbRot) end)
                for _, p in ipairs(cmCar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.AssemblyLinearVelocity = Vector3.zero; p.AssemblyAngularVelocity = Vector3.zero end)
                    end
                end
            end)
        else
            if cmCar and cmCar.Parent then
                for _, p in ipairs(cmCar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.AssemblyLinearVelocity = Vector3.zero; p.AssemblyAngularVelocity = Vector3.zero end)
                    end
                end
            end
            cmStatus.Text = "Orbit OFF"
        end
    end)
    local cnOn, cnSaved, cnConns, cnCarCache = false, {}, {}, {}
    local cnConcreteSolid = false
    local function cnIsCarPart(inst)
        local a = inst.Parent
        while a and a ~= Workspace do
            if a:IsA("Model") then
                if cnCarCache[a] == nil then
                    local nm = string.lower(a.Name)
                    cnCarCache[a] = (nm:find("car") ~= nil) or isVehicleModel(a)
                end
                if cnCarCache[a] then return true end
            end
            a = a.Parent
        end
        return false
    end
    local function cnKeepSolid(p)
        local nm = string.lower(p.Name)
        if nm:find("floor") or nm:find("ground") then return true end
        local c = p.Color
        if c.G > c.R and c.G > c.B and c.G > 0.3 then return true end
        if c.R > c.B and c.G > c.B * 0.8 and c.R > 0.25 and (c.R - c.B) > 0.1 then return true end
        local mn = string.lower(p.Material.Name)
        if mn:find("grass") or mn:find("dirt") or mn:find("mud") or mn:find("sand")
            or mn:find("soil") or mn:find("asphalt") or mn:find("ground") then
            return true
        end
        return false
    end
    local function cnIsConcrete(p)
        local ok, r = pcall(function() return string.lower(p.Material.Name):find("concrete") ~= nil end)
        return ok and r
    end
    cmNoclipBtn.MouseButton1Click:Connect(function()
        cnOn = not cnOn; setToggle(cmNoclipBtn, cnOn)
        if cnOn then
            cnCarCache = {}
            local kept, cut = 0, 0
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("BasePart") and not cnIsCarPart(d) then
                    if cnKeepSolid(d) or (cnConcreteSolid and cnIsConcrete(d)) then kept = kept + 1
                    else
                        if cnSaved[d] == nil then cnSaved[d] = { c = d.CanCollide, t = d.CanTouch } end
                        d.CanCollide, d.CanTouch = false, false
                        cut = cut + 1
                    end
                end
            end
            local dc
            dc = Workspace.DescendantAdded:Connect(function(d)
                if d:IsA("BasePart") and not cnIsCarPart(d) and not cnKeepSolid(d)
                    and not (cnConcreteSolid and cnIsConcrete(d)) then
                    if cnSaved[d] == nil then cnSaved[d] = { c = d.CanCollide, t = d.CanTouch } end
                    d.CanCollide, d.CanTouch = false, false
                end
            end)
            table.insert(cnConns, dc)
            cmStatus.Text = string.format("Noclip ON (%d phased, %d kept)", cut, kept)
        else
            for p, v in pairs(cnSaved) do pcall(function() p.CanCollide = v.c; p.CanTouch = v.t end) end
            cnSaved = {}
            for _, c in ipairs(cnConns) do pcall(function() c:Disconnect() end) end
            cnConns = {}
            cmStatus.Text = "Noclip OFF"
        end
    end)
    cmConcTog.MouseButton1Click:Connect(function()
        cnConcreteSolid = not cnConcreteSolid; setToggle(cmConcTog, cnConcreteSolid)
        if cnOn then
            for p, v in pairs(cnSaved) do
                if p and p.Parent and cnIsConcrete(p) then
                    if cnConcreteSolid then
                        pcall(function() p.CanCollide = v.c; p.CanTouch = v.t end)
                    else
                        pcall(function() p.CanCollide, p.CanTouch = false, false end)
                    end
                end
            end
            cmStatus.Text = cnConcreteSolid and "Concrete: solid" or "Concrete: phased"
        end
    end)
    local function floatBtn(text, x, y, onPress, onRelease)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 56, 0, 56)
        b.Position = UDim2.new(1, x, 0.5, y)
        b.BackgroundColor3 = COL_BG_ALT
        b.BackgroundTransparency = 0.15
        b.Text = text
        b.TextColor3 = COL_TEXT
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Parent = gui
        corner(b, 28)
        stroke(b, COL_ACCENT, 1)
        local dragging, moved, sp, bp = false, false, nil, nil
        b.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, moved = true, false
                sp = input.Position
                bp = b.Position
                if onPress then onPress() end
            end
        end)
        b.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - sp
                if math.abs(d.X) + math.abs(d.Y) > 8 then moved = true end
                if moved then b.Position = UDim2.new(bp.X.Scale, bp.X.Offset + d.X, bp.Y.Scale, bp.Y.Offset + d.Y) end
            end
        end)
        b.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if onRelease then onRelease(moved) end
            end
        end)
        return b
    end
    floatBtn("JUMP", -70, -100, nil, function(moved)
        if moved then return end
        if not cmNeedCar() then return end
        local cr = cmRoot()
        if cr then pcall(function() cr.AssemblyLinearVelocity = Vector3.new(cr.AssemblyLinearVelocity.X, cmJumpH, cr.AssemblyLinearVelocity.Z) end) end
    end)
    floatBtn("UP", -70, -38, function() kfUpH = true end, function() kfUpH = false end)
    floatBtn("DN", -70, 24, function() kfDnH = true end, function() kfDnH = false end)
end

do
    local page = pages["Brookhaven"]
    local y = 4
    pageLabel(page, y, "Brookhaven Car (name .. 'Car')")
    local bhRescan = pageApply(page, y - 2, 258, "Find car")
    y = y + 22

    pageLabel(page, y, "MaxSpeed");          local bhSpeedBox = pageBox(page, y - 2, 160, 90, "50");   local bhSpeedApply = pageApply(page, y - 2, 258); y = y + 30
    pageLabel(page, y, "Turbo string");      local bhTurboBox = pageBox(page, y - 2, 160, 90, "TurboEnabled"); local bhTurboApply = pageApply(page, y - 2, 258); y = y + 30
    pageLabel(page, y, "Speed Multiplier");  local bhMultBox = pageBox(page, y - 2, 160, 90, "2");     local bhMultApply = pageApply(page, y - 2, 258); y = y + 34

    pageLabel(page, y, "Car Noclip");   local bhCarNoclip = pageToggle(page, y - 2, 160); y = y + 34
    local bhStatus = Instance.new("TextLabel")
    bhStatus.Size = UDim2.new(1, -8, 0, 16); bhStatus.Position = UDim2.new(0, 4, 0, y)
    bhStatus.BackgroundTransparency = 1; bhStatus.Text = "Status: Ready"; bhStatus.TextColor3 = COL_GREEN
    bhStatus.Font = Enum.Font.Gotham; bhStatus.TextSize = 10; bhStatus.TextXAlignment = Enum.TextXAlignment.Left; bhStatus.Parent = page
    page.CanvasSize = UDim2.new(0, 0, 0, y + 30)

    local bhCar, baseMax = nil, nil
    local carNcOn = false
    local carNcConns, carNcOrig = {}, {}

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
    bhCarNoclip.MouseButton1Click:Connect(function()
        if not bhNeedCar() then return end
        carNcOn = not carNcOn; setToggle(bhCarNoclip, carNcOn)
        if carNcOn then
            carNcOrig = {}
            for _, p in ipairs(bhCar:GetDescendants()) do
                if p:IsA("BasePart") then
                    carNcOrig[p] = { c = p.CanCollide, t = p.CanTouch }
                    p.CanCollide, p.CanTouch = false, false
                end
            end
            local hb
            hb = RunService.Heartbeat:Connect(function()
                if not carNcOn then return end
                if not bhCar or not bhCar.Parent then
                    local c = bhFindCar()
                    if not c then return end
                    bhCar, baseMax = c, nil
                    bhStatus.Text = "Car: " .. c.Name; bhStatus.TextColor3 = COL_GREEN
                end
                for _, p in ipairs(bhCar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if carNcOrig[p] == nil then carNcOrig[p] = { c = p.CanCollide, t = p.CanTouch } end
                        if p.CanCollide or p.CanTouch then p.CanCollide, p.CanTouch = false, false end
                    end
                end
            end)
            table.insert(carNcConns, hb)
            bhStatus.Text = "Car Noclip ON"
        else
            for p, d in pairs(carNcOrig) do pcall(function() p.CanCollide = d.c; p.CanTouch = d.t end) end
            carNcOrig = {}
            for _, c in ipairs(carNcConns) do pcall(function() c:Disconnect() end) end
            carNcConns = {}
            bhStatus.Text = "Car Noclip OFF"
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
        if not bhNeedCar() then return end
        local v = bhVal("MaxSpeed")
        if v and v:IsA("NumberValue") then
            if not baseMax then baseMax = v.Value end
            v.Value = baseMax * m
            flashOk(bhMultBox)
            bhStatus.Text = "Multiplier x" .. tostring(m)
        else bhStatus.Text = "MaxSpeed not found (" .. bhListVals() .. ")"; bhStatus.TextColor3 = COL_RED end
    end)
end

do
    local page = pages["Player"]
    local y = 4
    pageLabel(page, y, "Infinite Jump"); local bhInfJ = pageToggle(page, y - 2, 160); y = y + 30
    pageLabel(page, y, "Noclip"); local bhNoclip = pageToggle(page, y - 2, 160); y = y + 30
    pageLabel(page, y, "Fly Speed"); local bhFlyBox = pageBox(page, y - 2, 160, 90, "50"); local bhFlyApply = pageApply(page, y - 2, 258, "Set"); y = y + 30
    pageLabel(page, y, "Player Fly"); local bhFly = pageToggle(page, y - 2, 160); y = y + 30
    pageLabel(page, y, "WalkSpeed");  local bhWSBox = pageBox(page, y - 2, 160, 90, "16"); local bhWSApply = pageApply(page, y - 2, 258); y = y + 30
    pageLabel(page, y, "JumpPower");  local bhJPBox = pageBox(page, y - 2, 160, 90, "50"); local bhJPApply = pageApply(page, y - 2, 258); y = y + 30
    pageLabel(page, y, "Character Hitbox"); local bhHBBox = pageBox(page, y - 2, 160, 90, "1"); local bhHBApply = pageApply(page, y - 2, 258, "Set"); y = y + 34
    local bhRespawn = pageWideBtn(page, y, "Respawn"); y = y + 34
    pageLabel(page, y, "ESP"); local espTog = pageToggle(page, y - 2, 160); espTog.Text = "ESP: Off"; y = y + 30
    local espDestroy = pageWideBtn(page, y, "Destroy ESP"); y = y + 34
    pageLabel(page, y, "Aimbot"); local abTog = pageToggle(page, y - 2, 160); abTog.Text = "Aimbot: Off"; y = y + 30
    pageLabel(page, y, "Aim Radius"); local abBox = pageBox(page, y - 2, 160, 90, "120"); local abApply = pageApply(page, y - 2, 258, "Set"); y = y + 30
    pageLabel(page, y, "Team Check"); local abTeamTog = pageToggle(page, y - 2, 160); setToggle(abTeamTog, true); y = y + 34
    local plStatus = Instance.new("TextLabel")
    plStatus.Size = UDim2.new(1, -8, 0, 16); plStatus.Position = UDim2.new(0, 4, 0, y)
    plStatus.BackgroundTransparency = 1; plStatus.Text = "Status: Ready"; plStatus.TextColor3 = COL_GREEN
    plStatus.Font = Enum.Font.Gotham; plStatus.TextSize = 10; plStatus.TextXAlignment = Enum.TextXAlignment.Left; plStatus.Parent = page
    page.CanvasSize = UDim2.new(0, 0, 0, y + 30)
    local noclipOn, infJOn, pflyOn = false, false, false
    local pflySpeed, pflyConn, ncChar, standOff = 50, nil, nil, 3
    local noclipConns, infJConn, origColl = {}, nil, {}
    bhNoclip.MouseButton1Click:Connect(function()
        local ch = player.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if not hum or not root then plStatus.Text = "No character"; plStatus.TextColor3 = COL_RED return end
        noclipOn = not noclipOn; setToggle(bhNoclip, noclipOn)
        if noclipOn then
            ncChar = ch
            origColl = {}
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then
                    origColl[p] = { c = p.CanCollide, t = p.CanTouch }
                    p.CanCollide, p.CanTouch = false, false
                end
            end
            local rp0 = RaycastParams.new()
            rp0.FilterType = Enum.RaycastFilterType.Exclude
            rp0.FilterDescendantsInstances = { ch }
            local hit0 = Workspace:Raycast(root.Position + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0), rp0)
            standOff = hit0 and (root.Position.Y - hit0.Position.Y) or (hum.HipHeight + root.Size.Y * 0.5)
            local hb
            hb = RunService.Heartbeat:Connect(function()
                if not noclipOn then return end
                local c2 = player.Character
                local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
                if not r2 or not h2 then return end
                if c2 ~= ncChar then
                    ncChar = c2
                    for _, p in ipairs(c2:GetDescendants()) do
                        if p:IsA("BasePart") and origColl[p] == nil then
                            origColl[p] = { c = p.CanCollide, t = p.CanTouch }
                        end
                    end
                end
                for _, p in ipairs(c2:GetDescendants()) do
                    if p:IsA("BasePart") and (p.CanCollide or p.CanTouch) then
                        p.CanCollide, p.CanTouch = false, false
                    end
                end
                if r2.AssemblyLinearVelocity.Y > 1 then return end
                local prm = RaycastParams.new()
                prm.FilterType = Enum.RaycastFilterType.Exclude
                prm.FilterDescendantsInstances = { c2 }
                local h = Workspace:Raycast(r2.Position, Vector3.new(0, -(standOff + 6), 0), prm)
                if h then
                    local gy = h.Position.Y + standOff
                    if r2.Position.Y <= gy + 0.5 then
                        r2.CFrame = CFrame.new(r2.Position.X, gy, r2.Position.Z) * (r2.CFrame - r2.CFrame.Position)
                    end
                end
            end)
            table.insert(noclipConns, hb)
            plStatus.Text = "Noclip ON (floor kept)"
        else
            for p, d in pairs(origColl) do pcall(function() p.CanCollide = d.c; p.CanTouch = d.t end) end
            origColl = {}
            for _, c in ipairs(noclipConns) do pcall(function() c:Disconnect() end) end
            noclipConns = {}
            plStatus.Text = "Noclip OFF"
        end
    end)
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
    bhFlyApply.MouseButton1Click:Connect(function()
        local n = tonumber(bhFlyBox.Text)
        if n and n >= 1 then pflySpeed = math.clamp(n, 1, 500); bhFlyBox.Text = tostring(pflySpeed); flashOk(bhFlyBox)
        else flashErr(bhFlyBox) end
    end)
    bhFly.MouseButton1Click:Connect(function()
        pflyOn = not pflyOn; setToggle(bhFly, pflyOn)
        if pflyConn then pcall(function() pflyConn:Disconnect() end) pflyConn = nil end
        if pflyOn then
            plStatus.Text = "Fly ON (WASD + E/Q)"
            pflyConn = RunService.Heartbeat:Connect(function(dt)
                if not pflyOn then return end
                local ch = player.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local root = ch and ch:FindFirstChild("HumanoidRootPart")
                if not hum or not root then return end
                local md = hum.MoveDirection
                local vel = Vector3.new(md.X, 0, md.Z) * pflySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then vel = vel + Vector3.new(0, pflySpeed, 0)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then vel = vel - Vector3.new(0, pflySpeed, 0) end
                if vel.Magnitude < 0.01 then
                    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
                    return
                end
                pcall(function()
                    root.CFrame = root.CFrame + vel * math.min(dt, 0.05)
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end)
            end)
        else
            local ch = player.Character
            local root = ch and ch:FindFirstChild("HumanoidRootPart")
            if root then pcall(function() root.AssemblyLinearVelocity = Vector3.zero end) end
            plStatus.Text = "Fly OFF"
        end
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
                flashOk(bhJPBox); plStatus.Text = "Jump set"
            else flashErr(bhJPBox) end
        end
    end)
    local chHbMult, chHbOrig, chHbChar = 1, nil, nil
    local function chHbApply()
        local ch = player.Character
        local rp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not rp then plStatus.Text = "No character"; plStatus.TextColor3 = COL_RED return false end
        if ch ~= chHbChar then chHbChar = ch; chHbOrig = rp.Size end
        pcall(function()
            rp.Size = chHbOrig * chHbMult
            rp.CanCollide = false
        end)
        return true
    end
    bhHBApply.MouseButton1Click:Connect(function()
        local n = tonumber(bhHBBox.Text)
        if n and n >= 0.5 and n <= 20 then
            chHbMult = n
            if chHbApply() then
                bhHBBox.Text = tostring(chHbMult); flashOk(bhHBBox)
                plStatus.Text = "Hitbox x" .. tostring(chHbMult); plStatus.TextColor3 = COL_GREEN
            end
        else flashErr(bhHBBox) end
    end)
    player.CharacterAdded:Connect(function(ch)
        ch:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.5)
        if chHbMult ~= 1 then chHbApply() end
    end)
    bhRespawn.MouseButton1Click:Connect(function()
        local ch = player.Character; local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
    local espOn, espTracked, espConn, espAcc, espFrame, espPhase = false, {}, nil, 0, 0, 0
    local function espTeam(plr)
        local col = Color3.fromRGB(255, 255, 255)
        pcall(function()
            if plr.Team then col = plr.TeamColor.Color end
        end)
        return col
    end
    local function espMake()
        local box = Drawing.new("Square")
        box.Visible = false
        box.Filled = false
        box.Thickness = 1.5
        local name = Drawing.new("Text")
        name.Visible = false
        name.Centered = true
        name.Size = 13
        name.Outline = true
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1.2
        return { box = box, name = name, tracer = tracer }
    end
    local function espDrop(set)
        pcall(function() set.box:Remove() end)
        pcall(function() set.name:Remove() end)
        pcall(function() set.tracer:Remove() end)
    end
    local function espHide(set)
        set.box.Visible = false
        set.name.Visible = false
        set.tracer.Visible = false
    end
    local function espCache(plr)
        local e = espTracked[plr]
        if not e then
            e = espMake()
            e.phase = espPhase
            espPhase = espPhase + 1
            if espPhase >= 3 then espPhase = 0 end
            espTracked[plr] = e
        end
        e.char = plr.Character
        e.hum = e.char and e.char:FindFirstChildOfClass("Humanoid")
        e.root = e.char and e.char:FindFirstChild("HumanoidRootPart")
        e.team = plr.Team
        e.col = espTeam(plr)
        e.label = plr.Name
        return e
    end
    local function espSync()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and not espTracked[plr] then
                espCache(plr)
            end
        end
        for plr, set in pairs(espTracked) do
            if plr.Parent ~= Players then
                espDrop(set)
                espTracked[plr] = nil
            end
        end
    end
    espTog.MouseButton1Click:Connect(function()
        if not espOn then
            local okD, test = pcall(function() return Drawing.new("Square") end)
            if not okD or not test then plStatus.Text = "Drawing unsupported"; plStatus.TextColor3 = COL_RED return end
            pcall(function() test:Remove() end)
        end
        espOn = not espOn; setToggle(espTog, espOn, "ESP: On", "ESP: Off")
        if espConn then pcall(function() espConn:Disconnect() end) espConn = nil end
        if espOn then
            espSync()
            plStatus.Text = "ESP ON"
            espConn = RunService.RenderStepped:Connect(function(dt)
                espAcc = espAcc + dt
                if espAcc >= 2 then espAcc = 0 espSync() end
                espFrame = espFrame + 1
                local cam = Workspace.CurrentCamera
                if not cam then return end
                local ch0 = player.Character
                local root0 = ch0 and ch0:FindFirstChild("HumanoidRootPart")
                local from
                if root0 then
                    local v, on = cam:WorldToViewportPoint(root0.Position)
                    if on then from = Vector2.new(v.X, v.Y) end
                end
                if not from then from = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y) end
                local camPos = cam.CFrame.Position
                for plr, e in pairs(espTracked) do
                    if not e.root or not e.root.Parent or e.char ~= plr.Character or e.team ~= plr.Team then
                        espCache(plr)
                    end
                    local hum, root = e.hum, e.root
                    if hum and root and hum.Health > 0 then
                        local d = (camPos - root.Position).Magnitude
                        if d <= 400 or (espFrame + (e.phase or 0)) % 3 == 0 then
                            local v, on = cam:WorldToViewportPoint(root.Position)
                            if on then
                                local h = math.clamp(1500 / math.max(d, 1), 20, 300)
                                local w = h * 0.6
                                e.box.Size = Vector2.new(w, h)
                                e.box.Position = Vector2.new(v.X - w * 0.5, v.Y - h * 0.5)
                                e.box.Color = e.col
                                e.box.Visible = true
                                e.name.Text = e.label .. " [" .. math.floor(d + 0.5) .. "]"
                                e.name.Position = Vector2.new(v.X, v.Y - h * 0.5 - 14)
                                e.name.Color = e.col
                                e.name.Visible = true
                                e.tracer.From = from
                                e.tracer.To = Vector2.new(v.X, v.Y)
                                e.tracer.Color = e.col
                                e.tracer.Visible = true
                            else
                                espHide(e)
                            end
                        end
                    else
                        espHide(e)
                    end
                end
            end)
        else
            for _, set in pairs(espTracked) do espHide(set) end
            plStatus.Text = "ESP OFF"
        end
    end)
    espDestroy.MouseButton1Click:Connect(function()
        espOn = false; setToggle(espTog, espOn, "ESP: On", "ESP: Off")
        if espConn then pcall(function() espConn:Disconnect() end) espConn = nil end
        for plr, set in pairs(espTracked) do espDrop(set) espTracked[plr] = nil end
        plStatus.Text = "ESP destroyed"
    end)
    local abOn, abRadius, abTeam, abConn, abCircle = false, 120, true, nil, nil
    abApply.MouseButton1Click:Connect(function()
        local n = tonumber(abBox.Text)
        if n then abRadius = math.clamp(n, 20, 600); abBox.Text = tostring(abRadius); flashOk(abBox)
            if abCircle then abCircle.Radius = abRadius end
        else flashErr(abBox) end
    end)
    abTeamTog.MouseButton1Click:Connect(function()
        abTeam = not abTeam; setToggle(abTeamTog, abTeam)
    end)
    abTog.MouseButton1Click:Connect(function()
        abOn = not abOn; setToggle(abTog, abOn, "Aimbot: On", "Aimbot: Off")
        if abConn then pcall(function() abConn:Disconnect() end) abConn = nil end
        if abOn then
            if not abCircle or not abCircle.Parent then
                pcall(function()
                    if abCircle then abCircle:Remove() end
                    local c = Drawing.new("Circle")
                    c.Visible = false
                    c.NumSides = 64
                    c.Thickness = 1.5
                    c.Color = Color3.fromRGB(255, 60, 60)
                    c.Radius = abRadius
                    abCircle = c
                end)
            end
            plStatus.Text = "Aimbot ON"
            abConn = RunService.RenderStepped:Connect(function()
                local cam = Workspace.CurrentCamera
                if not cam then return end
                if abCircle then
                    abCircle.Position = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
                    abCircle.Radius = abRadius
                    abCircle.Visible = abOn
                end
                if not abOn then return end
                local cx, cy = cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5
                local best, bestPart, bestD = nil, nil, abRadius
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then
                        local ch = plr.Character
                        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if not (abTeam and plr.Team and player.Team and plr.Team == player.Team) then
                                local part = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
                                if part then
                                    local v, on = cam:WorldToViewportPoint(part.Position)
                                    if on then
                                        local d = (Vector2.new(v.X, v.Y) - Vector2.new(cx, cy)).Magnitude
                                        if d <= bestD then best, bestPart, bestD = plr, part, d end
                                    end
                                end
                            end
                        end
                    end
                end
                if best and bestPart and bestPart.Parent then
                    local ch0 = player.Character
                    local camPos = cam.CFrame.Position
                    local dir = bestPart.Position - camPos
                    local prm = RaycastParams.new()
                    prm.FilterType = Enum.RaycastFilterType.Exclude
                    local f = {}
                    if ch0 then table.insert(f, ch0) end
                    if best.Character then table.insert(f, best.Character) end
                    prm.FilterDescendantsInstances = f
                    local hit = Workspace:Raycast(camPos, dir, prm)
                    if not hit then
                        pcall(function()
                            cam.CFrame = cam.CFrame:Lerp(CFrame.new(camPos, bestPart.Position), 0.4)
                        end)
                    end
                end
            end)
        else
            if abCircle then abCircle.Visible = false end
            plStatus.Text = "Aimbot OFF"
        end
    end)
end

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

do
    local page = pages["Backdoor"]

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
