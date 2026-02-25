repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-------------------------------------------------
-- GUI
-------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "SmartLoaderGenerator"
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 300)
main.Position = UDim2.new(0.5, -250, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 12)

-------------------------------------------------
-- SCROLL (porque son muchos inputs)
-------------------------------------------------
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -10)
scroll.Position = UDim2.new(0, 5, 0, 5)
scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

-------------------------------------------------
-- FUNCION CREAR BOX
-------------------------------------------------
local function createBox(text)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -10, 0, 35)
	box.BackgroundColor3 = Color3.fromRGB(40,40,40)
	box.TextColor3 = Color3.new(1,1,1)
	box.PlaceholderText = text
	box.Text = ""
	box.ClearTextOnFocus = false
	box.Parent = scroll
	
	local corner = Instance.new("UICorner", box)
	corner.CornerRadius = UDim.new(0,8)
	
	return box
end

-------------------------------------------------
-- INPUTS
-------------------------------------------------
local gameIdBox = createBox("Game PlaceId")
local gameNameBox = createBox("Nombre del juego")
local folderBox = createBox("Carpetas en Workspace (ej: Kit,Hum)")
local remoteBox = createBox("Remotes en ReplicatedStorage (ej: FreeReviveRequest,SkipTutorial)")
local intValueBox = createBox("IntValues (ej: TotalDays)")
local leaderstatsBox = createBox("Leaderstats (ej: MaxDays,Income)")
local minCondBox = createBox("Mínimo de condiciones (ej: 2)")
local execBox = createBox("Código a ejecutar (ej: loadstring(...))")

execBox.Size = UDim2.new(1, -10, 0, 70)

-------------------------------------------------
-- BOTON
-------------------------------------------------
local generate = Instance.new("TextButton", scroll)
generate.Size = UDim2.new(1, -10, 0, 40)
generate.Text = "GENERAR LOADER"
generate.BackgroundColor3 = Color3.fromRGB(0,170,255)
generate.TextColor3 = Color3.new(1,1,1)

local cornerBtn = Instance.new("UICorner", generate)
cornerBtn.CornerRadius = UDim.new(0,10)

-------------------------------------------------
-- OUTPUT
-------------------------------------------------
local output = Instance.new("TextBox", scroll)
output.Size = UDim2.new(1, -10, 0, 150)
output.BackgroundColor3 = Color3.fromRGB(15,15,15)
output.TextColor3 = Color3.fromRGB(0,255,0)
output.TextWrapped = true
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top
output.MultiLine = true
output.ClearTextOnFocus = false

local cornerOut = Instance.new("UICorner", output)
cornerOut.CornerRadius = UDim.new(0,8)

-------------------------------------------------
-- GENERADOR
-------------------------------------------------
generate.MouseButton1Click:Connect(function()

	local condicionesMin = tonumber(minCondBox.Text) or 1
	
	local code = ""
	code ..= "repeat task.wait() until game:IsLoaded()\n"
	code ..= "local condiciones = 0\n"
	code ..= "local player = game:GetService('Players').LocalPlayer\n\n"

	-- GameId
	if gameIdBox.Text ~= "" then
		code ..= "if game.PlaceId == "..gameIdBox.Text.." then condiciones += 1 end\n\n"
	end
	
	-- Carpetas (PROFUNDO + limpia espacios)
	if folderBox.Text ~= "" then
		for folder in string.gmatch(folderBox.Text, '([^,]+)') do
			folder = folder:match("^%s*(.-)%s*$")
			code ..= "if game.Workspace:FindFirstChild('"..folder.."', true) then condiciones += 1 end\n"
		end
	end
	
	-- Remotes (PROFUNDO + limpia espacios)
	if remoteBox.Text ~= "" then
		for remote in string.gmatch(remoteBox.Text, '([^,]+)') do
			remote = remote:match("^%s*(.-)%s*$")
			code ..= "if game.ReplicatedStorage:FindFirstChild('"..remote.."', true) then condiciones += 1 end\n"
		end
	end
	
	-- IntValues (profundo)
	if intValueBox.Text ~= "" then
		for val in string.gmatch(intValueBox.Text, '([^,]+)') do
			val = val:match("^%s*(.-)%s*$")
			code ..= "if game:FindFirstChild('"..val.."', true) then condiciones += 1 end\n"
		end
	end
	
	-- Leaderstats
	if leaderstatsBox.Text ~= "" then
		code ..= "local ls = player:FindFirstChild('leaderstats')\n"
		for stat in string.gmatch(leaderstatsBox.Text, '([^,]+)') do
			stat = stat:match("^%s*(.-)%s*$")
			code ..= "if ls and ls:FindFirstChild('"..stat.."') then condiciones += 1 end\n"
		end
	end
	
	code ..= "\nif condiciones >= "..condicionesMin.." then\n"
	code ..= "    "..execBox.Text.."\n"
	code ..= "end"
	
	output.Text = code
end)
