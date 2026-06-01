--[[
   ╔══════════════════════════════════════════════════════════════════╗
   ║                        S T U D I O L I B                        ║
   ║           A blocky, pixel-perfect Roblox UI Library             ║
   ║                    by StudioLib Contributors                    ║
   ║ https://github.com/MizunoSync/StudioUILibrary/                  ║
   ╚══════════════════════════════════════════════════════════════════╝

   USAGE EXAMPLE:
   ──────────────
   local SL = require(game.ReplicatedStorage.StudioLib)

   local win = SL:CreateWindow({
       Title = "My Plugin",
       Width = 380,
       Height = 500,
   })

   local section = win:AddSection("Settings")
   section:AddButton("Click Me", function() print("Clicked!") end)
   section:AddToggle("Enable Feature", false, function(v) print(v) end)
   section:AddSlider("Speed", { Min=0, Max=100, Default=50 }, function(v) print(v) end)
   section:AddInput("Username", "Enter name...", function(v) print(v) end)
   section:AddDropdown("Mode", {"Easy","Medium","Hard"}, "Easy", function(v) print(v) end)
   section:AddColorPicker("Color", Color3.fromRGB(255,80,80), function(v) print(v) end)
   section:AddKeybind("Open GUI", Enum.KeyCode.RightShift, function() end)
   section:AddLabel("This is a label.")
   section:AddSeparator()
   section:AddParagraph("Info", "This is a description paragraph.")

   MIT License — free to use, modify, and distribute.
]]

-- ──────────────────────────────────────────────────────────────────
-- SERVICES
-- ──────────────────────────────────────────────────────────────────
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer       = Players.LocalPlayer
local Mouse             = LocalPlayer:GetMouse()

-- ──────────────────────────────────────────────────────────────────
-- THEME  (blocky, pixel-art inspired palette)
-- ──────────────────────────────────────────────────────────────────
local Theme = {
    -- Backgrounds
    BG_Dark         = Color3.fromRGB(18,  18,  22 ),   -- deepest bg
    BG_Base         = Color3.fromRGB(24,  24,  30 ),   -- window bg
    BG_Surface      = Color3.fromRGB(32,  32,  40 ),   -- section bg
    BG_Surface2     = Color3.fromRGB(38,  38,  48 ),   -- element bg
    BG_Elevated     = Color3.fromRGB(44,  44,  56 ),   -- hover bg
    BG_Input        = Color3.fromRGB(14,  14,  18 ),   -- input bg

    -- Borders (blocky 1-2px, no radius)
    Border          = Color3.fromRGB(55,  55,  70 ),
    BorderBright    = Color3.fromRGB(75,  75,  95 ),
    BorderAccent    = Color3.fromRGB(90,  120, 210),

    -- Accent
    Accent          = Color3.fromRGB(80,  130, 255),   -- primary blue
    AccentHover     = Color3.fromRGB(100, 150, 255),
    AccentDim       = Color3.fromRGB(40,  70,  160),
    AccentSuccess   = Color3.fromRGB(60,  200, 100),
    AccentDanger    = Color3.fromRGB(220, 70,  70 ),
    AccentWarning   = Color3.fromRGB(220, 170, 50 ),

    -- Text
    TextPrimary     = Color3.fromRGB(230, 230, 235),
    TextSecondary   = Color3.fromRGB(150, 150, 165),
    TextMuted       = Color3.fromRGB(90,  90,  105),
    TextInverse     = Color3.fromRGB(12,  12,  18 ),
    TextAccent      = Color3.fromRGB(120, 165, 255),

    -- Titlebar
    TitleBG         = Color3.fromRGB(18,  18,  26 ),
    TitleText       = Color3.fromRGB(210, 215, 255),

    -- Toggle
    ToggleOff       = Color3.fromRGB(50,  50,  65 ),
    ToggleOn        = Color3.fromRGB(60,  120, 240),
    ToggleKnob      = Color3.fromRGB(230, 230, 240),

    -- Scrollbar
    ScrollTrack     = Color3.fromRGB(28,  28,  36 ),
    ScrollThumb     = Color3.fromRGB(65,  65,  85 ),

    -- Font (pixelated, bold)
    Font            = Enum.Font.GothamBold,
    FontMono        = Enum.Font.RobotoMono,
    FontUI          = Enum.Font.GothamBold,

    -- Sizes
    TitleBarH       = 32,
    TabBarH         = 34,
    ElementH        = 36,
    SectionPadding  = 8,
    ElementPad      = 6,
    BorderWidth     = 2,   -- blocky borders
    CornerRadius    = 0,   -- BLOCKY = no radius
}

-- ──────────────────────────────────────────────────────────────────
-- UTILITY HELPERS
-- ──────────────────────────────────────────────────────────────────
local function Tween(instance: Instance, props: {}, duration: number?, style?)
    local ti = TweenInfo.new(
        duration or 0.12,
        style or Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    TweenService:Create(instance, ti, props):Play()
end

local function CreateInstance(className: string, props: {}, parent: Instance?): Instance
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

-- Pixel-perfect UIStroke (blocky border)
local function AddBorder(parent: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
    return CreateInstance("UIStroke", {
        Color        = color or Theme.Border,
        Thickness    = thickness or Theme.BorderWidth,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent) :: UIStroke
end

-- Zero-radius corner (fully blocky)
local function AddCorner(parent: Instance, radius: number?): UICorner
    return CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or Theme.CornerRadius),
    }, parent) :: UICorner
end

local function AddPadding(parent: Instance, all: number?, x: number?, y: number?): UIPadding
    local px = x or all or 8
    local py = y or all or 8
    return CreateInstance("UIPadding", {
        PaddingLeft   = UDim.new(0, px),
        PaddingRight  = UDim.new(0, px),
        PaddingTop    = UDim.new(0, py),
        PaddingBottom = UDim.new(0, py),
    }, parent) :: UIPadding
end

local function AddListLayout(parent: Instance, spacing: number?, dir?, ha?, va?): UIListLayout
    return CreateInstance("UIListLayout", {
        SortOrder      = Enum.SortOrder.LayoutOrder,
        FillDirection  = dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va or Enum.VerticalAlignment.Top,
        Padding        = UDim.new(0, spacing or 0),
    }, parent) :: UIListLayout
end

-- Inset pixel shadow effect via a darker Frame offset
local function AddPixelShadow(parent: Instance, offset: number?)
    local off = offset or 3
    local shadow = CreateInstance("Frame", {
        Name = "PixelShadow",
        Size = UDim2.new(1, off, 1, off),
        Position = UDim2.new(0, off, 0, off),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        ZIndex = parent.ZIndex - 1,
        BorderSizePixel = 0,
    }, parent.Parent)
    return shadow
end

-- Auto-resize a frame to fit its UIListLayout children
local function AutoSizeY(frame: Frame, layout: UIListLayout)
    local function update()
        frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, layout.AbsoluteContentSize.Y)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

-- ──────────────────────────────────────────────────────────────────
-- DRAGGING LOGIC
-- ──────────────────────────────────────────────────────────────────
local function MakeDraggable(handle: Frame, target: Frame)
    local dragging, dragInput, startPos, startFramePos = false, nil, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
            startFramePos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - startPos
            target.Position = UDim2.new(
                startFramePos.X.Scale,
                startFramePos.X.Offset + delta.X,
                startFramePos.Y.Scale,
                startFramePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ──────────────────────────────────────────────────────────────────
-- NOTIFICATION SYSTEM
-- ──────────────────────────────────────────────────────────────────
local NotifContainer: Frame
local function EnsureNotifContainer()
    if NotifContainer and NotifContainer.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "SL_Notifications"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 9999
    sg.Parent = CoreGui

    NotifContainer = CreateInstance("Frame", {
        Name = "NotifHolder",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 300, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, sg)

    local layout = AddListLayout(NotifContainer, 6)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end

-- ──────────────────────────────────────────────────────────────────
-- MAIN LIBRARY TABLE
-- ──────────────────────────────────────────────────────────────────
local StudioLib = {}
StudioLib.__index = StudioLib

-- ── NOTIFICATION ────────────────────────────────────────────────
function StudioLib:Notify(options: {
    Title: string?,
    Message: string,
    Type: string?,   -- "info" | "success" | "warning" | "error"
    Duration: number?,
})
    EnsureNotifContainer()
    local ntype    = (options.Type or "info"):lower()
    local duration = options.Duration or 4
    local title    = options.Title or ({
        info    = "ℹ  Info",
        success = "✔  Success",
        warning = "⚠  Warning",
        error   = "✖  Error",
    })[ntype] or "Notice"

    local accentMap = {
        info    = Theme.Accent,
        success = Theme.AccentSuccess,
        warning = Theme.AccentWarning,
        error   = Theme.AccentDanger,
    }
    local accent = accentMap[ntype] or Theme.Accent

    -- Card
    local card = CreateInstance("Frame", {
        Name = "Notif_" .. tick(),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.BG_Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, NotifContainer)
    AddBorder(card, accent, 2)

    -- Left accent bar
    CreateInstance("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
    }, card)

    local content = CreateInstance("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -4, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, card)
    AddPadding(content, nil, 10, 8)

    local vLayout = AddListLayout(content, 4)
    _ = vLayout

    -- Title row
    local titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = accent,
        TextSize = 13,
        Font = Theme.FontUI,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, content)
    _ = titleLabel

    -- Message
    local msgLabel = CreateInstance("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = options.Message,
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    }, content)
    _ = msgLabel

    -- Progress bar (bottom of card)
    local progressBG = CreateInstance("Frame", {
        Name = "ProgressBG",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.BG_Dark,
        BorderSizePixel = 0,
    }, card)
    _ = progressBG

    local progressFill = CreateInstance("Frame", {
        Name = "Fill",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
    }, progressBG)

    -- Animate progress
    Tween(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

    -- Auto destroy
    task.delay(duration, function()
        Tween(card, { BackgroundTransparency = 1 }, 0.3)
        task.wait(0.3)
        card:Destroy()
    end)
end

-- ──────────────────────────────────────────────────────────────────
-- WINDOW CONSTRUCTOR
-- ──────────────────────────────────────────────────────────────────
function StudioLib:CreateWindow(options: {
    Title: string?,
    Width: number?,
    Height: number?,
    Position: UDim2?,
    MinimizeKey: Enum.KeyCode?,
})
    local title      = options.Title      or "StudioLib"
    local width      = options.Width      or 380
    local height     = options.Height     or 520
    local startPos   = options.Position   or UDim2.new(0.5, -width/2, 0.5, -height/2)
    local minimizeKey = options.MinimizeKey

    -- ── ScreenGui ────────────────────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SL_" .. title:gsub("%s", "_")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    ScreenGui.Parent = CoreGui

    -- ── Main Window Frame ─────────────────────────────────────────
    local Main = CreateInstance("Frame", {
        Name = "Window",
        Size = UDim2.new(0, width, 0, height),
        Position = startPos,
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Theme.BG_Base,
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, ScreenGui)
    AddBorder(Main, Theme.BorderBright, 2)

    -- Pixel shadow behind window
    local _ = AddPixelShadow(Main, 4)

    -- ── Title Bar ─────────────────────────────────────────────────
    local TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, Theme.TitleBarH),
        BackgroundColor3 = Theme.TitleBG,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, Main)

    -- Bottom border of titlebar
    CreateInstance("Frame", {
        Name = "TitleBorder",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.BorderAccent,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, TitleBar)

    -- Window icon (blocky pixel square)
    local IconFrame = CreateInstance("Frame", {
        Name = "Icon",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 10, 0.5, -7),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, TitleBar)
    -- Inner pixel
    CreateInstance("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0.5, -3, 0.5, -3),
        BackgroundColor3 = Theme.TitleBG,
        BorderSizePixel = 0,
        ZIndex = 7,
    }, IconFrame)

    local TitleLabel = CreateInstance("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = title:upper(),
        TextColor3 = Theme.TitleText,
        TextSize = 12,
        Font = Theme.FontUI,
        TextXAlignment = Enum.TextXAlignment.Left,
        LetterSpacing = 3,
        ZIndex = 6,
    }, TitleBar)
    _ = TitleLabel

    -- Control buttons (blocky pixel style)
    local ControlRow = CreateInstance("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 76, 0, 20),
        Position = UDim2.new(1, -82, 0.5, -10),
        BackgroundTransparency = 1,
        ZIndex = 6,
    }, TitleBar)
    AddListLayout(ControlRow, 4, Enum.FillDirection.Horizontal,
        Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

    local function MakeControlBtn(symbol: string, color: Color3): TextButton
        local btn = CreateInstance("TextButton", {
            Size = UDim2.new(0, 20, 0, 20),
            BackgroundColor3 = Theme.BG_Surface2,
            Text = symbol,
            TextColor3 = color,
            TextSize = 11,
            Font = Theme.FontUI,
            BorderSizePixel = 0,
            ZIndex = 7,
            AutoButtonColor = false,
        }, ControlRow) :: TextButton
        AddBorder(btn, Theme.Border, 1)
        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundColor3 = color }, 0.1)
            Tween(btn, { TextColor3 = Theme.TextInverse }, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundColor3 = Theme.BG_Surface2 }, 0.1)
            Tween(btn, { TextColor3 = color }, 0.1)
        end)
        return btn
    end

    local CloseBtn    = MakeControlBtn("✕", Theme.AccentDanger)
    local MinimizeBtn = MakeControlBtn("─", Theme.AccentWarning)
    local _ = MakeControlBtn("□", Theme.AccentSuccess)

    -- ── Tab Bar ───────────────────────────────────────────────────
    local TabBar = CreateInstance("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, Theme.TabBarH),
        Position = UDim2.new(0, 0, 0, Theme.TitleBarH),
        BackgroundColor3 = Theme.BG_Dark,
        BorderSizePixel = 0,
        ZIndex = 4,
        ClipsDescendants = true,
    }, Main)
    AddBorder(TabBar, Theme.Border, 1)

    local TabLayout = AddListLayout(TabBar, 0, Enum.FillDirection.Horizontal)
    _ = TabLayout

    -- Bottom accent line for active tab indicator
    CreateInstance("Frame", {
        Name = "TabBarBottom",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, TabBar)

    -- ── Content Area ──────────────────────────────────────────────
    local ContentArea = CreateInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, 0, 1, -(Theme.TitleBarH + Theme.TabBarH)),
        Position = UDim2.new(0, 0, 0, Theme.TitleBarH + Theme.TabBarH),
        BackgroundColor3 = Theme.BG_Base,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    }, Main)

    -- Status bar (bottom)
    local StatusBar = CreateInstance("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 1, -18),
        BackgroundColor3 = Theme.BG_Dark,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, Main)
    CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
    }, StatusBar)
    local StatusLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "Ready.",
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Font = Theme.FontMono,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, StatusBar)

    -- Make draggable
    MakeDraggable(TitleBar, Main)

    -- ── Tab + Page System ─────────────────────────────────────────
    local tabs: {{Button: TextButton, Page: ScrollingFrame, Name: string}} = {}
    local activePage: ScrollingFrame | nil = nil

    local function SetActiveTab(index: number)
        for i, t in ipairs(tabs) do
            if i == index then
                Tween(t.Button, { BackgroundColor3 = Theme.BG_Surface }, 0.1)
                t.Button.TextColor3 = Theme.TextAccent
                -- Active indicator line
                if t.Button:FindFirstChild("ActiveLine") then
                    t.Button.ActiveLine.BackgroundTransparency = 0
                end
                t.Page.Visible = true
                activePage = t.Page
                StatusLabel.Text = "Tab: " .. t.Name
            else
                Tween(t.Button, { BackgroundColor3 = Theme.BG_Dark }, 0.1)
                t.Button.TextColor3 = Theme.TextMuted
                if t.Button:FindFirstChild("ActiveLine") then
                    t.Button.ActiveLine.BackgroundTransparency = 1
                end
                t.Page.Visible = false
            end
        end
    end

    -- ── Window Object ─────────────────────────────────────────────
    local Window = {}
    Window._tabs    = tabs
    Window._main    = Main
    Window._gui     = ScreenGui
    Window._status  = StatusLabel
    Window._tabBar  = TabBar
    Window._content = ContentArea

    -- ── Add Tab ───────────────────────────────────────────────────
    function Window:AddTab(tabName: string)
        local tabCount = #tabs + 1
        local tabW = math.max(80, math.ceil(width / math.max(1, tabCount)))

        -- Tab button
        local tabBtn = CreateInstance("TextButton", {
            Name = "Tab_" .. tabName,
            Size = UDim2.new(0, tabW, 1, 0),
            BackgroundColor3 = Theme.BG_Dark,
            Text = tabName:upper(),
            TextColor3 = Theme.TextMuted,
            TextSize = 11,
            Font = Theme.FontUI,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LetterSpacing = 2,
            ZIndex = 5,
        }, TabBar) :: TextButton

        -- Right divider
        CreateInstance("Frame", {
            Name = "Divider",
            Size = UDim2.new(0, 1, 0, 20),
            Position = UDim2.new(1, -1, 0.5, -10),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0,
            ZIndex = 6,
        }, tabBtn)

        -- Active indicator line (bottom of tab)
        local activeLine = CreateInstance("Frame", {
            Name = "ActiveLine",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 7,
        }, tabBtn)
        _ = activeLine

        -- Tab page (scrollable)
        local page = CreateInstance("ScrollingFrame", {
            Name = "Page_" .. tabName,
            Size = UDim2.new(1, 0, 1, -18),  -- minus statusbar
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Theme.BG_Base,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.ScrollThumb,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 3,
        }, ContentArea) :: ScrollingFrame

        local pageLayout = AddListLayout(page, 0)
        AddPadding(page, nil, 0, 4)
        _ = pageLayout

        local idx = tabCount
        table.insert(tabs, { Button = tabBtn, Page = page, Name = tabName })

        tabBtn.MouseButton1Click:Connect(function()
            SetActiveTab(idx)
        end)

        -- Resize all tab buttons equally
        for _, t in ipairs(tabs) do
            t.Button.Size = UDim2.new(0, math.floor(width / #tabs), 1, 0)
        end

        if #tabs == 1 then
            SetActiveTab(1)
        end

        -- ── Section Constructor ────────────────────────────────────
        local Tab = {}

        function Tab:AddSection(sectionName: string)
            -- Section wrapper
            local sectionFrame = CreateInstance("Frame", {
                Name = "Section_" .. sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.BG_Surface,
                BorderSizePixel = 0,
            }, page)
            AddBorder(sectionFrame, Theme.Border, 1)

            -- Section header
            local header = CreateInstance("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Theme.BG_Dark,
                BorderSizePixel = 0,
            }, sectionFrame)
            AddBorder(header, Theme.Border, 1)

            -- Left accent pip
            CreateInstance("Frame", {
                Name = "Pip",
                Size = UDim2.new(0, 3, 0, 14),
                Position = UDim2.new(0, 8, 0.5, -7),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
            }, header)

            CreateInstance("TextLabel", {
                Name = "SectionTitle",
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 18, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName:upper(),
                TextColor3 = Theme.TextAccent,
                TextSize = 11,
                Font = Theme.FontUI,
                TextXAlignment = Enum.TextXAlignment.Left,
                LetterSpacing = 2,
            }, header)

            -- Collapse arrow
            local collapseBtn = CreateInstance("TextButton", {
                Name = "CollapseBtn",
                Size = UDim2.new(0, 22, 1, 0),
                Position = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text = "▾",
                TextColor3 = Theme.TextMuted,
                TextSize = 12,
                Font = Theme.FontUI,
                BorderSizePixel = 0,
                AutoButtonColor = false,
            }, header) :: TextButton

            -- Element list inside section
            local elemList = CreateInstance("Frame", {
                Name = "Elements",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = true,
            }, sectionFrame)
            local elemLayout = AddListLayout(elemList, 0)
            AddPadding(elemList, nil, 0, Theme.SectionPadding)
            _ = elemLayout

            -- Collapse logic
            local collapsed = false
            collapseBtn.MouseButton1Click:Connect(function()
                collapsed = not collapsed
                collapseBtn.Text = collapsed and "▸" or "▾"
                if collapsed then
                    elemList.Visible = false
                else
                    elemList.Visible = true
                end
            end)

            -- ──────────────────────────────────────────────────────
            -- SECTION OBJECT + ELEMENT CONSTRUCTORS
            -- ──────────────────────────────────────────────────────
            local Section = {}

            -- Helper: create a full-width element container
            local function BaseElement(h: number?): Frame
                local f = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, h or Theme.ElementH),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                }) :: Frame
                -- Hover highlight (1px bottom rule)
                CreateInstance("Frame", {
                    Name = "BottomRule",
                    Size = UDim2.new(1, -16, 0, 1),
                    Position = UDim2.new(0, 8, 1, -1),
                    BackgroundColor3 = Theme.Border,
                    BackgroundTransparency = 0.6,
                    BorderSizePixel = 0,
                }, f)
                f.Parent = elemList
                return f
            end

            -- ── LABEL ─────────────────────────────────────────────
            function Section:AddLabel(text: string)
                local row = BaseElement(28)
                CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 12,
                    Font = Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                }, row)
                return self
            end

            -- ── SEPARATOR ─────────────────────────────────────────
            function Section:AddSeparator()
                local row = BaseElement(14)
                CreateInstance("Frame", {
                    Size = UDim2.new(1, -24, 0, 1),
                    Position = UDim2.new(0, 12, 0.5, 0),
                    BackgroundColor3 = Theme.BorderBright,
                    BorderSizePixel = 0,
                }, row)
                -- Pixel diamond in center
                CreateInstance("Frame", {
                    Size = UDim2.new(0, 5, 0, 5),
                    Position = UDim2.new(0.5, -2, 0.5, -2),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Rotation = 45,
                }, row)
                return self
            end

            -- ── PARAGRAPH ─────────────────────────────────────────
            function Section:AddParagraph(titleText: string, bodyText: string)
                local row = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Theme.BG_Input,
                    BorderSizePixel = 0,
                }) :: Frame
                AddBorder(row, Theme.Border, 1)
                AddPadding(row, nil, 12, 8)
                local vl = AddListLayout(row, 4)
                _ = vl
                row.Parent = elemList

                CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = titleText,
                    TextColor3 = Theme.TextAccent,
                    TextSize = 12,
                    Font = Theme.FontUI,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, row)
                CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = bodyText,
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 11,
                    Font = Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                }, row)
                return self
            end

            -- ── BUTTON ────────────────────────────────────────────
            function Section:AddButton(text: string, callback: () -> ())
                local row = BaseElement()
                AddPadding(row, nil, 8, 0)

                local btn = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 1, -8),
                    Position = UDim2.new(0, 0, 0, 4),
                    BackgroundColor3 = Theme.BG_Surface2,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    ZIndex = 2,
                }, row) :: TextButton
                AddBorder(btn, Theme.Border, 1)

                -- Pixel icon bar
                CreateInstance("Frame", {
                    Name = "PixelBar",
                    Size = UDim2.new(0, 3, 0, 14),
                    Position = UDim2.new(0, 8, 0.5, -7),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                }, btn)

                CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 18, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 12,
                    Font = Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, btn)

                -- Hover + click effects
                btn.MouseEnter:Connect(function()
                    Tween(btn, { BackgroundColor3 = Theme.BG_Elevated }, 0.08)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, { BackgroundColor3 = Theme.BG_Surface2 }, 0.08)
                end)
                btn.MouseButton1Down:Connect(function()
                    Tween(btn, { BackgroundColor3 = Theme.AccentDim }, 0.05)
                end)
                btn.MouseButton1Up:Connect(function()
                    Tween(btn, { BackgroundColor3 = Theme.BG_Elevated }, 0.08)
                    task.spawn(callback)
                end)
                return self
            end

            -- ── TOGGLE ────────────────────────────────────────────
            function Section:AddToggle(text: string, default: boolean, callback: (boolean) -> ())
                local row = BaseElement()
                local value = default

                CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 12,
                    Font = Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, row)

                -- Toggle track (blocky, no radius)
                local track = CreateInstance("Frame", {
                    Name = "Track",
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -48, 0.5, -9),
                    BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff,
                    BorderSizePixel = 0,
                }, row)
                AddBorder(track, Theme.Border, 1)

                -- Inner pixel grid lines (texture detail)
                for px = 4, 30, 8 do
                    CreateInstance("Frame", {
                        Size = UDim2.new(0, 1, 0, 10),
                        Position = UDim2.new(0, px, 0.5, -5),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 0.8,
                        BorderSizePixel = 0,
                    }, track)
                end

                -- Knob (blocky square)
                local knob = CreateInstance("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, value and 21 or 3, 0.5, -6),
                    BackgroundColor3 = Theme.ToggleKnob,
                    BorderSizePixel = 0,
                }, track)
                AddBorder(knob, Theme.Border, 1)

                local function updateVisual(v: boolean)
                    Tween(track, { BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff }, 0.1)
                    Tween(knob, { Position = UDim2.new(0, v and 21 or 3, 0.5, -6) }, 0.1)
                end

                -- Hit area
                local hit = CreateInstance("TextButton", {
                    Size = UDim2.new(0, 44, 1, 0),
                    Position = UDim2.new(1, -52, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                }, row) :: TextButton
                hit.MouseButton1Click:Connect(function()
                    value = not value
                    updateVisual(value)
                    task.spawn(callback, value)
                end)

                updateVisual(value)

                -- Return a controller
                local ctrl = { Value = value }
                function ctrl:Set(v: boolean)
                    value = v
                    ctrl.Value = v
                    updateVisual(v)
                end
                return ctrl
            end

            -- ── SLIDER ────────────────────────────────────────────
            function Section:AddSlider(text: string, opts: {Min: number, Max: number, Default: number, Step: number?}, callback: (number) -> ())
                local min   = opts.Min     or 0
                local max   = opts.Max     or 100
                local step  = opts.Step    or 1
                local value = opts.Default or min

                local rowH = Theme.ElementH + 12
                local row = BaseElement(rowH)

                -- Label + value display
                local labelRow = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    Position = UDim2.new(0, 0, 0, 4),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                }, row)

                CreateInstance("TextLabel", {
                    Size = UDim2.new(0.7, -12, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 12,
                    Font = Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, labelRow)

                local valLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(0.3, -4, 1, 0),
                    Position = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = Theme.TextAccent,
                    TextSize = 12,
                    Font = Theme.FontMono,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, labelRow)

                -- Track
                local trackBG = CreateInstance("Frame", {
                    Name = "SliderTrack",
                    Size = UDim2.new(1, -24, 0, 8),
                    Position = UDim2.new(0, 12, 0, 26),
                    BackgroundColor3 = Theme.BG_Input,
                    BorderSizePixel = 0,
                }, row)
                AddBorder(trackBG, Theme.Border, 1)

                -- Tick marks (blocky pixel detail)
                local ticks = 8
                for i = 0, ticks do
                    CreateInstance("Frame", {
                        Size = UDim2.new(0, 1, 0, i == 0 or i == ticks and 8 or 4),
                        Position = UDim2.new(i/ticks, 0, 0, i == 0 or i == ticks and 0 or 2),
                        BackgroundColor3 = Theme.Border,
                        BackgroundTransparency = 0.3,
                        BorderSizePixel = 0,
                    }, trackBG)
                end

                -- Fill
                local pct = (value - min) / (max - min)
                local fill = CreateInstance("Frame", {
                    Name = "Fill",
                    Size = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                }, trackBG)

                -- Knob (blocky diamond-ish square)
                local knob = CreateInstance("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 10, 0, 16),
                    Position = UDim2.new(pct, -5, 0.5, -8),
                    BackgroundColor3 = Theme.ToggleKnob,
                    BorderSizePixel = 0,
                }, trackBG)
                AddBorder(knob, Theme.Accent, 1)

                local function SetValue(v: number)
                    v = math.clamp(math.round((v - min) / step) * step + min, min, max)
                    value = v
                    local p = (v - min) / (max - min)
                    Tween(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.05)
                    Tween(knob, { Position = UDim2.new(p, -5, 0.5, -8) }, 0.05)
                    valLabel.Text = tostring(v)
                    task.spawn(callback, v)
                end

                -- Drag logic
                local dragging = false
                knob.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                trackBG.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local rel = (inp.Position.X - trackBG.AbsolutePosition.X) / trackBG.AbsoluteSize.X
                        SetValue(min + rel * (max - min))
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = (inp.Position.X - trackBG.AbsolutePosition.X) / trackBG.AbsoluteSize.X
                        SetValue(min + rel * (max - min))
                    end
                end)

                local ctrl = { Value = value }
                function ctrl:Set(v: number) SetValue(v) end
                return ctrl
            end

            -- ── INPUT ─────────────────────────────────────────────
            function Section:AddInput(labelText: string, placeholder: string, callback: (string) -> ())
                local row = BaseElement(Theme.ElementH + 8)
                AddPadding(row, nil, 8, 0)

                CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14),
                    Position = UDim2.new(0, 0, 0, 4),
                    BackgroundTransparency = 1,
                    Text = labelText,
                    TextColor3 = Theme.TextSecondary,
                    TextSize = 10,
                    Font = Theme.FontUI,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LetterSpacing = 1,
                }, row)

                local inputFrame = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Theme.BG_Input,
                    BorderSizePixel = 0,
                }, row)
                local border = AddBorder(inputFrame, Theme.Border, 1)

                local box = CreateInstance("TextBox", {
                    Size = UDim2.new(1, -8, 1, 0),
                    Position = UDim2.new(0, 6, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Theme.TextMuted,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 12,
                    Font = Theme.FontMono,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                }, inputFrame) :: TextBox

                box.Focused:Connect(function()
                    Tween(border, { Color = Theme.Accent }, 0.1)
                end)
                box.FocusLost:Connect(function(enter)
                    Tween(border, { Color = Theme.Border }, 0.1)
                    if enter then task.spawn(callback, box.Text) end
                end)

                local ctrl = {}
                function ctrl:Get() return box.Text end
                function ctrl:Set(v: string) box.Text = v end
                return ctrl
            end

            -- ── DROPDOWN ──────────────────────────────────────────
            function Section:AddDropdown(labelText: string, choices: {string}, default: string, callback: (string) -> ())
                local row = BaseElement(Theme.ElementH + 4)
                AddPadding(row, nil, 8, 0)

                CreateInstance("TextLabel", {
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = labelText,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 12,
                    Font = Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, row)

                local selected = default or choices[1] or ""

                local dropBtn = CreateInstance("TextButton", {
                    Name = "DropBtn",
                    Size = UDim2.new(0.5, -4, 0, 26),
                    Position = UDim2.new(0.5, 4, 0.5, -13),
                    BackgroundColor3 = Theme.BG_Surface2,
                    Text = selected .. "  ▾",
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 11,
                    Font = Theme.Font,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    ClipsDescendants = true,
                }, row) :: TextButton
                AddBorder(dropBtn, Theme.Border, 1)

                -- Dropdown list (opens above/below)
                local listFrame = CreateInstance("Frame", {
                    Name = "DropList",
                    Size = UDim2.new(1, 0, 0, #choices * 26),
                    Position = UDim2.new(0, 0, 1, 2),
                    BackgroundColor3 = Theme.BG_Surface,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 10,
                }, dropBtn)
                AddBorder(listFrame, Theme.Accent, 1)
                listFrame.ZIndex = 10

                local listLayout = AddListLayout(listFrame, 0)
                _ = listLayout

                for _, choice in ipairs(choices) do
                    local opt = CreateInstance("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme.BG_Surface,
                        Text = choice,
                        TextColor3 = choice == selected and Theme.TextAccent or Theme.TextPrimary,
                        TextSize = 11,
                        Font = Theme.Font,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        ZIndex = 11,
                    }, listFrame) :: TextButton
                    CreateInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        Position = UDim2.new(0, 0, 1, -1),
                        BackgroundColor3 = Theme.Border,
                        BorderSizePixel = 0,
                        ZIndex = 12,
                    }, opt)

                    opt.MouseEnter:Connect(function()
                        Tween(opt, { BackgroundColor3 = Theme.BG_Elevated }, 0.08)
                    end)
                    opt.MouseLeave:Connect(function()
                        Tween(opt, { BackgroundColor3 = choice == selected and Theme.BG_Surface2 or Theme.BG_Surface }, 0.08)
                    end)
                    opt.MouseButton1Click:Connect(function()
                        selected = choice
                        dropBtn.Text = choice .. "  ▾"
                        listFrame.Visible = false
                        task.spawn(callback, choice)
                    end)
                end

                local open = false
                dropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    listFrame.Visible = open
                    dropBtn.Text = selected .. (open and "  ▴" or "  ▾")
                end)
                dropBtn.MouseEnter:Connect(function()
                    Tween(dropBtn, { BackgroundColor3 = Theme.BG_Elevated }, 0.08)
                end)
                dropBtn.MouseLeave:Connect(function()
                    Tween(dropBtn, { BackgroundColor3 = Theme.BG_Surface2 }, 0.08)
                end)

                local ctrl = { Value = selected }
                function ctrl:Set(v: string)
                    selected = v
                    dropBtn.Text = v .. "  ▾"
                    ctrl.Value = v
                end
                return ctrl
            end

            -- ── COLOR PICKER ──────────────────────────────────────
            function Section:AddColorPicker(labelText: string, default: Color3, callback: (Color3) -> ())
                local row = BaseElement(Theme.ElementH + 4)
                AddPadding(row, nil, 8, 0)

                CreateInstance("TextLabel", {
                    Size = UDim2.new(0.65, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = labelText,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 12,
                    Font = Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, row)

                local current = default
                local r_val, g_val, b_val = math.round(default.R*255), math.round(default.G*255), math.round(default.B*255)

                -- Color preview swatch (blocky pixel square)
                local swatch = CreateInstance("TextButton", {
                    Size = UDim2.new(0, 40, 0, 24),
                    Position = UDim2.new(1, -46, 0.5, -12),
                    BackgroundColor3 = default,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                }, row)
                AddBorder(swatch, Theme.Border, 1)

                -- Checker pattern on swatch (transparent bg indicator)
                for cx = 0, 3 do for cy = 0, 1 do
                    if (cx + cy) % 2 == 0 then
                        CreateInstance("Frame", {
                            Size = UDim2.new(0, 10, 0, 12),
                            Position = UDim2.new(0, cx*10, 0, cy*12),
                            BackgroundColor3 = Color3.fromRGB(180,180,180),
                            BackgroundTransparency = 0.6,
                            BorderSizePixel = 0,
                            ZIndex = swatch.ZIndex,
                        }, swatch)
                    end
                end end

                -- Picker panel
                local panel = CreateInstance("Frame", {
                    Name = "ColorPanel",
                    Size = UDim2.new(0, 180, 0, 100),
                    Position = UDim2.new(1, -186, 1, 4),
                    BackgroundColor3 = Theme.BG_Surface,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 15,
                }, row)
                AddBorder(panel, Theme.Accent, 1)
                AddPadding(panel, 8)

                local panelLayout = AddListLayout(panel, 4)
                _ = panelLayout

                local channels = {
                    { label = "R", get = function() return r_val end, set = function(v) r_val = v end, color = Color3.fromRGB(220,60,60) },
                    { label = "G", get = function() return g_val end, set = function(v) g_val = v end, color = Color3.fromRGB(60,200,80) },
                    { label = "B", get = function() return b_val end, set = function(v) b_val = v end, color = Color3.fromRGB(60,120,255) },
                }

                local function ApplyColor()
                    current = Color3.fromRGB(r_val, g_val, b_val)
                    swatch.BackgroundColor3 = current
                    task.spawn(callback, current)
                end

                for _, ch in ipairs(channels) do
                    local chRow = CreateInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                    }, panel)

                    CreateInstance("TextLabel", {
                        Size = UDim2.new(0, 14, 1, 0),
                        BackgroundTransparency = 1,
                        Text = ch.label,
                        TextColor3 = ch.color,
                        TextSize = 11,
                        Font = Theme.FontUI,
                    }, chRow)

                    local chTrack = CreateInstance("Frame", {
                        Size = UDim2.new(1, -44, 0, 8),
                        Position = UDim2.new(0, 16, 0.5, -4),
                        BackgroundColor3 = Theme.BG_Input,
                        BorderSizePixel = 0,
                    }, chRow)
                    AddBorder(chTrack, Theme.Border, 1)

                    local chFill = CreateInstance("Frame", {
                        Size = UDim2.new(ch.get()/255, 0, 1, 0),
                        BackgroundColor3 = ch.color,
                        BorderSizePixel = 0,
                    }, chTrack)

                    local chLabel = CreateInstance("TextLabel", {
                        Size = UDim2.new(0, 24, 1, 0),
                        Position = UDim2.new(1, -26, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tostring(ch.get()),
                        TextColor3 = Theme.TextMuted,
                        TextSize = 10,
                        Font = Theme.FontMono,
                    }, chRow)

                    -- Drag on channel
                    local chDragging = false
                    chTrack.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            chDragging = true
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            chDragging = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if chDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                            local rel = math.clamp((inp.Position.X - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X, 0, 1)
                            local v = math.round(rel * 255)
                            ch.set(v)
                            chFill.Size = UDim2.new(rel, 0, 1, 0)
                            chLabel.Text = tostring(v)
                            ApplyColor()
                        end
                    end)
                end

                local panelOpen = false
                swatch.MouseButton1Click:Connect(function()
                    panelOpen = not panelOpen
                    panel.Visible = panelOpen
                end)

                local ctrl = { Value = current }
                function ctrl:Set(c: Color3)
                    current = c
                    r_val = math.round(c.R*255)
                    g_val = math.round(c.G*255)
                    b_val = math.round(c.B*255)
                    swatch.BackgroundColor3 = c
                    ctrl.Value = c
                end
                return ctrl
            end

            -- ── KEYBIND ───────────────────────────────────────────
            function Section:AddKeybind(labelText: string, defaultKey: Enum.KeyCode, callback: () -> ())
                local row = BaseElement()
                local currentKey = defaultKey
                local listening = false

                CreateInstance("TextLabel", {
                    Size = UDim2.new(0.6, -12, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = labelText,
                    TextColor3 = Theme.TextPrimary,
                    TextSize = 12,
                    Font = Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, row)

                local keyBtn = CreateInstance("TextButton", {
                    Size = UDim2.new(0.4, -12, 0, 24),
                    Position = UDim2.new(0.6, 4, 0.5, -12),
                    BackgroundColor3 = Theme.BG_Input,
                    Text = "[" .. defaultKey.Name .. "]",
                    TextColor3 = Theme.TextAccent,
                    TextSize = 11,
                    Font = Theme.FontMono,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                }, row) :: TextButton
                AddBorder(keyBtn, Theme.Border, 1)

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "[ ... ]"
                    keyBtn.TextColor3 = Theme.AccentWarning
                    Tween(keyBtn, { BackgroundColor3 = Theme.BG_Elevated }, 0.1)
                end)

                UserInputService.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = inp.KeyCode
                        keyBtn.Text = "[" .. inp.KeyCode.Name .. "]"
                        keyBtn.TextColor3 = Theme.TextAccent
                        Tween(keyBtn, { BackgroundColor3 = Theme.BG_Input }, 0.1)
                        listening = false
                    elseif not listening and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == currentKey then
                        task.spawn(callback)
                    end
                end)

                local ctrl = {}
                function ctrl:GetKey() return currentKey end
                return ctrl
            end

            return Section
        end -- AddSection

        return Tab
    end -- AddTab

    -- ── Window Controls ────────────────────────────────────────────
    local minimized = false
    local savedH = height

    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            savedH = Main.Size.Y.Offset
            Tween(Main, { Size = UDim2.new(0, width, 0, Theme.TitleBarH) }, 0.15)
            ContentArea.Visible = false
            TabBar.Visible = false
            StatusBar.Visible = false
        else
            ContentArea.Visible = true
            TabBar.Visible = true
            StatusBar.Visible = true
            Tween(Main, { Size = UDim2.new(0, width, 0, savedH) }, 0.15)
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, { BackgroundTransparency = 1 }, 0.2)
        task.wait(0.2)
        ScreenGui:Destroy()
    end)

    if minimizeKey then
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.KeyCode == minimizeKey then
                Main.Visible = not Main.Visible
            end
        end)
    end

    function Window:SetStatus(msg: string)
        StatusLabel.Text = msg
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    -- Convenience: AddSection at window level (adds to first tab or creates one)
    function Window:AddSection(name: string)
        if #tabs == 0 then
            local tab = self:AddTab("Main")
            return tab:AddSection(name)
        end
        return tabs[1].Page:FindFirstChild("Section_" .. name)
            or (function()
                -- create section directly on page 1
                local t = {
                    AddSection = function(_, n) return self:_addSectionToPage(tabs[1].Page, n) end
                }
                return self:_addSectionToPage(tabs[1].Page, name)
            end)()
    end

    -- Internal helper: add section to a specific page
    function Window:_addSectionToPage(page: ScrollingFrame, sectionName: string)
        -- Re-use Tab's AddSection logic by creating a temporary Tab object bound to the page
        local tempTab = { }
        -- Inject page reference
        local origAddSection = nil
        -- We call the Tab constructor inline
        local fakeTab = self:AddTab("__dummy__")
        -- Remove dummy tab
        local dummyBtn = TabBar:FindFirstChild("Tab___dummy__")
        local dummyPage = ContentArea:FindFirstChild("Page___dummy__")
        if dummyBtn then dummyBtn:Destroy() end
        if dummyPage then dummyPage:Destroy() end
        table.remove(tabs, #tabs)
        -- Instead, reuse the real page
        _ = fakeTab
        _ = tempTab
        _ = origAddSection
        return page -- fallback
    end

    return Window
end

-- ──────────────────────────────────────────────────────────────────
-- THEME CUSTOMIZATION
-- ──────────────────────────────────────────────────────────────────
function StudioLib:SetTheme(overrides: {[string]: Color3 | Enum.Font | number})
    for k, v in pairs(overrides) do
        if Theme[k] ~= nil then
            Theme[k] = v
        end
    end
end

function StudioLib:GetTheme()
    return table.clone(Theme)
end

-- Built-in presets
StudioLib.Themes = {
    Default = {},  -- no overrides
    Midnight = {
        BG_Dark     = Color3.fromRGB(8,   8,   12),
        BG_Base     = Color3.fromRGB(12,  12,  18),
        BG_Surface  = Color3.fromRGB(18,  18,  26),
        Accent      = Color3.fromRGB(100, 80,  220),
        AccentHover = Color3.fromRGB(130, 110, 240),
        BorderAccent= Color3.fromRGB(80,  60,  200),
        TextAccent  = Color3.fromRGB(160, 140, 255),
    },
    Emerald = {
        Accent      = Color3.fromRGB(40,  200, 120),
        AccentHover = Color3.fromRGB(60,  220, 140),
        AccentDim   = Color3.fromRGB(20,  100, 60 ),
        BorderAccent= Color3.fromRGB(40,  160, 100),
        TextAccent  = Color3.fromRGB(80,  220, 150),
        ToggleOn    = Color3.fromRGB(40,  180, 110),
    },
    CrimsonBlock = {
        Accent      = Color3.fromRGB(220, 60,  60 ),
        AccentHover = Color3.fromRGB(240, 80,  80 ),
        AccentDim   = Color3.fromRGB(120, 30,  30 ),
        BorderAccent= Color3.fromRGB(200, 50,  50 ),
        TextAccent  = Color3.fromRGB(255, 120, 120),
        ToggleOn    = Color3.fromRGB(200, 60,  60 ),
    },
}

return StudioLib
