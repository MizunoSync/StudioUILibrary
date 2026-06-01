local StudioLibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Studio Dark Theme Palette
local Theme = {
    Background = Color3.fromRGB(46, 46, 46),
    Header = Color3.fromRGB(37, 37, 37),
    Border = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(204, 204, 204),
    TextHover = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(11, 90, 175), -- Studio Blue selection
    CheckboxBG = Color3.fromRGB(30, 30, 30),
    Scrollbar = Color3.fromRGB(60, 60, 60)
}

function StudioLibrary:CreateWindow(titleText)
    local Window = {}
    
    -- Safe initialization logic
    local parentTarget = script.Parent
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StudioUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentTarget

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderColor3 = Theme.Border
    MainFrame.Parent = ScreenGui

    -- Header (Like the "Explorer" or "Properties" bar)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 25)
    Header.BackgroundColor3 = Theme.Header
    Header.BorderColor3 = Theme.Border
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Theme.Text
    Title.TextSize = 13
    Title.Font = Enum.Font.SourceSans
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Scrolling Container
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, 0, 1, -25)
    Container.Position = UDim2.new(0, 0, 0, 25)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 6
    Container.ScrollBarImageColor3 = Theme.Scrollbar
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Container

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Component Functions
    function Window:AddButton(text, callback)
        local ButtonFrame = Instance.new("TextButton")
        ButtonFrame.Size = UDim2.new(1, 0, 0, 22)
        ButtonFrame.BackgroundColor3 = Theme.Background
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.Text = "  " .. text
        ButtonFrame.TextColor3 = Theme.Text
        ButtonFrame.TextSize = 13
        ButtonFrame.Font = Enum.Font.SourceSans
        ButtonFrame.TextXAlignment = Enum.TextXAlignment.Left
        ButtonFrame.Parent = Container

        ButtonFrame.MouseEnter:Connect(function()
            ButtonFrame.BackgroundColor3 = Theme.Accent
            ButtonFrame.TextColor3 = Theme.TextHover
        end)
        ButtonFrame.MouseLeave:Connect(function()
            ButtonFrame.BackgroundColor3 = Theme.Background
            ButtonFrame.TextColor3 = Theme.Text
        end)
        ButtonFrame.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end

    function Window:AddToggle(text, default, callback)
        local toggled = default or false
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 22)
        ToggleFrame.BackgroundColor3 = Theme.Background
        ToggleFrame.BorderColor3 = Theme.Border
        ToggleFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.5, -10, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 13
        Label.Font = Enum.Font.SourceSans
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local CheckboxFrame = Instance.new("Frame")
        CheckboxFrame.Size = UDim2.new(0, 14, 0, 14)
        CheckboxFrame.Position = UDim2.new(0.5, 5, 0.5, -7)
        CheckboxFrame.BackgroundColor3 = toggled and Theme.Accent or Theme.CheckboxBG
        CheckboxFrame.BorderColor3 = Theme.Border
        CheckboxFrame.Parent = ToggleFrame

        local Checkmark = Instance.new("TextLabel")
        Checkmark.Size = UDim2.new(1, 0, 1, 0)
        Checkmark.BackgroundTransparency = 1
        Checkmark.Text = toggled and "✓" or ""
        Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
        Checkmark.TextSize = 12
        Checkmark.Parent = CheckboxFrame

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""
        Button.Parent = ToggleFrame

        Button.MouseButton1Click:Connect(function()
            toggled = not toggled
            CheckboxFrame.BackgroundColor3 = toggled and Theme.Accent or Theme.CheckboxBG
            Checkmark.Text = toggled and "✓" or ""
            if callback then callback(toggled) end
        end)
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end

    function Window:AddSlider(text, min, max, default, callback)
        local value = default or min
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 40)
        SliderFrame.BackgroundColor3 = Theme.Background
        SliderFrame.BorderColor3 = Theme.Border
        SliderFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -10, 0, 20)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text .. ": " .. tostring(value)
        Label.TextColor3 = Theme.Text
        Label.TextSize = 13
        Label.Font = Enum.Font.SourceSans
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame

        local SliderBG = Instance.new("Frame")
        SliderBG.Size = UDim2.new(1, -20, 0, 4)
        SliderBG.Position = UDim2.new(0, 10, 0, 25)
        SliderBG.BackgroundColor3 = Theme.CheckboxBG
        SliderBG.BorderSizePixel = 0
        SliderBG.Parent = SliderFrame

        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        SliderFill.BackgroundColor3 = Theme.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBG

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""
        Button.Parent = SliderBG

        local draggingSlider = false
        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativeX = math.clamp(input.Position.X - SliderBG.AbsolutePosition.X, 0, SliderBG.AbsoluteSize.X)
                local percentage = relativeX / SliderBG.AbsoluteSize.X
                value = math.floor(min + (max - min) * percentage)
                
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                Label.Text = text .. ": " .. tostring(value)
                if callback then callback(value) end
            end
        end)
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end
    
    function Window:AddRichLabel(textData)
        local LabelFrame = Instance.new("Frame")
        LabelFrame.Size = UDim2.new(1, 0, 0, 22)
        LabelFrame.BackgroundColor3 = Theme.Background
        LabelFrame.BorderSizePixel = 0
        LabelFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -10, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.RichText = true
        Label.Text = textData
        Label.TextColor3 = Theme.Text
        Label.TextSize = 13
        Label.Font = Enum.Font.SourceSans
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = LabelFrame
        
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end

    return Window
end

return StudioLibrary
