-- NZ-IS v6 - MOBILE WORKING (COMPRESSED)
local P, U, T, R, L, W = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("Lighting"), game:GetService("Workspace")
local pl, gp, C = P.LocalPlayer, pl:WaitForChild("PlayerGui"), W.CurrentCamera
pcall(function() if gp:FindFirstChild("InfectiousRoot") then gp.InfectiousRoot:Destroy() end end)
local rt = Instance.new("ScreenGui"); rt.Name, rt.Parent, rt.ResetOnSpawn, rt.ZIndexBehavior, rt.IgnoreGuiInset = "InfectiousRoot", gp, false, Enum.ZIndexBehavior.Sibling, true
local bl = Instance.new("BlurEffect", L); bl.Size = 3
local th = {D={bg=Color3.fromRGB(18,18,22),ac=Color3.fromRGB(255,50,80),tx=Color3.fromRGB(220,220,230),bt=Color3.fromRGB(30,30,35),st=Color3.fromRGB(255,50,80)},C={bg=Color3.fromRGB(20,10,12),ac=Color3.fromRGB(255,30,50),tx=Color3.fromRGB(230,200,200),bt=Color3.fromRGB(35,20,22),st=Color3.fromRGB(200,30,50)},Cy={bg=Color3.fromRGB(8,10,20),ac=Color3.fromRGB(0,200,255),tx=Color3.fromRGB(180,230,255),bt=Color3.fromRGB(15,25,40),st=Color3.fromRGB(0,180,255)},A={bg=Color3.fromRGB(18,14,8),ac=Color3.fromRGB(255,180,0),tx=Color3.fromRGB(240,220,180),bt=Color3.fromRGB(30,25,15),st=Color3.fromRGB(200,150,0)},V={bg=Color3.fromRGB(16,10,22),ac=Color3.fromRGB(180,80,255),tx=Color3.fromRGB(220,200,240),bt=Color3.fromRGB(28,18,35),st=Color3.fromRGB(150,50,220)}}
local ct, io, im = "D", true, false
local dIA, dKA, dDA, rA, fA, tA, sA, iJA, nA, fA2 = false, false, false, false, false, false, false, false, false, false
local wv, jv = 16, 50
local iC, kC, dC, eC, fC, nC, iB = nil, nil, nil, nil, nil, nil, nil
local dI, dK, dD, eO = {}, {}, {}, {}
local fV, fG = nil, nil
local fUH, fDH = false, false
local oL = {Brightness=L.Brightness,ClockTime=L.ClockTime,Ambient=L.Ambient,OutdoorAmbient=L.OutdoorAmbient,ColorShift_Top=L.ColorShift_Top,ColorShift_Bottom=L.ColorShift_Bottom,EnvironmentDiffuseScale=L.EnvironmentDiffuseScale,EnvironmentSpecularScale=L.EnvironmentSpecularScale,GlobalShadows=L.GlobalShadows,ShadowSoftness=L.ShadowSoftness,Technology=L.Technology}
local fr = Instance.new("Frame"); fr.Size, fr.Position, fr.BackgroundColor3, fr.BackgroundTransparency, fr.ClipsDescendants, fr.Parent, fr.Visible, fr.ZIndex, fr.Active = UDim2.new(0,360,0,340), UDim2.new(0.5,-180,0.5,-170), th.D.bg, 0.08, true, rt, true, 10, true
Instance.new("UICorner", fr).CornerRadius = UDim.new(0,8)
local st = Instance.new("UIStroke", fr); st.Color, st.Thickness, st.Transparency = th.D.st, 1.5, 0.6
local tb = Instance.new("Frame"); tb.Size, tb.BackgroundTransparency, tb.BackgroundColor3, tb.Parent, tb.Active = UDim2.new(1,0,0,44), 0.2, Color3.fromRGB(20,20,25), fr, true
Instance.new("UICorner", tb).CornerRadius = UDim.new(0,8)
local tl = Instance.new("TextLabel"); tl.Size, tl.Position, tl.Text, tl.TextColor3, tl.TextSize, tl.Font, tl.TextXAlignment, tl.BackgroundTransparency, tl.Parent = UDim2.new(0.5,0,1,0), UDim2.new(0,10,0,0), "NZ-IS", th.D.ac, 14, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 1, tb
local mn = Instance.new("TextButton"); mn.Size, mn.Position, mn.Text, mn.TextColor3, mn.TextSize, mn.Font, mn.BackgroundColor3, mn.BackgroundTransparency, mn.Parent, mn.AutoButtonColor = UDim2.new(0,30,0,30), UDim2.new(1,-68,0,7), "─", Color3.fromRGB(200,200,210), 18, Enum.Font.GothamBold, Color3.fromRGB(40,40,45), 0.2, tb, true
Instance.new("UICorner", mn).CornerRadius = UDim.new(0,6)
local cl = Instance.new("TextButton"); cl.Size, cl.Position, cl.Text, cl.TextColor3, cl.TextSize, cl.Font, cl.BackgroundColor3, cl.BackgroundTransparency, cl.Parent, cl.AutoButtonColor = UDim2.new(0,30,0,30), UDim2.new(1,-36,0,7), "✕", Color3.fromRGB(200,200,210), 14, Enum.Font.GothamBold, Color3.fromRGB(40,40,45), 0.2, tb, true
Instance.new("UICorner", cl).CornerRadius = UDim.new(0,6)
local mf = Instance.new("Frame"); mf.Size, mf.Position, mf.BackgroundColor3, mf.BackgroundTransparency, mf.ClipsDescendants, mf.Parent, mf.Visible, mf.ZIndex, mf.Active = UDim2.new(0,55,0,55), UDim2.new(1,-65,0,10), th.D.ac, 0.1, true, rt, false, 999, true
Instance.new("UICorner", mf).CornerRadius = UDim.new(0,12)
local ms = Instance.new("UIStroke", mf); ms.Color, ms.Thickness, ms.Transparency = th.D.ac, 2, 0.3
local ml = Instance.new("TextLabel"); ml.Size, ml.Text, ml.TextColor3, ml.TextSize, ml.Font, ml.BackgroundTransparency, ml.Parent = UDim2.new(1,0,1,0), "NZ", Color3.fromRGB(255,255,255), 14, Enum.Font.GothamBold, 1, mf
local sb = Instance.new("TextButton"); sb.Size, sb.Position, sb.Text, sb.TextSize, sb.TextColor3, sb.BackgroundColor3, sb.Parent, sb.Visible, sb.ZIndex, sb.Active = UDim2.new(0,55,0,55), UDim2.new(0,10,1,-70), "🔄", 26, Color3.fromRGB(255,255,255), Color3.fromRGB(255,50,80), rt, false, 999, true
Instance.new("UICorner", sb).CornerRadius = UDim.new(1,0); Instance.new("UIStroke", sb).Color = Color3.fromRGB(255,255,255)
sb.MouseButton1Click:Connect(function() print("SF") end); sb.TouchTap:Connect(function() print("SF") end)
local fU = Instance.new("TextButton"); fU.Size, fU.Position, fU.Text, fU.TextSize, fU.TextColor3, fU.BackgroundColor3, fU.BackgroundTransparency, fU.Parent, fU.Visible, fU.ZIndex = UDim2.new(0,70,0,70), UDim2.new(1,-85,0.5,-85), "▲", 30, Color3.fromRGB(255,255,255), Color3.fromRGB(255,50,80), 0.5, rt, false, 999
Instance.new("UICorner", fU).CornerRadius = UDim.new(1,0)
local fD = Instance.new("TextButton"); fD.Size, fD.Position, fD.Text, fD.TextSize, fD.TextColor3, fD.BackgroundColor3, fD.BackgroundTransparency, fD.Parent, fD.Visible, fD.ZIndex = UDim2.new(0,70,0,70), UDim2.new(1,-85,0.5,-5), "▼", 30, Color3.fromRGB(255,255,255), Color3.fromRGB(255,50,80), 0.5, rt, false, 999
Instance.new("UICorner", fD).CornerRadius = UDim.new(1,0)
fU.TouchBegan:Connect(function() fUH = true end); fU.TouchEnded:Connect(function() fUH = false end); fU.MouseButton1Down:Connect(function() fUH = true end); fU.MouseButton1Up:Connect(function() fUH = false end)
fD.TouchBegan:Connect(function() fDH = true end); fD.TouchEnded:Connect(function() fDH = false end); fD.MouseButton1Down:Connect(function() fDH = true end); fD.MouseButton1Up:Connect(function() fDH = false end)
local tc = Instance.new("Frame"); tc.Size, tc.Position, tc.BackgroundTransparency, tc.Parent = UDim2.new(1,-10,0,28), UDim2.new(0,5,0,48), 1, fr
local function ct2(n, x)
    local b = Instance.new("TextButton"); b.Size, b.Position, b.Text, b.TextColor3, b.TextSize, b.Font, b.BackgroundColor3, b.BackgroundTransparency, b.Parent, b.AutoButtonColor = UDim2.new(0,65,1,0), UDim2.new(0,x,0,0), n, Color3.fromRGB(200,200,210), 10, Enum.Font.GothamBold, Color3.fromRGB(30,30,35), 0.3, tc, true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5); return b
end
local tm, tp, tg, tth, to = ct2("Mods",0), ct2("Player",70), ct2("Graphics",140), ct2("Theme",210), ct2("Others",280)
local function cp()
    local p = Instance.new("ScrollingFrame"); p.Size, p.Position, p.BackgroundTransparency, p.CanvasSize, p.ScrollBarThickness, p.ScrollBarImageColor3, p.Parent, p.Visible = UDim2.new(1,-10,1,-84), UDim2.new(0,5,0,80), 1, UDim2.new(0,0,0,550), 3, th.D.ac, fr, false; return p
end
local mp, pp, gp2, tp2, op = cp(), cp(), cp(), cp(), cp()
local function ml2(t, y, p, w)
    w = w or 100; local l = Instance.new("TextLabel"); l.Size, l.Position, l.Text, l.TextColor3, l.TextSize, l.Font, l.BackgroundTransparency, l.TextXAlignment, l.Parent = UDim2.new(0,w,0,22), UDim2.new(0,0,0,y), t, th.D.tx, 11, Enum.Font.Gotham, 1, Enum.TextXAlignment.Left, p; return l
end
local function mt(y, p)
    local b = Instance.new("TextButton"); b.Size, b.Position, b.Text, b.TextColor3, b.TextSize, b.Font, b.BackgroundColor3, b.Parent, b.AutoButtonColor = UDim2.new(0,60,0,22), UDim2.new(0,180,0,y), "OFF", Color3.fromRGB(255,100,100), 10, Enum.Font.GothamBold, Color3.fromRGB(40,20,20), p, true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4); return b
end
local function ms2(t, y, p, mn2, mx, d, cb)
    local l = Instance.new("TextLabel"); l.Size, l.Position, l.Text, l.TextColor3, l.TextSize, l.Font, l.BackgroundTransparency, l.TextXAlignment, l.Parent = UDim2.new(0,120,0,22), UDim2.new(0,0,0,y), t, th.D.tx, 11, Enum.Font.Gotham, 1, Enum.TextXAlignment.Left, p
    local vl = Instance.new("TextLabel"); vl.Size, vl.Position, vl.Text, vl.TextColor3, vl.TextSize, vl.Font, vl.BackgroundTransparency, vl.TextXAlignment, vl.Parent = UDim2.new(0,40,0,22), UDim2.new(0,125,0,y), tostring(d), th.D.ac, 11, Enum.Font.GothamBold, 1, Enum.TextXAlignment.Center, p
    local s = Instance.new("Frame"); s.Size, s.Position, s.BackgroundColor3, s.Parent = UDim2.new(0,120,0,8), UDim2.new(0,170,0,y+7), Color3.fromRGB(40,40,50), p
    Instance.new("UICorner", s).CornerRadius = UDim.new(0,4)
    local f = Instance.new("Frame"); f.Size, f.BackgroundColor3, f.Parent = UDim2.new((d-mn2)/(mx-mn2),0,1,0), th.D.ac, s
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,4)
    local cv = d
    local function us(i)
        local pos = i.Position.X - s.AbsolutePosition.X; local w2 = s.AbsoluteSize.X
        local pct = math.clamp(pos/w2,0,1); local nv = math.floor((mn2+(mx-mn2)*pct)*10)/10
        if nv < mn2 then nv = mn2 end; if nv > mx then nv = mx end
        cv = nv; f.Size = UDim2.new(pct,0,1,0); vl.Text = tostring(nv); if cb then cb(nv) end
    end
    s.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then us(i) end end)
    s.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then us(i) end end)
    return {Slider=s,Fill=f,ValueLabel=vl,GetValue=function() return cv end}
end
local function mb(t, y, p, c)
    c = c or Color3.fromRGB(60,30,30); local b = Instance.new("TextButton"); b.Size, b.Position, b.Text, b.TextColor3, b.TextSize, b.Font, b.BackgroundColor3, b.Parent, b.AutoButtonColor = UDim2.new(0,150,0,32), UDim2.new(0.5,-75,0,y), t, Color3.fromRGB(255,255,255), 13, Enum.Font.GothamBold, c, p, true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6); return b
end
local yOff = 4
ml2("Delete Infected", yOff, mp, 120); local iB2 = mt(yOff, mp); yOff = yOff + 28
ml2("Disable Kill Parts", yOff, mp, 120); local kB = mt(yOff, mp); yOff = yOff + 28
ml2("Disable Doors/Gates", yOff, mp, 120); local dB = mt(yOff, mp); yOff = yOff + 28
ml2("TEAM ESP", yOff, mp, 120); local eB = mt(yOff, mp); yOff = yOff + 32
local sL = Instance.new("TextLabel"); sL.Size, sL.Position, sL.Text, sL.TextColor3, sL.TextSize, sL.Font, sL.BackgroundTransparency, sL.TextXAlignment, sL.Parent = UDim2.new(1,-10,0,22), UDim2.new(0,0,0,yOff), "Ready", Color3.fromRGB(0,255,150), 11, Enum.Font.GothamBold, 1, Enum.TextXAlignment.Left, mp
yOff = yOff + 28; mp.CanvasSize = UDim2.new(0,0,0,yOff+10)
local pY = 4
ml2("Enable Shitflock", pY, pp, 120); local sT = mt(pY, pp); pY = pY + 28
ms2("WalkSpeed", pY, pp, 10, 100, 16, function(v) wv = v; if pl.Character and pl.Character:FindFirstChild("Humanoid") then pl.Character.Humanoid.WalkSpeed = v end end)
pY = pY + 36
ms2("JumpPower", pY, pp, 20, 200, 50, function(v) jv = v; if pl.Character and pl.Character:FindFirstChild("Humanoid") then pl.Character.Humanoid.JumpPower = v end end)
pY = pY + 36
ml2("Inf Jump", pY, pp, 120); local iJB = mt(pY, pp); pY = pY + 28
ml2("Noclip", pY, pp, 120); local nB = mt(pY, pp); pY = pY + 28
ml2("Fly", pY, pp, 120); local fB = mt(pY, pp); pY = pY + 28
local pD = Instance.new("TextLabel"); pD.Size, pD.Position, pD.Text, pD.TextColor3, pD.TextSize, pD.Font, pD.BackgroundTransparency, pD.TextXAlignment, pD.Parent = UDim2.new(1,-10,0,30), UDim2.new(0,0,0,pY), "Fly: ▲ ▼ buttons appear on the right side", Color3.fromRGB(150,150,170), 10, Enum.Font.Gotham, 1, Enum.TextXAlignment.Left, pp
pY = pY + 40; pp.CanvasSize = UDim2.new(0,0,0,pY+10)
local gY = 4
ml2("RTX Graphics", gY, gp2, 120); local rB = mt(gY, gp2); gY = gY + 28
ml2("Realistic/Future Lighting", gY, gp2, 120); local fB2 = mt(gY, gp2); gY = gY + 28
local gD = Instance.new("TextLabel"); gD.Size, gD.Position, gD.Text, gD.TextColor3, gD.TextSize, gD.Font, gD.BackgroundTransparency, gD.TextXAlignment, gD.Parent = UDim2.new(1,-10,0,30), UDim2.new(0,0,0,gY), "Lighting: Enables Future/Realistic tech\nRTX: Full visual overhaul", Color3.fromRGB(150,150,170), 10, Enum.Font.Gotham, 1, Enum.TextXAlignment.Left, gp2
gY = gY + 40; gp2.CanvasSize = UDim2.new(0,0,0,gY+10)
local tY = 4
local tL = Instance.new("TextLabel"); tL.Size, tL.Position, tL.Text, tL.TextColor3, tL.TextSize, tL.Font, tL.BackgroundTransparency, tL.TextXAlignment, tL.Parent = UDim2.new(1,-10,0,22), UDim2.new(0,0,0,tY), "THEMES", Color3.fromRGB(180,180,220), 11, Enum.Font.GothamBold, 1, Enum.TextXAlignment.Left, tp2
tY = tY + 28
local function ctb(n, y, c)
    local b = Instance.new("TextButton"); b.Size, b.Position, b.Text, b.TextColor3, b.TextSize, b.Font, b.BackgroundColor3, b.Parent, b.AutoButtonColor = UDim2.new(0,120,0,28), UDim2.new(0,0,0,y), n, Color3.fromRGB(255,255,255), 12, Enum.Font.GothamBold, c or Color3.fromRGB(30,30,50), tp2, true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    local function ap()
        ct = n; local t = th[n]; fr.BackgroundColor3, st.Color, tl.TextColor3, sL.TextColor3, mf.BackgroundColor3, ms.Color, mn.TextColor3, cl.TextColor3, sb.BackgroundColor3, fU.BackgroundColor3, fD.BackgroundColor3 = t.bg, t.st, t.ac, t.ac, t.ac, t.ac, t.ac, t.ac, t.ac, t.ac, t.ac
        for _, ch in pairs(fr:GetDescendants()) do
            if ch:IsA("TextButton") and ch ~= iB2 and ch ~= kB and ch ~= dB and ch ~= eB and ch ~= rB and ch ~= fB2 and ch ~= mn and ch ~= cl and ch ~= sT and ch ~= iJB and ch ~= nB and ch ~= fB then
                if ch.Text == "Mods" or ch.Text == "Player" or ch.Text == "Graphics" or ch.Text == "Theme" or ch.Text == "Others" then ch.TextColor3 = t.ac end
            end
            if ch:IsA("ScrollingFrame") then ch.ScrollBarImageColor3 = t.ac end
        end
        local function ut(b, a) if a then b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100) else b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100) end end
        ut(iB2, dIA); ut(kB, dKA); ut(dB, dDA); ut(eB, tA); ut(rB, rA); ut(fB2, fA); ut(sT, sA); ut(iJB, iJA); ut(nB, nA); ut(fB, fA2)
    end
    b.MouseButton1Click:Connect(ap); b.TouchTap:Connect(ap); return b
end
local tC = {{n="Default",c=Color3.fromRGB(30,20,25)},{n="Crimson",c=Color3.fromRGB(35,15,20)},{n="Cyber",c=Color3.fromRGB(10,15,40)},{n="Amber",c=Color3.fromRGB(35,25,15)},{n="Violet",c=Color3.fromRGB(25,15,40)}}
for _, t in pairs(tC) do ctb(t.n, tY, t.c); tY = tY + 33 end
local oY = 10
local dBt = mb("Destroy GUI", oY, op, Color3.fromRGB(80,20,20)); oY = oY + 40
local cL = Instance.new("TextLabel"); cL.Size, cL.Position, cL.Text, cL.TextColor3, cL.TextSize, cL.Font, cL.BackgroundTransparency, cL.TextXAlignment, cL.Parent = UDim2.new(1,-10,0,20), UDim2.new(0,0,0,oY), "NZ-IS v6", Color3.fromRGB(100,100,120), 10, Enum.Font.Gotham, 1, Enum.TextXAlignment.Center, op
oY = oY + 30; op.CanvasSize = UDim2.new(0,0,0,oY+10)
local function tS()
    sA = not sA
    if sA then sT.Text, sT.BackgroundColor3, sT.TextColor3, sb.Visible, sL.Text, sL.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), true, "Shitflock ENABLED", Color3.fromRGB(0,200,255)
    else sT.Text, sT.BackgroundColor3, sT.TextColor3, sb.Visible, sL.Text, sL.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100), false, "Shitflock DISABLED", Color3.fromRGB(255,100,100); task.wait(0.5); sL.Text, sL.TextColor3 = "Ready", Color3.fromRGB(0,255,150) end
end
sT.MouseButton1Click:Connect(tS); sT.TouchTap:Connect(tS)
local function sIJ()
    if iB then pcall(function() iB:Disconnect() end); iB = nil end
    local c = pl.Character; if not c then return end; local h = c:FindFirstChild("Humanoid"); if not h then return end
    local jc = 0
    iB = h.StateChanged:Connect(function(os, ns)
        if not iJA then return end
        if ns == Enum.HumanoidStateType.Jumping then jc = jc + 1 end
        if ns == Enum.HumanoidStateType.Landed then jc = 0 end
        if ns == Enum.HumanoidStateType.Freefall and jc > 0 then task.wait(0.05); if iJA and h and h.Parent then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
    end)
end
local function tIJ()
    iJA = not iJA
    if iJA then iJB.Text, iJB.BackgroundColor3, iJB.TextColor3, sL.Text, sL.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Inf Jump ENABLED", Color3.fromRGB(0,200,255); sIJ()
    else iJB.Text, iJB.BackgroundColor3, iJB.TextColor3, sL.Text, sL.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100), "Inf Jump DISABLED", Color3.fromRGB(255,100,100); if iB then pcall(function() iB:Disconnect() end); iB = nil end; task.wait(0.5); sL.Text, sL.TextColor3 = "Ready", Color3.fromRGB(0,255,150) end
end
iJB.MouseButton1Click:Connect(tIJ); iJB.TouchTap:Connect(tIJ)
local function sN()
    if nC then pcall(function() nC:Disconnect() end); nC = nil end
    if not nA then return end
    nC = R.Stepped:Connect(function() if nA and pl.Character then for _, p in pairs(pl.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
end
local function tN()
    nA = not nA
    if nA then nB.Text, nB.BackgroundColor3, nB.TextColor3, sL.Text, sL.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Noclip ENABLED", Color3.fromRGB(0,200,255); sN()
    else nB.Text, nB.BackgroundColor3, nB.TextColor3, sL.Text, sL.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100), "Noclip DISABLED", Color3.fromRGB(255,100,100); if nC then pcall(function() nC:Disconnect() end); nC = nil end; if pl.Character then for _, p in pairs(pl.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end; task.wait(0.5); sL.Text, sL.TextColor3 = "Ready", Color3.fromRGB(0,255,150) end
end
nB.MouseButton1Click:Connect(tN); nB.TouchTap:Connect(tN)
local function sF()
    if fC then pcall(function() fC:Disconnect() end); fC = nil end
    if not fA2 then return end
    fC = R.Heartbeat:Connect(function()
        if not fA2 then return end
        local c = pl.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        local rp = c.HumanoidRootPart; local h = c:FindFirstChild("Humanoid")
        if not fV or fV.Parent == nil then fV = Instance.new("BodyVelocity"); fV.MaxForce = Vector3.new(1e9,1e9,1e9); fV.Parent = rp end
        if not fG or fG.Parent == nil then fG = Instance.new("BodyGyro"); fG.MaxTorque = Vector3.new(1e9,1e9,1e9); fG.CFrame = rp.CFrame; fG.Parent = rp end
        local md = Vector3.new(); local f = C.CFrame.LookVector; local r = C.CFrame.RightVector
        if U:IsKeyDown(Enum.KeyCode.W) then md = md + f end; if U:IsKeyDown(Enum.KeyCode.S) then md = md - f end; if U:IsKeyDown(Enum.KeyCode.A) then md = md - r end; if U:IsKeyDown(Enum.KeyCode.D) then md = md + r end
        if fUH then md = md + Vector3.new(0,1,0) end; if fDH then md = md + Vector3.new(0,-1,0) end
        if U:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0,1,0) end; if U:IsKeyDown(Enum.KeyCode.LeftShift) then md = md + Vector3.new(0,-1,0) end
        if md.Magnitude > 0 then md = md.Unit * 50 end
        fV.Velocity = md; fG.CFrame = CFrame.new(rp.Position, rp.Position + f * 10)
        if h then h.PlatformStand = true; h.AutoRotate = false end
    end)
end
local function tF()
    fA2 = not fA2
    if fA2 then fB.Text, fB.BackgroundColor3, fB.TextColor3, sL.Text, sL.TextColor3, fU.Visible, fD.Visible = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Fly ENABLED", Color3.fromRGB(0,200,255), true, true; sF()
    else fB.Text, fB.BackgroundColor3, fB.TextColor3, sL.Text, sL.TextColor3, fU.Visible, fD.Visible, fUH, fDH = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100), "Fly DISABLED", Color3.fromRGB(255,100,100), false, false, false, false; if fC then pcall(function() fC:Disconnect() end); fC = nil end; if fV then pcall(function() fV:Destroy() end); fV = nil end; if fG then pcall(function() fG:Destroy() end); fG = nil end; local c = pl.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.PlatformStand = false; c.Humanoid.AutoRotate = true end; task.wait(0.5); sL.Text, sL.TextColor3 = "Ready", Color3.fromRGB(0,255,150) end
end
fB.MouseButton1Click:Connect(tF); fB.TouchTap:Connect(tF)
local function onCA(c)
    task.wait(0.3)
    if pl.Character and pl.Character:FindFirstChild("Humanoid") then pl.Character.Humanoid.WalkSpeed = wv; pl.Character.Humanoid.JumpPower = jv end
    if iJA then sIJ() end; if nA then sN() end; if fA2 then sF() end
end
pl.CharacterAdded:Connect(onCA)
local function dG()
    if iC then pcall(function() iC:Disconnect() end) end; if kC then pcall(function() kC:Disconnect() end) end; if dC then pcall(function() dC:Disconnect() end) end; if eC then pcall(function() eC:Disconnect() end) end; if nC then pcall(function() nC:Disconnect() end) end; if fC then pcall(function() fC:Disconnect() end) end; if iB then pcall(function() iB:Disconnect() end) end; if fV then pcall(function() fV:Destroy() end) end; if fG then pcall(function() fG:Destroy() end) end
    for _, d in pairs(eO) do pcall(function() if d.Highlight then d.Highlight:Destroy() end; if d.Box then d.Box:Destroy() end; if d.Line then d.Line:Destroy() end end) end
    eO = {}; rt:Destroy(); bl:Destroy()
end
dBt.MouseButton1Click:Connect(dG); dBt.TouchTap:Connect(dG)
local function rI()
    local c = 0; local it = {}; for _, itm in pairs(dI) do if itm and not itm.Parent then table.insert(it, itm) end end
    for _, itm in pairs(it) do pcall(function() itm.Parent = W; c = c + 1 end) end; dI = {}; if c > 0 then sL.Text, sL.TextColor3 = "Restored " .. c .. " infect", Color3.fromRGB(0,255,150) end; return c
end
local function rK()
    local c = 0; local it = {}; for _, itm in pairs(dK) do if itm and not itm.Parent then table.insert(it, itm) end end
    for _, itm in pairs(it) do pcall(function() itm.Parent = W; c = c + 1 end) end; dK = {}; if c > 0 then sL.Text, sL.TextColor3 = "Restored " .. c .. " kill", Color3.fromRGB(0,255,150) end; return c
end
local function rD()
    local c = 0; local it = {}; for _, itm in pairs(dD) do if itm and not itm.Parent then table.insert(it, itm) end end
    for _, itm in pairs(it) do pcall(function() itm.Parent = W; c = c + 1 end) end; dD = {}; if c > 0 then sL.Text, sL.TextColor3 = "Restored " .. c .. " doors", Color3.fromRGB(0,255,150) end; return c
end
local function sDI()
    if not dIA then rI(); return end
    local f = {}; for _, v in pairs(W:GetDescendants()) do if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then if v.Name and string.lower(v.Name):find("infect") then table.insert(f, v) end end end
    for _, v in pairs(f) do if v and v.Parent then table.insert(dI, v); pcall(function() v.Parent = nil end) end end
    if #f > 0 then sL.Text, sL.TextColor3 = "Del " .. #f .. " inf", Color3.fromRGB(255,200,50) elseif dIA then sL.Text, sL.TextColor3 = "No infect found", Color3.fromRGB(0,255,150) end
end
local function sDK()
    if not dKA then rK(); return end
    local f = {}; for _, v in pairs(W:GetDescendants()) do if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then if v.Name and string.lower(v.Name):find("kill") then table.insert(f, v) end end end
    for _, v in pairs(f) do if v and v.Parent then table.insert(dK, v); pcall(function() v.Parent = nil end) end end
    if #f > 0 then sL.Text, sL.TextColor3 = "Del " .. #f .. " kill", Color3.fromRGB(255,200,50) elseif dKA then sL.Text, sL.TextColor3 = "No kill found", Color3.fromRGB(0,255,150) end
end
local function sDD()
    if not dDA then rD(); return end
    local f, kw = {}, {"door","gate","portal","doorway","entrance","exit"}
    for _, v in pairs(W:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") and v.Name then
            local nl = string.lower(v.Name); for _, k in pairs(kw) do if nl:find(k) then table.insert(f, v); break end end
        end
    end
    for _, v in pairs(f) do if v and v.Parent then table.insert(dD, v); pcall(function() v.Parent = nil end) end end
    if #f > 0 then sL.Text, sL.TextColor3 = "Del " .. #f .. " doors", Color3.fromRGB(255,200,50) elseif dDA then sL.Text, sL.TextColor3 = "No doors found", Color3.fromRGB(0,255,150) end
end
local function gTC(p2) if p2.Team then return p2.Team.TeamColor.Color end; return Color3.fromRGB(255,255,255) end
local function cE(tg)
    if tg == pl then return end; if not tg.Character or not tg.Character:FindFirstChild("HumanoidRootPart") then return end
    local rp = tg.Character.HumanoidRootPart; local tc = gTC(tg)
    local h = Instance.new("Highlight"); h.Name, h.FillTransparency, h.OutlineTransparency, h.FillColor, h.OutlineColor, h.DepthMode, h.Parent = "ESP_Highlight", 0.6, 0.3, tc, tc, Enum.HighlightDepthMode.AlwaysOnTop, tg.Character
    local b = Instance.new("Frame"); b.Name, b.Size, b.Position, b.BackgroundTransparency, b.BackgroundColor3, b.BorderSizePixel, b.BorderColor3, b.Parent, b.Visible = "ESP_Box", UDim2.new(0,30,0,60), UDim2.new(0.5,-15,0.5,-30), 0.5, tc, 2, tc, rp, false
    local nl = Instance.new("TextLabel"); nl.Name, nl.Size, nl.Position, nl.Text, nl.TextColor3, nl.TextSize, nl.Font, nl.BackgroundTransparency, nl.TextStrokeColor3, nl.TextStrokeTransparency, nl.Parent = "ESP_Name", UDim2.new(1,0,0,16), UDim2.new(0,0,0,-18), tg.Name, Color3.fromRGB(255,255,255), 10, Enum.Font.GothamBold, 1, Color3.fromRGB(0,0,0), 0.3, b
    local l = Instance.new("Frame"); l.Name, l.Size, l.BackgroundTransparency, l.BackgroundColor3, l.Parent, l.Visible = "ESP_Line", UDim2.new(0,1,0,1), 0.6, tc, rp, false
    eO[tg] = {Highlight=h, Box=b, Name=nl, Line=l, Root=rp}
end
local function uE()
    if not tA then for _, d in pairs(eO) do if d.Highlight then d.Highlight:Destroy() end; if d.Box then d.Box:Destroy() end; if d.Line then d.Line:Destroy() end end; eO = {}; return end
    local c = pl.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return end; local mp2 = c.HumanoidRootPart.Position
    for _, tg in pairs(P:GetPlayers()) do
        if tg ~= pl and tg.Character and tg.Character:FindFirstChild("HumanoidRootPart") then
            if not eO[tg] then cE(tg) end
            local d = eO[tg]; if d and d.Root then
                local tp = d.Root.Position; local dist = (mp2 - tp).Magnitude; local sp, os = C:WorldToViewportPoint(tp)
                local fd = math.clamp((dist-15)/30, 0.3, 1)
                if os and dist < 200 then
                    local bs = math.clamp(80/dist, 20, 80); d.Box.Size, d.Box.Position, d.Box.BackgroundTransparency, d.Box.Visible = UDim2.new(0,bs,0,bs*1.8), UDim2.new(0,sp.X-bs/2,0,sp.Y-bs*0.9), 0.3+(1-fd)*0.5, true
                    d.Highlight.FillTransparency, d.Highlight.OutlineTransparency = 0.4+(1-fd)*0.4, 0.2+(1-fd)*0.3
                    local cx, cy = sp.X, sp.Y + bs*0.5; local sc = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2); local dx, dy = cx - sc.X, cy - sc.Y; local a = math.atan2(dy, dx); local len = math.clamp(math.sqrt(dx^2+dy^2), 20, 300)
                    d.Line.Size, d.Line.Position, d.Line.Rotation, d.Line.BackgroundTransparency, d.Line.Visible = UDim2.new(0,len,0,1), UDim2.new(0,sc.X,0,sc.Y), math.deg(a), 0.4+(1-fd)*0.3, true
                else d.Box.Visible, d.Line.Visible, d.Highlight.FillTransparency = false, false, 0.7 end
            end
        end
    end
end
local function tE()
    tA = not tA
    if tA then eB.Text, eB.BackgroundColor3, eB.TextColor3, sL.Text, sL.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "ESP ENABLED", Color3.fromRGB(0,200,255)
        if eC then pcall(function() eC:Disconnect() end) end
        for _, tg in pairs(P:GetPlayers()) do if tg ~= pl then cE(tg) end end
        eC = R.RenderStepped:Connect(uE)
        P.PlayerAdded:Connect(function(tg) task.wait(0.5); if tA then cE(tg) end end)
        P.PlayerRemoving:Connect(function(tg) if eO[tg] then pcall(function() if eO[tg].Highlight then eO[tg].Highlight:Destroy() end; if eO[tg].Box then eO[tg].Box:Destroy() end; if eO[tg].Line then eO[tg].Line:Destroy() end end); eO[tg] = nil end end)
    else eB.Text, eB.BackgroundColor3, eB.TextColor3, sL.Text, sL.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100), "ESP DISABLED", Color3.fromRGB(255,100,100)
        if eC then pcall(function() eC:Disconnect() end) end
        for _, d in pairs(eO) do if d.Highlight then d.Highlight:Destroy() end; if d.Box then d.Box:Destroy() end; if d.Line then d.Line:Destroy() end end
        eO = {}; task.wait(0.5); sL.Text, sL.TextColor3 = "Ready", Color3.fromRGB(0,255,150)
    end
end
eB.MouseButton1Click:Connect(tE); eB.TouchTap:Connect(tE)
local function tF3()
    fA = not fA
    if fA then fB2.Text, fB2.BackgroundColor3, fB2.TextColor3, sL.Text, sL.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Lighting ON", Color3.fromRGB(0,200,255)
        oL.Technology = L.Technology
        pcall(function() L.Technology = Enum.Technology.Future end)
        if L.Technology ~= Enum.Technology.Future then pcall(function() L.Technology = Enum.Technology.Realistic end) end
        L.GlobalShadows, L.ShadowSoftness = true, 0.5
    else fB2.Text, fB2.BackgroundColor3, fB2.TextColor3, sL.Text, sL.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100), "Lighting OFF", Color3.fromRGB(255,100,100)
        L.Technology, L.GlobalShadows, L.ShadowSoftness = oL.Technology, oL.GlobalShadows, oL.ShadowSoftness
        task.wait(0.5); sL.Text, sL.TextColor3 = "Ready", Color3.fromRGB(0,255,150)
    end
end
fB2.MouseButton1Click:Connect(tF3); fB2.TouchTap:Connect(tF3)
local function tR()
    rA = not rA
    if rA then rB.Text, rB.BackgroundColor3, rB.TextColor3, sL.Text, sL.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "RTX ENABLED", Color3.fromRGB(0,200,255)
        oL.Brightness, oL.ClockTime, oL.Ambient, oL.OutdoorAmbient, oL.ColorShift_Top, oL.ColorShift_Bottom, oL.EnvironmentDiffuseScale, oL.EnvironmentSpecularScale, oL.GlobalShadows, oL.ShadowSoftness, oL.Technology = L.Brightness, L.ClockTime, L.Ambient, L.OutdoorAmbient, L.ColorShift_Top, L.ColorShift_Bottom, L.EnvironmentDiffuseScale, L.EnvironmentSpecularScale, L.GlobalShadows, L.ShadowSoftness, L.Technology
        pcall(function() L.Technology = Enum.Technology.Future end)
        if L.Technology ~= Enum.Technology.Future then pcall(function() L.Technology = Enum.Technology.Realistic end) end
        local isN = L.ClockTime < 6 or L.ClockTime > 18
        if isN then L.Brightness, L.Ambient, L.OutdoorAmbient, L.ColorShift_Top, L.ColorShift_Bottom, L.ShadowSoftness, sL.Text = 0.4, Color3.fromRGB(20,20,30), Color3.fromRGB(15,15,25), Color3.fromRGB(10,15,30), Color3.fromRGB(5,5,15), 0.8, "RTX NIGHT MODE"
        else L.Brightness, L.Ambient, L.OutdoorAmbient, L.ColorShift_Top, L.ColorShift_Bottom, L.ShadowSoftness, sL.Text = 2.5, Color3.fromRGB(80,85,95), Color3.fromRGB(120,130,150), Color3.fromRGB(180,200,255), Color3.fromRGB(100,80,120), 0.5, "RTX DAY MODE" end
        L.EnvironmentDiffuseScale, L.EnvironmentSpecularScale, L.GlobalShadows = 1.5, 1.5, true
        local bm = L:FindFirstChild("Bloom"); if not bm then bm = Instance.new("BloomEffect", L); bm.Name = "Bloom" end; bm.Intensity, bm.Size, bm.Threshold = isN and 0.15 or 0.5, isN and 1 or 2, isN and 0.5 or 0.3
        local cc = L:FindFirstChild("ColorCorrection"); if not cc then cc = Instance.new("ColorCorrectionEffect", L); cc.Name = "ColorCorrection" end; cc.Saturation, cc.Contrast, cc.Brightness = isN and 0.8 or 1.1, isN and 0.9 or 1.1, isN and -0.1 or 0.05
        local sr = L:FindFirstChild("SunRays"); if not isN then if not sr then sr = Instance.new("SunRaysEffect", L); sr.Name = "SunRays" end; sr.Intensity, sr.Spread, sr.Enabled = 0.15, 0.5, true elseif sr then sr.Enabled = false end
        local df = L:FindFirstChild("DepthOfField"); if not df then df = Instance.new("DepthOfFieldEffect", L); df.Name = "DepthOfField" end; df.FarIntensity, df.FarBlurSize, df.NearIntensity, df.NearBlurSize, df.FocusDistance, df.InFocusRadius = isN and 0.1 or 0.3, isN and 1 or 2, 0, 0, isN and 30 or 50, isN and 20 or 30
        sL.TextColor3 = isN and Color3.fromRGB(100,150,255) or Color3.fromRGB(0,200,255)
    else rB.Text, rB.BackgroundColor3, rB.TextColor3, sL.Text, sL.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100), "RTX DISABLED", Color3.fromRGB(255,100,100)
        L.Brightness, L.ClockTime, L.Ambient, L.OutdoorAmbient, L.ColorShift_Top, L.ColorShift_Bottom, L.EnvironmentDiffuseScale, L.EnvironmentSpecularScale, L.GlobalShadows, L.ShadowSoftness, L.Technology = oL.Brightness, oL.ClockTime, oL.Ambient, oL.OutdoorAmbient, oL.ColorShift_Top, oL.ColorShift_Bottom, oL.EnvironmentDiffuseScale, oL.EnvironmentSpecularScale, oL.GlobalShadows, oL.ShadowSoftness, oL.Technology
        local bm = L:FindFirstChild("Bloom"); if bm then bm:Destroy() end; local cc = L:FindFirstChild("ColorCorrection"); if cc then cc:Destroy() end; local sr = L:FindFirstChild("SunRays"); if sr then sr:Destroy() end; local df = L:FindFirstChild("DepthOfField"); if df then df:Destroy() end
        task.wait(0.5); sL.Text, sL.TextColor3 = "Ready", Color3.fromRGB(0,255,150)
    end
end
rB.MouseButton1Click:Connect(tR); rB.TouchTap:Connect(tR)
local function tI()
    dIA = not dIA
    if dIA then iB2.Text, iB2.BackgroundColor3, iB2.TextColor3, sL.Text, sL.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Scanning infect...", Color3.fromRGB(0,255,100)
        if iC then pcall(function() iC:Disconnect() end); iC = nil end
        sDI(); iC = R.Heartbeat:Connect(function() if dIA then sDI() end end)
    else iB2.Text, iB2.BackgroundColor3, iB2.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        if iC then pcall(function() iC:Disconnect() end); iC = nil end
        local r = rI(); sL.Text = r > 0 and "Restored " .. r .. " infect" or "No infect to restore"; sL.TextColor3 = Color3.fromRGB(0,255,150)
    end
end
iB2.MouseButton1Click:Connect(tI); iB2.TouchTap:Connect(tI)
local function tK()
    dKA = not dKA
    if dKA then kB.Text, kB.BackgroundColor3, kB.TextColor3, sL.Text, sL.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Scanning kill...", Color3.fromRGB(0,255,100)
        if kC then pcall(function() kC:Disconnect() end); kC = nil end
        sDK(); kC = R.Heartbeat:Connect(function() if dKA then sDK() end end)
    else kB.Text, kB.BackgroundColor3, kB.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        if kC then pcall(function() kC:Disconnect() end); kC = nil end
        local r = rK(); sL.Text = r > 0 and "Restored " .. r .. " kill" or "No kill to restore"; sL.TextColor3 = Color3.fromRGB(0,255,150)
    end
end
kB.MouseButton1Click:Connect(tK); kB.TouchTap:Connect(tK)
local function tD()
    dDA = not dDA
    if dDA then dB.Text, dB.BackgroundColor3, dB.TextColor3, sL.Text, sL.TextColor3 = "ON", Color3.fromRGB(20,60,30), Color3.fromRGB(100,255,100), "Scanning doors...", Color3.fromRGB(0,255,100)
        if dC then pcall(function() dC:Disconnect() end); dC = nil end
        sDD(); dC = R.Heartbeat:Connect(function() if dDA then sDD() end end)
    else dB.Text, dB.BackgroundColor3, dB.TextColor3 = "OFF", Color3.fromRGB(40,20,20), Color3.fromRGB(255,100,100)
        if dC then pcall(function() dC:Disconnect() end); dC = nil end
        local r = rD(); sL.Text = r > 0 and "Restored " .. r .. " doors" or "No doors to restore"; sL.TextColor3 = Color3.fromRGB(0,255,150)
    end
end
dB.MouseButton1Click:Connect(tD); dB.TouchTap:Connect(tD)
local function swM()
    mp.Visible, pp.Visible, gp2.Visible, tp2.Visible, op.Visible = true, false, false, false, false
    tm.TextColor3, tp.TextColor3, tg.TextColor3, tth.TextColor3, to.TextColor3 = th[ct].ac, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function swP()
    mp.Visible, pp.Visible, gp2.Visible, tp2.Visible, op.Visible = false, true, false, false, false
    tp.TextColor3, tm.TextColor3, tg.TextColor3, tth.TextColor3, to.TextColor3 = th[ct].ac, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function swG()
    mp.Visible, pp.Visible, gp2.Visible, tp2.Visible, op.Visible = false, false, true, false, false
    tg.TextColor3, tm.TextColor3, tp.TextColor3, tth.TextColor3, to.TextColor3 = th[ct].ac, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function swT()
    mp.Visible, pp.Visible, gp2.Visible, tp2.Visible, op.Visible = false, false, false, true, false
    tth.TextColor3, tm.TextColor3, tp.TextColor3, tg.TextColor3, to.TextColor3 = th[ct].ac, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
local function swO()
    mp.Visible, pp.Visible, gp2.Visible, tp2.Visible, op.Visible = false, false, false, false, true
    to.TextColor3, tm.TextColor3, tp.TextColor3, tg.TextColor3, tth.TextColor3 = th[ct].ac, Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210), Color3.fromRGB(180,180,210)
end
tm.MouseButton1Click:Connect(swM); tm.TouchTap:Connect(swM)
tp.MouseButton1Click:Connect(swP); tp.TouchTap:Connect(swP)
tg.MouseButton1Click:Connect(swG); tg.TouchTap:Connect(swG)
tth.MouseButton1Click:Connect(swT); tth.TouchTap:Connect(swT)
to.MouseButton1Click:Connect(swO); to.TouchTap:Connect(swO)
mp.Visible, tm.TextColor3 = true, th.D.ac
local function mng()
    if im then return end; im = true; fr.Visible, mf.Visible, bl.Size = false, true, 0
end
local function umng()
    if not im then return end; im = false; fr.Visible, mf.Visible, bl.Size = true, false, 3
end
mn.MouseButton1Click:Connect(mng); mn.TouchTap:Connect(mng)
mf.MouseButton1Click:Connect(umng); mf.TouchTap:Connect(umng)
cl.MouseButton1Click:Connect(function()
    if io then io, fr.Visible, mf.Visible, cl.Text, cl.TextColor3, bl.Size = false, false, false, "▶", Color3.fromRGB(100,255,100), 0
    else io, fr.Visible, cl.Text, cl.TextColor3 = true, true, "✕", th[ct].ac; if not im then bl.Size = 3 end end
end)
cl.TouchTap:Connect(function()
    if io then io, fr.Visible, mf.Visible, cl.Text, cl.TextColor3, bl.Size = false, false, false, "▶", Color3.fromRGB(100,255,100), 0
    else io, fr.Visible, cl.Text, cl.TextColor3 = true, true, "✕", th[ct].ac; if not im then bl.Size = 3 end end
end)
U.InputBegan:Connect(function(i, gp2)
    if gp2 then return end
    if i.KeyCode == Enum.KeyCode.Insert then
        if io then io, fr.Visible, mf.Visible, cl.Text, cl.TextColor3, bl.Size = false, false, false, "▶", Color3.fromRGB(100,255,100), 0
        else io, fr.Visible, cl.Text, cl.TextColor3 = true, true, "✕", th[ct].ac; if not im then bl.Size = 3 end end
    end
end)
task.wait(0.3)
fr.Visible, fr.BackgroundTransparency, fr.Size, fr.Position, bl.Size, mf.Visible, cl.Text, sb.Visible, fU.Visible, fD.Visible = true, 0.08, UDim2.new(0,360,0,340), UDim2.new(0.5,-180,0.5,-170), 3, false, "✕", false, false, false
print("NZ-IS v6 - LOADED!")
