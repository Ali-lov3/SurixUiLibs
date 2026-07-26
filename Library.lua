if getgenv().SurixUiLibs and getgenv().SurixUiLibs._Destroy then
    pcall(getgenv().SurixUiLibs._Destroy)
end

local SurixUiLibs = {}
getgenv().SurixUiLibs = SurixUiLibs

local Players         = game:GetService("Players")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local isMobile    = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Lucide.lua"))()

local T = {
    Background  = Color3.fromRGB(20, 21, 27),
    Panel       = Color3.fromRGB(25, 27, 34),
    Sidebar     = Color3.fromRGB(16, 17, 22),
    SidebarTab  = Color3.fromRGB(22, 24, 31),
    Element     = Color3.fromRGB(30, 32, 42),
    ElementHov  = Color3.fromRGB(38, 41, 54),
    Header      = Color3.fromRGB(18, 19, 25),
    Stroke      = Color3.fromRGB(42, 45, 60),
    StrokeBright= Color3.fromRGB(60, 65, 88),
    Accent      = Color3.fromRGB(82, 120, 255),
    AccentDim   = Color3.fromRGB(50, 80, 200),
    AccentBright= Color3.fromRGB(130, 165, 255),
    AccentFade  = Color3.fromRGB(82, 120, 255),
    ToggleOff   = Color3.fromRGB(38, 40, 54),
    ToggleOn    = Color3.fromRGB(82, 120, 255),
    Text        = Color3.fromRGB(230, 232, 245),
    TextDim     = Color3.fromRGB(155, 160, 188),
    TextSub     = Color3.fromRGB(85, 90, 120),
    White       = Color3.fromRGB(255, 255, 255),
    Black       = Color3.fromRGB(0, 0, 0),
    Red         = Color3.fromRGB(255, 80, 80),
    Yellow      = Color3.fromRGB(255, 190, 40),
    Green       = Color3.fromRGB(50, 205, 90),
    DropBG      = Color3.fromRGB(18, 19, 26),
    DropItem    = Color3.fromRGB(28, 30, 40),
    DropHov     = Color3.fromRGB(36, 39, 52),
    GroupBG     = Color3.fromRGB(22, 23, 31),
    GroupHeader = Color3.fromRGB(27, 29, 39),
}

local SIDEBAR_W = isMobile and 108 or 146
local TITLE_H   = 40
local TAB_H     = isMobile and 36 or 42
local ELEM_H    = 34
local GAP       = 6
local PAD       = 10
local W         = isMobile and 540 or 660
local H         = isMobile and 280 or 430

local _connections = {}
local _threads     = {}

SurixUiLibs._Destroy = function()
    for _, c in ipairs(_connections) do pcall(function() c:Disconnect() end) end
    for _, t in ipairs(_threads) do pcall(function() task.cancel(t) end) end
end

local function conn(signal, fn)
    local c = signal:Connect(fn)
    table.insert(_connections, c)
    return c
end

local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function Corner(r, parent)
    return New("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local function Stroke(col, thick, parent, trans)
    return New("UIStroke", {
        Color = col or T.Stroke,
        Thickness = thick or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function Grad(c1, c2, rot, parent)
    return New("UIGradient", {
        Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2) }),
        Rotation = rot or 90,
    }, parent)
end

local function Tw(obj, props, t, sty, dir)
    TweenService:Create(obj, TweenInfo.new(t or 0.18, sty or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

local function Img(icon, size, color, parent)
    local img = New("ImageLabel", {
        Size = UDim2.new(0, size or 16, 0, size or 16),
        BackgroundTransparency = 1,
        Image = (Icons and Icons[icon]) or "",
        ImageColor3 = color or T.TextDim,
        ScaleType = Enum.ScaleType.Fit,
    }, parent)
    return img
end

local function Draggable(frame, handle)
    local dragging, start, origin = false, nil, nil
    conn(handle.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start    = i.Position
            origin   = frame.Position
        end
    end)
    conn(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            frame.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end)
    conn(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function ShowLoading(gui, logoId, title)
    local bg = New("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.fromRGB(12,12,16),
        BorderSizePixel = 0,
        ZIndex = 500,
    }, gui)

    local card = New("Frame", {
        Size = UDim2.new(0,220,0,120),
        Position = UDim2.new(0.5,-110,0.5,-60),
        BackgroundColor3 = T.Panel,
        BorderSizePixel = 0,
        ZIndex = 501,
    }, bg)
    Corner(14, card)
    Stroke(T.Accent, 1, card, 0.55)
    Grad(T.Panel, T.Element, 135, card)

    local logoHolder = New("Frame", {
        Size = UDim2.new(0,42,0,42),
        Position = UDim2.new(0.5,-21,0,16),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 502,
    }, card)
    Corner(10, logoHolder)
    Grad(T.AccentBright, T.AccentDim, 135, logoHolder)
    Stroke(T.AccentBright, 1, logoHolder, 0.4)

    if logoId and logoId ~= "" and logoId ~= "rbxassetid://0" then
        New("ImageLabel", {
            Size = UDim2.new(1,-6,1,-6),
            Position = UDim2.new(0,3,0,3),
            BackgroundTransparency = 1,
            Image = logoId,
            ZIndex = 503,
        }, logoHolder)
    else
        local dot = New("Frame", {
            Size = UDim2.new(0,16,0,16),
            Position = UDim2.new(0.5,-8,0.5,-8),
            BackgroundColor3 = T.White,
            BorderSizePixel = 0,
            ZIndex = 503,
        }, logoHolder)
        Corner(8, dot)
    end

    New("TextLabel", {
        Size = UDim2.new(1,-20,0,20),
        Position = UDim2.new(0,10,0,66),
        BackgroundTransparency = 1,
        Text = title or "SurixUiLibs",
        TextColor3 = T.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 502,
    }, card)

    local barBG = New("Frame", {
        Size = UDim2.new(0,188,0,3),
        Position = UDim2.new(0.5,-94,1,-12),
        BackgroundColor3 = T.Element,
        BorderSizePixel = 0,
        ZIndex = 502,
    }, card)
    Corner(3, barBG)

    local barFill = New("Frame", {
        Size = UDim2.new(0,0,1,0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 503,
    }, barBG)
    Corner(3, barFill)
    Grad(T.AccentBright, T.Accent, 0, barFill)

    Tw(barFill, {Size = UDim2.new(1,0,1,0)}, 1.35, Enum.EasingStyle.Quint)
    task.delay(1.65, function()
        Tw(bg, {BackgroundTransparency = 1}, 0.35)
        Tw(card, {BackgroundTransparency = 1}, 0.35)
        task.wait(0.38)
        bg:Destroy()
    end)
end

function SurixUiLibs:CreateWindow(cfg)
    cfg = cfg or {}
    local title   = cfg.Title or "SurixUiLibs"
    local logoId  = cfg.Logo  or ""
    local loading = cfg.Loading ~= false

    local gui = New("ScreenGui", {
        Name = "SurixUiLibs_"..title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    }, (gethui and gethui()) or LocalPlayer.PlayerGui)

    if loading then ShowLoading(gui, logoId, title) end

    local main = New("Frame", {
        Name = "Main",
        Size = UDim2.new(0,W,0,H),
        Position = UDim2.new(0.5,-W/2,0.5,-H/2),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, gui)
    Corner(12, main)
    Stroke(T.Stroke, 1, main)

    local shadow = New("ImageLabel", {
        Size = UDim2.new(1,60,1,60),
        Position = UDim2.new(0,-30,0,-30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7912134082",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(50,50,450,450),
        ZIndex = -1,
    }, main)

    local titleBar = New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1,0,0,TITLE_H),
        BackgroundColor3 = T.Header,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, main)
    Corner(12, titleBar)

    local tbFix = New("Frame", {
        Size = UDim2.new(1,0,0.5,0),
        Position = UDim2.new(0,0,0.5,0),
        BackgroundColor3 = T.Header,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, titleBar)

    local tbLine = New("Frame", {
        Size = UDim2.new(1,0,0,1),
        Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = T.Stroke,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, titleBar)
    Grad(T.Accent, T.Stroke, 0, tbLine)

    local logoBox = New("Frame", {
        Size = UDim2.new(0,26,0,26),
        Position = UDim2.new(0,12,0.5,-13),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, titleBar)
    Corner(7, logoBox)
    Grad(T.AccentBright, T.AccentDim, 135, logoBox)

    if logoId and logoId ~= "" and logoId ~= "rbxassetid://0" then
        New("ImageLabel", {
            Size = UDim2.new(1,-4,1,-4),
            Position = UDim2.new(0,2,0,2),
            BackgroundTransparency = 1,
            Image = logoId,
            ZIndex = 4,
        }, logoBox)
    else
        local ld = New("Frame", {
            Size = UDim2.new(0,10,0,10),
            Position = UDim2.new(0.5,-5,0.5,-5),
            BackgroundColor3 = T.White,
            BorderSizePixel = 0,
            ZIndex = 4,
        }, logoBox)
        Corner(5, ld)
    end

    New("TextLabel", {
        Size = UDim2.new(1,-180,1,0),
        Position = UDim2.new(0,46,0,0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = T.Text,
        TextSize = isMobile and 12 or 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, titleBar)

    local dotsHolder = New("Frame", {
        Size = UDim2.new(0,64,0,14),
        Position = UDim2.new(1,-76,0.5,-7),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, titleBar)

    local function Dot(x, col)
        local b = New("TextButton", {
            Size = UDim2.new(0,13,0,13),
            Position = UDim2.new(0,x,0.5,-6),
            BackgroundColor3 = col,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 4,
        }, dotsHolder)
        Corner(7, b)
        return b
    end
    local closeBtn = Dot(0,  T.Red)
    local minBtn   = Dot(18, T.Yellow)
    Dot(36, T.Green)

    Draggable(main, titleBar)

    local minimized = false
    local body

    conn(closeBtn.MouseButton1Click, function() main.Visible = false end)
    conn(minBtn.MouseButton1Click, function()
        minimized = not minimized
        Tw(main, { Size = minimized and UDim2.new(0,W,0,TITLE_H+1) or UDim2.new(0,W,0,H) }, 0.22, Enum.EasingStyle.Quint)
        if body then body.Visible = not minimized end
    end)

    body = New("Frame", {
        Name = "Body",
        Size = UDim2.new(1,0,1,-TITLE_H),
        Position = UDim2.new(0,0,0,TITLE_H),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 2,
    }, main)

    local sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0,SIDEBAR_W,1,0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, body)
    Corner(10, sidebar)
    New("Frame", {
        Size = UDim2.new(0,12,1,0),
        Position = UDim2.new(1,-12,0,0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, sidebar)

    local tabList = New("ScrollingFrame", {
        Size = UDim2.new(1,0,1,-8),
        Position = UDim2.new(0,0,0,8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
    }, sidebar)
    New("UIPadding", { PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6) }, tabList)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2) }, tabList)

    local sbLine = New("Frame", {
        Size = UDim2.new(0,1,0.75,0),
        Position = UDim2.new(1,0,0.125,0),
        BackgroundColor3 = T.Stroke,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, sidebar)
    Grad(Color3.fromRGB(0,0,0), T.StrokeBright, 90, sbLine)

    local contentArea = New("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1,-(SIDEBAR_W+1),1,0),
        Position = UDim2.new(0,SIDEBAR_W+1,0,0),
        BackgroundColor3 = T.Panel,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 2,
    }, body)
    Corner(10, contentArea)
    New("Frame", {
        Size = UDim2.new(0,12,1,0),
        BackgroundColor3 = T.Panel,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, contentArea)

    local dropOverlay = New("Frame", {
        Name = "DropOverlay",
        Size = UDim2.new(0,W,0,H),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 200,
    }, main)

    local tabs      = {}
    local activeTab = nil
    local openDropRef = nil

    local function CloseOpenDrop()
        if openDropRef then
            pcall(openDropRef)
            openDropRef = nil
        end
    end

    conn(UserInputService.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            CloseOpenDrop()
        end
    end)

    local function SetActive(tab)
        if activeTab == tab then return end
        CloseOpenDrop()
        if activeTab then
            Tw(activeTab._btn, { BackgroundTransparency = 1 }, 0.14)
            activeTab._accent.Size = UDim2.new(0,3,0,0)
            activeTab._label.TextColor3 = T.TextSub
            activeTab._label.Font = Enum.Font.Gotham
            if activeTab._ico then activeTab._ico.ImageColor3 = T.TextSub end
            activeTab._content.Visible = false
        end
        activeTab = tab
        Tw(tab._btn, { BackgroundTransparency = 0 }, 0.14)
        Tw(tab._accent, { Size = UDim2.new(0,3,0,TAB_H-16) }, 0.2)
        tab._label.TextColor3 = T.AccentBright
        tab._label.Font = Enum.Font.GothamBold
        if tab._ico then Tw(tab._ico, { ImageColor3 = T.AccentBright }, 0.14) end
        tab._content.Visible = true
    end

    local function MakeDropPanel(opts, currentSel, isMulti, selTable, cbClose, cbSelect, anchor)
        CloseOpenDrop()

        local absPos  = anchor.AbsolutePosition
        local absSize = anchor.AbsoluteSize
        local mainAbs = main.AbsolutePosition

        local relX = absPos.X - mainAbs.X
        local relY = absPos.Y - mainAbs.Y + absSize.Y + 4

        local panelH = math.min(#opts * 32 + 8, 160)
        local panelW = absSize.X

        local overflow = (relY + panelH) - H
        if overflow > 0 then
            relY = relY - absSize.Y - panelH - 8
        end

        local panel = New("Frame", {
            Name = "DropPanel",
            Size = UDim2.new(0,panelW,0,0),
            Position = UDim2.new(0,relX,0,relY),
            BackgroundColor3 = T.DropBG,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 200,
        }, dropOverlay)
        Corner(8, panel)
        Stroke(T.Accent, 1, panel, 0.65)

        local scroll = New("ScrollingFrame", {
            Size = UDim2.new(1,-6,1,-6),
            Position = UDim2.new(0,3,0,3),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = T.StrokeBright,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 201,
        }, panel)
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2) }, scroll)
        New("UIPadding", { PaddingTop = UDim.new(0,2), PaddingLeft = UDim.new(0,2), PaddingRight = UDim.new(0,2), PaddingBottom = UDim.new(0,2) }, scroll)

        local function Rebuild()
            for _, c in ipairs(scroll:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            for _, opt in ipairs(opts) do
                local isSel = isMulti and (selTable[opt] == true) or (not isMulti and currentSel == opt)
                local row = New("Frame", {
                    Name = opt,
                    Size = UDim2.new(1,0,0,30),
                    BackgroundColor3 = isSel and T.DropHov or T.DropItem,
                    BorderSizePixel = 0,
                    ZIndex = 202,
                }, scroll)
                Corner(6, row)
                if isSel then
                    Stroke(T.Accent, 1, row, 0.5)
                end

                if isMulti then
                    local cbBox = New("Frame", {
                        Size = UDim2.new(0,14,0,14),
                        Position = UDim2.new(0,8,0.5,-7),
                        BackgroundColor3 = isSel and T.Accent or T.Element,
                        BorderSizePixel = 0,
                        ZIndex = 203,
                    }, row)
                    Corner(4, cbBox)
                    if not isSel then Stroke(T.Stroke, 1, cbBox) end
                    if isSel then
                        local ck = Img("check", 10, T.White, cbBox)
                        ck.Position = UDim2.new(0.5,-5,0.5,-5)
                        ck.ZIndex = 204
                    end
                    New("TextLabel", {
                        Size = UDim2.new(1,-30,1,0),
                        Position = UDim2.new(0,28,0,0),
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = isSel and T.Text or T.TextDim,
                        TextSize = 12,
                        Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 203,
                    }, row)
                else
                    New("TextLabel", {
                        Size = UDim2.new(1,-36,1,0),
                        Position = UDim2.new(0,12,0,0),
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = isSel and T.Text or T.TextDim,
                        TextSize = 12,
                        Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 203,
                    }, row)
                    if isSel then
                        local ck = Img("check", 11, T.AccentBright, row)
                        ck.Position = UDim2.new(1,-21,0.5,-5)
                        ck.ZIndex = 203
                    end
                end

                local hit = New("TextButton", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 205,
                }, row)

                conn(hit.MouseEnter, function()
                    if not isSel then Tw(row, { BackgroundColor3 = T.DropHov }, 0.1) end
                end)
                conn(hit.MouseLeave, function()
                    if not isSel then Tw(row, { BackgroundColor3 = T.DropItem }, 0.1) end
                end)

                conn(hit.MouseButton1Click, function()
                    if isMulti then
                        if selTable[opt] then selTable[opt] = nil else selTable[opt] = true end
                        cbSelect()
                        Rebuild()
                    else
                        currentSel = opt
                        cbSelect(opt)
                        cbClose()
                    end
                end)
            end
        end
        Rebuild()

        Tw(panel, { Size = UDim2.new(0,panelW,0,panelH) }, 0.18, Enum.EasingStyle.Quint)

        local closed = false
        local function Close()
            if closed then return end
            closed = true
            Tw(panel, { Size = UDim2.new(0,panelW,0,0) }, 0.14, Enum.EasingStyle.Quint)
            task.wait(0.15)
            if panel and panel.Parent then panel:Destroy() end
        end

        openDropRef = Close
        return Close
    end

    local function MakeAPI(scroll, isGroupbox)
        local function ElemFrame(h)
            local f = New("Frame", {
                Size = UDim2.new(1,0,0,h or ELEM_H),
                BackgroundColor3 = T.Element,
                BorderSizePixel = 0,
            }, scroll)
            Corner(8, f)
            Stroke(T.Stroke, 1, f)
            return f
        end

        local labelSize = isGroupbox and UDim2.new(0.52,0,1,0) or UDim2.new(0.52,0,1,0)

        local function ELabel(parent, text)
            return New("TextLabel", {
                Size = labelSize,
                Position = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = T.TextDim,
                TextSize = isMobile and 11 or 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, parent)
        end

        local api = {}

        function api:AddToggle(cfg)
            cfg = cfg or {}
            local state = cfg.Default or false
            local cb    = cfg.Callback or function() end

            local f = ElemFrame()
            ELabel(f, cfg.Label or "Toggle")

            local track = New("Frame", {
                Size = UDim2.new(0,38,0,20),
                Position = UDim2.new(1,-50,0.5,-10),
                BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
                BorderSizePixel = 0,
            }, f)
            Corner(10, track)

            if state then
                Grad(T.AccentBright, T.AccentDim, 0, track)
            end
            Stroke(state and T.Accent or T.Stroke, 1, track)

            local thumb = New("Frame", {
                Size = UDim2.new(0,14,0,14),
                Position = UDim2.new(0,state and 21 or 3,0.5,-7),
                BackgroundColor3 = T.White,
                BorderSizePixel = 0,
            }, track)
            Corner(7, thumb)

            local function SetState(v)
                state = v
                Tw(track, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff }, 0.18)
                Tw(thumb, { Position = UDim2.new(0, state and 21 or 3, 0.5, -7) }, 0.18)
                Tw(track.UIStroke, { Color = state and T.Accent or T.Stroke }, 0.18)
                if state then
                    Grad(T.AccentBright, T.AccentDim, 0, track)
                else
                    for _, g in ipairs(track:GetChildren()) do if g:IsA("UIGradient") then g:Destroy() end end
                end
            end

            local btn = New("TextButton", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text = "",
            }, f)
            conn(btn.MouseButton1Click, function()
                SetState(not state)
                cb(state)
            end)
            conn(btn.MouseEnter, function() Tw(f, { BackgroundColor3 = T.ElementHov }, 0.1) end)
            conn(btn.MouseLeave, function() Tw(f, { BackgroundColor3 = T.Element    }, 0.1) end)

            return {
                GetValue = function() return state end,
                SetValue = function(v) SetState(v) cb(v) end,
            }
        end

        function api:AddSlider(cfg)
            cfg = cfg or {}
            local min = cfg.Min     or 0
            local max = cfg.Max     or 100
            local cur = math.clamp(cfg.Default or min, min, max)
            local cb  = cfg.Callback or function() end

            local f = ElemFrame(ELEM_H + 10)
            ELabel(f, cfg.Label or "Slider")

            local valLbl = New("TextLabel", {
                Size = UDim2.new(0.42,-12,0,18),
                Position = UDim2.new(0.52,0,0,8),
                BackgroundTransparency = 1,
                Text = tostring(cur),
                TextColor3 = T.AccentBright,
                TextSize = isMobile and 11 or 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, f)

            local trackBG = New("Frame", {
                Size = UDim2.new(1,-24,0,4),
                Position = UDim2.new(0,12,0,ELEM_H),
                BackgroundColor3 = T.Header,
                BorderSizePixel = 0,
            }, f)
            Corner(3, trackBG)
            Stroke(T.Stroke, 1, trackBG)

            local pct = (cur - min) / (max - min)

            local fill = New("Frame", {
                Size = UDim2.new(pct,0,1,0),
                BackgroundColor3 = T.Accent,
                BorderSizePixel = 0,
            }, trackBG)
            Corner(3, fill)
            Grad(T.AccentBright, T.Accent, 0, fill)

            local knob = New("Frame", {
                Size = UDim2.new(0,14,0,14),
                Position = UDim2.new(pct,-7,0.5,-7),
                BackgroundColor3 = T.White,
                BorderSizePixel = 0,
            }, trackBG)
            Corner(7, knob)
            Stroke(T.Accent, 2, knob)

            local dragging = false
            local function Upd(pos)
                local a, s = trackBG.AbsolutePosition, trackBG.AbsoluteSize
                local rx = math.clamp((pos.X - a.X) / s.X, 0, 1)
                local v  = math.floor(min + rx * (max - min) + 0.5)
                local vp = (v - min) / (max - min)
                cur = v
                fill.Size = UDim2.new(vp,0,1,0)
                knob.Position = UDim2.new(vp,-7,0.5,-7)
                valLbl.Text = tostring(v)
                cb(v)
            end

            local hitbox = New("TextButton", {
                Size = UDim2.new(1,0,0,28),
                Position = UDim2.new(0,0,0.5,-14),
                BackgroundTransparency = 1,
                Text = "",
            }, trackBG)
            conn(hitbox.InputBegan, function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Upd(i.Position)
                    Tw(knob, { Size = UDim2.new(0,16,0,16) }, 0.1)
                    knob.Position = UDim2.new(pct,-8,0.5,-8)
                end
            end)
            conn(UserInputService.InputChanged, function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    Upd(i.Position)
                end
            end)
            conn(UserInputService.InputEnded, function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    Tw(knob, { Size = UDim2.new(0,14,0,14) }, 0.1)
                end
            end)

            conn(f.MouseEnter, function() Tw(f, { BackgroundColor3 = T.ElementHov }, 0.1) end)
            conn(f.MouseLeave, function() Tw(f, { BackgroundColor3 = T.Element    }, 0.1) end)

            return {
                GetValue = function() return cur end,
                SetValue = function(v)
                    v = math.clamp(v, min, max)
                    local vp = (v - min) / (max - min)
                    cur = v
                    fill.Size = UDim2.new(vp,0,1,0)
                    knob.Position = UDim2.new(vp,-7,0.5,-7)
                    valLbl.Text = tostring(v)
                    cb(v)
                end,
            }
        end

        function api:AddDropdown(cfg)
            cfg = cfg or {}
            local opts = cfg.Options or {}
            local sel  = cfg.Default or opts[1] or ""
            local cb   = cfg.Callback or function() end
            local isOpen = false
            local closeRef = nil

            local f = ElemFrame()
            ELabel(f, cfg.Label or "Dropdown")

            local selLbl = New("TextLabel", {
                Size = UDim2.new(0.42,-24,1,0),
                Position = UDim2.new(0.52,0,0,0),
                BackgroundTransparency = 1,
                Text = sel,
                TextColor3 = T.AccentBright,
                TextSize = isMobile and 10 or 12,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, f)

            local arrow = Img("chevron-down", 13, T.TextSub, f)
            arrow.Position = UDim2.new(1,-21,0.5,-6)

            local btn = New("TextButton", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text = "",
            }, f)
            conn(btn.MouseEnter, function() Tw(f, { BackgroundColor3 = T.ElementHov }, 0.1) end)
            conn(btn.MouseLeave, function() Tw(f, { BackgroundColor3 = T.Element    }, 0.1) end)

            conn(btn.MouseButton1Click, function()
                if isOpen then
                    isOpen = false
                    Tw(arrow, { Rotation = 0 }, 0.15)
                    if closeRef then closeRef() closeRef = nil end
                    return
                end
                isOpen = true
                Tw(arrow, { Rotation = 180 }, 0.15)
                closeRef = MakeDropPanel(
                    opts,
                    sel,
                    false,
                    {},
                    function()
                        isOpen = false
                        Tw(arrow, { Rotation = 0 }, 0.15)
                        closeRef = nil
                    end,
                    function(picked)
                        sel = picked
                        selLbl.Text = picked
                        cb(picked)
                    end,
                    f
                )
                local origClose = closeRef
                openDropRef = function()
                    isOpen = false
                    Tw(arrow, { Rotation = 0 }, 0.15)
                    closeRef = nil
                    origClose()
                end
            end)

            return {
                GetValue = function() return sel end,
                SetOptions = function(newOpts)
                    opts = newOpts
                    sel = newOpts[1] or ""
                    selLbl.Text = sel
                end,
            }
        end

        function api:AddMultiDropdown(cfg)
            cfg = cfg or {}
            local opts = cfg.Options or {}
            local cb   = cfg.Callback or function() end
            local sel  = {}
            for _, v in ipairs(cfg.Default or {}) do sel[v] = true end
            local isOpen = false
            local closeRef = nil

            local f = ElemFrame()
            ELabel(f, cfg.Label or "Multi-Select")

            local cntLbl = New("TextLabel", {
                Size = UDim2.new(0.42,-24,1,0),
                Position = UDim2.new(0.52,0,0,0),
                BackgroundTransparency = 1,
                TextColor3 = T.AccentBright,
                TextSize = isMobile and 10 or 12,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, f)

            local function GetList()
                local t = {}
                for k in pairs(sel) do table.insert(t, k) end
                return t
            end
            local function UpdateLabel()
                local n = 0
                for _ in pairs(sel) do n = n + 1 end
                cntLbl.Text = n > 0 and (n .. " selected") or "None"
            end
            UpdateLabel()

            local arrow = Img("chevron-down", 13, T.TextSub, f)
            arrow.Position = UDim2.new(1,-21,0.5,-6)

            local btn = New("TextButton", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text = "",
            }, f)
            conn(btn.MouseEnter, function() Tw(f, { BackgroundColor3 = T.ElementHov }, 0.1) end)
            conn(btn.MouseLeave, function() Tw(f, { BackgroundColor3 = T.Element    }, 0.1) end)

            conn(btn.MouseButton1Click, function()
                if isOpen then
                    isOpen = false
                    Tw(arrow, { Rotation = 0 }, 0.15)
                    if closeRef then closeRef() closeRef = nil end
                    return
                end
                isOpen = true
                Tw(arrow, { Rotation = 180 }, 0.15)
                closeRef = MakeDropPanel(
                    opts,
                    nil,
                    true,
                    sel,
                    function()
                        isOpen = false
                        Tw(arrow, { Rotation = 0 }, 0.15)
                        closeRef = nil
                    end,
                    function()
                        UpdateLabel()
                        cb(GetList())
                    end,
                    f
                )
                local origClose = closeRef
                openDropRef = function()
                    isOpen = false
                    Tw(arrow, { Rotation = 0 }, 0.15)
                    closeRef = nil
                    origClose()
                end
            end)

            return { GetValue = GetList }
        end

        return api
    end

    local mobileBtn = nil
    if isMobile then
        mobileBtn = New("TextButton", {
            Name = "MobileToggle",
            Size = UDim2.new(0,28,0,70),
            Position = UDim2.new(0,0,0.5,-35),
            BackgroundColor3 = T.Accent,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 300,
        }, gui)
        Corner(8, mobileBtn)
        Grad(T.AccentBright, T.AccentDim, 90, mobileBtn)
        Stroke(T.AccentBright, 1, mobileBtn, 0.4)

        local ch = Img("chevron-right", 13, T.White, mobileBtn)
        ch.Position = UDim2.new(0.5,-6,0.5,-6)
        ch.ZIndex = 301

        Draggable(mobileBtn, mobileBtn)

        local vis = true
        conn(mobileBtn.MouseButton1Click, function()
            vis = not vis
            main.Visible = vis
            ch.Image = Icons and Icons[vis and "chevron-left" or "chevron-right"] or ""
        end)
    end

    local window = {}

    function window:AddTab(tc)
        tc = tc or {}
        local name = tc.Name or "Tab"
        local icon = tc.Icon or "layout-dashboard"
        local typ  = tc.Type or "Normal"

        local btn = New("TextButton", {
            Size = UDim2.new(1,0,0,TAB_H),
            BackgroundColor3 = T.SidebarTab,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 4,
        }, tabList)
        Corner(8, btn)

        local accent = New("Frame", {
            Size = UDim2.new(0,3,0,0),
            Position = UDim2.new(0,-1,0.5,0),
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundColor3 = T.Accent,
            BorderSizePixel = 0,
            ZIndex = 5,
        }, btn)
        Corner(3, accent)
        Grad(T.AccentBright, T.AccentDim, 90, accent)

        local ico = Img(icon, isMobile and 14 or 15, T.TextSub, btn)
        ico.Position = UDim2.new(0,10,0.5,-(isMobile and 7 or 7))
        ico.ZIndex = 5

        local lbl = New("TextLabel", {
            Size = UDim2.new(1,-34,1,0),
            Position = UDim2.new(0,30,0,0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = T.TextSub,
            TextSize = isMobile and 11 or 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
        }, btn)

        local content = New("ScrollingFrame", {
            Name = name.."Content",
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = T.StrokeBright,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ClipsDescendants = false,
            ZIndex = 3,
        }, contentArea)

        local tabObj = { _btn = btn, _accent = accent, _label = lbl, _ico = ico, _content = content, _type = typ }

        conn(btn.MouseButton1Click, function() SetActive(tabObj) end)
        conn(btn.MouseEnter, function()
            if activeTab ~= tabObj then Tw(btn, { BackgroundTransparency = 0.5 }, 0.12) end
        end)
        conn(btn.MouseLeave, function()
            if activeTab ~= tabObj then Tw(btn, { BackgroundTransparency = 1 }, 0.12) end
        end)

        local result

        if typ == "Normal" then
            New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,GAP) }, content)
            New("UIPadding", {
                PaddingTop    = UDim.new(0,PAD),
                PaddingLeft   = UDim.new(0,PAD),
                PaddingRight  = UDim.new(0,PAD),
                PaddingBottom = UDim.new(0,PAD),
            }, content)

            result = MakeAPI(content, false)

        elseif typ == "Groupbox" then
            local wrap = New("Frame", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                ClipsDescendants = false,
                ZIndex = 3,
            }, content)
            New("UIPadding", {
                PaddingTop    = UDim.new(0,PAD),
                PaddingLeft   = UDim.new(0,PAD),
                PaddingRight  = UDim.new(0,PAD),
                PaddingBottom = UDim.new(0,PAD),
            }, wrap)

            local function MakeGB(side, gc)
                gc = gc or {}
                local isLeft = side == "Left"

                local gb = New("Frame", {
                    Size = UDim2.new(0.5, isLeft and -5 or -5, 1, -4),
                    Position = isLeft and UDim2.new(0,0,0,0) or UDim2.new(0.5,4,0,0),
                    BackgroundColor3 = T.GroupBG,
                    BorderSizePixel = 0,
                    ClipsDescendants = false,
                    ZIndex = 3,
                }, wrap)
                Corner(10, gb)
                Stroke(T.Stroke, 1, gb)

                local hdr = New("Frame", {
                    Size = UDim2.new(1,0,0,32),
                    BackgroundColor3 = T.GroupHeader,
                    BorderSizePixel = 0,
                    ZIndex = 4,
                }, gb)
                Corner(10, hdr)
                New("Frame", {
                    Size = UDim2.new(1,0,0.5,0),
                    Position = UDim2.new(0,0,0.5,0),
                    BackgroundColor3 = T.GroupHeader,
                    BorderSizePixel = 0,
                    ZIndex = 4,
                }, hdr)

                local hdrLine = New("Frame", {
                    Size = UDim2.new(1,-16,0,1),
                    Position = UDim2.new(0,8,1,-1),
                    BackgroundColor3 = T.Stroke,
                    BorderSizePixel = 0,
                    ZIndex = 5,
                }, hdr)
                Grad(T.Accent, T.Stroke, 0, hdrLine)

                local hIco = Img(gc.Icon or "box", 13, T.Accent, hdr)
                hIco.Position = UDim2.new(0,10,0.5,-6)
                hIco.ZIndex = 5

                New("TextLabel", {
                    Size = UDim2.new(1,-30,1,0),
                    Position = UDim2.new(0,27,0,0),
                    BackgroundTransparency = 1,
                    Text = gc.Title or "Group",
                    TextColor3 = T.Text,
                    TextSize = isMobile and 10 or 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                }, hdr)

                local sc = New("ScrollingFrame", {
                    Size = UDim2.new(1,-8,1,-40),
                    Position = UDim2.new(0,4,0,36),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = T.StrokeBright,
                    CanvasSize = UDim2.new(0,0,0,0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ClipsDescendants = false,
                    ZIndex = 4,
                }, gb)
                New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,GAP-2) }, sc)
                New("UIPadding", {
                    PaddingTop    = UDim.new(0,5),
                    PaddingLeft   = UDim.new(0,4),
                    PaddingRight  = UDim.new(0,4),
                    PaddingBottom = UDim.new(0,5),
                }, sc)

                return MakeAPI(sc, true)
            end

            result = {
                AddLeftGroupbox  = function(_, gc) return MakeGB("Left",  gc) end,
                AddRightGroupbox = function(_, gc) return MakeGB("Right", gc) end,
            }
        end

        table.insert(tabs, tabObj)
        if #tabs == 1 then SetActive(tabObj) end

        return result
    end

    return window
end

return SurixUiLibs
