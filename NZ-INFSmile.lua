local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
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

local isOpen = true

-- Mods
local deleteInfectActive = false
local deleteKillActive = false
local deleteDoorsActive = false
local deleteAntiHackActive = false
local deleteSpearsActive = false
local deleteFireLavaActive = false
local deleteSeismicActive = false
local antiInfectionActive = false
local deleteOrbActive = false
local toolCooldownActive = false

local deletedInfect = {}
local deletedKill = {}
local deletedDoors = {}
local deletedAntiHack = {}
local deletedSpears = {}
local deletedFireLava = {}
local deletedSeismic = {}
local deletedOrb = {}
local duplicatedSadWater = nil
local originalSadWater = nil

-- ===== MAIN FRAME =====
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 320)
frame.Position = UDim2.new(0.5, -175, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
frame.BackgroundTransparency = 0.08
frame.ClipsDescendants = true
frame.Parent = root
frame.Visible = true
frame.ZIndex = 10

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 50, 80)
stroke.Thickness = 1.5
stroke.Transparency = 0.6

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
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.Text = "NZ-IS"
titleLabel.TextColor3 = Color3.fromRGB(255, 50, 80)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

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
    btn.Size = UDim2.new(0, 100, 1, 0)
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
local tabOthers = createTab("Others", 110)

-- ===== PAGES =====
local function createPage()
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, -10, 1, -74)
    pg.Position = UDim2.new(0, 5, 0, 65)
    pg.BackgroundTransparency = 1
    pg.CanvasSize = UDim2.new(0, 0, 0, 500)
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 80)
    pg.Parent = frame
    pg.Visible = false
    return pg
end

local modsPage = createPage()
local othersPage = createPage()

-- ===== UI HELPERS =====
local function makeLabel(text, y, parent, w)
    w = w or 100
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, w, 0, 22)
    l.Position = UDim2.new(0, 0, 0, y)
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220, 220, 230)
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
    btn.Position = UDim2.new(0, 200, 0, y)
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

makeLabel("Disable Spears", yOff, modsPage, 110)
local spearsBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable Fire/Lava", yOff, modsPage, 110)
local fireLavaBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Disable-SeismicFall", yOff, modsPage, 110)
local seismicBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Anti-Infection", yOff, modsPage, 110)
local antiInfectionBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

makeLabel("Delete Orb", yOff, modsPage, 110)
local deleteOrbBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

-- Tool Cooldown
makeLabel("Tool Cooldown", yOff, modsPage, 80)
local cooldownTextBox = Instance.new("TextBox")
cooldownTextBox.Size = UDim2.new(0, 80, 0, 22)
cooldownTextBox.Position = UDim2.new(0, 85, 0, yOff)
cooldownTextBox.PlaceholderText = "Seconds"
cooldownTextBox.Text = ""
cooldownTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
cooldownTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
cooldownTextBox.BackgroundTransparency = 0.3
cooldownTextBox.TextSize = 11
cooldownTextBox.Font = Enum.Font.Gotham
cooldownTextBox.Parent = modsPage
local cooldownCorner = Instance.new("UICorner", cooldownTextBox)
cooldownCorner.CornerRadius = UDim.new(0, 4)

local cooldownBtn = makeToggle(yOff, modsPage)
yOff = yOff + 28

-- TP to ToolCollector
makeLabel("TP to ToolCollector", yOff, modsPage, 80)
local tpTextBox = Instance.new("TextBox")
tpTextBox.Size = UDim2.new(0, 120, 0, 22)
tpTextBox.Position = UDim2.new(0, 85, 0, yOff)
tpTextBox.PlaceholderText = "Type model name..."
tpTextBox.Text = ""
tpTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
tpTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
tpTextBox.BackgroundTransparency = 0.3
tpTextBox.TextSize = 11
tpTextBox.Font = Enum.Font.Gotham
tpTextBox.Parent = modsPage
local tpCorner = Instance.new("UICorner", tpTextBox)
tpCorner.CornerRadius = UDim.new(0, 4)

-- TP Button
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0, 65, 0, 30)
tpBtn.Position = UDim2.new(0, 85, 0, yOff + 28)
tpBtn.Text = "TP →"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.TextSize = 12
tpBtn.Font = Enum.Font.GothamBold
tpBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
tpBtn.Parent = modsPage
tpBtn.AutoButtonColor = true
local tpCorner2 = Instance.new("UICorner", tpBtn)
tpCorner2.CornerRadius = UDim.new(0, 6)

-- Scan Collections Button
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0, 65, 0, 30)
scanBtn.Position = UDim2.new(0, 155, 0, yOff + 28)
scanBtn.Text = "Scan"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 12
scanBtn.Font = Enum.Font.GothamBold
scanBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 40)
scanBtn.Parent = modsPage
scanBtn.AutoButtonColor = true
local scanCorner = Instance.new("UICorner", scanBtn)
scanCorner.CornerRadius = UDim.new(0, 6)

yOff = yOff + 36

-- Collection List display
local collectionListLabel = Instance.new("TextLabel")
collectionListLabel.Size = UDim2.new(1, -10, 0, 60)
collectionListLabel.Position = UDim2.new(0, 0, 0, yOff)
collectionListLabel.Text = "Collection Models: None found"
collectionListLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
collectionListLabel.TextSize = 10
collectionListLabel.Font = Enum.Font.Gotham
collectionListLabel.BackgroundTransparency = 1
collectionListLabel.TextXAlignment = Enum.TextXAlignment.Left
collectionListLabel.TextYAlignment = Enum.TextYAlignment.Top
collectionListLabel.TextWrapped = true
collectionListLabel.Parent = modsPage
yOff = yOff + 68

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

-- SPEARS
local function restoreSpears() local c = restoreItems(deletedSpears); if c > 0 then statusLabel.Text = "Restored "..c.." spears"; statusLabel.TextColor3 = Color3.fromRGB(0,255,150) else statusLabel.Text = "No spears to restore"; statusLabel.TextColor3 = Color3.fromRGB(255,200,50) end return c end
local function scanAndDeleteSpears()
    if not deleteSpearsActive then restoreSpears(); return end
    local found = {}
    local keywords = {"spear","javelin","lance","pike","harpoon"}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") and v.Name then
            local nl = string.lower(v.Name)
            for _, kw in pairs(keywords) do if nl:find(kw) then table.insert(found, v); break end end
        end
    end
    deleteItems(found, deletedSpears)
    if #found > 0 then statusLabel.Text, statusLabel.TextColor3 = "Deleted "..#found.." spears", Color3.fromRGB(255,200,50) else statusLabel.Text, statusLabel.TextColor3 = "No spears found", Color3.fromRGB(0,255,150) end
end

-- FIRE/LAVA
local function restoreFireLava() local c = restoreItems(deletedFireLava); if c > 0 then statusLabel.Text = "Restored "..c.." fire/lava items"; statusLabel.TextColor3 = Color3.fromRGB(0,255,150) else statusLabel.Text = "No fire/lava items to restore"; statusLabel.TextColor3 = Color3.fromRGB(255,200,50) end return c end
local function scanAndDeleteFireLava()
    if not deleteFireLavaActive then restoreFireLava(); return end
    local found = {}
    local keywords = {"fire","lava","flame","burn","ignite","molten","magma","combust","pyro"}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") and v.Name then
            local nl = string.lower(v.Name)
            for _, kw in pairs(keywords) do if nl:find(kw) then table.insert(found, v); break end end
        end
    end
    deleteItems(found, deletedFireLava)
    if #found > 0 then statusLabel.Text, statusLabel.TextColor3 = "Deleted "..#found.." fire/lava items", Color3.fromRGB(255,200,50) else statusLabel.Text, statusLabel.TextColor3 = "No fire/lava items found", Color3.fromRGB(0,255,150) end
end

-- SEISMIC (deletes "seismic" AND "water" models)
local function restoreSeismic()
    local c = restoreItems(deletedSeismic)
    if c > 0 then
        statusLabel.Text = "Restored "..c.." seismic/water models"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        statusLabel.Text = "No seismic/water models to restore"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    end
    return c
end

local function scanAndDeleteSeismic()
    if not deleteSeismicActive then restoreSeismic(); return end
    local found = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name then
            local nl = string.lower(v.Name)
            if nl:find("seismic") or nl:find("water") then
                table.insert(found, v)
            end
        end
    end
    deleteItems(found, deletedSeismic)
    if #found > 0 then
        statusLabel.Text = "Deleted "..#found.." seismic/water models"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    else
        statusLabel.Text = "No seismic/water models found"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

-- ===== ANTI-INFECTION (FIXED SCALING) =====
local function enableAntiInfection()
    local sadWater = nil
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name and string.lower(v.Name):find("sadwater") then
            sadWater = v
            break
        end
    end
    
    if not sadWater then
        statusLabel.Text = "Error: SadWater not found!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return false
    end
    
    originalSadWater = sadWater
    
    local newSadWater = sadWater:Clone()
    newSadWater.Name = "SadWater_AntiInfection"
    newSadWater.Parent = Workspace
    
    local mapSize = 5000
    newSadWater.Size = Vector3.new(mapSize, mapSize, mapSize)
    newSadWater.Position = Vector3.new(0, 0, 0)
    newSadWater.CastShadow = false
    
    for _, child in pairs(newSadWater:GetDescendants()) do
        if child:IsA("BasePart") then
            child.Size = Vector3.new(mapSize, mapSize, mapSize)
            child.Position = Vector3.new(0, 0, 0)
            child.CastShadow = false
        end
    end
    
    duplicatedSadWater = newSadWater
    
    statusLabel.Text = "Anti-Infection ENABLED! (5000x5000x5000)"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    return true
end

local function disableAntiInfection()
    if duplicatedSadWater then
        duplicatedSadWater:Destroy()
        duplicatedSadWater = nil
    end
    originalSadWater = nil
    statusLabel.Text = "Anti-Infection DISABLED"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

local function toggleAntiInfection()
    antiInfectionActive = not antiInfectionActive
    if antiInfectionActive then
        antiInfectionBtn.Text = "ON"
        antiInfectionBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        antiInfectionBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        if not enableAntiInfection() then
            antiInfectionActive = false
            antiInfectionBtn.Text = "OFF"
            antiInfectionBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            antiInfectionBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    else
        antiInfectionBtn.Text = "OFF"
        antiInfectionBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        antiInfectionBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        disableAntiInfection()
    end
end

antiInfectionBtn.MouseButton1Click:Connect(toggleAntiInfection)
antiInfectionBtn.TouchTap:Connect(toggleAntiInfection)

-- ===== DELETE ORB =====
local function restoreOrb()
    local count = restoreItems(deletedOrb)
    if count > 0 then
        statusLabel.Text = "Restored " .. count .. " orbs"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        statusLabel.Text = "No orbs to restore"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    end
    return count
end

local function scanAndDeleteOrb()
    if not deleteOrbActive then restoreOrb(); return end
    local found = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name and string.lower(v.Name) == "orb" then
            table.insert(found, v)
        end
    end
    deleteItems(found, deletedOrb)
    if #found > 0 then
        statusLabel.Text = "Deleted " .. #found .. " orbs"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    else
        statusLabel.Text = "No orbs found"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

local function toggleDeleteOrb()
    deleteOrbActive = not deleteOrbActive
    if deleteOrbActive then
        deleteOrbBtn.Text = "ON"
        deleteOrbBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        deleteOrbBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Scanning..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        scanAndDeleteOrb()
    else
        deleteOrbBtn.Text = "OFF"
        deleteOrbBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        deleteOrbBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        restoreOrb()
    end
end

deleteOrbBtn.MouseButton1Click:Connect(toggleDeleteOrb)
deleteOrbBtn.TouchTap:Connect(toggleDeleteOrb)

-- ===== TOOL COOLDOWN (FIXED - checks Character too) =====
local function applyToolCooldown(value)
    local count = 0
    local containers = {
        player:FindFirstChild("Backpack"),
        player:FindFirstChild("Inventory"),
        player:FindFirstChild("Hotbar"),
        player:FindFirstChild("Character"),        -- Tools being held
        player:FindFirstChild("StarterGear")       -- Some games store tools here
    }
    
    for _, container in pairs(containers) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    local cooldownNum = tool:FindFirstChild("Cooldown")
                    if cooldownNum and cooldownNum:IsA("NumberValue") then
                        pcall(function()
                            cooldownNum.Value = value
                            count = count + 1
                        end)
                    end
                end
            end
        end
    end
    
    return count
end

local function toggleToolCooldown()
    toolCooldownActive = not toolCooldownActive
    if toolCooldownActive then
        cooldownBtn.Text = "ON"
        cooldownBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        cooldownBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Tool Cooldown ENABLED - Enter a number"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    else
        cooldownBtn.Text = "OFF"
        cooldownBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        cooldownBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "Tool Cooldown DISABLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(0.5)
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

cooldownBtn.MouseButton1Click:Connect(toggleToolCooldown)
cooldownBtn.TouchTap:Connect(toggleToolCooldown)

cooldownTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and toolCooldownActive then
        local input = cooldownTextBox.Text
        local num = tonumber(input)
        if num and num >= 0 then
            local count = applyToolCooldown(num)
            statusLabel.Text = "Set cooldown to " .. num .. " on " .. count .. " tools"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            statusLabel.Text = "Enter a valid number (e.g. 5)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        end
    end
end)

-- ===== TP TO TOOLCOLLECTOR =====
local function teleportToModel(modelName)
    if not modelName or modelName == "" then
        statusLabel.Text = "Please enter a model name"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    
    local targetModel = nil
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and string.lower(v.Name) == string.lower(modelName) then
            targetModel = v
            break
        end
    end
    
    if not targetModel then
        statusLabel.Text = "Model '" .. modelName .. "' not found!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local targetPart = targetModel:FindFirstChild("PrimaryPart")
    if not targetPart or not targetPart:IsA("BasePart") then
        for _, v in pairs(targetModel:GetDescendants()) do
            if v:IsA("BasePart") then
                targetPart = v
                break
            end
        end
    end
    
    if not targetPart then
        statusLabel.Text = "No BasePart found in model"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local character = player.Character
    if not character then
        statusLabel.Text = "Character not found"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        statusLabel.Text = "HumanoidRootPart not found"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local targetCFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
    
    pcall(function()
        hrp.CFrame = targetCFrame
    end)
    
    task.wait(0.1)
    pcall(function()
        hrp.CFrame = targetCFrame
    end)
    
    statusLabel.Text = "Teleported to '" .. targetModel.Name .. "'"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
end

-- Scan Collections
local function scanCollections()
    local foundModels = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name and string.lower(v.Name):find("collection") then
            table.insert(foundModels, v.Name)
        end
    end
    
    if #foundModels > 0 then
        local displayText = "Collection Models:\n"
        for i, name in pairs(foundModels) do
            displayText = displayText .. "• " .. name
            if i < #foundModels then displayText = displayText .. "\n" end
        end
        collectionListLabel.Text = displayText
        statusLabel.Text = "Found " .. #foundModels .. " collection models"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        collectionListLabel.Text = "Collection Models: None found"
        statusLabel.Text = "No collection models found"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    end
end

scanBtn.MouseButton1Click:Connect(scanCollections)
scanBtn.TouchTap:Connect(scanCollections)

tpBtn.MouseButton1Click:Connect(function()
    local modelName = tpTextBox.Text
    teleportToModel(modelName)
end)

tpBtn.TouchTap:Connect(function()
    local modelName = tpTextBox.Text
    teleportToModel(modelName)
end)

tpTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local modelName = tpTextBox.Text
        teleportToModel(modelName)
    end
end)

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

local function toggleSpears()
    deleteSpearsActive = not deleteSpearsActive
    if deleteSpearsActive then
        spearsBtn.Text, spearsBtn.BackgroundColor3, spearsBtn.TextColor3, statusLabel.Text, statusLabel.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Scanning...", Color3.fromRGB(0,255,100)
        scanAndDeleteSpears()
    else
        spearsBtn.Text, spearsBtn.BackgroundColor3, spearsBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        restoreSpears()
    end
end
spearsBtn.MouseButton1Click:Connect(toggleSpears)
spearsBtn.TouchTap:Connect(toggleSpears)

local function toggleFireLava()
    deleteFireLavaActive = not deleteFireLavaActive
    if deleteFireLavaActive then
        fireLavaBtn.Text, fireLavaBtn.BackgroundColor3, fireLavaBtn.TextColor3, statusLabel.Text, statusLabel.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Scanning...", Color3.fromRGB(0,255,100)
        scanAndDeleteFireLava()
    else
        fireLavaBtn.Text, fireLavaBtn.BackgroundColor3, fireLavaBtn.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        restoreFireLava()
    end
end
fireLavaBtn.MouseButton1Click:Connect(toggleFireLava)
fireLavaBtn.TouchTap:Connect(toggleFireLava)

local function toggleSeismic()
    deleteSeismicActive = not deleteSeismicActive
    if deleteSeismicActive then
        seismicBtn.Text = "ON"
        seismicBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
        seismicBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Scanning..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        scanAndDeleteSeismic()
    else
        seismicBtn.Text = "OFF"
        seismicBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        seismicBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        restoreSeismic()
    end
end

seismicBtn.MouseButton1Click:Connect(toggleSeismic)
seismicBtn.TouchTap:Connect(toggleSeismic)

-- ===== DESTROY GUI =====
local function destroyGUI()
    if duplicatedSadWater then
        duplicatedSadWater:Destroy()
    end
    root:Destroy()
    blur:Destroy()
end
destroyBtn.MouseButton1Click:Connect(destroyGUI)
destroyBtn.TouchTap:Connect(destroyGUI)

-- ===== TAB SWITCHING =====
local function switchToMods()
    modsPage.Visible, othersPage.Visible = true, false
    tabMods.TextColor3, tabOthers.TextColor3 = Color3.fromRGB(255,50,80), Color3.fromRGB(180,180,210)
end
local function switchToOthers()
    modsPage.Visible, othersPage.Visible = false, true
    tabOthers.TextColor3, tabMods.TextColor3 = Color3.fromRGB(255,50,80), Color3.fromRGB(180,180,210)
end
tabMods.MouseButton1Click:Connect(switchToMods)
tabMods.TouchTap:Connect(switchToMods)
tabOthers.MouseButton1Click:Connect(switchToOthers)
tabOthers.TouchTap:Connect(switchToOthers)
modsPage.Visible, tabMods.TextColor3 = true, Color3.fromRGB(255,50,80)

-- ===== CLOSE/RE-OPEN =====
local function toggleOpenClose()
    if isOpen then
        isOpen, frame.Visible, reopenBtn.Visible, closeBtn.Text, closeBtn.TextColor3, blur.Size = false, false, true, "▶", Color3.fromRGB(100,255,100), 0
    else
        isOpen, frame.Visible, reopenBtn.Visible, closeBtn.Text, closeBtn.TextColor3 = true, true, false, "X", Color3.fromRGB(200,200,210)
        blur.Size = 3
    end
end
closeBtn.MouseButton1Click:Connect(toggleOpenClose)
closeBtn.TouchTap:Connect(toggleOpenClose)

reopenBtn.MouseButton1Click:Connect(function()
    if not isOpen then
        isOpen, frame.Visible, reopenBtn.Visible, closeBtn.Text, closeBtn.TextColor3 = true, true, false, "X", Color3.fromRGB(200,200,210)
        blur.Size = 3
    end
end)
reopenBtn.TouchTap:Connect(function()
    if not isOpen then
        isOpen, frame.Visible, reopenBtn.Visible, closeBtn.Text, closeBtn.TextColor3 = true, true, false, "X", Color3.fromRGB(200,200,210)
        blur.Size = 3
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
UserInputService.InputBegan:Connect(function(i, gp) if gp then return end; if i.KeyCode == Enum.KeyCode.Insert then toggleOpenClose() end end)

-- ===== FORCE VISIBILITY =====
frame.BackgroundTransparency = 0.08
frame.Size = UDim2.new(0, 350, 0, 320)
blur.Size = 3

print("NZ-IS v6 - LOADED! (Tool Cooldown now checks held tools)")
