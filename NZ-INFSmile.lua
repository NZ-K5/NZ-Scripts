local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

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
local deleteInfectActive = false
local deleteKillActive = false
local deleteDoorsActive = false
local rtxActive = false

local infectConnection = nil
local killConnection = nil
local doorsConnection = nil

local deletedInfect = {}
local deletedKill = {}
local deletedDoors = {}

-- Store original lighting settings for RTX restore
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
frame.Size = UDim2.new(0, 300, 0, 240)
frame.Position = UDim2.new(0.5, -150, 0.5, -120)
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

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "NZ-IS"
titleLabel.TextColor3 = themes.Default.accent
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

-- ========== CLOSE BUTTON ==========
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0, 7)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

-- ========== TABS ==========
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 26)
tabContainer.Position = UDim2.new(0, 5, 0, 48)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local function createTab(name, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 1, 0)
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
local tabGraphics = createTab("Graphics", 95)
local tabTheme = createTab("Theme", 190)

-- ========== PAGES ==========
local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -82)
    pg.Position = UDim2.new(0, 5, 0, 78)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 260)
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
    btn.Position = UDim2.new(0, 170, 0, y)
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

local rtxDesc = Instance.new("TextLabel")
rtxDesc.Size = UDim2.new(1, -10, 0, 30)
rtxDesc.Position = UDim2.new(0, 0, 0, gY)
rtxDesc.Text = "Enables realistic lighting,\nshadows, bloom & more"
rtxDesc.TextColor3 = Color3.fromRGB(150, 150, 170)
rtxDesc.TextSize = 10
rtxDesc.Font = Enum.Font.Gotham
rtxDesc.BackgroundTransparency = 1
rtxDesc.TextXAlignment = Enum.TextXAlignment.Left
rtxDesc.Parent = graphicsPage
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
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 5)

    local function applyTheme()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        statusLabel.TextColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= infectBtn and child ~= killBtn and child ~= doorsBtn and child ~= rtxBtn then
                if child.Text == "Mods" or child.Text == "Graphics" or child.Text == "Theme" then
                    child.TextColor3 = t.accent
                end
            end
            if child:IsA("ScrollingFrame") then
                child.ScrollBarImageColor3 = t.accent
            end
        end
        closeBtn.BackgroundColor3 = t.button
        
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
        updateToggle(rtxBtn, rtxActive)
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

-- RESTORE FUNCTIONS
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

-- SCAN & DELETE FUNCTIONS
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
        
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(80, 85, 95)
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 130, 150)
        Lighting.ColorShift_Top = Color3.fromRGB(180, 200, 255)
        Lighting.ColorShift_Bottom = Color3.fromRGB(100, 80, 120)
        Lighting.EnvironmentDiffuseScale = 1.5
        Lighting.EnvironmentSpecularScale = 1.5
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.5
        Lighting.Technology = Enum.Technology.Future
        
        local bloom = Lighting:FindFirstChild("Bloom")
        if not bloom then
            bloom = Instance.new("BloomEffect")
            bloom.Name = "Bloom"
            bloom.Intensity = 0.5
            bloom.Size = 2
            bloom.Threshold = 0.3
            bloom.Parent = Lighting
        else
            bloom.Intensity = 0.5
            bloom.Size = 2
            bloom.Threshold = 0.3
        end
        
        local cc = Lighting:FindFirstChild("ColorCorrection")
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "ColorCorrection"
            cc.Saturation = 1.1
            cc.Contrast = 1.1
            cc.Brightness = 0.05
            cc.Parent = Lighting
        else
            cc.Saturation = 1.1
            cc.Contrast = 1.1
            cc.Brightness = 0.05
        end
        
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
        end
        
        local dof = Lighting:FindFirstChild("DepthOfField")
        if not dof then
            dof = Instance.new("DepthOfFieldEffect")
            dof.Name = "DepthOfField"
            dof.FarIntensity = 0.3
            dof.FarBlurSize = 2
            dof.NearIntensity = 0
            dof.NearBlurSize = 0
            dof.FocusDistance = 50
            dof.InFocusRadius = 30
            dof.Parent = Lighting
        else
            dof.FarIntensity = 0.3
            dof.FarBlurSize = 2
            dof.NearIntensity = 0
            dof.NearBlurSize = 0
            dof.FocusDistance = 50
            dof.InFocusRadius = 30
        end
        
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

-- ========== DRAGGABLE OPEN/CLOSE BUTTON ==========
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 1, -65)
toggleBtn.Text = "◀"
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
toggleBtn.Parent = root
local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(1, 0)
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Thickness = 2
toggleStroke.Transparency = 0.2
toggleBtn.ZIndex = 999
toggleBtn.Active = true
toggleBtn.Draggable = true

-- Button drag data
local btnDragData = {
    dragging = false,
    startPos = nil,
    btnStart = nil
}

local function startBtnDrag(input)
    btnDragData.dragging = true
    btnDragData.startPos = input.Position    btnDragData.btnStart = toggleBtn.Position
end

local function updateBtnDrag(input)
    if not btnDragData.dragging or not btnDragData.startPos then return end
    local delta = input.Position - btnDragData.startPos
    toggleBtn.Position = UDim2.new(
        btnDragData.btnStart.X.Scale,
        btnDragData.btnStart.X.Offset + delta.X,
        btnDragData.btnStart.Y.Scale,
        btnDragData.btnStart.Y.Offset + delta.Y
    )
end

local function endBtnDrag()
    btnDragData.dragging = false
    btnDragData.startPos = nil
    btnDragData.btnStart = nil
end

-- Mobile touch drag for button
toggleBtn.TouchBegan:Connect(function(input)
    startBtnDrag(input)
end)
toggleBtn.TouchMoved:Connect(function(input)
    updateBtnDrag(input)
end)
toggleBtn.TouchEnded:Connect(function()
    endBtnDrag()
end)

-- PC mouse drag for button
toggleBtn.MouseButton1Down:Connect(function(input)
    startBtnDrag(input)
end)
toggleBtn.MouseMoved:Connect(function(input)
    updateBtnDrag(input)
end)
toggleBtn.MouseButton1Up:Connect(function()
    endBtnDrag()
end)

-- Button click (open/close) - separate from drag
local btnClickStart = nil
local btnClickEnd = nil

toggleBtn.TouchBegan:Connect(function(input)
    btnClickStart = tick()
end)

toggleBtn.TouchEnded:Connect(function()
    btnClickEnd = tick()
    if btnClickStart and btnClickEnd - btnClickStart < 0.3 then
        -- It was a tap, not a drag
        if isOpen then closeGUI() else openGUI() end
    end
    btnClickStart = nil
    btnClickEnd = nil
end)

toggleBtn.MouseButton1Click:Connect(function()
    if isOpen then closeGUI() else openGUI() end
end)

-- ========== OPEN/CLOSE FUNCTIONS ==========
local function openGUI()
    isOpen = true
    frame.Visible = true
    toggleBtn.Text = "◀"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    blur.Size = 3
end

local function closeGUI()
    isOpen = false
    frame.Visible = false
    toggleBtn.Text = "▶"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    blur.Size = 0
end

closeBtn.MouseButton1Click:Connect(closeGUI)
closeBtn.TouchTap:Connect(closeGUI)

-- ========== FRAME DRAG SYSTEM ==========
local dragData = {
    dragging = false,
    startPos = nil,
    frameStart = nil
}

local function isOverButton(input)
    local guiService = game:GetService("GuiService")
    local pos = input.Position
    local hit = guiService:GetGuiObjectAtPosition(pos.X, pos.Y)
    if hit then
        local parent = hit
        while parent do
            if parent:IsA("TextButton") or parent:IsA("ImageButton") then
                return true
            end
            parent = parent.Parent
        end
    end
    return false
end

local function startDrag(input)
    if isOverButton(input) then return end
    dragData.dragging = true
    dragData.startPos = input.Position
    dragData.frameStart = frame.Position
end

local function updateDrag(input)
    if not dragData.dragging or not dragData.startPos then return end
    local delta = input.Position - dragData.startPos
    frame.Position = UDim2.new(
        dragData.frameStart.X.Scale,
        dragData.frameStart.X.Offset + delta.X,
        dragData.frameStart.Y.Scale,
        dragData.frameStart.Y.Offset + delta.Y
    )
end

local function endDrag()
    dragData.dragging = false
    dragData.startPos = nil
    dragData.frameStart = nil
end

frame.TouchBegan:Connect(startDrag)
frame.TouchMoved:Connect(updateDrag)
frame.TouchEnded:Connect(endDrag)

frame.MouseButton1Down:Connect(startDrag)
frame.MouseMoved:Connect(updateDrag)
frame.MouseButton1Up:Connect(endDrag)

titleBar.TouchBegan:Connect(startDrag)
titleBar.TouchMoved:Connect(updateDrag)
titleBar.TouchEnded:Connect(endDrag)

titleBar.MouseButton1Down:Connect(startDrag)
titleBar.MouseMoved:Connect(updateDrag)
titleBar.MouseButton1Up:Connect(endDrag)

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
frame.Size = UDim2.new(0, 300, 0, 240)
frame.Position = UDim2.new(0.5, -150, 0.5, -120)
blur.Size = 3
toggleBtn.Text = "◀"

print("NZ-IS v2 - Toggle button is now draggable!")
