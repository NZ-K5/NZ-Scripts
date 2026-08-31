local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

pcall(function()
    if guiParent:FindFirstChild("ModRoot") then
        guiParent.ModRoot:Destroy()
    end
end)

local root = Instance.new("ScreenGui")
root.Name = "ModRoot"
root.Parent = guiParent
root.ResetOnSpawn = false
root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 6

local themes = {
    Default = {
        background = Color3.fromRGB(18, 18, 22),
        accent = Color3.fromRGB(0, 255, 150),
        text = Color3.fromRGB(220, 220, 230),
        button = Color3.fromRGB(30, 30, 35),
        stroke = Color3.fromRGB(0, 255, 150),
        danger = Color3.fromRGB(255, 70, 70)
    },
    Crimson = {
        background = Color3.fromRGB(20, 10, 12),
        accent = Color3.fromRGB(255, 50, 50),
        text = Color3.fromRGB(230, 200, 200),
        button = Color3.fromRGB(35, 20, 22),
        stroke = Color3.fromRGB(200, 40, 40),
        danger = Color3.fromRGB(255, 30, 30)
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
local noclipActive = false
local keyboardFlyActive = false
local mouseFlyActive = false
local floatActive = false
local jumpActive = false
local infJumpActive = false
local flingActive = false
local speedMultiplier = 1
local jumpHeight = 50
local floatHeight = 20
local flySpeed = 50
local mouseFlySpeed = 30
local flingPower = 500
local noclipConnections = {}
local keyboardFlyConnection = nil
local mouseFlyConnection = nil
local floatConnection = nil
local jumpConnection = nil
local infJumpConnection = nil
local flingConnection = nil
local originalCollision = {}

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 580, 0, 580)
frame.Position = UDim2.new(0.5, -290, 0.5, -290)
frame.BackgroundColor3 = themes.Default.background
frame.BackgroundTransparency = 0.08
frame.ClipsDescendants = true
frame.Parent = root
frame.Visible = true
frame.ZIndex = 10

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = themes.Default.stroke
stroke.Thickness = 1.5
stroke.Transparency = 0.6

local grad = Instance.new("UIGradient", frame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.Text = "NZ-Brookhaven"
titleLabel.TextColor3 = themes.Default.accent
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -80, 0, 4)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
minimizeBtn.BackgroundTransparency = 0.2
minimizeBtn.Parent = titleBar
local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 6)

minimizeBtn.MouseEnter:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
end)
minimizeBtn.MouseLeave:Connect(function()
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 4)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
closeBtn.TextSize = 18
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
    confirm.Text = "Confirm Close?"
    confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirm.TextSize = 14
    confirm.Font = Enum.Font.GothamBold
    confirm.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    confirm.Parent = frame
    local cCorner = Instance.new("UICorner", confirm)
    cCorner.CornerRadius = UDim.new(0, 6)
    confirm.ZIndex = 999

    local function destroyAll()
        confirm:Destroy()
        for _, conn in pairs(noclipConnections) do
            pcall(function() conn:Disconnect() end)
        end
        if keyboardFlyConnection then
            pcall(function() keyboardFlyConnection:Disconnect() end)
            keyboardFlyConnection = nil
        end
        if mouseFlyConnection then
            pcall(function() mouseFlyConnection:Disconnect() end)
            mouseFlyConnection = nil
        end
        if floatConnection then
            pcall(function() floatConnection:Disconnect() end)
            floatConnection = nil
        end
        if jumpConnection then
            pcall(function() jumpConnection:Disconnect() end)
            jumpConnection = nil
        end
        if infJumpConnection then
            pcall(function() infJumpConnection:Disconnect() end)
            infJumpConnection = nil
        end
        if flingConnection then
            pcall(function() flingConnection:Disconnect() end)
            flingConnection = nil
        end
        root:Destroy()
        blur:Destroy()
    end

    confirm.MouseButton1Click:Connect(destroyAll)
    task.wait(3)
    confirm:Destroy()
end)

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local function createTab(name, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BackgroundTransparency = 0.3
    btn.Parent = tabContainer
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end

local tabCar = createTab("Car Mods", 0)
local tabPlayer = createTab("Player", 145)
local tabTheme = createTab("Theme", 290)

local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -20, 1, -95)
    pg.Position = UDim2.new(0, 10, 0, 85)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 650)
    pg.ScrollBarThickness = 4
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local carPage = createPage()
local playerPage = createPage()
local themePage = createPage()

local function makeLabel(text, y, parent, w)
    w = w or 140
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, w, 0, 30)
    l.Position = UDim2.new(0, 0, 0, y)
    l.Text = text
    l.TextColor3 = themes.Default.text
    l.TextSize = 13
    l.Font = Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function makeBox(y, parent, default)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0, 120, 0, 28)
    b.Position = UDim2.new(0, 150, 0, y)
    b.Text = default or ""
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 13
    b.Font = Enum.Font.Code
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.ClearTextOnFocus = false
    b.Parent = parent
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 4)
    return b
end

local function makeApply(y, parent, text)
    text = text or "Apply"
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 70, 0, 28)
    b.Position = UDim2.new(0, 280, 0, y)
    b.Text = text
    b.TextColor3 = themes.Default.accent
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = themes.Default.button
    b.Parent = parent
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 4)
    return b
end

local function makeToggle(y, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 28)
    btn.Position = UDim2.new(0, 180, 0, y)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    btn.Parent = parent
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 4)
    return btn
end

local yOff = 0

makeLabel("MaxSpeed", yOff, carPage)
local speedBox = makeBox(yOff, carPage, "50")
local speedApply = makeApply(yOff, carPage)
yOff = yOff + 35

makeLabel("Turbo String", yOff, carPage)
local turboBox = makeBox(yOff, carPage, "TurboEnabled")
local turboApply = makeApply(yOff, carPage)
yOff = yOff + 35

makeLabel("Speed Multiplier", yOff, carPage)
local speedMultBox = makeBox(yOff, carPage, "2")
local speedMultApply = makeApply(yOff, carPage)
yOff = yOff + 35

makeLabel("Jump Height", yOff, carPage)
local jumpHeightBox = makeBox(yOff, carPage, "50")
local jumpHeightApply = makeApply(yOff, carPage)
yOff = yOff + 35

makeLabel("Float Height", yOff, carPage)
local floatHeightBox = makeBox(yOff, carPage, "20")
local floatHeightApply = makeApply(yOff, carPage)
yOff = yOff + 40

makeLabel("Noclip", yOff, carPage)
local noclipBtn = makeToggle(yOff, carPage)
yOff = yOff + 35

makeLabel("Keyboard Fly", yOff, carPage)
local keyboardFlyBtn = makeToggle(yOff, carPage)
yOff = yOff + 35

makeLabel("Mouse Fly", yOff, carPage)
local mouseFlyBtn = makeToggle(yOff, carPage)
yOff = yOff + 35

makeLabel("Car Float", yOff, carPage)
local floatBtn = makeToggle(yOff, carPage)
yOff = yOff + 35

makeLabel("Car Jump (F)", yOff, carPage)
local jumpBtn = makeToggle(yOff, carPage)
yOff = yOff + 35

makeLabel("Car Fling", yOff, carPage)
local flingBtn = makeToggle(yOff, carPage)
yOff = yOff + 35

makeLabel("Fling Power", yOff, carPage)
local flingPowerBox = makeBox(yOff, carPage, "500")
local flingPowerApply = makeApply(yOff, carPage, "Set")
flingPowerApply.Size = UDim2.new(0, 50, 0, 28)
flingPowerApply.Position = UDim2.new(0, 280, 0, yOff)
flingPowerApply.Text = "Set"
yOff = yOff + 40

local modButton = Instance.new("TextButton")
modButton.Size = UDim2.new(0, 400, 0, 35)
modButton.Position = UDim2.new(0, 0, 0, yOff)
modButton.Text = "Car Modded Customization"
modButton.TextColor3 = themes.Default.accent
modButton.TextSize = 13
modButton.Font = Enum.Font.GothamBold
modButton.BackgroundColor3 = themes.Default.button
modButton.Parent = carPage
local mbCorner = Instance.new("UICorner", modButton)
mbCorner.CornerRadius = UDim.new(0, 6)
yOff = yOff + 45

local instantBrakeBtn = Instance.new("TextButton")
instantBrakeBtn.Size = UDim2.new(0, 180, 0, 35)
instantBrakeBtn.Position = UDim2.new(0, 0, 0, yOff)
instantBrakeBtn.Text = "Instant Brake"
instantBrakeBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
instantBrakeBtn.TextSize = 13
instantBrakeBtn.Font = Enum.Font.GothamBold
instantBrakeBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 20)
instantBrakeBtn.Parent = carPage
local ibCorner = Instance.new("UICorner", instantBrakeBtn)
ibCorner.CornerRadius = UDim.new(0, 6)
yOff = yOff + 45

makeLabel("Car Scale", yOff, carPage)
local carScaleBox = makeBox(yOff, carPage, "1")
local carScaleApply = makeApply(yOff, carPage, "Set")
carScaleApply.Size = UDim2.new(0, 50, 0, 28)
carScaleApply.Position = UDim2.new(0, 280, 0, yOff)
carScaleApply.Text = "Set"
yOff = yOff + 35

carPage.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)

local pOff = 0

makeLabel("Infinite Jump", pOff, playerPage)
local infJumpBtn = makeToggle(pOff, playerPage)
pOff = pOff + 35

makeLabel("Walk Speed", pOff, playerPage)
local walkSpeedBox = makeBox(pOff, playerPage, "16")
local walkSpeedApply = makeApply(pOff, playerPage)
pOff = pOff + 35

makeLabel("Jump Power", pOff, playerPage)
local jumpPowerBox = makeBox(pOff, playerPage, "50")
local jumpPowerApply = makeApply(pOff, playerPage)
pOff = pOff + 40

makeLabel("Teleport to Player", pOff, playerPage)
local tpBox = makeBox(pOff, playerPage, "Username")
local tpApply = makeApply(pOff, playerPage, "TP")
tpApply.Size = UDim2.new(0, 50, 0, 28)
tpApply.Position = UDim2.new(0, 280, 0, pOff)
tpApply.Text = "TP"
pOff = pOff + 35

makeLabel("Teleport to Coords", pOff, playerPage)
local coordBox = makeBox(pOff, playerPage, "0, 10, 0")
local coordApply = makeApply(pOff, playerPage, "TP")
coordApply.Size = UDim2.new(0, 50, 0, 28)
coordApply.Position = UDim2.new(0, 280, 0, pOff)
coordApply.Text = "TP"
pOff = pOff + 45

local respawnBtn = Instance.new("TextButton")
respawnBtn.Size = UDim2.new(0, 180, 0, 35)
respawnBtn.Position = UDim2.new(0, 0, 0, pOff)
respawnBtn.Text = "Respawn"
respawnBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
respawnBtn.TextSize = 13
respawnBtn.Font = Enum.Font.GothamBold
respawnBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 20)
respawnBtn.Parent = playerPage
local respCorner = Instance.new("UICorner", respawnBtn)
respCorner.CornerRadius = UDim.new(0, 6)

playerPage.CanvasSize = UDim2.new(0, 0, 0, pOff + 60)

local themeY = 0
local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(1, -20, 0, 30)
themeLabel.Position = UDim2.new(0, 10, 0, themeY)
themeLabel.Text = "Select Theme:"
themeLabel.TextColor3 = themes.Default.text
themeLabel.TextSize = 14
themeLabel.Font = Enum.Font.GothamBold
themeLabel.BackgroundTransparency = 1
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.Parent = themePage
themeY = themeY + 40

local function createThemeButton(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Parent = themePage
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minimizeBtn and child ~= noclipBtn and child ~= keyboardFlyBtn and child ~= mouseFlyBtn and child ~= floatBtn and child ~= jumpBtn and child ~= flingBtn and child ~= infJumpBtn and child ~= speedApply and child ~= turboApply and child ~= speedMultApply and child ~= jumpHeightApply and child ~= floatHeightApply and child ~= walkSpeedApply and child ~= jumpPowerApply and child ~= tpApply and child ~= coordApply and child ~= carScaleApply and child ~= flingPowerApply then
                if child.Text == "Apply" or child.Text == "Set" or child.Text == "Car Modded Customization" or child.Text == "Instant Brake" or child.Text == "Respawn" then
                    child.TextColor3 = t.accent
                end
            end
            if child:IsA("TextBox") then
                child.BackgroundColor3 = t.button
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

local themeNames = {"Default", "Crimson", "Cyber", "Amber", "Violet"}
for i, name in ipairs(themeNames) do
    createThemeButton(name, themeY + (i-1)*45)
end

local carModel
local carModelConnection = nil
local carModelRemovingConnection = nil

local function updateCarModel(newCar)
    carModel = newCar
    originalCollision = {}
end

local function setupCarTracking()
    if carModelConnection then
        carModelConnection:Disconnect()
        carModelConnection = nil
    end
    if carModelRemovingConnection then
        carModelRemovingConnection:Disconnect()
        carModelRemovingConnection = nil
    end
    
    carModelConnection = workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("Model") and desc.Name == player.Name.."Car" then
            updateCarModel(desc)
        end
    end)
    
    carModelRemovingConnection = workspace.DescendantRemoving:Connect(function(desc)
        if desc == carModel then
            carModel = nil
            for _, conn in pairs(noclipConnections) do
                pcall(function() conn:Disconnect() end)
            end
            noclipConnections = {}
            noclipActive = false
            noclipBtn.Text = "OFF"
            noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            noclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            if keyboardFlyConnection then
                pcall(function() keyboardFlyConnection:Disconnect() end)
                keyboardFlyConnection = nil
            end
            keyboardFlyActive = false
            keyboardFlyBtn.Text = "OFF"
            keyboardFlyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            keyboardFlyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            if mouseFlyConnection then
                pcall(function() mouseFlyConnection:Disconnect() end)
                mouseFlyConnection = nil
            end
            mouseFlyActive = false
            mouseFlyBtn.Text = "OFF"
            mouseFlyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            mouseFlyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            if floatConnection then
                pcall(function() floatConnection:Disconnect() end)
                floatConnection = nil
            end
            floatActive = false
            floatBtn.Text = "OFF"
            floatBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            floatBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            if jumpConnection then
                pcall(function() jumpConnection:Disconnect() end)
                jumpConnection = nil
            end
            jumpActive = false
            jumpBtn.Text = "OFF"
            jumpBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            jumpBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            if flingConnection then
                pcall(function() flingConnection:Disconnect() end)
                flingConnection = nil
            end
            flingActive = false
            flingBtn.Text = "OFF"
            flingBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            flingBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            if infJumpConnection then
                pcall(function() infJumpConnection:Disconnect() end)
                infJumpConnection = nil
            end
            infJumpActive = false
            infJumpBtn.Text = "OFF"
            infJumpBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            infJumpBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            originalCollision = {}
        end
    end)
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == player.Name.."Car" then
            updateCarModel(v)
            break
        end
    end
end

setupCarTracking()

local function findValue(name)
    if not carModel then return end
    for _, v in pairs(carModel:GetDescendants()) do
        if v.Name == name then
            return v
        end
    end
end

local function restoreCollision()
    for part, data in pairs(originalCollision) do
        if part and part:IsA("BasePart") then
            part.CanCollide = data.collide
            part.CanTouch = data.touch
        end
    end
    originalCollision = {}
end

local function toggleNoclip()
    if not carModel then return end
    noclipActive = not noclipActive
    if noclipActive then
        noclipBtn.Text = "ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        noclipBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        originalCollision = {}
        for _, part in pairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCollision[part] = {collide = part.CanCollide, touch = part.CanTouch}
                local conn = part.Touched:Connect(function(hit)
                    if hit and hit:IsA("BasePart") and hit.Parent ~= carModel then
                        local char = player.Character
                        if char and char:FindFirstChild("Humanoid") then
                            local rootPart = char:FindFirstChild("HumanoidRootPart")
                            if rootPart and rootPart.Parent == part.Parent then return end
                        end
                        if hit.Name == "Floor" or hit.Name == "Ground" or hit:IsA("Terrain") then return end
                        if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then return end
                        part.CanCollide = false
                        part.CanTouch = false
                    end
                end)
                table.insert(noclipConnections, conn)
                part.CanCollide = false
                part.CanTouch = false
            end
        end
    else
        noclipBtn.Text = "OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        noclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        for _, conn in pairs(noclipConnections) do
            pcall(function() conn:Disconnect() end)
        end
        noclipConnections = {}
        restoreCollision()
    end
end

noclipBtn.MouseButton1Click:Connect(toggleNoclip)

local function toggleKeyboardFly()
    if not carModel then return end
    if mouseFlyActive then
        toggleMouseFly()
    end
    keyboardFlyActive = not keyboardFlyActive
    if keyboardFlyActive then
        keyboardFlyBtn.Text = "ON"
        keyboardFlyBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        keyboardFlyBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        if keyboardFlyConnection then
            pcall(function() keyboardFlyConnection:Disconnect() end)
            keyboardFlyConnection = nil
        end
        keyboardFlyConnection = RunService.Heartbeat:Connect(function()
            if not carModel or not keyboardFlyActive then return end
            local char = player.Character
            if not char then return end
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then return end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            local carRoot = carModel:FindFirstChild("HumanoidRootPart") or carModel:FindFirstChildWhichIsA("BasePart")
            if not carRoot then return end
            
            local moveDirection = humanoid.MoveDirection
            local forward = Vector3.new(moveDirection.X, 0, moveDirection.Z) * flySpeed
            local up = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                up = Vector3.new(0, flySpeed, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.E) then
                up = Vector3.new(0, -flySpeed, 0)
            end
            
            local velocity = forward + up
            if velocity.Magnitude > 0 then
                carRoot.Velocity = velocity
                carRoot.CFrame = carRoot.CFrame + velocity * 0.016
                for _, part in pairs(carModel:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= carRoot then
                        part.Velocity = velocity
                    end
                end
            end
        end)
    else
        keyboardFlyBtn.Text = "OFF"
        keyboardFlyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        keyboardFlyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if keyboardFlyConnection then
            pcall(function() keyboardFlyConnection:Disconnect() end)
            keyboardFlyConnection = nil
        end
        for _, part in pairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

keyboardFlyBtn.MouseButton1Click:Connect(toggleKeyboardFly)

local function toggleMouseFly()
    if not carModel then return end
    if keyboardFlyActive then
        toggleKeyboardFly()
    end
    mouseFlyActive = not mouseFlyActive
    if mouseFlyActive then
        mouseFlyBtn.Text = "ON"
        mouseFlyBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        mouseFlyBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        if mouseFlyConnection then
            pcall(function() mouseFlyConnection:Disconnect() end)
            mouseFlyConnection = nil
        end
        mouseFlyConnection = RunService.Heartbeat:Connect(function()
            if not carModel or not mouseFlyActive then return end
            local char = player.Character
            if not char then return end
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then return end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            local camera = workspace.CurrentCamera
            if not camera then return end
            local carRoot = carModel:FindFirstChild("HumanoidRootPart") or carModel:FindFirstChildWhichIsA("BasePart")
            if not carRoot then return end
            
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ScreenPointToRay(mousePos.X, mousePos.Y)
            local targetPos = ray.Origin + ray.Direction * 500
            local direction = (targetPos - carRoot.Position).Unit
            local horizontalDir = Vector3.new(direction.X, 0, direction.Z).Unit
            
            local up = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                up = Vector3.new(0, mouseFlySpeed, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.E) then
                up = Vector3.new(0, -mouseFlySpeed, 0)
            end
            
            local velocity = horizontalDir * mouseFlySpeed + up
            if velocity.Magnitude > 0 then
                carRoot.Velocity = velocity
                carRoot.CFrame = carRoot.CFrame + velocity * 0.016
                for _, part in pairs(carModel:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= carRoot then
                        part.Velocity = velocity
                    end
                end
            end
        end)
    else
        mouseFlyBtn.Text = "OFF"
        mouseFlyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        mouseFlyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if mouseFlyConnection then
            pcall(function() mouseFlyConnection:Disconnect() end)
            mouseFlyConnection = nil
        end
        for _, part in pairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

mouseFlyBtn.MouseButton1Click:Connect(toggleMouseFly)

local function toggleFloat()
    if not carModel then return end
    floatActive = not floatActive
    if floatActive then
        floatBtn.Text = "ON"
        floatBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        floatBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        if floatConnection then
            pcall(function() floatConnection:Disconnect() end)
            floatConnection = nil
        end
        floatConnection = RunService.Heartbeat:Connect(function()
            if not carModel or not floatActive then return end
            local carRoot = carModel:FindFirstChild("HumanoidRootPart") or carModel:FindFirstChildWhichIsA("BasePart")
            if not carRoot then return end
            
            local ray = Ray.new(carRoot.Position + Vector3.new(0, 10, 0), Vector3.new(0, -100, 0))
            local hit, pos = workspace:FindPartOnRay(ray, carModel)
            if hit and pos then
                local targetY = pos.Y + floatHeight
                local currentY = carRoot.Position.Y
                if currentY < targetY then
                    carRoot.Velocity = Vector3.new(carRoot.Velocity.X, (targetY - currentY) * 8, carRoot.Velocity.Z)
                elseif currentY > targetY + 1 then
                    carRoot.Velocity = Vector3.new(carRoot.Velocity.X, -10, carRoot.Velocity.Z)
                end
            end
        end)
    else
        floatBtn.Text = "OFF"
        floatBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        floatBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if floatConnection then
            pcall(function() floatConnection:Disconnect() end)
            floatConnection = nil
        end
    end
end

floatBtn.MouseButton1Click:Connect(toggleFloat)

local function toggleJump()
    if not carModel then return end
    jumpActive = not jumpActive
    if jumpActive then
        jumpBtn.Text = "ON"
        jumpBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        jumpBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        if jumpConnection then
            pcall(function() jumpConnection:Disconnect() end)
            jumpConnection = nil
        end
        jumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if not carModel or not jumpActive then return end
            if input.KeyCode == Enum.KeyCode.F then
                local carRoot = carModel:FindFirstChild("HumanoidRootPart") or carModel:FindFirstChildWhichIsA("BasePart")
                if carRoot then
                    carRoot.Velocity = Vector3.new(carRoot.Velocity.X, jumpHeight, carRoot.Velocity.Z)
                end
            end
        end)
    else
        jumpBtn.Text = "OFF"
        jumpBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        jumpBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if jumpConnection then
            pcall(function() jumpConnection:Disconnect() end)
            jumpConnection = nil
        end
    end
end

jumpBtn.MouseButton1Click:Connect(toggleJump)

local function toggleFling()
    if not carModel then return end
    flingActive = not flingActive
    if flingActive then
        flingBtn.Text = "ON"
        flingBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        flingBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
        if flingConnection then
            pcall(function() flingConnection:Disconnect() end)
            flingConnection = nil
        end
        flingConnection = RunService.Heartbeat:Connect(function()
            if not flingActive then return end
            
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player then
                    local otherChar = otherPlayer.Character
                    if otherChar then
                        local otherCar = otherChar:FindFirstChildOfClass("Model")
                        if otherCar and otherCar.Name:find("Car") then
                            local char = player.Character
                            if char then
                                local rootPart = char:FindFirstChild("HumanoidRootPart")
                                if rootPart and (rootPart.Position - otherCar:GetPivot().Position).Magnitude < 20 then
                                    local carRoot = otherCar:FindFirstChild("HumanoidRootPart") or otherCar:FindFirstChildWhichIsA("BasePart")
                                    if carRoot then
                                        local direction = (carRoot.Position - rootPart.Position).Unit
                                        carRoot.Velocity = direction * flingPower + Vector3.new(0, flingPower * 0.3, 0)
                                        for _, part in pairs(otherCar:GetDescendants()) do
                                            if part:IsA("BasePart") and part ~= carRoot then
                                                part.Velocity = direction * flingPower + Vector3.new(0, flingPower * 0.3, 0)
                                            end
                                        end
                                        local humanoid = char:FindFirstChild("Humanoid")
                                        if humanoid then
                                            humanoid.Sit = true
                                            task.wait(0.1)
                                            humanoid.Sit = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        flingBtn.Text = "OFF"
        flingBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        flingBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if flingConnection then
            pcall(function() flingConnection:Disconnect() end)
            flingConnection = nil
        end
    end
end

flingBtn.MouseButton1Click:Connect(toggleFling)

flingPowerApply.MouseButton1Click:Connect(function()
    local power = tonumber(flingPowerBox.Text)
    if power and power > 0 then
        flingPower = power
    end
end)

local function toggleInfJump()
    infJumpActive = not infJumpActive
    if infJumpActive then
        infJumpBtn.Text = "ON"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        infJumpBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        if infJumpConnection then
            pcall(function() infJumpConnection:Disconnect() end)
            infJumpConnection = nil
        end
        local playerChar = player.Character
        if playerChar then
            local humanoid = playerChar:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Jump = true
            end
        end
        infJumpConnection = RunService.Heartbeat:Connect(function()
            if not infJumpActive then return end
            local char = player.Character
            if not char then return end
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then return end
            if humanoid.Jump then
                humanoid.Jump = true
            end
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end)
    else
        infJumpBtn.Text = "OFF"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        infJumpBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if infJumpConnection then
            pcall(function() infJumpConnection:Disconnect() end)
            infJumpConnection = nil
        end
    end
end

infJumpBtn.MouseButton1Click:Connect(toggleInfJump)

speedApply.MouseButton1Click:Connect(function()
    local v = findValue("MaxSpeed")
    if v and v:IsA("NumberValue") then
        v.Value = tonumber(speedBox.Text) or v.Value
    end
end)

turboApply.MouseButton1Click:Connect(function()
    local v = findValue("Turbo")
    if v and v:IsA("StringValue") then
        v.Value = turboBox.Text
    end
end)

speedMultApply.MouseButton1Click:Connect(function()
    speedMultiplier = tonumber(speedMultBox.Text) or 1
    local v = findValue("MaxSpeed")
    if v and v:IsA("NumberValue") then
        v.Value = v.Value * speedMultiplier
    end
end)

jumpHeightApply.MouseButton1Click:Connect(function()
    jumpHeight = tonumber(jumpHeightBox.Text) or 50
end)

floatHeightApply.MouseButton1Click:Connect(function()
    floatHeight = tonumber(floatHeightBox.Text) or 20
    if floatActive then
        toggleFloat()
        toggleFloat()
    end
end)

local keyboardFlySpeedBox = makeBox(yOff, carPage, "50")
local keyboardFlySpeedApply = makeApply(yOff, carPage, "Set")
keyboardFlySpeedApply.Size = UDim2.new(0, 50, 0, 28)
keyboardFlySpeedApply.Position = UDim2.new(0, 280, 0, yOff)
keyboardFlySpeedApply.Text = "Set"

keyboardFlySpeedApply.MouseButton1Click:Connect(function()
    local speed = tonumber(keyboardFlySpeedBox.Text)
    if speed and speed > 0 then
        flySpeed = speed
    end
end)

local mouseFlySpeedBox = makeBox(yOff, carPage, "30")
local mouseFlySpeedApply = makeApply(yOff, carPage, "Set")
mouseFlySpeedApply.Size = UDim2.new(0, 50, 0, 28)
mouseFlySpeedApply.Position = UDim2.new(0, 280, 0, yOff)
mouseFlySpeedApply.Text = "Set"

mouseFlySpeedApply.MouseButton1Click:Connect(function()
    local speed = tonumber(mouseFlySpeedBox.Text)
    if speed and speed > 0 then
        mouseFlySpeed = speed
    end
end)

modButton.MouseButton1Click:Connect(function()
    if not carModel then return end
    local materials = {"Plastic","Neon","Metal","Wood","Slate","Concrete","DiamondPlate"}
    local matStr = materials[math.random(1, #materials)]
    local color = Color3.fromRGB(math.random(50,255), math.random(50,255), math.random(50,255))
    for _, part in pairs(carModel:GetDescendants()) do
        if part:IsA("BasePart") then
            local r,g,b = part.Color.R, part.Color.G, part.Color.B
            if not ((r > 0.9 and g > 0.9 and b > 0.9) or (r < 0.1 and g < 0.1 and b < 0.1) or (math.abs(r-g)<0.05 and math.abs(r-b)<0.05)) then
                pcall(function()
                    part.Material = Enum.Material[matStr]
                end)
                part.Color = color
            end
        end
    end
end)

instantBrakeBtn.MouseButton1Click:Connect(function()
    if not carModel then return end
    for _, part in pairs(carModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

carScaleApply.MouseButton1Click:Connect(function()
    if not carModel then return end
    local scale = tonumber(carScaleBox.Text)
    if scale and scale > 0 then
        for _, part in pairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * scale
            end
        end
    end
end)

walkSpeedApply.MouseButton1Click:Connect(function()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = tonumber(walkSpeedBox.Text) or 16
        end
    end
end)

jumpPowerApply.MouseButton1Click:Connect(function()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = tonumber(jumpPowerBox.Text) or 50
        end
    end
end)

tpApply.MouseButton1Click:Connect(function()
    local targetName = tpBox.Text
    local target = Players:FindFirstChild(targetName)
    if target and target.Character then
        local char = player.Character
        if char then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
    end
end)

coordApply.MouseButton1Click:Connect(function()
    local coords = coordBox.Text
    local parts = {}
    for word in coords:gmatch("[^, ]+") do
        table.insert(parts, tonumber(word))
    end
    if #parts >= 3 then
        local char = player.Character
        if char then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(parts[1], parts[2], parts[3])
            end
        end
    end
end)

respawnBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end)

tabCar.MouseButton1Click:Connect(function()
    carPage.Visible = true
    playerPage.Visible = false
    themePage.Visible = false
    tabCar.TextColor3 = themes[currentTheme].accent
    tabPlayer.TextColor3 = Color3.fromRGB(200, 200, 210)
    tabTheme.TextColor3 = Color3.fromRGB(200, 200, 210)
end)

tabPlayer.MouseButton1Click:Connect(function()
    carPage.Visible = false
    playerPage.Visible = true
    themePage.Visible = false
    tabPlayer.TextColor3 = themes[currentTheme].accent
    tabCar.TextColor3 = Color3.fromRGB(200, 200, 210)
    tabTheme.TextColor3 = Color3.fromRGB(200, 200, 210)
end)

tabTheme.MouseButton1Click:Connect(function()
    carPage.Visible = false
    playerPage.Visible = false
    themePage.Visible = true
    tabTheme.TextColor3 = themes[currentTheme].accent
    tabCar.TextColor3 = Color3.fromRGB(200, 200, 210)
    tabPlayer.TextColor3 = Color3.fromRGB(200, 200, 210)
end)

carPage.Visible = true
tabCar.TextColor3 = themes.Default.accent

local function minimizeGUI()
    isMinimized = true
    frame.Size = UDim2.new(0, 180, 0, 40)
    frame.Position = UDim2.new(0.5, -90, 0.5, -20)
    tabContainer.Visible = false
    carPage.Visible = false
    playerPage.Visible = false
    themePage.Visible = false
    closeBtn.Visible = true
    minimizeBtn.Text = "+"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    titleLabel.Text = "NZ-BH"
    titleLabel.TextSize = 16
    blur.Size = 0
end

local function maximizeGUI()
    isMinimized = false
    frame.Size = UDim2.new(0, 580, 0, 580)
    frame.Position = UDim2.new(0.5, -290, 0.5, -290)
    tabContainer.Visible = true
    carPage.Visible = true
    playerPage.Visible = false
    themePage.Visible = false
    closeBtn.Visible = true
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    titleLabel.Text = "NZ-Brookhaven"
    titleLabel.TextSize = 18
    blur.Size = 6
    tabCar.TextColor3 = themes[currentTheme].accent
    tabPlayer.TextColor3 = Color3.fromRGB(200, 200, 210)
    tabTheme.TextColor3 = Color3.fromRGB(200, 200, 210)
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
