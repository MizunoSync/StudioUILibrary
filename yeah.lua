local Library = {}

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Executions = {}
do
    local Path = "ZeroHub/Zero_Executions.txt"
    function Executions.Increment()
        if getgenv()._ZeroExecCount then
            return getgenv()._ZeroExecCount
        end
        local Count = 0
        pcall(function()
            if isfile(Path) then
                Count = tonumber(readfile(Path)) or 0
            end
        end)
        Count = Count + 1
        pcall(function()
            writefile(Path, tostring(Count))
        end)
        getgenv()._ZeroExecCount = Count
        return Count
    end
end

local AccentTargets = {}
local function RegisterAccent(Updater)
    table.insert(AccentTargets, Updater)
    pcall(Updater)
    return Updater
end

local NotifyHolder
local ActiveNotifs = {}
local Collapsibles = {}

Library.Flags = {}
Library.Options = {}
Library.Connections = {}
Library.Popups = {}

local Theme = {
    Background = Color3.fromRGB(12, 12, 16),
    Panel = Color3.fromRGB(19, 19, 25),
    Stroke = Color3.fromRGB(34, 35, 43),
    Accent = Color3.fromRGB(18, 18, 24),
    AccentHover = Color3.fromRGB(28, 28, 36),
    AccentClick = Color3.fromRGB(36, 36, 44),
    AccentText = Color3.fromRGB(200, 200, 210),
    ElementBackground = Color3.fromRGB(12, 12, 16),
    ElementStroke = Color3.fromRGB(31, 31, 39),
    Title = Color3.fromRGB(175, 175, 177),
    Text = Color3.fromRGB(118, 118, 127),
    SubText = Color3.fromRGB(101, 101, 114),
    GroupboxTitle = Color3.fromRGB(115, 115, 130),
    CategoryTitle = Color3.fromRGB(163, 163, 173),
    TabSelected = Color3.fromRGB(206, 206, 206),
    TabUnselected = Color3.fromRGB(93, 93, 105),
    SliderTrack = Color3.fromRGB(19, 19, 25),
    SliderStroke = Color3.fromRGB(31, 32, 40),
    SliderFill = Color3.fromRGB(220, 220, 230),
    Line = Color3.fromRGB(31, 32, 40),
    ButtonStroke = Color3.fromRGB(36, 47, 66),
    OutlineButton = Color3.fromRGB(19, 19, 25),
    OutlineButtonHover = Color3.fromRGB(29, 29, 39),
    OutlineButtonClick = Color3.fromRGB(37, 37, 47),
    OutlineButtonStroke = Color3.fromRGB(33, 33, 39),
    TableHeader = Color3.fromRGB(12, 12, 16),
    TableRow = Color3.fromRGB(19, 19, 25),
    TableStroke = Color3.fromRGB(33, 34, 42),
    TableText = Color3.fromRGB(109, 109, 117),
    TableTitle = Color3.fromRGB(156, 156, 166),
    DimText = Color3.fromRGB(116, 116, 131),
    CogClosed = Color3.fromRGB(108, 108, 122),
    CogOpen = Color3.fromRGB(164, 164, 186),
    DropdownArrow = Color3.fromRGB(126, 126, 128),
    DropdownBlank = Color3.fromRGB(112, 112, 120),
    KeybindMenuText = Color3.fromRGB(137, 137, 137),
    KeybindModeOn = Color3.fromRGB(0, 111, 231),
    KeybindModeOff = Color3.fromRGB(19, 19, 19),
    TextboxStroke = Color3.fromRGB(33, 34, 40),
    TextboxText = Color3.fromRGB(130, 130, 131),
    ButtonDefault = Color3.fromRGB(22, 22, 28),
    ButtonDefaultHover = Color3.fromRGB(32, 32, 40),
    ButtonDefaultStroke = Color3.fromRGB(36, 36, 46),
    ElementBorder = Color3.fromRGB(32, 32, 40),
    TooltipBackground = Color3.fromRGB(22, 22, 28),
    TooltipBorder = Color3.fromRGB(44, 44, 56),
    TooltipTitle = Color3.fromRGB(235, 235, 240),
    TooltipDesc = Color3.fromRGB(155, 155, 168),
}

Library.Theme = Theme

local Assets = {
    Close = "rbxassetid://89555599605432",
    Minimize = "rbxassetid://107635635765106",
    Arrow = "rbxassetid://128254015050703",
    Check = "rbxassetid://83941192767745",
    Cog = "rbxassetid://82403158704288",
    DropdownArrow = "rbxassetid://89961947412215",
    KeybindIcon = "rbxassetid://134005031785541",
}

local Settings = {
    KeybindMenuOffset = Vector2.new(170, 70),
    DropdownMenuOffset = Vector2.new(0, 65),
    DragFadeTransparency = 0.3,
    DragImage = "https://raw.githubusercontent.com/aymanabdo0355-ctrl/Images/main/ChatGPT%20Image%20Jul%2017%2C%202026%2C%2011_47_50%20PM.png",
    DragImageSize = UDim2.fromScale(0.9, 0.85),
    DragImageRotation = -25,
    CursorEnabled = true,
    CursorImage = "rbxassetid://131481965346967",
    CursorSize = Vector2.new(20, 20),
    CursorOffset = Vector2.new(0, 0),
    CursorColor = Theme.AccentText,
}

Library.Settings = Settings

local function Hook(Signal, Callback)
    local Connection = Signal:Connect(Callback)
    table.insert(Library.Connections, Connection)
    return Connection
end

local function Tween(Object, Properties, Duration, Style, Direction)
    local Info = TweenInfo.new(
        Duration or 0.2,
        Style or Enum.EasingStyle.Quad,
        Direction or Enum.EasingDirection.Out
    )
    local Object2 = TweenService:Create(Object, Info, Properties)
    Object2:Play()
    return Object2
end

local FadeTargets = {}
local RegisterFadesEnabled = true

local function RegisterFade(Object)
    if Object:IsA("UIStroke") then
        table.insert(FadeTargets, { Object, "Transparency" })
    elseif Object:IsA("GuiObject") then
        table.insert(FadeTargets, { Object, "BackgroundTransparency" })
        if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
            table.insert(FadeTargets, { Object, "TextTransparency" })
        end
        if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
            table.insert(FadeTargets, { Object, "ImageTransparency" })
        end
    end
end

local function Create(ClassName, Properties, Children)
    local Object = Instance.new(ClassName)
    for Property, Value in pairs(Properties or {}) do
        if Property ~= "Parent" then
            Object[Property] = Value
        end
    end
    for _, Child in ipairs(Children or {}) do
        Child.Parent = Object
    end
    if RegisterFadesEnabled then
        RegisterFade(Object)
    end
    if Properties and Properties.Parent then
        Object.Parent = Properties.Parent
    end
    return Object
end

local function LoadCustomFont(FontName, FontUrl)
    local TtfName = FontName .. ".ttf"
    local FontDataName = FontName .. ".font"

    if not isfile(TtfName) then
        writefile(TtfName, game:HttpGet(FontUrl))
    end

    local Data = {
        name = FontName,
        faces = { {
            name = FontName,
            weight = 600,
            style = "normal",
            assetId = getcustomasset(TtfName),
        } },
    }
    writefile(FontDataName, HttpService:JSONEncode(Data))

    return Font.new(getcustomasset(FontDataName))
end

local FontOk, Inter = pcall(LoadCustomFont, "InterSemiBold", "https://github.com/toeerolo-z/ethossuiterewriteA/blob/main/InterSemibold%20(1).ttf")
local InterSemiBold = FontOk and Inter or Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)

Library.Font = InterSemiBold

local function GetGuiParent()
    local Ok, Hui = pcall(function()
        return gethui()
    end)
    if Ok and Hui then
        return Hui
    end
    local Ok2 = pcall(function()
        return CoreGui.Name
    end)
    if Ok2 then
        return CoreGui
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function SafeCall(Callback, ...)
    if type(Callback) ~= "function" then
        return
    end
    local Ok, Err = pcall(Callback, ...)
    if not Ok then
        warn("[EthosLibrary] Callback error: " .. tostring(Err))
    end
end

local ShadowSupported = pcall(function() Instance.new("UIShadow"):Destroy() end)

local function MakeShadow(Parent, Props)
    if not ShadowSupported then return nil end
    Props = Props or {}
    local Ok, Shadow = pcall(function()
        local S = Instance.new("UIShadow")
        S.Color = Props.Color or Color3.fromRGB(0, 0, 0)
        S.Offset = Props.Offset or Vector2.new(0, 2)
        S.Size = Props.Size or 8
        S.Transparency = Props.Transparency or 0.6
        S.Parent = Parent
        return S
    end)
    return Ok and Shadow or nil
end

local TooltipGui, TipImage, TipTitle, TipDesc
local TipToken = 0

local function ResolveAsset(Path)
    if not Path or Path == "" then return nil end
    if Path:match("^rbxassetid://") then return Path end
    local Ok, Asset = pcall(getcustomasset, Path)
    return Ok and Asset or nil
end

local function BuildTooltip()
    if TooltipGui then return end
    local Screen = Library.Window and Library.Window.Screen
    if not Screen then return end

    RegisterFadesEnabled = false

    TooltipGui = Create("CanvasGroup", {
        Name = "Tooltip", Parent = Screen, BorderSizePixel = 0,
        BackgroundColor3 = Theme.TooltipBackground,
        Size = UDim2.new(0, 220, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        GroupTransparency = 1, Visible = false, ZIndex = 200,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TooltipGui })
    Create("UIStroke", { Thickness = 1.5, Color = Theme.TooltipBorder, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = TooltipGui })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = TooltipGui })
    MakeShadow(TooltipGui, { Color = Color3.fromRGB(160, 160, 190), Size = 12, Transparency = 0.6, Offset = Vector2.new(0, 0) })

    TipImage = Create("ImageLabel", {
        Name = "Image", Parent = TooltipGui, LayoutOrder = 1, BorderSizePixel = 0,
        BackgroundColor3 = Theme.Background, Size = UDim2.new(1, 0, 0, 140),
        ScaleType = Enum.ScaleType.Crop, Visible = false, ZIndex = 201,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TipImage })

    local Inner = Create("Frame", {
        Name = "Inner", Parent = TooltipGui, LayoutOrder = 2, BorderSizePixel = 0,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 201,
    })
    Create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = Inner })
    Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Inner })

    TipTitle = Create("TextLabel", {
        Name = "Title", Parent = Inner, LayoutOrder = 1, BorderSizePixel = 0,
        BackgroundTransparency = 1, FontFace = InterSemiBold, TextSize = 14,
        TextColor3 = Theme.TooltipTitle, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0), Text = "", ZIndex = 202,
    })

    TipDesc = Create("TextLabel", {
        Name = "Desc", Parent = Inner, LayoutOrder = 2, BorderSizePixel = 0,
        BackgroundTransparency = 1, FontFace = InterSemiBold, TextSize = 13,
        TextColor3 = Theme.TooltipDesc, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0), Text = "", Visible = false, ZIndex = 202,
    })

    RegisterFadesEnabled = true
end

local function ShowTooltip(Element, Opts)
    BuildTooltip()
    if not TooltipGui then return end

    TipToken = TipToken + 1
    TipTitle.Text = Opts.TooltipTitle or Opts.Text or ""
    TipDesc.Text = Opts.TooltipDesc or Opts.Description or ""
    TipDesc.Visible = TipDesc.Text ~= ""

    local Img = ResolveAsset(Opts.TooltipImage)
    TipImage.Image = Img or ""
    TipImage.Visible = Img ~= nil

    local Pos = Element.AbsolutePosition
    local Sz = Element.AbsoluteSize
    local Vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local X = Pos.X + Sz.X + 8
    local Y = Pos.Y
    if X + 228 > Vp.X then X = Pos.X - 228 end
    if Y + 200 > Vp.Y then Y = Vp.Y - 210 end

    TooltipGui.Position = UDim2.fromOffset(X, Y)
    TooltipGui.Visible = true
    Tween(TooltipGui, { GroupTransparency = 0 }, 0.15)
end

local function HideTooltip()
    if not TooltipGui then return end
    TipToken = TipToken + 1
    local Token = TipToken
    task.delay(0.06, function()
        if TipToken ~= Token then return end
        Tween(TooltipGui, { GroupTransparency = 1 }, 0.12)
        task.delay(0.13, function()
            if TipToken == Token and TooltipGui then
                TooltipGui.Visible = false
            end
        end)
    end)
end

local function HookTooltip(Holder, Opts)
    if not Opts.TooltipImage and not Opts.TooltipDesc and not Opts.Description then return end
    Holder.MouseEnter:Connect(function() ShowTooltip(Holder, Opts) end)
    Holder.MouseLeave:Connect(function() HideTooltip() end)
end

local function GatherFade(Object, Acc)
    if Object:IsA("UIStroke") then
        table.insert(Acc, { Object, "Transparency", Object.Transparency })
    elseif Object:IsA("GuiObject") then
        table.insert(Acc, { Object, "BackgroundTransparency", Object.BackgroundTransparency })
        if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
            table.insert(Acc, { Object, "TextTransparency", Object.TextTransparency })
        end
        if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
            table.insert(Acc, { Object, "ImageTransparency", Object.ImageTransparency })
        end
    end
    for _, Child in ipairs(Object:GetChildren()) do
        GatherFade(Child, Acc)
    end
    return Acc
end

local function FadePopupIn(Root)
    local Parts = GatherFade(Root, {})
    for _, Part in ipairs(Parts) do
        Part[1][Part[2]] = 1
    end
    local Target = Root.Position
    Root.Position = Target - UDim2.fromOffset(0, 10)
    Tween(Root, { Position = Target }, 0.22, Enum.EasingStyle.Quint)
    for _, Part in ipairs(Parts) do
        Tween(Part[1], { [Part[2]] = Part[3] }, 0.22)
    end
    return Parts
end

local function FadePopupOut(Root, Parts)
    Tween(Root, { Position = Root.Position - UDim2.fromOffset(0, 10) }, 0.2, Enum.EasingStyle.Quint)
    for _, Part in ipairs(Parts or GatherFade(Root, {})) do
        Tween(Part[1], { [Part[2]] = 1 }, 0.2)
    end
    task.delay(0.22, function()
        if Root and Root.Parent then
            Root:Destroy()
        end
    end)
end

local function RevealPage(Page)
    local Parts = GatherFade(Page, {})
    for _, Part in ipairs(Parts) do
        Part[1][Part[2]] = 1
    end
    for _, Part in ipairs(Parts) do
        Tween(Part[1], { [Part[2]] = Part[3] }, 0.3, Enum.EasingStyle.Quint)
    end
end

local DragFadeBase
local DragFaded = false
local DragRestoring = false
local DragRestoreToken = 0
local DragImageLabel
local DragHideTargets = {}

local function SetWindowFaded(Faded)
    if Faded == DragFaded then return end
    DragFaded = Faded

    if Faded then
        for _, Target in ipairs(DragHideTargets) do
            Target.Visible = false
        end
        if DragImageLabel then
            DragImageLabel.Visible = true
            Tween(DragImageLabel, { ImageTransparency = 0 }, 0.15)
        end
        local Win = Library.Window
        if Win and Win.Main then
            Tween(Win.Main, { BackgroundTransparency = Settings.DragFadeTransparency }, 0.15)
        end
    else
        if DragImageLabel then
            Tween(DragImageLabel, { ImageTransparency = 1 }, 0.15)
            task.delay(0.16, function()
                if not DragFaded and DragImageLabel then
                    DragImageLabel.Visible = false
                end
            end)
        end
        for _, Target in ipairs(DragHideTargets) do
            Target.Visible = true
        end
        local Win = Library.Window
        if Win and Win.Main then
            Tween(Win.Main, { BackgroundTransparency = 0 }, 0.15)
        end
    end
end

local function MakeDraggable(DragHandle, Target)
    local Dragging = false
    local StartMouse
    local StartPosition

    local function IsPress(t) return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch end
    local function IsMove(t) return t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch end

    DragHandle.InputBegan:Connect(function(Input)
        if IsPress(Input.UserInputType) then
            Dragging = true
            StartMouse = Input.Position
            StartPosition = Target.Position
            Library:CloseAllPopups()
            SetWindowFaded(true)
        end
    end)

    Hook(UserInputService.InputEnded, function(Input)
        if IsPress(Input.UserInputType) and Dragging then
            Dragging = false
            SetWindowFaded(false)
        end
    end)

    Hook(UserInputService.InputChanged, function(Input)
        if Dragging and IsMove(Input.UserInputType) then
            local Delta = Input.Position - StartMouse
            Target.Position = UDim2.new(
                StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
            )
        end
    end)
end

local function SetCollapsed(Container, Arrow, Collapsed, ClosedRotation)
    Container.Visible = not Collapsed
    if Arrow then
        Tween(Arrow, { Rotation = Collapsed and (ClosedRotation or 180) or 0 }, 0.2)
    end
end

function Library:CloseAllPopups(Except)
    for _, Popup in ipairs(Library.Popups) do
        if Popup ~= Except and Popup.Close then
            Popup.Close()
        end
    end
end

local function RegisterPopup(Closer)
    local Object = { Close = Closer }
    table.insert(Library.Popups, Object)
    return Object
end

local Window = {}
Window.__index = Window

local Category = {}
Category.__index = Category

local Groupbox = {}
Groupbox.__index = Groupbox

local function MakeHolder(Parent, Height)
    local Holder = Create("Frame", {
        Name = "ElementHolder",
        Parent = Parent,
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, Height or 0),
    })
    return Holder
end

local function MakeTitle(Parent, Text, Color)
    local Label = Create("TextLabel", {
        Name = "Title",
        Parent = Parent,
        BorderSizePixel = 0,
        TextSize = 13,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Color or Theme.Text,
        AutomaticSize = Enum.AutomaticSize.XY,
        Text = Text,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 4),
        Parent = Label,
    })
    return Label
end

local function MakeDescription(Parent, Text)
    local Label = Create("TextLabel", {
        Name = "Description",
        Parent = Parent,
        TextWrapped = true,
        BorderSizePixel = 0,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Theme.SubText,
        Size = UDim2.new(1, -55, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = Text,
        Position = UDim2.new(0, 0, 0, 24),
    })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingBottom = UDim.new(0, 8), Parent = Label })
    return Label
end

local function BuildGroupbox(Tab, Name)
    local Box = Create("Frame", {
        Name = "Groupbox",
        Parent = Tab.Page,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Panel,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
    })
    Create("UIStroke", { Color = Theme.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Box })
    Create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = Box })
    Create("UIPadding", { PaddingBottom = UDim.new(0, 5), Parent = Box })
    MakeShadow(Box, { Color = Color3.fromRGB(140, 140, 170), Size = 8, Transparency = 0.82, Offset = Vector2.new(0, 0) })

    local Title = Create("TextLabel", {
        Name = "GroupboxTitle",
        Parent = Box,
        BorderSizePixel = 0,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Theme.GroupboxTitle,
        Size = UDim2.new(0, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = Name,
    })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = Title })

    local Arrow = Create("ImageButton", {
        Name = "GroupboxArrow",
        Parent = Box,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        ImageColor3 = Theme.CategoryTitle,
        AnchorPoint = Vector2.new(1, 0),
        Image = Assets.Arrow,
        Size = UDim2.new(0, 15, 0, 15),
        Position = UDim2.new(1, -8, 0, 8),
    })

    local Container = Create("Frame", {
        Name = "Container",
        Parent = Box,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 31),
    })
    Create("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Container })

    local Self = setmetatable({}, Groupbox)
    Self.Window = Tab.Window
    Self.Box = Box
    Self.Container = Container
    Self.Arrow = Arrow
    Self.Collapsed = false
    Self.Name = Name

    Arrow.MouseButton1Click:Connect(function()
        Self.Collapsed = not Self.Collapsed
        SetCollapsed(Container, Arrow, Self.Collapsed, 180)
    end)
    Arrow.MouseEnter:Connect(function()
        Tween(Arrow, { Rotation = (Self.Collapsed and 180 or 0) + 20 }, 0.15)
    end)
    Arrow.MouseLeave:Connect(function()
        Tween(Arrow, { Rotation = Self.Collapsed and 180 or 0 }, 0.15)
    end)

    function Self:SetCollapsed(State)
        Self.Collapsed = State
        SetCollapsed(Container, Arrow, State, 180)
    end

    table.insert(Collapsibles, Self)
    return Self
end

function Library:CreateWindow(Config)
    Config = Config or {}

    if getgenv()._ZeroWindow then
        pcall(function()
            getgenv()._ZeroWindow:Unload()
        end)
        getgenv()._ZeroWindow = nil
    end

    if not Config.GameName then
        pcall(function()
            Config.GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
        end)
    end

    local Screen = Create("ScreenGui", {
        Name = "Zero",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = GetGuiParent(),
    })

    local Main = Create("Frame", {
        Name = "MainFrame",
        Parent = Screen,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Background,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = Config.Position or UDim2.fromScale(0.5, 0.5),
        Size = IsMobile and UDim2.fromScale(0.92, 0.8) or (Config.Size or UDim2.fromOffset(960, 580)),
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Main })
    Create("UIStroke", { Transparency = 0.5, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Stroke, Parent = Main })
    MakeShadow(Main, { Color = Color3.fromRGB(180, 180, 200), Size = 20, Transparency = 0.7, Offset = Vector2.new(0, 0) })

    if Settings.DragImage then
        RegisterFadesEnabled = false
        local DragSrc = Settings.DragImage
        if type(DragSrc) == "string" and DragSrc:match("^https?://") then
            local DragFile = "ZeroHub/drag_image_v2.png"
            pcall(function()
                if not isfile(DragFile) then
                    writefile(DragFile, game:HttpGet(DragSrc))
                end
            end)
            DragSrc = DragFile
        end
        local Img = ResolveAsset(DragSrc)
        if Img then
            DragImageLabel = Create("ImageLabel", {
                Name = "DragImage", Parent = Main, BorderSizePixel = 0,
                BackgroundTransparency = 1, ImageTransparency = 1,
                Image = Img, ScaleType = Enum.ScaleType.Fit,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = Settings.DragImageSize,
                Rotation = Settings.DragImageRotation or 0,
                Visible = false, ZIndex = 50,
            })
        end
        RegisterFadesEnabled = true
    end

    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = Main,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Panel,
        Size = UDim2.new(1, 0, 0, 45),
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = TopBar })
    Create("Frame", {
        Name = "Line",
        Parent = TopBar,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Stroke,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
    })

    local TopHolder = Create("Frame", {
        Parent = TopBar,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 470, 1, 0),
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        FillDirection = Enum.FillDirection.Horizontal,
        Parent = TopHolder,
    })

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = TopHolder,
        LayoutOrder = 1,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = InterSemiBold,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = Config.Title or "ZERO",
    })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = TitleLabel })

    if Config.GameName then
        local GameName = Create("TextLabel", {
            Name = "GameName",
            Parent = TopHolder,
            LayoutOrder = 2,
            BorderSizePixel = 0,
            TextSize = 12,
            BackgroundColor3 = Theme.AccentText,
            FontFace = InterSemiBold,
            TextColor3 = Color3.fromRGB(12, 12, 16),
            Size = UDim2.new(0, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = Config.GameName,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = GameName })
        Create("UIPadding", { PaddingRight = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), Parent = GameName })
        RegisterAccent(function()
            GameName.BackgroundColor3 = Theme.AccentText
        end)
    end

    local function AddBadge(Text, Order)
        local Badge = Create("TextLabel", {
            Parent = TopHolder,
            LayoutOrder = Order,
            BorderSizePixel = 0,
            TextSize = 12,
            BackgroundColor3 = Theme.Panel,
            FontFace = InterSemiBold,
            TextColor3 = Theme.DimText,
            Size = UDim2.new(0, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = Text,
        })
        Create("UIStroke", { Color = Theme.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Badge })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Badge })
        Create("UIPadding", { PaddingRight = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), Parent = Badge })
        return Badge
    end

    AddBadge(Config.Version or "v0.0.0", 3)
    local ExecBadge = AddBadge("0 executions", 4)

    local function MakeTopButton(Image, Width, RightOffset)
        return Create("ImageButton", {
            Parent = TopBar,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            ImageColor3 = Theme.DimText,
            AnchorPoint = Vector2.new(1, 0.5),
            Image = Image,
            Size = UDim2.new(0, Width, 0, 25),
            Position = UDim2.new(1, RightOffset, 0.5, 0),
        })
    end

    local CloseButton = MakeTopButton(Assets.Close, 25, -10)
    local MinimizeButton = MakeTopButton(Assets.Minimize, 18, -45)

    local TabsHolder = Create("Frame", {
        Name = "TabsHolder",
        Parent = Main,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 180, 1, -47),
        Position = UDim2.new(0, 0, 0, 46),
    })
    Create("Frame", {
        Name = "Line",
        Parent = TabsHolder,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Stroke,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
    })

    local TabsScroller = Create("ScrollingFrame", {
        Name = "ActualTabsHolder",
        Parent = TabsHolder,
        Active = true,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
    })
    Create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabsScroller })
    Create("UIPadding", { PaddingTop = UDim.new(0, 10), Parent = TabsScroller })

    local GroupboxesHolder = Create("Frame", {
        Name = "GroupboxesHolder",
        Parent = Main,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(1, -180, 1, -46),
        Position = UDim2.new(1, 0, 1, 0),
    })

    local Backdrop = Create("TextButton", {
        Name = "Backdrop",
        Parent = Main,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 100,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Backdrop })

    local Self = setmetatable({}, Window)
    Self.Screen = Screen
    Self.Main = Main
    Self.TopBar = TopBar
    Self.TabsScroller = TabsScroller
    Self.GroupboxesHolder = GroupboxesHolder
    Self.Backdrop = Backdrop
    Self.ExecBadge = ExecBadge
    Self.Categories = {}
    Self.Tabs = {}

    DragHideTargets = { TopBar, TabsHolder, GroupboxesHolder }
    Self.ActiveTab = nil
    Self.Minimized = false
    Self.OpenPopupCount = 0

    MakeDraggable(TopBar, Main)

    local function HoverButton(Button)
        Button.MouseEnter:Connect(function()
            Tween(Button, { ImageColor3 = Color3.fromRGB(255, 255, 255) }, 0.15)
        end)
        Button.MouseLeave:Connect(function()
            Tween(Button, { ImageColor3 = Theme.DimText }, 0.15)
        end)
    end
    HoverButton(CloseButton)
    HoverButton(MinimizeButton)

    CloseButton.MouseButton1Click:Connect(function()
        Self:Unload()
    end)
    MinimizeButton.MouseButton1Click:Connect(function()
        Main.Visible = false
        if Settings.CursorEnabled then
            UserInputService.MouseIconEnabled = true
        end
        Library:Notify({ Title = "Menu Hidden", Description = "Press " .. (Self.ToggleKey and Self.ToggleKey.Name or "Right Shift") .. " to reopen the menu.", Type = "Info", Duration = 5 })
    end)

    Backdrop.MouseButton1Click:Connect(function()
        Library:CloseAllPopups()
    end)

    if Settings.CursorEnabled then
        local Cursor = Instance.new("ImageLabel")
        Cursor.Name = "Cursor"
        Cursor.BackgroundTransparency = 1
        Cursor.Image = Settings.CursorImage
        Cursor.ImageColor3 = Settings.CursorColor
        Cursor.Size = UDim2.fromOffset(Settings.CursorSize.X, Settings.CursorSize.Y)
        Cursor.AnchorPoint = Vector2.new(0, 0)
        Cursor.ZIndex = 9999
        Cursor.Parent = Screen
        Self.Cursor = Cursor

        Hook(RunService.RenderStepped, function()
            Cursor.Visible = Main.Visible
            if Main.Visible then
                local Mouse = UserInputService:GetMouseLocation()
                Cursor.Position = UDim2.fromOffset(Mouse.X + Settings.CursorOffset.X, Mouse.Y + Settings.CursorOffset.Y)
            end
        end)

        UserInputService.MouseIconEnabled = false
    end

    Self.ToggleKey = Config.ToggleKey or Enum.KeyCode.RightShift
    pcall(function()
        if isfile("ZeroHub/Zero_MenuKey.txt") then
            local Saved = Enum.KeyCode[readfile("ZeroHub/Zero_MenuKey.txt")]
            if Saved then
                Self.ToggleKey = Saved
            end
        end
    end)

    if Config.ToggleKey ~= false then
        Hook(UserInputService.InputBegan, function(Input, GameProcessed)
            if not GameProcessed and Input.KeyCode == Self.ToggleKey then
                Main.Visible = not Main.Visible
                if Settings.CursorEnabled then
                    UserInputService.MouseIconEnabled = not Main.Visible
                end
            end
        end)
    end

    if IsMobile then
        local MobileButton = Create("TextButton", {
            Name = "MobileToggle",
            Parent = Screen,
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Accent,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.fromOffset(48, 48),
            ZIndex = 9998,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = MobileButton })
        Create("UIStroke", { Color = Theme.Stroke, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = MobileButton })

        for _, YOffset in ipairs({ -7, 0, 7 }) do
            Create("Frame", {
                Parent = MobileButton,
                BorderSizePixel = 0,
                BackgroundColor3 = Theme.AccentText,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, YOffset),
                Size = UDim2.fromOffset(22, 3),
            })
        end

        MobileButton.MouseButton1Click:Connect(function()
            Main.Visible = not Main.Visible
        end)
    end

    pcall(function()
        Self:SetExecutions(Executions.Increment())
    end)

    Library.Window = Self
    getgenv()._ZeroWindow = Self
    return Self
end

function Window:ShowBackdrop()
    self.OpenPopupCount = self.OpenPopupCount + 1
    self.Backdrop.Visible = true
    Tween(self.Backdrop, { BackgroundTransparency = 0.5 }, 0.15)
end

function Window:HideBackdrop()
    self.OpenPopupCount = math.max(0, self.OpenPopupCount - 1)
    if self.OpenPopupCount == 0 then
        Tween(self.Backdrop, { BackgroundTransparency = 1 }, 0.15)
        task.delay(0.16, function()
            if self.OpenPopupCount == 0 then
                self.Backdrop.Visible = false
            end
        end)
    end
end

function Window:SetMinimized(State)
    self.Minimized = State
    if State then
        self.FullSize = self.Main.Size
        self.Main.ClipsDescendants = true
        Tween(self.Main, { Size = UDim2.new(self.Main.Size.X.Scale, self.Main.Size.X.Offset, 0, 45) }, 0.25)
    else
        Tween(self.Main, { Size = self.FullSize or UDim2.fromOffset(960, 580) }, 0.25)
        task.delay(0.26, function()
            self.Main.ClipsDescendants = false
        end)
    end
end

function Window:SetExecutions(Count)
    self.ExecBadge.Text = tostring(Count) .. " executions"
end

function Window:Unload()
    for _, Connection in ipairs(Library.Connections) do
        pcall(function()
            Connection:Disconnect()
        end)
    end
    Library.Connections = {}
    pcall(function()
        UserInputService.MouseIconEnabled = true
    end)
    if NotifyHolder then
        pcall(function()
            NotifyHolder.Parent:Destroy()
        end)
        NotifyHolder = nil
    end
    ActiveNotifs = {}
    if TooltipGui then
        pcall(function() TooltipGui:Destroy() end)
        TooltipGui = nil
    end
    if getgenv()._ZeroWindow == self then
        getgenv()._ZeroWindow = nil
    end
    if self.Screen then
        self.Screen:Destroy()
    end
end

function Window:AddCategory(Name)
    local Holder = Create("Frame", {
        Name = "TabCategory",
        Parent = self.TabsScroller,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
    })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = Holder })

    local Title = Create("TextLabel", {
        Name = "TabTitle",
        Parent = Holder,
        LayoutOrder = 1,
        BorderSizePixel = 0,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Theme.CategoryTitle,
        Size = UDim2.new(1, 0, 0, 30),
        Text = Name,
    })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = Title })

    local Arrow = Create("ImageButton", {
        Name = "TabArrow",
        Parent = Title,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        ImageColor3 = Theme.CategoryTitle,
        AnchorPoint = Vector2.new(1, 0.5),
        Image = Assets.Arrow,
        Size = UDim2.new(0, 15, 0, 15),
        Position = UDim2.new(1, -10, 0.5, 2),
    })

    local Container = Create("Frame", {
        Name = "TabsContainer",
        Parent = Holder,
        LayoutOrder = 2,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
    })
    Create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Container })

    local Self = setmetatable({}, Category)
    Self.Window = self
    Self.Holder = Holder
    Self.Container = Container
    Self.Arrow = Arrow
    Self.Collapsed = false
    Self.Name = Name

    Arrow.MouseButton1Click:Connect(function()
        Self.Collapsed = not Self.Collapsed
        SetCollapsed(Container, Arrow, Self.Collapsed, 180)
    end)
    Arrow.MouseEnter:Connect(function()
        Tween(Arrow, { Rotation = (Self.Collapsed and 180 or 0) + 20 }, 0.15)
    end)
    Arrow.MouseLeave:Connect(function()
        Tween(Arrow, { Rotation = Self.Collapsed and 180 or 0 }, 0.15)
    end)

    table.insert(self.Categories, Self)
    table.insert(Collapsibles, Self)
    return Self
end

function Category:AddTab(Name)
    local Window2 = self.Window

    local Label = Create("TextLabel", {
        Name = "Tab",
        Parent = self.Container,
        BorderSizePixel = 0,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Theme.TabUnselected,
        Size = UDim2.new(1, 0, 0, 20),
        Text = Name,
    })
    local Padding = Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = Label })

    local Line = Create("Frame", {
        Name = "SelectedTabLine",
        Parent = Label,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.AccentText,
        AnchorPoint = Vector2.new(0, 1),
        Size = UDim2.new(0, 0, 0, 5),
        Position = UDim2.new(0, 0, 1, 5),
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Line })
    RegisterAccent(function()
        Line.BackgroundColor3 = Theme.AccentText
    end)

    local Button = Create("TextButton", {
        Parent = Label,
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
    })

    local Page = Create("ScrollingFrame", {
        Name = "Page",
        Parent = Window2.GroupboxesHolder,
        Active = true,
        Visible = false,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
    })
    Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Page })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 8),
        Parent = Page,
    })

    local Tab = {}
    Tab.Window = Window2
    Tab.Label = Label
    Tab.Padding = Padding
    Tab.Line = Line
    Tab.Page = Page
    Tab.Selected = false

    function Tab.AddGroupbox(_, GroupboxName)
        return BuildGroupbox(Tab, GroupboxName)
    end

    function Tab:Select()
        if Window2.ActiveTab == Tab then
            return
        end
        local Previous = Window2.ActiveTab
        Window2.ActiveTab = Tab

        if Previous then
            Previous.Selected = false
            Previous.Page.Visible = false
            Tween(Previous.Label, { TextColor3 = Theme.TabUnselected, Size = UDim2.new(1, 0, 0, 20) }, 0.13)
            Tween(Previous.Padding, { PaddingBottom = UDim.new(0, 0) }, 0.13)
            Tween(Previous.Line, { Size = UDim2.new(0, 0, 0, 5) }, 0.13)
        end

        Tab.Selected = true
        Page.Visible = true
        RevealPage(Page)
        Tween(Label, { TextColor3 = Theme.TabSelected, Size = UDim2.new(1, 0, 0, 28) }, 0.13)
        Tween(Padding, { PaddingBottom = UDim.new(0, 3) }, 0.13)
        Tween(Line, { Size = UDim2.new(0, 13, 0, 5) }, 0.15)
    end

    Button.MouseEnter:Connect(function()
        if not Tab.Selected then
            Tween(Label, { TextColor3 = Color3.fromRGB(140, 140, 150) }, 0.15)
        end
    end)
    Button.MouseLeave:Connect(function()
        if not Tab.Selected then
            Tween(Label, { TextColor3 = Theme.TabUnselected }, 0.15)
        end
    end)
    Button.MouseButton1Click:Connect(function()
        Tab:Select()
    end)

    table.insert(Window2.Tabs, Tab)
    if not Window2.ActiveTab then
        Tab:Select()
    end
    return Tab
end

function Category:SetCollapsed(State)
    self.Collapsed = State
    SetCollapsed(self.Container, self.Arrow, State, 180)
end

function Groupbox:AddToggle(Flag, Options)
    Options = Options or {}
    local Holder = MakeHolder(self.Container)
    local Title = MakeTitle(Holder, Options.Text or "Toggle", Theme.Text)
    if Options.Description then
        MakeDescription(Holder, Options.Description)
    end

    HookTooltip(Holder, Options)

    local Checkmark = Create("Frame", {
        Name = "Checkmark",
        Parent = Holder,
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.ElementBackground,
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -8, 0.5, 0),
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Checkmark })
    local BoxStroke = Create("UIStroke", { Thickness = 1.3, Color = Theme.ElementStroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Checkmark })
    local CheckShadow = MakeShadow(Checkmark, { Color = Color3.fromRGB(200, 200, 220), Size = 4, Transparency = 1, Offset = Vector2.new(0, 0) })

    local Glow = Create("Frame", {
        Name = "Glow",
        Parent = Checkmark,
        ZIndex = 0,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = Glow })
    local GlowStroke = Create("UIStroke", { Thickness = 2, Color = Theme.Accent, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 1, Parent = Glow })

    local Tick = Create("ImageLabel", {
        Parent = Checkmark,
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(210, 210, 220),
        ImageTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = Assets.Check,
        Size = UDim2.new(0, 13, 0, 13),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })

    local Click = Create("TextButton", {
        Name = "ButtonToEnableCheckbox",
        Parent = Checkmark,
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 4,
    })

    local Toggle = {}
    Toggle.Type = "Toggle"
    Toggle.Flag = Flag
    Toggle.Value = Options.Default or false
    Toggle.Callback = Options.Callback
    Toggle.Holder = Holder
    Toggle.Window = self.Window

    local function Visual()
        if Toggle.Value then
            Tween(Checkmark, { BackgroundColor3 = Theme.Accent }, 0.15)
            Tween(BoxStroke, { Transparency = 0, Color = Theme.AccentText }, 0.15)
            Tween(Tick, { ImageTransparency = 0 }, 0.15)
            Tween(GlowStroke, { Transparency = 0, Color = Theme.AccentText }, 0.15)
            Tween(Title, { TextColor3 = Theme.Title }, 0.15)
            if CheckShadow then pcall(function() Tween(CheckShadow, { Transparency = 0.3, Size = 12 }, 0.2) end) end
        else
            Tween(Checkmark, { BackgroundColor3 = Theme.ElementBackground }, 0.15)
            Tween(BoxStroke, { Transparency = 0, Color = Theme.ElementStroke, Thickness = 1.3 }, 0.15)
            Tween(Tick, { ImageTransparency = 1 }, 0.15)
            Tween(GlowStroke, { Transparency = 1 }, 0.15)
            Tween(Title, { TextColor3 = Theme.Text }, 0.15)
            if CheckShadow then pcall(function() Tween(CheckShadow, { Transparency = 1, Size = 4 }, 0.2) end) end
        end
    end

    function Toggle:SetValue(Value, SkipCallback)
        Toggle.Value = Value and true or false
        Library.Flags[Flag] = Toggle.Value
        Visual()
        if not SkipCallback then
            SafeCall(Toggle.Callback, Toggle.Value)
        end
    end

    function Toggle:OnChanged(Callback)
        Toggle.Callback = Callback
    end

    Click.MouseEnter:Connect(function()
        if not Toggle.Value then
            Tween(BoxStroke, { Transparency = 0.5, Thickness = 2 }, 0.15)
        end
    end)
    Click.MouseLeave:Connect(function()
        if not Toggle.Value then
            Tween(BoxStroke, { Transparency = 0, Thickness = 1.3 }, 0.15)
        end
    end)
    Click.MouseButton1Click:Connect(function()
        Toggle:SetValue(not Toggle.Value)
    end)

    if Flag then
        Library.Flags[Flag] = Toggle.Value
        Library.Options[Flag] = Toggle
    end
    Visual()
    RegisterAccent(Visual)

    function Toggle.AddKeybind(_, KeyOptions)
        return Library:BindKeybind(Toggle, KeyOptions or {})
    end

    return Toggle
end

function Groupbox:AddSlider(Flag, Options)
    Options = Options or {}
    local Min = Options.Min or 0
    local Max = Options.Max or 100
    local Decimals = Options.Decimals or 0
    local Suffix = Options.Suffix or ""
    local HasDesc = Options.Description ~= nil

    local Holder = MakeHolder(self.Container, HasDesc and nil or 38)
    Holder.AutomaticSize = HasDesc and Enum.AutomaticSize.Y or Enum.AutomaticSize.None

    HookTooltip(Holder, Options)

    local Title = Create("TextLabel", {
        Name = "SliderTitle",
        Parent = Holder,
        BorderSizePixel = 0,
        TextSize = 13,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Theme.Text,
        AutomaticSize = Enum.AutomaticSize.XY,
        Text = Options.Text or "Slider",
    })
    Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 10), PaddingBottom = UDim.new(0, 4), Parent = Title })

    local Track = Create("Frame", {
        Name = "Track",
        Parent = Holder,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.SliderTrack,
        AnchorPoint = HasDesc and Vector2.new(0.5, 0) or Vector2.new(0.5, 1),
        Size = UDim2.new(1, -20, 0, 6),
        Position = HasDesc and UDim2.new(0.5, 0, 0, 35) or UDim2.new(0.5, 0, 1, -5),
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

    local Fill = Create("Frame", {
        Name = "Fill",
        Parent = Track,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.SliderFill,
        Size = UDim2.new(0, 0, 1, 0),
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })

    local Knob = Create("Frame", {
        Name = "Knob",
        Parent = Track,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(240, 240, 245),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 0, 0.5, 0),
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
    Create("UIStroke", { Thickness = 1, Color = Color3.fromRGB(60, 60, 72), Transparency = 0.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Knob })
    MakeShadow(Knob, { Color = Color3.fromRGB(220, 220, 240), Size = 8, Transparency = 0.5, Offset = Vector2.new(0, 0) })

    local ValueLabel = Create("TextBox", {
        Name = "ValueLabel",
        Parent = Holder,
        BorderSizePixel = 0,
        TextSize = 13,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Theme.Text,
        AnchorPoint = Vector2.new(1, 1),
        AutomaticSize = Enum.AutomaticSize.XY,
        Text = "0",
        ClearTextOnFocus = true,
        Position = UDim2.new(1, -8, 1, -15),
    })

    if HasDesc then
        local Desc = MakeDescription(Holder, Options.Description)
        Desc.Position = UDim2.new(0, 0, 0, 45)
        ValueLabel.AnchorPoint = Vector2.new(1, 0)
        ValueLabel.Position = UDim2.new(1, -8, 0, 8)
    end

    local Slider = {}
    Slider.Type = "Slider"
    Slider.Flag = Flag
    Slider.Value = Options.Default or Min
    Slider.Callback = Options.Callback

    local function Round(Number)
        if Decimals <= 0 then
            return math.floor(Number + 0.5)
        end
        local Mult = 10 ^ Decimals
        return math.floor(Number * Mult + 0.5) / Mult
    end

    local function Visual()
        local Alpha = math.clamp((Slider.Value - Min) / (Max - Min), 0, 1)
        Tween(Fill, { Size = UDim2.new(Alpha, 0, 1, 0) }, 0.1)
        Tween(Knob, { Position = UDim2.new(Alpha, 0, 0.5, 0) }, 0.1)
        ValueLabel.Text = tostring(Slider.Value) .. Suffix
    end

    ValueLabel.FocusLost:Connect(function(Enter)
        local Raw = ValueLabel.Text:gsub(Suffix, "")
        local Num = tonumber(Raw)
        if Num then
            Slider:SetValue(Num)
        else
            Visual()
        end
    end)

    function Slider:SetValue(Value, SkipCallback)
        Slider.Value = Round(math.clamp(Value, Min, Max))
        Library.Flags[Flag] = Slider.Value
        Visual()
        if not SkipCallback then
            SafeCall(Slider.Callback, Slider.Value)
        end
    end

    local Dragging = false
    local function UpdateFromPos(pos)
        local Alpha = (pos.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
        Slider:SetValue(Min + (Max - Min) * math.clamp(Alpha, 0, 1))
    end

    Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Tween(Title, { TextColor3 = Theme.Title }, 0.15)
            Tween(ValueLabel, { TextColor3 = Theme.Title }, 0.15)
            Tween(Knob, { Size = UDim2.new(0, 12, 0, 12) }, 0.1)
            UpdateFromPos(Input.Position)
        end
    end)
    Hook(UserInputService.InputChanged, function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            UpdateFromPos(Input.Position)
        end
    end)
    Hook(UserInputService.InputEnded, function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then
            Dragging = false
            Tween(Title, { TextColor3 = Theme.Text }, 0.15)
            Tween(ValueLabel, { TextColor3 = Theme.Text }, 0.15)
            Tween(Knob, { Size = UDim2.new(0, 14, 0, 14) }, 0.1)
        end
    end)

    if Flag then
        Library.Flags[Flag] = Slider.Value
        Library.Options[Flag] = Slider
    end
    Visual()

    return Slider
end

function Groupbox:AddButton(Options)
    Options = Options or {}
    local Holder = MakeHolder(self.Container, 35)
    Holder.AutomaticSize = Enum.AutomaticSize.None

    HookTooltip(Holder, Options)

    local UsesAccent = false
    local Color = Options.Color or Theme.ButtonDefault

    local ButtonFrame = Create("Frame", {
        Name = "Button",
        Parent = Holder,
        BorderSizePixel = 0,
        BackgroundColor3 = Color,
        BackgroundTransparency = 0.4,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, -15, 1, -10),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ButtonFrame })
    local StrokeColor = Options.Color or Theme.ButtonDefaultStroke
    local ButtonStroke = Create("UIStroke", { Color = StrokeColor, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = ButtonFrame })
    MakeShadow(ButtonFrame, { Color = Color3.fromRGB(160, 160, 190), Size = 6, Transparency = 0.8, Offset = Vector2.new(0, 0) })

    local Click = Create("TextButton", {
        Parent = ButtonFrame,
        BorderSizePixel = 0,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        Size = UDim2.new(1, 0, 1, 0),
        Text = Options.Text or "Button",
    })

    local Button = {}
    Button.Type = "Button"
    Button.Func = Options.Func or Options.Callback
    local Confirming = false
    local Hovering = false

    Click.MouseEnter:Connect(function()
        Hovering = true
        Tween(ButtonFrame, { BackgroundTransparency = 0.2 }, 0.15)
    end)
    Click.MouseLeave:Connect(function()
        Hovering = false
        Tween(ButtonFrame, { BackgroundTransparency = 0.4 }, 0.15)
    end)
    Click.MouseButton1Down:Connect(function()
        Tween(ButtonFrame, { BackgroundTransparency = 0 }, 0.08)
    end)
    Click.MouseButton1Up:Connect(function()
        Tween(ButtonFrame, { BackgroundTransparency = Hovering and 0.2 or 0.4 }, 0.1)
    end)
    Click.MouseButton1Click:Connect(function()
        if Options.DoubleClick and not Confirming then
            Confirming = true
            Click.Text = "Are you sure?"
            task.delay(2, function()
                if Confirming then
                    Confirming = false
                    Click.Text = Options.Text or "Button"
                end
            end)
            return
        end
        Confirming = false
        Click.Text = Options.Text or "Button"
        SafeCall(Button.Func)
    end)

    function Button:SetColor(NewColor)
        Color = NewColor
        ButtonFrame.BackgroundColor3 = NewColor
        ButtonStroke.Color = NewColor
    end

    function Button:SetText(Text)
        Click.Text = Text
    end

    return Button
end

function Groupbox:AddInput(Flag, Options)
    Options = Options or {}
    local Holder = MakeHolder(self.Container)
    HookTooltip(Holder, Options)
    MakeTitle(Holder, Options.Text or "Input", Theme.Title)
    if Options.Description then
        MakeDescription(Holder, Options.Description)
    end

    local Box = Create("Frame", {
        Name = "Textbox",
        Parent = Holder,
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.ElementBackground,
        AnchorPoint = Vector2.new(1, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, -5),
        Position = UDim2.new(1, -8, 0.5, 0),
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Box })
    Create("UIStroke", { Color = Theme.TextboxStroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Box })
    Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), Parent = Box })

    local TextBox = Create("TextBox", {
        Parent = Box,
        BorderSizePixel = 0,
        TextSize = 12,
        TextColor3 = Theme.TextboxText,
        PlaceholderColor3 = Color3.fromRGB(90, 90, 100),
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.XY,
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        ClearTextOnFocus = Options.ClearOnFocus == true,
        Text = Options.Default or "",
        PlaceholderText = Options.Placeholder or "Write Here..",
    })

    local Input = {}
    Input.Type = "Input"
    Input.Flag = Flag
    Input.Value = Options.Default or ""
    Input.Callback = Options.Callback

    function Input:SetValue(Value, SkipCallback)
        Input.Value = tostring(Value)
        TextBox.Text = Input.Value
        if Flag then
            Library.Flags[Flag] = Input.Value
        end
        if not SkipCallback then
            SafeCall(Input.Callback, Input.Value)
        end
    end

    TextBox.FocusLost:Connect(function(EnterPressed)
        if Options.EnterOnly and not EnterPressed then
            TextBox.Text = Input.Value
            return
        end
        Input.Value = TextBox.Text
        if Flag then
            Library.Flags[Flag] = Input.Value
        end
        SafeCall(Input.Callback, Input.Value)
    end)

    if Flag then
        Library.Flags[Flag] = Input.Value
        Library.Options[Flag] = Input
    end

    return Input
end

function Groupbox:AddLabel(Text, Color)
    local Holder = MakeHolder(self.Container)
    local Label = Create("TextLabel", {
        Name = "Label",
        Parent = Holder,
        BorderSizePixel = 0,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Color or Theme.SubText,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, -20, 0, 0),
        Text = Text or "",
    })
    Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 10), PaddingBottom = UDim.new(0, 4), Parent = Label })

    local LabelObj = {}
    LabelObj.Type = "Label"
    LabelObj.Label = Label

    function LabelObj:SetText(NewText)
        Label.Text = NewText
    end

    function LabelObj:SetColor(NewColor)
        Label.TextColor3 = NewColor
    end

    return LabelObj
end

function Groupbox:AddDivider()
    local Holder = Create("Frame", {
        Name = "LineHolder",
        Parent = self.Container,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 5),
    })
    Create("Frame", {
        Name = "Line",
        Parent = Holder,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Line,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, -15, 0, 1),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })
    return Holder
end

function Groupbox:AddDropdown(Flag, Options)
    Options = Options or {}
    local Multi = Options.Multi or false

    local Holder = MakeHolder(self.Container)
    HookTooltip(Holder, Options)
    local DropTitle = MakeTitle(Holder, Options.Text or "Dropdown", Theme.Text)
    if Options.Description then
        MakeDescription(Holder, Options.Description)
    end

    local Control = Create("Frame", {
        Name = "Dropdown",
        Parent = Holder,
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.ElementBackground,
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 160, 0, 28),
        Position = UDim2.new(1, -8, 0.5, 0),
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Control })
    Create("UIStroke", { Color = Theme.ElementStroke, Transparency = 0.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Control })
    MakeShadow(Control, { Color = Color3.fromRGB(140, 140, 170), Size = 5, Transparency = 0.82, Offset = Vector2.new(0, 0) })

    local ArrowImage = Create("ImageLabel", {
        Name = "DropdownArrows",
        Parent = Control,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ImageColor3 = Theme.DropdownArrow,
        AnchorPoint = Vector2.new(1, 0.5),
        Image = Assets.DropdownArrow,
        Size = UDim2.new(0, 11, 0, 11),
        Rotation = 90,
        Position = UDim2.new(1, -6, 0.5, 0),
    })

    local Display = Create("TextLabel", {
        Name = "IfDropdownBlank",
        Parent = Control,
        BorderSizePixel = 0,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Theme.DropdownBlank,
        Size = UDim2.new(1, -28, 1, 0),
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = "--",
        Position = UDim2.new(0, 8, 0, 0),
    })

    local ClickButton = Create("TextButton", {
        Parent = Control,
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
    })

    local Dropdown = {}
    Dropdown.Type = "Dropdown"
    Dropdown.Flag = Flag
    Dropdown.Values = Options.Values or {}
    Dropdown.Multi = Multi
    Dropdown.Value = Multi and (type(Options.Default) == "table" and Options.Default or {}) or Options.Default
    Dropdown.Callback = Options.Callback
    Dropdown.Open = false

    local Popup
    local PopupParts
    local Catcher

    local function UpdateDisplay()
        if Multi then
            Display.Text = #Dropdown.Value > 0 and table.concat(Dropdown.Value, ", ") or "--"
        else
            Display.Text = Dropdown.Value or "--"
        end
    end

    local function IsSelected(Item)
        if Multi then
            for _, Selected in ipairs(Dropdown.Value) do
                if Selected == Item then
                    return true
                end
            end
            return false
        end
        return Dropdown.Value == Item
    end

    local function ClosePopup()
        if not Dropdown.Open then
            return
        end
        Dropdown.Open = false
        Tween(ArrowImage, { ImageColor3 = Theme.DropdownArrow }, 0.15)
        Tween(DropTitle, { TextColor3 = Theme.Text }, 0.15)
        if Catcher then
            Catcher:Destroy()
            Catcher = nil
        end
        if Popup then
            FadePopupOut(Popup, PopupParts)
            Popup = nil
        end
    end

    RegisterPopup(ClosePopup)

    local function OpenPopup()
        Library:CloseAllPopups()
        Dropdown.Open = true
        Tween(ArrowImage, { ImageColor3 = Theme.AccentText }, 0.15)
        Tween(DropTitle, { TextColor3 = Theme.Title }, 0.15)

        Catcher = Create("TextButton", {
            Name = "DropdownCatcher",
            Parent = self.Window.Screen,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 109,
        })
        Catcher.MouseButton1Click:Connect(function()
            ClosePopup()
        end)

        local ItemCount = #Dropdown.Values
        local PopupHeight = math.min(ItemCount * 24 + 12 + (ItemCount >= 8 and 30 or 0), 220)
        Popup = Create("ScrollingFrame", {
            Name = "OpenDropdown",
            Parent = self.Window.Screen,
            Active = true,
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.ElementBackground,
            Size = UDim2.new(0, Control.AbsoluteSize.X, 0, PopupHeight),
            Position = UDim2.fromOffset(
                Control.AbsolutePosition.X + Settings.DropdownMenuOffset.X,
                Control.AbsolutePosition.Y + Control.AbsoluteSize.Y + Settings.DropdownMenuOffset.Y
            ),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ZIndex = 110,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Popup })
        Create("UIStroke", { Thickness = 1, Color = Theme.ElementStroke, Transparency = 0.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Popup })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = Popup })
        Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = Popup })

        local SearchBox
        if ItemCount >= 8 then
            local SearchHolder = Create("Frame", {
                Name = "SearchHolder", Parent = Popup, LayoutOrder = 0,
                BorderSizePixel = 0, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24), ZIndex = 111,
            })
            SearchBox = Create("TextBox", {
                Name = "Search", Parent = SearchHolder, BorderSizePixel = 0,
                TextSize = 12, BackgroundColor3 = Theme.Panel,
                FontFace = InterSemiBold, TextColor3 = Theme.TextboxText,
                PlaceholderColor3 = Color3.fromRGB(70, 70, 80),
                PlaceholderText = "Search...", Text = "",
                TextXAlignment = Enum.TextXAlignment.Left,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, -10, 0, 20),
                ClearTextOnFocus = false, ZIndex = 112,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = SearchBox })
            Create("UIStroke", { Color = Theme.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = SearchBox })
            Create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = SearchBox })
        end

        local OptionFrames = {}
        local Refreshers = {}
        for _, Item in ipairs(Dropdown.Values) do
            local Selected = IsSelected(Item)
            local Option = Create("TextLabel", {
                Parent = Popup,
                LayoutOrder = 1,
                BorderSizePixel = 0,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                FontFace = InterSemiBold,
                TextColor3 = Selected and Theme.AccentText or Theme.Text,
                Size = UDim2.new(1, 0, 0, 24),
                Text = Item,
                ZIndex = 111,
            })
            local OptionPad = Create("UIPadding", { PaddingLeft = UDim.new(0, Selected and 18 or 10), Parent = Option })

            local OptionButton = Create("TextButton", {
                Parent = Option,
                Text = "",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 112,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = OptionButton })

            local function Refresh()
                if IsSelected(Item) then
                    Tween(Option, { TextColor3 = Theme.AccentText }, 0.15)
                    Tween(OptionPad, { PaddingLeft = UDim.new(0, 18) }, 0.15)
                else
                    Tween(Option, { TextColor3 = Theme.Text }, 0.15)
                    Tween(OptionPad, { PaddingLeft = UDim.new(0, 10) }, 0.15)
                end
            end
            table.insert(Refreshers, Refresh)

            OptionButton.MouseEnter:Connect(function()
                Tween(OptionButton, { BackgroundTransparency = 0.92 }, 0.12)
                if not IsSelected(Item) then
                    Tween(Option, { TextColor3 = Color3.fromRGB(150, 150, 158) }, 0.12)
                    Tween(OptionPad, { PaddingLeft = UDim.new(0, 14) }, 0.12)
                end
            end)
            OptionButton.MouseLeave:Connect(function()
                Tween(OptionButton, { BackgroundTransparency = 1 }, 0.12)
                if not IsSelected(Item) then
                    Tween(Option, { TextColor3 = Theme.Text }, 0.12)
                    Tween(OptionPad, { PaddingLeft = UDim.new(0, 10) }, 0.12)
                end
            end)
            OptionButton.MouseButton1Click:Connect(function()
                if Multi then
                    if IsSelected(Item) then
                        for Index, Selected2 in ipairs(Dropdown.Value) do
                            if Selected2 == Item then
                                table.remove(Dropdown.Value, Index)
                                break
                            end
                        end
                    else
                        table.insert(Dropdown.Value, Item)
                    end
                    Refresh()
                    Library.Flags[Flag] = Dropdown.Value
                    UpdateDisplay()
                    SafeCall(Dropdown.Callback, Dropdown.Value)
                else
                    Dropdown.Value = Item
                    Library.Flags[Flag] = Item
                    for _, R in ipairs(Refreshers) do
                        R()
                    end
                    UpdateDisplay()
                    SafeCall(Dropdown.Callback, Item)
                end
            end)

            table.insert(OptionFrames, { Frame = Option, Name = Item })
        end

        if SearchBox then
            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local Query = SearchBox.Text:lower()
                for _, Entry in ipairs(OptionFrames) do
                    Entry.Frame.Visible = Query == "" or Entry.Name:lower():find(Query, 1, true) ~= nil
                end
            end)
            task.defer(function()
                if SearchBox and SearchBox.Parent then
                    SearchBox:CaptureFocus()
                end
            end)
        end

        PopupParts = FadePopupIn(Popup)
    end

    ClickButton.MouseButton1Click:Connect(function()
        if Dropdown.Open then
            ClosePopup()
        else
            OpenPopup()
        end
    end)

    function Dropdown:SetValue(Value, SkipCallback)
        Dropdown.Value = Value
        Library.Flags[Flag] = Value
        UpdateDisplay()
        if not SkipCallback then
            SafeCall(Dropdown.Callback, Value)
        end
    end

    function Dropdown:SetValues(NewValues)
        Dropdown.Values = NewValues
        if Dropdown.Open then
            ClosePopup()
        end
    end

    if Flag then
        Library.Flags[Flag] = Dropdown.Value
        Library.Options[Flag] = Dropdown
    end
    UpdateDisplay()

    return Dropdown
end

function Groupbox:AddTable(TitleText, Options)
    Options = Options or {}
    local Columns = Options.Columns or {}
    local ColumnCount = math.max(#Columns, 1)
    local ColumnScale = 1 / ColumnCount

    local Holder = Create("Frame", {
        Name = "TableComponentsHolder",
        Parent = self.Container,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
    })

    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Holder,
        BorderSizePixel = 0,
        TextSize = 13,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextColor3 = Theme.TableTitle,
        AutomaticSize = Enum.AutomaticSize.XY,
        Text = TitleText or "Table",
    })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = Title })

    local TableFrame = Create("Frame", {
        Name = "TableComponents",
        Parent = Holder,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0.5, 0, 0, 20),
    })
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = TableFrame })

    local function MakeRow(Background)
        local Row = Create("Frame", {
            Parent = TableFrame,
            BorderSizePixel = 0,
            BackgroundColor3 = Background,
            Size = UDim2.new(1, 0, 0, 28),
        })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, Parent = Row })
        return Row
    end

    local function MakeCell(Row, Text)
        local Cell = Create("Frame", {
            Parent = Row,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Size = UDim2.new(ColumnScale, 0, 1, 0),
        })
        Create("UIStroke", { Thickness = 0.51, Color = Theme.TableStroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Cell })
        Create("TextLabel", {
            Parent = Cell,
            BorderSizePixel = 0,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            FontFace = InterSemiBold,
            TextColor3 = Theme.TableText,
            Size = UDim2.new(1, 0, 1, 0),
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = Text or "",
        }, { Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })
        return Cell
    end

    local Header = MakeRow(Theme.TableHeader)
    Header.Name = "Titles"
    for _, ColumnName in ipairs(Columns) do
        MakeCell(Header, ColumnName)
    end

    local Table = {}
    Table.Type = "Table"
    Table.Rows = {}

    function Table:AddRow(Data)
        local Row = MakeRow(Theme.TableRow)
        for Index = 1, ColumnCount do
            MakeCell(Row, Data[Index] and tostring(Data[Index]) or "")
        end
        table.insert(Table.Rows, Row)
        return Row
    end

    function Table:Clear()
        for _, Row in ipairs(Table.Rows) do
            Row:Destroy()
        end
        Table.Rows = {}
    end

    function Table:SetRows(RowList)
        Table:Clear()
        for _, Data in ipairs(RowList) do
            Table:AddRow(Data)
        end
    end

    if Options.Rows then
        Table:SetRows(Options.Rows)
    end

    return Table
end

function Library:OpenColorPicker(ColorPicker, Swatch)
    local Window2 = Library.Window
    Library:CloseAllPopups()

    local OriginalColor = ColorPicker.Value
    if typeof(OriginalColor) ~= "Color3" then
        OriginalColor = Color3.fromRGB(255, 255, 255)
        ColorPicker.Value = OriginalColor
    end
    local H, S, V = Color3.toHSV(OriginalColor)

    local DarkBG = Create("TextButton", {
        Name = "DarkBG",
        Parent = Window2.Main,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.65,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 120,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = DarkBG })

    local Holder = Create("Frame", {
        Name = "ColorpickerHolder",
        Parent = Window2.Main,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Panel,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 350, 0, 250),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex = 121,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Holder })
    Create("UIStroke", { Color = Theme.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Holder })

    local TopBar = Create("Frame", { Name = "TopBar", Parent = Holder, BorderSizePixel = 0, BackgroundColor3 = Theme.Panel, Size = UDim2.new(1, 0, 0, 40), ZIndex = 121 })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TopBar })
    Create("Frame", { Name = "Line", Parent = TopBar, BorderSizePixel = 0, BackgroundColor3 = Theme.Stroke, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), ZIndex = 121 })
    local TitleLabel = Create("TextLabel", { Parent = TopBar, BorderSizePixel = 0, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, FontFace = InterSemiBold, TextColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 150, 1, 0), Text = "Select Color", ZIndex = 122 })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = TitleLabel })
    local CloseBtn = Create("ImageButton", { Parent = TopBar, BorderSizePixel = 0, AutoButtonColor = false, BackgroundTransparency = 1, ImageColor3 = Theme.DimText, AnchorPoint = Vector2.new(1, 0.5), Image = Assets.Close, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -10, 0.5, 0), ZIndex = 122 })

    local Canvas = Create("Frame", { Name = "ColorCanvas", Parent = Holder, BorderSizePixel = 0, BackgroundColor3 = Color3.fromHSV(H, 1, 1), Size = UDim2.new(0, 155, 0, 150), Position = UDim2.new(0, 10, 0, 55), ZIndex = 121 })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Canvas })
    local SatFrame = Create("Frame", { Name = "SaturationFrame", Parent = Canvas, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(1, 0, 1, 0), ZIndex = 121 })
    Create("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = SatFrame })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = SatFrame })
    local ValFrame = Create("Frame", { Name = "ValueFrame", Parent = Canvas, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(0, 0, 0), Size = UDim2.new(1, 0, 1, 0), ZIndex = 121 })
    Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }), Parent = ValFrame })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = ValFrame })
    local PickerKnob = Create("Frame", { Name = "PickerKnob", Parent = Canvas, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(S, 0, 1 - V, 0), ZIndex = 122 })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = PickerKnob })
    Create("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1.5, Parent = PickerKnob })

    local HueBar = Create("Frame", { Name = "HueBar", Parent = Holder, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 15, 0, 150), Position = UDim2.new(0, 175, 0, 55), ZIndex = 121 })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = HueBar })
    Create("UIGradient", { Rotation = 90, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    }), Parent = HueBar })
    local HueKnob = Create("Frame", { Name = "HueKnob", Parent = HueBar, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1, 4, 0, 5), Position = UDim2.new(0.5, 0, H, 0), ZIndex = 122 })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = HueKnob })

    local NewFrame = Create("Frame", { Name = "NewColorFrame", Parent = Holder, BorderSizePixel = 0, BackgroundColor3 = OriginalColor, Size = UDim2.new(0, 55, 0, 30), Position = UDim2.new(0, 205, 0, 71), ZIndex = 121 })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = NewFrame })
    Create("UIStroke", { Color = Theme.Stroke, Parent = NewFrame })
    Create("TextLabel", { Parent = NewFrame, BorderSizePixel = 0, TextSize = 13, BackgroundTransparency = 1, FontFace = InterSemiBold, TextColor3 = Color3.fromRGB(93, 93, 106), Size = UDim2.new(1, 0, 0, 10), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 0, -3), Text = "New", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 122 })

    local CurFrame = Create("Frame", { Name = "CurrentColorFrame", Parent = Holder, BorderSizePixel = 0, BackgroundColor3 = OriginalColor, Size = UDim2.new(0, 55, 0, 30), Position = UDim2.new(0, 270, 0, 71), ZIndex = 121 })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = CurFrame })
    Create("UIStroke", { Color = Theme.Stroke, Parent = CurFrame })
    Create("TextLabel", { Parent = CurFrame, BorderSizePixel = 0, TextSize = 13, BackgroundTransparency = 1, FontFace = InterSemiBold, TextColor3 = Color3.fromRGB(93, 93, 106), Size = UDim2.new(1, 0, 0, 10), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 0, -3), Text = "Current", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 122 })

    local SavedHolder = Create("Frame", { Name = "SavedColorsHolder", Parent = Holder, BorderSizePixel = 0, BackgroundTransparency = 1, Size = UDim2.new(0, 145, 0, 60), Position = UDim2.new(0, 200, 0, 130), ZIndex = 121 })
    Create("TextLabel", { Parent = SavedHolder, BorderSizePixel = 0, TextSize = 13, BackgroundTransparency = 1, FontFace = InterSemiBold, TextColor3 = Color3.fromRGB(93, 93, 106), Size = UDim2.new(1, 0, 0, 12), Text = "Saved Colours", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 122 })
    local SavedRow = Create("ScrollingFrame", { Parent = SavedHolder, Active = true, BorderSizePixel = 0, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -18), Position = UDim2.new(0, 0, 0, 18), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 0, ZIndex = 121 })
    Create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Parent = SavedRow })

    local CurrentColor = function()
        return Color3.fromHSV(H, S, V)
    end

    local function Refresh()
        Canvas.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
        Tween(PickerKnob, { Position = UDim2.new(S, 0, 1 - V, 0) }, 0.06, Enum.EasingStyle.Linear)
        Tween(HueKnob, { Position = UDim2.new(0.5, 0, H, 0) }, 0.06, Enum.EasingStyle.Linear)
        NewFrame.BackgroundColor3 = CurrentColor()
        ColorPicker.Value = CurrentColor()
        Swatch.BackgroundColor3 = ColorPicker.Value
        if ColorPicker.Flag then
            Library.Flags[ColorPicker.Flag] = ColorPicker.Value
        end
        SafeCall(ColorPicker.Callback, ColorPicker.Value)
    end

    local PlusIcon = Create("Frame", { Name = "PlusIcon", Parent = SavedRow, LayoutOrder = 0, BorderSizePixel = 0, BackgroundColor3 = Theme.Panel, Size = UDim2.new(0, 17, 0, 17), ZIndex = 122 })
    Create("UIStroke", { Color = Theme.Stroke, Parent = PlusIcon })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = PlusIcon })
    local PlusButton = Create("TextButton", { Parent = PlusIcon, BorderSizePixel = 0, TextSize = 15, BackgroundTransparency = 1, FontFace = InterSemiBold, TextColor3 = Theme.Text, Size = UDim2.new(1, 0, 1, 0), Text = "+", ZIndex = 123 })

    local function AddSavedSwatch(Color)
        local Sw = Create("Frame", { Parent = SavedRow, LayoutOrder = #ColorPicker.Saved, BorderSizePixel = 0, BackgroundColor3 = Color, Size = UDim2.new(0, 17, 0, 17), ZIndex = 122 })
        Create("UIStroke", { Color = Theme.Stroke, Parent = Sw })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Sw })
        local SwBtn = Create("TextButton", { Parent = Sw, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 123 })
        SwBtn.MouseButton1Click:Connect(function()
            if typeof(Color) == "Color3" then
                H, S, V = Color3.toHSV(Color)
                Refresh()
            end
        end)
    end

    for _, Color in ipairs(ColorPicker.Saved) do
        AddSavedSwatch(Color)
    end

    PlusButton.MouseButton1Click:Connect(function()
        table.insert(ColorPicker.Saved, CurrentColor())
        AddSavedSwatch(CurrentColor())
    end)

    local function MakeButton(Text, RightOffset, Background, HoverColor)
        local Frame = Create("Frame", { Parent = Holder, BorderSizePixel = 0, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Size = UDim2.new(0, 65, 0, 25), Position = UDim2.new(1, RightOffset, 1, -10), ZIndex = 121 })
        Create("UIStroke", { Color = Theme.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Frame })
        local Button = Create("TextButton", { Parent = Frame, BorderSizePixel = 0, TextSize = 13, AutoButtonColor = false, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Background, FontFace = InterSemiBold, Size = UDim2.new(1, 0, 1, 0), Text = Text, ZIndex = 122 })
        Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = Button })
        Button.MouseEnter:Connect(function()
            Tween(Button, { BackgroundColor3 = HoverColor }, 0.15)
        end)
        Button.MouseLeave:Connect(function()
            Tween(Button, { BackgroundColor3 = Background }, 0.15)
        end)
        return Button
    end
    local ConfirmBtn = MakeButton("Confirm", -10, Theme.Accent, Theme.AccentHover)
    local CancelBtn = MakeButton("Cancel", -85, Color3.fromRGB(13, 13, 17), Color3.fromRGB(24, 24, 30))

    local DraggingCanvas, DraggingHue = false, false
    local function UpdateCanvas(Position)
        S = math.clamp((Position.X - Canvas.AbsolutePosition.X) / Canvas.AbsoluteSize.X, 0, 1)
        V = 1 - math.clamp((Position.Y - Canvas.AbsolutePosition.Y) / Canvas.AbsoluteSize.Y, 0, 1)
        Refresh()
    end
    local function UpdateHue(Position)
        H = math.clamp((Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
        Refresh()
    end

    Canvas.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            DraggingCanvas = true
            UpdateCanvas(Input.Position)
        end
    end)
    HueBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            DraggingHue = true
            UpdateHue(Input.Position)
        end
    end)
    local MoveConn = UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            if DraggingCanvas then
                UpdateCanvas(Input.Position)
            end
            if DraggingHue then
                UpdateHue(Input.Position)
            end
        end
    end)
    local EndConn = UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            DraggingCanvas = false
            DraggingHue = false
        end
    end)

    local Closed = false
    local function Close(Apply)
        if Closed then
            return
        end
        Closed = true
        MoveConn:Disconnect()
        EndConn:Disconnect()
        if not Apply then
            ColorPicker:SetValue(OriginalColor)
        end
        FadePopupOut(Holder)
        Tween(DarkBG, { BackgroundTransparency = 1 }, 0.12)
        task.delay(0.13, function()
            DarkBG:Destroy()
        end)
    end

    CloseBtn.MouseButton1Click:Connect(function()
        Close(false)
    end)
    CancelBtn.MouseButton1Click:Connect(function()
        Close(false)
    end)
    ConfirmBtn.MouseButton1Click:Connect(function()
        Close(true)
    end)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { ImageColor3 = Color3.fromRGB(255, 255, 255) }, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { ImageColor3 = Theme.DimText }, 0.15)
    end)
    PlusButton.MouseEnter:Connect(function()
        Tween(PlusButton, { TextColor3 = Color3.fromRGB(180, 180, 190) }, 0.15)
    end)
    PlusButton.MouseLeave:Connect(function()
        Tween(PlusButton, { TextColor3 = Theme.Text }, 0.15)
    end)

    Refresh()

    DarkBG.BackgroundTransparency = 1
    Tween(DarkBG, { BackgroundTransparency = 0.65 }, 0.12)
    FadePopupIn(Holder)
end

function Groupbox:AddColorPicker(Flag, Options)
    Options = Options or {}
    local Default = Options.Default or Color3.fromRGB(255, 255, 255)

    local Holder = MakeHolder(self.Container)
    HookTooltip(Holder, Options)
    MakeTitle(Holder, Options.Text or "Colorpicker", Theme.Title)
    if Options.Description then
        MakeDescription(Holder, Options.Description)
    end

    local Swatch = Create("Frame", {
        Name = "Colorpicker",
        Parent = Holder,
        ZIndex = 2,
        BorderSizePixel = 0,
        BackgroundColor3 = Default,
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -8, 0.5, 0),
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Swatch })
    local SwatchButton = Create("TextButton", { Parent = Swatch, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 3 })

    local ColorPicker = {}
    ColorPicker.Type = "ColorPicker"
    ColorPicker.Flag = Flag
    ColorPicker.Value = Default
    ColorPicker.Callback = Options.Callback
    ColorPicker.Saved = {}

    function ColorPicker:SetValue(Color, SkipCallback)
        ColorPicker.Value = Color
        Swatch.BackgroundColor3 = Color
        if Flag then
            Library.Flags[Flag] = Color
        end
        if not SkipCallback then
            SafeCall(ColorPicker.Callback, Color)
        end
    end

    SwatchButton.MouseButton1Click:Connect(function()
        Library:OpenColorPicker(ColorPicker, Swatch)
    end)

    if Flag then
        Library.Flags[Flag] = ColorPicker.Value
        Library.Options[Flag] = ColorPicker
    end

    return ColorPicker
end

function Library:BindKeybind(Toggle, Options)
    local Window2 = Toggle.Window or Library.Window
    local Holder = Toggle.Holder

    local CogHolder = Create("Frame", {
        Name = "Keybind",
        Parent = Holder,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -35, 0.5, 0),
        ZIndex = 5,
    })
    local Cog = Create("ImageButton", {
        Parent = CogHolder,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        ImageColor3 = Theme.CogClosed,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = Assets.Cog,
        Size = UDim2.new(1, -3, 1, -3),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex = 5,
    })

    local Keybind = {}
    Keybind.Mode = Options.Mode or "Toggle"
    Keybind.Key = Options.Default
    Keybind.Callback = Options.Callback
    Keybind.Listening = false
    Keybind.Menu = nil
    Keybind.MenuParts = nil

    local function KeyName()
        if not Keybind.Key then
            return ". . ."
        end
        return Keybind.Key.Name
    end

    local function CloseMenu()
        if not Keybind.Menu then
            return
        end
        local Menu = Keybind.Menu
        local Parts = Keybind.MenuParts
        Keybind.Menu = nil
        Keybind.Listening = false
        if Keybind.Catcher then
            Keybind.Catcher:Destroy()
            Keybind.Catcher = nil
        end
        Tween(Cog, { Rotation = 0, ImageColor3 = Theme.CogClosed }, 0.2)
        FadePopupOut(Menu, Parts)
    end

    RegisterPopup(CloseMenu)

    local function OpenMenu()
        Library:CloseAllPopups()
        Tween(Cog, { Rotation = 90, ImageColor3 = Theme.CogOpen }, 0.2)

        Keybind.Catcher = Create("TextButton", {
            Name = "KeybindCatcher",
            Parent = Window2.Screen,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 109,
        })
        Keybind.Catcher.MouseButton1Click:Connect(function()
            CloseMenu()
        end)

        local Menu = Create("Frame", {
            Name = "OpenKeybindMenu",
            Parent = Window2.Screen,
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.Panel,
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.new(0, 180, 0, 65),
            Position = UDim2.fromOffset(
                Cog.AbsolutePosition.X + Cog.AbsoluteSize.X + Settings.KeybindMenuOffset.X,
                Cog.AbsolutePosition.Y + Cog.AbsoluteSize.Y + Settings.KeybindMenuOffset.Y
            ),
            ZIndex = 110,
        })
        Keybind.Menu = Menu
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Menu })
        Create("UIStroke", { Thickness = 1.5, Color = Theme.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Menu })

        local Inner = Create("Frame", {
            Name = "OpenKeybindMenuHolder",
            Parent = Menu,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            ZIndex = 111,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Inner })
        Create("UIStroke", { Thickness = 1.5, Color = Theme.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Inner })

        Create("ImageLabel", {
            Parent = Inner,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ImageColor3 = Theme.KeybindMenuText,
            Image = Assets.KeybindIcon,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 5, 0, 3),
            ZIndex = 111,
        })
        Create("TextLabel", {
            Parent = Inner,
            BorderSizePixel = 0,
            TextSize = 13,
            BackgroundTransparency = 1,
            FontFace = InterSemiBold,
            TextColor3 = Theme.KeybindMenuText,
            Size = UDim2.new(0, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "Keybind",
            Position = UDim2.new(0, 27, 0, 3),
            ZIndex = 111,
        })
        local KeyLabel = Create("TextLabel", {
            Name = "ActualKeybind",
            Parent = Inner,
            BorderSizePixel = 0,
            TextSize = 13,
            BackgroundTransparency = 1,
            FontFace = InterSemiBold,
            TextColor3 = Theme.KeybindMenuText,
            AnchorPoint = Vector2.new(1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 0, 20),
            Text = KeyName(),
            Position = UDim2.new(1, -10, 0, 3),
            ZIndex = 111,
        })
        Keybind.KeyLabel = KeyLabel

        local KeyButton = Create("TextButton", {
            Parent = Inner,
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 60, 0, 20),
            Position = UDim2.new(1, -65, 0, 3),
            ZIndex = 112,
        })

        local ButtonRow = Create("Frame", {
            Name = "Toggle/Hold Button",
            Parent = Inner,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 1, -5),
            ZIndex = 111,
        })
        Create("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            Parent = ButtonRow,
        })

        local ToggleFrame, HoldFrame

        local function MakeModeButton(ModeName, Order)
            local Frame = Create("Frame", {
                Name = ModeName,
                Parent = ButtonRow,
                LayoutOrder = Order,
                BorderSizePixel = 0,
                BackgroundColor3 = Keybind.Mode == ModeName and Theme.Accent or Theme.KeybindModeOff,
                Size = UDim2.new(0, 78, 1, 0),
                ZIndex = 111,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Frame })
            Create("UIStroke", { Color = Theme.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Frame })
            local Click = Create("TextButton", {
                Parent = Frame,
                BorderSizePixel = 0,
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                FontFace = InterSemiBold,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ModeName,
                ZIndex = 112,
            })
            return Frame, Click
        end

        local ToggleFrame2, ToggleClick = MakeModeButton("Toggle", 1)
        local HoldFrame2, HoldClick = MakeModeButton("Hold", 2)
        ToggleFrame = ToggleFrame2
        HoldFrame = HoldFrame2

        local function RefreshMode()
            Tween(ToggleFrame, { BackgroundColor3 = Keybind.Mode == "Toggle" and Theme.Accent or Theme.KeybindModeOff }, 0.15)
            Tween(HoldFrame, { BackgroundColor3 = Keybind.Mode == "Hold" and Theme.Accent or Theme.KeybindModeOff }, 0.15)
        end

        ToggleClick.MouseButton1Click:Connect(function()
            Keybind.Mode = "Toggle"
            RefreshMode()
        end)
        HoldClick.MouseButton1Click:Connect(function()
            Keybind.Mode = "Hold"
            RefreshMode()
        end)

        KeyButton.MouseButton1Click:Connect(function()
            if Keybind.Listening then
                return
            end
            Keybind.Listening = true
            task.spawn(function()
                local Frames = { ".", ". .", ". . ." }
                local Index = 1
                while Keybind.Listening and Keybind.KeyLabel do
                    Keybind.KeyLabel.Text = Frames[Index]
                    Index = Index % 3 + 1
                    task.wait(0.25)
                end
            end)
        end)

        Keybind.MenuParts = FadePopupIn(Menu)
    end

    Cog.MouseButton1Click:Connect(function()
        if Keybind.Menu then
            CloseMenu()
        else
            OpenMenu()
        end
    end)

    Hook(UserInputService.InputBegan, function(Input, GameProcessed)
        if Keybind.Listening and Input.UserInputType == Enum.UserInputType.Keyboard then
            Keybind.Key = Input.KeyCode
            Keybind.Listening = false
            if Keybind.KeyLabel then
                Keybind.KeyLabel.Text = KeyName()
            end
            return
        end
        if GameProcessed then
            return
        end
        if Keybind.Key and Input.KeyCode == Keybind.Key then
            if Keybind.Mode == "Toggle" then
                Toggle:SetValue(not Toggle.Value)
            else
                Toggle:SetValue(true)
            end
            SafeCall(Keybind.Callback, Keybind.Key)
        end
    end)

    Hook(UserInputService.InputEnded, function(Input)
        if Keybind.Mode == "Hold" and Keybind.Key and Input.KeyCode == Keybind.Key then
            Toggle:SetValue(false)
        end
    end)

    Toggle.Keybind = Keybind
    return Keybind
end

local NotifyKinds = {
    Info = { Icon = "rbxassetid://83474456355516", Color = Color3.fromRGB(121, 121, 231) },
    Success = { Icon = "rbxassetid://104017061818006", Color = Color3.fromRGB(56, 186, 91) },
    Warning = { Icon = "rbxassetid://121692565210966", Color = Color3.fromRGB(206, 146, 46) },
    Error = { Icon = "rbxassetid://87330550858647", Color = Color3.fromRGB(206, 51, 66) },
}

local function ReflowNotifs()
    local Offset = 8
    for _, Entry in ipairs(ActiveNotifs) do
        Tween(Entry.Gui, { Position = UDim2.new(1, -8, 1, -Offset) }, 0.25, Enum.EasingStyle.Quint)
        Offset = Offset + Entry.Gui.AbsoluteSize.Y + 6
    end
end

function Library:Notify(Options)
    Options = Options or {}
    local Kind = NotifyKinds[Options.Type] or NotifyKinds.Info
    local Duration = Options.Duration or 5

    if not NotifyHolder then
        local Screen = Create("ScreenGui", {
            Name = "EthosNotifications",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            DisplayOrder = 9999,
            Parent = GetGuiParent(),
        })
        NotifyHolder = Create("Frame", {
            Name = "Holder",
            Parent = Screen,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
        })
    end

    RegisterFadesEnabled = false

    local Gui = Create("CanvasGroup", {
        Name = "Notification",
        Parent = NotifyHolder,
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Panel,
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 270, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(1, 320, 1, -8),
        GroupTransparency = 1,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Gui })
    Create("UIStroke", { Transparency = 0.5, Thickness = 1.5, Color = Color3.fromRGB(50, 50, 66), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = Gui })
    Create("UISizeConstraint", { MinSize = Vector2.new(270, 46), Parent = Gui })
    MakeShadow(Gui, { Color = Color3.fromRGB(160, 160, 190), Size = 14, Transparency = 0.6, Offset = Vector2.new(0, 0) })

    Create("ImageLabel", {
        Name = "Icon",
        Parent = Gui,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ImageColor3 = Kind.Color,
        AnchorPoint = Vector2.new(0, 0.5),
        Image = Kind.Icon,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(0, 8, 0.5, 0),
    })

    local TextHolder = Create("Frame", {
        Name = "TextHolder",
        Parent = Gui,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(1, -50, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TextHolder })
    Create("UIPadding", { PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 12), Parent = TextHolder })

    Create("TextLabel", {
        Name = "Title",
        Parent = TextHolder,
        LayoutOrder = 1,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        FontFace = InterSemiBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(235, 235, 240),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        Text = Options.Title or "Notification",
    })

    if Options.Description then
        Create("TextLabel", {
            Name = "Description",
            Parent = TextHolder,
            LayoutOrder = 2,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            FontFace = InterSemiBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(135, 135, 143),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            Text = Options.Description,
        })
    end

    local TimeLine = Create("Frame", {
        Name = "TimeRemainingLine",
        Parent = Gui,
        BorderSizePixel = 0,
        BackgroundColor3 = Kind.Color,
        AnchorPoint = Vector2.new(0, 1),
        Size = UDim2.new(1, -50, 0, 3),
        Position = UDim2.new(0, 0, 1, 0),
    })

    local Click = Create("TextButton", {
        Parent = Gui,
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 5,
    })

    RegisterFadesEnabled = true

    local Entry = { Gui = Gui }
    table.insert(ActiveNotifs, 1, Entry)

    local function Dismiss()
        if Entry.Dismissed then
            return
        end
        Entry.Dismissed = true
        for Index, Value in ipairs(ActiveNotifs) do
            if Value == Entry then
                table.remove(ActiveNotifs, Index)
                break
            end
        end
        Tween(Gui, { Position = Gui.Position + UDim2.fromOffset(330, 0), GroupTransparency = 1 }, 0.3, Enum.EasingStyle.Quint)
        ReflowNotifs()
        task.delay(0.32, function()
            if Gui then
                Gui:Destroy()
            end
        end)
    end

    Click.MouseButton1Click:Connect(Dismiss)

    task.wait()
    ReflowNotifs()
    Tween(Gui, { GroupTransparency = 0 }, 0.25)
    Tween(TimeLine, { Size = UDim2.new(0, -50, 0, 3) }, Duration, Enum.EasingStyle.Linear)
    task.delay(Duration, Dismiss)

    return { Dismiss = Dismiss }
end

function Library:SetAccent(Color)
    Theme.Accent = Color
    Theme.AccentHover = Color:Lerp(Color3.new(1, 1, 1), 0.12)
    Theme.AccentClick = Color:Lerp(Color3.new(1, 1, 1), 0.22)
    Theme.AccentText = Color
    for _, Updater in ipairs(AccentTargets) do
        pcall(Updater)
    end
end

function Library:CreateSettingsTab(Window)
    local ConfigFolder = "ZeroHub/Zero_Configs"
    local AutoloadPath = "ZeroHub/Zero_Autoload.txt"
    pcall(function()
        if not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
    end)

    local function ListConfigs()
        local Names = {}
        pcall(function()
            for _, File in ipairs(listfiles(ConfigFolder)) do
                local Name = tostring(File):match("([^/\\]+)%.json$")
                if Name then
                    table.insert(Names, Name)
                end
            end
        end)
        return Names
    end

    local function SerializeValue(Value)
        if typeof(Value) == "Color3" then
            return { __type = "Color3", R = math.floor(Value.R * 255 + 0.5), G = math.floor(Value.G * 255 + 0.5), B = math.floor(Value.B * 255 + 0.5) }
        end
        return Value
    end

    local function DeserializeValue(Raw)
        if type(Raw) == "table" and Raw.__type == "Color3" then
            return Color3.fromRGB(Raw.R or 255, Raw.G or 255, Raw.B or 255)
        end
        return Raw
    end

    local function CaptureConfig()
        local Data = { Flags = {}, Saved = {}, Keybinds = {}, Collapsed = {} }
        for Flag, Option in pairs(Library.Options) do
            if not tostring(Flag):match("^_") then
                if Option.Value ~= nil then
                    Data.Flags[Flag] = SerializeValue(Option.Value)
                end
                if Option.Type == "ColorPicker" and Option.Saved then
                    local List = {}
                    for _, Saved in ipairs(Option.Saved) do
                        table.insert(List, SerializeValue(Saved))
                    end
                    Data.Saved[Flag] = List
                end
                if Option.Type == "Toggle" and Option.Keybind and Option.Keybind.Key then
                    Data.Keybinds[Flag] = { Key = Option.Keybind.Key.Name, Mode = Option.Keybind.Mode }
                end
            end
        end
        for _, Item in ipairs(Collapsibles) do
            Data.Collapsed[Item.Name] = Item.Collapsed and true or false
        end
        return Data
    end

    local function ApplyConfig(Data)
        if type(Data) ~= "table" then
            return
        end
        for Flag, Raw in pairs(Data.Flags or {}) do
            local Option = Library.Options[Flag]
            if Option and Option.SetValue then
                pcall(function()
                    Option:SetValue(DeserializeValue(Raw))
                end)
            end
        end
        for Flag, List in pairs(Data.Saved or {}) do
            local Option = Library.Options[Flag]
            if Option and Option.Type == "ColorPicker" then
                Option.Saved = {}
                for _, Saved in ipairs(List) do
                    table.insert(Option.Saved, DeserializeValue(Saved))
                end
            end
        end
        for Flag, Bind in pairs(Data.Keybinds or {}) do
            local Option = Library.Options[Flag]
            if Option and Option.Keybind then
                Option.Keybind.Mode = Bind.Mode or Option.Keybind.Mode
                if Bind.Key and Enum.KeyCode[Bind.Key] then
                    Option.Keybind.Key = Enum.KeyCode[Bind.Key]
                end
            end
        end
        for Name, State in pairs(Data.Collapsed or {}) do
            for _, Item in ipairs(Collapsibles) do
                if Item.Name == Name and Item.SetCollapsed then
                    pcall(function()
                        Item:SetCollapsed(State)
                    end)
                    break
                end
            end
        end
    end

    local function SaveConfig(Name)
        if not Name or Name == "" then
            Library:Notify({ Title = "Config", Description = "Enter a config name first.", Type = "Warning" })
            return false
        end
        local Ok = pcall(function()
            writefile(ConfigFolder .. "/" .. Name .. ".json", HttpService:JSONEncode(CaptureConfig()))
        end)
        Library:Notify({ Title = "Config", Description = Ok and ("Saved '" .. Name .. "'.") or "Failed to save.", Type = Ok and "Success" or "Error" })
        return Ok
    end

    local function LoadConfig(Name)
        if not Name or Name == "" then
            Library:Notify({ Title = "Config", Description = "Select a config to load.", Type = "Warning" })
            return
        end
        local Ok, Data = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFolder .. "/" .. Name .. ".json"))
        end)
        if Ok and type(Data) == "table" then
            ApplyConfig(Data)
            Library:Notify({ Title = "Config", Description = "Loaded '" .. Name .. "'.", Type = "Success" })
        else
            Library:Notify({ Title = "Config", Description = "Failed to load.", Type = "Error" })
        end
    end

    local Category = Window:AddCategory("SETTINGS")
    local Tab = Category:AddTab("Configuration")

    local PremadeOrder = { "Violet", "Crimson", "Emerald", "Amber", "Rose", "Cyan", "Mono" }
    local PremadeThemes = {
        ["Violet"] = Color3.fromRGB(138, 121, 231),
        ["Crimson"] = Color3.fromRGB(206, 51, 66),
        ["Emerald"] = Color3.fromRGB(56, 186, 91),
        ["Amber"] = Color3.fromRGB(206, 146, 46),
        ["Rose"] = Color3.fromRGB(231, 110, 160),
        ["Cyan"] = Color3.fromRGB(64, 196, 209),
        ["Mono"] = Color3.fromRGB(150, 150, 165),
    }

    local ThemeBox = Tab:AddGroupbox("Theme")
    local AccentPicker = ThemeBox:AddColorPicker("ZeroAccent", {
        Text = "Accent Color",
        Default = Theme.Accent,
        Callback = function(Color)
            Library:SetAccent(Color)
        end,
    })
    local CursorPicker = ThemeBox:AddColorPicker("ZeroCursor", {
        Text = "Cursor Color",
        Default = Settings.CursorColor,
        Callback = function(Color)
            Settings.CursorColor = Color
            if Library.Window and Library.Window.Cursor then
                Library.Window.Cursor.ImageColor3 = Color
            end
        end,
    })
    ThemeBox:AddDropdown("_ZeroPremade", {
        Text = "Premade Themes",
        Values = PremadeOrder,
        Callback = function(Value)
            local Color = PremadeThemes[Value]
            if Color then
                AccentPicker:SetValue(Color)
                CursorPicker:SetValue(Color)
            end
        end,
    })

    local MenuBox = Tab:AddGroupbox("Menu")
    local MenuListening = false
    local MenuKeyButton
    MenuKeyButton = MenuBox:AddButton({
        Text = "Show / Hide Key: " .. Window.ToggleKey.Name,
        Func = function()
            if MenuListening then
                return
            end
            MenuListening = true
            MenuKeyButton:SetText("Press any key...")
        end,
    })
    Hook(UserInputService.InputBegan, function(Input)
        if MenuListening and Input.UserInputType == Enum.UserInputType.Keyboard then
            MenuListening = false
            Window.ToggleKey = Input.KeyCode
            pcall(function()
                writefile("ZeroHub/Zero_MenuKey.txt", Input.KeyCode.Name)
            end)
            MenuKeyButton:SetText("Show / Hide Key: " .. Input.KeyCode.Name)
        end
    end)

    local ConfigBox = Tab:AddGroupbox("Configs")
    local NameInput = ConfigBox:AddInput("_ZeroConfigName", { Text = "Config Name", Placeholder = "MyConfig" })
    local ConfigList = ConfigBox:AddDropdown("_ZeroConfigList", { Text = "Saved Configs", Values = ListConfigs() })

    ConfigBox:AddButton({ Text = "Create / Save", Func = function()
        if SaveConfig(NameInput.Value) then
            ConfigList:SetValues(ListConfigs())
        end
    end })
    ConfigBox:AddButton({ Text = "Overwrite Selected", Func = function()
        if ConfigList.Value and ConfigList.Value ~= "" then
            SaveConfig(ConfigList.Value)
        else
            Library:Notify({ Title = "Config", Description = "Select a config to overwrite.", Type = "Warning" })
        end
    end })
    ConfigBox:AddButton({ Text = "Load", Func = function()
        LoadConfig(ConfigList.Value)
    end })
    ConfigBox:AddButton({ Text = "Delete", Color = Color3.fromRGB(170, 55, 60), Func = function()
        if ConfigList.Value and ConfigList.Value ~= "" then
            pcall(function()
                delfile(ConfigFolder .. "/" .. ConfigList.Value .. ".json")
            end)
            ConfigList:SetValues(ListConfigs())
            Library:Notify({ Title = "Config", Description = "Deleted.", Type = "Success" })
        end
    end })
    ConfigBox:AddButton({ Text = "Refresh List", Color = Color3.fromRGB(70, 70, 86), Func = function()
        ConfigList:SetValues(ListConfigs())
    end })

    ConfigBox:AddDivider()

    ConfigBox:AddButton({ Text = "Set Autoload", Func = function()
        if ConfigList.Value and ConfigList.Value ~= "" then
            pcall(function()
                writefile(AutoloadPath, ConfigList.Value)
            end)
            Library:Notify({ Title = "Autoload", Description = "Autoload set to '" .. ConfigList.Value .. "'.", Type = "Success" })
        end
    end })
    ConfigBox:AddButton({ Text = "Clear Autoload", Color = Color3.fromRGB(70, 70, 86), Func = function()
        pcall(function()
            if isfile(AutoloadPath) then
                delfile(AutoloadPath)
            end
        end)
        Library:Notify({ Title = "Autoload", Description = "Autoload cleared.", Type = "Info" })
    end })

    task.spawn(function()
        task.wait(0.2)
        local Ok, Name = pcall(function()
            if isfile(AutoloadPath) then
                return readfile(AutoloadPath)
            end
        end)
        if Ok and Name and Name ~= "" and isfile(ConfigFolder .. "/" .. Name .. ".json") then
            LoadConfig(Name)
        end
    end)

    return Tab
end

return Library
