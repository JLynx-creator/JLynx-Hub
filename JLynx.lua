-- JLynx Universal Hack v4 by Yağız
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cursor Fix: Fare imlecini gizle ve lock'la (Rivals'ta mükemmel)
UserInputService.MouseIconEnabled = false
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

-- Mouse lock koruması (Rivals FPS için - sürekli kontrol)
RunService.RenderStepped:Connect(function()
    if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
    if UserInputService.MouseIconEnabled then
        UserInputService.MouseIconEnabled = false
    end
end)

-- Rayfield GUI (JLynx) - Koyu Tema
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- GUI State
local GUIEnabled = false
local Window = nil
local MainTab = nil
local MovementTab = nil
local MiscTab = nil

-- GUI Oluşturma Fonksiyonu
local function CreateGUI()
    if Window then return end
    
    Window = Rayfield:CreateWindow({
        Name = "JLynx by Yağız",
        LoadingTitle = "JLynx Loading...",
        LoadingSubtitle = "Rivals & Roblox FPS Universal",
        ConfigurationSaving = { Enabled = true, FolderName = "JLynxConfig" },
        Theme = {
            BackgroundColor = Color3.fromRGB(15, 15, 15),
            MainColor = Color3.fromRGB(100, 50, 200),
            AccentColor = Color3.fromRGB(150, 100, 255),
            TextColor = Color3.fromRGB(255, 255, 255),
            TextStrokeColor = Color3.fromRGB(0, 0, 0)
        }
    })
    
    MainTab = Window:CreateTab("Combat", 11769687313)  -- Aimbot/ESP ikon
    MovementTab = Window:CreateTab("Movement", 11769687313)
    MiscTab = Window:CreateTab("Misc", 11769687313)
    
    -- GUI Toggle'lar ve Slider'lar
    MainTab:CreateToggle({ 
        Name = "Aimbot (Sağ Tık)", 
        Callback = function(v) Settings.Aimbot = v end 
    })
    
    MainTab:CreateToggle({
        Name = "Silent Aim",
        Callback = function(v) Settings.SilentAim = v end
    })
    
    MainTab:CreateToggle({ 
        Name = "ESP", 
        Callback = function(v) 
            Settings.ESP = v
            if not v then
                for player, _ in pairs(ESPObjects) do
                    RemoveESP(player)
                end
            end
        end 
    })
    
    MainTab:CreateToggle({
        Name = "ESP 2D Box",
        Callback = function(v) Settings.ESP2DBox = v end
    })
    
    MainTab:CreateToggle({
        Name = "ESP Corner Box",
        Callback = function(v) Settings.ESPCornerBox = v end
    })
    
    MainTab:CreateToggle({
        Name = "Triggerbot",
        Callback = function(v) Settings.Triggerbot = v end
    })
    
    MainTab:CreateSlider({ 
        Name = "Aimbot FOV", 
        Min = 50, 
        Max = 300, 
        Default = 150, 
        Callback = function(v) Settings.AimbotFOV = v end 
    })
    
    MainTab:CreateSlider({ 
        Name = "Aimbot Smooth", 
        Min = 0.05, 
        Max = 0.5, 
        Increment = 0.05, 
        Default = 0.15, 
        Callback = function(v) Settings.AimbotSmooth = v end 
    })
    
    MainTab:CreateSlider({
        Name = "Triggerbot Delay",
        Min = 0.05,
        Max = 0.5,
        Increment = 0.05,
        Default = 0.1,
        Callback = function(v) Settings.TriggerbotDelay = v end
    })
    
    MovementTab:CreateToggle({
        Name = "Fly",
        Callback = function(val)
            Settings.Fly = val
            if val then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    flyBody = Instance.new("BodyVelocity")
                    flyBody.MaxForce = Vector3.new(40000, 40000, 40000)
                    flyBody.Velocity = Vector3.new(0, 0, 0)
                    flyBody.Parent = LocalPlayer.Character.HumanoidRootPart
                end
            else
                if flyBody then 
                    flyBody:Destroy()
                    flyBody = nil
                end
                flyVelocity = Vector3.new(0, 0, 0)
            end
        end
    })
    
    MovementTab:CreateToggle({
        Name = "NoClip",
        Callback = function(val)
            Settings.NoClip = val
            if noClipConnection then
                noClipConnection:Disconnect()
                noClipConnection = nil
            end
            if val then
                noClipConnection = RunService.Stepped:Connect(function()
                    if Settings.NoClip and LocalPlayer.Character then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end
    })
    
    MovementTab:CreateSlider({
        Name = "Fly Speed",
        Min = 50,
        Max = 200,
        Default = 100,
        Callback = function(v) Settings.FlySpeed = v end
    })
    
    MiscTab:CreateToggle({
        Name = "Anti-AFK",
        Callback = function(val)
            Settings.AntiAFK = val
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
            if val then
                antiAFKConnection = RunService.Heartbeat:Connect(function()
                    if Settings.AntiAFK and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        -- VirtualUser ile AFK önleme
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end
                end)
            end
        end
    })
end

-- GUI Toggle Fonksiyonu
local function ToggleGUI()
    GUIEnabled = not GUIEnabled
    
    if GUIEnabled then
        CreateGUI()
        Rayfield:Notify({
            Title = "JLynx",
            Content = "GUI: Açık",
            Duration = 2,
            Image = 11769687313
        })
    else
        if Window then
            Window:Destroy()
            Window = nil
            MainTab = nil
            MovementTab = nil
            MiscTab = nil
        end
        Rayfield:Notify({
            Title = "JLynx",
            Content = "GUI: Kapalı",
            Duration = 2,
            Image = 11769687313
        })
    end
end

-- Insert tuşu ile GUI toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        ToggleGUI()
    end
end)

-- Değişkenler
local Settings = {
    Aimbot = false,
    SilentAim = false,
    ESP = false,
    ESP2DBox = true,
    ESPCornerBox = true,
    Fly = false,
    NoClip = false,
    Triggerbot = false,
    AntiAFK = false,
    AimbotFOV = 150,
    AimbotSmooth = 0.15,
    FlySpeed = 100,
    TriggerbotDelay = 0.1
}

-- Drawing API için ESP
local Drawing = Drawing or loadstring(game:HttpGet("https://raw.githubusercontent.com/VisualRoblox/Roblox/main/DrawingAPI.lua"))()
local ESPObjects = {}

-- ESP Drawing API ile 2D Box + Corner Box
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local esp = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Corner1 = Drawing.new("Line"),
        Corner2 = Drawing.new("Line"),
        Corner3 = Drawing.new("Line"),
        Corner4 = Drawing.new("Line"),
        Corner5 = Drawing.new("Line"),
        Corner6 = Drawing.new("Line"),
        Corner7 = Drawing.new("Line"),
        Corner8 = Drawing.new("Line"),
        NameText = Drawing.new("Text"),
        DistanceText = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square")
    }
    
    -- Box ayarları
    esp.Box.Visible = false
    esp.Box.Color = Color3.fromRGB(255, 0, 0)
    esp.Box.Thickness = 1
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    esp.BoxOutline.Visible = false
    esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Transparency = 1
    esp.BoxOutline.Filled = false
    
    -- Corner box ayarları
    for i = 1, 8 do
        esp["Corner"..i].Visible = false
        esp["Corner"..i].Color = Color3.fromRGB(255, 0, 0)
        esp["Corner"..i].Thickness = 1
        esp["Corner"..i].Transparency = 1
    end
    
    -- Text ayarları
    esp.NameText.Visible = false
    esp.NameText.Color = Color3.fromRGB(255, 255, 255)
    esp.NameText.Size = 14
    esp.NameText.Font = 2
    esp.NameText.Outline = true
    esp.NameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    esp.DistanceText.Visible = false
    esp.DistanceText.Color = Color3.fromRGB(255, 255, 255)
    esp.DistanceText.Size = 12
    esp.DistanceText.Font = 2
    esp.DistanceText.Outline = true
    esp.DistanceText.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    -- Health bar
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Transparency = 1
    esp.HealthBar.Filled = true
    
    esp.HealthBarOutline.Visible = false
    esp.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.HealthBarOutline.Thickness = 3
    esp.HealthBarOutline.Transparency = 1
    esp.HealthBarOutline.Filled = false
    
    ESPObjects[player] = esp
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoidRootPart and head then
                if Settings.ESP then
                    CreateESP(player)
                    local esp = ESPObjects[player]
                    
                    local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                    if onScreen then
                        local size = (Camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, 2.5, 0)).Y) / 2
                        local boxSize = Vector2.new(math.floor(size * 1.5), math.floor(size * 2))
                        local boxPosition = Vector2.new(math.floor(vector.X - boxSize.X / 2), math.floor(vector.Y - boxSize.Y / 2))
                        
                        -- 2D Box
                        if Settings.ESP2DBox then
                            esp.BoxOutline.Size = boxSize
                            esp.BoxOutline.Position = boxPosition
                            esp.BoxOutline.Visible = true
                            
                            esp.Box.Size = boxSize
                            esp.Box.Position = boxPosition
                            esp.Box.Visible = true
                        else
                            esp.BoxOutline.Visible = false
                            esp.Box.Visible = false
                        end
                        
                        -- Corner Box
                        if Settings.ESPCornerBox then
                            local cornerSize = 10
                            local x1, y1 = boxPosition.X, boxPosition.Y
                            local x2, y2 = boxPosition.X + boxSize.X, boxPosition.Y
                            local x3, y3 = boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y
                            local x4, y4 = boxPosition.X, boxPosition.Y + boxSize.Y
                            
                            -- Üst köşeler
                            esp.Corner1.From = Vector2.new(x1, y1)
                            esp.Corner1.To = Vector2.new(x1 + cornerSize, y1)
                            esp.Corner1.Visible = true
                            
                            esp.Corner2.From = Vector2.new(x1, y1)
                            esp.Corner2.To = Vector2.new(x1, y1 + cornerSize)
                            esp.Corner2.Visible = true
                            
                            esp.Corner3.From = Vector2.new(x2, y2)
                            esp.Corner3.To = Vector2.new(x2 - cornerSize, y2)
                            esp.Corner3.Visible = true
                            
                            esp.Corner4.From = Vector2.new(x2, y2)
                            esp.Corner4.To = Vector2.new(x2, y2 + cornerSize)
                            esp.Corner4.Visible = true
                            
                            -- Alt köşeler
                            esp.Corner5.From = Vector2.new(x3, y3)
                            esp.Corner5.To = Vector2.new(x3 - cornerSize, y3)
                            esp.Corner5.Visible = true
                            
                            esp.Corner6.From = Vector2.new(x3, y3)
                            esp.Corner6.To = Vector2.new(x3, y3 - cornerSize)
                            esp.Corner6.Visible = true
                            
                            esp.Corner7.From = Vector2.new(x4, y4)
                            esp.Corner7.To = Vector2.new(x4 + cornerSize, y4)
                            esp.Corner7.Visible = true
                            
                            esp.Corner8.From = Vector2.new(x4, y4)
                            esp.Corner8.To = Vector2.new(x4, y4 - cornerSize)
                            esp.Corner8.Visible = true
                        else
                            for i = 1, 8 do
                                esp["Corner"..i].Visible = false
                            end
                        end
                        
                        -- Name & Distance
                        local distance = math.floor((humanoidRootPart.Position - Camera.CFrame.Position).Magnitude)
                        esp.NameText.Text = player.Name
                        esp.NameText.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y - 20)
                        esp.NameText.Visible = true
                        
                        esp.DistanceText.Text = tostring(distance) .. " studs"
                        esp.DistanceText.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y + boxSize.Y + 5)
                        esp.DistanceText.Visible = true
                        
                        -- Health Bar
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local barWidth = boxSize.X
                        local barHeight = 3
                        local barX = boxPosition.X
                        local barY = boxPosition.Y + boxSize.Y + 15
                        
                        esp.HealthBarOutline.Size = Vector2.new(barWidth, barHeight)
                        esp.HealthBarOutline.Position = Vector2.new(barX, barY)
                        esp.HealthBarOutline.Visible = true
                        
                        esp.HealthBar.Size = Vector2.new(barWidth * healthPercent, barHeight)
                        esp.HealthBar.Position = Vector2.new(barX, barY)
                        esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        esp.HealthBar.Visible = true
                    else
                        for _, drawing in pairs(esp) do
                            drawing.Visible = false
                        end
                    end
                else
                    RemoveESP(player)
                end
            end
        end
    end
end

-- Player çıktığında ESP'yi temizle
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

-- Silent Aim (Mouse hareket ettirmeden vuruş)
local silentAimTarget = nil
local function GetSilentAimTarget()
    if not Settings.SilentAim then return nil end
    
    local closest = nil
    local shortestDist = Settings.AimbotFOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, visible = Camera:WorldToViewportPoint(head.Position)
            if visible then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = head
                end
            end
        end
    end
    
    return closest
end

-- Silent Aim için Remote hook (Rivals ve diğer FPS oyunları için)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Settings.SilentAim and (method == "FireServer" or method == "InvokeServer") then
        local target = GetSilentAimTarget()
        if target and self.Name ~= nil then
            -- Remote'ları hook'la ve hedefi değiştir
            local remoteName = tostring(self.Name):lower()
            if remoteName:find("fire") or remoteName:find("shoot") or remoteName:find("hit") or remoteName:find("damage") then
                if #args > 0 and typeof(args[1]) == "table" then
                    args[1].hit = target
                    args[1].target = target
                end
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

-- Aimbot (Sağ tık ile lock, smooth)
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closest = nil
        local shortestDist = Settings.AimbotFOV
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local screenPos, visible = Camera:WorldToViewportPoint(head.Position)
                if visible then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = head
                    end
                end
            end
        end
        if closest then
            local targetPos = Camera:WorldToViewportPoint(closest.Position)
            local mousePos = UserInputService:GetMouseLocation()
            mousemoverel((targetPos.X - mousePos.X) * Settings.AimbotSmooth, (targetPos.Y - mousePos.Y) * Settings.AimbotSmooth)
        end
    end
end)

-- Triggerbot (Crosshair'daki düşmana otomatik ateş)
local lastTriggerTime = 0
RunService.RenderStepped:Connect(function()
    if Settings.Triggerbot and (tick() - lastTriggerTime) >= Settings.TriggerbotDelay then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
        if result and result.Instance then
            local hitPart = result.Instance
            local hitCharacter = hitPart:FindFirstAncestorOfClass("Model")
            if hitCharacter then
                local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)
                if hitPlayer and hitPlayer ~= LocalPlayer and hitCharacter:FindFirstChild("Humanoid") then
                    -- Ateş et
                    mouse1click()
                    lastTriggerTime = tick()
                end
            end
        end
    end
end)

-- Fly (W A S D + Space/Ctrl ile yön kontrolü)
local flyBody
local flyVelocity = Vector3.new(0, 0, 0)

RunService.Heartbeat:Connect(function()
    if Settings.Fly and flyBody and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local moveDirection = Vector3.new(0, 0, 0)
        local camCFrame = Camera.CFrame
        
        -- W A S D kontrolü
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camCFrame.RightVector
        end
        
        -- Space/Ctrl kontrolü
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        -- Normalize ve hız uygula
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * Settings.FlySpeed
        end
        
        flyBody.Velocity = moveDirection
    end
end)

-- NoClip
local noClipConnection

-- Anti-AFK
local antiAFKConnection


print("JLynx v4 yüklendi - Tüm özellikler aktif!")
