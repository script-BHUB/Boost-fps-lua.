local ScreenGui = Instance.new("ScreenGui")
pcall(function()
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 999999999
	ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
	pcall(function()
		ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end)
end
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
local FrameCorner = Instance.new("UICorner")
local FrameStroke = Instance.new("UIStroke")
local UltraFastButton = Instance.new("TextButton")
local UltraFastCorner = Instance.new("UICorner")
local UltraFastStroke = Instance.new("UIStroke")

MainFrame.Name = "SupremeFPS_Extreme"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.Position = UDim2.new(0, 15, 0, 100)
MainFrame.Size = UDim2.new(0, 180, 0, 65)
MainFrame.Active = true
MainFrame.ZIndex = 999999998

FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

FrameStroke.Color = Color3.fromRGB(40, 40, 55)
FrameStroke.Thickness = 2
FrameStroke.Parent = MainFrame

local Color_Off = Color3.fromRGB(25, 25, 30)
local Color_On = Color3.fromRGB(0, 180, 120)
local TextColor_Off = Color3.fromRGB(180, 180, 190)
local TextColor_On = Color3.fromRGB(255, 255, 255)

UltraFastButton.Parent = MainFrame
UltraFastButton.Position = UDim2.new(0, 13, 0, 10)
UltraFastButton.BackgroundColor3 = Color_Off
UltraFastButton.Size = UDim2.new(0, 154, 0, 45)
UltraFastButton.Font = Enum.Font.GothamBold
UltraFastButton.Text = "B hub - Extreme Boost: Off"
UltraFastButton.TextColor3 = TextColor_Off
UltraFastButton.TextSize = 10
UltraFastButton.ZIndex = 999999999

UltraFastCorner.CornerRadius = UDim.new(0, 8)
UltraFastCorner.Parent = UltraFastButton

UltraFastStroke.Color = Color3.fromRGB(50, 50, 60)
UltraFastStroke.Thickness = 1.5
UltraFastStroke.Parent = UltraFastButton

local isEnabled = false
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")

local function optimizeWorkspace()
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
		
		workspace.Terrain.Decoration = false
		workspace.Terrain.WaterWaveSize = 0
		workspace.Terrain.WaterWaveSpeed = 0
		
		Lighting.GlobalShadows = false
		Lighting.ShadowMapDisplayDistance = 0
		Lighting.FogEnd = 9e9
		
		if MaterialService then MaterialService.Use2022Materials = false end
		
		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("PostEffect") or child:IsA("BloomEffect") or child:IsA("BlurEffect") 
			   or child:IsA("DepthOfFieldEffect") or child:IsA("SunRaysEffect") 
			   or child:IsA("ColorCorrectionEffect") or child:IsA("Atmosphere") or child:IsA("Sky") then
				if child:IsA("Sky") then child:Destroy() else child.Enabled = false end
			end
		end
		
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				v.Material = Enum.Material.SmoothPlastic
				v.CastShadow = false
				v.Reflectance = 0
				if v:IsA("MeshPart") then v.TextureId = "" end
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
				v.Enabled = false
			end
		end
	end)
end

UltraFastButton.MouseButton1Click:Connect(function()
	isEnabled = not isEnabled
	if isEnabled then
		UltraFastButton.Text = "B hub - Extreme Boost: On"
		UltraFastButton.BackgroundColor3 = Color_On
		UltraFastButton.TextColor3 = TextColor_On
		UltraFastStroke.Color = Color3.fromRGB(0, 255, 180)
		
		optimizeWorkspace()
		collectgarbage("collect")
	else
		UltraFastButton.Text = "B hub - Extreme Boost: Off"
		UltraFastButton.BackgroundColor3 = Color_Off
		UltraFastButton.TextColor3 = TextColor_Off
		UltraFastStroke.Color = Color3.fromRGB(50, 50, 60)
	end
end)

local UIS = game:GetService("UserInputService")
pcall(function()
	local dragStart, startPos
	MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragStart = nil
		end
	end)
end)
