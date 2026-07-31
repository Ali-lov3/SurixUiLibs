local Gokai = {}
Gokai.__index = Gokai

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local HttpService        = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")

local LucideLoaded, LucideModule = pcall(function()
	return (loadstring(game:HttpGet("https://gitlab.com/upio/lucide-roblox-direct/-/raw/main/source.lua")))()
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
		Background=Color3.fromRGB(5,5,5), Surface=Color3.fromRGB(13,13,13), SurfaceMid=Color3.fromRGB(18,18,18),
		SurfaceHigh=Color3.fromRGB(25,25,25), Border=Color3.fromRGB(38,38,38), BorderHigh=Color3.fromRGB(55,55,55),
		TextPrimary=Color3.fromRGB(235,235,235), TextSub=Color3.fromRGB(145,145,145), TextMuted=Color3.fromRGB(75,75,75),
	},
	Slate = {
		Background=Color3.fromRGB(8,10,14), Surface=Color3.fromRGB(13,16,22), SurfaceMid=Color3.fromRGB(19,23,32),
		SurfaceHigh=Color3.fromRGB(27,32,44), Border=Color3.fromRGB(42,48,64), BorderHigh=Color3.fromRGB(58,67,86),
		TextPrimary=Color3.fromRGB(224,230,242), TextSub=Color3.fromRGB(138,148,168), TextMuted=Color3.fromRGB(70,80,100),
	},
	Carbon = {
		Background=Color3.fromRGB(10,8,7), Surface=Color3.fromRGB(16,14,12), SurfaceMid=Color3.fromRGB(22,19,17),
		SurfaceHigh=Color3.fromRGB(30,27,24), Border=Color3.fromRGB(46,41,36), BorderHigh=Color3.fromRGB(64,57,50),
		TextPrimary=Color3.fromRGB(238,232,225), TextSub=Color3.fromRGB(155,145,135), TextMuted=Color3.fromRGB(80,72,65),
	},
	Frost = {
		Background=Color3.fromRGB(6,9,13), Surface=Color3.fromRGB(10,15,21), SurfaceMid=Color3.fromRGB(15,22,31),
		SurfaceHigh=Color3.fromRGB(20,30,44), Border=Color3.fromRGB(34,50,68), BorderHigh=Color3.fromRGB(50,72,95),
		TextPrimary=Color3.fromRGB(218,234,248), TextSub=Color3.fromRGB(128,155,180), TextMuted=Color3.fromRGB(62,88,114),
	},
	Stone = {
		Background=Color3.fromRGB(9,9,9), Surface=Color3.fromRGB(15,15,14), SurfaceMid=Color3.fromRGB(21,21,20),
		SurfaceHigh=Color3.fromRGB(29,29,27), Border=Color3.fromRGB(44,44,42), BorderHigh=Color3.fromRGB(61,61,58),
		TextPrimary=Color3.fromRGB(230,228,223), TextSub=Color3.fromRGB(146,144,138), TextMuted=Color3.fromRGB(76,74,70),
	},
	Ember = {
		Background=Color3.fromRGB(10,6,5), Surface=Color3.fromRGB(16,11,9), SurfaceMid=Color3.fromRGB(22,15,13),
		SurfaceHigh=Color3.fromRGB(31,22,18), Border=Color3.fromRGB(50,34,28), BorderHigh=Color3.fromRGB(68,48,39),
		TextPrimary=Color3.fromRGB(240,228,220), TextSub=Color3.fromRGB(162,138,125), TextMuted=Color3.fromRGB(88,68,58),
	},
}

local CONFIG_FOLDER = "GokaiUI/configs"
local AUTOLOAD_FILE = "GokaiUI/autoload.txt"

local function hasFS()
	return isfolder and writefile and readfile and listfiles and makefolder
end

local function ensureFolder()
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
		if name then writefile(AUTOLOAD_FILE, name)
		else if isfile(AUTOLOAD_FILE) then delfile(AUTOLOAD_FILE) end end
	end)
end

local function getAutoload()
	if not hasFS() then return nil end
	local ok, v = pcall(readfile, AUTOLOAD_FILE)
	return ok and v or nil
end

local function Tween(obj, props, t, style)
	TweenService:Create(obj, TweenInfo.new(t or 0.16, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function New(class, props)
	local i = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" and k ~= "Children" then i[k] = v end
	end
	if props.Children then
		for _, c in ipairs(props.Children) do c.Parent = i end
	end
	if props.Parent then i.Parent = props.Parent end
	return i
end

local function Corner(parent, r)
	return New("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = parent })
end

local function Border(parent, color, thickness)
	return New("UIStroke", {
		Color = color or THEME.Border,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function GradientColor(parent, stops, rotation)
	local kp = {}
	for _, s in ipairs(stops) do
		table.insert(kp, ColorSequenceKeypoint.new(s[1], s[2]))
	end
	return New("UIGradient", {
		Color = ColorSequence.new(kp),
		Rotation = rotation or 90,
		Parent = parent,
	})
end

local function GradientTransparency(parent, stops, rotation)
	local kp = {}
	for _, s in ipairs(stops) do
		table.insert(kp, NumberSequenceKeypoint.new(s[1], s[2]))
	end
	return New("UIGradient", {
		Transparency = NumberSequence.new(kp),
		Rotation = rotation or 90,
		Parent = parent,
	})
end

local function GetIcon(name)
	if not LucideLoaded or not LucideModule or not name or name == "" then return nil end
	local ok, icon = pcall(LucideModule.GetAsset, name)
	if not ok or not icon then return nil end
	return icon
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
	local sx = (vp.X - 20) / 580
	local sy = (vp.Y - 60) / 450
	return math.max(math.min(sx, sy, 1.0), 0.52)
end

function Gokai.new(config)
	local self = setmetatable({}, Gokai)
	config = config or {}

	self.Title   = config.Title   or "Gokai"
	self.Footer  = config.Footer  or ""
	self.Logo    = config.Logo    or ""
	self.Tabs    = {}
	self.Active  = nil
	self.Open    = true
	self._values = {}

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
		Position         = UDim2.new(0.5, -W/2, 0.5, -H/2),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel  = 0,
		ClipsDescendants = false,
		Parent           = gui,
	})
	Corner(win, 10)
	Border(win, THEME.Border, 1)

	local winClip = New("Frame", {
		Size             = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent           = win,
	})
	Corner(winClip, 10)
	self._win     = win
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
	GradientColor(topBar, {
		{0, Color3.fromRGB(30, 30, 30)},
		{0.5, Color3.fromRGB(16, 16, 16)},
		{1, Color3.fromRGB(8, 8, 8)},
	}, 180)
	local shine = New("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = THEME.White,
		BorderSizePixel  = 0,
		Parent           = topBar,
	})
	GradientTransparency(shine, { {0, 1}, {0.15, 0.55}, {0.5, 0.55}, {0.85, 0.55}, {1, 1} }, 0)
	Draggable(topBar, win)

	if self.Logo ~= "" then
		New("ImageLabel", {
			Size             = UDim2.new(0, 18, 0, 18),
			Position         = UDim2.new(0, 12, 0.5, -9),
			BackgroundTransparency = 1,
			Image            = self.Logo,
			ScaleType        = Enum.ScaleType.Fit,
			Parent           = topBar,
		})
	end
	local logoOff = self.Logo ~= "" and 36 or 12
	New("TextLabel", {
		Size             = UDim2.new(1, -(logoOff + 80), 1, 0),
		Position         = UDim2.new(0, logoOff, 0, 0),
		BackgroundTransparency = 1,
		Text             = self.Title,
		Font             = Enum.Font.GothamBold,
		TextSize         = 13,
		TextColor3       = THEME.TextPrimary,
		TextXAlignment   = Enum.TextXAlignment.Left,
		Parent           = topBar,
	})

	local closeBtn = New("TextButton", {
		Name             = "Close",
		Size             = UDim2.new(0, 28, 0, 28),
		Position         = UDim2.new(1, -34, 0.5, -14),
		BackgroundColor3 = THEME.SurfaceHigh,
		Text             = "",
		BorderSizePixel  = 0,
		Parent           = topBar,
	})
	Corner(closeBtn, 6)
	Border(closeBtn, THEME.Border, 1)
	local closeIcon = Icon(closeBtn, "x", UDim2.new(0, 12, 0, 12), UDim2.new(0.5, -6, 0.5, -6), THEME.TextSub)
	if not closeIcon then
		New("TextLabel", {
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text             = "×",
			Font             = Enum.Font.GothamBold,
			TextSize         = 16,
			TextColor3       = THEME.TextSub,
			Parent           = closeBtn,
		})
	end

	local tabBar = New("Frame", {
		Name             = "TabBar",
		Size             = UDim2.new(1, -20, 0, 28),
		Position         = UDim2.new(0, 10, 0, 42),
		BackgroundTransparency = 1,
		Parent           = winClip,
	})
	New("UIListLayout", {
		FillDirection    = Enum.FillDirection.Horizontal,
		SortOrder        = Enum.SortOrder.LayoutOrder,
		Padding          = UDim.new(0, 3),
		Parent           = tabBar,
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
		Name             = "Content",
		Size             = UDim2.new(1, -16, 1, -98),
		Position         = UDim2.new(0, 8, 0, 75),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent           = winClip,
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
	GradientColor(footer, {
		{0, Color3.fromRGB(14, 14, 14)},
		{1, Color3.fromRGB(6, 6, 6)},
	}, 180)
	New("Frame", {
		Size             = UDim2.new(1, 0, 0, 8),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel  = 0,
		Parent           = footer,
	})
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
		Name             = "PopupLayer",
		Size             = UDim2.new(1, 0, 1, 0),
		Position         = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		ZIndex           = 200,
		Parent           = gui,
	})
	self._popupLayer = popupLayer

	local inputSink = New("TextButton", {
		Name             = "InputSink",
		Size             = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text             = "",
		BorderSizePixel  = 0,
		ZIndex           = 150,
		Visible          = false,
		Active           = true,
		Parent           = gui,
	})
	self._inputSink = inputSink

	local fading = false
	local function toggleWindow(value)
		if fading then return end
		if typeof(value) == "boolean" then self.Open = value
		else self.Open = not self.Open end

		fading = true
		if self.Open then
			winClip.Visible = true
			local tweens = {}
			for _, inst in ipairs(win:GetDescendants()) do
				if inst:IsA("GuiObject") then
					local t = TweenService:Create(inst, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0})
					pcall(function() t:Play() end)
				end
			end
			Tween(win, { Size = UDim2.new(0, W, 0, H) }, 0.22, Enum.EasingStyle.Quad)
			task.delay(0.23, function() fading = false end)
		else
			Tween(win, { Size = UDim2.new(0, W, 0, 0) }, 0.2, Enum.EasingStyle.Quad)
			task.delay(0.21, function()
				winClip.Visible = false
				fading = false
			end)
		end
	end
	self.Toggle = toggleWindow

	closeBtn.MouseButton1Click:Connect(function() toggleWindow(false) end)
	closeBtn.MouseEnter:Connect(function() Tween(closeBtn, { BackgroundColor3 = Color3.fromRGB(50, 30, 30) }, 0.12) end)
	closeBtn.MouseLeave:Connect(function() Tween(closeBtn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)

	UserInputService.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == Enum.KeyCode.RightShift or i.KeyCode == Enum.KeyCode.Insert then
			toggleWindow()
		end
	end)

	self:_buildSettingsTab()
	return self
end

function Gokai:AddTab(cfg)
	cfg = cfg or {}
	local self_win   = self._win
	local inputSink  = self._inputSink
	local popupLayer = self._popupLayer

	local tab = { Name = cfg.Name or "Tab", Icon = cfg.Icon or "", Groups = {} }

	local hasIcon = tab.Icon ~= ""
	local tw = #tab.Name * 7 + (hasIcon and 20 or 0) + 22

	local btn = New("TextButton", {
		Name             = tab.Name,
		Size             = UDim2.new(0, tw, 1, 0),
		BackgroundTransparency = 1,
		Text             = "",
		BorderSizePixel  = 0,
		LayoutOrder      = #self.Tabs + 1,
		Parent           = self._tabBar,
	})

	local iconW = 0
	if hasIcon then
		local ic = Icon(btn, tab.Icon, UDim2.new(0, 13, 0, 13), UDim2.new(0, 6, 0.5, -6.5), THEME.TextMuted)
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
		Name             = tab.Name,
		Size             = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible          = false,
		Parent           = self._content,
	})

	local leftCol = New("Frame", {
		Size             = UDim2.new(0.5, -4, 1, 0),
		BackgroundTransparency = 1,
		Parent           = page,
	})
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = leftCol })

	local rightCol = New("Frame", {
		Size             = UDim2.new(0.5, -4, 1, 0),
		Position         = UDim2.new(0.5, 4, 0, 0),
		BackgroundTransparency = 1,
		Parent           = page,
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
		local gb = { Name = gcfg.Name or "Group", Icon = gcfg.Icon or "", Side = gcfg.Side or "left" }
		local col = gb.Side == "right" and rightCol or leftCol

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
		GradientColor(box, {
			{0, Color3.fromRGB(16, 16, 16)},
			{1, Color3.fromRGB(8, 8, 8)},
		}, 180)

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
		GradientColor(hdr, {
			{0, Color3.fromRGB(28, 28, 28)},
			{0.6, Color3.fromRGB(18, 18, 18)},
			{1, Color3.fromRGB(10, 10, 10)},
		}, 180)
		local hdrShine = New("Frame", {
			Size             = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = THEME.White,
			BorderSizePixel  = 0,
			Parent           = hdr,
		})
		GradientTransparency(hdrShine, { {0, 1}, {0.2, 0.7}, {0.5, 0.65}, {0.8, 0.7}, {1, 1} }, 0)

		local iconOff = 0
		if gb.Icon ~= "" then
			local ic = Icon(hdr, gb.Icon, UDim2.new(0, 12, 0, 12), UDim2.new(0, 9, 0.5, -6), THEME.TextSub)
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
			Name             = "Body",
			Size             = UDim2.new(1, 0, 0, 0),
			Position         = UDim2.new(0, 0, 0, 28),
			BackgroundTransparency = 1,
			AutomaticSize    = Enum.AutomaticSize.Y,
			Parent           = box,
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

		local function rowOrd() return #body:GetChildren() end

		function gb:AddToggle(tc)
			tc = tc or {}
			local t = { Value = tc.Default or false }
			if tc.Flag then self._values = self._values or {}; self._values[tc.Flag] = t end

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

			local function vis(v, anim)
				if anim then
					Tween(track, { BackgroundColor3 = v and THEME.ToggleOn or THEME.ToggleOff }, 0.18)
					Tween(thumb, { Position = v and UDim2.new(0, 20, 0.5, -5.5) or UDim2.new(0, 3, 0.5, -5.5), BackgroundColor3 = v and THEME.White or THEME.TextMuted }, 0.18)
				else
					track.BackgroundColor3 = v and THEME.ToggleOn or THEME.ToggleOff
					thumb.Position = v and UDim2.new(0, 20, 0.5, -5.5) or UDim2.new(0, 3, 0.5, -5.5)
					thumb.BackgroundColor3 = v and THEME.White or THEME.TextMuted
				end
			end
			vis(t.Value, false)

			row.MouseButton1Click:Connect(function()
				t.Value = not t.Value
				vis(t.Value, true)
				if tc.Callback then tc.Callback(t.Value) end
			end)
			row.MouseEnter:Connect(function() row.BackgroundTransparency = 0; row.BackgroundColor3 = THEME.SurfaceHigh end)
			row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)

			function t:Set(v) self.Value = v; vis(v, true); if tc.Callback then tc.Callback(v) end end
			return t
		end

		function gb:AddCheckbox(cc)
			cc = cc or {}
			local c = { Value = cc.Default or false }

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

			local function vis(v, anim)
				mark.Visible = v
				if anim then Tween(box2, { BackgroundColor3 = v and THEME.White or THEME.ToggleOff }, 0.14)
				else box2.BackgroundColor3 = v and THEME.White or THEME.ToggleOff end
			end
			vis(c.Value, false)

			row.MouseButton1Click:Connect(function()
				c.Value = not c.Value; vis(c.Value, true)
				if cc.Callback then cc.Callback(c.Value) end
			end)
			row.MouseEnter:Connect(function() row.BackgroundTransparency = 0; row.BackgroundColor3 = THEME.SurfaceHigh end)
			row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)

			function c:Set(v) self.Value = v; vis(v, true); if cc.Callback then cc.Callback(v) end end
			return c
		end

		function gb:AddButton(bc)
			bc = bc or {}
			local b = {}

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
			GradientColor(btn2, {
				{0, Color3.fromRGB(24, 24, 24)},
				{0.5, Color3.fromRGB(15, 15, 15)},
				{1, Color3.fromRGB(8, 8, 8)},
			}, 180)

			local shine2 = New("Frame", {
				Size             = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = THEME.White,
				BackgroundTransparency = 0.65,
				BorderSizePixel  = 0,
				Parent           = btn2,
			})
			GradientTransparency(shine2, { {0, 1}, {0.2, 0}, {0.8, 0}, {1, 1} }, 0)

			New("TextLabel", {
				Size             = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text             = bc.Name or "Button",
				Font             = Enum.Font.GothamSemibold,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				Parent           = btn2,
			})

			btn2.MouseButton1Click:Connect(function()
				Tween(btn2, { BackgroundColor3 = THEME.SurfaceHigh }, 0.08)
				task.delay(0.12, function() Tween(btn2, { BackgroundColor3 = THEME.SurfaceMid }, 0.15) end)
				if bc.Callback then bc.Callback() end
			end)
			btn2.MouseEnter:Connect(function() Tween(btn2, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
			btn2.MouseLeave:Connect(function() Tween(btn2, { BackgroundColor3 = THEME.SurfaceMid }, 0.12) end)
			return b
		end

		function gb:AddInput(ic)
			ic = ic or {}
			local inp = { Value = ic.Default or "" }

			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, 44),
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
				Position         = UDim2.new(0, 0, 0, ic.Name and 16 or 0),
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
			wrap.Size = UDim2.new(1, 0, 0, ic.Name and 44 or 28)
			Corner(box3, 5)
			Border(box3, THEME.Border, 1)
			New("UIPadding", {
				PaddingLeft  = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				Parent       = box3,
			})
			GradientColor(box3, {
				{0, Color3.fromRGB(22, 22, 22)},
				{1, Color3.fromRGB(11, 11, 11)},
			}, 180)

			box3:GetPropertyChangedSignal("Text"):Connect(function()
				inp.Value = box3.Text
				if ic.Callback then ic.Callback(box3.Text) end
			end)

			box3.Focused:Connect(function() Tween(box3, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
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
			local s = { Value = sc.Default or sc.Min or 0 }
			local mn, mx = sc.Min or 0, sc.Max or 100

			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, 44),
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
				Size             = UDim2.new(1, 0, 0, 4),
				Position         = UDim2.new(0, 0, 0, 28),
				BackgroundColor3 = THEME.Border,
				BorderSizePixel  = 0,
				Parent           = wrap,
			})
			Corner(track, 2)

			local fill = New("Frame", {
				Size             = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = THEME.White,
				BorderSizePixel  = 0,
				ClipsDescendants = false,
				Parent           = track,
			})
			Corner(fill, 2)
			GradientColor(fill, {
				{0, Color3.fromRGB(255, 255, 255)},
				{1, Color3.fromRGB(160, 160, 160)},
			}, 0)

			local thumb = New("Frame", {
				Size             = UDim2.new(0, 12, 0, 12),
				Position         = UDim2.new(1, -6, 0.5, -6),
				BackgroundColor3 = THEME.White,
				BorderSizePixel  = 0,
				Parent           = fill,
			})
			Corner(thumb, 6)
			Border(thumb, THEME.BorderHigh, 1.5)

			local function setValue(v)
				v = math.clamp(v, mn, mx)
				if sc.Step then v = math.round(v / sc.Step) * sc.Step end
				s.Value = v
				local pct = (v - mn) / (mx - mn)
				Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.07)
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
				if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and drag then
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

		local function makePopup(btnRef, options, multi)
			local itemH = 26
			local popup = New("Frame", {
				Name             = "Popup",
				Size             = UDim2.new(0, 1, 0, 0),
				BackgroundColor3 = THEME.SurfaceMid,
				BorderSizePixel  = 0,
				ClipsDescendants = true,
				Visible          = false,
				ZIndex           = 60,
				Parent           = popupLayer,
			})
			Corner(popup, 6)
			Border(popup, THEME.BorderHigh, 1)
			GradientColor(popup, {
				{0, Color3.fromRGB(22, 22, 22)},
				{1, Color3.fromRGB(10, 10, 10)},
			}, 180)
			New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = popup })

			local function reposition()
				local abs    = btnRef.AbsolutePosition
				local sz     = btnRef.AbsoluteSize
				local layerX = popupLayer.AbsolutePosition.X
				local layerY = popupLayer.AbsolutePosition.Y
				popup.Position = UDim2.new(0, abs.X - layerX, 0, abs.Y - layerY + sz.Y + 2)
				popup.Size     = UDim2.new(0, sz.X, 0, 0)
			end

			local isOpen  = false
			local itemRefs = {}
			local selected = {}

			for i, opt in ipairs(options) do
				local item = New("TextButton", {
					Size             = UDim2.new(1, 0, 0, itemH),
					BackgroundTransparency = 1,
					Text             = "",
					BorderSizePixel  = 0,
					LayoutOrder      = i,
					ZIndex           = 61,
					Parent           = popup,
				})
				local check2
				if multi then
					check2 = New("Frame", {
						Size             = UDim2.new(0, 13, 0, 13),
						Position         = UDim2.new(0, 8, 0.5, -6.5),
						BackgroundColor3 = THEME.ToggleOff,
						BorderSizePixel  = 0,
						ZIndex           = 62,
						Parent           = item,
					})
					Corner(check2, 3)
					Border(check2, THEME.Border, 1)
					New("ImageLabel", {
						Size             = UDim2.new(0, 8, 0, 8),
						Position         = UDim2.new(0.5, -4, 0.5, -4),
						BackgroundTransparency = 1,
						Image            = "rbxassetid://7072706796",
						ImageColor3      = THEME.Black,
						ZIndex           = 63,
						Visible          = false,
						Parent           = check2,
					})
				end
				local txtOff = multi and 28 or 8
				New("TextLabel", {
					Size             = UDim2.new(1, -(txtOff + 6), 1, 0),
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
				item.MouseEnter:Connect(function() item.BackgroundTransparency = 0; item.BackgroundColor3 = THEME.SurfaceHigh end)
				item.MouseLeave:Connect(function() item.BackgroundTransparency = 1 end)
				itemRefs[i] = { frame = item, check = check2, val = opt }
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

			return { popup=popup, items=itemRefs, open=open, close=close, toggle=toggle, isOpen=function() return isOpen end, selected=selected }
		end

		local function makeDropBtn(parent, placeholderText, layoutOrd)
			local dBtn = New("TextButton", {
				Size             = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = THEME.SurfaceMid,
				Text             = "",
				BorderSizePixel  = 0,
				LayoutOrder      = layoutOrd,
				Parent           = parent,
			})
			Corner(dBtn, 5)
			Border(dBtn, THEME.Border, 1)
			GradientColor(dBtn, {
				{0, Color3.fromRGB(22, 22, 22)},
				{1, Color3.fromRGB(11, 11, 11)},
			}, 180)
			local vLbl = New("TextLabel", {
				Size             = UDim2.new(1, -28, 1, 0),
				Position         = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text             = placeholderText or "Select...",
				Font             = Enum.Font.Gotham,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				TextXAlignment   = Enum.TextXAlignment.Left,
				Parent           = dBtn,
			})
			local arrowFrame = New("Frame", {
				Size             = UDim2.new(0, 20, 0, 20),
				Position         = UDim2.new(1, -24, 0.5, -10),
				BackgroundTransparency = 1,
				Parent           = dBtn,
			})
			local arrowIc = Icon(arrowFrame, "chevron-down", UDim2.new(0, 12, 0, 12), UDim2.new(0.5, -6, 0.5, -6), THEME.TextSub)
			if not arrowIc then
				New("TextLabel", {
					Size             = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text             = "▾",
					Font             = Enum.Font.Gotham,
					TextSize         = 14,
					TextColor3       = THEME.TextSub,
					Parent           = arrowFrame,
				})
			end
			dBtn.MouseEnter:Connect(function() Tween(dBtn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
			dBtn.MouseLeave:Connect(function() Tween(dBtn, { BackgroundColor3 = THEME.SurfaceMid }, 0.12) end)
			return dBtn, vLbl
		end

		function gb:AddDropdown(dc)
			dc = dc or {}
			local d = { Value = dc.Default }

			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, dc.Name and 44 or 28),
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

			local dBtn, vLbl = makeDropBtn(wrap, d.Value or "Select...", 0)
			if dc.Name then dBtn.Position = UDim2.new(0, 0, 0, 16) end

			local opts   = dc.Options or {}
			local popup  = makePopup(dBtn, opts, false)

			for _, ref in ipairs(popup.items) do
				ref.frame.MouseButton1Click:Connect(function()
					d.Value = ref.val; vLbl.Text = tostring(ref.val)
					popup.close()
					if dc.Callback then dc.Callback(ref.val) end
				end)
			end
			dBtn.MouseButton1Click:Connect(function() popup.toggle() end)

			function d:Set(v) self.Value = v; vLbl.Text = tostring(v or "Select..."); if dc.Callback then dc.Callback(v) end end
			function d:Refresh(newOpts)
				opts = newOpts
				for _, c in ipairs(popup.popup:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				popup = makePopup(dBtn, newOpts, false)
			end
			return d
		end

		function gb:AddMultiDropdown(mc)
			mc = mc or {}
			local m = { Value = {} }
			local selected = {}

			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, mc.Name and 44 or 28),
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

			local dBtn, vLbl = makeDropBtn(wrap, "Select...", 0)
			if mc.Name then dBtn.Position = UDim2.new(0, 0, 0, 16) end
			vLbl.TextTruncate = Enum.TextTruncate.AtEnd

			local popup = makePopup(dBtn, mc.Options or {}, true)

			local function updateLabel()
				local keys = {}
				for k in pairs(selected) do table.insert(keys, k) end
				m.Value = keys
				vLbl.Text = #keys > 0 and table.concat(keys, ", ") or "Select..."
			end

			for _, ref in ipairs(popup.items) do
				ref.frame.MouseButton1Click:Connect(function()
					if selected[ref.val] then
						selected[ref.val] = nil
						ref.check.BackgroundColor3 = THEME.ToggleOff
						ref.check:FindFirstChildWhichIsA("ImageLabel").Visible = false
					else
						selected[ref.val] = true
						ref.check.BackgroundColor3 = THEME.White
						ref.check:FindFirstChildWhichIsA("ImageLabel").Visible = true
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

function Gokai:_applyTheme(name)
	local theme = THEMES[name]
	if not theme then return end
	for k, v in pairs(theme) do THEME[k] = v end
end

function Gokai:_buildSettingsTab()
	local stab = self:AddTab({ Name = "UI Settings", Icon = "settings" })
	stab._btn.LayoutOrder = 9999

	local themeBox  = stab:AddGroupbox({ Name = "Theme",  Icon = "palette", Side = "left"  })
	local configBox = stab:AddGroupbox({ Name = "Config", Icon = "save",    Side = "right" })

	local themeNames = {}
	for k in pairs(THEMES) do table.insert(themeNames, k) end
	table.sort(themeNames)

	themeBox:AddDropdown({
		Name    = "Select Theme",
		Options = themeNames,
		Default = "Midnight",
		Callback = function(v)
			self:_applyTheme(v)
		end,
	})

	themeBox:AddButton({
		Name     = "Reset to Midnight",
		Callback = function() self:_applyTheme("Midnight") end,
	})

	local configNameInput = configBox:AddInput({
		Name        = "Config Name",
		Placeholder = "Enter name...",
	})

	local savedConfigs   = listConfigs()
	local configDropdown = { _lbl = nil, _popup = nil, Value = nil }
	local autoloadName   = getAutoload()

	configBox:AddButton({
		Name = "Save Config",
		Callback = function()
			local name = configNameInput.Value
			if not name or name == "" then return end
			local data = {}
			for flag, obj in pairs(self._values or {}) do
				data[flag] = obj.Value
			end
			saveConfig(name, data)
			savedConfigs = listConfigs()
		end,
	})

	local cfgDrop = configBox:AddDropdown({
		Name    = "Saved Configs",
		Options = savedConfigs,
	})

	configBox:AddButton({
		Name = "Load",
		Callback = function()
			local name = cfgDrop.Value
			if not name then return end
			local data = loadConfig(name)
			if not data then return end
			for flag, val in pairs(data) do
				if self._values and self._values[flag] then
					self._values[flag]:Set(val)
				end
			end
		end,
	})

	configBox:AddButton({
		Name = "Set as Autoload",
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
			savedConfigs = listConfigs()
		end,
	})

	local al = getAutoload()
	if al then
		local data = loadConfig(al)
		if data then
			for flag, val in pairs(data) do
				if self._values and self._values[flag] then
					self._values[flag]:Set(val)
				end
			end
		end
	end
end

function Gokai:Destroy()
	self._gui:Destroy()
end

return Gokai
