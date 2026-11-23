--[[
	Talentless-style Piano
	For Xeno / any executor
	Just execute the whole file
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- destroy old one if already running
if playerGui:FindFirstChild("TalentlessPiano") then
	playerGui.TalentlessPiano:Destroy()
end

-------------------------------------------------
-- CONFIG
-------------------------------------------------
local VOLUME = 1.4
local TRANSPOSE = 0
local SUSTAIN = false

local NOTE_SOUNDS = {
	["C"]  = "rbxassetid://9042785938",
	["C#"] = "rbxassetid://9042785938",
	["D"]  = "rbxassetid://9042785938",
	["D#"] = "rbxassetid://9042785938",
	["E"]  = "rbxassetid://9042785938",
	["F"]  = "rbxassetid://9042785938",
	["F#"] = "rbxassetid://9042785938",
	["G"]  = "rbxassetid://9042785938",
	["G#"] = "rbxassetid://9042785938",
	["A"]  = "rbxassetid://9042785938",
	["A#"] = "rbxassetid://9042785938",
	["B"]  = "rbxassetid://9042785938",
}

local PITCH = {
	["C"]  = 1.00,
	["C#"] = 1.05946,
	["D"]  = 1.12246,
	["D#"] = 1.18921,
	["E"]  = 1.25992,
	["F"]  = 1.33484,
	["F#"] = 1.41421,
	["G"]  = 1.49831,
	["G#"] = 1.58740,
	["A"]  = 1.68179,
	["A#"] = 1.78180,
	["B"]  = 1.88775,
}

-------------------------------------------------
-- KEY LAYOUT
-------------------------------------------------
local WHITE_NOTES = {
	"C","D","E","F","G","A","B",
	"C","D","E","F","G","A","B",
	"C","D","E","F","G","A","B",
	"C","D","E","F","G","A","B","C"
}

local WHITE_KEYS = {
	"1","2","3","4","5","6","7","8","9","0",
	"q","w","e","r","t","y","u","i","o","p",
	"a","s","d","f","g","h","j","k","l",
	"z","x","c","v","b","n","m"
}

local BLACK_NOTES = {
	"C#","D#",nil,"F#","G#","A#",nil,
	"C#","D#",nil,"F#","G#","A#",nil,
	"C#","D#",nil,"F#","G#","A#",nil,
	"C#","D#",nil,"F#","G#","A#"
}

local BLACK_KEYS = {
	"!","@","#","$","%","^","&","*",
	"Q","W","E","R","T","Y","U","I","O","P",
	"A","S","D","F","G","H","J","K","L",
	"Z","X","C","V","B","N"
}

-------------------------------------------------
-- UI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TalentlessPiano"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "PianoFrame"
main.AnchorPoint = Vector2.new(0.5, 1)
main.Position = UDim2.new(0.5, 0, 1, -18)
main.Size = UDim2.new(0.93, 0, 0, 145)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
main.BorderSizePixel = 0
main.Parent = screenGui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 28)
topBar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
topBar.BorderSizePixel = 0
topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 220, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "TALENTLESS  •  PIANO"
title.TextColor3 = Color3.fromRGB(225, 225, 235)
title.TextSize = 14
title.Font = Enum.Font.GothamMedium
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local volumeLabel = Instance.new("TextLabel")
volumeLabel.Size = UDim2.new(0, 90, 1, 0)
volumeLabel.Position = UDim2.new(1, -200, 0, 0)
volumeLabel.BackgroundTransparency = 1
volumeLabel.Text = "Vol: 140%"
volumeLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
volumeLabel.TextSize = 13
volumeLabel.Font = Enum.Font.Gotham
volumeLabel.Parent = topBar

local transposeLabel = Instance.new("TextLabel")
transposeLabel.Size = UDim2.new(0, 90, 1, 0)
transposeLabel.Position = UDim2.new(1, -100, 0, 0)
transposeLabel.BackgroundTransparency = 1
transposeLabel.Text = "Trans: 0"
transposeLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
transposeLabel.TextSize = 13
transposeLabel.Font = Enum.Font.Gotham
transposeLabel.Parent = topBar

local keysFrame = Instance.new("Frame")
keysFrame.Name = "Keys"
keysFrame.Position = UDim2.new(0, 8, 0, 32)
keysFrame.Size = UDim2.new(1, -16, 1, -40)
keysFrame.BackgroundTransparency = 1
keysFrame.Parent = main

local whiteLayout = Instance.new("UIListLayout")
whiteLayout.FillDirection = Enum.FillDirection.Horizontal
whiteLayout.Padding = UDim.new(0, 1)
whiteLayout.SortOrder = Enum.SortOrder.LayoutOrder
whiteLayout.Parent = keysFrame

-------------------------------------------------
-- SOUND
-------------------------------------------------
local keyButtons = {}
local held = {}

local function playNote(noteName, octaveOffset)
	octaveOffset = octaveOffset or 0
	local basePitch = PITCH[noteName] or 1
	local finalPitch = basePitch * (2 ^ ((TRANSPOSE + octaveOffset * 12) / 12))

	local sound = Instance.new("Sound")
	sound.SoundId = NOTE_SOUNDS[noteName] or NOTE_SOUNDS["C"]
	sound.Volume = VOLUME
	sound.Pitch = finalPitch
	sound.Parent = SoundService
	sound:Play()

	if not SUSTAIN then
		task.delay(3.2, function()
			if sound and sound.Parent then
				sound:Stop()
				sound:Destroy()
			end
		end)
	end
end

-------------------------------------------------
-- BUILD WHITE KEYS
-------------------------------------------------
local whiteWidth = 1 / #WHITE_KEYS

for i, keyChar in ipairs(WHITE_KEYS) do
	local note = WHITE_NOTES[i] or "C"
	local octave = math.floor((i - 1) / 7) - 1

	local btn = Instance.new("TextButton")
	btn.Name = "White_" .. keyChar
	btn.Size = UDim2.new(whiteWidth, -1, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(242, 242, 248)
	btn.BorderSizePixel = 0
	btn.Text = keyChar
	btn.TextColor3 = Color3.fromRGB(35, 35, 45)
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamMedium
	btn.AutoButtonColor = false
	btn.LayoutOrder = i
	btn.Parent = keysFrame

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	local noteLabel = Instance.new("TextLabel")
	noteLabel.Size = UDim2.new(1, 0, 0, 14)
	noteLabel.Position = UDim2.new(0, 0, 1, -18)
	noteLabel.BackgroundTransparency = 1
	noteLabel.Text = note
	noteLabel.TextColor3 = Color3.fromRGB(110, 110, 120)
	noteLabel.TextSize = 10
	noteLabel.Font = Enum.Font.Gotham
	noteLabel.Parent = btn

	keyButtons[keyChar:lower()] = {
		button = btn,
		note = note,
		octave = octave,
		isBlack = false
	}

	btn.MouseButton1Down:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(170, 195, 255)
		playNote(note, octave)
	end)
	btn.MouseButton1Up:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(242, 242, 248)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(242, 242, 248)
	end)
end

-------------------------------------------------
-- BUILD BLACK KEYS
-------------------------------------------------
for i, keyChar in ipairs(BLACK_KEYS) do
	local note = BLACK_NOTES[i]
	if note then
		local xPos = (i - 0.55) / #WHITE_KEYS

		local btn = Instance.new("TextButton")
		btn.Name = "Black_" .. keyChar
		btn.Size = UDim2.new(whiteWidth * 0.62, 0, 0.57, 0)
		btn.Position = UDim2.new(xPos, 0, 0, 0)
		btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
		btn.BorderSizePixel = 0
		btn.Text = keyChar
		btn.TextColor3 = Color3.fromRGB(200, 200, 210)
		btn.TextSize = 10
		btn.Font = Enum.Font.GothamMedium
		btn.AutoButtonColor = false
		btn.ZIndex = 5
		btn.Parent = keysFrame

		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

		keyButtons[keyChar:lower()] = {
			button = btn,
			note = note,
			octave = math.floor((i - 1) / 5) - 1,
			isBlack = true
		}

		btn.MouseButton1Down:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(65, 85, 135)
			playNote(note, keyButtons[keyChar:lower()].octave)
		end)
		btn.MouseButton1Up:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
		end)
	end
end

-------------------------------------------------
-- INPUT
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

	local key = input.KeyCode.Name:lower()
	local data = keyButtons[key]

	if data and not held[key] then
		held[key] = true
		data.button.BackgroundColor3 = data.isBlack
			and Color3.fromRGB(65, 85, 135)
			or Color3.fromRGB(170, 195, 255)
		playNote(data.note, data.octave)
	end

	-- controls
	if input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.Plus then
		VOLUME = math.clamp(VOLUME + 0.1, 0.1, 2)
		volumeLabel.Text = string.format("Vol: %d%%", math.floor(VOLUME * 100))
	elseif input.KeyCode == Enum.KeyCode.Minus then
		VOLUME = math.clamp(VOLUME - 0.1, 0.1, 2)
		volumeLabel.Text = string.format("Vol: %d%%", math.floor(VOLUME * 100))
	elseif input.KeyCode == Enum.KeyCode.RightBracket then
		TRANSPOSE = TRANSPOSE + 1
		transposeLabel.Text = "Trans: " .. TRANSPOSE
	elseif input.KeyCode == Enum.KeyCode.LeftBracket then
		TRANSPOSE = TRANSPOSE - 1
		transposeLabel.Text = "Trans: " .. TRANSPOSE
	elseif input.KeyCode == Enum.KeyCode.Space then
		SUSTAIN = not SUSTAIN
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local key = input.KeyCode.Name:lower()
	local data = keyButtons[key]
	if data then
		held[key] = nil
		data.button.BackgroundColor3 = data.isBlack
			and Color3.fromRGB(22, 22, 28)
			or Color3.fromRGB(242, 242, 248)
	end
end)

print("[Talentless Piano] loaded — ready for Xeno")
