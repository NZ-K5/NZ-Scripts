-- LOADER FOR NZ-INFSmile.lua (Mobile-friendly chunked loading)
local scriptChunks = {
    [1] = [[
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
local shitflockActive = false
local infJumpActive = false
local noclipActive = false
local flyActive = false
local walkspeedValue = 16
local jumppowerValue = 50

local infectConnection = nil
local killConnection = nil
local doorsConnection = nil
local espConnection = nil
local flyConnection = nil
local noclipConnection = nil
local espObjects = {}
local flyBodyVelocity = nil
local flyBodyGyro = nil
local infJumpBind = nil

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
frame.Size = UDim2.new(0, 360, 0, 340)
frame.Position = UDim2.new(0.5, -180, 0.5, -170)
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

-- ========== TITLE BAR ==========
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundTransparency = 0.2
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
titleBar.Parent = frame
titleBar.Active = true

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "NZ-IS"
titleLabel.TextColor3 = themes.Default.accent
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

-- ========== MINIMIZE BUTTON ==========
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -68, 0, 7)
minBtn.Text = "─"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
minBtn.BackgroundTransparency = 0.2
minBtn.Parent = titleBar
minBtn.AutoButtonColor = true
local minCorner = Instance.new("UICorner", minBtn)
minCorner.CornerRadius = UDim.new(0, 6)

-- ========== CLOSE/OPEN BUTTON ==========
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0, 7)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Parent = titleBar
closeBtn.AutoButtonColor = true
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

-- ========== MINIMIZED SQUARE ==========
local miniFrame = Instance.new("Frame")
miniFrame.Size = UDim2.new(0, 55, 0, 55)
miniFrame.Position = UDim2.new(1, -65, 0, 10)
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
]],
    [2] = [[
-- ========== SHITFLOCK BUTTON ==========
local shitflockBtn = Instance.new("TextButton")
shitflockBtn.Size = UDim2.new(0, 55, 0, 55)
shitflockBtn.Position = UDim2.new(0, 10, 1, -70)
shitflockBtn.Text = "🔄"
shitflockBtn.TextSize = 26
shitflockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shitflockBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
shitflockBtn.Parent = root
shitflockBtn.Visible = false
shitflockBtn.ZIndex = 999
shitflockBtn.Active = true

local shitflockCorner = Instance.new("UICorner", shitflockBtn)
shitflockCorner.CornerRadius = UDim.new(1, 0)
local shitflockStroke = Instance.new("UIStroke", shitflockBtn)
shitflockStroke.Color = Color3.fromRGB(255, 255, 255)
shitflockStroke.Thickness = 2
shitflockStroke.Transparency = 0.2

shitflockBtn.MouseButton1Click:Connect(function()
    print("Shitflock button pressed!")
end)
shitflockBtn.TouchTap:Connect(function()
    print("Shitflock button pressed!")
end)

-- ========== FLY MOBILE CONTROLS ==========
local flyUpBtn = Instance.new("TextButton")
flyUpBtn.Size = UDim2.new(0, 70, 0, 70)
flyUpBtn.Position = UDim2.new(1, -85, 0.5, -85)
flyUpBtn.Text = "▲"
flyUpBtn.TextSize = 30
flyUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyUpBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
flyUpBtn.BackgroundTransparency = 0.5
flyUpBtn.Parent = root
flyUpBtn.Visible = false
flyUpBtn.ZIndex = 999
local flyUpCorner = Instance.new("UICorner", flyUpBtn)
flyUpCorner.CornerRadius = UDim.new(1, 0)

local flyDownBtn = Instance.new("TextButton")
flyDownBtn.Size = UDim2.new(0, 70, 0, 70)
flyDownBtn.Position = UDim2.new(1, -85, 0.5, -5)
flyDownBtn.Text = "▼"
flyDownBtn.TextSize = 30
flyDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyDownBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
flyDownBtn.BackgroundTransparency = 0.5
flyDownBtn.Parent = root
flyDownBtn.Visible = false
flyDownBtn.ZIndex = 999
local flyDownCorner = Instance.new("UICorner", flyDownBtn)
flyDownCorner.CornerRadius = UDim.new(1, 0)

local flyUpHeld = false
local flyDownHeld = false

flyUpBtn.TouchBegan:Connect(function() flyUpHeld = true end)
flyUpBtn.TouchEnded:Connect(function() flyUpHeld = false end)
flyUpBtn.MouseButton1Down:Connect(function() flyUpHeld = true end)
flyUpBtn.MouseButton1Up:Connect(function() flyUpHeld = false end)

flyDownBtn.TouchBegan:Connect(function() flyDownHeld = true end)
flyDownBtn.TouchEnded:Connect(function() flyDownHeld = false end)
flyDownBtn.MouseButton1Down:Connect(function() flyDownHeld = true end)
flyDownBtn.MouseButton1Up:Connect(function() flyDownHeld = false end)

-- ========== TABS ==========
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 28)
tabContainer.Position = UDim2.new(0, 5, 0, 48)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local function createTab(name, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 10
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
local tabPlayer = createTab("Player", 70)
local tabGraphics = createTab("Graphics", 140)
local tabTheme = createTab("Theme", 210)
local tabOthers = createTab("Others", 280)

-- ========== PAGES ==========
local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -84)
    pg.Position = UDim2.new(0, 5, 0, 80)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 550)
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local modsPage = createPage()
local playerPage = createPage()
local graphicsPage = createPage()
local themePage = createPage()
local othersPage = createPage()

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

local function makeSlider(text, y, parent, minVal, maxVal, defaultVal, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 120, 0, 22)
    label.Position = UDim2.new(0, 0, 0, y)
    label.Text = text
    label.TextColor3 = themes.Default.text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 22)
    valueLabel.Position = UDim2.new(0, 125, 0, y)
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = themes.Default.accent
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = parent
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0, 120, 0, 8)
    slider.Position = UDim2.new(0, 170, 0, y + 7)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    slider.Parent = parent
    local sliderCorner = Instance.new("UICorner", slider)
    sliderCorner.CornerRadius = UDim.new(0, 4)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = themes.Default.accent
    fill.Parent = slider
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 4)
    
    local currentVal = defaultVal
    
    local function updateSlider(input)
        local pos = input.Position.X - slider.AbsolutePosition.X
        local width = slider.AbsoluteSize.X
        local percent = math.clamp(pos / width, 0, 1)
        local newVal = math.floor((minVal + (maxVal - minVal) * percent) * 10) / 10
        if newVal < minVal then newVal = minVal end
        if newVal > maxVal then newVal = maxVal end
        currentVal = newVal
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(newVal)
        if callback then callback(newVal) end
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)
    
    slider.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)
    
    return {Slider = slider, Fill = fill, ValueLabel = valueLabel, GetValue = function() return currentVal end}
end

local function makeButton(text, y, parent, color)
    color = color or Color3.fromRGB(60, 30, 30)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 0, 32)
    btn.Position = UDim2.new(0.5, -75, 0, y)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = color
    btn.Parent = parent
    btn.AutoButtonColor = true
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end
]],
    [3] = [[
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

-- ========== PLAYER PAGE ==========
local pY = 4

makeLabel("Enable Shitflock", pY, playerPage, 120)
local shitflockToggle = makeToggle(pY, playerPage)
pY = pY + 28

local wsSlider = makeSlider("WalkSpeed", pY, playerPage, 10, 100, 16, function(val)
    walkspeedValue = val
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = val
    end
end)
pY = pY + 36

local jpSlider = makeSlider("JumpPower", pY, playerPage, 20, 200, 50, function(val)
    jumppowerValue = val
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = val
    end
end)
pY = pY + 36

makeLabel("Inf Jump", pY, playerPage, 120)
local infJumpBtn = makeToggle(pY, playerPage)
pY = pY + 28

makeLabel("Noclip", pY, playerPage, 120)
local noclipBtn = makeToggle(pY, playerPage)
pY = pY + 28

makeLabel("Fly", pY, playerPage, 120)
local flyBtn = makeToggle(pY, playerPage)
pY = pY + 28

local playerDesc = Instance.new("TextLabel")
playerDesc.Size = UDim2.new(1, -10, 0, 30)
playerDesc.Position = UDim2.new(0, 0, 0, pY)
playerDesc.Text = "Fly: ▲ ▼ buttons appear on the right side"
playerDesc.TextColor3 = Color3.fromRGB(150, 150, 170)
playerDesc.TextSize = 10
playerDesc.Font = Enum.Font.Gotham
playerDesc.BackgroundTransparency = 1
playerDesc.TextXAlignment = Enum.TextXAlignment.Left
playerDesc.Parent = playerPage
pY = pY + 40

playerPage.CanvasSize = UDim2.new(0, 0, 0, pY + 10)

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
        minBtn.TextColor3 = t.accent
        closeBtn.TextColor3 = t.accent
        shitflockBtn.BackgroundColor3 = t.accent
        flyUpBtn.BackgroundColor3 = t.accent
        flyDownBtn.BackgroundColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= infectBtn and child ~= killBtn and child ~= doorsBtn and child ~= espBtn and child ~= rtxBtn and child ~= futureBtn and child ~= minBtn and child ~= closeBtn and child ~= shitflockToggle and child ~= infJumpBtn and child ~= noclipBtn and child ~= flyBtn then
                if child.Text == "Mods" or child.Text == "Player" or child.Text == "Graphics" or child.Text == "Theme" or child.Text == "Others" then
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
        updateToggle(shitflockToggle, shitflockActive)
        updateToggle(infJumpBtn, infJumpActive)
        updateToggle(noclipBtn, noclipActive)
        updateToggle(flyBtn, flyActive)
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

-- ========== OTHERS PAGE ==========
local oY = 10

local destroyBtn = makeButton("Destroy GUI", oY, othersPage, Color3.fromRGB(80, 20, 20))
oY = oY + 40

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Size = UDim2.new(1, -10, 0, 20)
creditsLabel.Position = UDim2.new(0, 0, 0, oY)
creditsLabel.Text = "NZ-IS v6"
creditsLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
creditsLabel.TextSize = 10
creditsLabel.Font = Enum.Font.Gotham
creditsLabel.BackgroundTransparency = 1
creditsLabel.TextXAlignment = Enum.TextXAlignment.Center
creditsLabel.Parent = othersPage
oY = oY + 30

othersPage.CanvasSize = UDim2.new(0, 0, 0, oY + 10)
]],
    [4] = [[
-- ========== SHITFLOCK TOGGLE ==========
local function toggleShitflock()
    shitflockActive = not shitflockActive
    if shitflockActive then
        shitflockToggle.Text = "ON"
        shitflockToggle.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        shitflockToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        shitflockBtn.Visible = true
        statusLabel.Text = "Shitflock ENABLED"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    else
        shitflockToggle.Text = "OFF"
        shitflockToggle.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        shitflockToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        shitflockBtn.Visible = false
        statusLabel.Text = "Shitflock DISABLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(0.5)
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

shitflockToggle.MouseButton1Click:Connect(toggleShitflock)
shitflockToggle.TouchTap:Connect(toggleShitflock)

-- ========== PLAYER MOD FUNCTIONS ==========

-- Inf Jump
local function setupInfJump()
    if infJumpBind then
        pcall(function() infJumpBind:Disconnect() end)
        infJumpBind = nil
    end
    
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    local jumpCount = 0
    local maxJumps = 999
    
    infJumpBind = hum.StateChanged:Connect(function(oldState, newState)
        if not infJumpActive then return end
        if newState == Enum.HumanoidStateType.Jumping then
            jumpCount = jumpCount + 1
        end
        if newState == Enum.HumanoidStateType.Landed then
            jumpCount = 0
        end
        if newState == Enum.HumanoidStateType.Freefall and jumpCount > 0 then
            task.wait(0.05)
            if infJumpActive and hum and hum.Parent then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function toggleInfJump()
    infJumpActive = not infJumpActive
    if infJumpActive then
        infJumpBtn.Text = "ON"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        infJumpBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Inf Jump ENABLED"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        setupInfJump()
    else
        infJumpBtn.Text = "OFF"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        infJumpBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Inf Jump DISABLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        if infJumpBind then
            pcall(function() infJumpBind:Disconnect() end)
            infJumpBind = nil
        end
        task.wait(0.5)
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

infJumpBtn.MouseButton1Click:Connect(toggleInfJump)
infJumpBtn.TouchTap:Connect(toggleInfJump)

-- Noclip
local function setupNoclip()
    if noclipConnection then
        pcall(function() noclipConnection:Disconnect() end)
        noclipConnection = nil
    end
    
    if not noclipActive then return end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if noclipActive and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function toggleNoclip()
    noclipActive = not noclipActive
    if noclipActive then
        noclipBtn.Text = "ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        noclipBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Noclip ENABLED"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        setupNoclip()
    else
        noclipBtn.Text = "OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        noclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Noclip DISABLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        if noclipConnection then
            pcall(function() noclipConnection:Disconnect() end)
            noclipConnection = nil
        end
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        task.wait(0.5)
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

noclipBtn.MouseButton1Click:Connect(toggleNoclip)
noclipBtn.TouchTap:Connect(toggleNoclip)

-- Fly
local function setupFly()
    if flyConnection then
        pcall(function() flyConnection:Disconnect() end)
        flyConnection = nil
    end
    
    if not flyActive then return end
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyActive then return end
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPart = char.HumanoidRootPart
        local hum = char:FindFirstChild("Humanoid")
        
        if not flyBodyVelocity or flyBodyVelocity.Parent == nil then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBodyVelocity.Parent = rootPart
        end
        
        if not flyBodyGyro or flyBodyGyro.Parent == nil then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBodyGyro.CFrame = rootPart.CFrame
            flyBodyGyro.Parent = rootPart
        end
        
        local moveDirection = Vector3.new()
        local forward = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + right end
        
        if flyUpHeld then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if flyDownHeld then moveDirection = moveDirection + Vector3.new(0, -1, 0) end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection + Vector3.new(0, -1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * 50
        end
        
        flyBodyVelocity.Velocity = moveDirection
        flyBodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + forward * 10)
        
        if hum then
            hum.PlatformStand = true
            hum.AutoRotate = false
        end
    end)
end

local function toggleFly()
    flyActive = not flyActive
    if flyActive then
        flyBtn.Text = "ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        flyBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Fly ENABLED"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        flyUpBtn.Visible = true
        flyDownBtn.Visible = true
        setupFly()
    else
        flyBtn.Text = "OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        flyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Fly DISABLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        flyUpBtn.Visible = false
        flyDownBtn.Visible = false
        flyUpHeld = false
        flyDownHeld = false
        if flyConnection then
            pcall(function() flyConnection:Disconnect() end)
            flyConnection = nil
        end
        if flyBodyVelocity then
            pcall(function() flyBodyVelocity:Destroy() end)
            flyBodyVelocity = nil
        end
        if flyBodyGyro then
            pcall(function() flyBodyGyro:Destroy() end)
            flyBodyGyro = nil
        end
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
            char.Humanoid.AutoRotate = true
        end
        task.wait(0.5)
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

flyBtn.MouseButton1Click:Connect(toggleFly)
flyBtn.TouchTap:Connect(toggleFly)

-- ========== CHARACTER ADDED REBIND ==========
local function onCharacterAdded(char)
    task.wait(0.3)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkspeedValue
        player.Character.Humanoid.JumpPower = jumppowerValue
    end
    if infJumpActive then setupInfJump() end
    if noclipActive then setupNoclip() end
    if flyActive then setupFly() end
end

player.CharacterAdded:Connect(onCharacterAdded)
]],
    [5] = [[
-- ========== DESTROY FUNCTION ==========
local function destroyGUI()
    if infectConnection then pcall(function() infectConnection:Disconnect() end) end
    if killConnection then pcall(function() killConnection:Disconnect() end) end
    if doorsConnection then pcall(function() doorsConnection:Disconnect() end) end
    if espConnection then pcall(function() espConnection:Disconnect() end) end
    if noclipConnection then pcall(function() noclipConnection:Disconnect() end) end
    if flyConnection then pcall(function() flyConnection:Disconnect() end) end
    if infJumpBind then pcall(function() infJumpBind:Disconnect() end) end
    if flyBodyVelocity then pcall(function() flyBodyVelocity:Destroy() end) end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) end
    for _, data in pairs(espObjects) do
        pcall(function()
            if data.Highlight then data.Highlight:Destroy() end
            if data.Box then data.Box:Destroy() end
            if data.Line then data.Line:Destroy() end
        end)
    end
    espObjects = {}
    root:Destroy()
    blur:Destroy()
end

destroyBtn.MouseButton1Click:Connect(destroyGUI)
destroyBtn.TouchTap:Connect(destroyGUI)

-- ========== CORE FUNCTIONS ==========
local function restoreInfect()
    local count = 0
    local items = {}
    for _, item in pairs(deletedInfect) do
        if item and not item.Parent then table.insert(items, item) end
    end
    for _, item in pairs(items) do
        pcall(function() item.Parent = workspace; count = count + 1 end)
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
        if item and not item.Parent then table.insert(items, item) end
    end
    for _, item in pairs(items) do
        pcall(function() item.Parent = workspace; count = count + 1 end)
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
        if item and not item.Parent then table.insert(items, item) end
    end
    for _, item in pairs(items) do
        pcall(function() item.Parent = workspace; count = count + 1 end)
    end
    deletedDoors = {}
    if count > 0 then
        statusLabel.Text = "Restored " .. count .. " doors"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
    return count
end

local function scanAndDeleteInfect()
    if not deleteInfectActive then restoreInfect(); return end
    local found = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name and string.lower(v.Name):find("infect") then table.insert(found, v) end
        end
    end
    for _, v in pairs(found) do
        if v and v.Parent then table.insert(deletedInfect, v); pcall(function() v.Parent = nil end) end
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
    if not deleteKillActive then restoreKill(); return end
    local found = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name and string.lower(v.Name):find("kill") then table.insert(found, v) end
        end
    end
    for _, v in pairs(found) do
        if v and v.Parent then table.insert(deletedKill, v); pcall(function() v.Parent = nil end) end
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
    if not deleteDoorsActive then restoreDoors(); return end
    local found, keywords = {}, {"door", "gate", "portal", "doorway", "entrance", "exit"}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") and v.Name then
            local nameLower = string.lower(v.Name)
            for _, kw in pairs(keywords) do
                if nameLower:find(kw) then table.insert(found, v); break end
            end
        end
    end
    for _, v in pairs(found) do
        if v and v.Parent then table.insert(deletedDoors, v); pcall(function() v.Parent = nil end) end
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
    if plr.Team then return plr.Team.TeamColor.Color end
    return Color3.fromRGB(255, 255, 255)
end

local function createEspForPlayer(target)
    if target == player then return end
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = target.Character.HumanoidRootPart
    local teamColor = getTeamColor(target)
    
    local highlight = Instance.new("Highlight")
    highlight.Name, highlight.FillTransparency, highlight.OutlineTransparency, highlight.FillColor, highlight.OutlineColor, highlight.DepthMode, highlight.Parent = "ESP_Highlight", 0.6, 0.3, teamColor, teamColor, Enum.HighlightDepthMode.AlwaysOnTop, target.Character
    
    local box = Instance.new("Frame")
    box.Name, box.Size, box.Position, box.BackgroundTransparency, box.BackgroundColor3, box.BorderSizePixel, box.BorderColor3, box.Parent, box.Visible = "ESP_Box", UDim2.new(0,30,0,60), UDim2.new(0.5,-15,0.5,-30), 0.5, teamColor, 2, teamColor, root, false
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name, nameLabel.Size, nameLabel.Position, nameLabel.Text, nameLabel.TextColor3, nameLabel.TextSize, nameLabel.Font, nameLabel.BackgroundTransparency, nameLabel.TextStrokeColor3, nameLabel.TextStrokeTransparency, nameLabel.Parent = "ESP_Name", UDim2.new(1,0,0,16), UDim2.new(0,0,0,-18), target.Name, Color3.fromRGB(255,255,255), 10, Enum.Font.GothamBold, 1, Color3.fromRGB(0,0,0), 0.3, box
    
    local line = Instance.new("Frame")
    line.Name, line.Size, line.BackgroundTransparency, line.BackgroundColor3, line.Parent, line.Visible = "ESP_Line", UDim2.new(0,1,0,1), 0.6, teamColor, root, false
    
    espObjects[target] = {Highlight = highlight, Box = box, Name = nameLabel, Line = line, Root = root}
end

local function updateEsp()
    if not teamEspActive then
        for _, data in pairs(espObjects) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Box then data.Box:Destroy() end
            if data.Line then data.Line:Destroy() end
        end
        espObjects = {}
        return
    end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = character.HumanoidRootPart.Position
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[target] then createEspForPlayer(target) end
            local data = espObjects[target]
            if data and data.Root then
                local targetPos = data.Root.Position
                local distance = (myPos - targetPos).Magnitude
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                local fade = math.clamp((distance - 15) / 30, 0.3, 1)
                if onScreen and distance < 200 then
                    local boxSize = math.clamp(80 / distance, 20, 80)
                    data.Box.Size, data.Box.Position, data.Box.BackgroundTransparency, data.Box.Visible = UDim2.new(0,boxSize,0,boxSize*1.8), UDim2.new(0,screenPos.X-boxSize/2,0,screenPos.Y-boxSize*0.9), 0.3 + (1-fade)*0.5, true
                    data.Highlight.FillTransparency, data.Highlight.OutlineTransparency = 0.4 + (1-fade)*0.4, 0.2 + (1-fade)*0.3
                    local centerX, centerY = screenPos.X, screenPos.Y + boxSize*0.5
                    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local dx, dy = centerX - screenCenter.X, centerY - screenCenter.Y
                    local angle, length = math.atan2(dy, dx), math.clamp(math.sqrt(dx^2+dy^2), 20, 300)
                    data.Line.Size, data.Line.Position, data.Line.Rotation, data.Line.BackgroundTransparency, data.Line.Visible = UDim2.new(0,length,0,1), UDim2.new(0,screenCenter.X,0,screenCenter.Y), math.deg(angle), 0.4 + (1-fade)*0.3, true
                else
                    data.Box.Visible, data.Line.Visible, data.Highlight.FillTransparency = false, false, 0.7
                end
            end
        end
    end
end

local function toggleEsp()
    teamEspActive = not teamEspActive
    if teamEspActive then
        espBtn.Text, espBtn.BackgroundColor3, espBtn.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100)
        statusLabel.Text, statusLabel.TextColor3 = "ESP ENABLED", Color3.fromRGB(0,200,255)
        if espConnection then pcall(function() espConnection:Disconnect() end) end
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player then createEspForPlayer(target) end
        end
        espConnection = RunService.RenderStepped:Connect(updateEsp)
        Players.PlayerAdded:Connect(function(target) task.wait(0.5); if teamEspActive then createEspForPlayer(target) end end)
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
        espBtn.Text, espBtn.BackgroundColor3, espBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        statusLabel.Text, statusLabel.TextColor3 = "ESP DISABLED", Color3.fromRGB(255,100,100)
        if espConnection then pcall(function() espConnection:Disconnect() end) end
        for _, data in pairs(espObjects) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Box then data.Box:Destroy() end
            if data.Line then data.Line:Destroy() end
        end
        espObjects = {}
        task.wait(0.5)
        statusLabel.Text, statusLabel.TextColor3 = "Ready", Color3.fromRGB(0,255,150)
    end
end

espBtn.MouseButton1Click:Connect(toggleEsp)
espBtn.TouchTap:Connect(toggleEsp)
]],
    [6] = [[
-- ========== LIGHTING TOGGLE ==========
local function toggleFuture()
    futureActive = not futureActive
    if futureActive then
        futureBtn.Text, futureBtn.BackgroundColor3, futureBtn.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100)
        statusLabel.Text, statusLabel.TextColor3 = "Lighting ON", Color3.fromRGB(0,200,255)
        originalLighting.Technology = Lighting.Technology
        pcall(function() Lighting.Technology = Enum.Technology.Future end)
        if Lighting.Technology ~= Enum.Technology.Future then pcall(function() Lighting.Technology = Enum.Technology.Realistic end) end
        Lighting.GlobalShadows, Lighting.ShadowSoftness = true, 0.5
    else
        futureBtn.Text, futureBtn.BackgroundColor3, futureBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        statusLabel.Text, statusLabel.TextColor3 = "Lighting OFF", Color3.fromRGB(255,100,100)
        Lighting.Technology, Lighting.GlobalShadows, Lighting.ShadowSoftness = originalLighting.Technology, originalLighting.GlobalShadows, originalLighting.ShadowSoftness
        task.wait(0.5)
        statusLabel.Text, statusLabel.TextColor3 = "Ready", Color3.fromRGB(0,255,150)
    end
end
futureBtn.MouseButton1Click:Connect(toggleFuture)
futureBtn.TouchTap:Connect(toggleFuture)

-- ========== RTX FUNCTION ==========
local function toggleRTX()
    rtxActive = not rtxActive
    if rtxActive then
        rtxBtn.Text, rtxBtn.BackgroundColor3, rtxBtn.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100)
        statusLabel.Text, statusLabel.TextColor3 = "RTX ENABLED", Color3.fromRGB(0,200,255)
        originalLighting.Brightness, originalLighting.ClockTime, originalLighting.Ambient, originalLighting.OutdoorAmbient, originalLighting.ColorShift_Top, originalLighting.ColorShift_Bottom, originalLighting.EnvironmentDiffuseScale, originalLighting.EnvironmentSpecularScale, originalLighting.GlobalShadows, originalLighting.ShadowSoftness, originalLighting.Technology = Lighting.Brightness, Lighting.ClockTime, Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.ColorShift_Top, Lighting.ColorShift_Bottom, Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale, Lighting.GlobalShadows, Lighting.ShadowSoftness, Lighting.Technology
        pcall(function() Lighting.Technology = Enum.Technology.Future end)
        if Lighting.Technology ~= Enum.Technology.Future then pcall(function() Lighting.Technology = Enum.Technology.Realistic end) end
        local isNight = Lighting.ClockTime < 6 or Lighting.ClockTime > 18
        if isNight then
            Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.ColorShift_Top, Lighting.ColorShift_Bottom, Lighting.ShadowSoftness, statusLabel.Text = 0.4, Color3.fromRGB(20,20,30), Color3.fromRGB(15,15,25), Color3.fromRGB(10,15,30), Color3.fromRGB(5,5,15), 0.8, "RTX NIGHT MODE"
        else
            Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.ColorShift_Top, Lighting.ColorShift_Bottom, Lighting.ShadowSoftness, statusLabel.Text = 2.5, Color3.fromRGB(80,85,95), Color3.fromRGB(120,130,150), Color3.fromRGB(180,200,255), Color3.fromRGB(100,80,120), 0.5, "RTX DAY MODE"
        end
        Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale, Lighting.GlobalShadows = 1.5, 1.5, true
        local bloom = Lighting:FindFirstChild("Bloom")
        if not bloom then bloom = Instance.new("BloomEffect", Lighting); bloom.Name = "Bloom" end
        bloom.Intensity, bloom.Size, bloom.Threshold = isNight and 0.15 or 0.5, isNight and 1 or 2, isNight and 0.5 or 0.3
        local cc = Lighting:FindFirstChild("ColorCorrection")
        if not cc then cc = Instance.new("ColorCorrectionEffect", Lighting); cc.Name = "ColorCorrection" end
        cc.Saturation, cc.Contrast, cc.Brightness = isNight and 0.8 or 1.1, isNight and 0.9 or 1.1, isNight and -0.1 or 0.05
        local sunRays = Lighting:FindFirstChild("SunRays")
        if not isNight then
            if not sunRays then sunRays = Instance.new("SunRaysEffect", Lighting); sunRays.Name = "SunRays" end
            sunRays.Intensity, sunRays.Spread, sunRays.Enabled = 0.15, 0.5, true
        elseif sunRays then sunRays.Enabled = false end
        local dof = Lighting:FindFirstChild("DepthOfField")
        if not dof then dof = Instance.new("DepthOfFieldEffect", Lighting); dof.Name = "DepthOfField" end
        dof.FarIntensity, dof.FarBlurSize, dof.NearIntensity, dof.NearBlurSize, dof.FocusDistance, dof.InFocusRadius = isNight and 0.1 or 0.3, isNight and 1 or 2, 0, 0, isNight and 30 or 50, isNight and 20 or 30
        statusLabel.TextColor3 = isNight and Color3.fromRGB(100,150,255) or Color3.fromRGB(0,200,255)
    else
        rtxBtn.Text, rtxBtn.BackgroundColor3, rtxBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        statusLabel.Text, statusLabel.TextColor3 = "RTX DISABLED", Color3.fromRGB(255,100,100)
        Lighting.Brightness, Lighting.ClockTime, Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.ColorShift_Top, Lighting.ColorShift_Bottom, Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale, Lighting.GlobalShadows, Lighting.ShadowSoftness, Lighting.Technology = originalLighting.Brightness, originalLighting.ClockTime, originalLighting.Ambient, originalLighting.OutdoorAmbient, originalLighting.ColorShift_Top, originalLighting.ColorShift_Bottom, originalLighting.EnvironmentDiffuseScale, originalLighting.EnvironmentSpecularScale, originalLighting.GlobalShadows, originalLighting.ShadowSoftness, originalLighting.Technology
        local bloom = Lighting:FindFirstChild("Bloom"); if bloom then bloom:Destroy() end
        local cc = Lighting:FindFirstChild("ColorCorrection"); if cc then cc:Destroy() end
        local sunRays = Lighting:FindFirstChild("SunRays"); if sunRays then sunRays:Destroy() end
        local dof = Lighting:FindFirstChild("DepthOfField"); if dof then dof:Destroy() end
        task.wait(0.5)
        statusLabel.Text, statusLabel.TextColor3 = "Ready", Color3.fromRGB(0,255,150)
    end
end
rtxBtn.MouseButton1Click:Connect(toggleRTX)
rtxBtn.TouchTap:Connect(toggleRTX)

-- ========== TOGGLES ==========
local function toggleInfect()
    deleteInfectActive = not deleteInfectActive
    if deleteInfectActive then
        infectBtn.Text, infectBtn.BackgroundColor3, infectBtn.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100)
        statusLabel.Text, statusLabel.TextColor3 = "Scanning infect...", Color3.fromRGB(0,255,100)
        if infectConnection then pcall(function() infectConnection:Disconnect() end); infectConnection = nil end
        scanAndDeleteInfect()
        infectConnection = RunService.Heartbeat:Connect(function() if deleteInfectActive then scanAndDeleteInfect() end end)
    else
        infectBtn.Text, infectBtn.BackgroundColor3, infectBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        if infectConnection then pcall(function() infectConnection:Disconnect() end); infectConnection = nil end
        local restored = restoreInfect()
        statusLabel.Text = restored > 0 and "Restored " .. restored .. " infect" or "No infect to restore"
        statusLabel.TextColor3 = Color3.fromRGB(0,255,150)
    end
end
infectBtn.MouseButton1Click:Connect(toggleInfect)
infectBtn.TouchTap:Connect(toggleInfect)

local function toggleKill()
    deleteKillActive = not deleteKillActive
    if deleteKillActive then
        killBtn.Text, killBtn.BackgroundColor3, killBtn.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100)
        statusLabel.Text, statusLabel.TextColor3 = "Scanning kill...", Color3.fromRGB(0,255,100)
        if killConnection then pcall(function() killConnection:Disconnect() end); killConnection = nil end
        scanAndDeleteKill()
        killConnection = RunService.Heartbeat:Connect(function() if deleteKillActive then scanAndDeleteKill() end end)
    else
        killBtn.Text, killBtn.BackgroundColor3, killBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        if killConnection then pcall(function() killConnection:Disconnect() end); killConnection = nil end
        local restored = restoreKill()
        statusLabel.Text = restored > 0 and "Restored " .. restored .. " kill" or "No kill to restore"
        statusLabel.TextColor3 = Color3.fromRGB(0,255,150)
    end
end
killBtn.MouseButton1Click:Connect(toggleKill)
killBtn.TouchTap:Connect(toggleKill)

local function toggleDoors()
    deleteDoorsActive = not deleteDoorsActive
    if deleteDoorsActive then
        doorsBtn.Text, doorsBtn.BackgroundColor3, doorsBtn.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100)
        statusLabel.Text, statusLabel.TextColor3 = "Scanning doors...", Color3.fromRGB(0,255,100)
        if doorsConnection then pcall(function() doorsConnection:Disconnect() end); doorsConnection = nil end
        scanAndDeleteDoors()
        doorsConnection = RunService.Heartbeat:Connect(function() if deleteDoorsActive then scanAndDeleteDoors() end end)
    else
        doorsBtn.Text, doorsBtn.BackgroundColor3, doorsBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        if doorsConnection then pcall(function() doorsConnection:Disconnect() end); doorsConnection = nil end
        local restored = restoreDoors()
        statusLabel.Text = restored > 0 and "Restored " .. restored .. " doors" or "No doors to restore"
        statusLabel.TextColor3 = Color3.fromRGB(0,255,150)
    end
end
doorsBtn.MouseButton1Click:Connect(toggleDoors)
doorsBtn.TouchTap:Connect(toggleDoors)
]],
    [7] = [[
-- ========== TAB SWITCHING ==========
local function switchToMods()
    modsPage.Visible, playerPage.Visible, graphicsPage.Visible, themePage.Visible, othersPage.Visible = true, false, false, false, false
    tabMods.TextColor3, tabPlayer.TextColor3, tabGraphics.TextColor3, tabTheme.TextColor3, tabOthers.TextColor3 = themes[currentTheme].accent, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function switchToPlayer()
    modsPage.Visible, playerPage.Visible, graphicsPage.Visible, themePage.Visible, othersPage.Visible = false, true, false, false, false
    tabPlayer.TextColor3, tabMods.TextColor3, tabGraphics.TextColor3, tabTheme.TextColor3, tabOthers.TextColor3 = themes[currentTheme].accent, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function switchToGraphics()
    modsPage.Visible, playerPage.Visible, graphicsPage.Visible, themePage.Visible, othersPage.Visible = false, false, true, false, false
    tabGraphics.TextColor3, tabMods.TextColor3, tabPlayer.TextColor3, tabTheme.TextColor3, tabOthers.TextColor3 = themes[currentTheme].accent, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function switchToTheme()
    modsPage.Visible, playerPage.Visible, graphicsPage.Visible, themePage.Visible, othersPage.Visible = false, false, false, true, false
    tabTheme.TextColor3, tabMods.TextColor3, tabPlayer.TextColor3, tabGraphics.TextColor3, tabOthers.TextColor3 = themes[currentTheme].accent, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function switchToOthers()
    modsPage.Visible, playerPage.Visible, graphicsPage.Visible, themePage.Visible, othersPage.Visible = false, false, false, false, true
    tabOthers.TextColor3, tabMods.TextColor3, tabPlayer.TextColor3, tabGraphics.TextColor3, tabTheme.TextColor3 = themes[currentTheme].accent, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
tabMods.MouseButton1Click:Connect(switchToMods)
tabMods.TouchTap:Connect(switchToMods)
tabPlayer.MouseButton1Click:Connect(switchToPlayer)
tabPlayer.TouchTap:Connect(switchToPlayer)
tabGraphics.MouseButton1Click:Connect(switchToGraphics)
tabGraphics.TouchTap:Connect(switchToGraphics)
tabTheme.MouseButton1Click:Connect(switchToTheme)
tabTheme.TouchTap:Connect(switchToTheme)
tabOthers.MouseButton1Click:Connect(switchToOthers)
tabOthers.TouchTap:Connect(switchToOthers)

modsPage.Visible, tabMods.TextColor3 = true, themes.Default.accent

-- ========== MINIMIZE FUNCTIONS ==========
local function minimizeGUI()
    if isMinimized then return end
    isMinimized = true
    frame.Visible, miniFrame.Visible, blur.Size = false, true, 0
end
local function unminimizeGUI()
    if not isMinimized then return end
    isMinimized = false
    frame.Visible, miniFrame.Visible, blur.Size = true, false, 3
end
minBtn.MouseButton1Click:Connect(minimizeGUI)
minBtn.TouchTap:Connect(minimizeGUI)
miniFrame.MouseButton1Click:Connect(unminimizeGUI)
miniFrame.TouchTap:Connect(unminimizeGUI)

closeBtn.MouseButton1Click:Connect(function()
    if isOpen then
        isOpen, frame.Visible, miniFrame.Visible, closeBtn.Text, closeBtn.TextColor3, blur.Size = false, false, false, "▶", Color3.fromRGB(100,255,100), 0
    else
        isOpen, frame.Visible, closeBtn.Text, closeBtn.TextColor3 = true, true, "✕", themes[currentTheme].accent
        if not isMinimized then blur.Size = 3 end
    end
end)
closeBtn.TouchTap:Connect(function()
    if isOpen then
        isOpen, frame.Visible, miniFrame.Visible, closeBtn.Text, closeBtn.TextColor3, blur.Size = false, false, false, "▶", Color3.fromRGB(100,255,100), 0
    else
        isOpen, frame.Visible, closeBtn.Text, closeBtn.TextColor3 = true, true, "✕", themes[currentTheme].accent
        if not isMinimized then blur.Size = 3 end
    end
end)

-- ========== HOTKEY ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if isOpen then
            isOpen, frame.Visible, miniFrame.Visible, closeBtn.Text, closeBtn.TextColor3, blur.Size = false, false, false, "▶", Color3.fromRGB(100,255,100), 0
        else
            isOpen, frame.Visible, closeBtn.Text, closeBtn.TextColor3 = true, true, "✕", themes[currentTheme].accent
            if not isMinimized then blur.Size = 3 end
        end
    end
end)

-- ========== FORCE VISIBILITY ==========
task.wait(0.3)
frame.Visible, frame.BackgroundTransparency, frame.Size, frame.Position = true, 0.08, UDim2.new(0,360,0,340), UDim2.new(0.5,-180,0.5,-170)
blur.Size, miniFrame.Visible, closeBtn.Text, shitflockBtn.Visible, flyUpBtn.Visible, flyDownBtn.Visible = 3, false, "✕", false, false, false

print("NZ-IS v6 - Fully loaded!")
]]
}

-- Execute all chunks
local fullScript = ""
for i = 1, #scriptChunks do
    fullScript = fullScript .. scriptChunks[i]
end

-- Load and execute
local func, err = loadstring(fullScript)
if func then
    func()
else
    warn("Failed to load script: " .. tostring(err))
    -- Fallback: try executing chunks individually
    for i, chunk in pairs(scriptChunks) do
        local f, e = loadstring(chunk)
        if f then
            pcall(f)
        else
            warn("Chunk " .. i .. " failed: " .. tostring(e))
        end
    end
end
