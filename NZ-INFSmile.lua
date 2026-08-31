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
blur.Size = 4

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
local deleteInfectActive = false
local deleteKillActive = false
local infectConnection = nil
local killConnection = nil
local deletedInfect = {}
local deletedKill = {}

-- SMALLER FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 260)
frame.Position = UDim2.new(0.5, -170, 0.5, -130)
frame.BackgroundColor3 = themes.Default.background
frame.BackgroundTransparency = 0.08
frame.ClipsDescendants = true
frame.Parent = root
frame.Visible = true
frame.ZIndex = 10

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = themes.Default.stroke
stroke.Thickness = 1.5
stroke.Transparency = 0.6

local grad = Instance.new("UIGradient", frame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})

-- SMALLER TITLE BAR
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "NZ-IS"
titleLabel.TextColor3 = themes.Default.accent
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

-- SMALLER BUTTONS
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -70, 0, 2)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
minimizeBtn.BackgroundTransparency = 0.2
minimizeBtn.Parent = titleBar
local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 6)

minimizeBtn.MouseEnter:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 50, 80)
end)
minimizeBtn.MouseLeave:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0, 2)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
end)
closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
end)

closeBtn.MouseButton1Click:Connect(function()
    local confirm = Instance.new("TextButton")
    confirm.Size = UDim2.new(0, 120, 0, 30)
    confirm.Position = UDim2.new(0.5, -60, 0.5, -15)
    confirm.Text = "Close?"
    confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirm.TextSize = 13
    confirm.Font = Enum.Font.GothamBold
    confirm.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    confirm.Parent = frame
    local cCorner = Instance.new("UICorner", confirm)
    cCorner.CornerRadius = UDim.new(0, 6)
    confirm.ZIndex = 999

    local function destroyAll()
        confirm:Destroy()
        if infectConnection then
            pcall(function() infectConnection:Disconnect() end)
            infectConnection = nil
        end
        if killConnection then
            pcall(function() killConnection:Disconnect() end)
            killConnection = nil
        end
        root:Destroy()
        blur:Destroy()
    end

    confirm.MouseButton1Click:Connect(destroyAll)
    confirm.TouchTap:Connect(destroyAll)
    task.wait(2.5)
    confirm:Destroy()
end)

-- SMALLER TABS
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -14, 0, 28)
tabContainer.Position = UDim2.new(0, 7, 0, 40)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local function createTab(name, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BackgroundTransparency = 0.3
    btn.Parent = tabContainer
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end

local tabMods = createTab("Mods", 0)
local tabTheme = createTab("Theme", 150)

-- SMALLER PAGES
local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -14, 1, -80)
    pg.Position = UDim2.new(0, 7, 0, 72)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 200)
    pg.ScrollBarThickness = 4
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local modsPage = createPage()
local themePage = createPage()

local function makeLabel(text, y, parent, w)
    w = w or 120
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, w, 0, 26)
    l.Position = UDim2.new(0, 0, 0, y)
    l.Text = text
    l.TextColor3 = themes.Default.text
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function makeToggle(y, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 26)
    btn.Position = UDim2.new(0, 170, 0, y)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    btn.Parent = parent
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 4)
    return btn
end

local yOff = 6

makeLabel("Delete Infected", yOff, modsPage, 130)
local infectBtn = makeToggle(yOff, modsPage)
yOff = yOff + 34

makeLabel("Disable Kill Parts", yOff, modsPage, 130)
local killBtn = makeToggle(yOff, modsPage)
yOff = yOff + 40

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -14, 0, 26)
statusLabel.Position = UDim2.new(0, 0, 0, yOff)
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = modsPage
yOff = yOff + 32

modsPage.CanvasSize = UDim2.new(0, 0, 0, yOff + 10)

-- SMALLER THEME PAGE
local themeY = 6
local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(1, -14, 0, 26)
themeLabel.Position = UDim2.new(0, 0, 0, themeY)
themeLabel.Text = "THEMES"
themeLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
themeLabel.TextSize = 13
themeLabel.Font = Enum.Font.GothamBold
themeLabel.BackgroundTransparency = 1
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.Parent = themePage
themeY = themeY + 34

local function createThemeButton(name, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    btn.Parent = themePage
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)

    local function applyTheme()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        statusLabel.TextColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minimizeBtn and child ~= infectBtn and child ~= killBtn then
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
    themeY = themeY + 38
end

-- FUNCTIONS (same logic, just compact)
local function restoreInfect()
    for _, item in pairs(deletedInfect) do
        if item and item.Parent then
            item.Parent = workspace
        end
    end
    deletedInfect = {}
end

local function restoreKill()
    for _, item in pairs(deletedKill) do
        if item and item.Parent then
            item.Parent = workspace
        end
    end
    deletedKill = {}
end

local function scanAndDeleteInfect()
    if not deleteInfectActive then
        restoreInfect()
        return
    end
    local found = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name and v.Name:lower():find("infect") then
                table.insert(found, v)
            end
        end
    end
    for _, v in pairs(found) do
        if v.Parent then
            table.insert(deletedInfect, v)
            v.Parent = nil
        end
    end
    if #found > 0 then
        statusLabel.Text = "Deleted " .. #found .. " infected"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
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
            if v.Name and v.Name:lower():find("kill") then
                table.insert(found, v)
            end
        end
    end
    for _, v in pairs(found) do
        if v.Parent then
            table.insert(deletedKill, v)
            v.Parent = nil
        end
    end
    if #found > 0 then
        statusLabel.Text = "Deleted " .. #found .. " kill"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    end
end

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
        restoreInfect()
        statusLabel.Text = "Restored"
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
        restoreKill()
        statusLabel.Text = "Restored"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

killBtn.MouseButton1Click:Connect(toggleKill)
killBtn.TouchTap:Connect(toggleKill)

-- TAB SWITCHING
local function switchToMods()
    modsPage.Visible = true
    themePage.Visible = false
    tabMods.TextColor3 = themes[currentTheme].accent
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
    TweenService:Create(tabMods, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end

local function switchToTheme()
    modsPage.Visible = false
    themePage.Visible = true
    tabTheme.TextColor3 = themes[currentTheme].accent
    tabMods.TextColor3 = Color3.fromRGB(180, 180, 210)
    TweenService:Create(tabTheme, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end

tabMods.MouseButton1Click:Connect(switchToMods)
tabMods.TouchTap:Connect(switchToMods)
tabTheme.MouseButton1Click:Connect(switchToTheme)
tabTheme.TouchTap:Connect(switchToTheme)

modsPage.Visible = true
tabMods.TextColor3 = themes.Default.accent
tabMods.BackgroundTransparency = 0

-- MINIMIZE / MAXIMIZE
local function minimizeGUI()
    isMinimized = true
    frame.Size = UDim2.new(0, 140, 0, 36)
    frame.Position = UDim2.new(0.5, -70, 0.5, -18)
    tabContainer.Visible = false
    modsPage.Visible = false
    themePage.Visible = false
    closeBtn.Visible = true
    minimizeBtn.Text = "+"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 50, 80)
    titleLabel.Text = "NZ-IS"
    titleLabel.TextSize = 14
    blur.Size = 0
end

local function maximizeGUI()
    isMinimized = false
    frame.Size = UDim2.new(0, 340, 0, 260)
    frame.Position = UDim2.new(0.5, -170, 0.5, -130)
    tabContainer.Visible = true
    modsPage.Visible = true
    themePage.Visible = false
    closeBtn.Visible = true
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    titleLabel.Text = "NZ-IS"
    titleLabel.TextSize = 15
    blur.Size = 4
    tabMods.TextColor3 = themes[currentTheme].accent
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
end

minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then maximizeGUI() else minimizeGUI() end
end)
minimizeBtn.TouchTap:Connect(function()
    if isMinimized then maximizeGUI() else minimizeGUI() end
end)

-- FLOATING OPEN BUTTON (smaller)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 10, 1, -65)
openBtn.Text = "⚙"
openBtn.TextSize = 24
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
openBtn.Parent = root
local openCorner = Instance.new("UICorner", openBtn)
openCorner.CornerRadius = UDim.new(1, 0)
local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Color = Color3.fromRGB(255, 255, 255)
openStroke.Thickness = 1.5
openStroke.Transparency = 0.3
openBtn.ZIndex = 999
openBtn.Visible = false

openBtn.MouseButton1Click:Connect(function()
    if isMinimized then maximizeGUI() else minimizeGUI() end
    openBtn.Visible = false
    task.wait(0.5)
    openBtn.Visible = true
end)
openBtn.TouchTap:Connect(function()
    if isMinimized then maximizeGUI() else minimizeGUI() end
    openBtn.Visible = false
    task.wait(0.5)
    openBtn.Visible = true
end)

local origMinimize = minimizeGUI
minimizeGUI = function()
    origMinimize()
    openBtn.Visible = true
end

local origMaximize = maximizeGUI
maximizeGUI = function()
    origMaximize()
    openBtn.Visible = false
end

-- DRAG SYSTEM (compact)
local dragging = false
local dragStart = nil
local startPos = nil

local function startDrag(input)
    dragging = true
    dragStart = input.Position
    startPos = frame.Position
end

local function updateDrag(input)
    if dragging and dragStart then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end

local function endDrag()
    dragging = false
    dragStart = nil
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        startDrag(input)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        endDrag()
    end
end)

titleBar.TouchBegan:Connect(startDrag)
titleBar.TouchMoved:Connect(updateDrag)
titleBar.TouchEnded:Connect(endDrag)

frame.TouchBegan:Connect(function(input)
    local hit = game:GetService("GuiService"):GetGuiObjectAtPosition(input.Position.X, input.Position.Y)
    if hit and (hit:IsA("TextButton") or hit:IsA("ImageButton")) then
        return
    end
    startDrag(input)
end)
frame.TouchMoved:Connect(function(input)
    if dragging then updateDrag(input) end
end)
frame.TouchEnded:Connect(endDrag)

-- HOTKEY
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if isMinimized then maximizeGUI() else minimizeGUI() end
    end
end)

-- FORCE VISIBILITY
task.wait(0.3)
frame.Visible = true
frame.BackgroundTransparency = 0.08
frame.Size = UDim2.new(0, 340, 0, 260)
frame.Position = UDim2.new(0.5, -170, 0.5, -130)
blur.Size = 4

print("NZ-IS Compact loaded on mobile!")
