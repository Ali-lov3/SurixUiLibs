local SurixUiLibs = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/IconFinder.lua"))()

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local COLORS = {
	BG = Color3.fromRGB(15, 15, 20),
	PANEL = Color3.fromRGB(22, 22, 30),
	SIDEBAR = Color3.fromRGB(18, 18, 24),
	HEADER = Color3.fromRGB(20, 20, 27),
	ACCENT = Color3.fromRGB(108, 92, 231),
	ACCENT_DARK = Color3.fromRGB(80, 67, 180),
	SURFACE = Color3.fromRGB(30, 30, 40),
	SURFACE2 = Color3.fromRGB(36, 36, 48),
	TEXT = Color3.fromRGB(230, 230, 240),
	TEXT_MUTED = Color3.fromRGB(120, 120, 150),
	TEXT_DIM = Color3.fromRGB(80, 80, 100),
	BORDER = Color3.fromRGB(40, 40, 55),
	TOGGLE_OFF = Color3.fromRGB(50, 50, 65),
	SLIDER_TRACK = Color3.fromRGB(40, 40, 55),
	RED = Color3.fromRGB(220, 80, 80),
	GREEN = Color3.fromRGB(80, 200, 120),
}

local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold
local FONT_SEMI = Enum.Font.GothamSemibold

local function create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			obj[k] = v
		end
	end
	if props.Parent then
		obj.Parent = props.Parent
	end
	return obj
end

local function tween(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

local function makeDraggable(frame, handle)
	local dragging = false
	local dragStart
	local startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local function addCorner(parent, radius)
	create("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function addPadding(parent, all, top, bottom, left, right)
	create("UIPadding", {
		PaddingTop = UDim.new(0, top or all or 0),
		PaddingBottom = UDim.new(0, bottom or all or 0),
		PaddingLeft = UDim.new(0, left or all or 0),
		PaddingRight = UDim.new(0, right or all or 0),
		Parent = parent
	})
end

local function addListLayout(parent, dir, spacing, halign, valign)
	create("UIListLayout", {
		FillDirection = dir or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, spacing or 0),
		HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
		Parent = parent
	})
end

local function addGridLayout(parent, size, spacing, fillDir)
	create("UIGridLayout", {
		CellSize = size,
		CellPadding = spacing or UDim2.new(0, 8, 0, 8),
		FillDirection = fillDir or Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent
	})
end

local function label(parent, text, size, color, font, xalign, name)
	return create("TextLabel", {
		Name = name or "Label",
		Text = text,
		TextSize = size or 13,
		TextColor3 = color or COLORS.TEXT,
		Font = font or FONT,
		BackgroundTransparency = 1,
		TextXAlignment = xalign or Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.XY,
		Parent = parent
	})
end

local screenGui = create("ScreenGui", {
	Name = "SurixUiLibs",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
	Parent = LocalPlayer.PlayerGui
})

local notifHolder = create("Frame", {
	Name = "Notifications",
	Size = UDim2.new(0, 280, 1, 0),
	Position = UDim2.new(1, -290, 0, 10),
	BackgroundTransparency = 1,
	Parent = screenGui
})
addListLayout(notifHolder, Enum.FillDirection.Vertical, 8)

function SurixUiLibs:Notify(opts)
	opts = opts or {}
	local title = opts.Title or "SurixUiLibs"
	local text = opts.Text or ""
	local duration = opts.Duration or 4
	local color = opts.Color or COLORS.ACCENT

	local notif = create("Frame", {
		Name = "Notif",
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = COLORS.PANEL,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = notifHolder
	})
	addCorner(notif, 8)

	create("Frame", {
		Name = "Border",
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = notif
	})

	local inner = create("Frame", {
		Name = "Inner",
		Size = UDim2.new(1, -14, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Parent = notif
	})
	addPadding(inner, 10)

	local titleLabel = label(inner, title, 13, COLORS.TEXT, FONT_BOLD)
	titleLabel.Size = UDim2.new(1, 0, 0, 16)
	titleLabel.AutomaticSize = Enum.AutomaticSize.None
	titleLabel.Position = UDim2.new(0, 0, 0, 8)

	local textLabel = label(inner, text, 12, COLORS.TEXT_MUTED)
	textLabel.Size = UDim2.new(1, 0, 0, 14)
	textLabel.AutomaticSize = Enum.AutomaticSize.None
	textLabel.Position = UDim2.new(0, 0, 0, 27)
	textLabel.TextWrapped = true

	local bar = create("Frame", {
		Name = "Bar",
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = notif
	})

	notif.BackgroundTransparency = 1
	tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { BackgroundTransparency = 0 })

	task.delay(duration, function()
		tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { BackgroundTransparency = 1 })
		task.wait(0.35)
		notif:Destroy()
	end)

	task.spawn(function()
		local elapsed = 0
		while elapsed < duration do
			elapsed = elapsed + RunService.Heartbeat:Wait()
			local pct = 1 - (elapsed / duration)
			if bar.Parent then
				bar.Size = UDim2.new(math.max(0, pct), 0, 0, 2)
			end
		end
	end)
end

function SurixUiLibs:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "SurixUiLibs"
	local size = opts.Size or (isMobile and UDim2.new(0, 540, 0, 380) or UDim2.new(0, 680, 0, 440))
	local pos = opts.Position or UDim2.new(0.5, -270, 0.5, -220)

	local win = {}
	local tabs = {}
	local activeTab = nil
	local activeTabBtn = nil

	local mainFrame = create("Frame", {
		Name = "MainWindow",
		Size = size,
		Position = pos,
		BackgroundColor3 = COLORS.BG,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui
	})
	addCorner(mainFrame, 10)

	create("UIStroke", {
		Color = COLORS.BORDER,
		Thickness = 1,
		Parent = mainFrame
	})

	local topBar = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = COLORS.HEADER,
		BorderSizePixel = 0,
		Parent = mainFrame
	})

	create("Frame", {
		Name = "Separator",
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = COLORS.BORDER,
		BorderSizePixel = 0,
		Parent = topBar
	})

	local logoBox = create("Frame", {
		Name = "Logo",
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 10, 0.5, -16),
		BackgroundColor3 = COLORS.ACCENT,
		BorderSizePixel = 0,
		Parent = topBar
	})
	addCorner(logoBox, 8)

	local logoText = create("TextLabel", {
		Name = "Letter",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = string.sub(title, 1, 1),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		Font = FONT_BOLD,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = logoBox
	})

	local titleLabel = create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(0, 120, 1, 0),
		Position = UDim2.new(0, 50, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = COLORS.TEXT,
		TextSize = 14,
		Font = FONT_BOLD,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar
	})

	local tabDropFrame = create("Frame", {
		Name = "TabDrop",
		Size = UDim2.new(0, 120, 0, 28),
		Position = UDim2.new(0, 180, 0.5, -14),
		BackgroundColor3 = COLORS.SURFACE,
		BorderSizePixel = 0,
		Parent = topBar
	})
	addCorner(tabDropFrame, 6)

	local tabDropLabel = create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = "Select Tab",
		TextColor3 = COLORS.TEXT_MUTED,
		TextSize = 12,
		Font = FONT,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tabDropFrame
	})

	local closeBtn = create("TextButton", {
		Name = "Close",
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -38, 0.5, -14),
		BackgroundColor3 = COLORS.SURFACE,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = COLORS.TEXT_MUTED,
		TextSize = 18,
		Font = FONT_BOLD,
		Parent = topBar
	})
	addCorner(closeBtn, 6)

	closeBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
		if mobileToggleBtn then
			mobileToggleBtn.Visible = true
		end
	end)

	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.RED, TextColor3 = Color3.fromRGB(255, 255, 255) })
	end)
	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.SURFACE, TextColor3 = COLORS.TEXT_MUTED })
	end)

	makeDraggable(mainFrame, topBar)

	local body = create("Frame", {
		Name = "Body",
		Size = UDim2.new(1, 0, 1, -42),
		Position = UDim2.new(0, 0, 0, 42),
		BackgroundTransparency = 1,
		Parent = mainFrame
	})

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 130, 1, 0),
		BackgroundColor3 = COLORS.SIDEBAR,
		BorderSizePixel = 0,
		Parent = body
	})

	create("Frame", {
		Name = "RightBorder",
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = COLORS.BORDER,
		BorderSizePixel = 0,
		Parent = sidebar
	})

	local searchFrame = create("Frame", {
		Name = "Search",
		Size = UDim2.new(1, -12, 0, 30),
		Position = UDim2.new(0, 6, 0, 8),
		BackgroundColor3 = COLORS.SURFACE,
		BorderSizePixel = 0,
		Parent = sidebar
	})
	addCorner(searchFrame, 6)

	local searchInput = create("TextBox", {
		Name = "Input",
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		PlaceholderText = "Search...",
		PlaceholderColor3 = COLORS.TEXT_DIM,
		Text = "",
		TextColor3 = COLORS.TEXT,
		TextSize = 12,
		Font = FONT,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = searchFrame
	})

	local tabList = create("ScrollingFrame", {
		Name = "TabList",
		Size = UDim2.new(1, 0, 1, -50),
		Position = UDim2.new(0, 0, 0, 46),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		Parent = sidebar
	})
	addListLayout(tabList, Enum.FillDirection.Vertical, 2)
	addPadding(tabList, nil, 4, 4, 6, 6)

	local content = create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -130, 1, 0),
		Position = UDim2.new(0, 130, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = body
	})

	local breadcrumb = create("TextLabel", {
		Name = "Breadcrumb",
		Size = UDim2.new(1, -10, 0, 24),
		Position = UDim2.new(0, 10, 0, 6),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = COLORS.TEXT_MUTED,
		TextSize = 11,
		Font = FONT,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = content
	})

	local contentScroll = create("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.new(1, 0, 1, -34),
		Position = UDim2.new(0, 0, 0, 34),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = COLORS.ACCENT,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = content
	})
	addPadding(contentScroll, nil, 6, 10, 8, 8)

	local columnsFrame = create("Frame", {
		Name = "Columns",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = contentScroll
	})
	addListLayout(columnsFrame, Enum.FillDirection.Horizontal, 8)

	local colLeft = create("Frame", {
		Name = "Left",
		Size = UDim2.new(0.5, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = columnsFrame
	})
	addListLayout(colLeft, Enum.FillDirection.Vertical, 8)

	local colRight = create("Frame", {
		Name = "Right",
		Size = UDim2.new(0.5, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = columnsFrame
	})
	addListLayout(colRight, Enum.FillDirection.Vertical, 8)

	local mobileToggleBtn
	if isMobile then
		mobileToggleBtn = create("TextButton", {
			Name = "MobileToggle",
			Size = UDim2.new(0, 44, 0, 44),
			Position = UDim2.new(0, 16, 1, -60),
			BackgroundColor3 = COLORS.ACCENT,
			BorderSizePixel = 0,
			Text = "☰",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 20,
			Font = FONT_BOLD,
			ZIndex = 100,
			Parent = screenGui
		})
		addCorner(mobileToggleBtn, 12)

		mobileToggleBtn.MouseButton1Click:Connect(function()
			mainFrame.Visible = not mainFrame.Visible
			mobileToggleBtn.Text = mainFrame.Visible and "×" or "☰"
		end)
	end

	local function setActiveTab(tab, btn)
		if activeTabBtn then
			tween(activeTabBtn, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1
			})
			local lbl = activeTabBtn:FindFirstChild("Label")
			if lbl then
				tween(lbl, TweenInfo.new(0.15), { TextColor3 = COLORS.TEXT_MUTED })
			end
			local dot = activeTabBtn:FindFirstChild("Dot")
			if dot then dot.Visible = false end
		end

		if activeTab then
			activeTab.Visible = false
		end

		activeTab = tab
		activeTabBtn = btn

		if btn then
			tween(btn, TweenInfo.new(0.15), {
				BackgroundColor3 = COLORS.SURFACE,
				BackgroundTransparency = 0
			})
			local lbl = btn:FindFirstChild("Label")
			if lbl then
				tween(lbl, TweenInfo.new(0.15), { TextColor3 = COLORS.TEXT })
			end
			local dot = btn:FindFirstChild("Dot")
			if dot then dot.Visible = true end
			tabDropLabel.Text = btn:FindFirstChild("Label") and btn.Label.Text or "Tab"
		end

		if tab then
			tab.Visible = true
		end
	end

	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(searchInput.Text)
		for _, tabData in pairs(tabs) do
			for _, item in pairs(tabData.Items or {}) do
				if item.Frame then
					item.Frame.Visible = query == "" or string.find(string.lower(item.Name or ""), query, 1, true)
				end
			end
		end
	end)

	function win:AddTab(opts)
		opts = opts or {}
		local tabName = opts.Title or "Tab"
		local icon = opts.Icon or "circle"

		local tabBtn = create("TextButton", {
			Name = tabName,
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = COLORS.SURFACE,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			Parent = tabList
		})
		addCorner(tabBtn, 6)

		local dot = create("Frame", {
			Name = "Dot",
			Size = UDim2.new(0, 3, 0, 16),
			Position = UDim2.new(0, 0, 0.5, -8),
			BackgroundColor3 = COLORS.ACCENT,
			BorderSizePixel = 0,
			Visible = false,
			Parent = tabBtn
		})
		addCorner(dot, 2)

		local iconLbl = create("TextLabel", {
			Name = "Icon",
			Size = UDim2.new(0, 20, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = "•",
			TextColor3 = COLORS.TEXT_MUTED,
			TextSize = 14,
			Font = FONT,
			Parent = tabBtn
		})

		local tabLabel = create("TextLabel", {
			Name = "Label",
			Size = UDim2.new(1, -36, 1, 0),
			Position = UDim2.new(0, 32, 0, 0),
			BackgroundTransparency = 1,
			Text = tabName,
			TextColor3 = COLORS.TEXT_MUTED,
			TextSize = 12,
			Font = FONT_SEMI,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = tabBtn
		})

		local tabContainer = create("Frame", {
			Name = tabName,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = contentScroll
		})

		local tab = {
			Frame = tabContainer,
			Items = {},
			Name = tabName,
		}

		local function makeColumn(side)
			local colFrame = create("Frame", {
				Name = side,
				Size = UDim2.new(0.5, -4, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Parent = tabContainer
			})

			if side == "Left" then
				colFrame.Position = UDim2.new(0, 0, 0, 0)
			else
				colFrame.Position = UDim2.new(0.5, 4, 0, 0)
			end

			addListLayout(colFrame, Enum.FillDirection.Vertical, 8)
			return colFrame
		end

		local leftCol = makeColumn("Left")
		local rightCol = makeColumn("Right")
		tab.LeftCol = leftCol
		tab.RightCol = rightCol

		tabBtn.MouseButton1Click:Connect(function()
			setActiveTab(tabContainer, tabBtn)
			breadcrumb.Text = title .. "  ›  " .. tabName
		end)

		tabBtn.MouseEnter:Connect(function()
			if activeTabBtn ~= tabBtn then
				tween(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.7, BackgroundColor3 = COLORS.SURFACE })
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if activeTabBtn ~= tabBtn then
				tween(tabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 1 })
			end
		end)

		if #tabs == 0 then
			setActiveTab(tabContainer, tabBtn)
			breadcrumb.Text = title .. "  ›  " .. tabName
		end

		table.insert(tabs, tab)

		function tab:AddSection(opts)
			opts = opts or {}
			local sectionName = opts.Title or "Section"
			local side = opts.Side or "Left"
			local col = side == "Right" and rightCol or leftCol

			local sectionFrame = create("Frame", {
				Name = sectionName,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = COLORS.PANEL,
				BorderSizePixel = 0,
				Parent = col
			})
			addCorner(sectionFrame, 8)
			addPadding(sectionFrame, nil, 6, 8, 0, 0)
			addListLayout(sectionFrame, Enum.FillDirection.Vertical, 4)

			create("UIStroke", {
				Color = COLORS.BORDER,
				Thickness = 1,
				Parent = sectionFrame
			})

			local sectionHeader = create("Frame", {
				Name = "Header",
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundTransparency = 1,
				Parent = sectionFrame
			})
			addPadding(sectionHeader, nil, 0, 0, 10, 8)

			local sectionTitle = create("TextLabel", {
				Name = "Title",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = string.upper(sectionName),
				TextColor3 = COLORS.TEXT_MUTED,
				TextSize = 10,
				Font = FONT_BOLD,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = sectionHeader
			})

			local section = { Frame = sectionFrame, Items = {} }

			local function itemPad(parent)
				addPadding(parent, nil, 0, 0, 10, 10)
			end

			function section:AddToggle(opts)
				opts = opts or {}
				local itemName = opts.Title or "Toggle"
				local default = opts.Default or false
				local callback = opts.Callback or function() end

				local state = default

				local row = create("Frame", {
					Name = itemName,
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundTransparency = 1,
					Parent = sectionFrame
				})
				addPadding(row, nil, 0, 0, 10, 8)

				local toggleBtn = create("TextButton", {
					Name = "Toggle",
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 0, 0.5, -9),
					BackgroundColor3 = state and COLORS.ACCENT or COLORS.TOGGLE_OFF,
					BorderSizePixel = 0,
					Text = "",
					Parent = row
				})
				addCorner(toggleBtn, 4)

				create("UIStroke", {
					Color = state and COLORS.ACCENT or COLORS.BORDER,
					Thickness = 1,
					Parent = toggleBtn
				})

				local checkMark = create("TextLabel", {
					Name = "Check",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "✓",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					Font = FONT_BOLD,
					Visible = state,
					Parent = toggleBtn
				})

				local nameLbl = create("TextLabel", {
					Name = "Name",
					Size = UDim2.new(1, -56, 1, 0),
					Position = UDim2.new(0, 26, 0, 0),
					BackgroundTransparency = 1,
					Text = itemName,
					TextColor3 = COLORS.TEXT,
					TextSize = 12,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row
				})

				local settingsBtn = create("TextButton", {
					Name = "Settings",
					Size = UDim2.new(0, 22, 0, 22),
					Position = UDim2.new(1, -22, 0.5, -11),
					BackgroundColor3 = COLORS.SURFACE,
					BorderSizePixel = 0,
					Text = "⚙",
					TextColor3 = COLORS.TEXT_DIM,
					TextSize = 12,
					Font = FONT,
					Parent = row
				})
				addCorner(settingsBtn, 5)

				local function updateToggle()
					tween(toggleBtn, TweenInfo.new(0.15), {
						BackgroundColor3 = state and COLORS.ACCENT or COLORS.TOGGLE_OFF
					})
					local stroke = toggleBtn:FindFirstChildOfClass("UIStroke")
					if stroke then
						tween(stroke, TweenInfo.new(0.15), {
							Color = state and COLORS.ACCENT or COLORS.BORDER
						})
					end
					checkMark.Visible = state
				end

				toggleBtn.MouseButton1Click:Connect(function()
					state = not state
					updateToggle()
					callback(state)
				end)
				nameLbl.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						state = not state
						updateToggle()
						callback(state)
					end
				end)

				local item = { Name = itemName, Frame = row }
				table.insert(section.Items, item)
				table.insert(tab.Items, item)

				function item:Set(val)
					state = val
					updateToggle()
					callback(state)
				end

				function item:Get()
					return state
				end

				return item
			end

			function section:AddSlider(opts)
				opts = opts or {}
				local itemName = opts.Title or "Slider"
				local min = opts.Min or 0
				local max = opts.Max or 100
				local default = opts.Default or min
				local suffix = opts.Suffix or ""
				local callback = opts.Callback or function() end

				local value = math.clamp(default, min, max)
				local dragging = false

				local row = create("Frame", {
					Name = itemName,
					Size = UDim2.new(1, 0, 0, 44),
					BackgroundTransparency = 1,
					Parent = sectionFrame
				})
				addPadding(row, nil, 0, 0, 10, 10)

				local topRow = create("Frame", {
					Name = "TopRow",
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					Parent = row
				})

				local nameLbl = create("TextLabel", {
					Name = "Name",
					Size = UDim2.new(0.7, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = itemName,
					TextColor3 = COLORS.TEXT,
					TextSize = 12,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = topRow
				})

				local valLbl = create("TextLabel", {
					Name = "Value",
					Size = UDim2.new(0.3, 0, 1, 0),
					Position = UDim2.new(0.7, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = tostring(value) .. suffix,
					TextColor3 = COLORS.TEXT_MUTED,
					TextSize = 11,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = topRow
				})

				local track = create("Frame", {
					Name = "Track",
					Size = UDim2.new(1, 0, 0, 5),
					Position = UDim2.new(0, 0, 0, 26),
					BackgroundColor3 = COLORS.SLIDER_TRACK,
					BorderSizePixel = 0,
					Parent = row
				})
				addCorner(track, 3)

				local fill = create("Frame", {
					Name = "Fill",
					Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
					BackgroundColor3 = COLORS.ACCENT,
					BorderSizePixel = 0,
					Parent = track
				})
				addCorner(fill, 3)

				local handle = create("TextButton", {
					Name = "Handle",
					Size = UDim2.new(1, 0, 0, 16),
					Position = UDim2.new(0, 0, 0, -5),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 5,
					Parent = track
				})

				local function updateSlider(x)
					local trackPos = track.AbsolutePosition.X
					local trackWidth = track.AbsoluteSize.X
					local pct = math.clamp((x - trackPos) / trackWidth, 0, 1)
					value = math.floor(pct * (max - min) + min)
					fill.Size = UDim2.new(pct, 0, 1, 0)
					valLbl.Text = tostring(value) .. suffix
					callback(value)
				end

				handle.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						dragging = true
					end
				end)

				UserInputService.InputChanged:Connect(function(inp)
					if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
						updateSlider(inp.Position.X)
					end
				end)

				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)

				track.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						updateSlider(inp.Position.X)
					end
				end)

				local item = { Name = itemName, Frame = row }
				table.insert(section.Items, item)
				table.insert(tab.Items, item)

				function item:Set(val)
					value = math.clamp(val, min, max)
					local pct = (value - min) / (max - min)
					fill.Size = UDim2.new(pct, 0, 1, 0)
					valLbl.Text = tostring(value) .. suffix
					callback(value)
				end

				function item:Get()
					return value
				end

				return item
			end

			function section:AddDropdown(opts)
				opts = opts or {}
				local itemName = opts.Title or "Dropdown"
				local options = opts.Options or {}
				local default = opts.Default or (options[1] or "")
				local callback = opts.Callback or function() end

				local selected = default
				local open = false

				local container = create("Frame", {
					Name = itemName,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					ZIndex = 10,
					Parent = sectionFrame
				})
				addPadding(container, nil, 0, 0, 10, 10)

				local row = create("Frame", {
					Name = "Row",
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundTransparency = 1,
					Parent = container
				})

				local nameLbl = create("TextLabel", {
					Name = "Name",
					Size = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Text = itemName,
					TextColor3 = COLORS.TEXT,
					TextSize = 12,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row
				})

				local dropBtn = create("TextButton", {
					Name = "Btn",
					Size = UDim2.new(1, 0, 0, 26),
					Position = UDim2.new(0, 0, 0, 16),
					BackgroundColor3 = COLORS.SURFACE,
					BorderSizePixel = 0,
					Text = "",
					Parent = row
				})
				addCorner(dropBtn, 6)

				create("UIStroke", {
					Color = COLORS.BORDER,
					Thickness = 1,
					Parent = dropBtn
				})

				local selLabel = create("TextLabel", {
					Name = "Selected",
					Size = UDim2.new(1, -28, 1, 0),
					Position = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					Text = selected,
					TextColor3 = COLORS.TEXT,
					TextSize = 12,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = dropBtn
				})

				local arrow = create("TextLabel", {
					Name = "Arrow",
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -22, 0, 0),
					BackgroundTransparency = 1,
					Text = "▾",
					TextColor3 = COLORS.TEXT_MUTED,
					TextSize = 12,
					Font = FONT,
					Parent = dropBtn
				})

				local dropList = create("Frame", {
					Name = "List",
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 50),
					BackgroundColor3 = COLORS.SURFACE2,
					BorderSizePixel = 0,
					Visible = false,
					ZIndex = 20,
					Parent = container
				})
				addCorner(dropList, 6)
				addListLayout(dropList, Enum.FillDirection.Vertical, 0)
				create("UIStroke", { Color = COLORS.BORDER, Thickness = 1, Parent = dropList })

				local function buildOptions()
					for _, child in pairs(dropList:GetChildren()) do
						if not child:IsA("UIListLayout") and not child:IsA("UIStroke") then
							child:Destroy()
						end
					end

					for _, opt in ipairs(options) do
						local optBtn = create("TextButton", {
							Name = opt,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Text = opt,
							TextColor3 = opt == selected and COLORS.ACCENT or COLORS.TEXT,
							TextSize = 12,
							Font = FONT,
							ZIndex = 21,
							Parent = dropList
						})
						addPadding(optBtn, nil, 0, 0, 10, 0)

						optBtn.MouseEnter:Connect(function()
							tween(optBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.8, BackgroundColor3 = COLORS.SURFACE })
						end)
						optBtn.MouseLeave:Connect(function()
							tween(optBtn, TweenInfo.new(0.1), { BackgroundTransparency = 1 })
						end)
						optBtn.MouseButton1Click:Connect(function()
							selected = opt
							selLabel.Text = opt
							open = false
							dropList.Visible = false
							tween(arrow, TweenInfo.new(0.15), { Rotation = 0 })
							buildOptions()
							callback(selected)
						end)
					end

					dropList.Size = UDim2.new(1, 0, 0, #options * 28)
				end

				buildOptions()

				dropBtn.MouseButton1Click:Connect(function()
					open = not open
					dropList.Visible = open
					tween(arrow, TweenInfo.new(0.15), { Rotation = open and 180 or 0 })
				end)

				local item = { Name = itemName, Frame = container }
				table.insert(section.Items, item)
				table.insert(tab.Items, item)

				function item:Set(val)
					selected = val
					selLabel.Text = val
					callback(selected)
				end

				function item:Get()
					return selected
				end

				function item:SetOptions(newOpts)
					options = newOpts
					buildOptions()
				end

				return item
			end

			function section:AddTextBox(opts)
				opts = opts or {}
				local itemName = opts.Title or "Input"
				local placeholder = opts.Placeholder or "Enter text..."
				local default = opts.Default or ""
				local callback = opts.Callback or function() end

				local row = create("Frame", {
					Name = itemName,
					Size = UDim2.new(1, 0, 0, 44),
					BackgroundTransparency = 1,
					Parent = sectionFrame
				})
				addPadding(row, nil, 0, 0, 10, 10)

				local nameLbl = create("TextLabel", {
					Name = "Name",
					Size = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Text = itemName,
					TextColor3 = COLORS.TEXT,
					TextSize = 12,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row
				})

				local inputFrame = create("Frame", {
					Name = "InputFrame",
					Size = UDim2.new(1, 0, 0, 26),
					Position = UDim2.new(0, 0, 0, 16),
					BackgroundColor3 = COLORS.SURFACE,
					BorderSizePixel = 0,
					Parent = row
				})
				addCorner(inputFrame, 6)
				create("UIStroke", { Color = COLORS.BORDER, Thickness = 1, Parent = inputFrame })

				local inputBox = create("TextBox", {
					Name = "Input",
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					Text = default,
					PlaceholderText = placeholder,
					PlaceholderColor3 = COLORS.TEXT_DIM,
					TextColor3 = COLORS.TEXT,
					TextSize = 12,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false,
					Parent = inputFrame
				})

				local stroke = inputFrame:FindFirstChildOfClass("UIStroke")
				inputBox.Focused:Connect(function()
					tween(stroke, TweenInfo.new(0.15), { Color = COLORS.ACCENT })
				end)
				inputBox.FocusLost:Connect(function(enter)
					tween(stroke, TweenInfo.new(0.15), { Color = COLORS.BORDER })
					if enter then callback(inputBox.Text) end
				end)

				local item = { Name = itemName, Frame = row }
				table.insert(section.Items, item)
				table.insert(tab.Items, item)

				function item:Get()
					return inputBox.Text
				end

				function item:Set(val)
					inputBox.Text = val
				end

				return item
			end

			function section:AddButton(opts)
				opts = opts or {}
				local itemName = opts.Title or "Button"
				local callback = opts.Callback or function() end

				local row = create("Frame", {
					Name = itemName,
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 1,
					Parent = sectionFrame
				})
				addPadding(row, nil, 0, 0, 10, 10)

				local btn = create("TextButton", {
					Name = "Btn",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = COLORS.SURFACE,
					BorderSizePixel = 0,
					Text = itemName,
					TextColor3 = COLORS.TEXT,
					TextSize = 12,
					Font = FONT_SEMI,
					Parent = row
				})
				addCorner(btn, 6)
				create("UIStroke", { Color = COLORS.BORDER, Thickness = 1, Parent = btn })

				btn.MouseEnter:Connect(function()
					tween(btn, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.ACCENT })
					local stroke = btn:FindFirstChildOfClass("UIStroke")
					if stroke then tween(stroke, TweenInfo.new(0.15), { Color = COLORS.ACCENT }) end
				end)
				btn.MouseLeave:Connect(function()
					tween(btn, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.SURFACE })
					local stroke = btn:FindFirstChildOfClass("UIStroke")
					if stroke then tween(stroke, TweenInfo.new(0.15), { Color = COLORS.BORDER }) end
				end)
				btn.MouseButton1Click:Connect(function()
					tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = COLORS.ACCENT_DARK })
					task.wait(0.1)
					tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = COLORS.ACCENT })
					callback()
				end)

				local item = { Name = itemName, Frame = row }
				table.insert(section.Items, item)
				table.insert(tab.Items, item)
				return item
			end

			function section:AddColorPicker(opts)
				opts = opts or {}
				local itemName = opts.Title or "Color"
				local default = opts.Default or Color3.fromRGB(108, 92, 231)
				local callback = opts.Callback or function() end

				local currentColor = default

				local row = create("Frame", {
					Name = itemName,
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundTransparency = 1,
					Parent = sectionFrame
				})
				addPadding(row, nil, 0, 0, 10, 10)

				local nameLbl = create("TextLabel", {
					Name = "Name",
					Size = UDim2.new(1, -36, 1, 0),
					BackgroundTransparency = 1,
					Text = itemName,
					TextColor3 = COLORS.TEXT,
					TextSize = 12,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row
				})

				local colorBtn = create("TextButton", {
					Name = "ColorBtn",
					Size = UDim2.new(0, 22, 0, 22),
					Position = UDim2.new(1, -22, 0.5, -11),
					BackgroundColor3 = currentColor,
					BorderSizePixel = 0,
					Text = "",
					Parent = row
				})
				addCorner(colorBtn, 11)
				create("UIStroke", { Color = COLORS.BORDER, Thickness = 1.5, Parent = colorBtn })

				colorBtn.MouseButton1Click:Connect(function()
					callback(currentColor)
				end)

				local item = { Name = itemName, Frame = row }
				table.insert(section.Items, item)
				table.insert(tab.Items, item)

				function item:Set(col)
					currentColor = col
					colorBtn.BackgroundColor3 = col
					callback(col)
				end

				function item:Get()
					return currentColor
				end

				return item
			end

			function section:AddKeybind(opts)
				opts = opts or {}
				local itemName = opts.Title or "Keybind"
				local default = opts.Default or Enum.KeyCode.Unknown
				local callback = opts.Callback or function() end

				local currentKey = default
				local listening = false

				local row = create("Frame", {
					Name = itemName,
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundTransparency = 1,
					Parent = sectionFrame
				})
				addPadding(row, nil, 0, 0, 10, 10)

				local nameLbl = create("TextLabel", {
					Name = "Name",
					Size = UDim2.new(1, -60, 1, 0),
					BackgroundTransparency = 1,
					Text = itemName,
					TextColor3 = COLORS.TEXT,
					TextSize = 12,
					Font = FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row
				})

				local keyBtn = create("TextButton", {
					Name = "KeyBtn",
					Size = UDim2.new(0, 52, 0, 22),
					Position = UDim2.new(1, -52, 0.5, -11),
					BackgroundColor3 = COLORS.SURFACE,
					BorderSizePixel = 0,
					Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name,
					TextColor3 = COLORS.TEXT_MUTED,
					TextSize = 11,
					Font = FONT,
					Parent = row
				})
				addCorner(keyBtn, 5)
				create("UIStroke", { Color = COLORS.BORDER, Thickness = 1, Parent = keyBtn })

				keyBtn.MouseButton1Click:Connect(function()
					listening = true
					keyBtn.Text = "..."
					keyBtn.TextColor3 = COLORS.ACCENT
				end)

				UserInputService.InputBegan:Connect(function(inp, processed)
					if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
						listening = false
						currentKey = inp.KeyCode
						keyBtn.Text = currentKey.Name
						keyBtn.TextColor3 = COLORS.TEXT_MUTED
						callback(currentKey)
					end
				end)

				local item = { Name = itemName, Frame = row }
				table.insert(section.Items, item)
				table.insert(tab.Items, item)

				function item:Get()
					return currentKey
				end

				function item:Set(key)
					currentKey = key
					keyBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
				end

				return item
			end

			return section
		end

		return tab
	end

	function win:CreateKeybindList(opts)
		opts = opts or {}
		local listTitle = opts.Title or "Keybind list"
		local size = opts.Size or UDim2.new(0, 220, 0, 180)
		local pos = opts.Position or UDim2.new(0, 40, 0.5, -90)

		local kbFrame = create("Frame", {
			Name = "KeybindList",
			Size = size,
			Position = pos,
			BackgroundColor3 = COLORS.PANEL,
			BorderSizePixel = 0,
			Parent = screenGui
		})
		addCorner(kbFrame, 8)
		create("UIStroke", { Color = COLORS.BORDER, Thickness = 1, Parent = kbFrame })

		local kbTop = create("Frame", {
			Name = "Top",
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = COLORS.HEADER,
			BorderSizePixel = 0,
			Parent = kbFrame
		})
		create("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
			BackgroundColor3 = COLORS.BORDER,
			BorderSizePixel = 0,
			Parent = kbTop
		})

		local kbIcon = create("Frame", {
			Name = "Icon",
			Size = UDim2.new(0, 14, 0, 14),
			Position = UDim2.new(0, 8, 0.5, -7),
			BackgroundColor3 = COLORS.ACCENT,
			BorderSizePixel = 0,
			Parent = kbTop
		})
		addCorner(kbIcon, 3)

		create("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, -60, 1, 0),
			Position = UDim2.new(0, 28, 0, 0),
			BackgroundTransparency = 1,
			Text = listTitle,
			TextColor3 = COLORS.TEXT,
			TextSize = 12,
			Font = FONT_SEMI,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = kbTop
		})

		local pinBtn = create("TextButton", {
			Name = "Pin",
			Size = UDim2.new(0, 22, 0, 22),
			Position = UDim2.new(1, -28, 0.5, -11),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "📌",
			TextSize = 12,
			Font = FONT,
			Parent = kbTop
		})

		makeDraggable(kbFrame, kbTop)

		local headerRow = create("Frame", {
			Name = "HeaderRow",
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			Parent = kbFrame
		})
		addPadding(headerRow, nil, 0, 0, 10, 10)

		local function colLabel(parent, text, xpct, w)
			create("TextLabel", {
				Name = text,
				Size = UDim2.new(w, 0, 1, 0),
				Position = UDim2.new(xpct, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = COLORS.TEXT_DIM,
				TextSize = 11,
				Font = FONT_BOLD,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = parent
			})
		end

		colLabel(headerRow, "Function", 0, 0.38)
		colLabel(headerRow, "Hotkey", 0.38, 0.25)
		colLabel(headerRow, "Status", 0.63, 0.37)

		create("Frame", {
			Name = "Divider",
			Size = UDim2.new(1, -16, 0, 1),
			Position = UDim2.new(0, 8, 0, 52),
			BackgroundColor3 = COLORS.BORDER,
			BorderSizePixel = 0,
			Parent = kbFrame
		})

		local kbScroll = create("ScrollingFrame", {
			Name = "Scroll",
			Size = UDim2.new(1, 0, 1, -54),
			Position = UDim2.new(0, 0, 0, 54),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = COLORS.ACCENT,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = kbFrame
		})
		addListLayout(kbScroll, Enum.FillDirection.Vertical, 0)

		local kbList = { Frame = kbFrame }

		function kbList:Add(name, hotkey, status)
			local row = create("TextButton", {
				Name = name,
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "",
				Parent = kbScroll
			})
			addPadding(row, nil, 0, 0, 10, 10)

			local fnLbl = create("TextLabel", {
				Size = UDim2.new(0.38, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = COLORS.TEXT,
				TextSize = 11,
				Font = FONT,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row
			})

			local hkLbl = create("TextLabel", {
				Size = UDim2.new(0.25, 0, 1, 0),
				Position = UDim2.new(0.38, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = hotkey or "None",
				TextColor3 = COLORS.TEXT_MUTED,
				TextSize = 11,
				Font = FONT,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row
			})

			local stLbl = create("TextLabel", {
				Size = UDim2.new(0.25, 0, 1, 0),
				Position = UDim2.new(0.63, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = status or "Toggle",
				TextColor3 = COLORS.TEXT_MUTED,
				TextSize = 11,
				Font = FONT,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row
			})

			local menuBtn = create("TextButton", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(1, -22, 0.5, -10),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "•••",
				TextColor3 = COLORS.TEXT_DIM,
				TextSize = 10,
				Font = FONT,
				Parent = row
			})

			row.MouseEnter:Connect(function()
				tween(row, TweenInfo.new(0.1), { BackgroundTransparency = 0.85, BackgroundColor3 = COLORS.SURFACE })
			end)
			row.MouseLeave:Connect(function()
				tween(row, TweenInfo.new(0.1), { BackgroundTransparency = 1 })
			end)

			return row
		end

		return kbList
	end

	return win
end

return SurixUiLibs
