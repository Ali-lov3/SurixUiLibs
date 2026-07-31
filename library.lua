local Gokai = {}
Gokai.__index = Gokai

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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
		Size             = size or UDim2.new(0, 14, 0, 14),
		Position         = pos or UDim2.new(0, 0, 0.5, -7),
		BackgroundTransparency = 1,
		Image            = icon.Url or icon.Id or "",
		ImageRectOffset  = icon.ImageRectOffset or Vector2.zero,
		ImageRectSize    = icon.ImageRectSize   or Vector2.zero,
		ImageColor3      = color or THEME.TextSub,
		ScaleType        = Enum.ScaleType.Crop,
		Parent           = parent,
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

	self.Title  = config.Title  or "Gokai"
	self.Footer = config.Footer or ""
	self.Logo   = config.Logo   or ""
	self.Tabs   = {}
	self.Active = nil
	self.Open   = true

	local gui = New("ScreenGui", {
		Name             = "GokaiUI",
		ResetOnSpawn     = false,
		ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset   = true,
	})
	pcall(function() gui.Parent = CoreGui end)
	if not gui.Parent then gui.Parent = game.Players.LocalPlayer.PlayerGui end
	self._gui = gui

	local scale = CalcScale()
	local uiScale = New("UIScale", { Scale = scale, Parent = gui })
	self._uiScale = uiScale

	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		uiScale.Scale = CalcScale()
	end)

	local W = 580
	local H = 450

	local win = New("Frame", {
		Name              = "Window",
		Size              = UDim2.new(0, W, 0, H),
		Position          = UDim2.new(0.5, -W/2, 0.5, -H/2),
		BackgroundColor3  = THEME.Background,
		BorderSizePixel   = 0,
		ClipsDescendants  = false,
		Parent            = gui,
	})
	Corner(win, 10)
	Border(win, THEME.Border, 1)

	local winClip = New("Frame", {
		Name             = "Clip",
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
		{0,   Color3.fromRGB(30, 30, 30)},
		{0.5, Color3.fromRGB(16, 16, 16)},
		{1,   Color3.fromRGB(8,  8,  8)},
	}, 180)

	local shine = New("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = THEME.White,
		BorderSizePixel  = 0,
		BackgroundTransparency = 0,
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
		Size             = UDim2.new(1, -(logoOff + 40), 1, 0),
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
		{0,   Color3.fromRGB(14, 14, 14)},
		{1,   Color3.fromRGB(6,  6,  6)},
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

	local toggleBtn = New("TextButton", {
		Name             = "Toggle",
		Size             = UDim2.new(0, 26, 0, 68),
		Position         = UDim2.new(0, -26, 0.5, -34),
		BackgroundColor3 = THEME.SurfaceMid,
		Text             = "",
		BorderSizePixel  = 0,
		Parent           = win,
	})
	Corner(toggleBtn, 7)
	Border(toggleBtn, THEME.Border, 1)
	GradientColor(toggleBtn, {
		{0,   Color3.fromRGB(26, 26, 26)},
		{1,   Color3.fromRGB(10, 10, 10)},
	}, 180)

	local function makeBar(y)
		local b = New("Frame", {
			Size             = UDim2.new(0, 12, 0, 1.5),
			Position         = UDim2.new(0.5, -6, 0, y),
			BackgroundColor3 = THEME.TextSub,
			BorderSizePixel  = 0,
			Parent           = toggleBtn,
		})
		Corner(b, 1)
		return b
	end
	local bars = { makeBar(22), makeBar(33), makeBar(44) }

	toggleBtn.MouseButton1Click:Connect(function()
		self.Open = not self.Open
		if self.Open then
			winClip.Visible = true
			Tween(win, { Size = UDim2.new(0, W, 0, H) }, 0.22)
			for _, b in ipairs(bars) do Tween(b, { BackgroundColor3 = THEME.TextSub }, 0.15) end
		else
			Tween(win, { Size = UDim2.new(0, 0, 0, H) }, 0.2)
			for _, b in ipairs(bars) do Tween(b, { BackgroundColor3 = THEME.TextMuted }, 0.15) end
			task.delay(0.21, function() if not self.Open then winClip.Visible = false end end)
		end
	end)
	toggleBtn.MouseEnter:Connect(function() Tween(toggleBtn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
	toggleBtn.MouseLeave:Connect(function() Tween(toggleBtn, { BackgroundColor3 = THEME.SurfaceMid  }, 0.12) end)

	self._toggleBtn = toggleBtn
	return self
end

function Gokai:AddTab(cfg)
	cfg = cfg or {}
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

	tab._btn  = btn
	tab._lbl  = lbl
	tab._bar  = bar
	tab._page = page
	tab._left = leftCol
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

	local popupLayer = self._popupLayer

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
			{0,   Color3.fromRGB(16, 16, 16)},
			{1,   Color3.fromRGB(8,  8,  8)},
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
			{0,    Color3.fromRGB(28, 28, 28)},
			{0.6,  Color3.fromRGB(18, 18, 18)},
			{1,    Color3.fromRGB(10, 10, 10)},
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
			row.MouseEnter:Connect(function()
				row.BackgroundTransparency = 0
				row.BackgroundColor3 = THEME.SurfaceHigh
			end)
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
				c.Value = not c.Value
				vis(c.Value, true)
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

			local btn = New("TextButton", {
				Size             = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = THEME.SurfaceMid,
				Text             = "",
				BorderSizePixel  = 0,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})
			Corner(btn, 5)
			Border(btn, THEME.Border, 1)
			GradientColor(btn, {
				{0,   Color3.fromRGB(24, 24, 24)},
				{0.5, Color3.fromRGB(15, 15, 15)},
				{1,   Color3.fromRGB(8,  8,  8)},
			}, 180)

			local shine2 = New("Frame", {
				Size             = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = THEME.White,
				BackgroundTransparency = 0.65,
				BorderSizePixel  = 0,
				Parent           = btn,
			})
			GradientTransparency(shine2, { {0, 1}, {0.2, 0}, {0.8, 0}, {1, 1} }, 0)

			New("TextLabel", {
				Size             = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text             = bc.Name or "Button",
				Font             = Enum.Font.GothamSemibold,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				Parent           = btn,
			})

			btn.MouseButton1Click:Connect(function()
				Tween(btn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.08)
				task.delay(0.12, function() Tween(btn, { BackgroundColor3 = THEME.SurfaceMid }, 0.15) end)
				if bc.Callback then bc.Callback() end
			end)
			btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
			btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = THEME.SurfaceMid  }, 0.12) end)
			return b
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
				{0,   Color3.fromRGB(255, 255, 255)},
				{1,   Color3.fromRGB(160, 160, 160)},
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

			local function set(v)
				v = math.clamp(v, mn, mx)
				if sc.Step then v = math.round(v / sc.Step) * sc.Step end
				s.Value = v
				local pct = (v - mn) / (mx - mn)
				Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.07)
				valLbl.Text = tostring(v)
				if sc.Callback then sc.Callback(v) end
			end
			set(s.Value)

			local drag = false
			thumb.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					local abs = track.AbsolutePosition
					local sz  = track.AbsoluteSize
					set(mn + (mx - mn) * math.clamp((i.Position.X - abs.X) / sz.X, 0, 1))
				end
			end)
			track.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					local abs = track.AbsolutePosition
					local sz  = track.AbsoluteSize
					set(mn + (mx - mn) * math.clamp((i.Position.X - abs.X) / sz.X, 0, 1))
				end
			end)

			function s:Set(v) set(v) end
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
				{0,   Color3.fromRGB(22, 22, 22)},
				{1,   Color3.fromRGB(10, 10, 10)},
			}, 180)

			New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = popup })

			local function reposition()
				local abs    = btnRef.AbsolutePosition
				local sz     = btnRef.AbsoluteSize
				local scale  = popupLayer.AbsoluteSize
				local layerX = popupLayer.AbsolutePosition.X
				local layerY = popupLayer.AbsolutePosition.Y
				popup.Position = UDim2.new(0, abs.X - layerX, 0, abs.Y - layerY + sz.Y + 2)
				popup.Size     = UDim2.new(0, sz.X, 0, 0)
			end

			local isOpen = false
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

				item.MouseEnter:Connect(function()
					item.BackgroundTransparency = 0
					item.BackgroundColor3 = THEME.SurfaceHigh
				end)
				item.MouseLeave:Connect(function() item.BackgroundTransparency = 1 end)

				itemRefs[i] = { frame = item, check = check2, val = opt }
			end

			local function open()
				isOpen = true
				reposition()
				popup.Visible = true
				Tween(popup, { Size = UDim2.new(0, btnRef.AbsoluteSize.X, 0, #options * itemH) }, 0.15)
			end
			local function close()
				isOpen = false
				Tween(popup, { Size = UDim2.new(0, btnRef.AbsoluteSize.X, 0, 0) }, 0.13)
				task.delay(0.14, function() if not isOpen then popup.Visible = false end end)
			end
			local function toggle()
				if isOpen then close() else open() end
			end

			return { popup = popup, items = itemRefs, open = open, close = close, toggle = toggle, isOpen = function() return isOpen end, selected = selected }
		end

		function gb:AddDropdown(dc)
			dc = dc or {}
			local d = { Value = dc.Default }

			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, 44),
				BackgroundTransparency = 1,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})

			New("TextLabel", {
				Size             = UDim2.new(1, 0, 0, 14),
				BackgroundTransparency = 1,
				Text             = dc.Name or "Dropdown",
				Font             = Enum.Font.Gotham,
				TextSize         = 11,
				TextColor3       = THEME.TextSub,
				TextXAlignment   = Enum.TextXAlignment.Left,
				Parent           = wrap,
			})

			local dropBtn = New("TextButton", {
				Size             = UDim2.new(1, 0, 0, 26),
				Position         = UDim2.new(0, 0, 0, 16),
				BackgroundColor3 = THEME.SurfaceMid,
				Text             = "",
				BorderSizePixel  = 0,
				Parent           = wrap,
			})
			Corner(dropBtn, 5)
			Border(dropBtn, THEME.Border, 1)
			GradientColor(dropBtn, {
				{0,   Color3.fromRGB(22, 22, 22)},
				{1,   Color3.fromRGB(11, 11, 11)},
			}, 180)

			local valLbl = New("TextLabel", {
				Size             = UDim2.new(1, -28, 1, 0),
				Position         = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text             = d.Value or "Select...",
				Font             = Enum.Font.Gotham,
				TextSize         = 12,
				TextColor3       = THEME.TextPrimary,
				TextXAlignment   = Enum.TextXAlignment.Left,
				Parent           = dropBtn,
			})

			local arrowFrame = New("Frame", {
				Size             = UDim2.new(0, 20, 0, 20),
				Position         = UDim2.new(1, -24, 0.5, -10),
				BackgroundTransparency = 1,
				Parent           = dropBtn,
			})
			local arrowIcon = Icon(arrowFrame, "chevron-down", UDim2.new(0, 12, 0, 12), UDim2.new(0.5, -6, 0.5, -6), THEME.TextSub)
			if not arrowIcon then
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

			local popup = makePopup(dropBtn, dc.Options or {}, false)

			for _, ref in ipairs(popup.items) do
				ref.frame.MouseButton1Click:Connect(function()
					d.Value = ref.val
					valLbl.Text = tostring(ref.val)
					popup.close()
					if dc.Callback then dc.Callback(ref.val) end
				end)
			end

			dropBtn.MouseButton1Click:Connect(function() popup.toggle() end)
			dropBtn.MouseEnter:Connect(function() Tween(dropBtn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
			dropBtn.MouseLeave:Connect(function() Tween(dropBtn, { BackgroundColor3 = THEME.SurfaceMid  }, 0.12) end)

			function d:Set(v) self.Value = v; valLbl.Text = tostring(v or "Select..."); if dc.Callback then dc.Callback(v) end end
			return d
		end

		function gb:AddMultiDropdown(mc)
			mc = mc or {}
			local m = { Value = {} }
			local selected = {}

			local wrap = New("Frame", {
				Size             = UDim2.new(1, 0, 0, 44),
				BackgroundTransparency = 1,
				LayoutOrder      = rowOrd(),
				Parent           = body,
			})

			New("TextLabel", {
				Size             = UDim2.new(1, 0, 0, 14),
				BackgroundTransparency = 1,
				Text             = mc.Name or "Multi Select",
				Font             = Enum.Font.Gotham,
				TextSize         = 11,
				TextColor3       = THEME.TextSub,
				TextXAlignment   = Enum.TextXAlignment.Left,
				Parent           = wrap,
			})

			local dropBtn = New("TextButton", {
				Size             = UDim2.new(1, 0, 0, 26),
				Position         = UDim2.new(0, 0, 0, 16),
				BackgroundColor3 = THEME.SurfaceMid,
				Text             = "",
				BorderSizePixel  = 0,
				Parent           = wrap,
			})
			Corner(dropBtn, 5)
			Border(dropBtn, THEME.Border, 1)
			GradientColor(dropBtn, {
				{0,   Color3.fromRGB(22, 22, 22)},
				{1,   Color3.fromRGB(11, 11, 11)},
			}, 180)

			local valLbl = New("TextLabel", {
				Size             = UDim2.new(1, -28, 1, 0),
				Position         = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text             = "Select...",
				Font             = Enum.Font.Gotham,
				TextSize         = 11,
				TextColor3       = THEME.TextPrimary,
				TextTruncate     = Enum.TextTruncate.AtEnd,
				TextXAlignment   = Enum.TextXAlignment.Left,
				Parent           = dropBtn,
			})

			local arrowFrame = New("Frame", {
				Size             = UDim2.new(0, 20, 0, 20),
				Position         = UDim2.new(1, -24, 0.5, -10),
				BackgroundTransparency = 1,
				Parent           = dropBtn,
			})
			local arrowIcon2 = Icon(arrowFrame, "chevron-down", UDim2.new(0, 12, 0, 12), UDim2.new(0.5, -6, 0.5, -6), THEME.TextSub)
			if not arrowIcon2 then
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

			local popup = makePopup(dropBtn, mc.Options or {}, true)

			local function updateLabel()
				local keys = {}
				for k in pairs(selected) do table.insert(keys, k) end
				m.Value = keys
				valLbl.Text = #keys > 0 and table.concat(keys, ", ") or "Select..."
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

			dropBtn.MouseButton1Click:Connect(function() popup.toggle() end)
			dropBtn.MouseEnter:Connect(function() Tween(dropBtn, { BackgroundColor3 = THEME.SurfaceHigh }, 0.12) end)
			dropBtn.MouseLeave:Connect(function() Tween(dropBtn, { BackgroundColor3 = THEME.SurfaceMid  }, 0.12) end)

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

function Gokai:Destroy()
	self._gui:Destroy()
end

return Gokai
