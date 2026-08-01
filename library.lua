local Gokai = {}
Gokai.__index = Gokai

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Background = Color3.fromRGB(5, 5, 5),
    Surface = Color3.fromRGB(13, 13, 13),
    SurfaceMid = Color3.fromRGB(19, 19, 19),
    SurfaceHigh = Color3.fromRGB(28, 28, 28),
    Border = Color3.fromRGB(45, 45, 45),
    BorderHigh = Color3.fromRGB(70, 70, 70),
    Text = Color3.fromRGB(238, 238, 238),
    TextSub = Color3.fromRGB(155, 155, 155),
    TextMuted = Color3.fromRGB(92, 92, 92),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
}

local function New(className, properties)
    local instance = Instance.new(className)
    for key, value in pairs(properties or {}) do
        if key ~= "Parent" then
            instance[key] = value
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Corner(parent, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent,
    })
end

local function Stroke(parent, color, thickness)
    return New("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function Gradient(parent, stops, rotation)
    local points = {}
    for _, stop in ipairs(stops) do
        table.insert(points, ColorSequenceKeypoint.new(stop[1], stop[2]))
    end
    return New("UIGradient", {
        Color = ColorSequence.new(points),
        Rotation = rotation or 90,
        Parent = parent,
    })
end

local function FadeGradient(parent, stops, rotation)
    local points = {}
    for _, stop in ipairs(stops) do
        table.insert(points, NumberSequenceKeypoint.new(stop[1], stop[2]))
    end
    return New("UIGradient", {
        Transparency = NumberSequence.new(points),
        Rotation = rotation or 90,
        Parent = parent,
    })
end

local function Tween(instance, properties, duration)
    TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    ):Play()
end

local function HexFromColor(color)
    return string.format("#%02X%02X%02X", math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
end

local function ColorFromHex(value)
    local hex = tostring(value or ""):gsub("#", "")
    if not hex:match("^%x%x%x%x%x%x$") then
        return nil
    end
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    )
end

local function SetZIndex(root, value)
    root.ZIndex = value
    for _, child in ipairs(root:GetDescendants()) do
        if child:IsA("GuiObject") then
            child.ZIndex = value
        end
    end
end

local function ConnectDrag(target, callback)
    local dragging = false
    target.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            callback(input.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            callback(input.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function MakeLabel(parent, text, size, position, textSize, color)
    return New("TextLabel", {
        Size = size,
        Position = position or UDim2.new(),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = textSize or 12,
        TextColor3 = color or Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent,
    })
end

local function MakeField(parent, text, placeholder, position, size)
    local field = New("TextBox", {
        Size = size,
        Position = position,
        BackgroundColor3 = Theme.SurfaceMid,
        BorderSizePixel = 0,
        Text = text or "",
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = Theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = parent,
    })
    Corner(field, 5)
    Stroke(field, Theme.Border, 1)
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = field,
    })
    Gradient(field, {{0, Color3.fromRGB(24, 24, 24)}, {1, Color3.fromRGB(12, 12, 12)}}, 180)
    field.Focused:Connect(function()
        Tween(field, {BackgroundColor3 = Theme.SurfaceHigh}, 0.1)
    end)
    field.FocusLost:Connect(function()
        Tween(field, {BackgroundColor3 = Theme.SurfaceMid}, 0.1)
    end)
    return field
end

local function AddRowLayout(parent)
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = parent,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 8),
        Parent = parent,
    })
end

local function AddHeader(parent, name, icon)
    local header = New("Frame", {
        Size = UDim2.new(1, 0, 0, 29),
        BackgroundColor3 = Theme.SurfaceHigh,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(header, 8)
    local lower = New("Frame", {
        Size = UDim2.new(1, 0, 0, 9),
        Position = UDim2.new(0, 0, 1, -9),
        BackgroundColor3 = Theme.SurfaceHigh,
        BorderSizePixel = 0,
        Parent = header,
    })
    Gradient(header, {
        {0, Color3.fromRGB(34, 34, 34)},
        {0.55, Color3.fromRGB(21, 21, 21)},
        {1, Color3.fromRGB(12, 12, 12)},
    }, 180)
    Gradient(lower, {
        {0, Color3.fromRGB(21, 21, 21)},
        {1, Color3.fromRGB(12, 12, 12)},
    }, 180)
    local offset = 9
    if icon and icon ~= "" then
        offset = 29
        MakeLabel(header, "◆", UDim2.new(0, 14, 1, 0), UDim2.new(0, 10, 0, 0), 9, Theme.TextSub)
    end
    MakeLabel(header, name, UDim2.new(1, -offset - 8, 1, 0), UDim2.new(0, offset, 0, 0), 11, Theme.TextSub)
    return header
end

function Gokai.new(config)
    config = config or {}
    local self = setmetatable({}, Gokai)
    self.Title = config.Title or "Gokai"
    self.Footer = config.Footer or ""
    self.Tabs = {}
    self.Active = nil
    self.Open = true
    self._flags = {}

    local gui = New("ScreenGui", {
        Name = "GokaiUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function()
        gui.Parent = CoreGui
    end)
    if not gui.Parent then
        gui.Parent = game.Players.LocalPlayer.PlayerGui
    end
    self._gui = gui

    local window = New("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 580, 0, 450),
        Position = UDim2.new(0.5, -290, 0.5, -225),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = gui,
    })
    Corner(window, 10)
    Stroke(window, Theme.Border, 1)
    self._window = window

    local top = New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.SurfaceMid,
        BorderSizePixel = 0,
        Parent = window,
    })
    Corner(top, 10)
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.SurfaceMid,
        BorderSizePixel = 0,
        Parent = top,
    })
    Gradient(top, {{0, Color3.fromRGB(34, 34, 34)}, {0.5, Color3.fromRGB(18, 18, 18)}, {1, Color3.fromRGB(8, 8, 8)}}, 180)
    MakeLabel(top, self.Title, UDim2.new(1, -24, 1, 0), UDim2.new(0, 12, 0, 0), 13, Theme.Text)

    local tabBar = New("Frame", {
        Size = UDim2.new(1, -20, 0, 29),
        Position = UDim2.new(0, 10, 0, 42),
        BackgroundTransparency = 1,
        Parent = window,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        Parent = tabBar,
    })
    self._tabBar = tabBar
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 71),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = window,
    })

    self._content = New("Frame", {
        Size = UDim2.new(1, -16, 1, -98),
        Position = UDim2.new(0, 8, 0, 75),
        BackgroundTransparency = 1,
        Parent = window,
    })
    self._popupLayer = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 200,
        Parent = gui,
    })

    local footer = New("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = window,
    })
    Gradient(footer, {{0, Color3.fromRGB(17, 17, 17)}, {1, Color3.fromRGB(7, 7, 7)}}, 180)
    MakeLabel(footer, self.Footer, UDim2.new(0.5, -12, 1, 0), UDim2.new(0, 10, 0, 0), 10, Theme.TextMuted)
    local footerRight = MakeLabel(footer, "Gokai UI", UDim2.new(0.5, -10, 1, 0), UDim2.new(0.5, 0, 0, 0), 10, Theme.TextMuted)
    footerRight.TextXAlignment = Enum.TextXAlignment.Right

    local toggle = New("TextButton", {
        Size = UDim2.new(0, 30, 0, 54),
        Position = UDim2.new(0, 6, 0.5, -27),
        BackgroundColor3 = Theme.SurfaceMid,
        Text = "≡",
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextColor3 = Theme.TextSub,
        BorderSizePixel = 0,
        Parent = gui,
    })
    Corner(toggle, 8)
    Stroke(toggle, Theme.Border, 1)
    toggle.MouseButton1Click:Connect(function()
        self.Open = not self.Open
        window.Visible = self.Open
    end)

    return self
end

function Gokai:AddTab(config)
    config = config or {}
    local self = self
    local owner = self
    local tab = {
        Name = config.Name or "Tab",
        Groups = {},
    }
    local button = New("TextButton", {
        Size = UDim2.new(0, math.max(70, #tab.Name * 7 + 22), 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        BorderSizePixel = 0,
        LayoutOrder = #self.Tabs + 1,
        Parent = self._tabBar,
    })
    local label = MakeLabel(button, tab.Name, UDim2.new(1, -8, 1, 0), UDim2.new(0, 6, 0, 0), 12, Theme.TextMuted)
    local line = New("Frame", {
        Size = UDim2.new(1, -8, 0, 2),
        Position = UDim2.new(0, 4, 1, -2),
        BackgroundColor3 = Theme.White,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = button,
    })
    Corner(line, 2)
    local page = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self._content,
    })
    local left = New("Frame", {
        Size = UDim2.new(0.5, -4, 1, 0),
        BackgroundTransparency = 1,
        Parent = page,
    })
    local right = New("Frame", {
        Size = UDim2.new(0.5, -4, 1, 0),
        Position = UDim2.new(0.5, 4, 0, 0),
        BackgroundTransparency = 1,
        Parent = page,
    })
    New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = left})
    New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = right})
    tab._page = page
    tab._label = label
    tab._line = line
    tab._left = left
    tab._right = right

    local function activate()
        if self.Active then
            self.Active._page.Visible = false
            self.Active._label.TextColor3 = Theme.TextMuted
            self.Active._line.BackgroundTransparency = 1
        end
        self.Active = tab
        page.Visible = true
        label.TextColor3 = Theme.Text
        line.BackgroundTransparency = 0
    end
    button.MouseButton1Click:Connect(activate)
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        activate()
    end

    function tab:AddGroupbox(groupConfig)
        groupConfig = groupConfig or {}
        local group = {
            Name = groupConfig.Name or "Group",
            Side = groupConfig.Side or "left",
        }
        local column = group.Side == "right" and right or left
        local box = New("Frame", {
            Name = group.Name,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            LayoutOrder = #tab.Groups + 1,
            Parent = column,
        })
        Corner(box, 8)
        Stroke(box, Theme.Border, 1)
        Gradient(box, {{0, Color3.fromRGB(17, 17, 17)}, {1, Color3.fromRGB(8, 8, 8)}}, 180)
        AddHeader(box, group.Name, groupConfig.Icon)
        local body = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 29),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = box,
        })
        AddRowLayout(body)
        group._body = body
        group._box = box
        table.insert(tab.Groups, group)

        local function order()
            return #body:GetChildren()
        end

        function group:AddToggle(control)
            control = control or {}
            local item = {Value = control.Default or false}
            if control.Flag then owner._flags[control.Flag] = item end
            local row = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = "",
                BorderSizePixel = 0,
                LayoutOrder = order(),
                Parent = body,
            })
            Corner(row, 4)
            MakeLabel(row, control.Name or "Toggle", UDim2.new(1, -48, 1, 0), UDim2.new(0, 2, 0, 0), 12, Theme.Text)
            local track = New("Frame", {
                Size = UDim2.new(0, 34, 0, 17),
                Position = UDim2.new(1, -35, 0.5, -8.5),
                BackgroundColor3 = Theme.SurfaceHigh,
                BorderSizePixel = 0,
                Parent = row,
            })
            Corner(track, 9)
            local thumb = New("Frame", {
                Size = UDim2.new(0, 11, 0, 11),
                Position = UDim2.new(0, 3, 0.5, -5.5),
                BackgroundColor3 = Theme.TextMuted,
                BorderSizePixel = 0,
                Parent = track,
            })
            Corner(thumb, 6)
            local function render(value, animate)
                local props = {
                    Position = value and UDim2.new(0, 20, 0.5, -5.5) or UDim2.new(0, 3, 0.5, -5.5),
                    BackgroundColor3 = value and Theme.White or Theme.TextMuted,
                }
                if animate then
                    Tween(thumb, props, 0.15)
                    Tween(track, {BackgroundColor3 = value and Theme.BorderHigh or Theme.SurfaceHigh}, 0.15)
                else
                    thumb.Position = props.Position
                    thumb.BackgroundColor3 = props.BackgroundColor3
                    track.BackgroundColor3 = value and Theme.BorderHigh or Theme.SurfaceHigh
                end
            end
            render(item.Value, false)
            local function set(value)
                item.Value = not not value
                render(item.Value, true)
                if control.Callback then control.Callback(item.Value) end
            end
            row.MouseButton1Click:Connect(function() set(not item.Value) end)
            function item:Set(value) set(value) end
            return item
        end

        function group:AddCheckbox(control)
            control = control or {}
            local item = {Value = control.Default or false}
            if control.Flag then owner._flags[control.Flag] = item end
            local row = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = "",
                BorderSizePixel = 0,
                LayoutOrder = order(),
                Parent = body,
            })
            Corner(row, 4)
            local check = New("Frame", {
                Size = UDim2.new(0, 15, 0, 15),
                Position = UDim2.new(0, 2, 0.5, -7.5),
                BackgroundColor3 = Theme.SurfaceHigh,
                BorderSizePixel = 0,
                Parent = row,
            })
            Corner(check, 4)
            Stroke(check, Theme.Border, 1)
            local mark = MakeLabel(check, "✓", UDim2.new(1, 0, 1, 0), UDim2.new(), 11, Theme.Black)
            mark.TextXAlignment = Enum.TextXAlignment.Center
            mark.Visible = item.Value
            MakeLabel(row, control.Name or "Checkbox", UDim2.new(1, -26, 1, 0), UDim2.new(0, 23, 0, 0), 12, Theme.Text)
            local function set(value)
                item.Value = not not value
                mark.Visible = item.Value
                check.BackgroundColor3 = item.Value and Theme.White or Theme.SurfaceHigh
                if control.Callback then control.Callback(item.Value) end
            end
            row.MouseButton1Click:Connect(function() set(not item.Value) end)
            function item:Set(value) set(value) end
            return item
        end

        function group:AddButton(control)
            control = control or {}
            local button = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 29),
                BackgroundColor3 = Theme.SurfaceMid,
                Text = control.Name or "Button",
                Font = Enum.Font.GothamSemibold,
                TextSize = 12,
                TextColor3 = Theme.Text,
                BorderSizePixel = 0,
                LayoutOrder = order(),
                Parent = body,
            })
            Corner(button, 5)
            Stroke(button, Theme.Border, 1)
            Gradient(button, {{0, Color3.fromRGB(26, 26, 26)}, {1, Color3.fromRGB(11, 11, 11)}}, 180)
            button.MouseButton1Click:Connect(function()
                Tween(button, {BackgroundColor3 = Theme.SurfaceHigh}, 0.08)
                task.delay(0.1, function()
                    if button.Parent then Tween(button, {BackgroundColor3 = Theme.SurfaceMid}, 0.12) end
                end)
                if control.Callback then control.Callback() end
            end)
            return button
        end

        function group:AddInput(control)
            control = control or {}
            local item = {Value = control.Default or ""}
            local labelHeight = control.Name and 16 or 0
            local wrap = New("Frame", {
                Size = UDim2.new(1, 0, 0, labelHeight + 28),
                BackgroundTransparency = 1,
                LayoutOrder = order(),
                Parent = body,
            })
            if control.Name then
                MakeLabel(wrap, control.Name, UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 0, 0), 11, Theme.TextSub)
            end
            local field = MakeField(wrap, item.Value, control.Placeholder, UDim2.new(0, 0, 0, labelHeight), UDim2.new(1, 0, 0, 26))
            field:GetPropertyChangedSignal("Text"):Connect(function()
                item.Value = field.Text
                if control.Callback then control.Callback(item.Value) end
            end)
            field.FocusLost:Connect(function(enter)
                if enter and control.OnEnter then control.OnEnter(item.Value) end
            end)
            function item:Set(value)
                item.Value = tostring(value or "")
                field.Text = item.Value
            end
            function item:Get() return item.Value end
            return item
        end

        function group:AddSlider(control)
            control = control or {}
            local minimum = control.Min or 0
            local maximum = control.Max or 100
            local item = {Value = math.clamp(control.Default or minimum, minimum, maximum)}
            if control.Flag then owner._flags[control.Flag] = item end
            local wrap = New("Frame", {
                Size = UDim2.new(1, 0, 0, 47),
                BackgroundTransparency = 1,
                LayoutOrder = order(),
                Parent = body,
            })
            MakeLabel(wrap, control.Name or "Slider", UDim2.new(0.65, 0, 0, 18), UDim2.new(), 12, Theme.Text)
            local valueLabel = MakeLabel(wrap, tostring(item.Value), UDim2.new(0.35, 0, 0, 18), UDim2.new(0.65, 0, 0, 0), 12, Theme.TextSub)
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            local track = New("Frame", {
                Size = UDim2.new(1, 0, 0, 5),
                Position = UDim2.new(0, 0, 0, 31),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = wrap,
            })
            Corner(track, 3)
            local fill = New("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Theme.White,
                BorderSizePixel = 0,
                Parent = track,
            })
            Corner(fill, 3)
            local thumb = New("Frame", {
                Size = UDim2.new(0, 13, 0, 13),
                BackgroundColor3 = Theme.White,
                BorderSizePixel = 0,
                Parent = fill,
            })
            Corner(thumb, 7)
            Stroke(thumb, Theme.BorderHigh, 1)
            local function set(value)
                value = math.clamp(value, minimum, maximum)
                if control.Step then value = math.round(value / control.Step) * control.Step end
                item.Value = value
                local percent = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                thumb.Position = UDim2.new(1, -6, 0.5, -6.5)
                valueLabel.Text = tostring(value)
                if control.Callback then control.Callback(value) end
            end
            ConnectDrag(track, function(position)
                local x = math.clamp((position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                set(minimum + (maximum - minimum) * x)
            end)
            set(item.Value)
            function item:Set(value) set(value) end
            return item
        end

        function group:AddColorpicker(control)
            control = control or {}
            local item = {Value = control.Default or Color3.fromRGB(255, 0, 0)}
            if control.Flag then owner._flags[control.Flag] = item end
            local labelHeight = control.Name and 16 or 0
            local wrap = New("Frame", {
                Size = UDim2.new(1, 0, 0, labelHeight + 30),
                BackgroundTransparency = 1,
                LayoutOrder = order(),
                Parent = body,
            })
            if control.Name then
                MakeLabel(wrap, control.Name, UDim2.new(0.7, 0, 0, 14), UDim2.new(), 11, Theme.TextSub)
            end
            local preview = New("TextButton", {
                Size = UDim2.new(0, 40, 0, 24),
                Position = UDim2.new(1, -40, 0, labelHeight),
                BackgroundColor3 = item.Value,
                Text = "",
                BorderSizePixel = 0,
                LayoutOrder = order(),
                Parent = wrap,
            })
            Corner(preview, 6)
            Stroke(preview, Theme.BorderHigh, 1)
            local popup = New("Frame", {
                Size = UDim2.new(0, 286, 0, 238),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 210,
                Parent = owner._popupLayer,
            })
            Corner(popup, 9)
            Stroke(popup, Theme.BorderHigh, 1)
            Gradient(popup, {{0, Color3.fromRGB(25, 25, 25)}, {1, Color3.fromRGB(10, 10, 10)}}, 180)
            SetZIndex(popup, 211)
            local sv = New("Frame", {
                Size = UDim2.new(0, 194, 0, 176),
                Position = UDim2.new(0, 10, 0, 10),
                BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = popup,
            })
            Corner(sv, 9)
            local white = New("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme.White,
                BorderSizePixel = 0,
                Parent = sv,
            })
            Gradient(white, {{0, Color3.new(1, 1, 1)}, {1, Color3.new(1, 1, 1)}}, 0)
            FadeGradient(white, {{0, 0}, {1, 1}}, 0)
            local black = New("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme.Black,
                BorderSizePixel = 0,
                Parent = sv,
            })
            FadeGradient(black, {{0, 1}, {1, 0}}, 90)
            local svCursor = New("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = Theme.White,
                BorderSizePixel = 0,
                Parent = sv,
            })
            Corner(svCursor, 7)
            Stroke(svCursor, Theme.Black, 2)
            local hue = New("Frame", {
                Size = UDim2.new(0, 20, 0, 176),
                Position = UDim2.new(0, 214, 0, 10),
                BorderSizePixel = 0,
                Parent = popup,
            })
            Corner(hue, 10)
            Gradient(hue, {
                {0, Color3.fromRGB(255, 0, 0)},
                {0.17, Color3.fromRGB(255, 255, 0)},
                {0.33, Color3.fromRGB(0, 255, 0)},
                {0.5, Color3.fromRGB(0, 255, 255)},
                {0.67, Color3.fromRGB(0, 0, 255)},
                {0.83, Color3.fromRGB(255, 0, 255)},
                {1, Color3.fromRGB(255, 0, 0)},
            }, 90)
            local hueCursor = New("Frame", {
                Size = UDim2.new(0, 26, 0, 14),
                Position = UDim2.new(0.5, -13, 0, -7),
                BackgroundColor3 = Theme.White,
                BorderSizePixel = 0,
                Parent = hue,
            })
            Corner(hueCursor, 7)
            Stroke(hueCursor, Theme.Black, 2)
            local hex = MakeField(popup, "", "#RRGGBB", UDim2.new(0, 10, 0, 195), UDim2.new(0, 224, 0, 27))
            local hsvH, hsvS, hsvV = Color3.toHSV(item.Value)
            local open = false
            local function reposition()
                local absolute = preview.AbsolutePosition
                local layer = owner._popupLayer.AbsolutePosition
                local x = absolute.X - layer.X - popup.AbsoluteSize.X + preview.AbsoluteSize.X
                local y = absolute.Y - layer.Y + preview.AbsoluteSize.Y + 4
                popup.Position = UDim2.new(0, math.max(4, x), 0, y)
            end
            local function updateColor(emit)
                hsvH = math.clamp(hsvH, 0, 1)
                hsvS = math.clamp(hsvS, 0, 1)
                hsvV = math.clamp(hsvV, 0, 1)
                item.Value = Color3.fromHSV(hsvH, hsvS, hsvV)
                preview.BackgroundColor3 = item.Value
                sv.BackgroundColor3 = Color3.fromHSV(hsvH, 1, 1)
                svCursor.Position = UDim2.new(hsvS, -7, 1 - hsvV, -7)
                hueCursor.Position = UDim2.new(0.5, -13, hsvH, -7)
                hex.Text = HexFromColor(item.Value)
                if emit and control.Callback then control.Callback(item.Value) end
            end
            local function setColor(color, emit)
                if typeof(color) ~= "Color3" then
                    color = ColorFromHex(color)
                end
                if not color then return end
                hsvH, hsvS, hsvV = Color3.toHSV(color)
                updateColor(emit)
            end
            ConnectDrag(sv, function(position)
                hsvS = math.clamp((position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
                hsvV = 1 - math.clamp((position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
                updateColor(true)
            end)
            ConnectDrag(hue, function(position)
                hsvH = math.clamp((position.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
                updateColor(true)
            end)
            hex.FocusLost:Connect(function()
                local color = ColorFromHex(hex.Text)
                if color then
                    setColor(color, true)
                else
                    hex.Text = HexFromColor(item.Value)
                end
            end)
            preview.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    reposition()
                    popup.Visible = true
                    updateColor(false)
                else
                    popup.Visible = false
                end
            end)
            updateColor(false)
            function item:Set(value) setColor(value, true) end
            function item:Get() return item.Value end
            return item
        end

        function group:AddDropdown(control)
            control = control or {}
            local item = {Value = control.Default}
            local labelHeight = control.Name and 16 or 0
            local wrap = New("Frame", {
                Size = UDim2.new(1, 0, 0, labelHeight + 30),
                BackgroundTransparency = 1,
                LayoutOrder = order(),
                Parent = body,
            })
            if control.Name then
                MakeLabel(wrap, control.Name, UDim2.new(1, 0, 0, 14), UDim2.new(), 11, Theme.TextSub)
            end
            local button = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 27),
                Position = UDim2.new(0, 0, 0, labelHeight),
                BackgroundColor3 = Theme.SurfaceMid,
                Text = item.Value and tostring(item.Value) or "Select...",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                Parent = wrap,
            })
            Corner(button, 5)
            Stroke(button, Theme.Border, 1)
            New("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = button})
            local popup = New("Frame", {
                Size = UDim2.new(0, 1, 0, 0),
                BackgroundColor3 = Theme.SurfaceMid,
                BorderSizePixel = 0,
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 200,
                Parent = owner._popupLayer,
            })
            Corner(popup, 6)
            Stroke(popup, Theme.BorderHigh, 1)
            local options = control.Options or {}
            New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = popup})
            local function openPopup()
                local absolute = button.AbsolutePosition
                local layer = owner._popupLayer.AbsolutePosition
                popup.Position = UDim2.new(0, absolute.X - layer.X, 0, absolute.Y - layer.Y + button.AbsoluteSize.Y + 2)
                popup.Size = UDim2.new(0, button.AbsoluteSize.X, 0, #options * 26)
                popup.Visible = true
            end
            for index, option in ipairs(options) do
                local choice = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    Text = tostring(option),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    LayoutOrder = index,
                    ZIndex = 201,
                    Parent = popup,
                })
                New("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = choice})
                choice.MouseButton1Click:Connect(function()
                    item.Value = option
                    button.Text = tostring(option)
                    popup.Visible = false
                    if control.Callback then control.Callback(option) end
                end)
            end
            button.MouseButton1Click:Connect(function()
                if popup.Visible then popup.Visible = false else openPopup() end
            end)
            function item:Set(value)
                item.Value = value
                button.Text = value and tostring(value) or "Select..."
                if control.Callback then control.Callback(value) end
            end
            function item:Refresh(values)
                options = values or {}
                for _, child in ipairs(popup:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for index, option in ipairs(options) do
                    local choice = New("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundTransparency = 1,
                        Text = tostring(option),
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0,
                        LayoutOrder = index,
                        Parent = popup,
                    })
                    New("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = choice})
                    choice.MouseButton1Click:Connect(function()
                        item:Set(option)
                        popup.Visible = false
                    end)
                end
            end
            return item
        end

        function group:AddMultiDropdown(control)
            control = control or {}
            local item = {Value = {}}
            local selected = {}
            local labelHeight = control.Name and 16 or 0
            local wrap = New("Frame", {
                Size = UDim2.new(1, 0, 0, labelHeight + 30),
                BackgroundTransparency = 1,
                LayoutOrder = order(),
                Parent = body,
            })
            if control.Name then MakeLabel(wrap, control.Name, UDim2.new(1, 0, 0, 14), UDim2.new(), 11, Theme.TextSub) end
            local button = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 27),
                Position = UDim2.new(0, 0, 0, labelHeight),
                BackgroundColor3 = Theme.SurfaceMid,
                Text = "Select...",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                Parent = wrap,
            })
            Corner(button, 5)
            Stroke(button, Theme.Border, 1)
            New("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = button})
            local popup = New("Frame", {
                Size = UDim2.new(0, 1, 0, 0),
                BackgroundColor3 = Theme.SurfaceMid,
                BorderSizePixel = 0,
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 200,
                Parent = owner._popupLayer,
            })
            Corner(popup, 6)
            Stroke(popup, Theme.BorderHigh, 1)
            local options = control.Options or {}
            New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = popup})
            local function update()
                item.Value = {}
                for value in pairs(selected) do table.insert(item.Value, value) end
                button.Text = #item.Value > 0 and table.concat(item.Value, ", ") or "Select..."
                if control.Callback then control.Callback(item.Value) end
            end
            for index, option in ipairs(options) do
                local choice = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    Text = tostring(option),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    LayoutOrder = index,
                    ZIndex = 201,
                    Parent = popup,
                })
                New("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = choice})
                choice.MouseButton1Click:Connect(function()
                    selected[option] = not selected[option] or nil
                    update()
                end)
            end
            button.MouseButton1Click:Connect(function()
                local absolute = button.AbsolutePosition
                local layer = owner._popupLayer.AbsolutePosition
                popup.Position = UDim2.new(0, absolute.X - layer.X, 0, absolute.Y - layer.Y + button.AbsoluteSize.Y + 2)
                popup.Size = UDim2.new(0, button.AbsoluteSize.X, 0, #options * 26)
                popup.Visible = not popup.Visible
            end)
            function item:Set(values)
                selected = {}
                for _, value in ipairs(values or {}) do selected[value] = true end
                update()
            end
            return item
        end

        return group
    end
    return tab
end

function Gokai:Destroy()
    if self._gui then self._gui:Destroy() end
end

return Gokai