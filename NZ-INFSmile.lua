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
local isMinimized = false
local isOpen = true

-- Mods
local deleteInfectActive = false
local deleteKillActive = false
local deleteDoorsActive = false
local deleteAntiHackActive = false
local espActive = false

local deletedInfect = {}
local deletedKill = {}
local deletedDoors = {}
local deletedAntiHack = {}
local espObjects = {}
local espRebindTimer = nil
local espConnection = nil

-- ===== MAIN FRAME =====
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 230)
frame.Position = UDim2.new(0.5, -140, 0.5, -115)
frame.BackgroundColor3 = themes.Default.background
frame.BackgroundTransparency = 0.08
frame.ClipsDescendants = true
frame.Parent = root
frame.Visible = true
frame.ZIndex = 10

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = themes.Default.stroke
stroke.Thickness = 1.5
stroke.Transparency = 0.6

-- ===== MINI SQUARE =====
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 50, 0, 50)
miniBtn.Position = UDim2.new(1, -60, 0, 10)
miniBtn.Text = "NZ"
miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtn.TextSize = 13
miniBtn.Font = Enum.Font.GothamBold
miniBtn.BackgroundColor3 = themes.Default.accent
miniBtn.BackgroundTransparency = 0.15
miniBtn.Parent = root
miniBtn.Visible = false
miniBtn.ZIndex = 999
miniBtn.AutoButtonColor = true

local miniCorner = Instance.new("UICorner", miniBtn)
miniCorner.CornerRadius = UDim.new(0, 12)

local miniStroke = Instance.new("UIStroke", miniBtn)
miniStroke.Color = themes.Default.accent
miniStroke.Thickness = 2
miniStroke.Transparency = 0.3

-- ===== RE-OPEN BUTTON =====
local reopenBtn = Instance.new("TextButton")
reopenBtn.Size = UDim2.new(0, 50, 0, 50)
reopenBtn.Position = UDim2.new(0, 10, 1, -65)
reopenBtn.Text = "▶"
reopenBtn.TextSize = 22
reopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reopenBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
reopenBtn.BackgroundTransparency = 0.2
reopenBtn.Parent = root
reopenBtn.Visible = false
reopenBtn.ZIndex = 999
reopenBtn.AutoButtonColor = true

local reopenCorner = Instance.new("UICorner", reopenBtn)
reopenCorner.CornerRadius = UDim.new(1, 0)

local reopenStroke = Instance.new("UIStroke", reopenBtn)
reopenStroke.Color = Color3.fromRGB(255, 255, 255)
reopenStroke.Thickness = 2
reopenStroke.Transparency = 0.2

-- ===== TITLE BAR =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame
titleBar.Active = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.Text = "NZ-IS"
titleLabel.TextColor3 = themes.Default.accent
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
minimizeBtn.Position = UDim2.new(1, -62, 0, 3)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
minimizeBtn.BackgroundTransparency = 0.2
minimizeBtn.Parent = titleBar
local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 5)

-- Close/Re-Open Button (inside GUI)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 3)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 5)

-- ===== TABS =====
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 26)
tabContainer.Position = UDim2.new(0, 5, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local function createTab(name, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 1, 0)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BackgroundTransparency = 0.3
    btn.Parent = tabContainer
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 5)
    return btn
end

local tabMods = createTab("Mods", 0)
local tabTheme = createTab("Theme", 90)
local tabOthers = createTab("Others", 180)

-- ===== PAGES =====
local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -74)
    pg.Position = UDim2.new(0, 5, 0, 65)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 250)
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = themes.Default.accent
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local modsPage = createPage()
local themePage = createPage()
local othersPage = createPage()

-- ===== UI HELPERS =====
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
    btn.Position = UDim2.new(0, 160, 0, y)
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

local function makeButton(text, y, parent, color)
    color = color or Color3.fromRGB(60, 30, 30)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 30)
    btn.Position = UDim2.new(0.5, -70, 0, y)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = color
    btn.Parent = parent
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end

local function makeThemeButton(name, y, color)
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

    btn.MouseButton1Click:Connect(function()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        statusLabel.TextColor3 = t.accent
        miniBtn.BackgroundColor3 = t.accent
        miniStroke.Color = t.accent
        reopenBtn.BackgroundColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minimizeBtn and child ~= infectBtn and child ~= killBtn and child ~= doorsBtn and child ~= antiHackBtn and child ~= espBtn then
                if child.Text == "Mods" or child.Text == "Theme" or child.Text == "Others" then
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
    end)

    btn.TouchTap:Connect(function()
        currentTheme = name
        local t = themes[name]
        frame.BackgroundColor3 = t.background
        stroke.Color = t.stroke
        titleLabel.TextColor3 = t.accent
        statusLabel.TextColor3 = t.accent
        miniBtn.BackgroundColor3 = t.accent
        miniStroke.Color = t.accent
        reopenBtn.BackgroundColor3 = t.accent
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minimizeBtn and child ~= infectBtn and child ~= killBtn and child ~= doorsBtn and child ~= antiHackBtn and child ~= espBtn then
                if child.Text == "Mods" or child.Text == "Theme" or child.Text == "Others" then
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
    end)

    return btn
end

-- ===== MODS PAGE =====
local yOff = 4

makeLabel("Delete Infected", yOff, modsPage, 110)
local infectBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable Kill", yOff, modsPage, 110)
local killBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable Doors/Gates", yOff, modsPage, 110)
local doorsBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable Anti-Hack", yOff, modsPage, 110)
local antiHackBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("TEAM ESP", yOff, modsPage, 110)
local espBtn = makeToggle(yOff, modsPage)
yOff = yOff + 32

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 22)
statusLabel.Position = UDim2.new(0, 0, 0, yOff)
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamBold
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = modsPage
yOff = yOff + 28

modsPage.CanvasSize = UDim2.new(0, 0, 0, yOff + 10)

-- ===== THEME PAGE =====
local themeY = 8
local themeLabel = Instance.new("TextLabel")
themeLabel.Size = UDim2.new(1, -10, 0, 24)
themeLabel.Position = UDim2.new(0, 0, 0, themeY)
themeLabel.Text = "SELECT THEME"
themeLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
themeLabel.TextSize = 12
themeLabel.Font = Enum.Font.GothamBold
themeLabel.BackgroundTransparency = 1
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.Parent = themePage
themeY = themeY + 30

local themeColors = {
    {name = "Default", color = Color3.fromRGB(30, 20, 25)},
    {name = "Crimson", color = Color3.fromRGB(35, 15, 20)},
    {name = "Cyber", color = Color3.fromRGB(10, 15, 40)},
    {name = "Amber", color = Color3.fromRGB(35, 25, 15)},
    {name = "Violet", color = Color3.fromRGB(25, 15, 40)}
}

for _, t in ipairs(themeColors) do
    makeThemeButton(t.name, themeY, t.color)
    themeY = themeY + 34
end

themePage.CanvasSize = UDim2.new(0, 0, 0, themeY + 10)

-- ===== OTHERS PAGE =====
local oY = 20

local destroyBtn = makeButton("Destroy GUI", oY, othersPage, Color3.fromRGB(80, 20, 20))
oY = oY + 40

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, -10, 0, 20)
creditLabel.Position = UDim2.new(0, 0, 0, oY)
creditLabel.Text = "NZ-IS v6"
creditLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
creditLabel.TextSize = 10
creditLabel.Font = Enum.Font.Gotham
creditLabel.BackgroundTransparency = 1
creditLabel.TextXAlignment = Enum.TextXAlignment.Center
creditLabel.Parent = othersPage
oY = oY + 30

othersPage.CanvasSize = UDim2.new(0, 0, 0, oY + 10)

-- ===== DELETE FUNCTIONS =====
local function deleteItems(found, storage)
    for _, v in pairs(found) do
        if v and v.Parent then
            table.insert(storage, {Item = v, Parent = v.Parent})
            pcall(function() v.Parent = nil end)
        end
    end
end

local function restoreItems(storage)
    local count = 0
    local toRemove = {}
    for i, data in pairs(storage) do
        if data and data.Item and not data.Item.Parent then
            pcall(function()
                if data.Parent and data.Parent ~= nil then
                    data.Item.Parent = data.Parent
                else
                    data.Item.Parent = Workspace
                end
                count = count + 1
                table.insert(toRemove, i)
            end)
        else
            table.insert(toRemove, i)
        end
    end
    table.sort(toRemove, function(a, b) return a > b end)
    for _, i in pairs(toRemove) do
        table.remove(storage, i)
    end
    return count
end

-- INFECTED
local function restoreInfect() local c = restoreItems(deletedInfect); if c > 0 then statusLabel.Text = "Restored "..c.." infected"; statusLabel.TextColor3 = Color3.fromRGB(0,255,150) else statusLabel.Text = "No infected to restore"; statusLabel.TextColor3 = Color3.fromRGB(255,200,50) end return c end
local function scanAndDeleteInfect()
    if not deleteInfectActive then restoreInfect(); return end
    local found = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name and string.lower(v.Name):find("infect") then table.insert(found, v) end
        end
    end
    deleteItems(found, deletedInfect)
    if #found > 0 then statusLabel.Text, statusLabel.TextColor3 = "Deleted "..#found.." infected", Color3.fromRGB(255,200,50) else statusLabel.Text, statusLabel.TextColor3 = "No infected found", Color3.fromRGB(0,255,150) end
end

-- KILL
local function restoreKill() local c = restoreItems(deletedKill); if c > 0 then statusLabel.Text = "Restored "..c.." kill items"; statusLabel.TextColor3 = Color3.fromRGB(0,255,150) else statusLabel.Text = "No kill items to restore"; statusLabel.TextColor3 = Color3.fromRGB(255,200,50) end return c end
local function scanAndDeleteKill()
    if not deleteKillActive then restoreKill(); return end
    local found = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            if v.Name and string.lower(v.Name):find("kill") then table.insert(found, v) end
        end
    end
    deleteItems(found, deletedKill)
    if #found > 0 then statusLabel.Text, statusLabel.TextColor3 = "Deleted "..#found.." kill items", Color3.fromRGB(255,200,50) else statusLabel.Text, statusLabel.TextColor3 = "No kill items found", Color3.fromRGB(0,255,150) end
end

-- DOORS
local function restoreDoors() local c = restoreItems(deletedDoors); if c > 0 then statusLabel.Text = "Restored "..c.." doors/gates"; statusLabel.TextColor3 = Color3.fromRGB(0,255,150) else statusLabel.Text = "No doors/gates to restore"; statusLabel.TextColor3 = Color3.fromRGB(255,200,50) end return c end
local function scanAndDeleteDoors()
    if not deleteDoorsActive then restoreDoors(); return end
    local found = {}
    local keywords = {"door","gate","portal","doorway","entrance","exit"}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") and v.Name then
            local nl = string.lower(v.Name)
            for _, kw in pairs(keywords) do if nl:find(kw) then table.insert(found, v); break end end
        end
    end
    deleteItems(found, deletedDoors)
    if #found > 0 then statusLabel.Text, statusLabel.TextColor3 = "Deleted "..#found.." doors/gates", Color3.fromRGB(255,200,50) else statusLabel.Text, statusLabel.TextColor3 = "No doors/gates found", Color3.fromRGB(0,255,150) end
end

-- ANTI-HACK
local function restoreAntiHack() local c = restoreItems(deletedAntiHack); if c > 0 then statusLabel.Text = "Restored "..c.." anti-hack items"; statusLabel.TextColor3 = Color3.fromRGB(0,255,150) else statusLabel.Text = "No anti-hack items to restore"; statusLabel.TextColor3 = Color3.fromRGB(255,200,50) end return c end
local function scanAndDeleteAntiHack()
    if not deleteAntiHackActive then restoreAntiHack(); return end
    local found = {}
    local keywords = {"anti","hack","anticheat","anti-cheat","cheat","exploit","bypass","security"}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") and v.Name then
            local nl = string.lower(v.Name)
            for _, kw in pairs(keywords) do if nl:find(kw) then table.insert(found, v); break end end
        end
    end
    deleteItems(found, deletedAntiHack)
    if #found > 0 then statusLabel.Text, statusLabel.TextColor3 = "Deleted "..#found.." anti-hack items", Color3.fromRGB(255,200,50) else statusLabel.Text, statusLabel.TextColor3 = "No anti-hack items found", Color3.fromRGB(0,255,150) end
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

    if espObjects[target] then
        pcall(function()
            if espObjects[target].H then espObjects[target].H:Destroy() end
            if espObjects[target].B then espObjects[target].B:Destroy() end
            if espObjects[target].N then espObjects[target].N:Destroy() end
            if espObjects[target].L then espObjects[target].L:Destroy() end
        end)
        espObjects[target] = nil
    end

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.2
    highlight.FillColor = teamColor
    highlight.OutlineColor = teamColor
    highlight.Parent = target.Character

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 30, 0, 60)
    box.Position = UDim2.new(0.5, -15, 0.5, -30)
    box.BackgroundTransparency = 0.3
    box.BackgroundColor3 = teamColor
    box.BorderSizePixel = 2
    box.BorderColor3 = teamColor
    box.Parent = root
    box.Visible = true
    box.ZIndex = 999

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 150, 0, 20)
    nameLabel.Position = UDim2.new(0.5, -75, 0.5, -50)
    nameLabel.Text = target.Name
    nameLabel.TextColor3 = teamColor
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = root
    nameLabel.Visible = true
    nameLabel.ZIndex = 999

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 1, 0, 1)
    line.BackgroundTransparency = 0.4
    line.BackgroundColor3 = teamColor
    line.Parent = root
    line.Visible = true
    line.ZIndex = 999

    espObjects[target] = {H = highlight, B = box, N = nameLabel, L = line, R = rootPart, C = target.Character}
end

local function updateEsp()
    if not espActive then
        for _, d in pairs(espObjects) do
            pcall(function()
                if d.H then d.H:Destroy() end
                if d.B then d.B:Destroy() end
                if d.N then d.N:Destroy() end
                if d.L then d.L:Destroy() end
            end)
        end
        espObjects = {}
        return
    end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myPos = char.HumanoidRootPart.Position

    for _, target in pairs(Players:GetPlayers()) do
        if target == player then
            if espObjects[player] == nil then
                local selfLine = Instance.new("Frame")
                selfLine.Size = UDim2.new(0, 1, 0, 1)
                selfLine.BackgroundTransparency = 0.4
                selfLine.BackgroundColor3 = getTeamColor(player)
                selfLine.Parent = root
                selfLine.Visible = true
                selfLine.ZIndex = 999
                espObjects[player] = {L = selfLine, R = char.HumanoidRootPart, C = char}
            end
            if espObjects[player] and espObjects[player].L and espObjects[player].R then
                local sp, os = Camera:WorldToViewportPoint(espObjects[player].R.Position)
                if os then
                    local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    local dx, dy = sp.X - sc.X, sp.Y - sc.Y
                    local a = math.atan2(dy, dx)
                    local len = math.clamp(math.sqrt(dx^2 + dy^2), 20, 300)
                    espObjects[player].L.Size = UDim2.new(0, len, 0, 2)
                    espObjects[player].L.Position = UDim2.new(0, sc.X, 0, sc.Y)
                    espObjects[player].L.Rotation = math.deg(a)
                    espObjects[player].L.BackgroundTransparency = 0.3
                    espObjects[player].L.Visible = true
                end
            end
            goto continue
        end

        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[target] or espObjects[target].C ~= target.Character then
                createEsp(target)
            end

            local data = espObjects[target]
            if data and data.R then
                local targetPos = data.R.Position
                local dist = (myPos - targetPos).Magnitude
                local sp, os = Camera:WorldToViewportPoint(targetPos)

                if os then
                    local bs = math.clamp(80 / dist, 20, 80)
                    data.B.Size = UDim2.new(0, bs, 0, bs * 1.8)
                    data.B.Position = UDim2.new(0, sp.X - bs/2, 0, sp.Y - bs * 0.9)
                    data.B.BackgroundTransparency = 0.3
                    data.B.Visible = true

                    data.N.Position = UDim2.new(0, sp.X - 75, 0, sp.Y - bs * 1.1 - 20)
                    data.N.Visible = true

                    data.H.FillTransparency = 0.5
                    data.H.OutlineTransparency = 0.2

                    local cx, cy = sp.X, sp.Y + bs * 0.5
                    local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    local dx, dy = cx - sc.X, cy - sc.Y
                    local a = math.atan2(dy, dx)
                    local len = math.clamp(math.sqrt(dx^2 + dy^2), 20, 300)

                    data.L.Size = UDim2.new(0, len, 0, 2)
                    data.L.Position = UDim2.new(0, sc.X, 0, sc.Y)
                    data.L.Rotation = math.deg(a)
                    data.L.BackgroundTransparency = 0.3
                    data.L.Visible = true
                else
                    data.B.Visible = false
                    data.N.Visible = false
                    data.L.Visible = false
                    data.H.FillTransparency = 0.5
                    data.H.OutlineTransparency = 0.2
                end
            end
        end
        ::continue::
    end
end

-- ===== TOGGLES =====
local function toggleInfect()
    deleteInfectActive = not deleteInfectActive
    if deleteInfectActive then
        infectBtn.Text, infectBtn.BackgroundColor3, infectBtn.TextColor3, statusLabel.Text, statusLabel.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Scanning...", Color3.fromRGB(0,255,100)
        scanAndDeleteInfect()
    else
        infectBtn.Text, infectBtn.BackgroundColor3, infectBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        restoreInfect()
    end
end
infectBtn.MouseButton1Click:Connect(toggleInfect)
infectBtn.TouchTap:Connect(toggleInfect)

local function toggleKill()
    deleteKillActive = not deleteKillActive
    if deleteKillActive then
        killBtn.Text, killBtn.BackgroundColor3, killBtn.TextColor3, statusLabel.Text, statusLabel.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Scanning...", Color3.fromRGB(0,255,100)
        scanAndDeleteKill()
    else
        killBtn.Text, killBtn.BackgroundColor3, killBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        restoreKill()
    end
end
killBtn.MouseButton1Click:Connect(toggleKill)
killBtn.TouchTap:Connect(toggleKill)

local function toggleDoors()
    deleteDoorsActive = not deleteDoorsActive
    if deleteDoorsActive then
        doorsBtn.Text, doorsBtn.BackgroundColor3, doorsBtn.TextColor3, statusLabel.Text, statusLabel.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Scanning...", Color3.fromRGB(0,255,100)
        scanAndDeleteDoors()
    else
        doorsBtn.Text, doorsBtn.BackgroundColor3, doorsBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        restoreDoors()
    end
end
doorsBtn.MouseButton1Click:Connect(toggleDoors)
doorsBtn.TouchTap:Connect(toggleDoors)

local function toggleAntiHack()
    deleteAntiHackActive = not deleteAntiHackActive
    if deleteAntiHackActive then
        antiHackBtn.Text, antiHackBtn.BackgroundColor3, antiHackBtn.TextColor3, statusLabel.Text, statusLabel.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Scanning...", Color3.fromRGB(0,255,100)
        scanAndDeleteAntiHack()
    else
        antiHackBtn.Text, antiHackBtn.BackgroundColor3, antiHackBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        restoreAntiHack()
    end
end
antiHackBtn.MouseButton1Click:Connect(toggleAntiHack)
antiHackBtn.TouchTap:Connect(toggleAntiHack)

local function toggleEsp()
    espActive = not espActive
    if espActive then
        espBtn.Text, espBtn.BackgroundColor3, espBtn.TextColor3, statusLabel.Text, statusLabel.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "ESP ENABLED", Color3.fromRGB(0,200,255)

        if espConnection then pcall(function() espConnection:Disconnect() end); espConnection = nil end
        if espRebindTimer then pcall(function() espRebindTimer:Disconnect() end); espRebindTimer = nil end

        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player then createEsp(target) end
        end

        espConnection = RunService.RenderStepped:Connect(updateEsp)

        espRebindTimer = RunService.Heartbeat:Connect(function()
            if espActive then
                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= player then
                        if not espObjects[target] or espObjects[target].C ~= target.Character then
                            createEsp(target)
                        end
                    end
                end
            end
        end)

        Players.PlayerAdded:Connect(function(target)
            task.wait(0.5)
            if espActive then createEsp(target) end
        end)

        Players.PlayerRemoving:Connect(function(target)
            if espObjects[target] then
                pcall(function()
                    if espObjects[target].H then espObjects[target].H:Destroy() end
                    if espObjects[target].B then espObjects[target].B:Destroy() end
                    if espObjects[target].N then espObjects[target].N:Destroy() end
                    if espObjects[target].L then espObjects[target].L:Destroy() end
                end)
                espObjects[target] = nil
            end
        end)
    else
        espBtn.Text, espBtn.BackgroundColor3, espBtn.TextColor3, statusLabel.Text, statusLabel.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100), "ESP DISABLED", Color3.fromRGB(255,100,100)

        if espConnection then pcall(function() espConnection:Disconnect() end); espConnection = nil end
        if espRebindTimer then pcall(function() espRebindTimer:Disconnect() end); espRebindTimer = nil end

        for _, data in pairs(espObjects) do
            pcall(function()
                if data.H then data.H:Destroy() end
                if data.B then data.B:Destroy() end
                if data.N then data.N:Destroy() end
                if data.L then data.L:Destroy() end
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

-- ===== DESTROY GUI =====
local function destroyGUI()
    if espConnection then pcall(function() espConnection:Disconnect() end); espConnection = nil end
    if espRebindTimer then pcall(function() espRebindTimer:Disconnect() end); espRebindTimer = nil end
    for _, data in pairs(espObjects) do
        pcall(function()
            if data.H then data.H:Destroy() end
            if data.B then data.B:Destroy() end
            if data.N then data.N:Destroy() end
            if data.L then data.L:Destroy() end
        end)
    end
    espObjects = {}
    root:Destroy()
    blur:Destroy()
end
destroyBtn.MouseButton1Click:Connect(destroyGUI)
destroyBtn.TouchTap:Connect(destroyGUI)

-- ===== TAB SWITCHING =====
local function switchToMods()
    modsPage.Visible, themePage.Visible, othersPage.Visible = true, false, false
    tabMods.TextColor3, tabTheme.TextColor3, tabOthers.TextColor3 = themes[currentTheme].accent, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function switchToTheme()
    modsPage.Visible, themePage.Visible, othersPage.Visible = false, true, false
    tabTheme.TextColor3, tabMods.TextColor3, tabOthers.TextColor3 = themes[currentTheme].accent, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function switchToOthers()
    modsPage.Visible, themePage.Visible, othersPage.Visible = false, false, true
    tabOthers.TextColor3, tabMods.TextColor3, tabTheme.TextColor3 = themes[currentTheme].accent, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
tabMods.MouseButton1Click:Connect(switchToMods)
tabMods.TouchTap:Connect(switchToMods)
tabTheme.MouseButton1Click:Connect(switchToTheme)
tabTheme.TouchTap:Connect(switchToTheme)
tabOthers.MouseButton1Click:Connect(switchToOthers)
tabOthers.TouchTap:Connect(switchToOthers)
modsPage.Visible, tabMods.TextColor3 = true, themes.Default.accent

-- ===== MINIMIZE / RESTORE =====
local function minimizeGUI()
    if isMinimized then return end
    isMinimized = true
    frame.Visible, miniBtn.Visible, reopenBtn.Visible, blur.Size = false, true, false, 0
end
local function restoreGUI()
    if not isMinimized then return end
    isMinimized = false
    frame.Visible, miniBtn.Visible, blur.Size = true, false, 3
end
minimizeBtn.MouseButton1Click:Connect(function() if isMinimized then restoreGUI() else minimizeGUI() end end)
minimizeBtn.TouchTap:Connect(function() if isMinimized then restoreGUI() else minimizeGUI() end end)
miniBtn.MouseButton1Click:Connect(restoreGUI)
miniBtn.TouchTap:Connect(restoreGUI)
miniBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then restoreGUI() end end)

-- ===== CLOSE/RE-OPEN =====
local function toggleOpenClose()
    if isOpen then
        isOpen, frame.Visible, miniBtn.Visible, reopenBtn.Visible, closeBtn.Text, closeBtn.TextColor3, blur.Size = false, false, false, true, "▶", Color3.fromRGB(100,255,100), 0
    else
        isOpen, frame.Visible, reopenBtn.Visible, closeBtn.Text, closeBtn.TextColor3 = true, true, false, "X", Color3.fromRGB(200,200,210)
        if not isMinimized then blur.Size = 3 end
    end
end
closeBtn.MouseButton1Click:Connect(toggleOpenClose)
closeBtn.TouchTap:Connect(toggleOpenClose)

reopenBtn.MouseButton1Click:Connect(function()
    if not isOpen then
        isOpen, frame.Visible, reopenBtn.Visible, closeBtn.Text, closeBtn.TextColor3 = true, true, false, "X", Color3.fromRGB(200,200,210)
        if not isMinimized then blur.Size = 3 end
    end
end)
reopenBtn.TouchTap:Connect(function()
    if not isOpen then
        isOpen, frame.Visible, reopenBtn.Visible, closeBtn.Text, closeBtn.TextColor3 = true, true, false, "X", Color3.fromRGB(200,200,210)
        if not isMinimized then blur.Size = 3 end
    end
end)

-- ===== DRAG SYSTEM =====
local frameDragData = {isDragging = false, startPos = nil, frameStart = nil, hasMoved = false}
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        frameDragData.isDragging, frameDragData.hasMoved, frameDragData.startPos, frameDragData.frameStart = false, false, i.Position, frame.Position
    end
end)
titleBar.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        if frameDragData.startPos then
            local d = i.Position - frameDragData.startPos
            if math.sqrt(d.X^2 + d.Y^2) > 5 then frameDragData.hasMoved, frameDragData.isDragging = true, true end
            if frameDragData.isDragging then frame.Position = UDim2.new(frameDragData.frameStart.X.Scale, frameDragData.frameStart.X.Offset + d.X, frameDragData.frameStart.Y.Scale, frameDragData.frameStart.Y.Offset + d.Y) end
        end
    end
end)
titleBar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then frameDragData.isDragging, frameDragData.startPos, frameDragData.frameStart = false, nil, nil end end)

local reopenDragData = {isDragging = false, startPos = nil, btnStart = nil, hasMoved = false}
reopenBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        reopenDragData.isDragging, reopenDragData.hasMoved, reopenDragData.startPos, reopenDragData.btnStart = false, false, i.Position, reopenBtn.Position
    end
end)
reopenBtn.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        if reopenDragData.startPos then
            local d = i.Position - reopenDragData.startPos
            if math.sqrt(d.X^2 + d.Y^2) > 10 then reopenDragData.hasMoved, reopenDragData.isDragging = true, true end
            if reopenDragData.isDragging then reopenBtn.Position = UDim2.new(reopenDragData.btnStart.X.Scale, reopenDragData.btnStart.X.Offset + d.X, reopenDragData.btnStart.Y.Scale, reopenDragData.btnStart.Y.Offset + d.Y) end
        end
    end
end)
reopenBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then reopenDragData.isDragging, reopenDragData.startPos, reopenDragData.btnStart = false, nil, nil end end)

-- ===== HOTKEY =====
UserInputService.InputBegan:Connect(function(i, gp) if gp then return end; if i.KeyCode == Enum.KeyCode.Insert then if isMinimized then restoreGUI() else minimizeGUI() end end end)

-- ===== FORCE VISIBILITY =====
frame.BackgroundTransparency, frame.Size = 1, UDim2.new(0,0,0,0)
TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 280, 0, 230),
    BackgroundTransparency = 0.08
}):Play()
blur.Size = 3

print("NZ-IS v6 - LOADED!")
