-- NZ-INFSmile.lua - WORKING VERSION (based on your original)
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
root.IgnoreGuiInset = true -- Mobile fix

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 6

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
frame.Size = UDim2.new(0, 580, 0, 420)
frame.Position = UDim2.new(0.5, -290, 0.5, -210)
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

-- ===== TITLE BAR =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.Text = "NZ Infectious Smile"
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
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 50, 80)
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

-- Close button functionality (with confirm)
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
        if infectConnection then pcall(function() infectConnection:Disconnect() end); infectConnection = nil end
        if killConnection then pcall(function() killConnection:Disconnect() end); killConnection = nil end
        if doorsConnection then pcall(function() doorsConnection:Disconnect() end); doorsConnection = nil end
        if espConnection then pcall(function() espConnection:Disconnect() end); espConnection = nil end
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

    confirm.MouseButton1Click:Connect(destroyAll)
    confirm.TouchTap:Connect(destroyAll)
    task.wait(3)
    confirm:Destroy()
end)

-- ===== TABS =====
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
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BackgroundTransparency = 0.3
    btn.Parent = tabContainer
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end

local tabMods = createTab("Mods", 0)
local tabOthers = createTab("Others", 160)

-- ===== PAGES =====
local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -20, 1, -95)
    pg.Position = UDim2.new(0, 10, 0, 85)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 350)
    pg.ScrollBarThickness = 4
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local modsPage = createPage()
local othersPage = createPage()

-- ===== UI HELPERS =====
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

local function makeToggle(y, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 28)
    btn.Position = UDim2.new(0, 220, 0, y)
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

local function makeButton(text, y, parent, color)
    color = color or Color3.fromRGB(60, 30, 30)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 0, 35)
    btn.Position = UDim2.new(0.5, -75, 0, y)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = color
    btn.Parent = parent
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end

-- ===== MODS PAGE =====
local yOff = 10

makeLabel("Delete Infected Parts", yOff, modsPage, 170)
local infectBtn = makeToggle(yOff, modsPage)
yOff = yOff + 38

makeLabel("Disable Kill Parts/Scripts", yOff, modsPage, 170)
local killBtn = makeToggle(yOff, modsPage)
yOff = yOff + 38

makeLabel("Disable Doors/Gates", yOff, modsPage, 170)
local doorsBtn = makeToggle(yOff, modsPage)
yOff = yOff + 38

makeLabel("TEAM ESP", yOff, modsPage, 170)
local espBtn = makeToggle(yOff, modsPage)
yOff = yOff + 42

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, yOff)
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = modsPage
yOff = yOff + 40

modsPage.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)

-- ===== OTHERS PAGE =====
local oY = 20

local destroyBtn = makeButton("Destroy GUI", oY, othersPage, Color3.fromRGB(80, 20, 20))
oY = oY + 50

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, -20, 0, 25)
creditLabel.Position = UDim2.new(0, 0, 0, oY)
creditLabel.Text = "NZ-IS v6"
creditLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
creditLabel.TextSize = 12
creditLabel.Font = Enum.Font.Gotham
creditLabel.BackgroundTransparency = 1
creditLabel.TextXAlignment = Enum.TextXAlignment.Center
creditLabel.Parent = othersPage
oY = oY + 35

othersPage.CanvasSize = UDim2.new(0, 0, 0, oY + 20)

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
    if not deleteInfectActive then
        restoreInfect()
        return
    end
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
        statusLabel.Text = "Deleted " .. #found .. " infected parts"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif deleteInfectActive then
        statusLabel.Text = "No infected parts found"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

local function scanAndDeleteKill()
    if not deleteKillActive then
        restoreKill()
        return
    end
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
    if not deleteDoorsActive then
        restoreDoors()
        return
    end
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
        statusLabel.Text = "Scanning for infected parts..."
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
        statusLabel.Text = "Infected parts restored"
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
        statusLabel.Text = "Scanning for kill parts..."
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
        statusLabel.Text = "Kill parts restored"
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
        statusLabel.Text = "Scanning for doors/gates..."
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
        statusLabel.Text = "Doors/gates restored"
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

-- ===== DESTROY BUTTON =====
destroyBtn.MouseButton1Click:Connect(function()
    if infectConnection then pcall(function() infectConnection:Disconnect() end) end
    if killConnection then pcall(function() killConnection:Disconnect() end) end
    if doorsConnection then pcall(function() doorsConnection:Disconnect() end) end
    if espConnection then pcall(function() espConnection:Disconnect() end) end
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
end)

destroyBtn.TouchTap:Connect(function()
    if infectConnection then pcall(function() infectConnection:Disconnect() end) end
    if killConnection then pcall(function() killConnection:Disconnect() end) end
    if doorsConnection then pcall(function() doorsConnection:Disconnect() end) end
    if espConnection then pcall(function() espConnection:Disconnect() end) end
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
end)

-- ===== TAB SWITCHING =====
tabMods.MouseButton1Click:Connect(function()
    modsPage.Visible = true
    othersPage.Visible = false
    tabMods.TextColor3 = themes[currentTheme].accent
    tabOthers.TextColor3 = Color3.fromRGB(180, 180, 210)
    TweenService:Create(tabMods, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

tabMods.TouchTap:Connect(function()
    modsPage.Visible = true
    othersPage.Visible = false
    tabMods.TextColor3 = themes[currentTheme].accent
    tabOthers.TextColor3 = Color3.fromRGB(180, 180, 210)
    TweenService:Create(tabMods, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

tabOthers.MouseButton1Click:Connect(function()
    modsPage.Visible = false
    othersPage.Visible = true
    tabOthers.TextColor3 = themes[currentTheme].accent
    tabMods.TextColor3 = Color3.fromRGB(180, 180, 210)
    TweenService:Create(tabOthers, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

tabOthers.TouchTap:Connect(function()
    modsPage.Visible = false
    othersPage.Visible = true
    tabOthers.TextColor3 = themes[currentTheme].accent
    tabMods.TextColor3 = Color3.fromRGB(180, 180, 210)
    TweenService:Create(tabOthers, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

modsPage.Visible = true
tabMods.TextColor3 = themes.Default.accent
tabMods.BackgroundTransparency = 0

-- ===== MINIMIZE FUNCTIONS =====
local function minimizeGUI()
    isMinimized = true
    frame.Size = UDim2.new(0, 180, 0, 40)
    frame.Position = UDim2.new(0.5, -90, 0.5, -20)
    tabContainer.Visible = false
    modsPage.Visible = false
    othersPage.Visible = false
    closeBtn.Visible = true
    minimizeBtn.Text = "+"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 50, 80)
    titleLabel.Text = "NZ-IS"
    titleLabel.TextSize = 16
    blur.Size = 0
end

local function maximizeGUI()
    isMinimized = false
    frame.Size = UDim2.new(0, 580, 0, 420)
    frame.Position = UDim2.new(0.5, -290, 0.5, -210)
    tabContainer.Visible = true
    modsPage.Visible = true
    othersPage.Visible = false
    closeBtn.Visible = true
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    titleLabel.Text = "NZ Infectious Smile"
    titleLabel.TextSize = 18
    blur.Size = 6
    tabMods.TextColor3 = themes[currentTheme].accent
    tabOthers.TextColor3 = Color3.fromRGB(180, 180, 210)
end

minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then maximizeGUI() else minimizeGUI() end
end)

minimizeBtn.TouchTap:Connect(function()
    if isMinimized then maximizeGUI() else minimizeGUI() end
end)

-- ===== DRAG SYSTEM =====
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

-- ===== HOTKEY =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if isMinimized then maximizeGUI() else minimizeGUI() end
    end
end)

-- ===== THEME BUTTONS =====
local themeContainer = Instance.new("Frame")
themeContainer.Size = UDim2.new(0, 220, 0, 30)
themeContainer.Position = UDim2.new(0.5, -110, 0, 82)
themeContainer.BackgroundTransparency = 1
themeContainer.Parent = frame

local function addThemeButton(name, color, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 38, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name:sub(1,1)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = color
    btn.Parent = themeContainer
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        statusLabel.TextColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minimizeBtn and child ~= infectBtn and child ~= killBtn and child ~= doorsBtn and child ~= espBtn and child ~= destroyBtn then
                if child.Text == "Mods" or child.Text == "Others" then
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
        if deleteDoorsActive then
            doorsBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
            doorsBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            doorsBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            doorsBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if espActive then
            espBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
            espBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            espBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            espBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)

    btn.TouchTap:Connect(function()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        statusLabel.TextColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minimizeBtn and child ~= infectBtn and child ~= killBtn and child ~= doorsBtn and child ~= espBtn and child ~= destroyBtn then
                if child.Text == "Mods" or child.Text == "Others" then
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
        if deleteDoorsActive then
            doorsBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
            doorsBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            doorsBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            doorsBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if espActive then
            espBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
            espBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            espBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            espBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    return btn
end

local themeColors2 = {
    {name = "Default", color = Color3.fromRGB(30, 20, 25)},
    {name = "Crimson", color = Color3.fromRGB(35, 15, 20)},
    {name = "Cyber", color = Color3.fromRGB(10, 15, 40)},
    {name = "Amber", color = Color3.fromRGB(35, 25, 15)},
    {name = "Violet", color = Color3.fromRGB(25, 15, 40)}
}

local tx = 0
for _, t in pairs(themeColors2) do
    addThemeButton(t.name, t.color, tx)
    tx = tx + 44
end

-- ===== FORCE VISIBILITY =====
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 580, 0, 420),
    BackgroundTransparency = 0.08
}):Play()
blur.Size = 6

print("NZ-IS v6 - LOADED SUCCESSFULLY!")
