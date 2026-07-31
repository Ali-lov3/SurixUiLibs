local Gokai = {}
Gokai.__index = Gokai

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local THEME = {
	Background = Color3.fromRGB(12, 12, 12),
	Surface = Color3.fromRGB(20, 20, 20),
	SurfaceLight = Color3.fromRGB(28, 28, 28),
	Border = Color3.fromRGB(45, 45, 45),
	BorderLight = Color3.fromRGB(60, 60, 60),
	TextPrimary = Color3.fromRGB(240, 240, 240),
	TextSecondary = Color3.fromRGB(160, 160, 160),
	TextMuted = Color3.fromRGB(100, 100, 100),
	Accent = Color3.fromRGB(220, 220, 220),
	AccentDark = Color3.fromRGB(180, 180, 180),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	Toggle = Color3.fromRGB(200, 200, 200),
	ToggleOff = Color3.fromRGB(50, 50, 50),
}

local function Tween(obj, props, duration, style, direction)
	local info = TweenInfo.new(duration or 0.18, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
	TweenService:Create(obj, info, props):Play()
end

local function Create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, child in pairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

local function MakeDraggable(handle, frame)
	local dragging = false
	local dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local function Gradient(frame, c1, c2, rotation)
	local gradient = Create("UIGradient", {
		Color = ColorSequence.new(c1 or THEME.Surface, c2 or THEME.Background),
		Rotation = rotation or 90,
	})
	gradient.Parent = frame
	return gradient
end

local function RoundCorners(frame, radius)
	local corner = Create("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
	corner.Parent = frame
	return corner
end

local function Stroke(frame, color, thickness)
	local stroke = Create("UIStroke", {
		Color = color or THEME.Border,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	stroke.Parent = frame
	return stroke
end

local function MakeIcon(parent, iconId, size, pos, color)
	if not iconId or iconId == "" then return end
	local img = Create("ImageLabel", {
		Size = size or UDim2.new(0, 14, 0, 14),
		Position = pos or UDim2.new(0, 0, 0.5, -7),
		BackgroundTransparency = 1,
		Image = iconId,
		ImageColor3 = color or THEME.TextSecondary,
		ScaleType = Enum.ScaleType.Fit,
		Parent = parent,
	})
	return img
end

function Gokai.new(config)
	local self = setmetatable({}, Gokai)
	config = config or {}

	self.Title = config.Title or "Gokai"
	self.Footer = config.Footer or ""
	self.Logo = config.Logo or ""
	self.Tabs = {}
	self.ActiveTab = nil
	self.Open = true

	local screenGui = Create("ScreenGui", {
		Name = "GokaiUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})

	pcall(function() screenGui.Parent = CoreGui end)
	if not screenGui.Parent then screenGui.Parent = game.Players.LocalPlayer.PlayerGui end
	self._gui = screenGui

	local window = Create("Frame", {
		Name = "Window",
		Size = UDim2.new(0, 580, 0, 440),
		Position = UDim2.new(0.5, -290, 0.5, -220),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui,
	})
	RoundCorners(window, 8)
	Stroke(window, THEME.Border, 1)
	self._window = window

	local titleBar = Create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel = 0,
		Parent = window,
	})
	RoundCorners(titleBar, 8)
	Create("Frame", {
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 1, -8),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel = 0,
		Parent = titleBar,
	})
	Gradient(titleBar, THEME.SurfaceLight, THEME.Surface, 180)
	Stroke(titleBar, THEME.Border, 1)
	MakeDraggable(titleBar, window)

	if self.Logo ~= "" then
		MakeIcon(titleBar, self.Logo, UDim2.new(0, 18, 0, 18), UDim2.new(0, 10, 0.5, -9), THEME.TextPrimary)
	end

	Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.new(0, self.Logo ~= "" and 34 or 12, 0, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = THEME.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar,
	})

	local footerBar = Create("Frame", {
		Name = "Footer",
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel = 0,
		Parent = window,
	})
	Create("Frame", {
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel = 0,
		Parent = footerBar,
	})
	Gradient(footerBar, THEME.Surface, THEME.Background, 0)

	Create("TextLabel", {
		Name = "FooterText",
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = self.Footer,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = THEME.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = footerBar,
	})

	local versionLabel = Create("TextLabel", {
		Name = "Version",
		Size = UDim2.new(0, 100, 1, 0),
		Position = UDim2.new(1, -110, 0, 0),
		BackgroundTransparency = 1,
		Text = "Gokai UI",
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = THEME.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = footerBar,
	})

	local tabBar = Create("Frame", {
		Name = "TabBar",
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.new(0, 12, 0, 40),
		BackgroundTransparency = 1,
		Parent = window,
	})
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = tabBar,
	})
	self._tabBar = tabBar

	local tabDivider = Create("Frame", {
		Name = "TabDivider",
		Size = UDim2.new(1, -24, 0, 1),
		Position = UDim2.new(0, 12, 0, 71),
		BackgroundColor3 = THEME.Border,
		BorderSizePixel = 0,
		Parent = window,
	})

	local contentArea = Create("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -24, 1, -112),
		Position = UDim2.new(0, 12, 0, 76),
		BackgroundTransparency = 1,
		Parent = window,
	})
	self._contentArea = contentArea

	local toggleBtn = Create("TextButton", {
		Name = "ToggleButton",
		Size = UDim2.new(0, 28, 0, 72),
		Position = UDim2.new(0, -28, 0.5, -36),
		BackgroundColor3 = THEME.Surface,
		Text = "",
		BorderSizePixel = 0,
		Parent = window,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = toggleBtn })
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = toggleBtn })
	Stroke(toggleBtn, THEME.Border, 1)
	Gradient(toggleBtn, THEME.SurfaceLight, THEME.Surface, 90)

	local toggleIcon = Create("Frame", {
		Name = "Icon",
		Size = UDim2.new(0, 12, 0, 40),
		Position = UDim2.new(0.5, -6, 0.5, -20),
		BackgroundTransparency = 1,
		Parent = toggleBtn,
	})

	local function makeBar(yOff)
		return Create("Frame", {
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 0, yOff),
			BackgroundColor3 = THEME.TextSecondary,
			BorderSizePixel = 0,
			Parent = toggleIcon,
		})
	end
	local bars = { makeBar(0), makeBar(9), makeBar(18) }

	toggleBtn.MouseButton1Click:Connect(function()
		self.Open = not self.Open
		if self.Open then
			window.Visible = true
			Tween(window, { Size = UDim2.new(0, 580, 0, 440) }, 0.22)
			for _, b in ipairs(bars) do Tween(b, { BackgroundColor3 = THEME.TextSecondary }, 0.18) end
		else
			Tween(window, { Size = UDim2.new(0, 0, 0, 440) }, 0.22)
			game:GetService("RunService").Heartbeat:Wait()
			for _, b in ipairs(bars) do Tween(b, { BackgroundColor3 = THEME.TextMuted }, 0.18) end
		end
	end)

	toggleBtn.MouseEnter:Connect(function()
		Tween(toggleBtn, { BackgroundColor3 = THEME.SurfaceLight }, 0.12)
	end)
	toggleBtn.MouseLeave:Connect(function()
		Tween(toggleBtn, { BackgroundColor3 = THEME.Surface }, 0.12)
	end)

	self._toggleBtn = toggleBtn
	return self
end

function Gokai:AddTab(config)
	config = config or {}
	local tab = {}
	tab.Name = config.Name or "Tab"
	tab.Icon = config.Icon or ""
	tab.Groups = {}

	local tabWidth = #tab.Name * 7 + (tab.Icon ~= "" and 22 or 0) + 24

	local tabBtn = Create("TextButton", {
		Name = tab.Name,
		Size = UDim2.new(0, tabWidth, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		BorderSizePixel = 0,
		LayoutOrder = #self.Tabs + 1,
		Parent = self._tabBar,
	})

	local iconOffset = tab.Icon ~= "" and 18 or 0

	if tab.Icon ~= "" then
		MakeIcon(tabBtn, tab.Icon, UDim2.new(0, 14, 0, 14), UDim2.new(0, 8, 0.5, -7), THEME.TextSecondary)
	end

	local tabLabel = Create("TextLabel", {
		Size = UDim2.new(1, -(iconOffset + 8), 1, 0),
		Position = UDim2.new(0, iconOffset + (tab.Icon ~= "" and 10 or 8), 0, 0),
		BackgroundTransparency = 1,
		Text = tab.Name,
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = THEME.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tabBtn,
	})

	local indicator = Create("Frame", {
		Name = "Indicator",
		Size = UDim2.new(1, -8, 0, 2),
		Position = UDim2.new(0, 4, 1, -2),
		BackgroundColor3 = THEME.White,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Parent = tabBtn,
	})
	RoundCorners(indicator, 2)

	local tabContent = Create("Frame", {
		Name = tab.Name .. "Content",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self._contentArea,
	})

	local leftCol = Create("Frame", {
		Name = "Left",
		Size = UDim2.new(0.5, -4, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = tabContent,
	})
	local leftLayout = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = leftCol,
	})

	local rightCol = Create("Frame", {
		Name = "Right",
		Size = UDim2.new(0.5, -4, 1, 0),
		Position = UDim2.new(0.5, 4, 0, 0),
		BackgroundTransparency = 1,
		Parent = tabContent,
	})
	local rightLayout = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = rightCol,
	})

	tab._btn = tabBtn
	tab._label = tabLabel
	tab._indicator = indicator
	tab._content = tabContent
	tab._leftCol = leftCol
	tab._rightCol = rightCol

	local function activateTab()
		if self.ActiveTab then
			Tween(self.ActiveTab._label, { TextColor3 = THEME.TextMuted }, 0.15)
			Tween(self.ActiveTab._indicator, { BackgroundTransparency = 1 }, 0.15)
			self.ActiveTab._content.Visible = false
		end
		self.ActiveTab = tab
		Tween(tabLabel, { TextColor3 = THEME.TextPrimary }, 0.15)
		Tween(indicator, { BackgroundTransparency = 0 }, 0.15)
		tabContent.Visible = true
	end

	tabBtn.MouseButton1Click:Connect(activateTab)

	tabBtn.MouseEnter:Connect(function()
		if self.ActiveTab ~= tab then
			Tween(tabLabel, { TextColor3 = THEME.TextSecondary }, 0.12)
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if self.ActiveTab ~= tab then
			Tween(tabLabel, { TextColor3 = THEME.TextMuted }, 0.12)
		end
	end)

	table.insert(self.Tabs, tab)

	if #self.Tabs == 1 then
		activateTab()
	end

	function tab:AddGroupbox(gbConfig)
		gbConfig = gbConfig or {}
		local gb = {}
		gb.Name = gbConfig.Name or "Group"
		gb.Icon = gbConfig.Icon or ""
		gb.Side = gbConfig.Side or "left"

		local parentCol = gb.Side == "right" and rightCol or leftCol

		local box = Create("Frame", {
			Name = gb.Name,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = THEME.Surface,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = #tab.Groups + 1,
			Parent = parentCol,
		})
		RoundCorners(box, 6)
		Stroke(box, THEME.Border, 1)

		local header = Create("Frame", {
			Name = "Header",
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = THEME.SurfaceLight,
			BorderSizePixel = 0,
			Parent = box,
		})
		RoundCorners(header, 6)
		Create("Frame", {
			Size = UDim2.new(1, 0, 0, 6),
			Position = UDim2.new(0, 0, 1, -6),
			BackgroundColor3 = THEME.SurfaceLight,
			BorderSizePixel = 0,
			Parent = header,
		})
		Gradient(header, THEME.SurfaceLight, THEME.Surface, 180)

		local iconOffset = gb.Icon ~= "" and 20 or 0
		if gb.Icon ~= "" then
			MakeIcon(header, gb.Icon, UDim2.new(0, 12, 0, 12), UDim2.new(0, 10, 0.5, -6), THEME.TextSecondary)
		end

		Create("TextLabel", {
			Size = UDim2.new(1, -(iconOffset + 20), 1, 0),
			Position = UDim2.new(0, iconOffset + 10, 0, 0),
			BackgroundTransparency = 1,
			Text = gb.Name,
			Font = Enum.Font.GothamSemibold,
			TextSize = 11,
			TextColor3 = THEME.TextSecondary,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = header,
		})

		local content = Create("Frame", {
			Name = "Content",
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = box,
		})
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
			Parent = content,
		})
		Create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 8),
			Parent = content,
		})

		gb._box = box
		gb._content = content
		table.insert(tab.Groups, gb)

		function gb:AddToggle(tConfig)
			tConfig = tConfig or {}
			local toggle = {}
			toggle.Value = tConfig.Default or false

			local row = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Text = "",
				BorderSizePixel = 0,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})

			Create("TextLabel", {
				Size = UDim2.new(1, -50, 1, 0),
				BackgroundTransparency = 1,
				Text = tConfig.Name or "Toggle",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
			})

			local track = Create("Frame", {
				Size = UDim2.new(0, 36, 0, 18),
				Position = UDim2.new(1, -36, 0.5, -9),
				BackgroundColor3 = THEME.ToggleOff,
				BorderSizePixel = 0,
				Parent = row,
			})
			RoundCorners(track, 9)
			Stroke(track, THEME.Border, 1)

			local thumb = Create("Frame", {
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(0, 3, 0.5, -6),
				BackgroundColor3 = THEME.TextMuted,
				BorderSizePixel = 0,
				Parent = track,
			})
			RoundCorners(thumb, 6)

			local function updateVisual(val, animate)
				if animate then
					Tween(track, { BackgroundColor3 = val and THEME.Toggle or THEME.ToggleOff }, 0.18)
					Tween(thumb, {
						Position = val and UDim2.new(0, 21, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
						BackgroundColor3 = val and THEME.White or THEME.TextMuted,
					}, 0.18)
				else
					track.BackgroundColor3 = val and THEME.Toggle or THEME.ToggleOff
					thumb.Position = val and UDim2.new(0, 21, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
					thumb.BackgroundColor3 = val and THEME.White or THEME.TextMuted
				end
			end

			updateVisual(toggle.Value, false)

			row.MouseButton1Click:Connect(function()
				toggle.Value = not toggle.Value
				updateVisual(toggle.Value, true)
				if tConfig.Callback then tConfig.Callback(toggle.Value) end
			end)

			row.MouseEnter:Connect(function()
				Tween(row, { BackgroundColor3 = THEME.SurfaceLight }, 0.12)
				row.BackgroundTransparency = 0
			end)
			row.MouseLeave:Connect(function()
				Tween(row, { BackgroundColor3 = THEME.Surface }, 0.12)
				row.BackgroundTransparency = 1
			end)

			function toggle:Set(val)
				self.Value = val
				updateVisual(val, true)
				if tConfig.Callback then tConfig.Callback(val) end
			end

			return toggle
		end

		function gb:AddCheckbox(cConfig)
			cConfig = cConfig or {}
			local checkbox = {}
			checkbox.Value = cConfig.Default or false

			local row = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Text = "",
				BorderSizePixel = 0,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})

			local box2 = Create("Frame", {
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 0, 0.5, -8),
				BackgroundColor3 = THEME.ToggleOff,
				BorderSizePixel = 0,
				Parent = row,
			})
			RoundCorners(box2, 3)
			Stroke(box2, THEME.Border, 1)

			local check = Create("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "✓",
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = THEME.Black,
				TextXAlignment = Enum.TextXAlignment.Center,
				Visible = false,
				Parent = box2,
			})

			Create("TextLabel", {
				Size = UDim2.new(1, -28, 1, 0),
				Position = UDim2.new(0, 24, 0, 0),
				BackgroundTransparency = 1,
				Text = cConfig.Name or "Checkbox",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
			})

			local function updateVisual(val, animate)
				check.Visible = val
				if animate then
					Tween(box2, { BackgroundColor3 = val and THEME.White or THEME.ToggleOff }, 0.15)
				else
					box2.BackgroundColor3 = val and THEME.White or THEME.ToggleOff
				end
			end

			updateVisual(checkbox.Value, false)

			row.MouseButton1Click:Connect(function()
				checkbox.Value = not checkbox.Value
				updateVisual(checkbox.Value, true)
				if cConfig.Callback then cConfig.Callback(checkbox.Value) end
			end)

			row.MouseEnter:Connect(function()
				row.BackgroundTransparency = 0
				Tween(row, { BackgroundColor3 = THEME.SurfaceLight }, 0.12)
			end)
			row.MouseLeave:Connect(function()
				row.BackgroundTransparency = 1
			end)

			function checkbox:Set(val)
				self.Value = val
				updateVisual(val, true)
				if cConfig.Callback then cConfig.Callback(val) end
			end

			return checkbox
		end

		function gb:AddButton(bConfig)
			bConfig = bConfig or {}
			local btn = {}

			local btnFrame = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = THEME.SurfaceLight,
				Text = "",
				BorderSizePixel = 0,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})
			RoundCorners(btnFrame, 5)
			Stroke(btnFrame, THEME.Border, 1)
			Gradient(btnFrame, THEME.SurfaceLight, THEME.Surface, 180)

			Create("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = bConfig.Name or "Button",
				Font = Enum.Font.GothamSemibold,
				TextSize = 12,
				TextColor3 = THEME.TextPrimary,
				Parent = btnFrame,
			})

			btnFrame.MouseButton1Click:Connect(function()
				Tween(btnFrame, { BackgroundColor3 = THEME.Border }, 0.1)
				task.delay(0.1, function()
					Tween(btnFrame, { BackgroundColor3 = THEME.SurfaceLight }, 0.15)
				end)
				if bConfig.Callback then bConfig.Callback() end
			end)

			btnFrame.MouseEnter:Connect(function()
				Tween(btnFrame, { BackgroundColor3 = Color3.fromRGB(38, 38, 38) }, 0.12)
			end)
			btnFrame.MouseLeave:Connect(function()
				Tween(btnFrame, { BackgroundColor3 = THEME.SurfaceLight }, 0.12)
			end)

			return btn
		end

		function gb:AddSlider(sConfig)
			sConfig = sConfig or {}
			local slider = {}
			slider.Value = sConfig.Default or sConfig.Min or 0

			local container = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 46),
				BackgroundTransparency = 1,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})

			local labelRow = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Parent = container,
			})

			Create("TextLabel", {
				Size = UDim2.new(0.7, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = sConfig.Name or "Slider",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = labelRow,
			})

			local valueLabel = Create("TextLabel", {
				Size = UDim2.new(0.3, 0, 1, 0),
				Position = UDim2.new(0.7, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = tostring(slider.Value),
				Font = Enum.Font.GothamSemibold,
				TextSize = 12,
				TextColor3 = THEME.TextSecondary,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = labelRow,
			})

			local track = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 4),
				Position = UDim2.new(0, 0, 0, 28),
				BackgroundColor3 = THEME.Border,
				BorderSizePixel = 0,
				Parent = container,
			})
			RoundCorners(track, 2)

			local fill = Create("Frame", {
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = THEME.White,
				BorderSizePixel = 0,
				Parent = track,
			})
			RoundCorners(fill, 2)
			Gradient(fill, THEME.White, THEME.TextSecondary, 0)

			local thumb = Create("Frame", {
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(0, -6, 0.5, -6),
				BackgroundColor3 = THEME.White,
				BorderSizePixel = 0,
				Parent = fill,
			})
			RoundCorners(thumb, 6)
			Stroke(thumb, THEME.BorderLight, 1)

			local min = sConfig.Min or 0
			local max = sConfig.Max or 100

			local function updateSlider(val)
				val = math.clamp(val, min, max)
				if sConfig.Step then
					val = math.round(val / sConfig.Step) * sConfig.Step
				end
				slider.Value = val
				local pct = (val - min) / (max - min)
				Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.08)
				valueLabel.Text = tostring(val)
				if sConfig.Callback then sConfig.Callback(val) end
			end

			updateSlider(slider.Value)

			local dragging = false
			thumb.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local abs = track.AbsolutePosition
					local sz = track.AbsoluteSize
					local pct = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
					updateSlider(min + (max - min) * pct)
				end
			end)

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local abs = track.AbsolutePosition
					local sz = track.AbsoluteSize
					local pct = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
					updateSlider(min + (max - min) * pct)
				end
			end)

			function slider:Set(val)
				updateSlider(val)
			end

			return slider
		end

		function gb:AddDropdown(dConfig)
			dConfig = dConfig or {}
			local dropdown = {}
			dropdown.Value = dConfig.Default or nil
			local isOpen = false

			local container = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				LayoutOrder = #content:GetChildren(),
				ClipsDescendants = false,
				Parent = content,
			})

			Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = dConfig.Name or "Dropdown",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.TextSecondary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})

			local btnFrame = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 28),
				Position = UDim2.new(0, 0, 0, 16),
				BackgroundColor3 = THEME.SurfaceLight,
				Text = "",
				BorderSizePixel = 0,
				Parent = container,
			})
			RoundCorners(btnFrame, 5)
			Stroke(btnFrame, THEME.Border, 1)
			container.Size = UDim2.new(1, 0, 0, 46)

			local valueLabel = Create("TextLabel", {
				Size = UDim2.new(1, -28, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text = dropdown.Value or "Select...",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = btnFrame,
			})

			local arrow = Create("TextLabel", {
				Size = UDim2.new(0, 20, 1, 0),
				Position = UDim2.new(1, -24, 0, 0),
				BackgroundTransparency = 1,
				Text = "▾",
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = THEME.TextMuted,
				Parent = btnFrame,
			})

			local listFrame = Create("Frame", {
				Name = "List",
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 2),
				BackgroundColor3 = THEME.Surface,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				ZIndex = 10,
				Visible = false,
				Parent = btnFrame,
			})
			RoundCorners(listFrame, 5)
			Stroke(listFrame, THEME.Border, 1)

			local listLayout = Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = listFrame,
			})

			local options = dConfig.Options or {}
			local itemHeight = 28

			local function closeDropdown()
				isOpen = false
				Tween(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
				task.delay(0.15, function() listFrame.Visible = false end)
				Tween(arrow, { TextColor3 = THEME.TextMuted }, 0.15)
			end

			local function openDropdown()
				isOpen = true
				listFrame.Visible = true
				Tween(listFrame, { Size = UDim2.new(1, 0, 0, #options * itemHeight) }, 0.15)
				Tween(arrow, { TextColor3 = THEME.TextPrimary }, 0.15)
			end

			for i, opt in ipairs(options) do
				local item = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, itemHeight),
					BackgroundTransparency = 1,
					Text = "",
					BorderSizePixel = 0,
					LayoutOrder = i,
					ZIndex = 11,
					Parent = listFrame,
				})

				Create("TextLabel", {
					Size = UDim2.new(1, -16, 1, 0),
					Position = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					Text = opt,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = THEME.TextPrimary,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
					Parent = item,
				})

				item.MouseEnter:Connect(function()
					item.BackgroundTransparency = 0
					item.BackgroundColor3 = THEME.SurfaceLight
				end)
				item.MouseLeave:Connect(function()
					item.BackgroundTransparency = 1
				end)

				item.MouseButton1Click:Connect(function()
					dropdown.Value = opt
					valueLabel.Text = opt
					closeDropdown()
					if dConfig.Callback then dConfig.Callback(opt) end
				end)
			end

			btnFrame.MouseButton1Click:Connect(function()
				if isOpen then closeDropdown() else openDropdown() end
			end)

			function dropdown:Set(val)
				self.Value = val
				valueLabel.Text = val or "Select..."
				if dConfig.Callback then dConfig.Callback(val) end
			end

			function dropdown:Refresh(newOptions)
				options = newOptions
				for _, c in ipairs(listFrame:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
			end

			return dropdown
		end

		function gb:AddMultiDropdown(mConfig)
			mConfig = mConfig or {}
			local mdrop = {}
			mdrop.Value = {}

			local container = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 46),
				BackgroundTransparency = 1,
				LayoutOrder = #content:GetChildren(),
				ClipsDescendants = false,
				Parent = content,
			})

			Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = mConfig.Name or "Multi Select",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.TextSecondary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})

			local btnFrame = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 28),
				Position = UDim2.new(0, 0, 0, 16),
				BackgroundColor3 = THEME.SurfaceLight,
				Text = "",
				BorderSizePixel = 0,
				Parent = container,
			})
			RoundCorners(btnFrame, 5)
			Stroke(btnFrame, THEME.Border, 1)

			local valueLabel = Create("TextLabel", {
				Size = UDim2.new(1, -28, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text = "Select...",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = THEME.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = btnFrame,
			})

			Create("TextLabel", {
				Size = UDim2.new(0, 20, 1, 0),
				Position = UDim2.new(1, -24, 0, 0),
				BackgroundTransparency = 1,
				Text = "▾",
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = THEME.TextMuted,
				Parent = btnFrame,
			})

			local listFrame = Create("Frame", {
				Name = "List",
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 2),
				BackgroundColor3 = THEME.Surface,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				ZIndex = 10,
				Visible = false,
				Parent = btnFrame,
			})
			RoundCorners(listFrame, 5)
			Stroke(listFrame, THEME.Border, 1)
			Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = listFrame })

			local options = mConfig.Options or {}
			local isOpen = false
			local itemHeight = 28
			local selected = {}

			local function updateLabel()
				local keys = {}
				for k in pairs(selected) do table.insert(keys, k) end
				valueLabel.Text = #keys > 0 and table.concat(keys, ", ") or "Select..."
				mdrop.Value = keys
			end

			for i, opt in ipairs(options) do
				local item = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, itemHeight),
					BackgroundTransparency = 1,
					Text = "",
					BorderSizePixel = 0,
					LayoutOrder = i,
					ZIndex = 11,
					Parent = listFrame,
				})

				local chkBox = Create("Frame", {
					Size = UDim2.new(0, 14, 0, 14),
					Position = UDim2.new(0, 8, 0.5, -7),
					BackgroundColor3 = THEME.ToggleOff,
					BorderSizePixel = 0,
					ZIndex = 11,
					Parent = item,
				})
				RoundCorners(chkBox, 3)
				Stroke(chkBox, THEME.Border, 1)

				local chkMark = Create("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "✓",
					Font = Enum.Font.GothamBold,
					TextSize = 10,
					TextColor3 = THEME.Black,
					Visible = false,
					ZIndex = 12,
					Parent = chkBox,
				})

				Create("TextLabel", {
					Size = UDim2.new(1, -34, 1, 0),
					Position = UDim2.new(0, 30, 0, 0),
					BackgroundTransparency = 1,
					Text = opt,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = THEME.TextPrimary,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
					Parent = item,
				})

				item.MouseEnter:Connect(function()
					item.BackgroundTransparency = 0
					item.BackgroundColor3 = THEME.SurfaceLight
				end)
				item.MouseLeave:Connect(function()
					item.BackgroundTransparency = 1
				end)

				item.MouseButton1Click:Connect(function()
					if selected[opt] then
						selected[opt] = nil
						chkMark.Visible = false
						Tween(chkBox, { BackgroundColor3 = THEME.ToggleOff }, 0.15)
					else
						selected[opt] = true
						chkMark.Visible = true
						Tween(chkBox, { BackgroundColor3 = THEME.White }, 0.15)
					end
					updateLabel()
					if mConfig.Callback then mConfig.Callback(mdrop.Value) end
				end)
			end

			btnFrame.MouseButton1Click:Connect(function()
				if isOpen then
					isOpen = false
					Tween(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
					task.delay(0.15, function() listFrame.Visible = false end)
				else
					isOpen = true
					listFrame.Visible = true
					Tween(listFrame, { Size = UDim2.new(1, 0, 0, #options * itemHeight) }, 0.15)
				end
			end)

			return mdrop
		end

		return gb
	end

	return tab
end

function Gokai:Destroy()
	self._gui:Destroy()
end

return Gokai
