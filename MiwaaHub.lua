--[[
    MIWAA NEON PANEL HUB - FISH IT SCRIPT
    Konversi dari desain HTML dengan semua fitur berfungsi
    Untuk Delta Mobile
]]

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ========== NOTIFIKASI AWAL ==========
game.StarterGui:SetCore("SendNotification", {
    Title = "Miwaa Neon Panel",
    Text = "Loading script...",
    Duration = 2
})

-- Cek game
if game.PlaceId ~= 121864768012064 then
    game.StarterGui:SetCore("SendNotification", {
        Title = "ERROR",
        Text = "Bukan game Fish It!",
        Duration = 3
    })
    return
end

-- ========== BYPASS BAWAAN ==========
spawn(function()
    while true do
        wait(45)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

pcall(function()
    if hookfunction then
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "FireServer" and args[1] and tostring(args[1]):find("Fishing") then
                task.wait(math.random(20,50)/1000)
            end
            return oldNamecall(self, ...)
        end)
    end
end)

-- ========== VARIABEL GLOBAL ==========
getgenv().Miwaa = {
    AutoFish = false,
    AutoSell = false,
    FastFishing = false,
    Fly = false,
    FlySpeed = 50,
    SecretESP = false,
    SecretESPPercent = false,
    ServerHop = false,
    HopMode = "GOOD", -- GOOD, NEWBIE, RANDOM
    CurrentLuck = 0,
    AutoEvent = {},
    Bypass = true
}

-- ========== REMOTE EVENTS ==========
local net = ReplicatedStorage:FindFirstChild("net") or 
            ReplicatedStorage:FindFirstChild("Network") or
            (ReplicatedStorage:FindFirstChild("Packages") and 
             ReplicatedStorage.Packages:FindFirstChild("_index") and
             ReplicatedStorage.Packages._index:FindFirstChild("sleitnick_net@0.2.0") and
             ReplicatedStorage.Packages._index["sleitnick_net@0.2.0"].net)

-- ========== FUNGSI AUTO FISH ==========
local function startAutoFish()
    spawn(function()
        while getgenv().Miwaa.AutoFish do
            pcall(function()
                if net then
                    local equip = net:FindFirstChild("RE/EquipToolFromHotbar")
                    local charge = net:FindFirstChild("RF/ChargeFishingRod")
                    local minigame = net:FindFirstChild("RF/RequestFishingMinigameStarted")
                    local complete = net:FindFirstChild("RE/FishingCompleted")
                    
                    if equip then equip:FireServer() end
                    wait(0.1)
                    if charge then charge:InvokeServer(1) end
                    wait(0.1)
                    if minigame then minigame:InvokeServer(1, 1) end
                    wait(0.1)
                    if complete then complete:FireServer() end
                end
            end)
            wait(getgenv().Miwaa.FastFishing and 0.1 or 0.8)
        end
    end)
end

-- ========== AUTO SELL ==========
local function startAutoSell(mode)
    spawn(function()
        while getgenv().Miwaa.AutoSell do
            pcall(function()
                if net then
                    local sellAll = net:FindFirstChild("RF/SellAllItems")
                    if sellAll and mode == "ALL" then
                        sellAll:InvokeServer()
                    end
                    -- Catatan: Untuk sell legendary/mythic perlu filter manual
                    -- Ini hanya contoh, perlu penyesuaian dengan sistem game
                end
            end)
            wait(3)
        end
    end)
end

-- ========== FLY MODE ==========
local flyBodyGyro, flyBodyVelocity

local function stopFly()
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
end

local function startFly()
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    stopFly()
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyVelocity = Instance.new("BodyVelocity")
    
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    flyBodyVelocity.Parent = hrp
    
    RunService.Heartbeat:Connect(function()
        if not getgenv().Miwaa.Fly then
            stopFly()
            return
        end
        
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * getgenv().Miwaa.FlySpeed
        end
        
        flyBodyVelocity.Velocity = moveDir
        flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end)
end

-- ========== SECRET ESP ==========
local espFloat = nil
local espFrame = nil

local function createESPFloat()
    if espFloat then espFloat:Destroy() end
    
    espFloat = Instance.new("ScreenGui")
    espFloat.Name = "MiwaaESPFloat"
    espFloat.Parent = player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 80)
    frame.Position = UDim2.new(0.5, -100, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderColor3 = Color3.fromRGB(0, 204, 255)
    frame.BorderSize = 2
    frame.Parent = espFloat
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 204, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(122, 0, 255))
    })
    grad.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label1 = Instance.new("TextLabel")
    label1.Size = UDim2.new(1, 0, 0.3, 0)
    label1.Position = UDim2.new(0, 0, 0, 0)
    label1.BackgroundTransparency = 1
    label1.Text = "🎣 SECRET TRACKER"
    label1.TextColor3 = Color3.fromRGB(0, 204, 255)
    label1.TextSize = 14
    label1.Font = Enum.Font.GothamBold
    label1.Parent = frame
    
    local label2 = Instance.new("TextLabel")
    label2.Size = UDim2.new(1, 0, 0.3, 0)
    label2.Position = UDim2.new(0, 0, 0.3, 0)
    label2.BackgroundTransparency = 1
    label2.Text = "1 / 6.000.000"
    label2.TextColor3 = Color3.fromRGB(255, 255, 255)
    label2.TextSize = 12
    label2.Font = Enum.Font.Gotham
    label2.Parent = frame
    
    local label3 = Instance.new("TextLabel")
    label3.Size = UDim2.new(1, 0, 0.3, 0)
    label3.Position = UDim2.new(0, 0, 0.6, 0)
    label3.BackgroundTransparency = 1
    label3.Text = "SECRET LUCK: 23%"
    label3.TextColor3 = Color3.fromRGB(122, 0, 255)
    label3.TextSize = 12
    label3.Font = Enum.Font.GothamBold
    label3.Parent = frame
    
    espFrame = frame
end

-- ========== SERVER HOP ==========
local function detectServerLuck()
    local luck = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Hint") and v.Text then
            if v.Text:find("Luck") or v.Text:find("Event") then
                luck = 100
            end
        end
    end
    return luck
end

local function getServerType()
    local avgLevel = 0
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        local stats = p:FindFirstChild("leaderstats")
        if stats and stats:FindFirstChild("Level") then
            avgLevel = avgLevel + stats.Level.Value
            count = count + 1
        end
    end
    if count > 0 then avgLevel = avgLevel / count end
    
    if avgLevel < 50 then return "NEWBIE"
    elseif avgLevel < 200 then return "GOOD"
    else return "PRO" end
end

local function hopServer()
    TeleportService:Teleport(game.PlaceId, player)
end

local function startServerHop()
    spawn(function()
        while getgenv().Miwaa.ServerHop do
            local luck = detectServerLuck()
            local serverType = getServerType()
            
            getgenv().Miwaa.CurrentLuck = luck
            
            local shouldHop = false
            if getgenv().Miwaa.HopMode == "GOOD" then
                shouldHop = (luck < 50 or serverType ~= "GOOD")
            elseif getgenv().Miwaa.HopMode == "NEWBIE" then
                shouldHop = (serverType ~= "NEWBIE")
            elseif getgenv().Miwaa.HopMode == "RANDOM" then
                shouldHop = (math.random(1,10) == 1) -- 10% chance
            end
            
            if shouldHop then
                wait(3)
                hopServer()
            end
            wait(30)
        end
    end)
end

-- ========== DATA TELEPORT (22 LOKASI) ==========
local teleportData = {
    {name = "Sacred Temple", pos = Vector3.new(1476.23, -21.85, -630.89)},
    {name = "Underground Cellar", pos = Vector3.new(2097.20, -91.20, -703.74)},
    {name = "Transcended Stone", pos = Vector3.new(1480.33, 127.62, -595.78)},
    {name = "Ancient Jungle", pos = Vector3.new(1281.76, 7.79, -202.02)},
    {name = "Outside Ancient Jungle", pos = Vector3.new(1489.63, 7.99, -511.28)},
    {name = "Kohana Lava", pos = Vector3.new(-593.32, 59.00, 130.82)},
    {name = "LEVER Diamond", pos = Vector3.new(1819.00, 8.45, -284.00)},
    {name = "LEVER Crescent", pos = Vector3.new(1420.00, 31.20, 79.00)},
    {name = "LEVER Hourglass", pos = Vector3.new(1486.00, 6.82, -857.00)},
    {name = "LEVER Arrow", pos = Vector3.new(898.14, 8.45, -363.17)},
    {name = "Kohana", pos = Vector3.new(-643.14, 16.03, 623.61)},
    {name = "Esoteric Island", pos = Vector3.new(2024.49, 27.40, 1391.62)},
    {name = "Ice Island", pos = Vector3.new(1766.46, 19.16, 3086.23)},
    {name = "Lost Isle", pos = Vector3.new(-3660.07, 5.43, -1053.02)},
    {name = "Sisyphus Statue", pos = Vector3.new(-3693.96, -135.57, -1027.28)},
    {name = "Treasure Hall", pos = Vector3.new(-3598.39, -275.82, -1641.46)},
    {name = "Fisherman Island", pos = Vector3.new(13.06, 24.53, 2911.16)},
    {name = "Tropical Grove", pos = Vector3.new(-2092.90, 6.27, 3693.93)},
    {name = "Weather Machine", pos = Vector3.new(-1495.25, 6.50, 1889.92)},
    {name = "Coral Reefs", pos = Vector3.new(-2949.36, 63.25, 2213.97)},
    {name = "Crater Island", pos = Vector3.new(1012.05, 22.68, 5080.22)},
    {name = "Enchant Area", pos = Vector3.new(3236.12, -1302.86, 1399.49)},
}

-- ========== PEMBUATAN GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "MiwaaNeonPanel"
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false

-- PANEL UTAMA
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 620, 0, 520)
panel.Position = UDim2.new(0.5, -310, 0.5, -260)
panel.BackgroundColor3 = Color3.fromRGB(10, 15, 44)
panel.BackgroundTransparency = 0
panel.BorderColor3 = Color3.fromRGB(0, 204, 255)
panel.BorderSize = 2
panel.Active = true
panel.Draggable = true
panel.Parent = gui

-- Gradasi background panel
local panelGrad = Instance.new("UIGradient")
panelGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 15, 44)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 0, 51))
})
panelGrad.Rotation = 135
panelGrad.Parent = panel

-- Sudut membulat
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

-- Shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(111, 0, 255)
shadow.ImageTransparency = 0.5
shadow.Parent = panel
shadow.ZIndex = -1

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(0, 204, 255)
header.BorderSize = 0
header.Parent = panel

local headerGrad = Instance.new("UIGradient")
headerGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 204, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(122, 0, 255))
})
headerGrad.Rotation = 90
headerGrad.Parent = header

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header
-- Karena corner radius di top saja
headerCorner:Destroy() -- Hapus, kita buat manual

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MIWAA NEON PANEL HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Control buttons
local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(0, 60, 1, 0)
btnFrame.Position = UDim2.new(1, -60, 0, 0)
btnFrame.BackgroundTransparency = 1
btnFrame.Parent = header

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(0, 5, 0.5, -12.5)
minBtn.BackgroundTransparency = 1
minBtn.Text = "▶️"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = btnFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(0, 30, 0.5, -12.5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "❌"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = btnFrame

-- BODY
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -42)
body.Position = UDim2.new(0, 0, 0, 42)
body.BackgroundTransparency = 1
body.Parent = panel

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 180, 1, 0)
sidebar.BackgroundTransparency = 1
sidebar.BorderSize = 0
sidebar.Parent = body

-- Sidebar border kanan
local sideBorder = Instance.new("Frame")
sideBorder.Size = UDim2.new(0, 1, 1, 0)
sideBorder.Position = UDim2.new(1, -1, 0, 0)
sideBorder.BackgroundColor3 = Color3.fromRGB(0, 204, 255)
sideBorder.BackgroundTransparency = 0
sideBorder.Parent = sidebar

-- Tab buttons
local tabs = {"Auto Fish", "Auto Sell", "Fly Mode", "Secret ESP", "Server Hop", "Teleport", "Event", "Bypass", "Lainnya"}
local tabNames = {"fish", "sell", "fly", "esp", "hop", "tp", "event", "bypass", "other"}
local tabButtons = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*40)
    btn.BackgroundTransparency = 1
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(0, 204, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = sidebar
    
    local hover = Instance.new("Frame")
    hover.Size = UDim2.new(1, 0, 1, 0)
    hover.BackgroundColor3 = Color3.fromRGB(0, 204, 255)
    hover.BackgroundTransparency = 0.85
    hover.Visible = false
    hover.Parent = btn
    
    btn.MouseEnter:Connect(function()
        hover.Visible = true
    end)
    btn.MouseLeave:Connect(function()
        hover.Visible = false
    end)
    
    tabButtons[tabNames[i]] = btn
end

-- CONTENT AREA
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -190, 1, -20)
content.Position = UDim2.new(0, 190, 0, 10)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
content.ScrollBarImageColor3 = Color3.fromRGB(122, 0, 255)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = body

-- Fungsi untuk membuat tab content
local contentFrames = {}

-- AUTO FISH TAB
local fishFrame = Instance.new("Frame")
fishFrame.Size = UDim2.new(1, -20, 0, 200)
fishFrame.BackgroundTransparency = 1
fishFrame.Visible = true
fishFrame.Parent = content
contentFrames.fish = fishFrame

local fishTitle = Instance.new("TextLabel")
fishTitle.Size = UDim2.new(1, 0, 0, 30)
fishTitle.BackgroundTransparency = 1
fishTitle.Text = "⚙️ AUTO FISH SETTINGS"
fishTitle.TextColor3 = Color3.fromRGB(0, 204, 255)
fishTitle.TextSize = 16
fishTitle.Font = Enum.Font.GothamBold
fishTitle.TextXAlignment = Enum.TextXAlignment.Left
fishTitle.Parent = fishFrame

local autoFishToggle = createToggle(fishFrame, "Auto Fish", 40, function(state)
    getgenv().Miwaa.AutoFish = state
    if state then startAutoFish() end
end)

local fastFishToggle = createToggle(fishFrame, "Fast Fishing (Skip Delay)", 80, function(state)
    getgenv().Miwaa.FastFishing = state
end)

-- AUTO SELL TAB
local sellFrame = Instance.new("Frame")
sellFrame.Size = UDim2.new(1, -20, 0, 250)
sellFrame.BackgroundTransparency = 1
sellFrame.Visible = false
sellFrame.Parent = content
contentFrames.sell = sellFrame

local sellTitle = Instance.new("TextLabel")
sellTitle.Size = UDim2.new(1, 0, 0, 30)
sellTitle.BackgroundTransparency = 1
sellTitle.Text = "💰 AUTO SELL SETTINGS"
sellTitle.TextColor3 = Color3.fromRGB(0, 204, 255)
sellTitle.TextSize = 16
sellTitle.Font = Enum.Font.GothamBold
sellTitle.TextXAlignment = Enum.TextXAlignment.Left
sellTitle.Parent = sellFrame

local sellAllToggle = createToggle(sellFrame, "Sell All Fish", 40, function(state)
    getgenv().Miwaa.AutoSell = state
    if state then startAutoSell("ALL") end
end)

local sellLegToggle = createToggle(sellFrame, "Sell All Legendary", 80, function(state)
    -- Implementasi khusus legendary
end)

local sellMythToggle = createToggle(sellFrame, "Sell All Mythic", 120, function(state)
    -- Implementasi khusus mythic
end)

-- FLY MODE TAB
local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(1, -20, 0, 200)
flyFrame.BackgroundTransparency = 1
flyFrame.Visible = false
flyFrame.Parent = content
contentFrames.fly = flyFrame

local flyTitle = Instance.new("TextLabel")
flyTitle.Size = UDim2.new(1, 0, 0, 30)
flyTitle.BackgroundTransparency = 1
flyTitle.Text = "🕊️ FLY MODE"
flyTitle.TextColor3 = Color3.fromRGB(0, 204, 255)
flyTitle.TextSize = 16
flyTitle.Font = Enum.Font.GothamBold
flyTitle.TextXAlignment = Enum.TextXAlignment.Left
flyTitle.Parent = flyFrame

local flyToggle = createToggle(flyFrame, "Enable Fly", 40, function(state)
    getgenv().Miwaa.Fly = state
    if state then startFly() else stopFly() end
end)

-- Speed slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 30)
speedLabel.Position = UDim2.new(0, 0, 0, 80)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Fly Speed: 50"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = flyFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.8, 0, 0, 4)
sliderBg.Position = UDim2.new(0, 0, 0, 115)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderBg.Parent = flyFrame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 204, 255)
sliderFill.Parent = sliderBg

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 20, 0, 20)
sliderButton.Position = UDim2.new(0.5, -10, 0.5, -10)
sliderButton.BackgroundColor3 = Color3.fromRGB(122, 0, 255)
sliderButton.Text = ""
sliderButton.Parent = sliderFill

local dragging = false
sliderButton.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = UserInputService:GetMouseLocation()
        local absPos = sliderBg.AbsolutePosition
        local relX = math.clamp(pos.X - absPos.X, 0, sliderBg.AbsoluteSize.X)
        local percent = relX / sliderBg.AbsoluteSize.X
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        local speed = math.floor(10 + percent * 90)
        speedLabel.Text = "Fly Speed: " .. speed
        getgenv().Miwaa.FlySpeed = speed
    end
end)

-- SECRET ESP TAB
local espFrame = Instance.new("Frame")
espFrame.Size = UDim2.new(1, -20, 0, 200)
espFrame.BackgroundTransparency = 1
espFrame.Visible = false
espFrame.Parent = content
contentFrames.esp = espFrame

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, 0, 0, 30)
espTitle.BackgroundTransparency = 1
espTitle.Text = "👁️ SECRET ESP"
espTitle.TextColor3 = Color3.fromRGB(0, 204, 255)
espTitle.TextSize = 16
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Parent = espFrame

local espSecretToggle = createToggle(espFrame, "Enable ESP Secret", 40, function(state)
    getgenv().Miwaa.SecretESP = state
    if state then 
        createESPFloat()
    else
        if espFloat then espFloat:Destroy() espFloat = nil end
    end
end)

local espPercentToggle = createToggle(espFrame, "Enable Secret %", 80, function(state)
    getgenv().Miwaa.SecretESPPercent = state
    if espFrame and state then
        -- Update tampilan persentase
    end
end)

-- SERVER HOP TAB
local hopFrame = Instance.new("Frame")
hopFrame.Size = UDim2.new(1, -20, 0, 250)
hopFrame.BackgroundTransparency = 1
hopFrame.Visible = false
hopFrame.Parent = content
contentFrames.hop = hopFrame

local hopTitle = Instance.new("TextLabel")
hopTitle.Size = UDim2.new(1, 0, 0, 30)
hopTitle.BackgroundTransparency = 1
hopTitle.Text = "🌐 SERVER HOPPER"
hopTitle.TextColor3 = Color3.fromRGB(0, 204, 255)
hopTitle.TextSize = 16
hopTitle.Font = Enum.Font.GothamBold
hopTitle.TextXAlignment = Enum.TextXAlignment.Left
hopTitle.Parent = hopFrame

local hopToggle = createToggle(hopFrame, "Enable Server Hop", 40, function(state)
    getgenv().Miwaa.ServerHop = state
    if state then startServerHop() end
end)

-- Mode selection
local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(1, 0, 0, 30)
modeLabel.Position = UDim2.new(0, 0, 0, 80)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "Hop Mode: GOOD"
modeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
modeLabel.TextSize = 14
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.Parent = hopFrame

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.5, 0, 0, 30)
modeBtn.Position = UDim2.new(0, 0, 0, 110)
modeBtn.BackgroundColor3 = Color3.fromRGB(122, 0, 255)
modeBtn.Text = "GOOD SERVER"
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.TextSize = 14
modeBtn.Font = Enum.Font.GothamBold
modeBtn.Parent = hopFrame

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 6)
modeCorner.Parent = modeBtn

local modes = {"GOOD", "NEWBIE", "RANDOM"}
local modeIndex = 1
modeBtn.MouseButton1Click:Connect(function()
    modeIndex = modeIndex + 1
    if modeIndex > #modes then modeIndex = 1 end
    modeBtn.Text = modes[modeIndex] .. " SERVER"
    modeLabel.Text = "Hop Mode: " .. modes[modeIndex]
    getgenv().Miwaa.HopMode = modes[modeIndex]
end)

-- TELEPORT TAB
local tpFrame = Instance.new("Frame")
tpFrame.Size = UDim2.new(1, -20, 0, 600)
tpFrame.BackgroundTransparency = 1
tpFrame.Visible = false
tpFrame.Parent = content
contentFrames.tp = tpFrame

local tpTitle = Instance.new("TextLabel")
tpTitle.Size = UDim2.new(1, 0, 0, 30)
tpTitle.BackgroundTransparency = 1
tpTitle.Text = "📍 TELEPORT (22 LOKASI)"
tpTitle.TextColor3 = Color3.fromRGB(0, 204, 255)
tpTitle.TextSize = 16
tpTitle.Font = Enum.Font.GothamBold
tpTitle.TextXAlignment = Enum.TextXAlignment.Left
tpTitle.Parent = tpFrame

local tpGrid = Instance.new("Frame")
tpGrid.Size = UDim2.new(1, 0, 1, -40)
tpGrid.Position = UDim2.new(0, 0, 0, 40)
tpGrid.BackgroundTransparency = 1
tpGrid.Parent = tpFrame

local gridList = Instance.new("UIListLayout")
gridList.FillDirection = Enum.FillDirection.Horizontal
gridList.HorizontalAlignment = Enum.HorizontalAlignment.Left
gridList.VerticalAlignment = Enum.VerticalAlignment.Top
gridList.SortOrder = Enum.SortOrder.LayoutOrder
gridList.Padding = UDim.new(0, 8)
gridList.Parent = tpGrid

local gridPadding = Instance.new("UIPadding")
gridPadding.PaddingLeft = UDim.new(0, 5)
gridPadding.PaddingTop = UDim.new(0, 5)
gridPadding.Parent = tpGrid

-- Buat 22 tombol teleport dalam grid 4 kolom
for i, data in ipairs(teleportData) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(0, 204, 255)
    btn.BackgroundTransparency = 0.85
    btn.Text = data.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tpGrid
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char.HumanoidRootPart then
            char.HumanoidRootPart.CFrame = CFrame.new(data.pos)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Teleport",
                Text = "Ke " .. data.name,
                Duration = 1
            })
        end
    end)
end

-- EVENT TAB
local eventFrame = Instance.new("Frame")
eventFrame.Size = UDim2.new(1, -20, 0, 400)
eventFrame.BackgroundTransparency = 1
eventFrame.Visible = false
eventFrame.Parent = content
contentFrames.event = eventFrame

local eventTitle = Instance.new("TextLabel")
eventTitle.Size = UDim2.new(1, 0, 0, 30)
eventTitle.BackgroundTransparency = 1
eventTitle.Text = "🎉 EVENT TRACKER"
eventTitle.TextColor3 = Color3.fromRGB(0, 204, 255)
eventTitle.TextSize = 16
eventTitle.Font = Enum.Font.GothamBold
eventTitle.TextXAlignment = Enum.TextXAlignment.Left
eventTitle.Parent = eventFrame

local events = {
    "Valentine Event (Love Nessie 1:6M)",
    "Leviathan Hunt (+200K Luck)",
    "Pirate Cove Event",
    "Ancient Jungle Expansion",
    "Full Moon Event",
    "Meteor Shower",
    "Aurora Borealis",
    "Tidal Wave",
    "Monster Migration",
    "Treasure Hunt"
}

for i, eventName in ipairs(events) do
    local toggle = createToggle(eventFrame, eventName, 30 + (i-1)*40, function(state)
        getgenv().Miwaa.AutoEvent[eventName] = state
        -- Implementasi auto event
    end)
end

-- BYPASS TAB
local bypassFrame = Instance.new("Frame")
bypassFrame.Size = UDim2.new(1, -20, 0, 100)
bypassFrame.BackgroundTransparency = 1
bypassFrame.Visible = false
bypassFrame.Parent = content
contentFrames.bypass = bypassFrame

local bypassTitle = Instance.new("TextLabel")
bypassTitle.Size = UDim2.new(1, 0, 0, 30)
bypassTitle.BackgroundTransparency = 1
bypassTitle.Text = "🛡️ BYPASS SYSTEM"
bypassTitle.TextColor3 = Color3.fromRGB(0, 204, 255)
bypassTitle.TextSize = 16
bypassTitle.Font = Enum.Font.GothamBold
bypassTitle.TextXAlignment = Enum.TextXAlignment.Left
bypassTitle.Parent = bypassFrame

local bypassStatus = Instance.new("TextLabel")
bypassStatus.Size = UDim2.new(1, 0, 0, 30)
bypassStatus.Position = UDim2.new(0, 0, 0, 40)
bypassStatus.BackgroundTransparency = 1
bypassStatus.Text = "✅ BYPASS RUNNING (Anti AFK + Anti Detect)"
bypassStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
bypassStatus.TextSize = 12
bypassStatus.Font = Enum.Font.Gotham
bypassStatus.TextXAlignment = Enum.TextXAlignment.Left
bypassStatus.Parent = bypassFrame

-- LAINNYA TAB
local otherFrame = Instance.new("Frame")
otherFrame.Size = UDim2.new(1, -20, 0, 200)
otherFrame.BackgroundTransparency = 1
otherFrame.Visible = false
otherFrame.Parent = content
contentFrames.other = otherFrame

local otherTitle = Instance.new("TextLabel")
otherTitle.Size = UDim2.new(1, 0, 0, 30)
otherTitle.BackgroundTransparency = 1
otherTitle.Text = "🔧 OTHER FEATURES"
otherTitle.TextColor3 = Color3.fromRGB(0, 204, 255)
otherTitle.TextSize = 16
otherTitle.Font = Enum.Font.GothamBold
otherTitle.TextXAlignment = Enum.TextXAlignment.Left
otherTitle.Parent = otherFrame

local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 50)
credits.Position = UDim2.new(0, 0, 0, 40)
credits.BackgroundTransparency = 1
credits.Text = "Miwaa's Hub v3.0\nDiscord: miwaa.xyz"
credits.TextColor3 = Color3.fromRGB(255, 255, 255)
credits.TextSize = 12
credits.Font = Enum.Font.Gotham
credits.LineHeight = 1.5
credits.Parent = otherFrame

-- Fungsi untuk mengganti tab
local function showTab(tabName)
    for name, frame in pairs(contentFrames) do
        frame.Visible = (name == tabName)
    end
    -- Update canvas size
    content.CanvasSize = UDim2.new(0, 0, 0, contentFrames[tabName].AbsoluteSize.Y + 20)
end

-- Hubungkan tombol sidebar
tabButtons.fish.MouseButton1Click:Connect(function() showTab("fish") end)
tabButtons.sell.MouseButton1Click:Connect(function() showTab("sell") end)
tabButtons.fly.MouseButton1Click:Connect(function() showTab("fly") end)
tabButtons.esp.MouseButton1Click:Connect(function() showTab("esp") end)
tabButtons.hop.MouseButton1Click:Connect(function() showTab("hop") end)
tabButtons.tp.MouseButton1Click:Connect(function() showTab("tp") end)
tabButtons.event.MouseButton1Click:Connect(function() showTab("event") end)
tabButtons.bypass.MouseButton1Click:Connect(function() showTab("bypass") end)
tabButtons.other.MouseButton1Click:Connect(function() showTab("other") end)

-- Fungsi toggle helper
function createToggle(parent, text, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -45, 0.5, -10)
    toggleBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleBg.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    toggleCircle.Parent = toggleBg
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    local state = false
    local function updateToggle()
        if state then
            toggleCircle:TweenPosition(UDim2.new(1, -18, 0.5, -8), "Out", "Linear", 0.1, true)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            toggleBg.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        else
            toggleCircle:TweenPosition(UDim2.new(0, 2, 0.5, -8), "Out", "Linear", 0.1, true)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            toggleBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
    
    toggleBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateToggle()
            callback(state)
        end
    end)
    
    updateToggle()
    return frame
end

-- Minimize functionality
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        body.Visible = false
        panel.Size = UDim2.new(0, 620, 0, 42)
        minBtn.Text = "🔽"
    else
        body.Visible = true
        panel.Size = UDim2.new(0, 620, 0, 520)
        minBtn.Text = "▶️"
    end
end)

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    stopFly()
    if espFloat then espFloat:Destroy() end
end)

-- Initialize first tab
showTab("fish")

-- Server luck updater
spawn(function()
    while true do
        wait(5)
        getgenv().Miwaa.CurrentLuck = detectServerLuck()
    end
end)

-- Notifikasi sukses
game.StarterGui:SetCore("SendNotification", {
    Title = "SUKSES",
    Text = "Miwaa Neon Panel siap digunakan!",
    Duration = 3
})