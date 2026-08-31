local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

pcall(function()
    if guiParent:FindFirstChild("InfectiousRoot") then
        guiParent.InfectiousRoot:Destroy()
    end
end)

local root = Instance.new("ScreenGui")
root.Name = "InfectiousRoot"
root.Parent = guiParent
root.ResetOnSpawn = false
root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
root.IgnoreGuiInset = true

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 3

local themes = {
    Default = {
        background = Color3.fromRGB(18, 18, 22),
        accent = Color3.fromRGB(255, 50, 80),
        text = Color3.fromRGB(220, 220, 230),
        button = Color3.fromRGB(30, 30, 35),
        stroke = Color3.fromRGB(255, 50, 80),
        danger = Color3.fromRGB(255, 20, 50)
    },
    Crimson = {
        background = Color3.fromRGB(20, 10, 12),
        accent = Color3.fromRGB(255, 30, 50),
        text = Color3.fromRGB(230, 200, 200),
        button = Color3.fromRGB(35, 20, 22),
        stroke = Color3.fromRGB(200, 30, 50),
        danger = Color3.fromRGB(255, 10, 30)
    },
    Cyber = {
        background = Color3.fromRGB(8, 10, 20),
        accent = Color3.fromRGB(0, 200, 255),
        text = Color3.fromRGB(180, 230, 255),
        button = Color3.fromRGB(15, 25, 40),
        stroke = Color3.fromRGB(0, 180, 255),
        danger = Color3.fromRGB(255, 50, 100)
    },
    Amber = {
        background = Color3.fromRGB(18, 14, 8),
        accent = Color3.fromRGB(255, 180, 0),
        text = Color3.fromRGB(240, 220, 180),
        button = Color3.fromRGB(30, 25, 15),
        stroke = Color3.fromRGB(200, 150, 0),
        danger = Color3.fromRGB(255, 100, 0)
    },
    Violet = {
        background = Color3.fromRGB(16, 10, 22),
        accent = Color3.fromRGB(180, 80, 255),
        text = Color3.fromRGB(220, 200, 240),
        button = Color3.fromRGB(28, 18, 35),
        stroke = Color3.fromRGB(150, 50, 220),
        danger = Color3.fromRGB(220, 50, 150)
    }
}

local currentTheme = "Default"
local isMinimized = false
local isOpen = true

-- Mods
local deleteInfectActive = false
local deleteKillActive = false
local deleteDoorsActive = false
local espActive = false

local infectConnection = nil
local killConnection = nil
local doorsConnection = nil
local espConnection = nil

local deletedInfect = {}
local deletedKill = {}
local deletedDoors = {}
local espObjects = {}

-- ===== MAIN FRAME =====
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 230)
frame.Position = UDim2.new(0.5, -140, 0.5, -115)
frame.BackgroundColor3 = themes.Default.background
frame.BackgroundTransparency = 0.08
frame.ClipsDescendants = true
frame.Parent = root
frame.Visible = true
frame.ZIndex = 10

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = themes.Default.stroke
stroke.Thickness = 1.5
stroke.Transparency = 0.6

-- ===== MINI SQUARE =====
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 50, 0, 50)
miniBtn.Position = UDim2.new(1, -60, 0, 10)
miniBtn.Text = "NZ"
miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtn.TextSize = 13
miniBtn.Font = Enum.Font.GothamBold
miniBtn.BackgroundColor3 = themes.Default.accent
miniBtn.BackgroundTransparency = 0.15
miniBtn.Parent = root
miniBtn.Visible = false
miniBtn.ZIndex = 999
miniBtn.AutoButtonColor = true

local miniCorner = Instance.new("UICorner", miniBtn)
miniCorner.CornerRadius = UDim.new(0, 12)

local miniStroke = Instance.new("UIStroke", miniBtn)
miniStroke.Color = themes.Default.accent
miniStroke.Thickness = 2
miniStroke.Transparency = 0.3

-- ===== RE-OPEN BUTTON (with tap/hold) =====
local reopenBtn = Instance.new("TextButton")
reopenBtn.Size = UDim2.new(0, 50, 0, 50)
reopenBtn.Position = UDim2.new(0, 10, 1, -65)
reopenBtn.Text = "▶"
reopenBtn.TextSize = 22
reopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reopenBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
reopenBtn.BackgroundTransparency = 0.2
reopenBtn.Parent = root
reopenBtn.Visible = false
reopenBtn.ZIndex = 999
reopenBtn.AutoButtonColor = true

local reopenCorner = Instance.new("UICorner", reopenBtn)
reopenCorner.CornerRadius = UDim.new(1, 0)

local reopenStroke = Instance.new("UIStroke", reopenBtn)
reopenStroke.Color = Color3.fromRGB(255, 255, 255)
reopenStroke.Thickness = 2
reopenStroke.Transparency = 0.2

-- ===== TITLE BAR =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame
titleBar.Active = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.Text = "NZ-IS"
titleLabel.TextColor3 = themes.Default.accent
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
minimizeBtn.Position = UDim2.new(1, -62, 0, 3)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
minimizeBtn.BackgroundTransparency = 0.2
minimizeBtn.Parent = titleBar
local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 5)

-- Close/Re-Open Button (inside GUI)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 3)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 5)

-- ===== TABS =====
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 26)
tabContainer.Position = UDim2.new(0, 5, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local function createTab(name, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BackgroundTransparency = 0.3
    btn.Parent = tabContainer
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 5)
    return btn
end

local tabMods = createTab("Mods", 0)
local tabTheme = createTab("Theme", 130)

-- ===== PAGES =====
local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -74)
    pg.Position = UDim2.new(0, 5, 0, 65)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 220)
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local modsPage = createPage()
local themePage = createPage()

-- ===== UI HELPERS =====
local function makeLabel(text, y, parent, w)
    w = w or 100
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, w, 0, 22)
    l.Position = UDim2.new(0, 0, 0, y)
    l.Text = text
    l.TextColor3 = themes.Default.text
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function makeToggle(y, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 22)
    btn.Position = UDim2.new(0, 160, 0, y)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    btn.Parent = parent
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 4)
    return btn
end

local function makeThemeButton(name, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    btn.Parent = themePage
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        statusLabel.TextColor3 = t.accent
        miniBtn.BackgroundColor3 = t.accent
        miniStroke.Color = t.accent
        reopenBtn.BackgroundColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minimizeBtn and child ~= infectBtn and child ~= killBtn and child ~= doorsBtn and child ~= espBtn then
                if child.Text == "Mods" or child.Text == "Theme" then
                    child.TextColor3 = t.accent
                end
            end
            if child:IsA("ScrollingFrame") then
                child.ScrollBarImageColor3 = t.accent
            end
        end
        closeBtn.BackgroundColor3 = t.button
        minimizeBtn.BackgroundColor3 = t.button
        minimizeBtn.TextColor3 = t.accent
    end)

    btn.TouchTap:Connect(function()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        statusLabel.TextColor3 = t.accent
        miniBtn.BackgroundColor3 = t.accent
        miniStroke.Color = t.accent
        reopenBtn.BackgroundColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minimizeBtn and child ~= infectBtn and child ~= killBtn and child ~= doorsBtn and child ~= espBtn then
                if child.Text == "Mods" or child.Text == "Theme" then
                    child.TextColor3 = t.accent
                end
            end
            if child:IsA("ScrollingFrame") then
                child.ScrollBarImageColor3 = t.accent
            end
        end
        closeBtn.BackgroundColor3 = t.button
        minimizeBtn.BackgroundColor3 = t.button
        minimizeBtn.TextColor3 = t.accent
    end)

    return btn
end

-- ===== MODS PAGE =====
local yOff = 4

makeLabel("Delete Infected", yOff, modsPage, 110)
local infectBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable Kill Parts", yOff, modsPage, 110)
local killBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable Doors/Gates", yOff, modsPage, 110)
local doorsBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("TEAM ESP", yOff, modsPage, 110)
local espBtn = makeToggle(yOff, modsPage)
yOff = yOff + 32

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 22)
statusLabel.Position = UDim2.new(0, 0, 0, yOff)
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamBold
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = modsPage
yOff = yOff + 28

modsPage.CanvasSize = UDim2.new(0, 0, 0, yOff + 10)

-- ===== THEME PAGE =====
local themeY = 8
local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(1, -10, 0, 24)
themeLabel.Position = UDim2.new(0, 0, 0, themeY)
themeLabel.Text = "SELECT THEME"
themeLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
themeLabel.TextSize = 12
themeLabel.Font = Enum.Font.GothamBold
themeLabel.BackgroundTransparency = 1
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.Parent = themePage
themeY = themeY + 30

local themeColors = {
    {name = "Default", color = Color3.fromRGB(30, 20, 25)},
    {name = "Crimson", color = Color3.fromRGB(35, 15, 20)},
    {name = "Cyber", color = Color3.fromRGB(10, 15, 40)},
    {name = "Amber", color = Color3.fromRGB(35, 25, 15)},
    {name = "Violet", color = Color3.fromRGB(25, 15, 40)}
}

for _, t in ipairs(themeColors) do
    makeThemeButton(t.name, themeY, t.color)
    themeY = themeY + 34
end

themePage.CanvasSize = UDim2.new(0, 0, 0, themeY + 10)

-- ===== CORE FUNCTIONS =====
local function restoreInfect()
    for _, item in pairs(deletedInfect) do
        if item and not item.Parent then
            pcall(function() item.Parent = Workspace end)
        end
    end
    deletedInfect = {}
end

local function restoreKill()
    for _, item in pairs(deletedKill) do
        if item and not item.Parent then
            pcall(function() item.Parent = Workspace end)
        end
    end
    deletedKill = {}
end

local function restoreDoors()
    for _, item in pairs(deletedDoors) do
        if item and not item.Parent then
            pcall(function() item.Parent = Workspace end)
        end
    end
    deletedDoors = {}
end

local function scanAndDeleteInfect()
    if not deleteInfectActive then restoreInfect(); return end
    local found = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name and string.lower(v.Name):find("infect") then
                table.insert(found, v)
            end
        end
    end
    for _, v in pairs(found) do
        if v.Parent then
            table.insert(deletedInfect, v)
            pcall(function() v.Parent = nil end)
        end
    end
    if #found > 0 then
        statusLabel.Text = "Deleted " .. #found .. " infected"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif deleteInfectActive then
        statusLabel.Text = "No infected found"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

local function scanAndDeleteKill()
    if not deleteKillActive then restoreKill(); return end
    local found = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name and string.lower(v.Name):find("kill") then
                table.insert(found, v)
            end
        end
    end
    for _, v in pairs(found) do
        if v.Parent then
            table.insert(deletedKill, v)
            pcall(function() v.Parent = nil end)
        end
    end
    if #found > 0 then
        statusLabel.Text = "Deleted " .. #found .. " kill parts"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif deleteKillActive then
        statusLabel.Text = "No kill parts found"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

local function scanAndDeleteDoors()
    if not deleteDoorsActive then restoreDoors(); return end
    local found = {}
    local keywords = {"door", "gate", "portal", "doorway", "entrance", "exit"}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") and v.Name then
            local nameLower = string.lower(v.Name)
            for _, kw in pairs(keywords) do
                if nameLower:find(kw) then
                    table.insert(found, v)
                    break
                end
            end
        end
    end
    for _, v in pairs(found) do
        if v.Parent then
            table.insert(deletedDoors, v)
            pcall(function() v.Parent = nil end)
        end
    end
    if #found > 0 then
        statusLabel.Text = "Deleted " .. #found .. " doors/gates"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif deleteDoorsActive then
        statusLabel.Text = "No doors/gates found"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

-- ===== ESP =====
local function getTeamColor(plr)
    if plr.Team then return plr.Team.TeamColor.Color end
    return Color3.fromRGB(255, 255, 255)
end

local function createEsp(target)
    if target == player then return end
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = target.Character.HumanoidRootPart
    local teamColor = getTeamColor(target)

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.3
    highlight.FillColor = teamColor
    highlight.OutlineColor = teamColor
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = target.Character

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 30, 0, 60)
    box.Position = UDim2.new(0.5, -15, 0.5, -30)
    box.BackgroundTransparency = 0.5
    box.BackgroundColor3 = teamColor
    box.BorderSizePixel = 2
    box.BorderColor3 = teamColor
    box.Parent = rootPart
    box.Visible = false

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 0, -18)
    nameLabel.Text = target.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Parent = box

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 1, 0, 1)
    line.BackgroundTransparency = 0.6
    line.BackgroundColor3 = teamColor
    line.Parent = rootPart
    line.Visible = false

    espObjects[target] = {Highlight = highlight, Box = box, Name = nameLabel, Line = line, Root = rootPart}
end

local function updateEsp()
    if not espActive then
        for _, data in pairs(espObjects) do
            pcall(function()
                if data.Highlight then data.Highlight:Destroy() end
                if data.Box then data.Box:Destroy() end
                if data.Line then data.Line:Destroy() end
            end)
        end
        espObjects = {}
        return
    end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myPos = char.HumanoidRootPart.Position

    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[target] then createEsp(target) end
            local data = espObjects[target]
            if data and data.Root then
                local targetPos = data.Root.Position
                local distance = (myPos - targetPos).Magnitude
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                local fade = math.clamp((distance - 15) / 30, 0.3, 1)

                if onScreen and distance < 200 then
                    local boxSize = math.clamp(80 / distance, 20, 80)
                    data.Box.Size = UDim2.new(0, boxSize, 0, boxSize * 1.8)
                    data.Box.Position = UDim2.new(0, screenPos.X - boxSize/2, 0, screenPos.Y - boxSize * 0.9)
                    data.Box.BackgroundTransparency = 0.3 + (1 - fade) * 0.5
                    data.Box.Visible = true

                    data.Highlight.FillTransparency = 0.4 + (1 - fade) * 0.4
                    data.Highlight.OutlineTransparency = 0.2 + (1 - fade) * 0.3

                    local centerX = screenPos.X
                    local centerY = screenPos.Y + boxSize * 0.5
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local dx = centerX - screenCenter.X
                    local dy = centerY - screenCenter.Y
                    local angle = math.atan2(dy, dx)
                    local length = math.clamp(math.sqrt(dx^2 + dy^2), 20, 300)

                    data.Line.Size = UDim2.new(0, length, 0, 1)
                    data.Line.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
                    data.Line.Rotation = math.deg(angle)
                    data.Line.BackgroundTransparency = 0.4 + (1 - fade) * 0.3
                    data.Line.Visible = true
                else
                    data.Box.Visible = false
                    data.Line.Visible = false
                    data.Highlight.FillTransparency = 0.7
                end
            end
        end
    end
end

-- ===== TOGGLES =====
local function toggleInfect()
    deleteInfectActive = not deleteInfectActive
    if deleteInfectActive then
        infectBtn.Text = "ON"
        infectBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        infectBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Scanning..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        if infectConnection then pcall(function() infectConnection:Disconnect() end); infectConnection = nil end
        scanAndDeleteInfect()
        infectConnection = RunService.Heartbeat:Connect(function()
            if deleteInfectActive then scanAndDeleteInfect() end
        end)
    else
        infectBtn.Text = "OFF"
        infectBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        infectBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if infectConnection then pcall(function() infectConnection:Disconnect() end); infectConnection = nil end
        restoreInfect()
        statusLabel.Text = "Infected restored"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

infectBtn.MouseButton1Click:Connect(toggleInfect)
infectBtn.TouchTap:Connect(toggleInfect)

local function toggleKill()
    deleteKillActive = not deleteKillActive
    if deleteKillActive then
        killBtn.Text = "ON"
        killBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        killBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Scanning..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        if killConnection then pcall(function() killConnection:Disconnect() end); killConnection = nil end
        scanAndDeleteKill()
        killConnection = RunService.Heartbeat:Connect(function()
            if deleteKillActive then scanAndDeleteKill() end
        end)
    else
        killBtn.Text = "OFF"
        killBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        killBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if killConnection then pcall(function() killConnection:Disconnect() end); killConnection = nil end
        restoreKill()
        statusLabel.Text = "Kill restored"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

killBtn.MouseButton1Click:Connect(toggleKill)
killBtn.TouchTap:Connect(toggleKill)

local function toggleDoors()
    deleteDoorsActive = not deleteDoorsActive
    if deleteDoorsActive then
        doorsBtn.Text = "ON"
        doorsBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        doorsBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Scanning..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        if doorsConnection then pcall(function() doorsConnection:Disconnect() end); doorsConnection = nil end
        scanAndDeleteDoors()
        doorsConnection = RunService.Heartbeat:Connect(function()
            if deleteDoorsActive then scanAndDeleteDoors() end
        end)
    else
        doorsBtn.Text = "OFF"
        doorsBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        doorsBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if doorsConnection then pcall(function() doorsConnection:Disconnect() end); doorsConnection = nil end
        restoreDoors()
        statusLabel.Text = "Doors restored"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

doorsBtn.MouseButton1Click:Connect(toggleDoors)
doorsBtn.TouchTap:Connect(toggleDoors)

local function toggleEsp()
    espActive = not espActive
    if espActive then
        espBtn.Text = "ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        espBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "ESP ENABLED"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)

        if espConnection then pcall(function() espConnection:Disconnect() end); espConnection = nil end
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player then createEsp(target) end
        end
        espConnection = RunService.RenderStepped:Connect(updateEsp)

        Players.PlayerAdded:Connect(function(target)
            task.wait(0.5)
            if espActive then createEsp(target) end
        end)

        Players.PlayerRemoving:Connect(function(target)
            if espObjects[target] then
                pcall(function()
                    if espObjects[target].Highlight then espObjects[target].Highlight:Destroy() end
                    if espObjects[target].Box then espObjects[target].Box:Destroy() end
                    if espObjects[target].Line then espObjects[target].Line:Destroy() end
                end)
                espObjects[target] = nil
            end
        end)
    else
        espBtn.Text = "OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        espBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "ESP DISABLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

        if espConnection then pcall(function() espConnection:Disconnect() end); espConnection = nil end
        for _, data in pairs(espObjects) do
            pcall(function()
                if data.Highlight then data.Highlight:Destroy() end
                if data.Box then data.Box:Destroy() end
                if data.Line then data.Line:Destroy() end
            end)
        end
        espObjects = {}
        task.wait(0.5)
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

espBtn.MouseButton1Click:Connect(toggleEsp)
espBtn.TouchTap:Connect(toggleEsp)

-- ===== TAB SWITCHING =====
tabMods.MouseButton1Click:Connect(function()
    modsPage.Visible = true
    themePage.Visible = false
    tabMods.TextColor3 = themes[currentTheme].accent
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
end)

tabMods.TouchTap:Connect(function()
    modsPage.Visible = true
    themePage.Visible = false
    tabMods.TextColor3 = themes[currentTheme].accent
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
end)

tabTheme.MouseButton1Click:Connect(function()
    modsPage.Visible = false
    themePage.Visible = true
    tabTheme.TextColor3 = themes[currentTheme].accent
    tabMods.TextColor3 = Color3.fromRGB(180, 180, 210)
end)

tabTheme.TouchTap:Connect(function()
    modsPage.Visible = false
    themePage.Visible = true
    tabTheme.TextColor3 = themes[currentTheme].accent
    tabMods.TextColor3 = Color3.fromRGB(180, 180, 210)
end)

modsPage.Visible = true
tabMods.TextColor3 = themes.Default.accent
tabMods.BackgroundTransparency = 0

-- ===== MINIMIZE / RESTORE =====
local function minimizeGUI()
    if isMinimized then return end
    isMinimized = true
    frame.Visible = false
    miniBtn.Visible = true
    reopenBtn.Visible = false
    blur.Size = 0
end

local function restoreGUI()
    if not isMinimized then return end
    isMinimized = false
    frame.Visible = true
    miniBtn.Visible = false
    blur.Size = 3
end

minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then restoreGUI() else minimizeGUI() end
end)

minimizeBtn.TouchTap:Connect(function()
    if isMinimized then restoreGUI() else minimizeGUI() end
end)

miniBtn.MouseButton1Click:Connect(restoreGUI)
miniBtn.TouchTap:Connect(restoreGUI)

miniBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        restoreGUI()
    end
end)

-- ===== CLOSE/RE-OPEN BUTTON =====
local function toggleOpenClose()
    if isOpen then
        isOpen = false
        frame.Visible = false
        miniBtn.Visible = false
        reopenBtn.Visible = true
        closeBtn.Text = "▶"
        closeBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        blur.Size = 0
    else
        isOpen = true
        frame.Visible = true
        reopenBtn.Visible = false
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
        if not isMinimized then
            blur.Size = 3
        end
    end
end

closeBtn.MouseButton1Click:Connect(toggleOpenClose)
closeBtn.TouchTap:Connect(toggleOpenClose)

-- ===== DRAG SYSTEM WITH TAP/HOLD DETECTION =====

-- FRAME DRAG (title bar only - hold to drag, tap does nothing)
local frameDragData = {
    isDragging = false,
    startPos = nil,
    frameStart = nil,
    hasMoved = false,
    touchStart = nil,
    isTap = false
}

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        frameDragData.isDragging = false
        frameDragData.hasMoved = false
        frameDragData.startPos = input.Position
        frameDragData.frameStart = frame.Position
        frameDragData.touchStart = tick()
        frameDragData.isTap = true
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if frameDragData.startPos then
            local delta = input.Position - frameDragData.startPos
            local distance = math.sqrt(delta.X^2 + delta.Y^2)
            if distance > 5 then
                frameDragData.hasMoved = true
                frameDragData.isDragging = true
                frameDragData.isTap = false
            end
            if frameDragData.isDragging then
                frame.Position = UDim2.new(frameDragData.frameStart.X.Scale, frameDragData.frameStart.X.Offset + delta.X, frameDragData.frameStart.Y.Scale, frameDragData.frameStart.Y.Offset + delta.Y)
            end
        end
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        frameDragData.isDragging = false
        frameDragData.startPos = nil
        frameDragData.frameStart = nil
    end
end)

-- RE-OPEN BUTTON DRAG (tap to open, hold to drag)
local reopenDragData = {
    isDragging = false,
    startPos = nil,
    btnStart = nil,
    hasMoved = false,
    touchStart = nil,
    isTap = false
}

reopenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        reopenDragData.isDragging = false
        reopenDragData.hasMoved = false
        reopenDragData.startPos = input.Position
        reopenDragData.btnStart = reopenBtn.Position
        reopenDragData.touchStart = tick()
        reopenDragData.isTap = true
    end
end)

reopenBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if reopenDragData.startPos then
            local delta = input.Position - reopenDragData.startPos
            local distance = math.sqrt(delta.X^2 + delta.Y^2)
            if distance > 10 then
                reopenDragData.hasMoved = true
                reopenDragData.isDragging = true
                reopenDragData.isTap = false
            end
            if reopenDragData.isDragging then
                reopenBtn.Position = UDim2.new(reopenDragData.btnStart.X.Scale, reopenDragData.btnStart.X.Offset + delta.X, reopenDragData.btnStart.Y.Scale, reopenDragData.btnStart.Y.Offset + delta.Y)
            end
        end
    end
end)

reopenBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Only trigger tap if it was a tap (not a drag)
        if reopenDragData.isTap and not reopenDragData.hasMoved and reopenDragData.touchStart then
            local holdTime = tick() - reopenDragData.touchStart
            if holdTime < 0.3 then
                -- Tap detected - open GUI
                if not isOpen then
                    isOpen = true
                    frame.Visible = true
                    reopenBtn.Visible = false
                    closeBtn.Text = "X"
                    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
                    if not isMinimized then
                        blur.Size = 3
                    end
                end
            end
        end
        reopenDragData.isDragging = false
        reopenDragData.startPos = nil
        reopenDragData.btnStart = nil
        reopenDragData.isTap = false
    end
end)

-- ===== HOTKEY =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if isMinimized then restoreGUI() else minimizeGUI() end
    end
end)

-- ===== FORCE VISIBILITY =====
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 280, 0, 230),
    BackgroundTransparency = 0.08
}):Play()
blur.Size = 3

print("NZ-IS v6 - TAP TO OPEN, HOLD TO DRAG!")
