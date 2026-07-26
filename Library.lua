local SurixUiLibs = {}
SurixUiLibs.__index = SurixUiLibs

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local LucideIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Lucide.lua"))()

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local C = {
    BG           = Color3.fromRGB(10, 10, 15),
    BG2          = Color3.fromRGB(16, 16, 24),
    Sidebar      = Color3.fromRGB(8, 8, 13),
    Sidebar2     = Color3.fromRGB(13, 13, 20),
    Surface      = Color3.fromRGB(18, 20, 30),
    Surface2     = Color3.fromRGB(26, 28, 42),
    SurfaceHov   = Color3.fromRGB(28, 32, 50),
    Accent       = Color3.fromRGB(56, 127, 255),
    Accent2      = Color3.fromRGB(100, 160, 255),
    AccentDark   = Color3.fromRGB(30, 70, 160),
    AccentGlow   = Color3.fromRGB(120, 175, 255),
    Text         = Color3.fromRGB(235, 238, 255),
    TextDim      = Color3.fromRGB(160, 168, 200),
    Subtext      = Color3.fromRGB(90, 100, 135),
    Divider      = Color3.fromRGB(25, 28, 44),
    Divider2     = Color3.fromRGB(35, 40, 62),
    ToggleOff    = Color3.fromRGB(28, 30, 46),
    ToggleOn     = Color3.fromRGB(56, 127, 255),
    SliderTrack  = Color3.fromRGB(22, 24, 38),
    SliderFill   = Color3.fromRGB(56, 127, 255),
    SliderFill2  = Color3.fromRGB(100, 175, 255),
    DropBG       = Color3.fromRGB(12, 13, 20),
    DropBG2      = Color3.fromRGB(18, 20, 32),
    GroupBG      = Color3.fromRGB(13, 14, 22),
    GroupBG2     = Color3.fromRGB(18, 20, 32),
    GroupBorder  = Color3.fromRGB(32, 36, 58),
    TitleBar     = Color3.fromRGB(8, 9, 14),
    TitleBar2    = Color3.fromRGB(14, 16, 26),
    ScrollBar    = Color3.fromRGB(45, 52, 80),
    White        = Color3.fromRGB(255, 255, 255),
    Black        = Color3.fromRGB(0, 0, 0),
    Transparent  = Color3.fromRGB(0, 0, 0),
}

local PC_W         = 660
local PC_H         = 430
local MOB_W        = 540
local MOB_H        = 280
local SIDEBAR_W    = isMobile and 112 or 150
local TITLE_H      = 38
local TAB_H        = isMobile and 37 or 44
local ELEM_H       = 34
local ELEM_PAD     = 7
local CONT_PAD     = 11

local function Create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Gradient(parent, c1, c2, rot)
    local g = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2),
        }),
        Rotation = rot or 90,
        Parent = parent,
    })
    return g
end

local function Tween(inst, props, t, style, dir)
    TweenService:Create(inst, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

local function Icon(parent, name, size, color, pos)
    size = size or 16
    color = color or C.Text
    local img = Create("ImageLabel", {
        Size = UDim2.new(0, size, 0, size),
        Position = pos or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Image = LucideIcons and LucideIcons[name] or "",
        ImageColor3 = color,
        Parent = parent,
    })
    return img
end

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function MakeRipple(btn)
    btn.MouseButton1Click:Connect(function()
        local ripple = Create("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            ZIndex = btn.ZIndex + 1,
            Parent = btn,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })
        Tween(ripple, { Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1 }, 0.4, Enum.EasingStyle.Quad)
        task.delay(0.4, function() ripple:Destroy() end)
    end)
end

local function ShowLoading(gui, logoId, title)
    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(6, 6, 10),
        BorderSizePixel = 0,
        ZIndex = 200,
        Parent = gui,
    })
    Gradient(overlay, Color3.fromRGB(6, 6, 12), Color3.fromRGB(10, 10, 20), 135)

    local card = Create("Frame", {
        Size = UDim2.new(0, 230, 0, 130),
        Position = UDim2.new(0.5, -115, 0.5, -65),
        BackgroundColor3 = C.Surface,
        BorderSizePixel = 0,
        ZIndex = 201,
        Parent = overlay,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = card })
    Gradient(card, C.Surface, C.Surface2, 135)
    Create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.6, Parent = card })

    local glow = Create("Frame", {
        Size = UDim2.new(0, 180, 0, 60),
        Position = UDim2.new(0.5, -90, 0, -20),
        BackgroundColor3 = C.Accent,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 200,
        Parent = card,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glow })

    local logoBox = Create("Frame", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0.5, -22, 0, 18),
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
        ZIndex = 202,
        Parent = card,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = logoBox })
    Gradient(logoBox, C.Accent, C.AccentDark, 145)
    Create("UIStroke", { Color = C.Accent2, Thickness = 1, Transparency = 0.4, Parent = logoBox })

    if logoId and logoId ~= "" and logoId ~= "rbxassetid://0" then
        Create("ImageLabel", {
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            Image = logoId,
            ZIndex = 203,
            Parent = logoBox,
        })
    else
        local dot = Create("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0.5, -9, 0.5, -9),
            BackgroundColor3 = C.White,
            BorderSizePixel = 0,
            ZIndex = 203,
            Parent = logoBox,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
    end

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 10, 0, 68),
        BackgroundTransparency = 1,
        Text = title or "SurixUiLibs",
        TextColor3 = C.Text,
        TextSize = isMobile and 13 or 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 202,
        Parent = card,
    })

    local trackBG = Create("Frame", {
        Size = UDim2.new(0, 190, 0, 3),
        Position = UDim2.new(0.5, -95, 0, 102),
        BackgroundColor3 = C.SliderTrack,
        BorderSizePixel = 0,
        ZIndex = 202,
        Parent = card,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackBG })

    local fill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
        ZIndex = 203,
        Parent = trackBG,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
    Gradient(fill, C.Accent2, C.Accent, 0)

    Tween(fill, { Size = UDim2.new(1, 0, 1, 0) }, 1.3, Enum.EasingStyle.Quart)

    task.delay(1.6, function()
        Tween(overlay, { BackgroundTransparency = 1 }, 0.35)
        Tween(card, { BackgroundTransparency = 1 }, 0.35)
        task.wait(0.38)
        overlay:Destroy()
    end)
end

function SurixUiLibs:CreateWindow(config)
    config = config or {}
    local wTitle  = config.Title or "SurixUiLibs"
    local logoId  = config.Logo or ""
    local loading = config.Loading ~= false

    local screenGui = Create("ScreenGui", {
        Name = "SurixUiLibs",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (gethui and gethui()) or LocalPlayer.PlayerGui,
    })

    if loading then
        ShowLoading(screenGui, logoId, wTitle)
    end

    local W = isMobile and MOB_W or PC_W
    local H = isMobile and MOB_H or PC_H

    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, W, 0, H),
        Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = C.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = mainFrame })
    Gradient(mainFrame, C.BG, C.BG2, 135)
    Create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.75, Parent = mainFrame })

    local outerGlow = Create("Frame", {
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundColor3 = C.Accent,
        BackgroundTransparency = 0.93,
        BorderSizePixel = 0,
        ZIndex = -1,
        Parent = mainFrame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 30), Parent = outerGlow })

    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, TITLE_H),
        BackgroundColor3 = C.TitleBar,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = titleBar })
    Gradient(titleBar, C.TitleBar, C.TitleBar2, 90)

    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = C.TitleBar2,
        BorderSizePixel = 0,
        Parent = titleBar,
    })

    local titleDivider = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.Divider2,
        BorderSizePixel = 0,
        Parent = titleBar,
    })
    Gradient(titleDivider, C.Accent, C.Divider2, 0)

    local logoBox = Create("Frame", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 11, 0.5, -12),
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
        Parent = titleBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = logoBox })
    Gradient(logoBox, C.Accent2, C.AccentDark, 135)

    if logoId and logoId ~= "" and logoId ~= "rbxassetid://0" then
        Create("ImageLabel", {
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundTransparency = 1,
            Image = logoId,
            Parent = logoBox,
        })
    else
        local ld = Create("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0.5, -5, 0.5, -5),
            BackgroundColor3 = C.White,
            BorderSizePixel = 0,
            Parent = logoBox,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ld })
    end

    Create("TextLabel", {
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, 43, 0, 0),
        BackgroundTransparency = 1,
        Text = wTitle,
        TextColor3 = C.Text,
        TextSize = isMobile and 12 or 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    local dotRow = Create("Frame", {
        Size = UDim2.new(0, 58, 0, 10),
        Position = UDim2.new(1, -70, 0.5, -5),
        BackgroundTransparency = 1,
        Parent = titleBar,
    })

    local function DotBtn(xOff, col)
        local d = Create("TextButton", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, xOff, 0.5, -6),
            BackgroundColor3 = col,
            BorderSizePixel = 0,
            Text = "",
            Parent = dotRow,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = d })
        return d
    end

    local closeBtn = DotBtn(0, Color3.fromRGB(255, 80, 80))
    local minBtn   = DotBtn(18, Color3.fromRGB(255, 190, 40))
    DotBtn(36, Color3.fromRGB(45, 200, 100))

    local hidden = false
    local body

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    minBtn.MouseButton1Click:Connect(function()
        hidden = not hidden
        if body then body.Visible = not hidden end
        Tween(mainFrame, { Size = hidden and UDim2.new(0, W, 0, TITLE_H) or UDim2.new(0, W, 0, H) }, 0.22)
    end)

    MakeDraggable(mainFrame, titleBar)

    body = Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -TITLE_H),
        Position = UDim2.new(0, 0, 0, TITLE_H),
        BackgroundTransparency = 1,
        Parent = mainFrame,
    })

    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, SIDEBAR_W, 1, 0),
        BackgroundColor3 = C.Sidebar,
        BorderSizePixel = 0,
        Parent = body,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = sidebar })
    Gradient(sidebar, C.Sidebar, C.Sidebar2, 160)

    Create("Frame", {
        Size = UDim2.new(0, 12, 1, 0),
        Position = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = C.Sidebar2,
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    local sidebarAccentLine = Create("Frame", {
        Size = UDim2.new(0, 1, 0.7, 0),
        Position = UDim2.new(1, -1, 0.15, 0),
        BackgroundColor3 = C.Accent,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    Gradient(sidebarAccentLine, C.Transparent, C.Accent, 90)

    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        Parent = tabList,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
        Parent = tabList,
    })

    local contentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -(SIDEBAR_W + 1), 1, 0),
        Position = UDim2.new(0, SIDEBAR_W + 1, 0, 0),
        BackgroundTransparency = 1,
        Parent = body,
    })

    local tabs = {}
    local activeTab = nil

    local function SetActive(tab)
        if activeTab == tab then return end
        if activeTab then
            Tween(activeTab._btn, { BackgroundTransparency = 1 }, 0.15)
            activeTab._btnAccent.Visible = false
            activeTab._btnLabel.TextColor3 = C.Subtext
            activeTab._btnLabel.Font = Enum.Font.Gotham
            if activeTab._btnIcon then activeTab._btnIcon.ImageColor3 = C.Subtext end
            activeTab._content.Visible = false
        end
        activeTab = tab
        Tween(tab._btn, { BackgroundTransparency = 0 }, 0.15)
        tab._btnAccent.Visible = true
        Tween(tab._btnAccent, { Size = UDim2.new(0, 3, 0, TAB_H - 14) }, 0.2)
        tab._btnLabel.TextColor3 = C.AccentGlow
        tab._btnLabel.Font = Enum.Font.GothamBold
        if tab._btnIcon then Tween(tab._btnIcon, { ImageColor3 = C.AccentGlow }, 0.15) end
        tab._content.Visible = true
    end

    local mobileBtn = nil
    if isMobile then
        mobileBtn = Create("TextButton", {
            Name = "MobileToggle",
            Size = UDim2.new(0, 30, 0, 72),
            Position = UDim2.new(0, 0, 0.5, -36),
            BackgroundColor3 = C.Accent,
            BorderSizePixel = 0,
            Text = "",
            Parent = screenGui,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = mobileBtn })
        Gradient(mobileBtn, C.Accent2, C.AccentDark, 90)
        Create("UIStroke", { Color = C.Accent2, Thickness = 1, Transparency = 0.5, Parent = mobileBtn })

        local chevron = Icon(mobileBtn, "chevron-right", 14, C.White, UDim2.new(0.5, -7, 0.5, -7))

        MakeDraggable(mobileBtn, mobileBtn)

        local mbVis = true
        mobileBtn.MouseButton1Click:Connect(function()
            mbVis = not mbVis
            mainFrame.Visible = mbVis
            chevron.Image = LucideIcons and LucideIcons[mbVis and "chevron-left" or "chevron-right"] or ""
        end)
    end

    local window = {}

    function window:AddTab(tc)
        tc = tc or {}
        local tName = tc.Name or "Tab"
        local tIcon = tc.Icon or "layout-dashboard"
        local tType = tc.Type or "Normal"

        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, TAB_H),
            BackgroundColor3 = C.SurfaceHov,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = tabList,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 9), Parent = btn })
        Gradient(btn, C.SurfaceHov, C.Surface, 135)

        local accent = Create("Frame", {
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, -1, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = C.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = btn,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = accent })
        Gradient(accent, C.AccentGlow, C.Accent, 90)

        local ico = Icon(btn, tIcon, isMobile and 14 or 15, C.Subtext, UDim2.new(0, 11, 0.5, -(isMobile and 7 or 7)))

        local lbl = Create("TextLabel", {
            Size = UDim2.new(1, -36, 1, 0),
            Position = UDim2.new(0, 31, 0, 0),
            BackgroundTransparency = 1,
            Text = tName,
            TextColor3 = C.Subtext,
            TextSize = isMobile and 11 or 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = btn,
        })

        local content = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = C.ScrollBar,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = contentArea,
        })

        local tabObj = {
            _btn = btn,
            _btnAccent = accent,
            _btnLabel = lbl,
            _btnIcon = ico,
            _content = content,
            _type = tType,
        }

        btn.MouseButton1Click:Connect(function() SetActive(tabObj) end)
        btn.MouseEnter:Connect(function()
            if activeTab ~= tabObj then
                Tween(btn, { BackgroundTransparency = 0.5 }, 0.12)
            end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= tabObj then
                Tween(btn, { BackgroundTransparency = 1 }, 0.12)
            end
        end)

        local function ElemSurface(parent, h)
            local f = Create("Frame", {
                Size = UDim2.new(1, 0, 0, h or ELEM_H),
                BackgroundColor3 = C.Surface,
                BorderSizePixel = 0,
                Parent = parent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = f })
            Gradient(f, C.Surface, C.Surface2, 135)
            Create("UIStroke", { Color = C.Divider2, Thickness = 1, Parent = f })
            return f
        end

        local function ElemLabel(parent, text, sz)
            return Create("TextLabel", {
                Size = UDim2.new(0.55, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = C.TextDim,
                TextSize = sz or (isMobile and 11 or 13),
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = parent,
            })
        end

        local function BuildToggle(cfg, parent)
            cfg = cfg or {}
            local state = cfg.Default or false
            local cb    = cfg.Callback or function() end

            local frame = ElemSurface(parent)
            ElemLabel(frame, cfg.Label or "Toggle")

            local track = Create("Frame", {
                Size = UDim2.new(0, 38, 0, 20),
                Position = UDim2.new(1, -48, 0.5, -10),
                BackgroundColor3 = state and C.ToggleOn or C.ToggleOff,
                BorderSizePixel = 0,
                Parent = frame,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
            Create("UIStroke", { Color = state and C.Accent2 or C.Divider2, Thickness = 1, Parent = track })
            if state then Gradient(track, C.Accent2, C.Accent, 0) end

            local thumb = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, state and 21 or 3, 0.5, -7),
                BackgroundColor3 = C.White,
                BorderSizePixel = 0,
                Parent = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })

            local clickBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = frame,
            })
            MakeRipple(clickBtn)

            clickBtn.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    Tween(track, { BackgroundColor3 = C.ToggleOn }, 0.18)
                    Gradient(track, C.Accent2, C.Accent, 0)
                else
                    Tween(track, { BackgroundColor3 = C.ToggleOff }, 0.18)
                    for _, g in ipairs(track:GetChildren()) do if g:IsA("UIGradient") then g:Destroy() end end
                end
                Tween(track.UIStroke, { Color = state and C.Accent2 or C.Divider2 }, 0.18)
                Tween(thumb, { Position = UDim2.new(0, state and 21 or 3, 0.5, -7) }, 0.18)
                cb(state)
            end)

            frame.Parent = parent
            return {
                GetValue = function() return state end,
                SetValue = function(v)
                    state = v
                    Tween(track, { BackgroundColor3 = state and C.ToggleOn or C.ToggleOff }, 0.18)
                    Tween(thumb, { Position = UDim2.new(0, state and 21 or 3, 0.5, -7) }, 0.18)
                    cb(state)
                end
            }
        end

        local function BuildSlider(cfg, parent)
            cfg = cfg or {}
            local min  = cfg.Min or 0
            local max  = cfg.Max or 100
            local def  = math.clamp(cfg.Default or min, min, max)
            local cb   = cfg.Callback or function() end
            local cur  = def

            local frame = ElemSurface(parent, ELEM_H + 12)
            ElemLabel(frame, cfg.Label or "Slider")

            local valLbl = Create("TextLabel", {
                Size = UDim2.new(0.38, -12, 0, 18),
                Position = UDim2.new(0.55, 0, 0, 8),
                BackgroundTransparency = 1,
                Text = tostring(def),
                TextColor3 = C.AccentGlow,
                TextSize = isMobile and 11 or 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = frame,
            })

            local trackBG = Create("Frame", {
                Size = UDim2.new(1, -24, 0, 4),
                Position = UDim2.new(0, 12, 0, ELEM_H - 2),
                BackgroundColor3 = C.SliderTrack,
                BorderSizePixel = 0,
                Parent = frame,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackBG })
            Create("UIStroke", { Color = C.Divider2, Thickness = 1, Parent = trackBG })

            local pct = (def - min) / (max - min)

            local fill = Create("Frame", {
                Size = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = C.SliderFill,
                BorderSizePixel = 0,
                Parent = trackBG,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
            Gradient(fill, C.SliderFill2, C.SliderFill, 0)

            local knob = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(pct, -7, 0.5, -7),
                BackgroundColor3 = C.White,
                BorderSizePixel = 0,
                Parent = trackBG,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
            Create("UIStroke", { Color = C.Accent2, Thickness = 2, Parent = knob })

            local dragging = false
            local function Upd(pos)
                local a, s = trackBG.AbsolutePosition, trackBG.AbsoluteSize
                local rx = math.clamp((pos.X - a.X) / s.X, 0, 1)
                local v  = math.floor(min + rx * (max - min) + 0.5)
                local vp = (v - min) / (max - min)
                cur = v
                fill.Size = UDim2.new(vp, 0, 1, 0)
                knob.Position = UDim2.new(vp, -7, 0.5, -7)
                valLbl.Text = tostring(v)
                cb(v)
            end

            local hit = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                Position = UDim2.new(0, 0, 0.5, -13),
                BackgroundTransparency = 1,
                Text = "",
                Parent = trackBG,
            })
            hit.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Upd(inp.Position)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    Upd(inp.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            frame.Parent = parent
            return {
                GetValue = function() return cur end,
                SetValue = function(v)
                    v = math.clamp(v, min, max)
                    local vp = (v - min) / (max - min)
                    cur = v
                    fill.Size = UDim2.new(vp, 0, 1, 0)
                    knob.Position = UDim2.new(vp, -7, 0.5, -7)
                    valLbl.Text = tostring(v)
                    cb(v)
                end
            }
        end

        local function BuildDropdown(cfg, parent)
            cfg = cfg or {}
            local opts = cfg.Options or {}
            local sel  = cfg.Default or opts[1] or ""
            local cb   = cfg.Callback or function() end
            local open = false

            local frame = ElemSurface(parent)
            frame.ClipsDescendants = false
            ElemLabel(frame, cfg.Label or "Dropdown")

            local selLbl = Create("TextLabel", {
                Size = UDim2.new(0.38, -22, 1, 0),
                Position = UDim2.new(0.55, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = sel,
                TextColor3 = C.AccentGlow,
                TextSize = isMobile and 10 or 12,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = frame,
            })

            local arrow = Icon(frame, "chevron-down", 12, C.Subtext, UDim2.new(1, -20, 0.5, -6))

            local panel = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 5),
                BackgroundColor3 = C.DropBG,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 15,
                Visible = false,
                Parent = frame,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = panel })
            Gradient(panel, C.DropBG, C.DropBG2, 135)
            Create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.7, Parent = panel })

            local pScroll = Create("ScrollingFrame", {
                Size = UDim2.new(1, -6, 1, -6),
                Position = UDim2.new(0, 3, 0, 3),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = C.ScrollBar,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 16,
                Parent = panel,
            })
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = pScroll })
            Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = pScroll })

            local function Populate()
                for _, c in ipairs(pScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _, opt in ipairs(opts) do
                    local isSel = opt == sel
                    local ob = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = isSel and C.SurfaceHov or C.Transparent,
                        BackgroundTransparency = isSel and 0 or 1,
                        BorderSizePixel = 0,
                        Text = opt,
                        TextColor3 = isSel and C.AccentGlow or C.TextDim,
                        TextSize = isMobile and 10 or 12,
                        Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham,
                        ZIndex = 17,
                        Parent = pScroll,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ob })
                    if isSel then
                        Gradient(ob, C.Surface2, C.SurfaceHov, 90)
                        local ck = Icon(ob, "check", 11, C.AccentGlow, UDim2.new(1, -19, 0.5, -5))
                        ck.ZIndex = 18
                    end
                    ob.MouseButton1Click:Connect(function()
                        sel = opt
                        selLbl.Text = opt
                        cb(opt)
                        open = false
                        Tween(panel, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                        task.wait(0.16)
                        panel.Visible = false
                        arrow.Image = LucideIcons and LucideIcons["chevron-down"] or ""
                        Populate()
                    end)
                end
            end
            Populate()

            local clickBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, ELEM_H),
                BackgroundTransparency = 1,
                Text = "",
                Parent = frame,
            })
            clickBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local ph = math.min(#opts * 30 + 8, 140)
                    panel.Visible = true
                    Tween(panel, { Size = UDim2.new(1, 0, 0, ph) }, 0.18)
                    arrow.Image = LucideIcons and LucideIcons["chevron-up"] or ""
                else
                    Tween(panel, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                    task.wait(0.16)
                    panel.Visible = false
                    arrow.Image = LucideIcons and LucideIcons["chevron-down"] or ""
                end
            end)

            frame.Parent = parent
            return { GetValue = function() return sel end }
        end

        local function BuildMultiDropdown(cfg, parent)
            cfg = cfg or {}
            local opts = cfg.Options or {}
            local cb   = cfg.Callback or function() end
            local sel  = {}
            for _, v in ipairs(cfg.Default or {}) do sel[v] = true end
            local open = false

            local frame = ElemSurface(parent)
            frame.ClipsDescendants = false
            ElemLabel(frame, cfg.Label or "Multi-Select")

            local cntLbl = Create("TextLabel", {
                Size = UDim2.new(0.38, -22, 1, 0),
                Position = UDim2.new(0.55, 0, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = C.AccentGlow,
                TextSize = isMobile and 10 or 12,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = frame,
            })

            local function UpdCount()
                local n = 0
                for _ in pairs(sel) do n = n + 1 end
                cntLbl.Text = n > 0 and n .. " selected" or "None"
            end
            UpdCount()

            local arrow = Icon(frame, "chevron-down", 12, C.Subtext, UDim2.new(1, -20, 0.5, -6))

            local panel = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 5),
                BackgroundColor3 = C.DropBG,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 15,
                Visible = false,
                Parent = frame,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = panel })
            Gradient(panel, C.DropBG, C.DropBG2, 135)
            Create("UIStroke", { Color = C.Accent, Thickness = 1, Transparency = 0.7, Parent = panel })

            local pScroll = Create("ScrollingFrame", {
                Size = UDim2.new(1, -6, 1, -6),
                Position = UDim2.new(0, 3, 0, 3),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = C.ScrollBar,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 16,
                Parent = panel,
            })
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = pScroll })
            Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = pScroll })

            local function GetList()
                local t = {}
                for k in pairs(sel) do table.insert(t, k) end
                return t
            end

            local function Populate()
                for _, c in ipairs(pScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                for _, opt in ipairs(opts) do
                    local isSel = sel[opt] == true
                    local row = Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = isSel and C.SurfaceHov or C.Transparent,
                        BackgroundTransparency = isSel and 0 or 1,
                        BorderSizePixel = 0,
                        ZIndex = 17,
                        Parent = pScroll,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = row })
                    if isSel then Gradient(row, C.Surface2, C.SurfaceHov, 90) end

                    local cb_box = Create("Frame", {
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = UDim2.new(0, 8, 0.5, -7),
                        BackgroundColor3 = isSel and C.Accent or C.ToggleOff,
                        BorderSizePixel = 0,
                        ZIndex = 18,
                        Parent = row,
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = cb_box })
                    if isSel then Gradient(cb_box, C.Accent2, C.Accent, 135) end

                    if isSel then
                        local ck = Icon(cb_box, "check", 10, C.White, UDim2.new(0.5, -5, 0.5, -5))
                        ck.ZIndex = 19
                    end

                    Create("TextLabel", {
                        Size = UDim2.new(1, -30, 1, 0),
                        Position = UDim2.new(0, 28, 0, 0),
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = isSel and C.AccentGlow or C.TextDim,
                        TextSize = isMobile and 10 or 12,
                        Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham,
                        ZIndex = 18,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = row,
                    })

                    local hit = Create("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        ZIndex = 20,
                        Parent = row,
                    })
                    hit.MouseButton1Click:Connect(function()
                        if sel[opt] then sel[opt] = nil else sel[opt] = true end
                        UpdCount()
                        cb(GetList())
                        Populate()
                    end)
                end
            end
            Populate()

            local clickBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, ELEM_H),
                BackgroundTransparency = 1,
                Text = "",
                Parent = frame,
            })
            clickBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local ph = math.min(#opts * 32 + 8, 155)
                    panel.Visible = true
                    Tween(panel, { Size = UDim2.new(1, 0, 0, ph) }, 0.18)
                    arrow.Image = LucideIcons and LucideIcons["chevron-up"] or ""
                else
                    Tween(panel, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                    task.wait(0.16)
                    panel.Visible = false
                    arrow.Image = LucideIcons and LucideIcons["chevron-down"] or ""
                end
            end)

            frame.Parent = parent
            return { GetValue = GetList }
        end

        if tType == "Normal" then
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, ELEM_PAD),
                Parent = content,
            })
            Create("UIPadding", {
                PaddingTop    = UDim.new(0, CONT_PAD),
                PaddingLeft   = UDim.new(0, CONT_PAD),
                PaddingRight  = UDim.new(0, CONT_PAD),
                PaddingBottom = UDim.new(0, CONT_PAD),
                Parent = content,
            })

            local api = {}
            function api:AddToggle(cfg)        return BuildToggle(cfg, content) end
            function api:AddSlider(cfg)        return BuildSlider(cfg, content) end
            function api:AddDropdown(cfg)      return BuildDropdown(cfg, content) end
            function api:AddMultiDropdown(cfg) return BuildMultiDropdown(cfg, content) end

            table.insert(tabs, tabObj)
            if #tabs == 1 then SetActive(tabObj) end
            return api

        elseif tType == "Groupbox" then
            local gbWrap = Create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Parent = content,
            })
            Create("UIPadding", {
                PaddingTop    = UDim.new(0, CONT_PAD),
                PaddingLeft   = UDim.new(0, CONT_PAD),
                PaddingRight  = UDim.new(0, CONT_PAD),
                PaddingBottom = UDim.new(0, CONT_PAD),
                Parent = gbWrap,
            })

            local function MakeGroupbox(side, gc)
                gc = gc or {}
                local isLeft = side == "Left"
                local gb = Create("Frame", {
                    Size = UDim2.new(0.5, isLeft and -5 or -5, 1, -4),
                    Position = isLeft and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, 4, 0, 0),
                    BackgroundColor3 = C.GroupBG,
                    BorderSizePixel = 0,
                    Parent = gbWrap,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = gb })
                Gradient(gb, C.GroupBG, C.GroupBG2, 145)
                Create("UIStroke", { Color = C.GroupBorder, Thickness = 1, Parent = gb })

                local header = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = C.Surface,
                    BackgroundTransparency = 0.6,
                    BorderSizePixel = 0,
                    Parent = gb,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = header })

                local headerFix = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 1, -12),
                    BackgroundColor3 = C.Surface,
                    BackgroundTransparency = 0.6,
                    BorderSizePixel = 0,
                    Parent = header,
                })

                local ico = Icon(header, gc.Icon or "box", 13, C.Accent, UDim2.new(0, 10, 0.5, -6))

                Create("TextLabel", {
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 27, 0, 0),
                    BackgroundTransparency = 1,
                    Text = gc.Title or "Group",
                    TextColor3 = C.Text,
                    TextSize = isMobile and 10 or 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = header,
                })

                local divLine = Create("Frame", {
                    Size = UDim2.new(1, -18, 0, 1),
                    Position = UDim2.new(0, 9, 0, 32),
                    BackgroundColor3 = C.Divider2,
                    BorderSizePixel = 0,
                    Parent = gb,
                })
                Gradient(divLine, C.Accent, C.Divider2, 0)

                local scroll = Create("ScrollingFrame", {
                    Size = UDim2.new(1, -8, 1, -42),
                    Position = UDim2.new(0, 4, 0, 38),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = C.ScrollBar,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = gb,
                })
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, ELEM_PAD - 2), Parent = scroll })
                Create("UIPadding", {
                    PaddingTop    = UDim.new(0, 4),
                    PaddingLeft   = UDim.new(0, 3),
                    PaddingRight  = UDim.new(0, 3),
                    PaddingBottom = UDim.new(0, 4),
                    Parent = scroll,
                })

                local gbApi = {}
                function gbApi:AddToggle(cfg)        return BuildToggle(cfg, scroll) end
                function gbApi:AddSlider(cfg)        return BuildSlider(cfg, scroll) end
                function gbApi:AddDropdown(cfg)      return BuildDropdown(cfg, scroll) end
                function gbApi:AddMultiDropdown(cfg) return BuildMultiDropdown(cfg, scroll) end
                return gbApi
            end

            local gbInterface = {}
            function gbInterface:AddLeftGroupbox(gc)  return MakeGroupbox("Left", gc) end
            function gbInterface:AddRightGroupbox(gc) return MakeGroupbox("Right", gc) end

            table.insert(tabs, tabObj)
            if #tabs == 1 then SetActive(tabObj) end
            return gbInterface
        end
    end

    return window
end

return SurixUiLibs
