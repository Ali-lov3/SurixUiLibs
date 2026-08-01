local Gokai = {}
Gokai.__index = Gokai

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local LucideLoaded, LucideModule = pcall(function()
	return (loadstring(game:HttpGet(
		"https://gitlab.com/upio/lucide-roblox-direct/-/raw/main/source.lua"
	)))()
end)

local THEME = {
	Background  = Color3.fromRGB(5,   5,   5),
	Surface     = Color3.fromRGB(13,  13,  13),
	SurfaceMid  = Color3.fromRGB(18,  18,  18),
	SurfaceHigh = Color3.fromRGB(25,  25,  25),
	Border      = Color3.fromRGB(38,  38,  38),
	BorderHigh  = Color3.fromRGB(55,  55,  55),
	TextPrimary = Color3.fromRGB(235, 235, 235),
	TextSub     = Color3.fromRGB(145, 145, 145),
	TextMuted   = Color3.fromRGB(75,  75,  75),
	White       = Color3.fromRGB(255, 255, 255),
	Black       = Color3.fromRGB(0,   0,   0),
	ToggleOn    = Color3.fromRGB(210, 210, 210),
	ToggleOff   = Color3.fromRGB(38,  38,  38),
}

local THEMES = {
	Midnight = {
		Background=Color3.fromRGB(5,5,5),     Surface=Color3.fromRGB(13,13,13),   SurfaceMid=Color3.fromRGB(18,18,18),
		SurfaceHigh=Color3.fromRGB(25,25,25), Border=Color3.fromRGB(38,38,38),    BorderHigh=Color3.fromRGB(55,55,55),
		TextPrimary=Color3.fromRGB(235,235,235), TextSub=Color3.fromRGB(145,145,145), TextMuted=Color3.fromRGB(75,75,75),
		ToggleOn=Color3.fromRGB(210,210,210), ToggleOff=Color3.fromRGB(38,38,38),
	},
	Slate = {
		Background=Color3.fromRGB(8,10,14),    Surface=Color3.fromRGB(13,16,22),   SurfaceMid=Color3.fromRGB(19,23,32),
		SurfaceHigh=Color3.fromRGB(27,32,44),  Border=Color3.fromRGB(42,48,64),    BorderHigh=Color3.fromRGB(58,67,86),
		TextPrimary=Color3.fromRGB(224,230,242), TextSub=Color3.fromRGB(138,148,168), TextMuted=Color3.fromRGB(70,80,100),
		ToggleOn=Color3.fromRGB(160,180,220),  ToggleOff=Color3.fromRGB(42,48,64),
	},
	Carbon = {
		Background=Color3.fromRGB(10,8,7),     Surface=Color3.fromRGB(16,14,12),   SurfaceMid=Color3.fromRGB(22,19,17),
		SurfaceHigh=Color3.fromRGB(30,27,24),  Border=Color3.fromRGB(46,41,36),    BorderHigh=Color3.fromRGB(64,57,50),
		TextPrimary=Color3.fromRGB(238,232,225), TextSub=Color3.fromRGB(155,145,135), TextMuted=Color3.fromRGB(80,72,65),
		ToggleOn=Color3.fromRGB(210,190,170),  ToggleOff=Color3.fromRGB(46,41,36),
	},
	Frost = {
		Background=Color3.fromRGB(6,9,13),     Surface=Color3.fromRGB(10,15,21),   SurfaceMid=Color3.fromRGB(15,22,31),
		SurfaceHigh=Color3.fromRGB(20,30,44),  Border=Color3.fromRGB(34,50,68),    BorderHigh=Color3.fromRGB(50,72,95),
		TextPrimary=Color3.fromRGB(218,234,248), TextSub=Color3.fromRGB(128,155,180), TextMuted=Color3.fromRGB(62,88,114),
		ToggleOn=Color3.fromRGB(140,190,240),  ToggleOff=Color3.fromRGB(34,50,68),
	},
	Stone = {
		Background=Color3.fromRGB(9,9,9),      Surface=Color3.fromRGB(15,15,14),   SurfaceMid=Color3.fromRGB(21,21,20),
		SurfaceHigh=Color3.fromRGB(29,29,27),  Border=Color3.fromRGB(44,44,42),    BorderHigh=Color3.fromRGB(61,61,58),
		TextPrimary=Color3.fromRGB(230,228,223), TextSub=Color3.fromRGB(146,144,138), TextMuted=Color3.fromRGB(76,74,70),
		ToggleOn=Color3.fromRGB(200,198,190),  ToggleOff=Color3.fromRGB(44,44,42),
	},
	Ember = {
		Background=Color3.fromRGB(10,6,5),     Surface=Color3.fromRGB(16,11,9),    SurfaceMid=Color3.fromRGB(22,15,13),
		SurfaceHigh=Color3.fromRGB(31,22,18),  Border=Color3.fromRGB(50,34,28),    BorderHigh=Color3.fromRGB(68,48,39),
		TextPrimary=Color3.fromRGB(240,228,220), TextSub=Color3.fromRGB(162,138,125), TextMuted=Color3.fromRGB(88,68,58),
		ToggleOn=Color3.fromRGB(220,170,140),  ToggleOff=Color3.fromRGB(50,34,28),
	},
}

local CONFIG_FOLDER = "GokaiUI/configs"
local AUTOLOAD_FILE = "GokaiUI/autoload.txt"

local function hasFS()
	return isfolder ~= nil and writefile ~= nil and readfile ~= nil and listfiles ~= nil and makefolder ~= nil
end

local function ensureFolder()
	if not hasFS() then return end
	pcall(function()
		if not isfolder("GokaiUI") then makefolder("GokaiUI") end
		if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
	end)
end

local function listConfigs()
	if not hasFS() then return {} end
	ensureFolder()
	local out = {}
	pcall(function()
		for _, f in ipairs(listfiles(CONFIG_FOLDER)) do
			local name = f:match("([^/\\]+)%.json$")
			if name then table.insert(out, name) end
		end
	end)
	return out
end

local function saveConfig(name, data)
	if not hasFS() then return false end
	ensureFolder()
	local ok = pcall(function()
		writefile(CONFIG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data))
	end)
	return ok
end

local function loadConfig(name)
	if not hasFS() then return nil end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG_FOLDER .. "/" .. name .. ".json"))
	end)
	return ok and data or nil
end

local function deleteConfig(name)
	if not hasFS() then return end
	pcall(function() delfile(CONFIG_FOLDER .. "/" .. name .. ".json") end)
end

local function setAutoload(name)
	if not hasFS() then return end
	ensureFolder()
	pcall(function()
		if name and name ~= "" then
			writefile(AUTOLOAD_FILE, name)
		else
			if isfile and isfile(AUTOLOAD_FILE) then delfile(AUTOLOAD_FILE) end
		end
	end)
end

local function getAutoload()
	if not hasFS() then return nil end
	if isfile and not isfile(AUTOLOAD_FILE) then return nil end
	local ok, v = pcall(readfile, AUTOLOAD_FILE)
	return (ok and v and v ~= "") and v or nil
end

local function c3Match(a, b)
	return math.abs(a.R - b.R) < 0.004 and math.abs(a.G - b.G) < 0.004 and math.abs(a.B - b.B) < 0.004
end

local function mapColor(color, oldTheme, newTheme)
	for k, old in pairs(oldTheme) do
		if newTheme[k] and c3Match(color, old) then return newTheme[k] end
	end
	return nil
end

local function Tween(obj, props, t, style)
	TweenService:Create(
		obj,
		TweenInfo.new(t or 0.16, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		props
	):Play()
end

local function New(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" and k ~= "Children" then
			inst[k] = v
		end
	end
	if props.Children then
		for _, c in ipairs(props.Children) do c.Parent = inst end
	end
	if props.Parent then inst.Parent = props.Parent end
	return inst
end

local function Corner(parent, r)
	return New("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = parent })
end

local function Border(parent, color, thickness)
	return New("UIStroke", {
		Color           = color or THEME.Border,
		Thickness       = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent          = parent,
	})
end

local function Gradient(parent, stops, rotation)
	local kp = {}
	for _, s in ipairs(stops) do table.insert(kp, ColorSequenceKeypoint.new(s[1], s[2])) end
	return New("UIGradient", { Color = ColorSequence.new(kp), Rotation = rotation or 90, Parent = parent })
end

local function GradAlpha(parent, stops, rotation)
	local kp = {}
	for _, s in ipairs(stops) do table.insert(kp, NumberSequenceKeypoint.new(s[1], s[2])) end
	return New("UIGradient", { Transparency = NumberSequence.new(kp), Rotation = rotation or 90, Parent = parent })
end

local function GetIcon(name)
	if not LucideLoaded or not LucideModule or not name or name == "" then return nil end
	local ok, icon = pcall(LucideModule.GetAsset, name)
	return (ok and icon) and icon or nil
end

local function Icon(parent, name, size, pos, color)
	if not name or name == "" then return nil end
	local icon = GetIcon(name)
	if not icon then return nil end
	return New("ImageLabel", {
		Size            = size or UDim2.new(0, 14, 0, 14),
		Position        = pos or UDim2.new(0, 0, 0.5, -7),
		BackgroundTransparency = 1,
		Image           = icon.Url or icon.Id or "",
		ImageRectOffset = icon.ImageRectOffset or Vector2.zero,
		ImageRectSize   = icon.ImageRectSize   or Vector2.zero,
		ImageColor3     = color or THEME.TextSub,
		ScaleType       = Enum.ScaleType.Crop,
		Parent          = parent,
	})
end

local function Draggable(handle, frame)
	local down, start, origin = false
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			down, start, origin = true, i.Position, frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if down and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - start
			frame.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			down = false
		end
	end)
end

local function CalcScale()
	local vp = workspace.CurrentCamera.ViewportSize
	local sx  = (vp.X - 20) / 580
	local sy  = (vp.Y - 60) / 450
	return math.max(math.min(sx, sy, 1.0), 0.52)
end

function Gokai.new(config)
	local self       = setmetatable({}, Gokai)
	config           = config or {}
	self.Title       = config.Title  or "Gokai"
	self.Footer      = config.Footer or ""
	self.Logo        = config.Logo   or ""
	self.Tabs        = {}
	self.Active      = nil
	self.Open        = true
	self._flags      = {}
	self._currentTheme = "Midnight"

	local gui = New("ScreenGui", {
		Name           = "GokaiUI",
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	pcall(function() gui.Parent = CoreGui end)
	if not gui.Parent then gui.Parent = game.Players.LocalPlayer.PlayerGui end
	self._gui = gui

	local uiScale = New("UIScale", { Scale = CalcScale(), Parent = gui })
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		uiScale.Scale = CalcScale()
	end)

	local W, H = 580, 450

	local win = New("Frame", {
		Name             = "Window",
		Size             = UDim2.new(0, W, 0, H),
		Position         = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel  = 0,
		ClipsDescendants = false,
		Parent           = gui,
	})
	Corner(win, 10)
	Border(win, THEME.Border, 1)
	self._win = win

	local winClip = New("Frame", {
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants       = true,
		Parent                 = win,
	})
	Corner(winClip, 10)
	self._winClip = winClip

	local topBar = New("Frame", {
		Name             = "TopBar",
		Size             = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = THEME.SurfaceMid,
		BorderSizePixel  = 0,
		Parent           = winClip,
	})
	Corner(topBar, 10)
	New("Frame", {
		Size             = UDim2.new(1, 0, 0, 10),
		Position         = UDim2.new(0, 0, 1, -10),
		BackgroundColor3 = THEME.SurfaceMid,
		BorderSizePixel  = 0,
		Parent           = topBar,
	})
	Gradient(topBar, {
		{ 0,   Color3.fromRGB(30, 30, 30) },
		{ 0.5, Color3.fromRGB(16, 16, 16) },
		{ 1,   Color3.fromRGB(8,  8,  8)  },
	}, 180)
	local topShine = New("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = THEME.White,
		BorderSizePixel  = 0,
		Parent           = topBar,
	})
	GradAlpha(topShine, { {0,1},{0.15,0.55},{0.5,0.55},{0.85,0.55},{1,1} }, 0)
	Draggable(topBar, win)

	if self.Logo ~= "" then
		New("ImageLabel", {
			Size                   = UDim2.new(0, 18, 0, 18),
			Position               = UDim2.new(0, 12, 0.5, -9),
			BackgroundTransparency = 1,
			Image                  = self.Logo,
			ScaleType              = Enum.ScaleType.Fit,
			Parent                 = topBar,
		})
	end
	local logoOff = self.Logo ~= "" and 36 or 12
	New("TextLabel", {
		Size             = UDim2.new(1, -(logoOff + 16), 1, 0),
		Position         = UDim2.new(0, logoOff, 0, 0),
		BackgroundTransparency = 1,
		Text             = self.Title,
		Font             = Enum.Font.GothamBold,
		TextSize         = 13,
		TextColor3       = THEME.TextPrimary,
		TextXAlignment   = Enum.TextXAlignment.Left,
		Parent           = topBar,
	})

	local tabBar = New("Frame", {
		Name                   = "TabBar",
		Size                   = UDim2.new(1, -20, 0, 28),
		Position               = UDim2.new(0, 10, 0, 42),
		BackgroundTransparency = 1,
		Parent                 = winClip,
	})
	New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder     = Enum.SortOrder.LayoutOrder,
		Padding       = UDim.new(0, 3),
		Parent        = tabBar,
	})
	self._tabBar = tabBar

	New("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 0, 71),
		BackgroundColor3 = THEME.Border,
		BorderSizePixel  = 0,
		Parent           = winClip,
	})

	local content = New("Frame", {
		Name                   = "Content",
		Size                   = UDim2.new(1, -16, 1, -98),
		Position               = UDim2.new(0, 8, 0, 75),
		BackgroundTransparency = 1,
		ClipsDescendants       = false,
		Parent                 = winClip,
	})
	self._content = content

	local footer = New("Frame", {
		Name             = "Footer",
		Size             = UDim2.new(1, 0, 0, 22),
		Position         = UDim2.new(0, 0, 1, -22),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel  = 0,
		Parent           = winClip,
	})
	New("Frame", {
		Size             = UDim2.new(1, 0, 0, 8),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel  = 0,
		Parent           = footer,
	})
	Gradient(footer, { {0,Color3.fromRGB(14,14,14)},{1,Color3.fromRGB(6,6,6)} }, 180)
	New("TextLabel", {
		Size             = UDim2.new(0.5, -8, 1, 0),
		Position         = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text             = self.Footer,
		Font             = Enum.Font.Gotham,
		TextSize         = 10,
		TextColor3       = THEME.TextMuted,
		TextXAlignment   = Enum.TextXAlignment.Left,
		Parent           = footer,
	})
	New("TextLabel", {
		Size             = UDim2.new(0.5, -8, 1, 0),
		Position         = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		Text             = "Gokai UI",
		Font             = Enum.Font.Gotham,
		TextSize         = 10,
		TextColor3       = THEME.TextMuted,
		TextXAlignment   = Enum.TextXAlignment.Right,
		Parent           = footer,
	})

	local popupLayer = New("Frame", {
		Name                   = "PopupLayer",
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants       = false,
		ZIndex                 = 200,
		Parent                 = gui,
	})
	self._popupLayer = popupLayer

	local inputSink = New("TextButton", {
		Name                   = "InputSink",
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text                   = "",
		BorderSizePixel        = 0,
		ZIndex                 = 150,
		Visible                = false,
		Active                 = true,
		Parent                 = gui,
	})
	self._inputSink = inputSink

	local toggleBtn = New("TextButton", {
		Name             = "ToggleBtn",
		Size             = UDim2.new(0, 28, 0, 56),
		AnchorPoint      = Vector2.new(0, 0.5),
		Position         = UDim2.new(0, 6, 0.5, 0),
		BackgroundColor3 = THEME.SurfaceMid,
		Text             = "",
		BorderSizePixel  = 0,
		ZIndex           = 10,
		Parent           = gui,
	})
	Corner(toggleBtn, 8)
	Border(toggleBtn, THEME.Border, 1)
	Gradient(toggleBtn, {
		{0, Color3.fromRGB(26, 26, 26)},
		{1, Color3.fromRGB(12, 12, 12)},
	}, 180)
	local toggleIcOpen  = Icon(toggleBtn, "panel-left-open",  UDim2.new(0,14,0,14), UDim2.new(0.5,-7,0.5,-7), THEME.TextSub)
	local toggleIcClose = Icon(toggleBtn, "panel-left-close", UDim2.new(0,14,0,14), UDim2.new(0.5,-7,0.5,-7), THEME.TextSub)
	if not toggleIcOpen and not toggleIcClose then
		local fallback = New("TextLabel", {
			Size             = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Text             = "≡",
			Font             = Enum.Font.GothamBold,
			TextSize         = 16,
			TextColor3       = THEME.TextSub,
			Parent           = toggleBtn,
		})
		self._toggleFallback = fallback
	end
	if toggleIcClose then toggleIcClose.Visible = false end
	self._toggleIcOpen  = toggleIcOpen
	self._toggleIcClose = toggleIcClose

	local function setToggleIcon(open)
		if toggleIcOpen  then toggleIcOpen.Visible  = not open end
		if toggleIcClose then toggleIcClose.Visible = open end
	end

	local function toggleWindow(v)
		self.Open = (v ~= nil) and v or (not self.Open)
		if self.Open then
			win.Visible = true
			Tween(win, { Size = UDim2.new(0, W, 0, H) }, 0.2, Enum.EasingStyle.Quart)
			Tween(toggleBtn, { BackgroundColor3 = THEME.SurfaceMid }, 0.15)
		else
			Tween(win, { Size = UDim2.new(0, W, 0, 0) }, 0.18, Enum.EasingStyle.Quart)
			task.delay(0.19, function() win.Visible = false end)
			Tween(toggleBtn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.15)
		end
		setToggleIcon(self.Open)
	end
	self.Toggle = toggleWindow

	toggleBtn.MouseButton1Click:Connect(function() toggleWindow() end)
	toggleBtn.MouseEnter:Connect(function() Tween(toggleBtn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
	toggleBtn.MouseLeave:Connect(function() Tween(toggleBtn, { BackgroundColor3 = self.Open and THEME.SurfaceMid or THEME.SurfaceHigh }, 0.12) end)

	self:_buildSettingsTab()
	return self
end

function Gokai:_applyTheme(name)
	local newTheme = THEMES[name]
	if not newTheme then return end

	local oldTheme = {}
	for k, v in pairs(THEME) do oldTheme[k] = v end

	for k, v in pairs(newTheme) do THEME[k] = v end
	if newTheme.ToggleOff then THEME.ToggleOff = newTheme.ToggleOff end
	if newTheme.ToggleOn  then THEME.ToggleOn  = newTheme.ToggleOn  end

	self._currentTheme = name

	for _, inst in ipairs(self._gui:GetDescendants()) do
		pcall(function()
			if inst:IsA("GuiObject") and inst.BackgroundTransparency < 1 then
				local nc = mapColor(inst.BackgroundColor3, oldTheme, newTheme)
				if nc then inst.BackgroundColor3 = nc end
			end

			if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
				local nc = mapColor(inst.TextColor3, oldTheme, newTheme)
				if nc then inst.TextColor3 = nc end
				if inst:IsA("TextBox") then
					local pc = mapColor(inst.PlaceholderColor3, oldTheme, newTheme)
					if pc then inst.PlaceholderColor3 = pc end
				end
			end

			if inst:IsA("UIStroke") then
				local nc = mapColor(inst.Color, oldTheme, newTheme)
				if nc then inst.Color = nc end
			end

			if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
				if inst.Image ~= "" then
					local nc = mapColor(inst.ImageColor3, oldTheme, newTheme)
					if nc then inst.ImageColor3 = nc end
				end
			end

			if inst:IsA("UIGradient") and inst.Color ~= ColorSequence.new(Color3.new(1,1,1)) then
				local kps = inst.Color.Keypoints
				local changed = false
				local newKps = {}
				for _, kp in ipairs(kps) do
					local nc = mapColor(kp.Value, oldTheme, newTheme)
					if nc then changed = true; table.insert(newKps, ColorSequenceKeypoint.new(kp.Time, nc))
					else table.insert(newKps, kp) end
				end
				if changed then inst.Color = ColorSequence.new(newKps) end
			end
		end)
	end
end

function Gokai:AddTab(cfg)
	cfg = cfg or {}
	local tab = { Name = cfg.Name or "Tab", Icon = cfg.Icon or "", Groups = {} }
local owner = self

	local inputSink  = self._inputSink
	local popupLayer = self._popupLayer

	local hasIcon = tab.Icon ~= ""
	local tw      = #tab.Name * 7 + (hasIcon and 20 or 0) + 22

	local btn = New("TextButton", {
		Name                   = tab.Name,
		Size                   = UDim2.new(0, tw, 1, 0),
		BackgroundTransparency = 1,
		Text                   = "",
		BorderSizePixel        = 0,
		LayoutOrder            = #self.Tabs + 1,
		Parent                 = self._tabBar,
	})

	local iconW = 0
	if hasIcon then
		local ic = Icon(btn, tab.Icon, UDim2.new(0,13,0,13), UDim2.new(0,6,0.5,-6.5), THEME.TextMuted)
		if ic then iconW = 19 end
	end

	local lbl = New("TextLabel", {
		Size             = UDim2.new(1, -(iconW + 6), 1, 0),
		Position         = UDim2.new(0, iconW + 6, 0, 0),
		BackgroundTransparency = 1,
		Text             = tab.Name,
		Font             = Enum.Font.GothamSemibold,
		TextSize         = 12,
		TextColor3       = THEME.TextMuted,
		TextXAlignment   = Enum.TextXAlignment.Left,
		Parent           = btn,
	})

	local bar = New("Frame", {
		Size             = UDim2.new(1, -8, 0, 2),
		Position         = UDim2.new(0, 4, 1, -2),
		BackgroundColor3 = THEME.White,
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		Parent           = btn,
	})
	Corner(bar, 1)

	local page = New("Frame", {
		Name                   = tab.Name,
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible                = false,
		Parent                 = self._content,
	})

	local leftCol = New("Frame", {
		Size                   = UDim2.new(0.5, -4, 1, 0),
		BackgroundTransparency = 1,
		Parent                 = page,
	})
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = leftCol })

	local rightCol = New("Frame", {
		Size                   = UDim2.new(0.5, -4, 1, 0),
		Position               = UDim2.new(0.5, 4, 0, 0),
		BackgroundTransparency = 1,
		Parent                 = page,
	})
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = rightCol })

	tab._btn   = btn
	tab._lbl   = lbl
	tab._bar   = bar
	tab._page  = page
	tab._left  = leftCol
	tab._right = rightCol

	local function activate()
		if self.Active then
			Tween(self.Active._lbl, { TextColor3 = THEME.TextMuted }, 0.15)
			Tween(self.Active._bar, { BackgroundTransparency = 1 }, 0.15)
			self.Active._page.Visible = false
		end
		self.Active = tab
		Tween(lbl, { TextColor3 = THEME.TextPrimary }, 0.15)
		Tween(bar, { BackgroundTransparency = 0 }, 0.15)
		page.Visible = true
	end

	btn.MouseButton1Click:Connect(activate)
	btn.MouseEnter:Connect(function()
		if self.Active ~= tab then Tween(lbl, { TextColor3 = THEME.TextSub }, 0.12) end
	end)
	btn.MouseLeave:Connect(function()
		if self.Active ~= tab then Tween(lbl, { TextColor3 = THEME.TextMuted }, 0.12) end
	end)

	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then activate() end

	function tab:AddGroupbox(gcfg)
		gcfg = gcfg or {}
		local gb   = { Name = gcfg.Name or "Group", Icon = gcfg.Icon or "", Side = gcfg.Side or "left" }
		local col  = gb.Side == "right" and rightCol or leftCol

		local box = New("Frame", {
			Name             = gb.Name,
			Size             = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = THEME.Surface,
			BorderSizePixel  = 0,
			AutomaticSize    = Enum.AutomaticSize.Y,
			LayoutOrder      = #tab.Groups + 1,
			Parent           = col,
		})
		Corner(box, 7)
		Border(box, THEME.Border, 1)
		Gradient(box, { {0,Color3.fromRGB(16,16,16)},{1,Color3.fromRGB(8,8,8)} }, 180)

		local hdr = New("Frame", {
			Size             = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = THEME.SurfaceHigh,
			BorderSizePixel  = 0,
			Parent           = box,
		})
		Corner(hdr, 7)
		New("Frame", {
			Size             = UDim2.new(1, 0, 0, 7),
			Position         = UDim2.new(0, 0, 1, -7),
			BackgroundColor3 = THEME.SurfaceHigh,
			BorderSizePixel  = 0,
			Parent           = hdr,
		})
		Gradient(hdr, { {0,Color3.fromRGB(28,28,28)},{0.6,Color3.fromRGB(18,18,18)},{1,Color3.fromRGB(10,10,10)} }, 180)
		local hdrShine = New("Frame", {
			Size             = UDim2.new(1,0,0,1),
			BackgroundColor3 = THEME.White,
			BorderSizePixel  = 0,
			Parent           = hdr,
		})
		GradAlpha(hdrShine, { {0,1},{0.2,0.7},{0.5,0.65},{0.8,0.7},{1,1} }, 0)

		local iconOff = 0
		if gb.Icon ~= "" then
			local ic = Icon(hdr, gb.Icon, UDim2.new(0,12,0,12), UDim2.new(0,9,0.5,-6), THEME.TextSub)
			if ic then iconOff = 20 end
		end
		New("TextLabel", {
			Size             = UDim2.new(1, -(iconOff + 18), 1, 0),
			Position         = UDim2.new(0, iconOff + 9, 0, 0),
			BackgroundTransparency = 1,
			Text             = gb.Name,
			Font             = Enum.Font.GothamSemibold,
			TextSize         = 11,
			TextColor3       = THEME.TextSub,
			TextXAlignment   = Enum.TextXAlignment.Left,
			Parent           = hdr,
		})

		local body = New("Frame", {
			Name                   = "Body",
			Size                   = UDim2.new(1, 0, 0, 0),
			Position               = UDim2.new(0, 0, 0, 28),
			BackgroundTransparency = 1,
			AutomaticSize          = Enum.AutomaticSize.Y,
			Parent                 = box,
		})
		New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1), Parent = body })
		New("UIPadding", {
			PaddingLeft   = UDim.new(0, 8),
			PaddingRight  = UDim.new(0, 8),
			PaddingTop    = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 8),
			Parent        = body,
		})

		gb._box  = box
		gb._body = body
		table.insert(tab.Groups, gb)

local gflags = owner._flags

		local function rowOrd() return #body:GetChildren() end

		function gb:AddToggle(tc)
			tc = tc or {}
			local t = { Value = tc.Default or false }
			if tc.Flag then gflags[tc.Flag] = t end

			local row = New("TextButton", {
				Size             = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Text             = "",
				BorderSizePixel  = 0,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})
			Corner(row, 4)
			New("TextLabel", {
				Size             = UDim2.new(1, -46, 1, 0),
				Position         = UDim2.new(0, 2, 0, 0),
				BackgroundTransparency = 1,
				Text             = tc.Name or "Toggle",
				Font             = Enum.Font.Gotham,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				TextXAlignment   = Enum.TextXAlignment.Left,
				Parent           = row,
			})

			local track = New("Frame", {
				Size             = UDim2.new(0, 34, 0, 17),
				Position         = UDim2.new(1, -35, 0.5, -8.5),
				BackgroundColor3 = THEME.ToggleOff,
				BorderSizePixel  = 0,
				Parent           = row,
			})
			Corner(track, 9)
			Border(track, THEME.Border, 1)

			local thumb = New("Frame", {
				Size             = UDim2.new(0, 11, 0, 11),
				Position         = UDim2.new(0, 3, 0.5, -5.5),
				BackgroundColor3 = THEME.TextMuted,
				BorderSizePixel  = 0,
				Parent           = track,
			})
			Corner(thumb, 6)

			local function applyVis(v, anim)
				if anim then
					Tween(track, { BackgroundColor3 = v and THEME.ToggleOn or THEME.ToggleOff }, 0.18)
					Tween(thumb, {
						Position        = v and UDim2.new(0,20,0.5,-5.5) or UDim2.new(0,3,0.5,-5.5),
						BackgroundColor3 = v and THEME.White or THEME.TextMuted,
					}, 0.18)
				else
					track.BackgroundColor3 = v and THEME.ToggleOn or THEME.ToggleOff
					thumb.Position         = v and UDim2.new(0,20,0.5,-5.5) or UDim2.new(0,3,0.5,-5.5)
					thumb.BackgroundColor3 = v and THEME.White or THEME.TextMuted
				end
			end
			applyVis(t.Value, false)

			row.MouseButton1Click:Connect(function()
				t.Value = not t.Value
				applyVis(t.Value, true)
				if tc.Callback then tc.Callback(t.Value) end
			end)
			row.MouseEnter:Connect(function() row.BackgroundTransparency = 0; row.BackgroundColor3 = THEME.SurfaceHigh end)
			row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)

			function t:Set(v) self.Value = v; applyVis(v, true); if tc.Callback then tc.Callback(v) end end
			return t
		end

		function gb:AddCheckbox(cc)
			cc = cc or {}
			local c = { Value = cc.Default or false }
			if cc.Flag then gflags[cc.Flag] = c end

			local row = New("TextButton", {
				Size             = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Text             = "",
				BorderSizePixel  = 0,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})
			Corner(row, 4)

			local box2 = New("Frame", {
				Size             = UDim2.new(0, 15, 0, 15),
				Position         = UDim2.new(0, 2, 0.5, -7.5),
				BackgroundColor3 = THEME.ToggleOff,
				BorderSizePixel  = 0,
				Parent           = row,
			})
			Corner(box2, 3)
			Border(box2, THEME.Border, 1)

			local mark = New("ImageLabel", {
				Size             = UDim2.new(0, 9, 0, 9),
				Position         = UDim2.new(0.5, -4.5, 0.5, -4.5),
				BackgroundTransparency = 1,
				Image            = "rbxassetid://7072706796",
				ImageColor3      = THEME.Black,
				Visible          = false,
				Parent           = box2,
			})
			New("TextLabel", {
				Size             = UDim2.new(1, -26, 1, 0),
				Position         = UDim2.new(0, 23, 0, 0),
				BackgroundTransparency = 1,
				Text             = cc.Name or "Checkbox",
				Font             = Enum.Font.Gotham,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				TextXAlignment   = Enum.TextXAlignment.Left,
				Parent           = row,
			})

			local function applyVis(v, anim)
				mark.Visible = v
				if anim then Tween(box2, { BackgroundColor3 = v and THEME.White or THEME.ToggleOff }, 0.14)
				else box2.BackgroundColor3 = v and THEME.White or THEME.ToggleOff end
			end
			applyVis(c.Value, false)

			row.MouseButton1Click:Connect(function()
				c.Value = not c.Value; applyVis(c.Value, true)
				if cc.Callback then cc.Callback(c.Value) end
			end)
			row.MouseEnter:Connect(function() row.BackgroundTransparency = 0; row.BackgroundColor3 = THEME.SurfaceHigh end)
			row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)

			function c:Set(v) self.Value = v; applyVis(v, true); if cc.Callback then cc.Callback(v) end end
			return c
		end

		function gb:AddButton(bc)
			bc = bc or {}

			local btn2 = New("TextButton", {
				Size             = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = THEME.SurfaceMid,
				Text             = "",
				BorderSizePixel  = 0,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})
			Corner(btn2, 5)
			Border(btn2, THEME.Border, 1)
			Gradient(btn2, { {0,Color3.fromRGB(24,24,24)},{0.5,Color3.fromRGB(15,15,15)},{1,Color3.fromRGB(8,8,8)} }, 180)

			local shine2 = New("Frame", {
				Size             = UDim2.new(1,0,0,1),
				BackgroundColor3 = THEME.White,
				BackgroundTransparency = 0.65,
				BorderSizePixel  = 0,
				Parent           = btn2,
			})
			GradAlpha(shine2, { {0,1},{0.2,0},{0.8,0},{1,1} }, 0)

			New("TextLabel", {
				Size             = UDim2.new(1,0,1,0),
				BackgroundTransparency = 1,
				Text             = bc.Name or "Button",
				Font             = Enum.Font.GothamSemibold,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				Parent           = btn2,
			})

			btn2.MouseButton1Click:Connect(function()
				Tween(btn2, { BackgroundColor3 = THEME.SurfaceHigh }, 0.07)
				task.delay(0.12, function() Tween(btn2, { BackgroundColor3 = THEME.SurfaceMid }, 0.15) end)
				if bc.Callback then bc.Callback() end
			end)
			btn2.MouseEnter:Connect(function() Tween(btn2, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
			btn2.MouseLeave:Connect(function() Tween(btn2, { BackgroundColor3 = THEME.SurfaceMid }, 0.12) end)

			return {}
		end

		function gb:AddInput(ic)
			ic = ic or {}
			local inp = { Value = ic.Default or "" }

			local labelH = ic.Name and 16 or 0
			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, labelH + 28),
				BackgroundTransparency = 1,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})

			if ic.Name then
				New("TextLabel", {
					Size             = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Text             = ic.Name,
					Font             = Enum.Font.Gotham,
					TextSize         = 11,
					TextColor3       = THEME.TextSub,
					TextXAlignment   = Enum.TextXAlignment.Left,
					Parent           = wrap,
				})
			end

			local box3 = New("TextBox", {
				Size             = UDim2.new(1, 0, 0, 26),
				Position         = UDim2.new(0, 0, 0, labelH),
				BackgroundColor3 = THEME.SurfaceMid,
				BorderSizePixel  = 0,
				Text             = ic.Default or "",
				PlaceholderText  = ic.Placeholder or "",
				PlaceholderColor3 = THEME.TextMuted,
				Font             = Enum.Font.Gotham,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				TextXAlignment   = Enum.TextXAlignment.Left,
				ClearTextOnFocus = ic.ClearOnFocus or false,
				Parent           = wrap,
			})
			Corner(box3, 5)
			Border(box3, THEME.Border, 1)
			New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = box3 })
			Gradient(box3, { {0,Color3.fromRGB(22,22,22)},{1,Color3.fromRGB(11,11,11)} }, 180)

			box3:GetPropertyChangedSignal("Text"):Connect(function()
				inp.Value = box3.Text
				if ic.Callback then ic.Callback(box3.Text) end
			end)
			box3.Focused:Connect(function()
				Tween(box3, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12)
			end)
			box3.FocusLost:Connect(function(enter)
				Tween(box3, { BackgroundColor3 = THEME.SurfaceMid }, 0.12)
				if ic.OnEnter and enter then ic.OnEnter(box3.Text) end
			end)

			function inp:Set(v) self.Value = v; box3.Text = v end
			function inp:Get() return self.Value end
			return inp
		end

		function gb:AddSlider(sc)
			sc = sc or {}
			local mn, mx = sc.Min or 0, sc.Max or 100
			local s = { Value = math.clamp(sc.Default or mn, mn, mx) }
			if sc.Flag then gflags[sc.Flag] = s end

			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, 46),
				BackgroundTransparency = 1,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})

			local topRow = New("Frame", {
				Size             = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Parent           = wrap,
			})
			New("TextLabel", {
				Size             = UDim2.new(0.65, 0, 1, 0),
				BackgroundTransparency = 1,
				Text             = sc.Name or "Slider",
				Font             = Enum.Font.Gotham,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				TextXAlignment   = Enum.TextXAlignment.Left,
				Parent           = topRow,
			})
			local valLbl = New("TextLabel", {
				Size             = UDim2.new(0.35, 0, 1, 0),
				Position         = UDim2.new(0.65, 0, 0, 0),
				BackgroundTransparency = 1,
				Text             = tostring(s.Value),
				Font             = Enum.Font.GothamSemibold,
				TextSize         = 12,
				TextColor3       = THEME.TextSub,
				TextXAlignment   = Enum.TextXAlignment.Right,
				Parent           = topRow,
			})

			local track = New("Frame", {
				Size             = UDim2.new(1, 0, 0, 5),
				Position         = UDim2.new(0, 0, 0, 30),
				BackgroundColor3 = THEME.Border,
				BorderSizePixel  = 0,
				Parent           = wrap,
			})
			Corner(track, 3)

			local fill = New("Frame", {
				Size             = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = THEME.White,
				BorderSizePixel  = 0,
				ClipsDescendants = false,
				Parent           = track,
			})
			Corner(fill, 3)
			Gradient(fill, { {0,Color3.fromRGB(255,255,255)},{1,Color3.fromRGB(160,160,160)} }, 0)

			local thumb = New("Frame", {
				Size             = UDim2.new(0, 13, 0, 13),
				Position         = UDim2.new(1, -6, 0.5, -6.5),
				BackgroundColor3 = THEME.White,
				BorderSizePixel  = 0,
				Parent           = fill,
			})
			Corner(thumb, 7)
			Border(thumb, THEME.BorderHigh, 1.5)

			local function setValue(v)
				v = math.clamp(v, mn, mx)
				if sc.Step then v = math.round(v / sc.Step) * sc.Step end
				s.Value  = v
				local pct = (v - mn) / (mx - mn)
				Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.06)
				valLbl.Text = tostring(v)
				if sc.Callback then sc.Callback(v) end
			end
			setValue(s.Value)

			local drag = false
			thumb.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					drag = true
					if inputSink then inputSink.Visible = true end
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if drag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
					drag = false
					if inputSink then inputSink.Visible = false end
				end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					local abs = track.AbsolutePosition
					local sz  = track.AbsoluteSize
					setValue(mn + (mx - mn) * math.clamp((i.Position.X - abs.X) / sz.X, 0, 1))
				end
			end)
			track.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					local abs = track.AbsolutePosition
					local sz  = track.AbsoluteSize
					setValue(mn + (mx - mn) * math.clamp((i.Position.X - abs.X) / sz.X, 0, 1))
				end
			end)

			function s:Set(v) setValue(v) end
			return s
		end

		local function makeDropBtn(parent, placeholder, layoutOrd, posOverride)
			local dBtn = New("TextButton", {
				Size             = UDim2.new(1, 0, 0, 28),
				Position         = posOverride or UDim2.new(0,0,0,0),
				BackgroundColor3 = THEME.SurfaceMid,
				Text             = "",
				BorderSizePixel  = 0,
				LayoutOrder      = layoutOrd or 0,
				Parent           = parent,
			})
			Corner(dBtn, 5)
			Border(dBtn, THEME.Border, 1)
			Gradient(dBtn, { {0,Color3.fromRGB(22,22,22)},{1,Color3.fromRGB(11,11,11)} }, 180)

			local vLbl = New("TextLabel", {
				Size             = UDim2.new(1, -28, 1, 0),
				Position         = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text             = placeholder or "Select...",
				Font             = Enum.Font.Gotham,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				TextXAlignment   = Enum.TextXAlignment.Left,
				TextTruncate     = Enum.TextTruncate.AtEnd,
				Parent           = dBtn,
			})
			local arrowF = New("Frame", {
				Size             = UDim2.new(0,20,0,20),
				Position         = UDim2.new(1,-24,0.5,-10),
				BackgroundTransparency = 1,
				Parent           = dBtn,
			})
			local arrowIc = Icon(arrowF, "chevron-down", UDim2.new(0,12,0,12), UDim2.new(0.5,-6,0.5,-6), THEME.TextSub)
			if not arrowIc then
				New("TextLabel", {
					Size             = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1,
					Text             = "▾",
					Font             = Enum.Font.Gotham,
					TextSize         = 14,
					TextColor3       = THEME.TextSub,
					Parent           = arrowF,
				})
			end
			dBtn.MouseEnter:Connect(function() Tween(dBtn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
			dBtn.MouseLeave:Connect(function() Tween(dBtn, { BackgroundColor3 = THEME.SurfaceMid }, 0.12) end)
			return dBtn, vLbl
		end

		local function makePopup(btnRef, options, multi)
			local itemH = 26
			local popup = New("Frame", {
				Name             = "Popup",
				Size             = UDim2.new(0,1,0,0),
				BackgroundColor3 = THEME.SurfaceMid,
				BorderSizePixel  = 0,
				ClipsDescendants = true,
				Visible          = false,
				ZIndex           = 60,
				Parent           = popupLayer,
			})
			Corner(popup, 6)
			Border(popup, THEME.BorderHigh, 1)
			Gradient(popup, { {0,Color3.fromRGB(22,22,22)},{1,Color3.fromRGB(10,10,10)} }, 180)
			New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = popup })

			local function reposition()
				local abs    = btnRef.AbsolutePosition
				local sz     = btnRef.AbsoluteSize
				local layerX = popupLayer.AbsolutePosition.X
				local layerY = popupLayer.AbsolutePosition.Y
				popup.Position = UDim2.new(0, abs.X - layerX, 0, abs.Y - layerY + sz.Y + 2)
				popup.Size     = UDim2.new(0, sz.X, 0, 0)
			end

			local isOpen   = false
			local itemRefs = {}

			for i, opt in ipairs(options) do
				local item = New("TextButton", {
					Size             = UDim2.new(1,0,0,itemH),
					BackgroundTransparency = 1,
					Text             = "",
					BorderSizePixel  = 0,
					LayoutOrder      = i,
					ZIndex           = 61,
					Parent           = popup,
				})

				local chkFrame
				if multi then
					chkFrame = New("Frame", {
						Size             = UDim2.new(0,13,0,13),
						Position         = UDim2.new(0,8,0.5,-6.5),
						BackgroundColor3 = THEME.ToggleOff,
						BorderSizePixel  = 0,
						ZIndex           = 62,
						Parent           = item,
					})
					Corner(chkFrame, 3)
					Border(chkFrame, THEME.Border, 1)
					New("ImageLabel", {
						Size             = UDim2.new(0,8,0,8),
						Position         = UDim2.new(0.5,-4,0.5,-4),
						BackgroundTransparency = 1,
						Image            = "rbxassetid://7072706796",
						ImageColor3      = THEME.Black,
						Visible          = false,
						ZIndex           = 63,
						Parent           = chkFrame,
					})
				end

				local txtOff = multi and 28 or 8
				New("TextLabel", {
					Size             = UDim2.new(1, -(txtOff+6), 1, 0),
					Position         = UDim2.new(0, txtOff, 0, 0),
					BackgroundTransparency = 1,
					Text             = tostring(opt),
					Font             = Enum.Font.Gotham,
					TextSize         = 12,
					TextColor3       = THEME.TextPrimary,
					TextXAlignment   = Enum.TextXAlignment.Left,
					ZIndex           = 62,
					Parent           = item,
				})

				item.MouseEnter:Connect(function()
					item.BackgroundTransparency = 0
					item.BackgroundColor3 = THEME.SurfaceHigh
				end)
				item.MouseLeave:Connect(function() item.BackgroundTransparency = 1 end)

				itemRefs[i] = { frame = item, check = chkFrame, val = opt }
			end

			local function open()
				isOpen = true; reposition()
				popup.Visible = true
				Tween(popup, { Size = UDim2.new(0, btnRef.AbsoluteSize.X, 0, #options * itemH) }, 0.15)
			end
			local function close()
				isOpen = false
				Tween(popup, { Size = UDim2.new(0, btnRef.AbsoluteSize.X, 0, 0) }, 0.13)
				task.delay(0.14, function() if not isOpen then popup.Visible = false end end)
			end
			local function toggle() if isOpen then close() else open() end end

			return {
				popup   = popup,
				items   = itemRefs,
				open    = open,
				close   = close,
				toggle  = toggle,
				isOpen  = function() return isOpen end,
			}
		end

		function gb:AddDropdown(dc)
			dc = dc or {}
			local d = { Value = dc.Default }

			local labelH = dc.Name and 16 or 0
			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, labelH + 30),
				BackgroundTransparency = 1,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})

			if dc.Name then
				New("TextLabel", {
					Size             = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Text             = dc.Name,
					Font             = Enum.Font.Gotham,
					TextSize         = 11,
					TextColor3       = THEME.TextSub,
					TextXAlignment   = Enum.TextXAlignment.Left,
					Parent           = wrap,
				})
			end

			local opts = dc.Options or {}
			local dBtn, vLbl = makeDropBtn(wrap, d.Value or "Select...", 0, UDim2.new(0,0,0,labelH))
			local popup = makePopup(dBtn, opts, false)

			for _, ref in ipairs(popup.items) do
				ref.frame.MouseButton1Click:Connect(function()
					d.Value = ref.val
					vLbl.Text = tostring(ref.val)
					popup.close()
					if dc.Callback then dc.Callback(ref.val) end
				end)
			end
			dBtn.MouseButton1Click:Connect(function() popup.toggle() end)

			function d:Set(v)
				self.Value = v
				vLbl.Text  = v and tostring(v) or "Select..."
				if dc.Callback then dc.Callback(v) end
			end

			function d:Refresh(newOpts)
				for _, c in ipairs(popup.popup:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				opts  = newOpts
				popup = makePopup(dBtn, newOpts, false)
				for _, ref in ipairs(popup.items) do
					ref.frame.MouseButton1Click:Connect(function()
						d.Value   = ref.val
						vLbl.Text = tostring(ref.val)
						popup.close()
						if dc.Callback then dc.Callback(ref.val) end
					end)
				end
			end

			return d
		end

		function gb:AddMultiDropdown(mc)
			mc = mc or {}
			local m        = { Value = {} }
			local selected = {}

			local labelH = mc.Name and 16 or 0
			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, labelH + 30),
				BackgroundTransparency = 1,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})

			if mc.Name then
				New("TextLabel", {
					Size             = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Text             = mc.Name,
					Font             = Enum.Font.Gotham,
					TextSize         = 11,
					TextColor3       = THEME.TextSub,
					TextXAlignment   = Enum.TextXAlignment.Left,
					Parent           = wrap,
				})
			end

			local dBtn, vLbl = makeDropBtn(wrap, "Select...", 0, UDim2.new(0,0,0,labelH))
			local popup      = makePopup(dBtn, mc.Options or {}, true)

			local function updateLabel()
				local keys = {}
				for k in pairs(selected) do table.insert(keys, k) end
				m.Value   = keys
				vLbl.Text = #keys > 0 and table.concat(keys, ", ") or "Select..."
			end

			for _, ref in ipairs(popup.items) do
				ref.frame.MouseButton1Click:Connect(function()
					if selected[ref.val] then
						selected[ref.val] = nil
						ref.check.BackgroundColor3 = THEME.ToggleOff
						local chk = ref.check:FindFirstChildWhichIsA("ImageLabel")
						if chk then chk.Visible = false end
					else
						selected[ref.val] = true
						ref.check.BackgroundColor3 = THEME.White
						local chk = ref.check:FindFirstChildWhichIsA("ImageLabel")
						if chk then chk.Visible = true end
					end
					updateLabel()
					if mc.Callback then mc.Callback(m.Value) end
				end)
			end
			dBtn.MouseButton1Click:Connect(function() popup.toggle() end)

			function m:Set(vals)
				selected = {}
				for _, v in ipairs(vals) do selected[v] = true end
				updateLabel()
				if mc.Callback then mc.Callback(self.Value) end
			end
			return m
		end

		return gb
	end

	return tab
end

function Gokai:_buildSettingsTab()
	local stab = self:AddTab({ Name = "UI Settings", Icon = "settings" })
	stab._btn.LayoutOrder = 9999

	local themeBox  = stab:AddGroupbox({ Name = "Theme",  Icon = "palette", Side = "left"  })
	local configBox = stab:AddGroupbox({ Name = "Config", Icon = "save",    Side = "right" })

	local themeNames = {}
	for k in pairs(THEMES) do table.insert(themeNames, k) end
	table.sort(themeNames)

	local themeDrop = themeBox:AddDropdown({
		Name     = "Select Theme",
		Options  = themeNames,
		Default  = self._currentTheme,
	})

	themeBox:AddButton({
		Name     = "Apply Theme",
		Callback = function()
			local name = themeDrop.Value
			if name then self:_applyTheme(name) end
		end,
	})

	local configNameInput = configBox:AddInput({
		Name        = "Config Name",
		Placeholder = "Enter name...",
	})

	configBox:AddButton({
		Name = "Save Config",
		Callback = function()
			local name = configNameInput.Value
			if not name or name:gsub("%s","") == "" then return end
			local data = {}
			for flag, obj in pairs(self._flags) do
				data[flag] = obj.Value
			end
			local ok = saveConfig(name, data)
			if ok then
				cfgDrop:Refresh(listConfigs())
			end
		end,
	})

	local savedConfigs = listConfigs()
	local cfgDrop = configBox:AddDropdown({
		Name    = "Saved Configs",
		Options = savedConfigs,
	})

	configBox:AddButton({
		Name = "Load Config",
		Callback = function()
			local name = cfgDrop.Value
			if not name then return end
			local data = loadConfig(name)
			if not data then return end
			for flag, val in pairs(data) do
				if self._flags[flag] then
					self._flags[flag]:Set(val)
				end
			end
		end,
	})

	configBox:AddButton({
		Name = "Set Autoload",
		Callback = function()
			local name = cfgDrop.Value
			if not name then return end
			setAutoload(name)
		end,
	})

	configBox:AddButton({
		Name = "Remove Autoload",
		Callback = function() setAutoload(nil) end,
	})

	configBox:AddButton({
		Name = "Delete Config",
		Callback = function()
			local name = cfgDrop.Value
			if not name then return end
			deleteConfig(name)
			cfgDrop:Set(nil)
			cfgDrop:Refresh(listConfigs())
		end,
	})

	local al = getAutoload()
	if al then
		local data = loadConfig(al)
		if data then
			task.defer(function()
				for flag, val in pairs(data) do
					if self._flags[flag] then
						self._flags[flag]:Set(val)
					end
				end
			end)
		end
	end
end

function Gokai:Destroy()
	self._gui:Destroy()
end

return Gokai
