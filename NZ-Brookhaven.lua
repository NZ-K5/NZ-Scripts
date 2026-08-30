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
local flyActive = false
local noclipConnections = {}
local flyConnection = nil
local flySpeed = 50
local originalCollision = {}

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 520, 0, 460)
frame.Position = UDim2.new(0.5, -260, 0.5, -230)
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
        if flyConnection then
            pcall(function() flyConnection:Disconnect() end)
            flyConnection = nil
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
    pg.CanvasSize = UDim2.new(0, 0, 0, 420)
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
yOff = yOff + 40

makeLabel("Noclip (Walls Only)", yOff, carPage)
local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0, 120, 0, 30)
noclipBtn.Position = UDim2.new(0, 180, 0, yOff)
noclipBtn.Text = "OFF"
noclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
noclipBtn.TextSize = 14
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
noclipBtn.Parent = carPage
local noclipCorner = Instance.new("UICorner", noclipBtn)
noclipCorner.CornerRadius = UDim.new(0, 4)
yOff = yOff + 40

makeLabel("Fly (Q Up / E Down)", yOff, carPage)
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 120, 0, 30)
flyBtn.Position = UDim2.new(0, 180, 0, yOff)
flyBtn.Text = "OFF"
flyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
flyBtn.TextSize = 14
flyBtn.Font = Enum.Font.GothamBold
flyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
flyBtn.Parent = carPage
local flyCorner = Instance.new("UICorner", flyBtn)
flyCorner.CornerRadius = UDim.new(0, 4)
yOff = yOff + 40

makeLabel("Fly Speed", yOff, carPage)
local flySpeedBox = makeBox(yOff, carPage, "50")
local flySpeedApply = makeApply(yOff, carPage, "Set")
flySpeedApply.Size = UDim2.new(0, 60, 0, 30)
flySpeedApply.Position = UDim2.new(0, 310, 0, yOff)
flySpeedApply.Text = "Set"
yOff = yOff + 40

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
yOff = yOff + 45

carPage.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)

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
    for _, conn in pairs(noclipConnections) do
        pcall(function() conn:Disconnect() end)
    end
    if flyConnection then
        pcall(function() flyConnection:Disconnect() end)
        flyConnection = nil
    end
    root:Destroy()
    blur:Destroy()
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
            if child:IsA("TextButton") and child ~= closeBtn and child ~= deleteBtn and child ~= minimizeBtn and child ~= noclipBtn and child ~= flyBtn and child ~= flySpeedApply then
                if child.Text == "Apply" or child.Text == "Car Modded Customization" or child.Text == "Set" then
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
        deleteBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        deleteBtn.TextColor3 = t.danger
        if noclipActive then
            noclipBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
            noclipBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            noclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if flyActive then
            flyBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
            flyBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            flyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            flyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
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
    originalCollision = {}
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
        for _, conn in pairs(noclipConnections) do
            pcall(function() conn:Disconnect() end)
        end
        noclipConnections = {}
        noclipActive = false
        noclipBtn.Text = "OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        noclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if flyConnection then
            pcall(function() flyConnection:Disconnect() end)
            flyConnection = nil
        end
        flyActive = false
        flyBtn.Text = "OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        flyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        originalCollision = {}
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
    if not carModel then
        return
    end
    
    noclipActive = not noclipActive
    
    if noclipActive then
        noclipBtn.Text = "ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        noclipBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        originalCollision = {}
        for _, part in pairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCollision[part] = {
                    collide = part.CanCollide,
                    touch = part.CanTouch
                }
                local conn = part.Touched:Connect(function(hit)
                    if hit and hit:IsA("BasePart") and hit.Parent ~= carModel then
                        local char = player.Character
                        if char and char:FindFirstChild("Humanoid") then
                            local rootPart = char:FindFirstChild("HumanoidRootPart")
                            if rootPart and rootPart.Parent == part.Parent then
                                return
                            end
                        end
                        if hit.Name == "Floor" or hit.Name == "Ground" or hit:IsA("Terrain") then
                            return
                        end
                        if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
                            return
                        end
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

flySpeedApply.MouseButton1Click:Connect(function()
    local speed = tonumber(flySpeedBox.Text)
    if speed and speed > 0 then
        flySpeed = speed
    end
end)

local function toggleFly()
    if not carModel then
        return
    end
    
    flyActive = not flyActive
    
    if flyActive then
        flyBtn.Text = "ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        flyBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        if flyConnection then
            pcall(function() flyConnection:Disconnect() end)
            flyConnection = nil
        end
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not carModel or not flyActive then
                return
            end
            
            local char = player.Character
            if not char then return end
            
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then return end
            
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local moveDirection = humanoid.MoveDirection
            local lookVector = rootPart.CFrame.LookVector
            
            local forward = lookVector * (moveDirection.Z * flySpeed)
            local right = rootPart.CFrame.RightVector * (moveDirection.X * flySpeed)
            local up = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                up = Vector3.new(0, flySpeed, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.E) then
                up = Vector3.new(0, -flySpeed, 0)
            end
            
            local velocity = forward + right + up
            
            if velocity.Magnitude > 0 then
                local carRoot = carModel:FindFirstChild("HumanoidRootPart") or carModel:FindFirstChildWhichIsA("BasePart")
                if carRoot then
                    carRoot.Velocity = velocity
                    carRoot.CFrame = carRoot.CFrame + velocity * 0.016
                end
                
                for _, part in pairs(carModel:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= carRoot then
                        part.Velocity = velocity
                    end
                end
            end
        end)
    else
        flyBtn.Text = "OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        flyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        if flyConnection then
            pcall(function() flyConnection:Disconnect() end)
            flyConnection = nil
        end
        
        for _, part in pairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

flyBtn.MouseButton1Click:Connect(toggleFly)

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

local function minimizeGUI()
    isMinimized = true
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(0.5, -100, 0.5, -20)
    tabContainer.Visible = false
    carPage.Visible = false
    otherPage.Visible = false
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
    frame.Size = UDim2.new(0, 520, 0, 460)
    frame.Position = UDim2.new(0.5, -260, 0.5, -230)
    tabContainer.Visible = true
    carPage.Visible = true
    otherPage.Visible = false
    themePage.Visible = false
    closeBtn.Visible = true
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    titleLabel.Text = "NZ-Brookhaven"
    titleLabel.TextSize = 18
    blur.Size = 6
    tabCar.TextColor3 = themes[currentTheme].accent
    tabOther.TextColor3 = Color3.fromRGB(200, 200, 210)
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
