-- библиотеки
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- вкладки
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local CheatEnabled = true
local Settings = {
    Aimbot = {
        Enabled = false,
        FOV = 100,
        ShowFOV = false,
        TargetPart = "Head",
        TeamCheck = true
    },
    ESP = {
        Enabled = false,
        Box = true,
        Distance = true,
        Skeleton = false,
        TeamCheck = true
    },
    Main = {
        NoClip = false,
        FreeCam = false,
        GodMode = false,
        Speed = 16
    }
}

-- библиотеки для менюшки
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/uwuware-ui/main/main.lua"))()
local window = library:CreateWindow("Cheat Menu")
local mainTab = window:AddFolder("Main")
local aimbotTab = window:AddFolder("Aimbot")
local espTab = window:AddFolder("ESP")

-- вкладка main
mainTab:AddToggle({
    text = "GodMode",
    flag = "GodModeToggle",
    callback = function(state)
        Settings.Main.GodMode = state
        if state then
            LocalPlayer.Character.Humanoid.MaxHealth = math.huge
            LocalPlayer.Character.Humanoid.Health = math.huge
        else
            LocalPlayer.Character.Humanoid.MaxHealth = 100
            LocalPlayer.Character.Humanoid.Health = 100
        end
    end
})

mainTab:AddToggle({
    text = "NoClip (X)",
    flag = "NoClipToggle",
    callback = function(state)
        Settings.Main.NoClip = state
    end
})

mainTab:AddToggle({
    text = "FreeCam (P)",
    flag = "FreeCamToggle",
    callback = function(state)
        Settings.Main.FreeCam = state
        if state then
            LocalPlayer.Character.HumanoidRootPart.Anchored = true
        else
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end
})

mainTab:AddSlider({
    text = "Speed",
    min = 0,
    max = 100,
    value = 16,
    callback = function(value)
        Settings.Main.Speed = value
    end
})

-- вкладка aim
aimbotTab:AddToggle({
    text = "Aimbot",
    flag = "AimbotToggle",
    callback = function(state)
        Settings.Aimbot.Enabled = state
    end
})

aimbotTab:AddToggle({
    text = "Show FOV",
    flag = "ShowFOVToggle",
    callback = function(state)
        Settings.Aimbot.ShowFOV = state
    end
})

aimbotTab:AddSlider({
    text = "Aimbot FOV",
    min = 1,
    max = 500,
    value = 100,
    callback = function(value)
        Settings.Aimbot.FOV = value
    end
})

aimbotTab:AddList({
    text = "Target Part",
    flag = "TargetPartList",
    values = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    value = "Head",
    callback = function(value)
        Settings.Aimbot.TargetPart = value
    end
})

aimbotTab:AddToggle({
    text = "Team Check",
    flag = "TeamCheckToggle",
    callback = function(state)
        Settings.Aimbot.TeamCheck = state
    end
})

-- вкладка esp
espTab:AddToggle({
    text = "ESP",
    flag = "ESPToggle",
    callback = function(state)
        Settings.ESP.Enabled = state
        if not state then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local character = player.Character
                    if character then
                        local highlight = character:FindFirstChild("ESP_Highlight")
                        if highlight then
                            highlight:Destroy()
                        end
                    end
                end
            end
        end
    end
})

espTab:AddToggle({

text = "Box",
    flag = "BoxToggle",
    callback = function(state)
        Settings.ESP.Box = state
    end
})

espTab:AddToggle({
    text = "Distance",
    flag = "DistanceToggle",
    callback = function(state)
        Settings.ESP.Distance = state
    end
})

espTab:AddToggle({
    text = "Skeleton",
    flag = "SkeletonToggle",
    callback = function(state)
        Settings.ESP.Skeleton = state
    end
})

espTab:AddToggle({
    text = "Team Check",
    flag = "ESTeamCheckToggle",
    callback = function(state)
        Settings.ESP.TeamCheck = state
    end
})

-- бинды
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.X then
            Settings.Main.NoClip = not Settings.Main.NoClip
            library.flags.NoClipToggle = Settings.Main.NoClip
        elseif input.KeyCode == Enum.KeyCode.P then
            Settings.Main.FreeCam = not Settings.Main.FreeCam
            library.flags.FreeCamToggle = Settings.Main.FreeCam
            LocalPlayer.Character.HumanoidRootPart.Anchored = Settings.Main.FreeCam
        end
    end
end)

-- Functions
local function IsTeamMate(player)
    if not Settings.Aimbot.TeamCheck and not Settings.ESP.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Settings.Aimbot.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeamMate(player) then
            local character = player.Character
            if character and character:FindFirstChild(Settings.Aimbot.TargetPart) then
                local targetPos = Camera:WorldToViewportPoint(character[Settings.Aimbot.TargetPart].Position)
                if targetPos.Z > 0 then
                    local distance = (Vector2.new(targetPos.X, targetPos.Y) - mousePos).Magnitude
                    if distance < closestDistance then
                        closestPlayer = player
                        closestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function CreateESP(player)
    if not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Parent = player.Character
    highlight.Adornee = player.Character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Parent = player.Character
    billboard.Adornee = player.Character.Head
    billboard.Size = UDim2.new(0, 100, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    
    local distanceText = Instance.new("TextLabel")
    distanceText.Name = "ESP_Distance"
    distanceText.Parent = billboard
    distanceText.Size = UDim2.new(1, 0, 1, 0)
    distanceText.TextScaled = true
    distanceText.BackgroundTransparency = 1
    distanceText.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceText.TextStrokeTransparency = 0.5
    distanceText.Font = Enum.Font.SourceSansBold
    
    if Settings.ESP.Skeleton then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local skeleton = Instance.new("BoxHandleAdornment")
                skeleton.Name = "ESP_Skeleton"
                skeleton.Parent = part
                skeleton.Adornee = part
                skeleton.AlwaysOnTop = true
                skeleton.ZIndex = 10
                skeleton.Size = part.Size
                skeleton.Transparency = 0.7

skeleton.Color3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end

local function UpdateESP()
    if not Settings.ESP.Enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeamMate(player) then
            if player.Character then
                local highlight = player.Character:FindFirstChild("ESP_Highlight")
                
                if not highlight then
                    CreateESP(player)
                else
                    highlight.Enabled = Settings.ESP.Enabled
                    
                    local billboard = player.Character:FindFirstChild("ESP_Billboard")
                    if billboard then
                        billboard.Enabled = Settings.ESP.Distance
                        
                        local distanceText = billboard:FindFirstChild("ESP_Distance")
                        if distanceText then
                            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            distanceText.Text = player.Name .. "\n" .. math.floor(distance) .. "m"
                        end
                    end
                    
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part:FindFirstChild("ESP_Skeleton") then
                            part.ESP_Skeleton.Enabled = Settings.ESP.Skeleton
                        end
                    end
                end
            end
        end
    end
end

-- Main loops
RunService.RenderStepped:Connect(function()
    -- NoClip
    if Settings.Main.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- фриКам
    if Settings.Main.FreeCam then
        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        
        local moveVector = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector + Vector3.new(0, -, -) end
