local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local FrameCorner = Instance.new("UICorner")
local FrameStroke = Instance.new("UIStroke")
local UIListLayout = Instance.new("UIListLayout")
local StatLabel = Instance.new("TextLabel")

local UltraFastButton = Instance.new("TextButton")
local UltraFastCorner = Instance.new("UICorner")
local UltraFastStroke = Instance.new("UIStroke")

pcall(function()
    local coreGui = game:GetService("CoreGui")
    if coreGui then
        ScreenGui.Parent = coreGui
    else
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999999
    ScreenGui.IgnoreGuiInset = false
end)

StatLabel.Name = "SupremeStats_V258"
StatLabel.Parent = ScreenGui
StatLabel.BackgroundTransparency = 0.5
StatLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatLabel.Position = UDim2.new(0, 10, 0, 10)
StatLabel.Size = UDim2.new(0, 200, 0, 30)
StatLabel.Font = Enum.Font.Code
StatLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatLabel.TextSize = 12
StatLabel.Text = "FPS: -- | PING: --ms"
StatLabel.Active = true
StatLabel.Visible = true
StatLabel.ZIndex = 999999999
local StatCorner = Instance.new("UICorner")
StatCorner.CornerRadius = UDim.new(0, 6)
StatCorner.Parent = StatLabel

MainFrame.Name = "SupremeFPS_V258"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.Position = UDim2.new(0, 10, 0, 50)
MainFrame.Size = UDim2.new(0, 180, 0, 75)
MainFrame.Active = true
MainFrame.ZIndex = 999999999

FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame
FrameStroke.Color = Color3.fromRGB(40, 40, 55)
FrameStroke.Thickness = 2
FrameStroke.Parent = MainFrame

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 0)
local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = MainFrame
UIPadding.PaddingTop = UDim.new(0, 14)

local Color_Off = Color3.fromRGB(25, 25, 30)
local Color_On = Color3.fromRGB(0, 180, 120)
local TextColor_Off = Color3.fromRGB(180, 180, 190)
local TextColor_On = Color3.fromRGB(255, 255, 255)

UltraFastButton.Parent = MainFrame
UltraFastButton.BackgroundColor3 = Color_Off
UltraFastButton.Size = UDim2.new(0, 154, 0, 46)
UltraFastButton.Font = Enum.Font.GothamBold
UltraFastButton.Text = "B hub - boost fps: Off"
UltraFastButton.TextColor3 = TextColor_Off
UltraFastButton.TextSize = 11
UltraFastButton.ZIndex = 999999999
UltraFastCorner.CornerRadius = UDim.new(0, 8)
UltraFastCorner.Parent = UltraFastButton
UltraFastStroke.Color = Color3.fromRGB(50, 50, 60)
UltraFastStroke.Thickness = 1.5
UltraFastStroke.Parent = UltraFastButton

local isEnabled = false
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local StatsService = game:GetService("Stats")

local originalData = {}
local lightingBackup = {}
local terrainBackup = {}
local listenerConnection = nil
local characterConnections = {}
local loopThreads = {}
local zeroSequence = NumberSequence.new(0)
local invisibleSequence = NumberSequence.new(1)
local clayGreyColor = Color3.fromRGB(120, 120, 125)
local maxRenderDistance = 250

local function isJointOrPhysics(v)
    if v:IsA("Attachment") or v:IsA("Constraint") or v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Animation") or v:IsA("Animator") or v:IsA("Humanoid") then
        return true
    end
    return false
end

local function applyAccessorySmooth(v)
    if not v or isJointOrPhysics(v) then return end
    pcall(function()
        if v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then
            if not originalData[v] then originalData[v] = {Parent = v.Parent} end
            v.Parent = nil
        elseif v:IsA("BasePart") or v:IsA("MeshPart") then
            if not originalData[v] then
                originalData[v] = {Mat = v.Material, Shadow = v.CastShadow, Ref = v.Reflectance, Color = v.Color}
            end
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
            v.Reflectance = 0
            v.Color = clayGreyColor
            if v:IsA("MeshPart") then
                if not originalData[v].TextureId then originalData[v].TextureId = v.TextureId end
                v.TextureId = ""
            end
        elseif v:IsA("SpecialMesh") then
            if not originalData[v] then originalData[v] = {TextureId = v.TextureId} end
            v.TextureId = ""
        elseif v:IsA("Decal") or v:IsA("Texture") then
            if not originalData[v] then originalData[v] = {Texture = v.Texture, Trans = v.Transparency} end
            v.Texture = ""
            v.Transparency = 1
        end
    end)
end

local function processCharacter(char)
    if not char then return end
    if char == LP.Character then return end
    local bodyParts = {
        ["head"] = true, ["torso"] = true, ["left arm"] = true, ["right arm"] = true, ["left leg"] = true, ["right leg"] = true,
        ["uppertorso"] = true, ["lowertorso"] = true, ["leftupperarm"] = true, ["leftlowerarm"] = true, ["lefthand"] = true,
        ["rightupperarm"] = true, ["rightlowerarm"] = true, ["righthand"] = true, ["leftupperleg"] = true, ["leftlowerleg"] = true,
        ["leftfoot"] = true, ["rightupperleg"] = true, ["rightlowerleg"] = true, ["rightfoot"] = true, ["humanoidrootpart"] = true
    }
    task.defer(function()
        local descendants = char:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local partName = string.lower(obj.Name)
                if not bodyParts[partName] then
                    applyAccessorySmooth(obj)
                end
            elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") or obj:IsA("SpecialMesh") then
                local pPart = obj.Parent
                if pPart and pPart:IsA("BasePart") then
                    local pName = string.lower(pPart.Name)
                    if not bodyParts[pName] then
                        applyAccessorySmooth(obj)
                    end
                else
                    applyAccessorySmooth(obj)
                end
            elseif obj:IsA("ShirtGraphic") or obj:IsA("Pants") or obj:IsA("Shirt") then
                pcall(function() obj:Destroy() end)
            end
        end
    end)
end

local function applyUltraSmooth(v, cleanMode)
    if not v or isJointOrPhysics(v) then return end
    
    local parent = v.Parent
    if parent and parent:IsA("Model") and Players:GetPlayerFromCharacter(parent) then
        if cleanMode then
            processCharacter(parent)
        end
        return
    end
    
    if cleanMode then
        pcall(function()
            if v:IsA("Atmosphere") or v:IsA("Clouds") or v:IsA("Sky") then
                if not originalData[v] then originalData[v] = {Parent = v.Parent} end
                v.Parent = nil
            elseif v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then
                if not originalData[v] then originalData[v] = {Parent = v.Parent} end
                v.Parent = nil
            elseif v:IsA("BasePart") or v:IsA("MeshPart") then
                if not originalData[v] then
                    originalData[v] = {Mat = v.Material, Shadow = v.CastShadow, Ref = v.Reflectance, Color = v.Color}
                end
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
                v.Reflectance = 0
                v.Color = clayGreyColor
                if v:IsA("MeshPart") then
                    if not originalData[v].TextureId then originalData[v].TextureId = v.TextureId end
                    v.TextureId = ""
                end
            elseif v:IsA("SpecialMesh") then
                if not originalData[v] then originalData[v] = {TextureId = v.TextureId} end
                v.TextureId = ""
            elseif v:IsA("Decal") or v:IsA("Texture") then
                if not originalData[v] then originalData[v] = {Texture = v.Texture, Trans = v.Transparency} end
                v.Texture = ""
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") then
                if not originalData[v] then originalData[v] = {Enabled = v.Enabled, Size = v.Size, Trans = v.Transparency} end
                v.Enabled = false
                v.Size = zeroSequence
                v.Transparency = invisibleSequence
            elseif v:IsA("Trail") or v:IsA("Beam") then
                if not originalData[v] then originalData[v] = {Enabled = v.Enabled, Trans = v.Transparency} end
                v.Enabled = false
                v.Transparency = invisibleSequence
            elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") or v:IsA("Highlight") then
                if not originalData[v] then originalData[v] = {Enabled = v.Enabled} end
                v.Enabled = false
            elseif v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
                if not originalData[v] then originalData[v] = {Enabled = v.Enabled} end
                v.Enabled = false
            end
        end)
    else
        if originalData[v] then
            pcall(function()
                if v:IsA("Atmosphere") or v:IsA("Clouds") or v:IsA("Sky") or v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then
                    if originalData[v].Parent and originalData[v].Parent.Parent then
                        v.Parent = originalData[v].Parent
                    end
                elseif v:IsA("BasePart") or v:IsA("MeshPart") then
                    v.Material = originalData[v].Mat
                    v.CastShadow = originalData[v].Shadow
                    v.Reflectance = originalData[v].Ref
                    if originalData[v].Color then v.Color = originalData[v].Color end
                    if v:IsA("MeshPart") and originalData[v].TextureId then
                        v.TextureId = originalData[v].TextureId
                    end
                elseif v:IsA("SpecialMesh") then
                    v.TextureId = originalData[v].TextureId
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Texture = originalData[v].Texture
                    v.Transparency = originalData[v].Trans
                elseif v:IsA("ParticleEmitter") then
                    v.Enabled = originalData[v].Enabled
                    v.Size = originalData[v].Size
                    v.Transparency = originalData[v].Trans
                elseif v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = originalData[v].Enabled
                    v.Transparency = originalData[v].Trans
                else
                    v.Enabled = originalData[v].Enabled
                end
            end)
        end
    end
end

local function setupPlayerListeners()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then processCharacter(player.Character) end
        characterConnections[player] = player.CharacterAdded:Connect(function(char)
            if isEnabled then
                processCharacter(char)
            end
        end)
    end
    
    characterConnections["PlayerAdded"] = Players.PlayerAdded:Connect(function(player)
        characterConnections[player] = player.CharacterAdded:Connect(function(char)
            if isEnabled then
                processCharacter(char)
            end
        end)
    end)
end

local function clearPlayerListeners()
    for k, conn in pairs(characterConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    characterConnections = {}
end

local function runBackgroundLoops()
    loopThreads["MemoryFlush"] = task.spawn(function()
        while isEnabled do
            task.wait(60)
            pcall(function()
                gcinfo()
            end)
        end
    end)

    loopThreads["PlayerEffectsCulling"] = task.spawn(function()
        while isEnabled do
            task.wait(0.8)
            local myChar = LP.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local myPos = myRoot.Position
                local currentPlayers = Players:GetPlayers()
                for i = 1, #currentPlayers do
                    local p = currentPlayers[i]
                    if p ~= LP and p.Character then
                        local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        if pRoot then
                            local dist = (myPos - pRoot.Position).Magnitude
                            local descendants = p.Character:GetDescendants()
                            for d = 1, #descendants do
                                local item = descendants[d]
                                if item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Beam") or item:IsA("Fire") or item:IsA("Smoke") or item:IsA("Sparkles") then
                                    if dist > maxRenderDistance then
                                        pcall(function() item.Enabled = false end)
                                    else
                                        if not originalData[item] then originalData[item] = {Enabled = true} end
                                        pcall(function() item.Enabled = true end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopBackgroundLoops()
    for k, thread in pairs(loopThreads) do
        if thread then
            task.cancel(thread)
        end
    end
    loopThreads = {}
end

local function clayBoost(state)
    if state then
        pcall(function()
            lightingBackup.GlobalShadows = Lighting.GlobalShadows
            terrainBackup.WaterWaveSize = workspace.Terrain.WaterWaveSize
            terrainBackup.WaterWaveSpeed = workspace.Terrain.WaterWaveSpeed
            terrainBackup.Decoration = workspace.Terrain.Decoration
            
            Lighting.GlobalShadows = false
            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
            workspace.Terrain.Decoration = false
            settings().Rendering.QualityLevel = 1
            sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
        end)
        
        pcall(function()
            local settingsService = settings()
            if settingsService and settingsService.Rendering then
                terrainBackup.MeshCacheSize = settingsService.Rendering.MeshCacheSize
                settingsService.Rendering.MeshCacheSize = 0
            end
        end)
        
        local descendants = workspace:GetDescendants()
        for i = 1, #descendants do
            applyUltraSmooth(descendants[i], true)
        end
        
        local lightingDesc = Lighting:GetDescendants()
        for i = 1, #lightingDesc do
            applyUltraSmooth(lightingDesc[i], true)
        end
        
        local terrainDesc = workspace.Terrain:GetDescendants()
        for i = 1, #terrainDesc do
            applyUltraSmooth(terrainDesc[i], true)
        end
        
        setupPlayerListeners()
        runBackgroundLoops()
        
        listenerConnection = workspace.DescendantAdded:Connect(function(child)
            task.defer(function()
                if isEnabled then
                    applyUltraSmooth(child, true)
                    if child and (child:IsA("Explosion") or child:IsA("Debris")) then
                        pcall(function() child:Destroy() end)
                    end
                end
            end)
        end)
    else
        if listenerConnection then
            listenerConnection:Disconnect()
            listenerConnection = nil
        end
        
        clearPlayerListeners()
        stopBackgroundLoops()
        
        pcall(function()
            if lightingBackup.GlobalShadows ~= nil then Lighting.GlobalShadows = lightingBackup.GlobalShadows end
            if terrainBackup.WaterWaveSize ~= nil then workspace.Terrain.WaterWaveSize = terrainBackup.WaterWaveSize end
            if terrainBackup.WaterWaveSpeed ~= nil then workspace.Terrain.WaterWaveSpeed = terrainBackup.WaterWaveSpeed end
            if terrainBackup.Decoration ~= nil then workspace.Terrain.Decoration = terrainBackup.Decoration end
            
            local settingsService = settings()
            if settingsService and settingsService.Rendering and terrainBackup.MeshCacheSize then
                settingsService.Rendering.MeshCacheSize = terrainBackup.MeshCacheSize
            end
        end)
        
        local descendants = workspace:GetDescendants()
        for i = 1, #descendants do
            applyUltraSmooth(descendants[i], false)
        end
        
        local lightingDesc = Lighting:GetDescendants()
        for i = 1, #lightingDesc do
            applyUltraSmooth(lightingDesc[i], false)
        end
        
        local terrainDesc = workspace.Terrain:GetDescendants()
        for i = 1, #terrainDesc do
            applyUltraSmooth(terrainDesc[i], false)
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, obj in pairs(player.Character:GetDescendants()) do
                    applyUltraSmooth(obj, false)
                end
            end
        end
        
        originalData = {}
        lightingBackup = {}
        terrainBackup = {}
    end
end

local function toggleScriptState(targetState)
    isEnabled = targetState
    if isEnabled then
        UltraFastButton.Text = "B hub - boost fps: On"
        UltraFastButton.BackgroundColor3 = Color_On
        UltraFastButton.TextColor3 = TextColor_On
        UltraFastStroke.Color = Color3.fromRGB(0, 255, 180)
        
        task.spawn(function()
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v and (v:IsA("Explosion") or v:IsA("Debris")) then
                        v:Destroy()
                    end
                end
            end)
        end)
        
        clayBoost(true)
    else
        UltraFastButton.Text = "B hub - boost fps: Off"
        UltraFastButton.BackgroundColor3 = Color_Off
        UltraFastButton.TextColor3 = TextColor_Off
        UltraFastStroke.Color = Color3.fromRGB(50, 50, 60)
        clayBoost(false)
    end
end

UltraFastButton.MouseButton1Click:Connect(function()
    toggleScriptState(not isEnabled)
end)

UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
        StatLabel.Visible = not StatLabel.Visible
    end
end)

task.spawn(function()
    local lastTime = os.clock()
    local frameCount = 0
    
    local function getPrecisePing()
        local networkStats = StatsService:FindFirstChild("Network")
        if networkStats then
            local serverStats = networkStats:FindFirstChild("ServerStatsItem")
            if serverStats then
                return math.floor(serverStats:GetValue() or 0)
            end
        end
        return math.floor(LP:GetNetworkPing() * 1000)
    end

    RunService.Heartbeat:Connect(function()
        if StatLabel.Visible then
            frameCo
