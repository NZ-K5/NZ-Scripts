local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

pcall(function()
    if guiParent:FindFirstChild("ModRoot") then
        guiParent.ModRoot:Destroy()
    end
    if guiParent:FindFirstChild("NZBHButton") then
        guiParent.NZBHButton:Destroy()
    end
end)

local root = Instance.new("ScreenGui")
root.Name = "ModRoot"
root.Parent = guiParent
root.ResetOnSpawn = false
root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 0

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
local isOpen = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 520, 0, 380)
frame.Position = UDim2.new(0.5, -260, 0.5, -190)
frame.BackgroundColor3 = themes.Default.background
frame.BackgroundTransparency = 0.08
frame.ClipsDescendants = true
frame.Parent = root
frame.Visible = false
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
titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.Text = "NZ-Brookhaven"
titleLabel.TextColor3 = themes.Default.accent
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

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
        root:Destroy()
        blur:Destroy()
        if guiParent:FindFirstChild("NZBHButton") then
            guiParent.NZBHButton:Destroy()
        end
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
    btn.Size = UDim2.new(0, 150, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BackgroundTransparency = 0.3
    btn.Parent = tabContainer
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end

local tabCar = createTab("Car Mods", 0)
local tabOther = createTab("Other", 160)
local tabTheme = createTab("Theme", 320)

local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -20, 1, -95)
    pg.Position = UDim2.new(0, 10, 0, 85)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 300)
    pg.ScrollBarThickness = 4
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local carPage = createPage()
local otherPage = createPage()
local themePage = createPage()

local function makeLabel(text, y, parent, w)
    w = w or 140
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, w, 0, 30)
    l.Position = UDim2.new(0, 0, 0, y)
    l.Text = text
    l.TextColor3 = themes.Default.text
    l.TextSize = 14
    l.Font = Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function makeBox(y, parent, default)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0, 150, 0, 30)
    b.Position = UDim2.new(0, 150, 0, y)
    b.Text = default or ""
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 14
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
    b.Size = UDim2.new(0, 90, 0, 30)
    b.Position = UDim2.new(0, 310, 0, y)
    b.Text = text
    b.TextColor3 = themes.Default.accent
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = themes.Default.button
    b.Parent = parent
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 4)
    return b
end

local yOff = 0
makeLabel("MaxSpeed", yOff, carPage)
local speedBox = makeBox(yOff, carPage, "50")
local speedApply = makeApply(yOff, carPage)
yOff = yOff + 40

makeLabel("Turbo String", yOff, carPage)
local turboBox = makeBox(yOff, carPage, "TurboEnabled")
local turboApply = makeApply(yOff, carPage)
yOff = yOff + 45

local modButton = Instance.new("TextButton")
modButton.Size = UDim2.new(0, 400, 0, 35)
modButton.Position = UDim2.new(0, 0, 0, yOff)
modButton.Text = "Car Modded Customization"
modButton.TextColor3 = themes.Default.accent
modButton.TextSize = 14
modButton.Font = Enum.Font.GothamBold
modButton.BackgroundColor3 = themes.Default.button
modButton.Parent = carPage
local mbCorner = Instance.new("UICorner", modButton)
mbCorner.CornerRadius = UDim.new(0, 6)

local deleteBtn = Instance.new("TextButton")
deleteBtn.Size = UDim2.new(0, 200, 0, 40)
deleteBtn.Position = UDim2.new(0.5, -100, 0.5, -20)
deleteBtn.Text = "Delete GUI"
deleteBtn.TextColor3 = themes.Default.danger
deleteBtn.TextSize = 16
deleteBtn.Font = Enum.Font.GothamBold
deleteBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
deleteBtn.Parent = otherPage
local delCorner = Instance.new("UICorner", deleteBtn)
delCorner.CornerRadius = UDim.new(0, 8)

deleteBtn.MouseButton1Click:Connect(function()
    root:Destroy()
    blur:Destroy()
    if guiParent:FindFirstChild("NZBHButton") then
        guiParent.NZBHButton:Destroy()
    end
end)

local themeY = 0
local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(1, -20, 0, 30)
themeLabel.Position = UDim2.new(0, 10, 0, themeY)
themeLabel.Text = "Select Theme:"
themeLabel.TextColor3 = themes.Default.text
themeLabel.TextSize = 16
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
    btn.TextSize = 14
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
            if child:IsA("TextButton") and child ~= closeBtn and child ~= deleteBtn then
                if child.Text == "Apply" or child.Text == "Car Modded Customization" then
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
        deleteBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        deleteBtn.TextColor3 = t.danger
        if guiParent:FindFirstChild("NZBHButton") then
            local btnStroke = guiParent.NZBHButton:FindFirstChild("UIStroke")
            if btnStroke then
                btnStroke.Color = t.stroke
            end
            local btnLabel = guiParent.NZBHButton:FindFirstChild("TextLabel")
            if btnLabel then
                btnLabel.TextColor3 = t.accent
            end
        end
    end)
    return btn
end

local themeNames = {"Default", "Crimson", "Cyber", "Amber", "Violet"}
for i, name in ipairs(themeNames) do
    createThemeButton(name, themeY + (i-1)*45)
end

local carModel

local function updateCarModel(newCar)
    carModel = newCar
end

for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Model") and v.Name == player.Name.."Car" then
        updateCarModel(v)
        break
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("Model") and desc.Name == player.Name.."Car" then
        updateCarModel(desc)
    end
end)

workspace.DescendantRemoving:Connect(function(desc)
    if desc == carModel then
        carModel = nil
    end
end)

local function findValue(name)
    if not carModel then return end
    for _, v in pairs(carModel:GetDescendants()) do
        if v.Name == name then
            return v
        end
    end
end

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

modButton.MouseButton1Click:Connect(function()
    if not carModel then return end
    local materials = {"Plastic","Neon","Metal","Wood","Slate","Concrete","DiamondPlate"}
    local matStr = materials[math.random(1, #materials)]
    local color = Color3.fromRGB(math.random(50,255), math.random(50,255), math.random(50,255))
    for _, part in pairs(carModel:GetDescendants()) do
        if part:IsA("BasePart") then
            local r,g,b = part.Color.R, part.Color.G, part.Color.B
            if not ((r > 0.9 and g > 0.9 and b > 0.9) or (r < 0.1 and g < 0.1 and b < 0.1) or (math.abs(r-g)<0.05 and math.abs(r-b)<0.05)) then
                part.Material = Enum.Material[matStr] or part.Material
                part.Color = color
            end
        end
    end
end)

tabCar.MouseButton1Click:Connect(function()
    carPage.Visible = true
    otherPage.Visible = false
    themePage.Visible = false
    tabCar.TextColor3 = themes[currentTheme].accent
    tabOther.TextColor3 = Color3.fromRGB(200, 200, 210)
    tabTheme.TextColor3 = Color3.fromRGB(200, 200, 210)
end)

tabOther.MouseButton1Click:Connect(function()
    carPage.Visible = false
    otherPage.Visible = true
    themePage.Visible = false
    tabOther.TextColor3 = themes[currentTheme].accent
    tabCar.TextColor3 = Color3.fromRGB(200, 200, 210)
    tabTheme.TextColor3 = Color3.fromRGB(200, 200, 210)
end)

tabTheme.MouseButton1Click:Connect(function()
    carPage.Visible = false
    otherPage.Visible = false
    themePage.Visible = true
    tabTheme.TextColor3 = themes[currentTheme].accent
    tabCar.TextColor3 = Color3.fromRGB(200, 200, 210)
    tabOther.TextColor3 = Color3.fromRGB(200, 200, 210)
end)

carPage.Visible = true
tabCar.TextColor3 = themes.Default.accent

local visible = false
frame.Visible = false
blur.Size = 0

local nzbhButton = Instance.new("TextButton")
nzbhButton.Name = "NZBHButton"
nzbhButton.Size = UDim2.new(0, 80, 0, 80)
nzbhButton.Position = UDim2.new(0, 10, 0.5, -40)
nzbhButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
nzbhButton.BackgroundTransparency = 0.08
nzbhButton.Parent = guiParent
nzbhButton.ZIndex = 999

local btnCorner = Instance.new("UICorner", nzbhButton)
btnCorner.CornerRadius = UDim.new(0, 14)

local btnStroke = Instance.new("UIStroke", nzbhButton)
btnStroke.Color = themes.Default.stroke
btnStroke.Thickness = 2
btnStroke.Transparency = 0.4

local btnGlow = Instance.new("UIStroke", nzbhButton)
btnGlow.Color = themes.Default.stroke
btnGlow.Thickness = 8
btnGlow.Transparency = 0.8

local btnGrad = Instance.new("UIGradient", nzbhButton)
btnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})

local btnLabel = Instance.new("TextLabel")
btnLabel.Size = UDim2.new(1, 0, 1, 0)
btnLabel.Position = UDim2.new(0, 0, 0, 0)
btnLabel.Text = "NZ-BH"
btnLabel.TextColor3 = themes.Default.accent
btnLabel.TextSize = 18
btnLabel.Font = Enum.Font.GothamBold
btnLabel.BackgroundTransparency = 1
btnLabel.Parent = nzbhButton

local function toggleMenu()
    isOpen = not isOpen
    if isOpen then
        frame.Visible = true
        frame.Size = UDim2.new(0, 0, 0, 0)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 520, 0, 380),
            Position = UDim2.new(0.5, -260, 0.5, -190)
        }):Play()
        blur.Size = 6
    else
        TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.2)
        frame.Visible = false
        blur.Size = 0
    end
end

nzbhButton.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleMenu()
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