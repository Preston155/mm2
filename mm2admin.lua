-- MM2 Admin - Fixed for GitHub Loadstring
-- CanvasSize issue resolved

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Role System
local RoleSys = {Roles = {}, Colors = {Murderer = Color3.fromRGB(255, 0, 60), Sheriff = Color3.fromRGB(0, 120, 255), Innocent = Color3.fromRGB(0, 255, 100), Unknown = Color3.fromRGB(150, 150, 150)}}

function RoleSys:Detect(p)
    if not p then return "Unknown" end
    local bp = p:FindFirstChild("Backpack")
    local char = p.Character
    local function check(c)
        if not c then return nil end
        for _, t in pairs(c:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("knife") then return "Murderer" end
                if n:find("gun") then return "Sheriff" end
            end
        end
        return nil
    end
    return check(char) or check(bp) or "Innocent"
end

function RoleSys:Update()
    for _, p in pairs(Players:GetPlayers()) do self.Roles[p] = self:Detect(p) end
end

function RoleSys:Get(p) return self.Roles[p] or self:Detect(p) end

-- Settings
local Settings = {Aimbot = {Enabled = false, FOV = 150, Smooth = 0.15}, Combat = {KillAura = false, Range = 15}, Fly = false, Noclip = false}

-- GUI
local function getParent()
    if gethui then return gethui() end
    if syn and syn.protect_gui then local g = Instance.new("ScreenGui") syn.protect_gui(g) g.Parent = game.CoreGui return g end
    return game.CoreGui
end

local SG = Instance.new("ScreenGui")
SG.Name = "MM2_" .. tostring(math.random(10000, 99999))
SG.ResetOnSpawn = false
pcall(function() SG.Parent = getParent() end)
if not SG.Parent then SG.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 550, 0, 400)
Main.Position = UDim2.new(0.5, -275, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 10)
mc.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "MM2 ADVANCED"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

-- Role Display
local RoleFrame = Instance.new("Frame")
RoleFrame.Size = UDim2.new(0, 300, 0, 35)
RoleFrame.Position = UDim2.new(0.5, -150, 0, 7)
RoleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
RoleFrame.Parent = Main

local rfc = Instance.new("UICorner")
rfc.CornerRadius = UDim.new(0, 6)
rfc.Parent = RoleFrame

local MLabel = Instance.new("TextLabel")
MLabel.Size = UDim2.new(0.33, 0, 1, 0)
MLabel.BackgroundTransparency = 1
MLabel.Text = "Murderer: None"
MLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
MLabel.TextSize = 11
MLabel.Font = Enum.Font.GothamBold
MLabel.Parent = RoleFrame

local SLabel = Instance.new("TextLabel")
SLabel.Size = UDim2.new(0.33, 0, 1, 0)
SLabel.Position = UDim2.new(0.33, 0, 0, 0)
SLabel.BackgroundTransparency = 1
SLabel.Text = "Sheriff: None"
SLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
SLabel.TextSize = 11
SLabel.Font = Enum.Font.GothamBold
SLabel.Parent = RoleFrame

local ILabel = Instance.new("TextLabel")
ILabel.Size = UDim2.new(0.33, 0, 1, 0)
ILabel.Position = UDim2.new(0.66, 0, 0, 0)
ILabel.BackgroundTransparency = 1
ILabel.Text = "Innocents: 0"
ILabel.TextColor3 = Color3.fromRGB(100, 255, 100)
ILabel.TextSize = 11
ILabel.Font = Enum.Font.GothamBold
ILabel.Parent = RoleFrame

-- Close
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.Parent = Main

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 6)
cc.Parent = Close

-- Content Frame
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -90)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Content.Parent = Main

local contc = Instance.new("UICorner")
contc.CornerRadius = UDim.new(0, 8)
contc.Parent = Content

-- Tab Buttons Frame
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -10, 0, 40)
TabFrame.Position = UDim2.new(0, 5, 0, 5)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Content

-- Tab Content Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -10, 1, -50)
TabContainer.Position = UDim2.new(0, 5, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Content

-- Tabs
local TabBtns = {}
local TabConts = {}
local CurrentTab = nil

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -5, 1, 0)
    btn.Position = UDim2.new((#TabBtns) * 0.25, 2, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabFrame
    
    local cont = Instance.new("ScrollingFrame")
    cont.Size = UDim2.new(1, 0, 1, 0)
    cont.BackgroundTransparency = 1
    cont.BorderSizePixel = 0
    cont.ScrollBarThickness = 4
    cont.Visible = false
    cont.AutomaticCanvasSize = Enum.AutomaticSize.Y
    cont.CanvasSize = UDim2.new(0, 0, 0, 0)
    cont.Parent = TabContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = cont
    
    local pad = Instance.new("UIPadding")
    pad.Padding = UDim.new(0, 5)
    pad.Parent = cont
    
    table.insert(TabBtns, btn)
    table.insert(TabConts, cont)
    
    btn.MouseButton1Click:Connect(function()
        for i, b in pairs(TabBtns) do
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            TabConts[i].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        cont.Visible = true
        CurrentTab = cont
    end)
    
    return cont
end

local CombatTab = CreateTab("COMBAT")
local VisualTab = CreateTab("VISUAL")
local TpTab = CreateTab("TELEPORT")
local MiscTab = CreateTab("MISC")

TabBtns[1].BackgroundColor3 = Color3.fromRGB(255, 50, 50)
TabConts[1].Visible = true

-- UI Helpers
local function Toggle(parent, txt, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 40)
    f.BackgroundTransparency = 1
    f.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.TextSize = 13
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 50, 0, 26)
    b.Position = UDim2.new(1, -50, 0.5, -13)
    b.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    b.Text = "OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = f
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 13)
    bc.Parent = b
    
    local e = false
    b.MouseButton1Click:Connect(function()
        e = not e
        b.BackgroundColor3 = e and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        b.Text = e and "ON" or "OFF"
        callback(e)
    end)
end

local function Slider(parent, txt, min, max, def, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 50)
    f.BackgroundTransparency = 1
    f.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = txt .. ": " .. def
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 8)
    bg.Position = UDim2.new(0, 0, 0, 28)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    bg.BorderSizePixel = 0
    bg.Parent = f
    
    local bgc = Instance.new("UICorner")
    bgc.CornerRadius = UDim.new(0, 4)
    bgc.Parent = bg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    fill.BorderSizePixel = 0
    fill.Parent = bg
    
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 4)
    fc.Parent = fill
    
    local drag = false
    bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local p = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (p * (max - min)))
            fill.Size = UDim2.new(p, 0, 1, 0)
            l.Text = txt .. ": " .. v
            callback(v)
        end
    end)
end

local function Btn(parent, txt, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.Parent = parent
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = b
    
    b.MouseButton1Click:Connect(callback)
    return b
end

-- COMBAT TAB CONTENT
Toggle(CombatTab, "Aimbot (Hold RMB)", function(v) Settings.Aimbot.Enabled = v end)
Toggle(CombatTab, "Kill Aura", function(v) Settings.Combat.KillAura = v end)
Slider(CombatTab, "Aimbot FOV", 50, 400, 150, function(v) Settings.Aimbot.FOV = v end)
Slider(CombatTab, "Kill Range", 5, 30, 15, function(v) Settings.Combat.Range = v end)

Btn(CombatTab, "Kill All (Murderer Only)", function()
    if RoleSys:Get(LocalPlayer) ~= "Murderer" then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local m = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r and m then m.CFrame = r.CFrame task.wait(0.2) end
        end
    end
end)

Btn(CombatTab, "Kill Murderer (Sheriff Only)", function()
    if RoleSys:Get(LocalPlayer) ~= "Sheriff" then return end
    for _, p in pairs(Players:GetPlayers()) do
        if RoleSys:Get(p) == "Murderer" and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local m = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r and m then m.CFrame = r.CFrame + Vector3.new(0, 0, 5) task.wait(0.2) end
        end
    end
end)

Btn(CombatTab, "Kill Sheriff (Murderer Only)", function()
    if RoleSys:Get(LocalPlayer) ~= "Murderer" then return end
    for _, p in pairs(Players:GetPlayers()) do
        if RoleSys:Get(p) == "Sheriff" and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local m = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r and m then m.CFrame = r.CFrame task.wait(0.2) end
        end
    end
end)

-- VISUAL TAB CONTENT
Toggle(VisualTab, "ESP", function(v)
    if v then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = Instance.new("Highlight")
                hl.Name = "MM2ESP"
                hl.FillTransparency = 0.6
                hl.OutlineTransparency = 0
                hl.FillColor = RoleSys.Colors[RoleSys:Get(p)]
                hl.Parent = p.Character
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                for _, c in pairs(p.Character:GetChildren()) do if c.Name == "MM2ESP" then c:Destroy() end end
            end
        end
    end
end)

Toggle(VisualTab, "Tracers", function(v)
    -- Tracers implementation would go here
end)

-- TELEPORT TAB CONTENT
local PlrList = Instance.new("ScrollingFrame")
PlrList.Size = UDim2.new(1, -10, 0, 250)
PlrList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
PlrList.BorderSizePixel = 0
PlrList.ScrollBarThickness = 4
PlrList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlrList.Parent = TpTab

local plc = Instance.new("UICorner")
plc.CornerRadius = UDim.new(0, 6)
plc.Parent = PlrList

local listLay = Instance.new("UIListLayout")
listLay.Padding = UDim.new(0, 5)
listLay.Parent = PlrList

local pad = Instance.new("UIPadding")
pad.Padding = UDim.new(0, 5)
pad.Parent = PlrList

-- MISC TAB CONTENT
Toggle(MiscTab, "Fly (Press F)", function(v) Settings.Fly = v end)
Toggle(MiscTab, "Noclip (Press N)", function(v) Settings.Noclip = v end)
Slider(MiscTab, "WalkSpeed", 16, 200, 16, function(v)
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = v end
end)

-- FOV Circle
local Circle = Drawing.new("Circle")
Circle.Thickness = 1.5
Circle.Color = Color3.fromRGB(255, 50, 50)
Circle.Filled = false

-- Aimbot
local function GetTarget()
    local mr = RoleSys:Get(LocalPlayer)
    local tr = nil
    if mr == "Sheriff" then tr = "Murderer"
    elseif mr == "Murderer" then tr = "Sheriff" end
    
    local closest = nil
    local maxDist = Settings.Aimbot.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if tr and RoleSys:Get(p) ~= tr then continue end
            local h = p.Character:FindFirstChild("Head")
            if h then
                local pos, vis = Camera:WorldToViewportPoint(h.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < maxDist then maxDist = dist closest = h end
                end
            end
        end
    end
    return closest
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    Circle.Visible = Settings.Aimbot.Enabled
    Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    Circle.Radius = Settings.Aimbot.FOV
    
    if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetTarget()
        if t then
            local p = Camera:WorldToViewportPoint(t.Position)
            local m = UserInputService:GetMouseLocation()
            mousemoverel((p.X - m.X) * Settings.Aimbot.Smooth, (p.Y - m.Y) * Settings.Aimbot.Smooth)
        end
    end
    
    if Settings.Combat.KillAura then
        local mr = RoleSys:Get(LocalPlayer)
        local mp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if mp then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local pr = p.Character:FindFirstChild("HumanoidRootPart")
                    if pr and (mp.Position - pr.Position).Magnitude <= Settings.Combat.Range then
                        if (mr == "Murderer" and RoleSys:Get(p) ~= "Murderer") or (mr == "Sheriff" and RoleSys:Get(p) == "Murderer") then
                            mp.CFrame = pr.CFrame
                        end
                    end
                end
            end
        end
    end
    
    if Settings.Noclip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end)

-- Fly
local FlyVel, FlyGyro = nil, nil
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F then
        Settings.Fly = not Settings.Fly
        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r then
            if Settings.Fly then
                FlyGyro = Instance.new("BodyGyro")
                FlyGyro.P = 9e4
                FlyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                FlyGyro.CFrame = r.CFrame
                FlyGyro.Parent = r
                
                FlyVel = Instance.new("BodyVelocity")
                FlyVel.Velocity = Vector3.zero
                FlyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                FlyVel.Parent = r
                
                task.spawn(function()
                    while Settings.Fly and r.Parent do
                        local v = Vector3.zero
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + Camera.CFrame.LookVector * 50 end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - Camera.CFrame.LookVector * 50 end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - Camera.CFrame.RightVector * 50 end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + Camera.CFrame.RightVector * 50 end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0, 50, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v = v - Vector3.new(0, 50, 0) end
                        FlyVel.Velocity = v
                        FlyGyro.CFrame = Camera.CFrame
                        task.wait()
                    end
                end)
            else
                if FlyGyro then FlyGyro:Destroy() end
                if FlyVel then FlyVel:Destroy() end
            end
        end
    elseif i.KeyCode == Enum.KeyCode.N then
        Settings.Noclip = not Settings.Noclip
    elseif i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- Update Roles & Player List
local function UpdateList()
    for _, c in pairs(PlrList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    
    RoleSys:Update()
    local m, s, ic = "None", "None", 0
    
    for p, r in pairs(RoleSys.Roles) do
        if r == "Murderer" then m = p.Name elseif r == "Sheriff" then s = p.Name elseif r == "Innocent" then ic = ic + 1 end
        
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 32)
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            b.Text = p.Name .. " [" .. r .. "]"
            b.TextColor3 = RoleSys.Colors[r]
            b.TextSize = 12
            b.Font = Enum.Font.GothamBold
            b.Parent = PlrList
            
            local bcc = Instance.new("UICorner")
            bcc.CornerRadius = UDim.new(0, 4)
            bcc.Parent = b
            
            b.MouseButton1Click:Connect(function()
                local myR = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local tR = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if myR and tR then myR.CFrame = tR.CFrame + Vector3.new(0, 3, 0) end
            end)
        end
    end
    
    MLabel.Text = "Murderer: " .. m
    SLabel.Text = "Sheriff: " .. s
    ILabel.Text = "Innocents: " .. ic
end

task.spawn(function() while task.wait(1) do UpdateList() end end)

Close.MouseButton1Click:Connect(function() Circle:Remove() SG:Destroy() end)

-- Anti AFK
local VU = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function() VU:Button2Down(Vector2.new(0,0), Camera.CFrame) task.wait(1) VU:Button2Up(Vector2.new(0,0), Camera.CFrame) end)
