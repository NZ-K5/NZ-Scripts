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
local isOpen = true
local isMinimized = false
local deleteInfectActive = false
local deleteKillActive = false
local deleteDoorsActive = false
local rtxActive = false
local futureActive = false
local teamEspActive = false

local infectConnection = nil
local killConnection = nil
local doorsConnection = nil
local espConnection = nil
local espObjects = {}

local deletedInfect = {}
local deletedKill = {}
local deletedDoors = {}

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    GlobalShadows = Lighting.GlobalShadows,
    ShadowSoftness = Lighting.ShadowSoftness,
    Technology = Lighting.Technology
}

-- ========== MAIN GUI FRAME ==========
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 280)
frame.Position = UDim2.new(0.5, -160, 0.5, -140)
frame.BackgroundColor3 = themes.Default.background
frame.BackgroundTransparency = 0.08
frame.ClipsDescendants = true
frame.Parent = root
frame.Visible = true
frame.ZIndex = 10
frame.Active = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = themes.Default.stroke
stroke.Thickness = 1.5
stroke.Transparency = 0.6

-- ========== TITLE BAR (TAP TO MINIMIZE) ==========
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundTransparency = 0.2
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
titleBar.Parent = frame
titleBar.Active = true

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "NZ-IS"
titleLabel.TextColor3 = themes.Default.accent
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

-- ========== MINIMIZED SQUARE (hidden by default) ==========
local miniFrame = Instance.new("Frame")
miniFrame.Size = UDim2.new(0, 60, 0, 60)
miniFrame.Position = UDim2.new(0.5, -30, 0.5, -30)
miniFrame.BackgroundColor3 = themes.Default.accent
miniFrame.BackgroundTransparency = 0.1
miniFrame.ClipsDescendants = true
miniFrame.Parent = root
miniFrame.Visible = false
miniFrame.ZIndex = 999
miniFrame.Active = true

local miniCorner = Instance.new("UICorner", miniFrame)
miniCorner.CornerRadius = UDim.new(0, 12)

local miniStroke = Instance.new("UIStroke", miniFrame)
miniStroke.Color = themes.Default.accent
miniStroke.Thickness = 2
miniStroke.Transparency = 0.3

local miniLabel = Instance.new("TextLabel")
miniLabel.Size = UDim2.new(1, 0, 1, 0)
miniLabel.Text = "NZ"
miniLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
miniLabel.TextSize = 14
miniLabel.Font = Enum.Font.GothamBold
miniLabel.BackgroundTransparency = 1
miniLabel.Parent = miniFrame

-- ========== TABS ==========
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 26)
tabContainer.Position = UDim2.new(0, 5, 0, 48)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local function createTab(name, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 95, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BackgroundTransparency = 0.3
    btn.Parent = tabContainer
    btn.AutoButtonColor = true
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 5)
    return btn
end

local tabMods = createTab("Mods", 0)
local tabGraphics = createTab("Graphics", 100)
local tabTheme = createTab("Theme", 200)

-- ========== PAGES ==========
local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -82)
    pg.Position = UDim2.new(0, 5, 0, 78)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 350)
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local modsPage = createPage()
local graphicsPage = createPage()
local themePage = createPage()

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
    btn.Position = UDim2.new(0, 180, 0, y)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    btn.Parent = parent
    btn.AutoButtonColor = true
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 4)
    return btn
end

-- ========== MODS PAGE ==========
local yOff = 4

makeLabel("Delete Infected", yOff, modsPage, 120)
local infectBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable Kill Parts", yOff, modsPage, 120)
local killBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable Doors/Gates", yOff, modsPage, 120)
local doorsBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("TEAM ESP", yOff, modsPage, 120)
local espBtn = makeToggle(yOff, modsPage)
yOff = yOff + 32

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 22)
statusLabel.Position = UDim2.new(0, 0, 0, yOff)
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamBold
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = modsPage
yOff = yOff + 28

modsPage.CanvasSize = UDim2.new(0, 0, 0, yOff + 10)

-- ========== GRAPHICS PAGE ==========
local gY = 4

makeLabel("RTX Graphics", gY, graphicsPage, 120)
local rtxBtn = makeToggle(gY, graphicsPage)
gY = gY + 28

makeLabel("Realistic/Future Lighting", gY, graphicsPage, 120)
local futureBtn = makeToggle(gY, graphicsPage)
gY = gY + 28

local gDesc = Instance.new("TextLabel")
gDesc.Size = UDim2.new(1, -10, 0, 30)
gDesc.Position = UDim2.new(0, 0, 0, gY)
gDesc.Text = "Lighting: Enables Future/Realistic tech\nRTX: Full visual overhaul"
gDesc.TextColor3 = Color3.fromRGB(150, 150, 170)
gDesc.TextSize = 10
gDesc.Font = Enum.Font.Gotham
gDesc.BackgroundTransparency = 1
gDesc.TextXAlignment = Enum.TextXAlignment.Left
gDesc.Parent = graphicsPage
gY = gY + 40

graphicsPage.CanvasSize = UDim2.new(0, 0, 0, gY + 10)

-- ========== THEME PAGE ==========
local themeY = 4
local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(1, -10, 0, 22)
themeLabel.Position = UDim2.new(0, 0, 0, themeY)
themeLabel.Text = "THEMES"
themeLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
themeLabel.TextSize = 11
themeLabel.Font = Enum.Font.GothamBold
themeLabel.BackgroundTransparency = 1
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.Parent = themePage
themeY = themeY + 28

local function createThemeButton(name, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    btn.Parent = themePage
    btn.AutoButtonColor = true
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 5)

    local function applyTheme()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        statusLabel.TextColor3 = t.accent
        miniFrame.BackgroundColor3 = t.accent
        miniStroke.Color = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= infectBtn and child ~= killBtn and child ~= doorsBtn and child ~= espBtn and child ~= rtxBtn and child ~= futureBtn then
                if child.Text == "Mods" or child.Text == "Graphics" or child.Text == "Theme" then
                    child.TextColor3 = t.accent
                end
            end
            if child:IsA("ScrollingFrame") then
                child.ScrollBarImageColor3 = t.accent
            end
        end
        
        local function updateToggle(btn, active)
            if active then
                btn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
                btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
                btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
        updateToggle(infectBtn, deleteInfectActive)
        updateToggle(killBtn, deleteKillActive)
        updateToggle(doorsBtn, deleteDoorsActive)
        updateToggle(espBtn, teamEspActive)
        updateToggle(rtxBtn, rtxActive)
        updateToggle(futureBtn, futureActive)
    end

    btn.MouseButton1Click:Connect(applyTheme)
    btn.TouchTap:Connect(applyTheme)
    return btn
end

local themeColors = {
    {name = "Default", color = Color3.fromRGB(30, 20, 25)},
    {name = "Crimson", color = Color3.fromRGB(35, 15, 20)},
    {name = "Cyber", color = Color3.fromRGB(10, 15, 40)},
    {name = "Amber", color = Color3.fromRGB(35, 25, 15)},
    {name = "Violet", color = Color3.fromRGB(25, 15, 40)}
}

for _, t in ipairs(themeColors) do
    createThemeButton(t.name, themeY, t.color)
    themeY = themeY + 33
end

-- ========== CORE FUNCTIONS ==========

local function restoreInfect()
    local count = 0
    local items = {}
    for _, item in pairs(deletedInfect) do
        if item and not item.Parent then
            table.insert(items, item)
        end
    end
    for _, item in pairs(items) do
        pcall(function()
            item.Parent = workspace
            count = count + 1
        end)
    end
    deletedInfect = {}
    if count > 0 then
        statusLabel.Text = "Restored " .. count .. " infect"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
    return count
end

local function restoreKill()
    local count = 0
    local items = {}
    for _, item in pairs(deletedKill) do
        if item and not item.Parent then
            table.insert(items, item)
        end
    end
    for _, item in pairs(items) do
        pcall(function()
            item.Parent = workspace
            count = count + 1
        end)
    end
    deletedKill = {}
    if count > 0 then
        statusLabel.Text = "Restored " .. count .. " kill"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
    return count
end

local function restoreDoors()
    local count = 0
    local items = {}
    for _, item in pairs(deletedDoors) do
        if item and not item.Parent then
            table.insert(items, item)
        end
    end
    for _, item in pairs(items) do
        pcall(function()
            item.Parent = workspace
            count = count + 1
        end)
    end
    deletedDoors = {}
    if count > 0 then
        statusLabel.Text = "Restored " .. count .. " doors"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
    return count
end

local function scanAndDeleteInfect()
    if not deleteInfectActive then
        restoreInfect()
        return
    end
    local found = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name and string.lower(v.Name):find("infect") then
                table.insert(found, v)
            end
        end
    end
    for _, v in pairs(found) do
        if v and v.Parent then
            table.insert(deletedInfect, v)
            pcall(function() v.Parent = nil end)
        end
    end
    if #found > 0 then
        statusLabel.Text = "Del " .. #found .. " inf"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif deleteInfectActive then
        statusLabel.Text = "No infect found"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

local function scanAndDeleteKill()
    if not deleteKillActive then
        restoreKill()
        return
    end
    local found = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name and string.lower(v.Name):find("kill") then
                table.insert(found, v)
            end
        end
    end
    for _, v in pairs(found) do
        if v and v.Parent then
            table.insert(deletedKill, v)
            pcall(function() v.Parent = nil end)
        end
    end
    if #found > 0 then
        statusLabel.Text = "Del " .. #found .. " kill"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif deleteKillActive then
        statusLabel.Text = "No kill found"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

local function scanAndDeleteDoors()
    if not deleteDoorsActive then
        restoreDoors()
        return
    end
    local found = {}
    local keywords = {"door", "gate", "portal", "doorway", "entrance", "exit"}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name then
                local nameLower = string.lower(v.Name)
                for _, kw in pairs(keywords) do
                    if nameLower:find(kw) then
                        table.insert(found, v)
                        break
                    end
                end
            end
        end
    end
    for _, v in pairs(found) do
        if v and v.Parent then
            table.insert(deletedDoors, v)
            pcall(function() v.Parent = nil end)
        end
    end
    if #found > 0 then
        statusLabel.Text = "Del " .. #found .. " doors"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif deleteDoorsActive then
        statusLabel.Text = "No doors found"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

-- ========== ESP SYSTEM ==========
local function getTeamColor(plr)
    if plr.Team then
        return plr.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function createEspForPlayer(target)
    if target == player then return end
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = target.Character.HumanoidRootPart
    local teamColor = getTeamColor(target)
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.3
    highlight.FillColor = teamColor
    highlight.OutlineColor = teamColor
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = target.Character
    
    local box = Instance.new("Frame")
    box.Name = "ESP_Box"
    box.Size = UDim2.new(0, 30, 0, 60)
    box.Position = UDim2.new(0.5, -15, 0.5, -30)
    box.BackgroundTransparency = 0.5
    box.BackgroundColor3 = teamColor
    box.BorderSizePixel = 2
    box.BorderColor3 = teamColor
    box.Parent = root
    box.Visible = false
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ESP_Name"
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
    line.Name = "ESP_Line"
    line.Size = UDim2.new(0, 1, 0, 1)
    line.BackgroundTransparency = 0.6
    line.BackgroundColor3 = teamColor
    line.Parent = root
    line.Visible = false
    
    espObjects[target] = {
        Highlight = highlight,
        Box = box,
        Name = nameLabel,
        Line = line,
        Root = root
    }
end

local function updateEsp()
    if not teamEspActive then
        for target, data in pairs(espObjects) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Box then data.Box:Destroy() end
            if data.Line then data.Line:Destroy() end
        end
        espObjects = {}
        return
    end
    
    local players = Players:GetPlayers()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = character.HumanoidRootPart.Position
    
    for _, target in pairs(players) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[target] then
                createEspForPlayer(target)
            end
            
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
                    local length = math.sqrt(dx^2 + dy^2)
                    length = math.clamp(length, 20, 300)
                    
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

local function toggleEsp()
    teamEspActive = not teamEspActive
    if teamEspActive then
        espBtn.Text = "ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        espBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "ESP ENABLED"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        
        if espConnection then
            pcall(function() espConnection:Disconnect() end)
            espConnection = nil
        end
        
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player then
                createEspForPlayer(target)
            end
        end
        
        espConnection = RunService.RenderStepped:Connect(updateEsp)
        
        Players.PlayerAdded:Connect(function(target)
            task.wait(0.5)
            if teamEspActive then
                createEspForPlayer(target)
            end
        end)
        
    else
        espBtn.Text = "OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        espBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "ESP DISABLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        if espConnection then
            pcall(function() espConnection:Disconnect() end)
            espConnection = nil
        end
        
        for target, data in pairs(espObjects) do
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

-- ========== LIGHTING TOGGLE ==========
local function toggleFuture()
    futureActive = not futureActive
    
    if futureActive then
        futureBtn.Text = "ON"
        futureBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        futureBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Lighting ON"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        
        originalLighting.Technology = Lighting.Technology
        
        pcall(function()
            Lighting.Technology = Enum.Technology.Future
        end)
        if Lighting.Technology ~= Enum.Technology.Future then
            pcall(function()
                Lighting.Technology = Enum.Technology.Realistic
            end)
        end
        
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.5
        
    else
        futureBtn.Text = "OFF"
        futureBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        futureBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Lighting OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        Lighting.Technology = originalLighting.Technology
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.ShadowSoftness = originalLighting.ShadowSoftness
        
        task.wait(0.5)
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

futureBtn.MouseButton1Click:Connect(toggleFuture)
futureBtn.TouchTap:Connect(toggleFuture)

-- ========== RTX FUNCTION ==========
local function toggleRTX()
    rtxActive = not rtxActive
    
    if rtxActive then
        rtxBtn.Text = "ON"
        rtxBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        rtxBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "RTX ENABLED"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        
        originalLighting.Brightness = Lighting.Brightness
        originalLighting.ClockTime = Lighting.ClockTime
        originalLighting.Ambient = Lighting.Ambient
        originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLighting.ColorShift_Top = Lighting.ColorShift_Top
        originalLighting.ColorShift_Bottom = Lighting.ColorShift_Bottom
        originalLighting.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
        originalLighting.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
        originalLighting.GlobalShadows = Lighting.GlobalShadows
        originalLighting.ShadowSoftness = Lighting.ShadowSoftness
        originalLighting.Technology = Lighting.Technology
        
        pcall(function()
            Lighting.Technology = Enum.Technology.Future
        end)
        if Lighting.Technology ~= Enum.Technology.Future then
            pcall(function()
                Lighting.Technology = Enum.Technology.Realistic
            end)
        end
        
        local currentTime = Lighting.ClockTime
        local isNight = currentTime < 6 or currentTime > 18
        
        if isNight then
            Lighting.Brightness = 0.4
            Lighting.Ambient = Color3.fromRGB(20, 20, 30)
            Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 25)
            Lighting.ColorShift_Top = Color3.fromRGB(10, 15, 30)
            Lighting.ColorShift_Bottom = Color3.fromRGB(5, 5, 15)
            Lighting.ShadowSoftness = 0.8
            statusLabel.Text = "RTX NIGHT MODE"
        else
            Lighting.Brightness = 2.5
            Lighting.Ambient = Color3.fromRGB(80, 85, 95)
            Lighting.OutdoorAmbient = Color3.fromRGB(120, 130, 150)
            Lighting.ColorShift_Top = Color3.fromRGB(180, 200, 255)
            Lighting.ColorShift_Bottom = Color3.fromRGB(100, 80, 120)
            Lighting.ShadowSoftness = 0.5
            statusLabel.Text = "RTX DAY MODE"
        end
        
        Lighting.EnvironmentDiffuseScale = 1.5
        Lighting.EnvironmentSpecularScale = 1.5
        Lighting.GlobalShadows = true
        
        local bloom = Lighting:FindFirstChild("Bloom")
        if not bloom then
            bloom = Instance.new("BloomEffect")
            bloom.Name = "Bloom"
            bloom.Intensity = isNight and 0.15 or 0.5
            bloom.Size = isNight and 1 or 2
            bloom.Threshold = isNight and 0.5 or 0.3
            bloom.Parent = Lighting
        else
            bloom.Intensity = isNight and 0.15 or 0.5
            bloom.Size = isNight and 1 or 2
            bloom.Threshold = isNight and 0.5 or 0.3
        end
        
        local cc = Lighting:FindFirstChild("ColorCorrection")
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "ColorCorrection"
            cc.Saturation = isNight and 0.8 or 1.1
            cc.Contrast = isNight and 0.9 or 1.1
            cc.Brightness = isNight and -0.1 or 0.05
            cc.Parent = Lighting
        else
            cc.Saturation = isNight and 0.8 or 1.1
            cc.Contrast = isNight and 0.9 or 1.1
            cc.Brightness = isNight and -0.1 or 0.05
        end
        
        if not isNight then
            local sunRays = Lighting:FindFirstChild("SunRays")
            if not sunRays then
                sunRays = Instance.new("SunRaysEffect")
                sunRays.Name = "SunRays"
                sunRays.Intensity = 0.15
                sunRays.Spread = 0.5
                sunRays.Parent = Lighting
            else
                sunRays.Intensity = 0.15
                sunRays.Spread = 0.5
                sunRays.Enabled = true
            end
        else
            local sunRays = Lighting:FindFirstChild("SunRays")
            if sunRays then sunRays.Enabled = false end
        end
        
        local dof = Lighting:FindFirstChild("DepthOfField")
        if not dof then
            dof = Instance.new("DepthOfFieldEffect")
            dof.Name = "DepthOfField"
            dof.FarIntensity = isNight and 0.1 or 0.3
            dof.FarBlurSize = isNight and 1 or 2
            dof.NearIntensity = 0
            dof.NearBlurSize = 0
            dof.FocusDistance = isNight and 30 or 50
            dof.InFocusRadius = isNight and 20 or 30
            dof.Parent = Lighting
        else
            dof.FarIntensity = isNight and 0.1 or 0.3
            dof.FarBlurSize = isNight and 1 or 2
            dof.NearIntensity = 0
            dof.NearBlurSize = 0
            dof.FocusDistance = isNight and 30 or 50
            dof.InFocusRadius = isNight and 20 or 30
        end
        
        statusLabel.TextColor3 = isNight and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(0, 200, 255)
        
    else
        rtxBtn.Text = "OFF"
        rtxBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        rtxBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "RTX DISABLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ColorShift_Top = originalLighting.ColorShift_Top
        Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
        Lighting.EnvironmentDiffuseScale = originalLighting.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = originalLighting.EnvironmentSpecularScale
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.ShadowSoftness = originalLighting.ShadowSoftness
        Lighting.Technology = originalLighting.Technology
        
        local bloom = Lighting:FindFirstChild("Bloom")
        if bloom then bloom:Destroy() end
        local cc = Lighting:FindFirstChild("ColorCorrection")
        if cc then cc:Destroy() end
        local sunRays = Lighting:FindFirstChild("SunRays")
        if sunRays then sunRays:Destroy() end
        local dof = Lighting:FindFirstChild("DepthOfField")
        if dof then dof:Destroy() end
        
        task.wait(0.5)
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

rtxBtn.MouseButton1Click:Connect(toggleRTX)
rtxBtn.TouchTap:Connect(toggleRTX)

-- ========== TOGGLES ==========
local function toggleInfect()
    deleteInfectActive = not deleteInfectActive
    if deleteInfectActive then
        infectBtn.Text = "ON"
        infectBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        infectBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Scanning infect..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        if infectConnection then
            pcall(function() infectConnection:Disconnect() end)
            infectConnection = nil
        end
        scanAndDeleteInfect()
        infectConnection = RunService.Heartbeat:Connect(function()
            if deleteInfectActive then
                scanAndDeleteInfect()
            end
        end)
    else
        infectBtn.Text = "OFF"
        infectBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        infectBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if infectConnection then
            pcall(function() infectConnection:Disconnect() end)
            infectConnection = nil
        end
        local restored = restoreInfect()
        if restored > 0 then
            statusLabel.Text = "Restored " .. restored .. " infect"
        else
            statusLabel.Text = "No infect to restore"
        end
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
        statusLabel.Text = "Scanning kill..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        if killConnection then
            pcall(function() killConnection:Disconnect() end)
            killConnection = nil
        end
        scanAndDeleteKill()
        killConnection = RunService.Heartbeat:Connect(function()
            if deleteKillActive then
                scanAndDeleteKill()
            end
        end)
    else
        killBtn.Text = "OFF"
        killBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        killBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if killConnection then
            pcall(function() killConnection:Disconnect() end)
            killConnection = nil
        end
        local restored = restoreKill()
        if restored > 0 then
            statusLabel.Text = "Restored " .. restored .. " kill"
        else
            statusLabel.Text = "No kill to restore"
        end
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
        statusLabel.Text = "Scanning doors..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        if doorsConnection then
            pcall(function() doorsConnection:Disconnect() end)
            doorsConnection = nil
        end
        scanAndDeleteDoors()
        doorsConnection = RunService.Heartbeat:Connect(function()
            if deleteDoorsActive then
                scanAndDeleteDoors()
            end
        end)
    else
        doorsBtn.Text = "OFF"
        doorsBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        doorsBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if doorsConnection then
            pcall(function() doorsConnection:Disconnect() end)
            doorsConnection = nil
        end
        local restored = restoreDoors()
        if restored > 0 then
            statusLabel.Text = "Restored " .. restored .. " doors"
        else
            statusLabel.Text = "No doors to restore"
        end
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

doorsBtn.MouseButton1Click:Connect(toggleDoors)
doorsBtn.TouchTap:Connect(toggleDoors)

-- ========== TAB SWITCHING ==========
local function switchToMods()
    modsPage.Visible = true
    graphicsPage.Visible = false
    themePage.Visible = false
    tabMods.TextColor3 = themes[currentTheme].accent
    tabGraphics.TextColor3 = Color3.fromRGB(180, 180, 210)
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
end

local function switchToGraphics()
    modsPage.Visible = false
    graphicsPage.Visible = true
    themePage.Visible = false
    tabGraphics.TextColor3 = themes[currentTheme].accent
    tabMods.TextColor3 = Color3.fromRGB(180, 180, 210)
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
end

local function switchToTheme()
    modsPage.Visible = false
    graphicsPage.Visible = false
    themePage.Visible = true
    tabTheme.TextColor3 = themes[currentTheme].accent
    tabMods.TextColor3 = Color3.fromRGB(180, 180, 210)
    tabGraphics.TextColor3 = Color3.fromRGB(180, 180, 210)
end

tabMods.MouseButton1Click:Connect(switchToMods)
tabMods.TouchTap:Connect(switchToMods)
tabGraphics.MouseButton1Click:Connect(switchToGraphics)
tabGraphics.TouchTap:Connect(switchToGraphics)
tabTheme.MouseButton1Click:Connect(switchToTheme)
tabTheme.TouchTap:Connect(switchToTheme)

modsPage.Visible = true
tabMods.TextColor3 = themes.Default.accent

-- ========== ARROW BUTTON (OPEN/CLOSE ONLY) ==========
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 1, -65)
toggleBtn.Text = "◀"
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
toggleBtn.Parent = root
toggleBtn.AutoButtonColor = true
toggleBtn.ZIndex = 999
toggleBtn.Active = true

local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Thickness = 2
toggleStroke.Transparency = 0.2

-- Arrow button ONLY opens/closes (no drag)
local function onToggleClick()
    if isOpen then closeGUI() else openGUI() end
end

toggleBtn.MouseButton1Click:Connect(onToggleClick)
toggleBtn.TouchTap:Connect(onToggleClick)

-- ========== MINIMIZE FUNCTIONS ==========
local function minimizeGUI()
    if isMinimized then return end
    isMinimized = true
    
    -- Hide main frame, show mini square
    frame.Visible = false
    miniFrame.Visible = true
    
    -- Position mini square where the frame was
    local framePos = frame.Position
    miniFrame.Position = UDim2.new(
        framePos.X.Scale,
        framePos.X.Offset + 160 - 30,
        framePos.Y.Scale,
        framePos.Y.Offset + 140 - 30
    )
    
    blur.Size = 0
end

local function unminimizeGUI()
    if not isMinimized then return end
    isMinimized = false
    
    -- Show main frame, hide mini square
    frame.Visible = true
    miniFrame.Visible = false
    
    blur.Size = 3
end

-- ========== TITLE BAR TAP TO MINIMIZE ==========
titleBar.MouseButton1Click:Connect(minimizeGUI)
titleBar.TouchTap:Connect(minimizeGUI)

-- ========== MINI SQUARE TAP TO UNMINIMIZE + DRAG ==========
-- Tap to unminimize
miniFrame.MouseButton1Click:Connect(unminimizeGUI)
miniFrame.TouchTap:Connect(unminimizeGUI)

-- Drag the mini square (hold and drag)
local miniDragData = {
    dragging = false,
    startPos = nil,
    frameStart = nil
}

miniFrame.TouchBegan:Connect(function(input)
    miniDragData.dragging = true
    miniDragData.startPos = input.Position
    miniDragData.frameStart = miniFrame.Position
end)

miniFrame.TouchMoved:Connect(function(input)
    if not miniDragData.dragging or not miniDragData.startPos then return end
    local delta = input.Position - miniDragData.startPos
    miniFrame.Position = UDim2.new(
        miniDragData.frameStart.X.Scale,
        miniDragData.frameStart.X.Offset + delta.X,
        miniDragData.frameStart.Y.Scale,
        miniDragData.frameStart.Y.Offset + delta.Y
    )
end)

miniFrame.TouchEnded:Connect(function()
    miniDragData.dragging = false
    miniDragData.startPos = nil
    miniDragData.frameStart = nil
end)

miniFrame.MouseButton1Down:Connect(function(input)
    miniDragData.dragging = true
    miniDragData.startPos = input.Position
    miniDragData.frameStart = miniFrame.Position
end)

miniFrame.MouseMoved:Connect(function(input)
    if not miniDragData.dragging or not miniDragData.startPos then return end
    local delta = input.Position - miniDragData.startPos
    miniFrame.Position = UDim2.new(
        miniDragData.frameStart.X.Scale,
        miniDragData.frameStart.X.Offset + delta.X,
        miniDragData.frameStart.Y.Scale,
        miniDragData.frameStart.Y.Offset + delta.Y
    )
end)

miniFrame.MouseButton1Up:Connect(function()
    miniDragData.dragging = false
    miniDragData.startPos = nil
    miniDragData.frameStart = nil
end)

-- ========== OPEN/CLOSE FUNCTIONS ==========
local function openGUI()
    isOpen = true
    frame.Visible = true
    toggleBtn.Text = "◀"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    if not isMinimized then
        blur.Size = 3
    end
end

local function closeGUI()
    isOpen = false
    frame.Visible = false
    miniFrame.Visible = false
    toggleBtn.Text = "▶"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    blur.Size = 0
end

-- ========== HOTKEY ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if isOpen then closeGUI() else openGUI() end
    end
end)

-- ========== FORCE VISIBILITY ==========
task.wait(0.3)
frame.Visible = true
frame.BackgroundTransparency = 0.08
frame.Size = UDim2.new(0, 320, 0, 280)
frame.Position = UDim2.new(0.5, -160, 0.5, -140)
blur.Size = 3
toggleBtn.Text = "◀"
miniFrame.Visible = false

print("NZ-IS v6 - Tap title bar to minimize, tap mini square to restore, drag mini square to move!")
