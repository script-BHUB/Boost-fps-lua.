local Players,Lighting,RunService,UIS,TweenService,Workspace=game:GetService("Players"),game:GetService("Lighting"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("TweenService"),game:GetService("Workspace")
local LP=Players.LocalPlayer
local PlayerGui=LP:WaitForChild("PlayerGui")
pcall(function()if game:GetService("CoreGui"):FindFirstChild("BHubSupremeUI")then game:GetService("CoreGui").BHubSupremeUI:Destroy()end end)
if PlayerGui:FindFirstChild("BHubSupremeUI")then PlayerGui.BHubSupremeUI:Destroy()end
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="BHubSupremeUI"
ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true
ScreenGui.DisplayOrder=999999999
pcall(function()ScreenGui.Parent=game:GetService("CoreGui")end)
if not ScreenGui.Parent then ScreenGui.Parent=PlayerGui end
local DarkBG,DarkButton,DarkBorder,ActiveColor=Color3.fromRGB(15,15,18),Color3.fromRGB(22,22,28),Color3.fromRGB(45,45,55),Color3.fromRGB(0,255,150)
local StatLabel=Instance.new("TextLabel")
StatLabel.Name="StatLabel"
StatLabel.Parent=ScreenGui
StatLabel.BackgroundTransparency=0.2
StatLabel.BackgroundColor3=DarkBG
StatLabel.Position=UDim2.new(0,15,0,50)
StatLabel.Size=UDim2.new(0,200,0,30)
StatLabel.Font=Enum.Font.Code
StatLabel.TextColor3=ActiveColor
StatLabel.TextSize=12
StatLabel.Text="FPS: -- | PING: --ms"
StatLabel.Active=true
local StatCorner=Instance.new("UICorner")
StatCorner.CornerRadius=UDim.new(0,8)
StatCorner.Parent=StatLabel
local StatStroke=Instance.new("UIStroke")
StatStroke.Color=DarkBorder
StatStroke.Transparency=0.2
StatStroke.Thickness=1.2
StatStroke.Parent=StatLabel
local MainFrame=Instance.new("Frame")
MainFrame.Name="MainFrame"
MainFrame.Parent=ScreenGui
MainFrame.BackgroundColor3=DarkBG
MainFrame.Position=UDim2.new(0,15,0,90)
MainFrame.Size=UDim2.new(0,200,0,260)
MainFrame.Active=true
local FrameCorner=Instance.new("UICorner")
FrameCorner.CornerRadius=UDim.new(0,12)
FrameCorner.Parent=MainFrame
local FrameStroke=Instance.new("UIStroke")
FrameStroke.Color=DarkBorder
FrameStroke.Transparency=0.1
FrameStroke.Thickness=1.5
FrameStroke.Parent=MainFrame
local UIList=Instance.new("UIListLayout")
UIList.Parent=MainFrame
UIList.SortOrder=Enum.SortOrder.LayoutOrder
UIList.Padding=UDim.new(0,6)
UIList.HorizontalAlignment=Enum.HorizontalAlignment.Center
local UIPadding=Instance.new("UIPadding")
UIPadding.Parent=MainFrame
UIPadding.PaddingTop=UDim.new(0,10)
UIPadding.PaddingBottom=UDim.new(0,10)
local function createButton(name,defaultText,layoutOrder)
local btn=Instance.new("TextButton")
btn.Name=name
btn.Parent=MainFrame
btn.Size=UDim2.new(1,-20,0,38)
btn.BackgroundColor3=DarkButton
btn.Font=Enum.Font.FredokaOne
btn.Text=defaultText
btn.TextColor3=Color3.fromRGB(180,180,190)
btn.TextSize=11
btn.AutoButtonColor=false
btn.LayoutOrder=layoutOrder
local btnCorner=Instance.new("UICorner")
btnCorner.CornerRadius=UDim.new(0,8)
btnCorner.Parent=btn
local btnStroke=Instance.new("UIStroke")
btnStroke.Color=DarkBorder
btnStroke.Transparency=0.3
btnStroke.Thickness=1.2
btnStroke.Parent=btn
return btn,btnStroke
end
local MasterBtn,MasterStroke=createButton("MasterBtn","Master FPS Boost: Off",1)
local RenderBtn,RenderStroke=createButton("RenderBtn","3D Render (AFK): On",2)
local CullingBtn,CullingStroke=createButton("CullingBtn","Distance Culling: Off",3)
local MapCleanBtn,MapCleanStroke=createButton("MapCleanBtn","Remove Map Assets",4)
local RamCleanBtn,RamCleanStroke=createButton("RamCleanBtn","Clean RAM Memory",5)
local isMasterOn,isRenderOn,isCullingOn=false,true,false
local originalData,connections={},{}
local zeroSeq,invSeq=NumberSequence.new(0),NumberSequence.new(1)
local function isExcluded(v)
if not v or not v.Parent then return true end
if v:IsA("Attachment") or v:IsA("Constraint") or v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Animation") or v:IsA("Animator") or v:IsA("Humanoid") or v:IsA("Camera") or v:IsA("Tool") or v:FindFirstAncestorOfClass("Tool") then return true end
local ancestor=v:FindFirstAncestorOfClass("Model")
return ancestor and Players:GetPlayerFromCharacter(ancestor)~=nil
end
local function applyOptimization(v,enable)
if isExcluded(v) then return end
pcall(function()
if enable then
if v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then
if not originalData[v] then originalData[v]={Parent=v.Parent} end
v.Parent=nil
elseif v:IsA("BasePart") or v:IsA("MeshPart") then
if not originalData[v] then originalData[v]={Mat=v.Material,Shadow=v.CastShadow,Ref=v.Reflectance} end
v.Material,v.CastShadow,v.Reflectance=Enum.Material.SmoothPlastic,false,0
if v:IsA("MeshPart") and v.TextureId~="" then
if not originalData[v].TextureId then originalData[v].TextureId=v.TextureId end
v.TextureId=""
end
elseif v:IsA("Decal") or v:IsA("Texture") then
if not originalData[v] then originalData[v]={Texture=v.Texture,Trans=v.Transparency} end
v.Texture,v.Transparency="",1
elseif v:IsA("ParticleEmitter") then
if not originalData[v] then originalData[v]={Enabled=v.Enabled,Size=v.Size,Trans=v.Transparency} end
v.Enabled,v.Size,v.Transparency=false,zeroSeq,invSeq
elseif v:IsA("Trail") or v:IsA("Beam") then
if not originalData[v] then originalData[v]={Enabled=v.Enabled,Trans=v.Transparency} end
v.Enabled,v.Transparency=false,invSeq
elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") or v:IsA("Highlight") then
if not originalData[v] then originalData[v]={Enabled=v.Enabled} end
v.Enabled=false
end
else
if originalData[v] then
if v:IsA("BasePart") or v:IsA("MeshPart") then
v.Material,v.CastShadow,v.Reflectance=originalData[v].Mat,originalData[v].Shadow,originalData[v].Ref
if v:IsA("MeshPart") and originalData[v].TextureId then v.TextureId=originalData[v].TextureId end
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
end)
end
MasterBtn.MouseButton1Click:Connect(function()
isMasterOn=not isMasterOn
local tweenInfo=TweenInfo.new(0.15)
if isMasterOn then
MasterBtn.Text="Master FPS Boost: On"
TweenService:Create(MasterBtn,tweenInfo,{BackgroundColor3=Color3.fromRGB(35,35,45),TextColor3=ActiveColor}):Play()
TweenService:Create(MasterStroke,tweenInfo,{Color=ActiveColor,Transparency=0.2}):Play()
pcall(function()
Lighting.GlobalShadows,Lighting.FogEnd=false,9e9
for _,effect in ipairs(Lighting:GetChildren()) do
if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("Atmosphere") then effect.Enabled=false end
end
end)
task.spawn(function()
local items=Workspace:GetDescendants()
for i=1,#items do
applyOptimization(items[i],true)
if i%500==0 then RunService.Heartbeat:Wait() end
end
end)
else
MasterBtn.Text="Master FPS Boost: Off"
TweenService:Create(MasterBtn,tweenInfo,{BackgroundColor3=DarkButton,TextColor3=Color3.fromRGB(180,180,190)}):Play()
TweenService:Create(MasterStroke,tweenInfo,{Color=DarkBorder,Transparency=0.3}):Play()
pcall(function() Lighting.GlobalShadows=true end)
task.spawn(function()
for v,_ in pairs(originalData) do applyOptimization(v,false) end
originalData={}
end)
end
end)
RenderBtn.MouseButton1Click:Connect(function()
isRenderOn=not isRenderOn
local tweenInfo=TweenInfo.new(0.15)
RunService:Set3dRenderingEnabled(isRenderOn)
if isRenderOn then
RenderBtn.Text="3D Render (AFK): On"
TweenService:Create(RenderBtn,tweenInfo,{BackgroundColor3=DarkButton,TextColor3=Color3.fromRGB(180,180,190)}):Play()
TweenService:Create(RenderStroke,tweenInfo,{Color=DarkBorder,Transparency=0.3}):Play()
else
RenderBtn.Text="3D Render (AFK): Off"
TweenService:Create(RenderBtn,tweenInfo,{BackgroundColor3=Color3.fromRGB(35,35,45),TextColor3=ActiveColor}):Play()
TweenService:Create(RenderStroke,tweenInfo,{Color=ActiveColor,Transparency=0.2}):Play()
end
end)
CullingBtn.MouseButton1Click:Connect(function()
isCullingOn=not isCullingOn
local tweenInfo=TweenInfo.new(0.15)
if isCullingOn then
CullingBtn.Text="Distance Culling: On"
TweenService:Create(CullingBtn,tweenInfo,{BackgroundColor3=Color3.fromRGB(35,35,45),TextColor3=ActiveColor}):Play()
TweenService:Create(CullingStroke,tweenInfo,{Color=ActiveColor,Transparency=0.2}):Play()
local cullingConn=RunService.Heartbeat:Connect(function()
local char=LP.Character
if not char or not char:FindFirstChild("HumanoidRootPart") then return end
local hrpPos=char.HumanoidRootPart.Position
for _,obj in ipairs(Workspace:GetDescendants()) do
if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
local dist=(obj.Position-hrpPos).Magnitude
if dist>150 then obj.LocalTransparencyModifier=1 else obj.LocalTransparencyModifier=0 end
end
end
end)
table.insert(connections,cullingConn)
else
CullingBtn.Text="Distance Culling: Off"
TweenService:Create(CullingBtn,tweenInfo,{BackgroundColor3=DarkButton,TextColor3=Color3.fromRGB(180,180,190)}):Play()
TweenService:Create(CullingStroke,tweenInfo,{Color=DarkBorder,Transparency=0.3}):Play()
for _,conn in ipairs(connections) do conn:Disconnect() end
connections={}
for _,obj in ipairs(Workspace:GetDescendants()) do
if obj:IsA("BasePart") then obj.LocalTransparencyModifier=0 end
end
end
end)
MapCleanBtn.MouseButton1Click:Connect(function()
local tweenInfo=TweenInfo.new(0.15)
TweenService:Create(MapCleanBtn,tweenInfo,{BackgroundColor3=Color3.fromRGB(35,35,45),TextColor3=ActiveColor}):Play()
for _,obj in ipairs(Workspace:GetDescendants()) do
if obj:IsA("Clouds") or obj:IsA("Atmosphere") or obj:IsA("PostEffect") then
obj:Destroy()
elseif obj:IsA("BasePart") then
local name=obj.Name:lower()
if name:find("leaf") or name:find("grass") or name:find("tree") or name:find("bush") then obj:Destroy() end
end
end
task.wait(0.3)
TweenService:Create(MapCleanBtn,tweenInfo,{BackgroundColor3=DarkButton,TextColor3=Color3.fromRGB(180,180,190)}):Play()
end)
RamCleanBtn.MouseButton1Click:Connect(function()
local tweenInfo=TweenInfo.new(0.15)
TweenService:Create(RamCleanBtn,tweenInfo,{BackgroundColor3=Color3.fromRGB(35,35,45),TextColor3=ActiveColor}):Play()
collectgarbage("collect")
task.wait(0.3)
TweenService:Create(RamCleanBtn,tweenInfo,{BackgroundColor3=DarkButton,TextColor3=Color3.fromRGB(180,180,190)}):Play()
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
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragStart,startPos=input.Position,frame.Position end
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
