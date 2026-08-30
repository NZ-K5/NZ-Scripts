local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

pcall(function()
    if guiParent:FindFirstChild("BackdoorRoot") then
        guiParent.BackdoorRoot:Destroy()
    end
end)

local root = Instance.new("ScreenGui")
root.Name = "BackdoorRoot"
root.Parent = guiParent
root.ResetOnSpawn = false
root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 8

local themes = {
    Default = {
        background = Color3.fromRGB(8, 8, 12),
        accent = Color3.fromRGB(0, 255, 200),
        accent2 = Color3.fromRGB(0, 180, 255),
        text = Color3.fromRGB(220, 220, 240),
        button = Color3.fromRGB(20, 20, 30),
        stroke = Color3.fromRGB(0, 255, 200),
        danger = Color3.fromRGB(255, 50, 80),
        glow = Color3.fromRGB(0, 200, 255)
    },
    Crimson = {
        background = Color3.fromRGB(12, 6, 8),
        accent = Color3.fromRGB(255, 40, 60),
        accent2 = Color3.fromRGB(200, 20, 50),
        text = Color3.fromRGB(240, 200, 210),
        button = Color3.fromRGB(30, 12, 16),
        stroke = Color3.fromRGB(255, 40, 60),
        danger = Color3.fromRGB(255, 20, 30),
        glow = Color3.fromRGB(255, 30, 80)
    },
    Cyber = {
        background = Color3.fromRGB(4, 6, 16),
        accent = Color3.fromRGB(0, 220, 255),
        accent2 = Color3.fromRGB(120, 0, 255),
        text = Color3.fromRGB(180, 230, 255),
        button = Color3.fromRGB(10, 15, 35),
        stroke = Color3.fromRGB(0, 200, 255),
        danger = Color3.fromRGB(255, 40, 100),
        glow = Color3.fromRGB(0, 180, 255)
    },
    Amber = {
        background = Color3.fromRGB(14, 10, 6),
        accent = Color3.fromRGB(255, 180, 0),
        accent2 = Color3.fromRGB(255, 220, 50),
        text = Color3.fromRGB(240, 220, 180),
        button = Color3.fromRGB(30, 22, 12),
        stroke = Color3.fromRGB(255, 180, 0),
        danger = Color3.fromRGB(255, 100, 0),
        glow = Color3.fromRGB(255, 200, 50)
    },
    Violet = {
        background = Color3.fromRGB(10, 6, 18),
        accent = Color3.fromRGB(200, 80, 255),
        accent2 = Color3.fromRGB(150, 40, 220),
        text = Color3.fromRGB(220, 200, 250),
        button = Color3.fromRGB(22, 12, 30),
        stroke = Color3.fromRGB(180, 80, 255),
        danger = Color3.fromRGB(220, 40, 180),
        glow = Color3.fromRGB(200, 80, 255)
    }
}

local currentTheme = "Default"
local isMinimized = false
local scanActive = false
local scanConnection = nil

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 600, 0, 480)
frame.Position = UDim2.new(0.5, -300, 0.5, -240)
frame.BackgroundColor3 = themes.Default.background
frame.BackgroundTransparency = 0.05
frame.ClipsDescendants = true
frame.Parent = root
frame.Visible = true
frame.ZIndex = 10

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = themes.Default.stroke
stroke.Thickness = 1.5
stroke.Transparency = 0.3

local glowStroke = Instance.new("UIStroke", frame)
glowStroke.Color = themes.Default.glow
glowStroke.Thickness = 8
glowStroke.Transparency = 0.85

local grad = Instance.new("UIGradient", frame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 12))
})

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 30, 1, 0)
titleIcon.Position = UDim2.new(0, 12, 0, 0)
titleIcon.Text = ""
titleIcon.TextColor3 = themes.Default.accent
titleIcon.TextSize = 20
titleIcon.Font = Enum.Font.GothamBold
titleIcon.TextXAlignment = Enum.TextXAlignment.Center
titleIcon.BackgroundTransparency = 1
titleIcon.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 48, 0, 0)
titleLabel.Text = "NZ Backdoor Scan"
titleLabel.TextColor3 = themes.Default.accent
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0.4, 0, 1, 0)
subtitleLabel.Position = UDim2.new(0.6, 0, 0, 0)
subtitleLabel.Text = "v3.0"
subtitleLabel.TextColor3 = Color3.fromRGB(100, 100, 140)
subtitleLabel.TextSize = 12
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Right
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 34, 0, 34)
minimizeBtn.Position = UDim2.new(1, -80, 0, 5)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
minimizeBtn.TextSize = 22
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
minimizeBtn.BackgroundTransparency = 0.2
minimizeBtn.Parent = titleBar
local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 8)

minimizeBtn.MouseEnter:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end)
minimizeBtn.MouseLeave:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 8)

closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 15, 20)
    closeBtn.TextColor3 = Color3.fromRGB(255, 60, 80)
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
end)

closeBtn.MouseButton1Click:Connect(function()
    local confirm = Instance.new("Frame")
    confirm.Size = UDim2.new(0, 200, 0, 80)
    confirm.Position = UDim2.new(0.5, -100, 0.5, -40)
    confirm.BackgroundColor3 = Color3.fromRGB(20, 10, 15)
    confirm.BackgroundTransparency = 0.1
    confirm.Parent = frame
    local confirmCorner = Instance.new("UICorner", confirm)
    confirmCorner.CornerRadius = UDim.new(0, 12)
    local confirmStroke = Instance.new("UIStroke", confirm)
    confirmStroke.Color = Color3.fromRGB(255, 50, 80)
    confirmStroke.Thickness = 1.5
    confirmStroke.Transparency = 0.5
    confirm.ZIndex = 999

    local confirmText = Instance.new("TextLabel")
    confirmText.Size = UDim2.new(1, 0, 0, 30)
    confirmText.Position = UDim2.new(0, 0, 0, 10)
    confirmText.Text = "Close Backdoor Scan?"
    confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmText.TextSize = 14
    confirmText.Font = Enum.Font.GothamBold
    confirmText.BackgroundTransparency = 1
    confirmText.Parent = confirm

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0, 80, 0, 30)
    confirmBtn.Position = UDim2.new(0.5, -85, 0, 45)
    confirmBtn.Text = "Confirm"
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.TextSize = 14
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
    confirmBtn.Parent = confirm
    local confirmBtnCorner = Instance.new("UICorner", confirmBtn)
    confirmBtnCorner.CornerRadius = UDim.new(0, 6)

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 80, 0, 30)
    cancelBtn.Position = UDim2.new(0.5, 5, 0, 45)
    cancelBtn.Text = "Cancel"
    cancelBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    cancelBtn.TextSize = 14
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    cancelBtn.Parent = confirm
    local cancelBtnCorner = Instance.new("UICorner", cancelBtn)
    cancelBtnCorner.CornerRadius = UDim.new(0, 6)

    local function destroyAll()
        confirm:Destroy()
        if scanConnection then
            pcall(function() scanConnection:Disconnect() end)
            scanConnection = nil
        end
        root:Destroy()
        blur:Destroy()
    end

    confirmBtn.MouseButton1Click:Connect(destroyAll)
    cancelBtn.MouseButton1Click:Connect(function()
        confirm:Destroy()
    end)
end)

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -30, 0, 40)
tabContainer.Position = UDim2.new(0, 15, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local function createTab(name, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 170, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 210)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    btn.BackgroundTransparency = 0.3
    btn.Parent = tabContainer
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 8)
    return btn
end

local tabScan = createTab("Scanner", 0)
local tabResults = createTab("Results", 180)
local tabTheme = createTab("Theme", 360)

local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -30, 1, -110)
    pg.Position = UDim2.new(0, 15, 0, 95)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 400)
    pg.ScrollBarThickness = 4
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.ScrollBarImageTransparency = 0.5
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local scanPage = createPage()
local resultsPage = createPage()
local themePage = createPage()

local function makeScanLabel(text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 30)
    l.Position = UDim2.new(0, 0, 0, y)
    l.Text = text
    l.TextColor3 = Color3.fromRGB(200, 200, 230)
    l.TextSize = 14
    l.Font = Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = scanPage
    return l
end

local function makeStatusLabel(y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 40)
    l.Position = UDim2.new(0, 0, 0, y)
    l.Text = "System Ready"
    l.TextColor3 = Color3.fromRGB(0, 255, 200)
    l.TextSize = 16
    l.Font = Enum.Font.GothamBold
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = scanPage
    return l
end

local scanStatus = makeStatusLabel(10)

local function makeButton(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 200, 0, 40)
    b.Position = UDim2.new(0, 0, 0, y)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    b.Parent = scanPage
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 8)
    return b
end

local scanBtn = makeButton("Start Scan", 60, Color3.fromRGB(20, 60, 40))
local stopBtn = makeButton("Stop Scan", 110, Color3.fromRGB(60, 20, 25))

local function makeResultItem(text, y, parent, color)
    local b = Instance.new("Frame")
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    b.BackgroundTransparency = 0.3
    b.Parent = parent
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(200, 200, 230)
    l.TextSize = 13
    l.Font = Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b
    return b
end

local resultsList = Instance.new("Frame")
resultsList.Size = UDim2.new(1, 0, 0, 340)
resultsList.Position = UDim2.new(0, 0, 0, 10)
resultsList.BackgroundTransparency = 1
resultsList.Parent = resultsPage

local resultItems = {}
local backdoorsFound = {}

local function addResult(text, color)
    color = color or Color3.fromRGB(200, 200, 230)
    local y = #resultItems * 40
    local item = makeResultItem(text, y, resultsList, color)
    table.insert(resultItems, item)
    resultsList.Size = UDim2.new(1, 0, 0, math.max(340, #resultItems * 40 + 20))
    resultsPage.CanvasSize = UDim2.new(0, 0, 0, math.max(400, #resultItems * 40 + 30))
end

local function clearResults()
    for _, item in pairs(resultItems) do
        item:Destroy()
    end
    resultItems = {}
    backdoorsFound = {}
    resultsList.Size = UDim2.new(1, 0, 0, 340)
    resultsPage.CanvasSize = UDim2.new(0, 0, 0, 400)
end

addResult("System initialized", Color3.fromRGB(0, 255, 200))
addResult("Waiting for scan...", Color3.fromRGB(200, 200, 230))

local themeY = 10
local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(1, -20, 0, 30)
themeLabel.Position = UDim2.new(0, 0, 0, themeY)
themeLabel.Text = "SELECT INTERFACE THEME"
themeLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
themeLabel.TextSize = 14
themeLabel.Font = Enum.Font.GothamBold
themeLabel.BackgroundTransparency = 1
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.Parent = themePage
themeY = themeY + 45

local function createThemeButton(name, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    btn.Parent = themePage
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 8)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        glowStroke.Color = t.glow
        titleLabel.TextColor3 = t.accent
        scanStatus.TextColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minimizeBtn and child ~= scanBtn and child ~= stopBtn then
                if child.Text == "Scanner" or child.Text == "Results" or child.Text == "Theme" then
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
        scanBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 40)
        stopBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
    end)
    return btn
end

local themeColors = {
    {name = "Default", color = Color3.fromRGB(20, 20, 35)},
    {name = "Crimson", color = Color3.fromRGB(35, 15, 20)},
    {name = "Cyber", color = Color3.fromRGB(10, 15, 40)},
    {name = "Amber", color = Color3.fromRGB(35, 25, 15)},
    {name = "Violet", color = Color3.fromRGB(25, 15, 40)}
}

for _, t in ipairs(themeColors) do
    createThemeButton(t.name, themeY, t.color)
    themeY = themeY + 50
end

local function performScan()
    if not scanActive then return end
    
    local found = {}
    local allInstances = workspace:GetDescendants()
    
    for _, v in pairs(allInstances) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
            local name = v.Name:lower()
            if name:find("backdoor") or name:find("exploit") or name:find("admin") or name:find("remote") or name:find("inject") or name:find("execute") or name:find("load") or name:find("script") or name:find("run") or name:find("control") or name:find("command") or name:find("hack") then
                table.insert(found, v)
            end
        end
    end
    
    if #found > 0 then
        for _, v in pairs(found) do
            local alreadyAdded = false
            for _, existing in pairs(backdoorsFound) do
                if existing == v then
                    alreadyAdded = true
                    break
                end
            end
            if not alreadyAdded then
                table.insert(backdoorsFound, v)
                addResult("Found: " .. v.Name .. " (" .. v.ClassName .. ")", Color3.fromRGB(255, 200, 50))
            end
        end
        scanStatus.Text = "Found " .. #backdoorsFound .. " backdoors"
        scanStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
    else
        if #backdoorsFound == 0 then
            addResult("Error Game Has No Backdoors: Code-203", Color3.fromRGB(255, 50, 80))
            scanStatus.Text = "No backdoors found"
            scanStatus.TextColor3 = Color3.fromRGB(255, 50, 80)
            scanActive = false
            scanBtn.Text = "Start Scan"
            if scanConnection then
                pcall(function() scanConnection:Disconnect() end)
                scanConnection = nil
            end
        end
    end
end

local function toggleScan()
    if scanActive then
        scanActive = false
        scanBtn.Text = "Start Scan"
        scanStatus.Text = "Scan Stopped"
        scanStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
        if scanConnection then
            pcall(function() scanConnection:Disconnect() end)
            scanConnection = nil
        end
        addResult("Scan interrupted", Color3.fromRGB(255, 200, 50))
    else
        clearResults()
        addResult("System initialized", Color3.fromRGB(0, 255, 200))
        scanActive = true
        scanBtn.Text = "Scanning..."
        scanStatus.Text = "Scanning for backdoors..."
        scanStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
        addResult("Scan started", Color3.fromRGB(0, 255, 200))

        if scanConnection then
            pcall(function() scanConnection:Disconnect() end)
            scanConnection = nil
        end

        performScan()
        
        scanConnection = RunService.Heartbeat:Connect(function()
            if not scanActive then return end
            performScan()
        end)
    end
end

scanBtn.MouseButton1Click:Connect(toggleScan)
stopBtn.MouseButton1Click:Connect(function()
    if scanActive then
        toggleScan()
    end
end)

tabScan.MouseButton1Click:Connect(function()
    scanPage.Visible = true
    resultsPage.Visible = false
    themePage.Visible = false
    tabScan.TextColor3 = themes[currentTheme].accent
    tabResults.TextColor3 = Color3.fromRGB(180, 180, 210)
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
    TweenService:Create(tabScan, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

tabResults.MouseButton1Click:Connect(function()
    scanPage.Visible = false
    resultsPage.Visible = true
    themePage.Visible = false
    tabResults.TextColor3 = themes[currentTheme].accent
    tabScan.TextColor3 = Color3.fromRGB(180, 180, 210)
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
    TweenService:Create(tabResults, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

tabTheme.MouseButton1Click:Connect(function()
    scanPage.Visible = false
    resultsPage.Visible = false
    themePage.Visible = true
    tabTheme.TextColor3 = themes[currentTheme].accent
    tabScan.TextColor3 = Color3.fromRGB(180, 180, 210)
    tabResults.TextColor3 = Color3.fromRGB(180, 180, 210)
    TweenService:Create(tabTheme, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

scanPage.Visible = true
tabScan.TextColor3 = themes.Default.accent
tabScan.BackgroundTransparency = 0

local function minimizeGUI()
    isMinimized = true
    frame.Size = UDim2.new(0, 180, 0, 40)
    frame.Position = UDim2.new(0.5, -90, 0.5, -20)
    tabContainer.Visible = false
    scanPage.Visible = false
    resultsPage.Visible = false
    themePage.Visible = false
    closeBtn.Visible = true
    minimizeBtn.Text = "+"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    titleLabel.Text = "NZ-BD"
    titleLabel.TextSize = 16
    subtitleLabel.Visible = false
    blur.Size = 0
end

local function maximizeGUI()
    isMinimized = false
    frame.Size = UDim2.new(0, 600, 0, 480)
    frame.Position = UDim2.new(0.5, -300, 0.5, -240)
    tabContainer.Visible = true
    scanPage.Visible = true
    resultsPage.Visible = false
    themePage.Visible = false
    closeBtn.Visible = true
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    titleLabel.Text = "NZ Backdoor Scan"
    titleLabel.TextSize = 18
    subtitleLabel.Visible = true
    blur.Size = 8
    tabScan.TextColor3 = themes[currentTheme].accent
    tabResults.TextColor3 = Color3.fromRGB(180, 180, 210)
    tabTheme.TextColor3 = Color3.fromRGB(180, 180, 210)
end

minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        maximizeGUI()
    else
        minimizeGUI()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if isMinimized then
            maximizeGUI()
        else
            minimizeGUI()
        end
    end
end)

local dragging, dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

frame.BackgroundTransparency = 1
frame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 600, 0, 480),
    BackgroundTransparency = 0.05
}):Play()
blur.Size = 8
