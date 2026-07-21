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
StatLabel.Position=UDim2.new(0,15,0,90)
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
MainFrame.Position=UDim2.new(0,15,0,130)
MainFrame.Size=UDim2.new(0,200,0,56)
MainFrame.Active=true
local FrameCorner=Instance.new("UICorner")
FrameCorner.CornerRadius=UDim.new(0,12)
FrameCorner.Parent=MainFrame
local FrameStroke=Instance.new("UIStroke")
FrameStroke.Color=DarkBorder
FrameStroke.Transparency=0.1
FrameStroke.Thickness=1.5
FrameStroke.Parent=MainFrame
local BoostBtn=Instance.new("TextButton")
BoostBtn.Parent=MainFrame
BoostBtn.Position=UDim2.new(0,8,0,8)
BoostBtn.Size=UDim2.new(1,-16,1,-16)
BoostBtn.BackgroundColor3=DarkButton
BoostBtn.Font=Enum.Font.FredokaOne
BoostBtn.Text="B Hub Boost FPS : OFF"
BoostBtn.TextColor3=Color3.fromRGB(180,180,190)
BoostBtn.TextSize=11
BoostBtn.AutoButtonColor=false
local BoostCorner=Instance.new("UICorner")
BoostCorner.CornerRadius=UDim.new(0,8)
BoostCorner.Parent=BoostBtn
local BoostStroke=Instance.new("UIStroke")
BoostStroke.Color=DarkBorder
BoostStroke.Transparency=0.3
BoostStroke.Thickness=1.2
BoostStroke.Parent=BoostBtn
local isEnabled=false
local originalData={}
local originalLighting={}

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
			if not originalData[v] then
				if v:IsA("BasePart") or v:IsA("MeshPart") then
					originalData[v]={Mat=v.Material,Shadow=v.CastShadow,Ref=v.Reflectance}
				elseif v:IsA("Decal") or v:IsA("Texture") then
					originalData[v]={Trans=v.Transparency}
				elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") or v:IsA("Highlight") then
					originalData[v]={Enabled=v.Enabled}
				end
			end
			
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				v.Material,v.CastShadow,v.Reflectance=Enum.Material.SmoothPlastic,false,0
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency=1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") or v:IsA("Highlight") then
				v.Enabled=false
			end
		else
			if originalData[v] then
				if v:IsA("BasePart") or v:IsA("MeshPart") then
					v.Material,v.CastShadow,v.Reflectance=originalData[v].Mat,originalData[v].Shadow,originalData[v].Ref
				elseif v:IsA("Decal") or v:IsA("Texture") then
					v.Transparency=originalData[v].Trans
				elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") or v:IsA("Highlight") then
					v.Enabled=originalData[v].Enabled
				end
			end
		end
	end)
end

BoostBtn.MouseButton1Click:Connect(function()
	isEnabled=not isEnabled
	local tweenInfo=TweenInfo.new(0.15)
	if isEnabled then
		BoostBtn.Text="B Hub Boost FPS : ON"
		TweenService:Create(BoostBtn,tweenInfo,{BackgroundColor3=Color3.fromRGB(35,35,45),TextColor3=ActiveColor}):Play()
		TweenService:Create(BoostStroke,tweenInfo,{Color=ActiveColor,Transparency=0.2}):Play()
		
		pcall(function()
			originalLighting.GlobalShadows = Lighting.GlobalShadows
			Lighting.GlobalShadows=false
			for _,effect in ipairs(Lighting:GetChildren()) do
				if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("Atmosphere") then
					if not originalLighting[effect] then originalLighting[effect] = effect.Enabled end
					effect.Enabled=false
				end
			end
		end)
		
		local items=Workspace:GetDescendants()
		for i=1,#items do
			applyOptimization(items[i],true)
		end
	else
		BoostBtn.Text="B Hub Boost FPS : OFF"
		TweenService:Create(BoostBtn,tweenInfo,{BackgroundColor3=DarkButton,TextColor3=Color3.fromRGB(180,180,190)}):Play()
		TweenService:Create(BoostStroke,tweenInfo,{Color=DarkBorder,Transparency=0.3}):Play()
		
		pcall(function()
			if originalLighting.GlobalShadows ~= nil then
				Lighting.GlobalShadows = originalLighting.GlobalShadows
			end
			for effect, state in pairs(originalLighting) do
				if typeof(effect) == "Instance" and effect.Parent then
					effect.Enabled = state
				end
			end
			originalLighting = {}
		end)
		
		for v,_ in pairs(originalData) do
			if v and v.Parent then
				applyOptimization(v,false)
			end
		end
		originalData={}
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
