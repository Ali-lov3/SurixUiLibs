local SurixUiLibs = {}
SurixUiLibs.__index = SurixUiLibs

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local IconFinder = loadstring(game:HttpGet("https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/IconFinder.lua"))()

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local Colors = {
    Background = Color3.fromRGB(11, 11, 16),
    Sidebar = Color3.fromRGB(7, 7, 11),
    Surface = Color3.fromRGB(18, 18, 26),
    SurfaceHover = Color3.fromRGB(24, 24, 34),
    Accent = Color3.fromRGB(59, 130, 246),
    AccentDim = Color3.fromRGB(37, 99, 200),
    AccentGlow = Color3.fromRGB(96, 165, 250),
    Text = Color3.fromRGB(242, 242, 248),
    Subtext = Color3.fromRGB(130, 130, 155),
    Divider = Color3.fromRGB(28, 28, 40),
    Toggle_Off = Color3.fromRGB(35, 35, 48),
    Toggle_On = Color3.fromRGB(59, 130, 246),
    Slider_Track = Color3.fromRGB(28, 28, 40),
    Slider_Fill = Color3.fromRGB(59, 130, 246),
    Dropdown_BG = Color3.fromRGB(14, 14, 20),
    Groupbox = Color3.fromRGB(15, 15, 22),
    GroupboxBorder = Color3.fromRGB(30, 30, 45),
    TitleBar = Color3.fromRGB(9, 9, 14),
    Scrollbar = Color3.fromRGB(40, 40, 60),
}

local PC_WIDTH = 640
local PC_HEIGHT = 420
local MOBILE_WIDTH = 540
local MOBILE_HEIGHT = 280
local SIDEBAR_WIDTH = isMobile and 110 or 148
local TITLEBAR_HEIGHT = 36
local TAB_HEIGHT = isMobile and 36 or 42
local ELEMENT_HEIGHT = 34
local ELEMENT_PADDING = 6
local CONTENT_PADDING = 10

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(inst, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(inst, info, props):Play()
end

local function MakeDraggable(frame, handle)
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
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function SetIcon(imageLabel, iconName, size)
    size = size or 16
    if IconFinder and IconFinder.GetIcon then
        local icon = IconFinder.GetIcon(iconName)
        if icon then
            imageLabel.Image = icon
            imageLabel.Size = UDim2.new(0, size, 0, size)
            return
        end
    end
    imageLabel.Image = ""
    imageLabel.Size = UDim2.new(0, size, 0, size)
end

local function ShowLoadingScreen(screenGui, logoId, title)
    local overlay = Create("Frame", {
        Name = "LoadingOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(6, 6, 10),
        BorderSizePixel = 0,
        ZIndex = 100,
        Parent = screenGui,
    })

    local card = Create("Frame", {
        Name = "LoadingCard",
        Size = UDim2.new(0, 220, 0, 110),
        Position = UDim2.new(0.5, -110, 0.5, -55),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = overlay,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })
    Create("UIStroke", {
        Color = Color3.fromRGB(40, 40, 60),
        Thickness = 1,
        Parent = card,
    })

    local logoHolder = Create("Frame", {
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0.5, -24, 0, 16),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = card,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = logoHolder })

    if logoId and logoId ~= "" then
        Create("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Image = logoId,
            ZIndex = 103,
            Parent = logoHolder,
        })
    else
        local dot = Create("Frame", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0.5, -10, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            ZIndex = 103,
            Parent = logoHolder,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
    end

    Create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 20),
        Position = UDim2.new(0, 8, 0, 70),
        BackgroundTransparency = 1,
        Text = title or "SurixUiLibs",
        TextColor3 = Colors.Text,
        TextSize = isMobile and 13 or 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 102,
        Parent = card,
    })

    local bar = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 3),
        Position = UDim2.new(0, 12, 1, -10),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = card,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })

    Tween(bar, { Size = UDim2.new(0, 196, 0, 3) }, 1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    task.delay(1.5, function()
        Tween(overlay, { BackgroundTransparency = 1 }, 0.4)
        Tween(card, { BackgroundTransparency = 1 }, 0.4)
        task.wait(0.45)
        overlay:Destroy()
    end)
end

function SurixUiLibs:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "SurixUiLibs"
    local logoId = config.Logo or ""
    local showLoading = config.Loading ~= false

    local screenGui = Create("ScreenGui", {
        Name = "SurixUiLibs",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = gethui and gethui() or LocalPlayer.PlayerGui,
    })

    if showLoading then
        ShowLoadingScreen(screenGui, logoId, windowTitle)
    end

    local W = isMobile and MOBILE_WIDTH or PC_WIDTH
    local H = isMobile and MOBILE_HEIGHT or PC_HEIGHT

    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, W, 0, H),
        Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = mainFrame })
    Create("UIStroke", {
        Color = Color3.fromRGB(35, 35, 55),
        Thickness = 1,
        Parent = mainFrame,
    })

    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, TITLEBAR_HEIGHT),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.TitleBar,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = titleBar })

    local titleBarFix = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Colors.TitleBar,
        BorderSizePixel = 0,
        Parent = titleBar,
    })

    local logoFrame = Create("Frame", {
        Name = "LogoFrame",
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 10, 0.5, -11),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Parent = titleBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = logoFrame })

    if logoId and logoId ~= "" then
        Create("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = logoId,
            Parent = logoFrame,
        })
    else
        local logoDot = Create("Frame", {
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(0.5, -4, 0.5, -4),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = logoFrame,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = logoDot })
    end

    Create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = windowTitle,
        TextColor3 = Colors.Text,
        TextSize = isMobile and 12 or 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    local closeBtn = Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -34, 0.5, -14),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        Text = "",
        Parent = titleBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })

    local closeIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundTransparency = 1,
        Parent = closeBtn,
    })
    SetIcon(closeIcon, "x", 14)

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        if mobileBtn then
            mobileBtn.Visible = not mainFrame.Visible
        end
    end)

    MakeDraggable(mainFrame, titleBar)

    local body = Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -TITLEBAR_HEIGHT),
        Position = UDim2.new(0, 0, 0, TITLEBAR_HEIGHT),
        BackgroundTransparency = 1,
        Parent = mainFrame,
    })

    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.Sidebar,
        BorderSizePixel = 0,
        Parent = body,
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = sidebar })
    local sidebarFix = Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = Colors.Sidebar,
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -8),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Scrollbar,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = tabList,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
        Parent = tabList,
    })

    local divider = Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 0),
        BackgroundColor3 = Colors.Divider,
        BorderSizePixel = 0,
        Parent = body,
    })

    local contentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -(SIDEBAR_WIDTH + 2), 1, 0),
        Position = UDim2.new(0, SIDEBAR_WIDTH + 2, 0, 0),
        BackgroundTransparency = 1,
        Parent = body,
    })

    local tabs = {}
    local activeTab = nil

    local mobileBtn = nil

    if isMobile then
        mobileBtn = Create("TextButton", {
            Name = "MobileToggle",
            Size = UDim2.new(0, 32, 0, 80),
            Position = UDim2.new(0, 0, 0.5, -40),
            BackgroundColor3 = Colors.Accent,
            BorderSizePixel = 0,
            Text = "",
            Parent = screenGui,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = mobileBtn })

        local arrowIcon = Create("ImageLabel", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0.5, -7, 0.5, -7),
            BackgroundTransparency = 1,
            Parent = mobileBtn,
        })
        SetIcon(arrowIcon, "chevron-right", 14)

        MakeDraggable(mobileBtn, mobileBtn)

        local mbVisible = true
        mobileBtn.MouseButton1Click:Connect(function()
            mbVisible = not mbVisible
            mainFrame.Visible = mbVisible
            SetIcon(arrowIcon, mbVisible and "chevron-left" or "chevron-right", 14)
        end)
    end

    local window = {}

    local function SetActiveTab(tab)
        if activeTab == tab then return end

        if activeTab then
            Tween(activeTab._btn, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) }, 0.14)
            activeTab._btn.BackgroundTransparency = 1
            activeTab._btnAccent.Size = UDim2.new(0, 2, 0, 0)
            activeTab._btnLabel.TextColor3 = Colors.Subtext
            activeTab._btnIcon.ImageColor3 = Colors.Subtext
            activeTab._content.Visible = false
        end

        activeTab = tab

        Tween(tab._btn, { BackgroundColor3 = Colors.SurfaceHover }, 0.14)
        tab._btn.BackgroundTransparency = 0
        Tween(tab._btnAccent, { Size = UDim2.new(0, 2, 0, TAB_HEIGHT - 12) }, 0.18)
        tab._btnLabel.TextColor3 = Colors.AccentGlow
        tab._btnIcon.ImageColor3 = Colors.AccentGlow
        tab._content.Visible = true
    end

    function window:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or "layout-dashboard"
        local tabType = tabConfig.Type or "Normal"

        local btn = Create("TextButton", {
            Name = tabName .. "Btn",
            Size = UDim2.new(1, 0, 0, TAB_HEIGHT),
            BackgroundColor3 = Colors.SurfaceHover,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = tabList,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = btn })

        local btnAccent = Create("Frame", {
            Name = "Accent",
            Size = UDim2.new(0, 2, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Colors.Accent,
            BorderSizePixel = 0,
            Parent = btn,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btnAccent })

        local btnIcon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(0, 12, 0.5, -7),
            BackgroundTransparency = 1,
            ImageColor3 = Colors.Subtext,
            Parent = btn,
        })
        SetIcon(btnIcon, tabIcon, 15)

        local btnLabel = Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -36, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Colors.Subtext,
            TextSize = isMobile and 11 or 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = btn,
        })

        local content = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Colors.Scrollbar,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = contentArea,
        })

        local tabObj = {
            _btn = btn,
            _btnAccent = btnAccent,
            _btnLabel = btnLabel,
            _btnIcon = btnIcon,
            _content = content,
            _type = tabType,
        }

        btn.MouseButton1Click:Connect(function()
            SetActiveTab(tabObj)
        end)

        btn.MouseEnter:Connect(function()
            if activeTab ~= tabObj then
                Tween(btn, { BackgroundColor3 = Color3.fromRGB(20, 20, 30) }, 0.1)
                btn.BackgroundTransparency = 0
            end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= tabObj then
                btn.BackgroundTransparency = 1
            end
        end)

        if tabType == "Normal" then
            local listLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, ELEMENT_PADDING),
                Parent = content,
            })
            Create("UIPadding", {
                PaddingTop = UDim.new(0, CONTENT_PADDING),
                PaddingLeft = UDim.new(0, CONTENT_PADDING),
                PaddingRight = UDim.new(0, CONTENT_PADDING),
                PaddingBottom = UDim.new(0, CONTENT_PADDING),
                Parent = content,
            })

            local tabInterface = {}

            local function AddElement(elemFrame)
                elemFrame.Parent = content
            end

            local function CreateToggle(cfg)
                cfg = cfg or {}
                local lbl = cfg.Label or "Toggle"
                local default = cfg.Default or false
                local callback = cfg.Callback or function() end

                local frame = Create("Frame", {
                    Name = lbl .. "Toggle",
                    Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT),
                    BackgroundColor3 = Colors.Surface,
                    BorderSizePixel = 0,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = frame })

                Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = lbl,
                    TextColor3 = Colors.Text,
                    TextSize = isMobile and 11 or 13,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame,
                })

                local toggleTrack = Create("Frame", {
                    Name = "Track",
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -46, 0.5, -9),
                    BackgroundColor3 = default and Colors.Toggle_On or Colors.Toggle_Off,
                    BorderSizePixel = 0,
                    Parent = frame,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleTrack })

                local toggleThumb = Create("Frame", {
                    Name = "Thumb",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, default and 21 or 3, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = toggleTrack,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleThumb })

                local state = default
                local clickBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = frame,
                })
                clickBtn.MouseButton1Click:Connect(function()
                    state = not state
                    Tween(toggleTrack, { BackgroundColor3 = state and Colors.Toggle_On or Colors.Toggle_Off }, 0.15)
                    Tween(toggleThumb, { Position = UDim2.new(0, state and 21 or 3, 0.5, -6) }, 0.15)
                    callback(state)
                end)

                AddElement(frame)
                return { GetValue = function() return state end, SetValue = function(v)
                    state = v
                    Tween(toggleTrack, { BackgroundColor3 = state and Colors.Toggle_On or Colors.Toggle_Off }, 0.15)
                    Tween(toggleThumb, { Position = UDim2.new(0, state and 21 or 3, 0.5, -6) }, 0.15)
                    callback(state)
                end }
            end

            local function CreateSlider(cfg)
                cfg = cfg or {}
                local lbl = cfg.Label or "Slider"
                local min = cfg.Min or 0
                local max = cfg.Max or 100
                local default = cfg.Default or min
                local callback = cfg.Callback or function() end

                local frame = Create("Frame", {
                    Name = lbl .. "Slider",
                    Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT + 10),
                    BackgroundColor3 = Colors.Surface,
                    BorderSizePixel = 0,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = frame })

                local topRow = Create("Frame", {
                    Size = UDim2.new(1, -24, 0, 18),
                    Position = UDim2.new(0, 12, 0, 8),
                    BackgroundTransparency = 1,
                    Parent = frame,
                })

                local labelTxt = Create("TextLabel", {
                    Size = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = lbl,
                    TextColor3 = Colors.Text,
                    TextSize = isMobile and 11 or 13,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = topRow,
                })

                local valueTxt = Create("TextLabel", {
                    Size = UDim2.new(0.3, 0, 1, 0),
                    Position = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    TextColor3 = Colors.AccentGlow,
                    TextSize = isMobile and 11 or 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = topRow,
                })

                local trackBG = Create("Frame", {
                    Name = "TrackBG",
                    Size = UDim2.new(1, -24, 0, 4),
                    Position = UDim2.new(0, 12, 0, 32),
                    BackgroundColor3 = Colors.Slider_Track,
                    BorderSizePixel = 0,
                    Parent = frame,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackBG })

                local pct = (default - min) / (max - min)
                local fill = Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = Colors.Slider_Fill,
                    BorderSizePixel = 0,
                    Parent = trackBG,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

                local knob = Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(pct, -6, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = trackBG,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
                Create("UIStroke", {
                    Color = Colors.Accent,
                    Thickness = 2,
                    Parent = knob,
                })

                local draggingSlider = false
                local currentValue = default

                local function UpdateSlider(inputPos)
                    local trackAbsPos = trackBG.AbsolutePosition
                    local trackAbsSize = trackBG.AbsoluteSize
                    local relX = math.clamp((inputPos.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
                    local val = math.floor(min + relX * (max - min) + 0.5)
                    local visualPct = (val - min) / (max - min)
                    currentValue = val
                    fill.Size = UDim2.new(visualPct, 0, 1, 0)
                    knob.Position = UDim2.new(visualPct, -6, 0.5, -6)
                    valueTxt.Text = tostring(val)
                    callback(val)
                end

                local hitbox = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0.5, -12),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = trackBG,
                })

                hitbox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        UpdateSlider(input.Position)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input.Position)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = false
                    end
                end)

                AddElement(frame)
                return {
                    GetValue = function() return currentValue end,
                    SetValue = function(v)
                        v = math.clamp(v, min, max)
                        local vp = (v - min) / (max - min)
                        currentValue = v
                        fill.Size = UDim2.new(vp, 0, 1, 0)
                        knob.Position = UDim2.new(vp, -6, 0.5, -6)
                        valueTxt.Text = tostring(v)
                        callback(v)
                    end
                }
            end

            local function CreateDropdown(cfg)
                cfg = cfg or {}
                local lbl = cfg.Label or "Dropdown"
                local options = cfg.Options or {}
                local default = cfg.Default or (options[1] or "")
                local callback = cfg.Callback or function() end

                local selected = default
                local open = false

                local frame = Create("Frame", {
                    Name = lbl .. "Dropdown",
                    Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT),
                    BackgroundColor3 = Colors.Surface,
                    BorderSizePixel = 0,
                    ClipsDescendants = false,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = frame })

                Create("TextLabel", {
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = lbl,
                    TextColor3 = Colors.Text,
                    TextSize = isMobile and 11 or 13,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame,
                })

                local selectedLabel = Create("TextLabel", {
                    Size = UDim2.new(0.45, -40, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected,
                    TextColor3 = Colors.AccentGlow,
                    TextSize = isMobile and 10 or 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = frame,
                })

                local arrowIco = Create("ImageLabel", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -22, 0.5, -6),
                    BackgroundTransparency = 1,
                    ImageColor3 = Colors.Subtext,
                    Parent = frame,
                })
                SetIcon(arrowIco, "chevron-down", 12)

                local dropPanel = Create("Frame", {
                    Name = "DropPanel",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = Colors.Dropdown_BG,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 10,
                    Visible = false,
                    Parent = frame,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = dropPanel })
                Create("UIStroke", { Color = Color3.fromRGB(35, 35, 55), Thickness = 1, Parent = dropPanel })

                local optList = Create("ScrollingFrame", {
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Colors.Scrollbar,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 11,
                    Parent = dropPanel,
                })
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = optList })
                Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = optList })

                local function PopulateOptions()
                    for _, child in ipairs(optList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local optBtn = Create("TextButton", {
                            Name = opt,
                            Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = opt == selected and Colors.SurfaceHover or Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = opt == selected and 0 or 1,
                            BorderSizePixel = 0,
                            Text = opt,
                            TextColor3 = opt == selected and Colors.AccentGlow or Colors.Text,
                            TextSize = isMobile and 10 or 12,
                            Font = Enum.Font.Gotham,
                            ZIndex = 12,
                            Parent = optList,
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = optBtn })
                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            selectedLabel.Text = opt
                            callback(opt)
                            open = false
                            Tween(dropPanel, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                            task.wait(0.15)
                            dropPanel.Visible = false
                            SetIcon(arrowIco, "chevron-down", 12)
                            PopulateOptions()
                        end)
                    end
                end
                PopulateOptions()

                local clickBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = frame,
                })
                clickBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        local panelH = math.min(#options * 28 + 8, 130)
                        dropPanel.Visible = true
                        Tween(dropPanel, { Size = UDim2.new(1, 0, 0, panelH) }, 0.15)
                        SetIcon(arrowIco, "chevron-up", 12)
                    else
                        Tween(dropPanel, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                        task.wait(0.15)
                        dropPanel.Visible = false
                        SetIcon(arrowIco, "chevron-down", 12)
                    end
                end)

                AddElement(frame)
                return {
                    GetValue = function() return selected end,
                    SetOptions = function(newOpts)
                        options = newOpts
                        selected = newOpts[1] or ""
                        selectedLabel.Text = selected
                        PopulateOptions()
                    end
                }
            end

            local function CreateMultiDropdown(cfg)
                cfg = cfg or {}
                local lbl = cfg.Label or "Multi-Select"
                local options = cfg.Options or {}
                local default = cfg.Default or {}
                local callback = cfg.Callback or function() end

                local selected = {}
                for _, v in ipairs(default) do selected[v] = true end

                local open = false

                local frame = Create("Frame", {
                    Name = lbl .. "MultiDrop",
                    Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT),
                    BackgroundColor3 = Colors.Surface,
                    BorderSizePixel = 0,
                    ClipsDescendants = false,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = frame })

                Create("TextLabel", {
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = lbl,
                    TextColor3 = Colors.Text,
                    TextSize = isMobile and 11 or 13,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame,
                })

                local countLabel = Create("TextLabel", {
                    Size = UDim2.new(0.4, -40, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.AccentGlow,
                    TextSize = isMobile and 10 or 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = frame,
                })

                local function UpdateCountLabel()
                    local count = 0
                    for _ in pairs(selected) do count = count + 1 end
                    countLabel.Text = count > 0 and count .. " selected" or "None"
                end
                UpdateCountLabel()

                local arrowIco = Create("ImageLabel", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(1, -22, 0.5, -6),
                    BackgroundTransparency = 1,
                    ImageColor3 = Colors.Subtext,
                    Parent = frame,
                })
                SetIcon(arrowIco, "chevron-down", 12)

                local dropPanel = Create("Frame", {
                    Name = "DropPanel",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = Colors.Dropdown_BG,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 10,
                    Visible = false,
                    Parent = frame,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = dropPanel })
                Create("UIStroke", { Color = Color3.fromRGB(35, 35, 55), Thickness = 1, Parent = dropPanel })

                local optList = Create("ScrollingFrame", {
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Colors.Scrollbar,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 11,
                    Parent = dropPanel,
                })
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = optList })
                Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = optList })

                local function GetSelectedList()
                    local list = {}
                    for k in pairs(selected) do table.insert(list, k) end
                    return list
                end

                local function PopulateOptions()
                    for _, child in ipairs(optList:GetChildren()) do
                        if child:IsA("Frame") then child:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local isSelected = selected[opt] == true
                        local optRow = Create("Frame", {
                            Name = opt,
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = isSelected and Colors.SurfaceHover or Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = isSelected and 0 or 1,
                            BorderSizePixel = 0,
                            ZIndex = 12,
                            Parent = optList,
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = optRow })

                        local checkboxFrame = Create("Frame", {
                            Size = UDim2.new(0, 14, 0, 14),
                            Position = UDim2.new(0, 8, 0.5, -7),
                            BackgroundColor3 = isSelected and Colors.Accent or Colors.Toggle_Off,
                            BorderSizePixel = 0,
                            ZIndex = 13,
                            Parent = optRow,
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = checkboxFrame })

                        if isSelected then
                            local checkIco = Create("ImageLabel", {
                                Size = UDim2.new(0, 10, 0, 10),
                                Position = UDim2.new(0.5, -5, 0.5, -5),
                                BackgroundTransparency = 1,
                                ZIndex = 14,
                                Parent = checkboxFrame,
                            })
                            SetIcon(checkIco, "check", 10)
                        end

                        Create("TextLabel", {
                            Size = UDim2.new(1, -32, 1, 0),
                            Position = UDim2.new(0, 28, 0, 0),
                            BackgroundTransparency = 1,
                            Text = opt,
                            TextColor3 = isSelected and Colors.AccentGlow or Colors.Text,
                            TextSize = isMobile and 10 or 12,
                            Font = Enum.Font.Gotham,
                            ZIndex = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = optRow,
                        })

                        local hitBtn = Create("TextButton", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            ZIndex = 15,
                            Parent = optRow,
                        })
                        hitBtn.MouseButton1Click:Connect(function()
                            if selected[opt] then
                                selected[opt] = nil
                            else
                                selected[opt] = true
                            end
                            UpdateCountLabel()
                            callback(GetSelectedList())
                            PopulateOptions()
                        end)
                    end
                end
                PopulateOptions()

                local clickBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = frame,
                })
                clickBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        local panelH = math.min(#options * 30 + 8, 150)
                        dropPanel.Visible = true
                        Tween(dropPanel, { Size = UDim2.new(1, 0, 0, panelH) }, 0.15)
                        SetIcon(arrowIco, "chevron-up", 12)
                    else
                        Tween(dropPanel, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                        task.wait(0.15)
                        dropPanel.Visible = false
                        SetIcon(arrowIco, "chevron-down", 12)
                    end
                end)

                AddElement(frame)
                return {
                    GetValue = GetSelectedList,
                    SetOptions = function(newOpts)
                        options = newOpts
                        selected = {}
                        UpdateCountLabel()
                        PopulateOptions()
                    end
                }
            end

            tabInterface.AddToggle = CreateToggle
            tabInterface.AddSlider = CreateSlider
            tabInterface.AddDropdown = CreateDropdown
            tabInterface.AddMultiDropdown = CreateMultiDropdown

            table.insert(tabs, tabObj)
            if #tabs == 1 then
                SetActiveTab(tabObj)
            end

            return tabInterface

        elseif tabType == "Groupbox" then
            local gbContainer = Create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Parent = content,
            })
            Create("UIPadding", {
                PaddingTop = UDim.new(0, CONTENT_PADDING),
                PaddingLeft = UDim.new(0, CONTENT_PADDING),
                PaddingRight = UDim.new(0, CONTENT_PADDING),
                PaddingBottom = UDim.new(0, CONTENT_PADDING),
                Parent = gbContainer,
            })

            local gbInterface = {}
            local groupboxes = {}

            local function CreateGroupbox(side, cfg)
                cfg = cfg or {}
                local gbTitle = cfg.Title or "Group"
                local gbIcon = cfg.Icon or "box"

                local isLeft = side == "Left"
                local gbFrame = Create("Frame", {
                    Name = gbTitle .. "Groupbox",
                    Size = UDim2.new(0.5, isLeft and -6 or -5, 1, -4),
                    Position = isLeft and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, 5, 0, 0),
                    BackgroundColor3 = Colors.Groupbox,
                    BorderSizePixel = 0,
                    ClipsDescendants = false,
                    Parent = gbContainer,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 9), Parent = gbFrame })
                Create("UIStroke", { Color = Colors.GroupboxBorder, Thickness = 1, Parent = gbFrame })

                local headerRow = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = gbFrame,
                })

                local headerIcon = Create("ImageLabel", {
                    Size = UDim2.new(0, 13, 0, 13),
                    Position = UDim2.new(0, 10, 0.5, -6),
                    BackgroundTransparency = 1,
                    ImageColor3 = Colors.Accent,
                    Parent = headerRow,
                })
                SetIcon(headerIcon, gbIcon, 13)

                Create("TextLabel", {
                    Size = UDim2.new(1, -32, 1, 0),
                    Position = UDim2.new(0, 26, 0, 0),
                    BackgroundTransparency = 1,
                    Text = gbTitle,
                    TextColor3 = Colors.Text,
                    TextSize = isMobile and 10 or 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = headerRow,
                })

                Create("Frame", {
                    Size = UDim2.new(1, -20, 0, 1),
                    Position = UDim2.new(0, 10, 0, 30),
                    BackgroundColor3 = Colors.Divider,
                    BorderSizePixel = 0,
                    Parent = gbFrame,
                })

                local scrollArea = Create("ScrollingFrame", {
                    Size = UDim2.new(1, -8, 1, -38),
                    Position = UDim2.new(0, 4, 0, 36),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Colors.Scrollbar,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = gbFrame,
                })
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, ELEMENT_PADDING - 2), Parent = scrollArea })
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 4),
                    Parent = scrollArea,
                })

                local gbApi = {}

                local function AddGbElement(elemFrame)
                    elemFrame.Parent = scrollArea
                end

                function gbApi:AddToggle(cfg2)
                    cfg2 = cfg2 or {}
                    local lbl = cfg2.Label or "Toggle"
                    local default = cfg2.Default or false
                    local callback2 = cfg2.Callback or function() end
                    local state = default

                    local frame = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT - 4),
                        BackgroundColor3 = Colors.Surface,
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = frame })

                    Create("TextLabel", {
                        Size = UDim2.new(1, -52, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1,
                        Text = lbl,
                        TextColor3 = Colors.Text,
                        TextSize = isMobile and 10 or 11,
                        Font = Enum.Font.GothamMedium,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = frame,
                    })

                    local toggleTrack = Create("Frame", {
                        Size = UDim2.new(0, 30, 0, 15),
                        Position = UDim2.new(1, -38, 0.5, -7),
                        BackgroundColor3 = default and Colors.Toggle_On or Colors.Toggle_Off,
                        BorderSizePixel = 0,
                        Parent = frame,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleTrack })

                    local toggleThumb = Create("Frame", {
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(0, default and 17 or 3, 0.5, -5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Parent = toggleTrack,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleThumb })

                    local clickBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = frame,
                    })
                    clickBtn.MouseButton1Click:Connect(function()
                        state = not state
                        Tween(toggleTrack, { BackgroundColor3 = state and Colors.Toggle_On or Colors.Toggle_Off }, 0.15)
                        Tween(toggleThumb, { Position = UDim2.new(0, state and 17 or 3, 0.5, -5) }, 0.15)
                        callback2(state)
                    end)

                    AddGbElement(frame)
                    return { GetValue = function() return state end }
                end

                function gbApi:AddSlider(cfg2)
                    cfg2 = cfg2 or {}
                    local lbl = cfg2.Label or "Slider"
                    local min = cfg2.Min or 0
                    local max = cfg2.Max or 100
                    local default = cfg2.Default or min
                    local callback2 = cfg2.Callback or function() end
                    local currentValue = default

                    local frame = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT + 4),
                        BackgroundColor3 = Colors.Surface,
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = frame })

                    Create("TextLabel", {
                        Size = UDim2.new(0.6, 0, 0, 16),
                        Position = UDim2.new(0, 8, 0, 5),
                        BackgroundTransparency = 1,
                        Text = lbl,
                        TextColor3 = Colors.Text,
                        TextSize = isMobile and 10 or 11,
                        Font = Enum.Font.GothamMedium,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = frame,
                    })

                    local valueTxt = Create("TextLabel", {
                        Size = UDim2.new(0.35, -8, 0, 16),
                        Position = UDim2.new(0.6, 0, 0, 5),
                        BackgroundTransparency = 1,
                        Text = tostring(default),
                        TextColor3 = Colors.AccentGlow,
                        TextSize = isMobile and 10 or 11,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = frame,
                    })

                    local trackBG = Create("Frame", {
                        Size = UDim2.new(1, -16, 0, 3),
                        Position = UDim2.new(0, 8, 0, 27),
                        BackgroundColor3 = Colors.Slider_Track,
                        BorderSizePixel = 0,
                        Parent = frame,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackBG })

                    local pct = (default - min) / (max - min)
                    local fill = Create("Frame", {
                        Size = UDim2.new(pct, 0, 1, 0),
                        BackgroundColor3 = Colors.Slider_Fill,
                        BorderSizePixel = 0,
                        Parent = trackBG,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

                    local knob = Create("Frame", {
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(pct, -5, 0.5, -5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Parent = trackBG,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
                    Create("UIStroke", { Color = Colors.Accent, Thickness = 1.5, Parent = knob })

                    local draggingSlider = false
                    local function UpdateSlider(inputPos)
                        local ta = trackBG.AbsolutePosition
                        local ts = trackBG.AbsoluteSize
                        local relX = math.clamp((inputPos.X - ta.X) / ts.X, 0, 1)
                        local val = math.floor(min + relX * (max - min) + 0.5)
                        local vp = (val - min) / (max - min)
                        currentValue = val
                        fill.Size = UDim2.new(vp, 0, 1, 0)
                        knob.Position = UDim2.new(vp, -5, 0.5, -5)
                        valueTxt.Text = tostring(val)
                        callback2(val)
                    end

                    local hitbox = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 20),
                        Position = UDim2.new(0, 0, 0.5, -10),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = trackBG,
                    })
                    hitbox.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSlider = true
                            UpdateSlider(input.Position)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            UpdateSlider(input.Position)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSlider = false
                        end
                    end)

                    AddGbElement(frame)
                    return { GetValue = function() return currentValue end }
                end

                function gbApi:AddDropdown(cfg2)
                    cfg2 = cfg2 or {}
                    local lbl = cfg2.Label or "Dropdown"
                    local options = cfg2.Options or {}
                    local default = cfg2.Default or (options[1] or "")
                    local callback2 = cfg2.Callback or function() end
                    local selected = default
                    local open = false

                    local frame = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT - 4),
                        BackgroundColor3 = Colors.Surface,
                        BorderSizePixel = 0,
                        ClipsDescendants = false,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = frame })

                    Create("TextLabel", {
                        Size = UDim2.new(0.5, 0, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1,
                        Text = lbl,
                        TextColor3 = Colors.Text,
                        TextSize = isMobile and 10 or 11,
                        Font = Enum.Font.GothamMedium,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = frame,
                    })

                    local selLabel = Create("TextLabel", {
                        Size = UDim2.new(0.42, -20, 1, 0),
                        Position = UDim2.new(0.5, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Text = selected,
                        TextColor3 = Colors.AccentGlow,
                        TextSize = isMobile and 9 or 11,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = frame,
                    })

                    local arrowIco = Create("ImageLabel", {
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(1, -16, 0.5, -5),
                        BackgroundTransparency = 1,
                        ImageColor3 = Colors.Subtext,
                        Parent = frame,
                    })
                    SetIcon(arrowIco, "chevron-down", 10)

                    local dropPanel = Create("Frame", {
                        Name = "DropPanel",
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0, 0, 1, 3),
                        BackgroundColor3 = Colors.Dropdown_BG,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        ZIndex = 20,
                        Visible = false,
                        Parent = frame,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = dropPanel })
                    Create("UIStroke", { Color = Color3.fromRGB(35, 35, 55), Thickness = 1, Parent = dropPanel })

                    local optList = Create("ScrollingFrame", {
                        Size = UDim2.new(1, -4, 1, -4),
                        Position = UDim2.new(0, 2, 0, 2),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ScrollBarThickness = 2,
                        ScrollBarImageColor3 = Colors.Scrollbar,
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ZIndex = 21,
                        Parent = dropPanel,
                    })
                    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = optList })
                    Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = optList })

                    local function PopulateOptions()
                        for _, c in ipairs(optList:GetChildren()) do
                            if c:IsA("TextButton") then c:Destroy() end
                        end
                        for _, opt in ipairs(options) do
                            local optBtn = Create("TextButton", {
                                Size = UDim2.new(1, 0, 0, 22),
                                BackgroundColor3 = opt == selected and Colors.SurfaceHover or Color3.fromRGB(0, 0, 0),
                                BackgroundTransparency = opt == selected and 0 or 1,
                                BorderSizePixel = 0,
                                Text = opt,
                                TextColor3 = opt == selected and Colors.AccentGlow or Colors.Text,
                                TextSize = isMobile and 9 or 11,
                                Font = Enum.Font.Gotham,
                                ZIndex = 22,
                                Parent = optList,
                            })
                            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = optBtn })
                            optBtn.MouseButton1Click:Connect(function()
                                selected = opt
                                selLabel.Text = opt
                                callback2(opt)
                                open = false
                                Tween(dropPanel, { Size = UDim2.new(1, 0, 0, 0) }, 0.12)
                                task.wait(0.13)
                                dropPanel.Visible = false
                                SetIcon(arrowIco, "chevron-down", 10)
                                PopulateOptions()
                            end)
                        end
                    end
                    PopulateOptions()

                    local clickBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT - 4),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = frame,
                    })
                    clickBtn.MouseButton1Click:Connect(function()
                        open = not open
                        if open then
                            local panelH = math.min(#options * 24 + 8, 110)
                            dropPanel.Visible = true
                            Tween(dropPanel, { Size = UDim2.new(1, 0, 0, panelH) }, 0.15)
                            SetIcon(arrowIco, "chevron-up", 10)
                        else
                            Tween(dropPanel, { Size = UDim2.new(1, 0, 0, 0) }, 0.12)
                            task.wait(0.13)
                            dropPanel.Visible = false
                            SetIcon(arrowIco, "chevron-down", 10)
                        end
                    end)

                    AddGbElement(frame)
                    return { GetValue = function() return selected end }
                end

                function gbApi:AddMultiDropdown(cfg2)
                    cfg2 = cfg2 or {}
                    local lbl = cfg2.Label or "Multi-Select"
                    local options = cfg2.Options or {}
                    local default = cfg2.Default or {}
                    local callback2 = cfg2.Callback or function() end
                    local selected = {}
                    for _, v in ipairs(default) do selected[v] = true end
                    local open = false

                    local frame = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT - 4),
                        BackgroundColor3 = Colors.Surface,
                        BorderSizePixel = 0,
                        ClipsDescendants = false,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = frame })

                    Create("TextLabel", {
                        Size = UDim2.new(0.5, 0, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1,
                        Text = lbl,
                        TextColor3 = Colors.Text,
                        TextSize = isMobile and 10 or 11,
                        Font = Enum.Font.GothamMedium,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = frame,
                    })

                    local countLbl = Create("TextLabel", {
                        Size = UDim2.new(0.42, -20, 1, 0),
                        Position = UDim2.new(0.5, 0, 0, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = Colors.AccentGlow,
                        TextSize = isMobile and 9 or 11,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = frame,
                    })

                    local function UpdateCount()
                        local n = 0
                        for _ in pairs(selected) do n = n + 1 end
                        countLbl.Text = n > 0 and n .. " sel." or "None"
                    end
                    UpdateCount()

                    local arrowIco = Create("ImageLabel", {
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(1, -16, 0.5, -5),
                        BackgroundTransparency = 1,
                        ImageColor3 = Colors.Subtext,
                        Parent = frame,
                    })
                    SetIcon(arrowIco, "chevron-down", 10)

                    local dropPanel = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0, 0, 1, 3),
                        BackgroundColor3 = Colors.Dropdown_BG,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        ZIndex = 20,
                        Visible = false,
                        Parent = frame,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = dropPanel })
                    Create("UIStroke", { Color = Color3.fromRGB(35, 35, 55), Thickness = 1, Parent = dropPanel })

                    local optList = Create("ScrollingFrame", {
                        Size = UDim2.new(1, -4, 1, -4),
                        Position = UDim2.new(0, 2, 0, 2),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ScrollBarThickness = 2,
                        ScrollBarImageColor3 = Colors.Scrollbar,
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ZIndex = 21,
                        Parent = dropPanel,
                    })
                    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = optList })
                    Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = optList })

                    local function GetSelectedList()
                        local list = {}
                        for k in pairs(selected) do table.insert(list, k) end
                        return list
                    end

                    local function PopulateOptions()
                        for _, c in ipairs(optList:GetChildren()) do
                            if c:IsA("Frame") then c:Destroy() end
                        end
                        for _, opt in ipairs(options) do
                            local isSel = selected[opt] == true
                            local row = Create("Frame", {
                                Size = UDim2.new(1, 0, 0, 24),
                                BackgroundColor3 = isSel and Colors.SurfaceHover or Color3.fromRGB(0, 0, 0),
                                BackgroundTransparency = isSel and 0 or 1,
                                BorderSizePixel = 0,
                                ZIndex = 22,
                                Parent = optList,
                            })
                            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = row })

                            local cb = Create("Frame", {
                                Size = UDim2.new(0, 12, 0, 12),
                                Position = UDim2.new(0, 6, 0.5, -6),
                                BackgroundColor3 = isSel and Colors.Accent or Colors.Toggle_Off,
                                BorderSizePixel = 0,
                                ZIndex = 23,
                                Parent = row,
                            })
                            Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = cb })

                            if isSel then
                                local ckIco = Create("ImageLabel", {
                                    Size = UDim2.new(0, 8, 0, 8),
                                    Position = UDim2.new(0.5, -4, 0.5, -4),
                                    BackgroundTransparency = 1,
                                    ZIndex = 24,
                                    Parent = cb,
                                })
                                SetIcon(ckIco, "check", 8)
                            end

                            Create("TextLabel", {
                                Size = UDim2.new(1, -26, 1, 0),
                                Position = UDim2.new(0, 22, 0, 0),
                                BackgroundTransparency = 1,
                                Text = opt,
                                TextColor3 = isSel and Colors.AccentGlow or Colors.Text,
                                TextSize = isMobile and 9 or 11,
                                Font = Enum.Font.Gotham,
                                ZIndex = 23,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Parent = row,
                            })

                            local hitBtn = Create("TextButton", {
                                Size = UDim2.new(1, 0, 1, 0),
                                BackgroundTransparency = 1,
                                Text = "",
                                ZIndex = 25,
                                Parent = row,
                            })
                            hitBtn.MouseButton1Click:Connect(function()
                                if selected[opt] then selected[opt] = nil else selected[opt] = true end
                                UpdateCount()
                                callback2(GetSelectedList())
                                PopulateOptions()
                            end)
                        end
                    end
                    PopulateOptions()

                    local clickBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT - 4),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = frame,
                    })
                    clickBtn.MouseButton1Click:Connect(function()
                        open = not open
                        if open then
                            local panelH = math.min(#options * 26 + 8, 130)
                            dropPanel.Visible = true
                            Tween(dropPanel, { Size = UDim2.new(1, 0, 0, panelH) }, 0.15)
                            SetIcon(arrowIco, "chevron-up", 10)
                        else
                            Tween(dropPanel, { Size = UDim2.new(1, 0, 0, 0) }, 0.12)
                            task.wait(0.13)
                            dropPanel.Visible = false
                            SetIcon(arrowIco, "chevron-down", 10)
                        end
                    end)

                    AddGbElement(frame)
                    return { GetValue = GetSelectedList }
                end

                return gbApi
            end

            function gbInterface:AddLeftGroupbox(cfg)
                return CreateGroupbox("Left", cfg)
            end

            function gbInterface:AddRightGroupbox(cfg)
                return CreateGroupbox("Right", cfg)
            end

            table.insert(tabs, tabObj)
            if #tabs == 1 then
                SetActiveTab(tabObj)
            end

            return gbInterface
        end
    end

    return window
end

return SurixUiLibs
