local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
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

local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
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
local infectConnection = nil
local killConnection = nil
local deletedInfect = {}
local deletedKill = {}

-- ========== MAIN GUI FRAME ==========
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 200)
frame.Position = UDim2.new(0.5, -140, 0.5, -100)
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

-- ========== CLOSE BUTTON (MINIMIZE TO BUTTON) ==========
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

-- ========== PAGES ==========
local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -82)
    pg.Position = UDim2.new(0, 5, 0, 78)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 180)
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local modsPage = createPage()
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
    btn.Position = UDim2.new(0, 150, 0, y)
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

local yOff = 4

makeLabel("Delete Infected", yOff, modsPage, 110)
local infectBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable Kill", yOff, modsPage, 110)
local killBtn = makeToggle(yOff, modsPage)
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
            if child:IsA("TextButton") and child ~= closeBtn and child ~= infectBtn and child ~= killBtn then
                if child.Text == "Mods" or child.Text == "Theme" then
                    child.TextColor3 = t.accent
                end
            end
            if child:IsA("ScrollingFrame") then
                child.ScrollBarImageColor3 = t.accent
            end
        end
        closeBtn.BackgroundColor3 = t.button
        if deleteInfectActive then
            infectBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
            infectBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            infectBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            infectBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if deleteKillActive then
            killBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
            killBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            killBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            killBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
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

-- ========== TOGGLES ==========
local function toggleInfect()
    deleteInfectActive = not deleteInfectActive
    if deleteInfectActive then
        infectBtn.Text = "ON"
        infectBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        infectBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Scanning..."
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
        statusLabel.Text = "Scanning..."
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

-- ========== TAB SWITCHING ==========
local function switchToMods()
    modsPage.Visible = true
    themePage.Visible = false
    tabMods.TextColor3 = themes[currentTheme].accent
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
end

local function switchToTheme()
    modsPage.Visible = false
    themePage.Visible = true
    tabTheme.TextColor3 = themes[currentTheme].accent
    tabMods.TextColor3 = Color3.fromRGB(180, 180, 210)
end

tabMods.MouseButton1Click:Connect(switchToMods)
tabMods.TouchTap:Connect(switchToMods)
tabTheme.MouseButton1Click:Connect(switchToTheme)
tabTheme.TouchTap:Connect(switchToTheme)

modsPage.Visible = true
tabMods.TextColor3 = themes.Default.accent

-- ========== OPEN/CLOSE BUTTON (like Delta executor) ==========
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 1, -65)
toggleBtn.Text = "▶"
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

toggleBtn.MouseButton1Click:Connect(function()
    if isOpen then closeGUI() else openGUI() end
end)

toggleBtn.TouchTap:Connect(function()
    if isOpen then closeGUI() else openGUI() end
end)

-- Close button minimizes to toggle button
closeBtn.MouseButton1Click:Connect(closeGUI)
closeBtn.TouchTap:Connect(closeGUI)

-- ========== DRAG SYSTEM (HOLD TO DRAG) ==========
local dragData = {
    dragging = false,
    startPos = nil,
    frameStart = nil,
    holdTimer = nil,
    isHolding = false
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

-- MOBILE: Touch and hold to drag
local function onTouchBegan(input)
    if isOverButton(input) then return end
    -- Start dragging immediately on touch (no hold required)
    startDrag(input)
end

local function onTouchMoved(input)
    if dragData.dragging then
        updateDrag(input)
    end
end

local function onTouchEnded()
    endDrag()
end

-- PC: Mouse drag
local function onMouseDown(input)
    if isOverButton(input) then return end
    startDrag(input)
end

local function onMouseMove(input)
    if dragData.dragging then
        updateDrag(input)
    end
end

local function onMouseUp()
    endDrag()
end

-- Connect events for the ENTIRE FRAME (not just title bar)
frame.TouchBegan:Connect(onTouchBegan)
frame.TouchMoved:Connect(onTouchMoved)
frame.TouchEnded:Connect(onTouchEnded)

frame.MouseButton1Down:Connect(onMouseDown)
frame.MouseMoved:Connect(onMouseMove)
frame.MouseButton1Up:Connect(onMouseUp)

-- Also allow drag from title bar
titleBar.TouchBegan:Connect(onTouchBegan)
titleBar.TouchMoved:Connect(onTouchMoved)
titleBar.TouchEnded:Connect(onTouchEnded)

titleBar.MouseButton1Down:Connect(onMouseDown)
titleBar.MouseMoved:Connect(onMouseMove)
titleBar.MouseButton1Up:Connect(onMouseUp)

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
frame.Size = UDim2.new(0, 280, 0, 200)
frame.Position = UDim2.new(0.5, -140, 0.5, -100)
blur.Size = 3
toggleBtn.Text = "◀"

print("NZ-IS Mobile Fixed - Touch anywhere to drag, tap toggle button to open/close")
