local Players,Lighting,RunService,UIS,Stats,MaterialService,TweenService=game:GetService("Players"),game:GetService("Lighting"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("Stats"),game:GetService("MaterialService"),game:GetService("TweenService")
local Terrain=workspace:FindFirstChildOfClass("Terrain")
local LP=Players.LocalPlayer
local PlayerGui=LP:WaitForChild("PlayerGui")

local successCore,_=pcall(function() return game:GetService("CoreGui") end)
if successCore and game:GetService("CoreGui"):FindFirstChild("BHubSupremeUI") then game:GetService("CoreGui").BHubSupremeUI:Destroy()
elseif PlayerGui:FindFirstChild("BHubSupremeUI") then PlayerGui.BHubSupremeUI:Destroy() end

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="BHubSupremeUI"
ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true
ScreenGui.DisplayOrder=999999999
pcall(function() ScreenGui.Parent=game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent=PlayerGui end

local StatLabel=Instance.new("TextLabel")
StatLabel.Name="StatLabel"
StatLabel.Parent=ScreenGui
StatLabel.BackgroundTransparency=0.3
StatLabel.BackgroundColor3=Color3.fromRGB(15,15,20)
StatLabel.Position=UDim2.new(0,15,0,80)
StatLabel.Size=UDim2.new(0,180,0,30)
StatLabel.Font=Enum.Font.Code
StatLabel.TextColor3=Color3.fromRGB(0,255,150)
StatLabel.TextSize=12
StatLabel.Text="FPS: -- | PING: --ms"
StatLabel.Active=true

local StatCorner=Instance.new("UICorner")
StatCorner.CornerRadius=UDim.new(0,8)
StatCorner.Parent=StatLabel

local StatStroke=Instance.new("UIStroke")
StatStroke.Color=Color3.fromRGB(0,255,150)
StatStroke.Transparency=0.6
StatStroke.Thickness=1
StatStroke.Parent=StatLabel

local MainFrame=Instance.new("Frame")
MainFrame.Name="MainFrame"
MainFrame.Parent=ScreenGui
MainFrame.BackgroundColor3=Color3.fromRGB(15,15,20)
MainFrame.Position=UDim2.new(0,15,0,120)
MainFrame.Size=UDim2.new(0,180,0,56)
MainFrame.Active=true

local FrameCorner=Instance.new("UICorner")
FrameCorner.CornerRadius=UDim.new(0,12)
FrameCorner.Parent=MainFrame

local FrameStroke=Instance.new("UIStroke")
FrameStroke.Color=Color3.fromRGB(0,140,255)
FrameStroke.Transparency=0.4
FrameStroke.Thickness=1.5
FrameStroke.Parent=MainFrame

local UltraFastButton=Instance.new("TextButton")
UltraFastButton.Parent=MainFrame
UltraFastButton.Position=UDim2.new(0,8,0,8)
UltraFastButton.Size=UDim2.new(1,-16,1,-16)
UltraFastButton.BackgroundColor3=Color3.fromRGB(25,30,45)
UltraFastButton.Font=Enum.Font.FredokaOne
UltraFastButton.Text="B hub - Boost FPS: Off"
UltraFastButton.TextColor3=Color3.fromRGB(180,200,230)
UltraFastButton.TextSize=11
UltraFastButton.AutoButtonColor=false

local UltraFastCorner=Instance.new("UICorner")
UltraFastCorner.CornerRadius=UDim.new(0,8)
UltraFastCorner.Parent=UltraFastButton

local UltraFastStroke=Instance.new("UIStroke")
UltraFastStroke.Color=Color3.fromRGB(0,140,255)
UltraFastStroke.Transparency=0.6
UltraFastStroke.Thickness=1.2
UltraFastStroke.Parent=UltraFastButton

local isEnabled=false
local originalData={}
local listenerConnection=nil
local playerConnections={}
local zeroSeq,invSeq=NumberSequence.new(0),NumberSequence.new(1)

local function isExcluded(v)
if not v or not v.Parent then return true end
if v:IsA("Attachment") or v:IsA("Constraint") or v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Animation") or v:IsA("Animator") or v:IsA("Humanoid") or v:IsA("Camera") or v:IsA("Tool") or v:FindFirstAncestorOfClass("Tool") then return true end
local ancestor=v:FindFirstAncestorOfClass("Model")
return ancestor and (ancestor==LP.Character or Players:GetPlayerFromCharacter(ancestor)==LP)
end

local function hideCharacterAccessories(character,enable)
if not character or character==LP.Character then return end
for _,item in pairs(character:GetChildren()) do
if item:IsA("Accessory") or item:IsA("Clothing") or item:IsA("CharacterMesh") then
for _,part in pairs(item:GetDescendants()) do
if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
if enable then
if not originalData[part] then originalData[part]={Trans=part.Transparency} end
part.Transparency=1
else
part.Transparency=(originalData[part] and originalData[part].Trans) or 0
end
end
end
end
end
end

local function applyUltraSmooth(v,cleanMode)
if isExcluded(v) then return end
if cleanMode then
if v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then
if not originalData[v] then originalData[v]={Parent=v.Parent} end
v.Parent=nil
elseif v:IsA("BasePart") or v:IsA("MeshPart") then
if not originalData[v] then originalData[v]={Mat=v.Material,Shadow=v.CastShadow,Ref=v.Reflectance} end
v.Material,v.CastShadow,v.Reflectance=Enum.Material.SmoothPlastic,false,0
if v:IsA("MeshPart") and v.TextureId~="" then
if not originalData[v].TextureId then originalData[v].TextureId=v.TextureId end
pcall(function() v.TextureId="" end)
end
elseif v:IsA("SpecialMesh") and v.TextureId~="" then
if not originalData[v] then originalData[v]={TextureId=v.TextureId} end
pcall(function() v.TextureId="" end)
elseif v:IsA("Decal") or v:IsA("Texture") then
if not originalData[v] then originalData[v]={Texture=v.Texture,Trans=v.Transparency} end
v.Texture,v.Transparency="",1
elseif v:IsA("ParticleEmitter") then
if not originalData[v] then originalData[v]={Enabled=v.Enabled,Size=v.Size,Trans=v.Transparency} end
v.Enabled,v.Size,v.Transparency=false,zeroSeq,invSeq
elseif v:IsA("Trail") or v:IsA("Beam") then
if not originalData[v] then originalData[v]={Enabled=v.Enabled,Trans=v.Transparency} end
v.Enabled,v.Transparency=false,invSeq
elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") or v:IsA("Highlight") or v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("Atmosphere") then
if not originalData[v] then originalData[v]={Enabled=v.Enabled} end
v.Enabled=false
end
else
if originalData[v] then
if v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then
v.Parent=originalData[v].Parent
elseif v:IsA("BasePart") or v:IsA("MeshPart") then
v.Material,v.CastShadow,v.Reflectance=originalData[v].Mat,originalData[v].Shadow,originalData[v].Ref
if v:IsA("MeshPart") and originalData[v].TextureId then v.TextureId=originalData[v].TextureId end
elseif v:IsA("SpecialMesh") then
v.TextureId=originalData[v].TextureId
elseif v:IsA("Decal") or v:IsA("Texture") then
v.Texture,v.Transparency=originalData[v].Texture,originalData[v].Trans
elseif v:IsA("ParticleEmitter") then
v.Enabled,v.Size,v.Transparency=originalData[v].Enabled,originalData[v].Size,originalData[v].Trans
elseif v:IsA("Trail") or v:IsA("Beam") then
v.Enabled,v.Transparency=originalData[v].Enabled,originalData[v].Trans
else
v.Enabled=originalData[v].Enabled
end
end
end
end

local function processBatch(items,cleanMode)
task.spawn(function()
for i=1,#items do
applyUltraSmooth(items[i],cleanMode)
if i%250==0 then RunService.Heartbeat:Wait() end
end
end)
end

local function clayBoost(state)
if state then
pcall(function()
if Terrain then Terrain.Decoration,Terrain.WaterWaveSize,Terrain.WaterWaveSpeed=false,0,0 end
Lighting.GlobalShadows,Lighting.ShadowMapDisplayDistance,Lighting.FogEnd=false,0,9e9
if MaterialService then MaterialService.Use2022Materials=false end
for _,effect in ipairs(Lighting:GetChildren()) do
if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("Atmosphere") then effect.Enabled=false end
end
end)

processBatch(workspace:GetDescendants(),true)

for _,p in pairs(Players:GetPlayers()) do
if p~=LP and p.Character then hideCharacterAccessories(p.Character,true) end
end

listenerConnection=workspace.DescendantAdded:Connect(function(child)
if not isEnabled then return end
task.defer(applyUltraSmooth,child,true)
end)

table.insert(playerConnections,Players.PlayerAdded:Connect(function(player)
table.insert(playerConnections,player.CharacterAdded:Connect(function(char)
if isEnabled and player~=LP then task.wait(0.5) hideCharacterAccessories(char,true) end
end))
end))
else
if listenerConnection then listenerConnection:Disconnect() listenerConnection=nil end
for _,conn in pairs(playerConnections) do conn:Disconnect() end
playerConnections={}
pcall(function()
Lighting.GlobalShadows=true
if Terrain then Terrain.Decoration=true end
for _,effect in ipairs(Lighting:GetChildren()) do
if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("Atmosphere") then effect.Enabled=true end
end
end)

for _,p in pairs(Players:GetPlayers()) do
if p~=LP and p.Character then hideCharacterAccessories(p.Character,false) end
end

processBatch(workspace:GetDescendants(),false)
end
end

UltraFastButton.MouseButton1Click:Connect(function()
isEnabled=not isEnabled
local tweenInfo=TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
if isEnabled then
UltraFastButton.Text="B hub - Boost FPS: On"
TweenService:Create(UltraFastButton,tweenInfo,{BackgroundColor3=Color3.fromRGB(30,180,90),TextColor3=Color3.fromRGB(255,255,255)}):Play()
TweenService:Create(UltraFastStroke,tweenInfo,{Color=Color3.fromRGB(50,255,120),Transparency=0.2}):Play()
clayBoost(true)
else
UltraFastButton.Text="B hub - Boost FPS: Off"
TweenService:Create(UltraFastButton,tweenInfo,{BackgroundColor3=Color3.fromRGB(25,30,45),TextColor3=Color3.fromRGB(180,200,230)}):Play()
TweenService:Create(UltraFastStroke,tweenInfo,{Color=Color3.fromRGB(0,140,255),Transparency=0.6}):Play()
clayBoost(false)
end
end)

UIS.InputBegan:Connect(function(input,gpe)
if not gpe and input.KeyCode==Enum.KeyCode.RightControl then
MainFrame.Visible,StatLabel.Visible=not MainFrame.Visible,not StatLabel.Visible
end
end)

task.spawn(function()
local lastTime,frameCount=os.clock(),0
RunService.Heartbeat:Connect(function()
if StatLabel.Visible then
frameCount=frameCount+1
local currentTime=os.clock()
if currentTime-lastTime>=0.5 then
local fps=math.floor(frameCount/(currentTime-lastTime))
frameCount,lastTime=0,currentTime
local ping=math.floor(LP:GetNetworkPing()*1000)
StatLabel.Text="FPS: "..fps.." | PING: "..ping.."ms"
end
end
end)
end)

local function makeDraggable(frame)
local dragStart,startPos
frame.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragStart,startPos=input.Position,frame.Position
end
end)
UIS.InputChanged:Connect(function(input)
if dragStart and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
local delta=input.Position-dragStart
frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
end
end)
UIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragStart=nil end
end)
end

makeDraggable(MainFrame)
makeDraggable(StatLabel)
