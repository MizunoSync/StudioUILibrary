-- Studio UI Library
-- Designed for complete local execution

local Library = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Themes = {
    Dark = {
        AppBg = Color3.fromRGB(32, 33, 36),
        PanelBg = Color3.fromRGB(42, 43, 47),
        InputBg = Color3.fromRGB(31, 32, 35),
        Border = Color3.fromRGB(68, 70, 77),
        Text = Color3.fromRGB(245, 245, 245),
        TextMuted = Color3.fromRGB(203, 203, 203),
        Accent = Color3.fromRGB(11, 105, 208) -- Studio Blue
    }
}

-- Utility: Smooth Dragging
local function MakeDraggable(topbar, window)
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(window, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        end
    end)
end

function Library:CreateWindow(Config)
    Config = Config or {}
    local TitleText = Config.Title or "Studio Library"
    local Theme = Themes.Dark -- Expandable via Config.Theme
    local Size = Config.Size or UDim2.fromOffset(430, 500)
    local Keybind = Config.Keybind or Enum.KeyCode.RightShift

    -- Protect GUI (synapse/krnl bypass if needed, fallback to PlayerGui)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StudioUI"
    ScreenGui.ResetOnSpawn = false
    
    local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
    if not success then ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Size
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.AppBg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Border
    UIStroke.Parent = MainFrame

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 36)
    Topbar.BackgroundColor3 = Theme.PanelBg
    Topbar.BorderSizePixel = 0
    Topbar.Parent = MainFrame
    MakeDraggable(Topbar, MainFrame)

    local TopbarStroke = Instance.new("Frame")
    TopbarStroke.Size = UDim2.new(1, 0, 0, 1)
    TopbarStroke.Position = UDim2.new(0, 0, 1, -1)
    TopbarStroke.BackgroundColor3 = Theme.Border
    TopbarStroke.BorderSizePixel = 0
    TopbarStroke.Parent = Topbar

    local Title = Instance.new("TextLabel")
    Title.Text = TitleText
    Title.Size = UDim2.new(1, -24, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Theme.Text
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    -- Container for Tabs & Content
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, 0, 1, -36)
    ContentContainer.Position = UDim2.new(0, 0, 0, 36)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    -- Tab Bar
    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.BackgroundColor3 = Theme.AppBg
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 0
    TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBar.Parent = ContentContainer

    local TabBarList = Instance.new("UIListLayout")
    TabBarList.FillDirection = Enum.FillDirection.Horizontal
    TabBarList.SortOrder = Enum.SortOrder.LayoutOrder
    TabBarList.Parent = TabBar

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, 0, 1, -30)
    PageContainer.Position = UDim2.new(0, 0, 0, 30)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = ContentContainer

    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Keybind then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil
    }

    -- Notification System
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 270, 1, -20)
    NotifContainer.Position = UDim2.new(1, -290, 0, 10)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 10)
    NotifLayout.Parent = NotifContainer

    function WindowObj:Notify(NotifConfig)
        local TitleText = NotifConfig.Title or "Notification"
        local ContentText = NotifConfig.Content or "..."
        local Duration = NotifConfig.Duration or 3

        local Toast = Instance.new("Frame")
        Toast.Size = UDim2.new(1, 0, 0, 60)
        Toast.BackgroundColor3 = Theme.PanelBg
        Toast.Parent = NotifContainer

        local ToastCorner = Instance.new("UICorner")
        ToastCorner.CornerRadius = UDim.new(0, 6)
        ToastCorner.Parent = Toast

        local ToastStroke = Instance.new("UIStroke")
        ToastStroke.Color = Theme.Accent
        ToastStroke.Thickness = 2
        ToastStroke.Parent = Toast

        local TTitle = Instance.new("TextLabel")
        TTitle.Text = TitleText
        TTitle.Size = UDim2.new(1, -20, 0, 20)
        TTitle.Position = UDim2.new(0, 10, 0, 5)
        TTitle.BackgroundTransparency = 1
        TTitle.TextColor3 = Theme.Text
        TTitle.Font = Enum.Font.GothamBold
        TTitle.TextSize = 13
        TTitle.TextXAlignment = Enum.TextXAlignment.Left
        TTitle.Parent = Toast

        local TContent = Instance.new("TextLabel")
        TContent.Text = ContentText
        TContent.Size = UDim2.new(1, -20, 0, 30)
        TContent.Position = UDim2.new(0, 10, 0, 25)
        TContent.BackgroundTransparency = 1
        TContent.TextColor3 = Theme.TextMuted
        TContent.Font = Enum.Font.Gotham
        TContent.TextSize = 12
        TContent.TextXAlignment = Enum.TextXAlignment.Left
        TContent.TextWrapped = true
        TContent.Parent = Toast

        task.spawn(function()
            task.wait(Duration)
            TweenService:Create(Toast, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(TTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(TContent, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(ToastStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            task.wait(0.3)
            Toast:Destroy()
        end)
    end

    function WindowObj:CreateTab(TabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = TabName
        TabBtn.Text = TabName
        TabBtn.Size = UDim2.new(0, 100, 1, 0)
        TabBtn.BackgroundColor3 = Theme.AppBg
        TabBtn.TextColor3 = Theme.TextMuted
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = TabBar

        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName.."Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = PageContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingLeft = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.Parent = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, btn in pairs(TabBar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.TextColor3 = Theme.TextMuted
                    btn.BackgroundColor3 = Theme.AppBg
                end
            end
            for _, page in pairs(PageContainer:GetChildren()) do
                if page:IsA("ScrollingFrame") then page.Visible = false end
            end
            
            TabBtn.TextColor3 = Theme.Text
            TabBtn.BackgroundColor3 = Theme.PanelBg
            Page.Visible = true
        end)

        if #WindowObj.Tabs == 0 then
            TabBtn.TextColor3 = Theme.Text
            TabBtn.BackgroundColor3 = Theme.PanelBg
            Page.Visible = true
        end
        table.insert(WindowObj.Tabs, TabName)

        local Elements = {}

        function Elements:AddButton(BtnConfig)
            local Btn = Instance.new("TextButton")
            Btn.Text = BtnConfig.Text or "Button"
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.BackgroundColor3 = Theme.Accent
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Btn.Parent = Page

            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

            Btn.MouseButton1Click:Connect(function()
                if BtnConfig.Callback then BtnConfig.Callback() end
            end)
        end

        function Elements:AddToggle(ToggleConfig)
            local State = ToggleConfig.Default or false
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 32)
            Frame.BackgroundColor3 = Theme.PanelBg
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

            local Label = Instance.new("TextLabel")
            Label.Text = ToggleConfig.Text or "Toggle"
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Text = ""
            ToggleBtn.Size = UDim2.new(0, 42, 0, 22)
            ToggleBtn.Position = UDim2.new(1, -52, 0.5, -11)
            ToggleBtn.BackgroundColor3 = State and Theme.Accent or Theme.InputBg
            ToggleBtn.Parent = Frame
            Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 16, 0, 16)
            Indicator.Position = State and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Indicator.BackgroundColor3 = Color3.new(1, 1, 1)
            Indicator.Parent = ToggleBtn
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            ToggleBtn.MouseButton1Click:Connect(function()
                State = not State
                TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = State and Theme.Accent or Theme.InputBg}):Play()
                TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
                if ToggleConfig.Callback then ToggleConfig.Callback(State) end
            end)
        end

        function Elements:AddSlider(SliderConfig)
            local Min = SliderConfig.Min or 0
            local Max = SliderConfig.Max or 100
            local Default = SliderConfig.Default or Min

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 45)
            Frame.BackgroundColor3 = Theme.PanelBg
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

            local Label = Instance.new("TextLabel")
            Label.Text = SliderConfig.Text or "Slider"
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Text = tostring(Default)
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextColor3 = Theme.TextMuted
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = Frame

            local Track = Instance.new("TextButton")
            Track.Text = ""
            Track.Size = UDim2.new(1, -20, 0, 6)
            Track.Position = UDim2.new(0, 10, 0, 28)
            Track.BackgroundColor3 = Theme.InputBg
            Track.Parent = Frame
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((Default - Min)/(Max - Min), 0, 1, 0)
            Fill.BackgroundColor3 = Theme.Accent
            Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local isDragging = false
            local function UpdateSlider(input)
                local sizeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(sizeX, 0, 1, 0)
                local val = math.floor(Min + ((Max - Min) * sizeX))
                ValueLabel.Text = tostring(val)
                if SliderConfig.Callback then SliderConfig.Callback(val) end
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    UpdateSlider(input)
                end
            end)
            Track.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
        end

        return Elements
    end

    return WindowObj
end

return Library
