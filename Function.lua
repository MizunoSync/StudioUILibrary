local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local HubLibrary = {}

-- ==========================================
-- PREMIUM THEME SETTINGS
-- ==========================================
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),      -- Main Hub Background
    Sidebar = Color3.fromRGB(25, 25, 25),         -- Tab Selector Area
    ElementBg = Color3.fromRGB(30, 30, 30),       -- Buttons, Toggles, Sliders
    ElementHover = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 136, 255),         -- Blue Selection/Checkmark Color
    Outline = Color3.fromRGB(45, 45, 45),         -- Subtle borders
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(150, 150, 150),
    Font = Enum.Font.GothamMedium,
    BoldFont = Enum.Font.GothamBold
}

local AnimSpeed = 0.2

-- ==========================================
-- LIBRARY CORE
-- ==========================================
function HubLibrary:CreateWindow(options)
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }
    
    local titleText = options.Name or "Premium Hub"
    
    -- GUI Setup
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PremiumHub_" .. tostring(math.random(1000, 9999))
    ScreenGui.ResetOnSpawn = false
    
    local success = pcall(function() ScreenGui.Parent = CoreGui end)
    if not success then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Main Frame
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", MainFrame).Color = Theme.Outline

    -- Dragging Logic
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y < MainFrame.AbsolutePosition.Y + 40 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Sidebar (Tabs)
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    
    local SidebarLine = Instance.new("Frame", Sidebar)
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.BackgroundColor3 = Theme.Outline
    SidebarLine.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", Sidebar)
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Theme.BoldFont
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = Theme.Accent
    TitleLabel.Text = titleText

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -50)
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Content Area
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -140, 1, 0)
    ContentArea.Position = UDim2.new(0, 140, 0, 0)
    ContentArea.BackgroundTransparency = 1

    -- ==========================================
    -- TABS
    -- ==========================================
    function Window:CreateTab(tabName)
        local Tab = {}
        
        -- Tab Button
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(0.9, 0, 0, 30)
        TabBtn.BackgroundColor3 = Theme.ElementBg
        TabBtn.BackgroundTransparency = 1
        TabBtn.Font = Theme.Font
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = Theme.SubText
        TabBtn.Text = tabName
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        -- Page Scroller
        local Page = Instance.new("ScrollingFrame", ContentArea)
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Theme.Outline
        Page.Visible = false
        
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        -- Auto adjust scrolling frame size
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        table.insert(self.Tabs, {Btn = TabBtn, Page = Page})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(Window.Tabs) do
                TweenService:Create(t.Btn, TweenInfo.new(AnimSpeed), {BackgroundTransparency = 1, TextColor3 = Theme.SubText}):Play()
                t.Page.Visible = false
            end
            TweenService:Create(TabBtn, TweenInfo.new(AnimSpeed), {BackgroundTransparency = 0, TextColor3 = Theme.Text}):Play()
            Page.Visible = true
        end)

        if #self.Tabs == 1 then
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Theme.Text
            Page.Visible = true
        end

        -- ==========================================
        -- ELEMENTS (Buttons, Toggles, Sliders, etc)
        -- ==========================================
        function Tab:CreateLabel(text)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.BoldFont
            Label.TextSize = 14
            Label.TextColor3 = Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Text = text
        end

        function Tab:CreateButton(options)
            local BtnFrame = Instance.new("TextButton", Page)
            BtnFrame.Size = UDim2.new(1, -5, 0, 35)
            BtnFrame.BackgroundColor3 = Theme.ElementBg
            BtnFrame.Font = Theme.Font
            BtnFrame.TextSize = 14
            BtnFrame.TextColor3 = Theme.Text
            BtnFrame.Text = options.Name
            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", BtnFrame).Color = Theme.Outline
            
            BtnFrame.MouseEnter:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(AnimSpeed), {BackgroundColor3 = Theme.ElementHover}):Play() end)
            BtnFrame.MouseLeave:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(AnimSpeed), {BackgroundColor3 = Theme.ElementBg}):Play() end)
            BtnFrame.MouseButton1Click:Connect(function()
                BtnFrame.TextSize = 12
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {TextSize = 14}):Play()
                if options.Callback then options.Callback() end
            end)
        end

        function Tab:CreateToggle(options)
            local state = options.Default or false
            
            local ToggleFrame = Instance.new("TextButton", Page)
            ToggleFrame.Size = UDim2.new(1, -5, 0, 35)
            ToggleFrame.BackgroundColor3 = Theme.ElementBg
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", ToggleFrame).Color = Theme.Outline

            local Title = Instance.new("TextLabel", ToggleFrame)
            Title.Size = UDim2.new(1, -40, 1, 0)
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.BackgroundTransparency = 1
            Title.Font = Theme.Font
            Title.TextSize = 14
            Title.TextColor3 = Theme.Text
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Text = options.Name

            -- Outer Square
            local CheckBox = Instance.new("Frame", ToggleFrame)
            CheckBox.Size = UDim2.new(0, 20, 0, 20)
            CheckBox.Position = UDim2.new(1, -30, 0.5, -10)
            CheckBox.BackgroundColor3 = Theme.Background
            Instance.new("UICorner", CheckBox).CornerRadius = UDim.new(0, 4)
            local CheckStroke = Instance.new("UIStroke", CheckBox)
            CheckStroke.Color = state and Theme.Accent or Theme.Outline

            -- Inner Blue Checkmark
            local CheckMark = Instance.new("TextLabel", CheckBox)
            CheckMark.Size = UDim2.new(1, 0, 1, 0)
            CheckMark.BackgroundTransparency = 1
            CheckMark.Font = Enum.Font.GothamBold
            CheckMark.TextSize = 14
            CheckMark.Text = "✓"
            CheckMark.TextColor3 = Theme.Accent
            CheckMark.TextTransparency = state and 0 or 1

            ToggleFrame.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(CheckMark, TweenInfo.new(AnimSpeed), {TextTransparency = state and 0 or 1}):Play()
                TweenService:Create(CheckStroke, TweenInfo.new(AnimSpeed), {Color = state and Theme.Accent or Theme.Outline}):Play()
                if options.Callback then options.Callback(state) end
            end)
        end

        function Tab:CreateSlider(options)
            local min = options.Min or 0
            local max = options.Max or 100
            local default = options.Default or min
            
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, -5, 0, 50)
            SliderFrame.BackgroundColor3 = Theme.ElementBg
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", SliderFrame).Color = Theme.Outline

            local Title = Instance.new("TextLabel", SliderFrame)
            Title.Size = UDim2.new(1, -20, 0, 25)
            Title.Position = UDim2.new(0, 10, 0, 5)
            Title.BackgroundTransparency = 1
            Title.Font = Theme.Font
            Title.TextSize = 14
            Title.TextColor3 = Theme.Text
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Text = options.Name

            local ValueLabel = Instance.new("TextLabel", SliderFrame)
            ValueLabel.Size = UDim2.new(1, -20, 0, 25)
            ValueLabel.Position = UDim2.new(0, 10, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Theme.Font
            ValueLabel.TextSize = 14
            ValueLabel.TextColor3 = Theme.Accent
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Text = tostring(default)

            local BarBg = Instance.new("TextButton", SliderFrame)
            BarBg.Size = UDim2.new(1, -20, 0, 6)
            BarBg.Position = UDim2.new(0, 10, 1, -15)
            BarBg.BackgroundColor3 = Theme.Background
            BarBg.Text = ""
            Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame", BarBg)
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Theme.Accent
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function updateSlider(input)
                local percent = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * percent)
                
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(value)
                if options.Callback then options.Callback(value) end
            end

            BarBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
        end

        function Tab:CreateDropdown(options)
            local DropdownFrame = Instance.new("Frame", Page)
            DropdownFrame.Size = UDim2.new(1, -5, 0, 35)
            DropdownFrame.BackgroundColor3 = Theme.ElementBg
            DropdownFrame.ClipsDescendants = true
            Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", DropdownFrame).Color = Theme.Outline

            local TopBtn = Instance.new("TextButton", DropdownFrame)
            TopBtn.Size = UDim2.new(1, 0, 0, 35)
            TopBtn.BackgroundTransparency = 1
            TopBtn.Font = Theme.Font
            TopBtn.TextSize = 14
            TopBtn.TextColor3 = Theme.Text
            TopBtn.TextXAlignment = Enum.TextXAlignment.Left
            TopBtn.Text = "  " .. options.Name .. ": " .. (options.Options[1] or "")

            local Icon = Instance.new("TextLabel", TopBtn)
            Icon.Size = UDim2.new(0, 35, 1, 0)
            Icon.Position = UDim2.new(1, -35, 0, 0)
            Icon.BackgroundTransparency = 1
            Icon.Font = Theme.BoldFont
            Icon.TextSize = 14
            Icon.TextColor3 = Theme.SubText
            Icon.Text = "+"

            local OptionContainer = Instance.new("Frame", DropdownFrame)
            OptionContainer.Size = UDim2.new(1, 0, 1, -35)
            OptionContainer.Position = UDim2.new(0, 0, 0, 35)
            OptionContainer.BackgroundTransparency = 1
            
            local OptLayout = Instance.new("UIListLayout", OptionContainer)
            OptLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local expanded = false
            TopBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                Icon.Text = expanded and "-" or "+"
                local targetHeight = expanded and (35 + (#options.Options * 30)) or 35
                TweenService:Create(DropdownFrame, TweenInfo.new(AnimSpeed), {Size = UDim2.new(1, -5, 0, targetHeight)}):Play()
            end)

            for _, opt in ipairs(options.Options) do
                local OptBtn = Instance.new("TextButton", OptionContainer)
                OptBtn.Size = UDim2.new(1, 0, 0, 30)
                OptBtn.BackgroundColor3 = Theme.Background
                OptBtn.BackgroundTransparency = 0.5
                OptBtn.Font = Theme.Font
                OptBtn.TextSize = 13
                OptBtn.TextColor3 = Theme.SubText
                OptBtn.Text = opt
                
                OptBtn.MouseEnter:Connect(function() OptBtn.TextColor3 = Theme.Accent end)
                OptBtn.MouseLeave:Connect(function() OptBtn.TextColor3 = Theme.SubText end)
                
                OptBtn.MouseButton1Click:Connect(function()
                    TopBtn.Text = "  " .. options.Name .. ": " .. opt
                    expanded = false
                    Icon.Text = "+"
                    TweenService:Create(DropdownFrame, TweenInfo.new(AnimSpeed), {Size = UDim2.new(1, -5, 0, 35)}):Play()
                    if options.Callback then options.Callback(opt) end
                end)
            end
        end

        return Tab
    end
    
    return Window
end

-- ==========================================
-- EXAMPLE OF HOW TO USE THE LIBRARY
-- ==========================================

local MyWindow = HubLibrary:CreateWindow({
    Name = "My Custom Hub"
})

local CombatTab = MyWindow:CreateTab("Combat")
local VisualsTab = MyWindow:CreateTab("Visuals")

-- Example Toggle with Blue Checkmark
CombatTab:CreateToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(state)
        print("Kill Aura:", state)
    end
})

CombatTab:CreateToggle({
    Name = "Auto Heal",
    Default = true,
    Callback = function(state)
        print("Auto Heal:", state)
    end
})

-- Example Slider
CombatTab:CreateSlider({
    Name = "Aura Radius",
    Min = 5,
    Max = 100,
    Default = 25,
    Callback = function(value)
        print("Radius set to:", value)
    end
})

-- Example Dropdown
CombatTab:CreateDropdown({
    Name = "Target Mode",
    Options = {"Closest to Mouse", "Closest to Player", "Lowest HP"},
    Callback = function(selected)
        print("Target mode:", selected)
    end
})

-- Example Buttons
VisualsTab:CreateLabel("ESP Settings")

VisualsTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        print("Refreshed Visuals!")
    end
})

VisualsTab:CreateToggle({
    Name = "Show Tracers",
    Default = false,
    Callback = function(state)
        print("Tracers:", state)
    end
})

return HubLibrary
