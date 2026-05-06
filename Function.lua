local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local StudioUI = {}

local Theme = {
    Background = Color3.fromRGB(46, 46, 46),       
    Panel = Color3.fromRGB(37, 37, 37),            
    Border = Color3.fromRGB(22, 22, 22),           
    Text = Color3.fromRGB(204, 204, 204),          
    TextHighlight = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(153, 153, 153),       
    Accent = Color3.fromRGB(11, 90, 190),          
    InputBg = Color3.fromRGB(30, 30, 30),          
    Button = Color3.fromRGB(53, 53, 53),           
    ButtonHover = Color3.fromRGB(70, 70, 70),
    CategoryBg = Color3.fromRGB(41, 41, 41)
}

-- ============================================================
-- CORE WINDOW CREATION
-- ============================================================
function StudioUI:CreateWindow(options)
    local Window = { Tabs = {}, CurrentTab = nil }
    options = options or {}
    local titleText = options.Title or "Studio Window"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StudioFramework_" .. HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, options.Width or 400, 0, options.Height or 500)
    MainFrame.Position = UDim2.new(0.5, -(options.Width or 400)/2, 0.5, -(options.Height or 500)/2)
    MainFrame.BackgroundColor3, MainFrame.BorderColor3, MainFrame.BorderSizePixel = Theme.Background, Theme.Border, 1
    MainFrame.Active = true

    local Topbar = Instance.new("Frame", MainFrame)
    Topbar.Size, Topbar.BackgroundColor3, Topbar.BorderSizePixel = UDim2.new(1, 0, 0, 24), Theme.Panel, 0
    local TopBorder = Instance.new("Frame", Topbar)
    TopBorder.Size, TopBorder.Position, TopBorder.BackgroundColor3, TopBorder.BorderSizePixel = UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, 0), Theme.Border, 0

    local Title = Instance.new("TextLabel", Topbar)
    Title.Size, Title.Position, Title.BackgroundTransparency = UDim2.new(1, -10, 1, 0), UDim2.new(0, 8, 0, 0), 1
    Title.Font, Title.TextSize, Title.TextColor3, Title.TextXAlignment = Enum.Font.SourceSans, 14, Theme.Text, Enum.TextXAlignment.Left
    Title.RichText, Title.Text = true, titleText

    -- Dragging Logic
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, input.Position, MainFrame.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Size, TabContainer.Position, TabContainer.BackgroundColor3, TabContainer.BorderSizePixel = UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 25), Theme.Background, 0
    
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.FillDirection, TabListLayout.SortOrder = Enum.FillDirection.Horizontal, Enum.SortOrder.LayoutOrder

    local ContentContainer = Instance.new("Frame", MainFrame)
    ContentContainer.Size, ContentContainer.Position, ContentContainer.BackgroundColor3, ContentContainer.BorderSizePixel = UDim2.new(1, 0, 1, -49), UDim2.new(0, 0, 0, 49), Theme.Background, 0

    -- ============================================================
    -- TAB SYSTEM
    -- ============================================================
    function Window:CreateTab(name)
        local Tab = { Categories = {} }
        
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size, TabBtn.BackgroundColor3, TabBtn.BorderColor3, TabBtn.BorderSizePixel = UDim2.new(0, 100, 1, 0), Theme.Panel, Theme.Border, 1
        TabBtn.Font, TabBtn.TextSize, TabBtn.TextColor3, TabBtn.Text = Enum.Font.SourceSans, 14, Theme.Text, name
        
        local ActiveLine = Instance.new("Frame", TabBtn)
        ActiveLine.Size, ActiveLine.Position, ActiveLine.BackgroundColor3, ActiveLine.BorderSizePixel = UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 0, 0), Theme.Accent, 0
        ActiveLine.Visible = false

        local Scroll = Instance.new("ScrollingFrame", ContentContainer)
        Scroll.Size, Scroll.BackgroundColor3, Scroll.BorderSizePixel, Scroll.ScrollBarThickness = UDim2.new(1, 0, 1, 0), Theme.Background, 0, 6
        Scroll.ScrollBarImageColor3, Scroll.Visible = Theme.Panel, false
        local Layout = Instance.new("UIListLayout", Scroll)

        -- Auto-resize scroll canvas
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10) end)

        table.insert(self.Tabs, {Btn = TabBtn, Line = ActiveLine, Page = Scroll})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(Window.Tabs) do
                local isActive = (t.Btn == TabBtn)
                t.Btn.BackgroundColor3 = isActive and Theme.Background or Theme.Panel
                t.Btn.TextColor3 = isActive and Theme.TextHighlight or Theme.Text
                t.Line.Visible = isActive
                t.Page.Visible = isActive
            end
        end)

        if #self.Tabs == 1 then TabBtn.BackgroundColor3, TabBtn.TextColor3, ActiveLine.Visible, Scroll.Visible = Theme.Background, Theme.TextHighlight, true, true end

        -- ============================================================
        -- CATEGORY (COLLAPSIBLE SECTIONS)
        -- ============================================================
        function Tab:CreateCategory(catName)
            local Category = {}
            
            local CatBtn = Instance.new("TextButton", Scroll)
            CatBtn.Size, CatBtn.BackgroundColor3, CatBtn.BorderColor3, CatBtn.BorderSizePixel = UDim2.new(1, 0, 0, 24), Theme.CategoryBg, Theme.Border, 1
            CatBtn.Font, CatBtn.TextSize, CatBtn.TextColor3, CatBtn.TextXAlignment, CatBtn.Text = Enum.Font.SourceSansBold, 13, Theme.TextHighlight, Enum.TextXAlignment.Left, "  [-]  " .. catName
            
            local ItemContainer = Instance.new("Frame", Scroll)
            ItemContainer.Size, ItemContainer.BackgroundColor3, ItemContainer.BorderSizePixel = UDim2.new(1, 0, 0, 0), Theme.Background, 0
            ItemContainer.ClipsDescendants = true
            local ItemLayout = Instance.new("UIListLayout", ItemContainer)
            
            ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if ItemContainer.Visible then ItemContainer.Size = UDim2.new(1, 0, 0, ItemLayout.AbsoluteContentSize.Y) end
            end)

            local expanded = true
            CatBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                CatBtn.Text = (expanded and "  [-]  " or "  [+]  ") .. catName
                ItemContainer.Visible = expanded
                if expanded then ItemContainer.Size = UDim2.new(1, 0, 0, ItemLayout.AbsoluteContentSize.Y) end
            end)

            -- Helpers for creating rows
            local function createRow(propName)
                local row = Instance.new("Frame", ItemContainer)
                row.Size, row.BackgroundColor3, row.BorderColor3, row.BorderSizePixel = UDim2.new(1, 0, 0, 24), Theme.Background, Theme.Border, 1
                local label = Instance.new("TextLabel", row)
                label.Size, label.BackgroundColor3, label.BorderColor3, label.BorderSizePixel = UDim2.new(0.4, 0, 1, 0), Theme.Panel, Theme.Border, 1
                label.Font, label.TextSize, label.TextColor3, label.TextXAlignment, label.Text = Enum.Font.SourceSans, 14, Theme.Text, Enum.TextXAlignment.Left, "  " .. propName
                return row
            end

            -- ELEMENTS --
            function Category:CreateToggle(opts)
                local row = createRow(opts.Name)
                local control = Instance.new("TextButton", row)
                control.Size, control.Position, control.BackgroundColor3, control.BorderColor3, control.BorderSizePixel = UDim2.new(0.6, 0, 1, 0), UDim2.new(0.4, 0, 0, 0), Theme.Background, Theme.Border, 1
                control.Font, control.TextSize, control.TextColor3, control.Text = Enum.Font.SourceSans, 14, Theme.Text, opts.Default and "[x] True" or "[ ] False"
                
                local state = opts.Default or false
                control.MouseButton1Click:Connect(function()
                    state = not state
                    control.Text = state and "[x] True" or "[ ] False"
                    control.TextColor3 = state and Theme.TextHighlight or Theme.Text
                    if opts.Callback then opts.Callback(state) end
                end)
            end

            function Category:CreateInput(opts)
                local row = createRow(opts.Name)
                local control = Instance.new("TextBox", row)
                control.Size, control.Position, control.BackgroundColor3, control.BorderColor3, control.BorderSizePixel = UDim2.new(0.6, 0, 1, 0), UDim2.new(0.4, 0, 0, 0), Theme.InputBg, Theme.Border, 1
                control.Font, control.TextSize, control.TextColor3, control.TextXAlignment = Enum.Font.SourceSans, 14, Theme.Text, Enum.TextXAlignment.Left
                control.Text, control.PlaceholderText, control.ClearTextOnFocus = " " .. (opts.Default or ""), " " .. (opts.Placeholder or ""), false
                
                control.FocusLost:Connect(function()
                    local cleanText = string.sub(control.Text, 2) -- Remove the padding space
                    if opts.Callback then opts.Callback(cleanText) end
                end)
            end

            function Category:CreateSlider(opts)
                local row = createRow(opts.Name)
                local valLabel = Instance.new("TextLabel", row)
                valLabel.Size, valLabel.Position, valLabel.BackgroundTransparency, valLabel.Font, valLabel.TextSize, valLabel.TextColor3 = UDim2.new(0.15, 0, 1, 0), UDim2.new(0.4, 0, 0, 0), 1, Enum.Font.SourceSans, 14, Theme.Text
                valLabel.Text = tostring(opts.Default or opts.Min)
                
                local sliderBg = Instance.new("Frame", row)
                sliderBg.Size, sliderBg.Position, sliderBg.BackgroundColor3, sliderBg.BorderColor3, sliderBg.BorderSizePixel = UDim2.new(0.4, -10, 0, 4), UDim2.new(0.55, 5, 0.5, -2), Theme.InputBg, Theme.Border, 1
                local sliderFill = Instance.new("Frame", sliderBg)
                sliderFill.Size, sliderFill.BackgroundColor3, sliderFill.BorderSizePixel = UDim2.new(0, 0, 1, 0), Theme.Accent, 0
                
                local dragging = false
                local function update(input)
                    local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    local value = math.floor(opts.Min + ((opts.Max - opts.Min) * percent))
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    valLabel.Text = tostring(value)
                    if opts.Callback then opts.Callback(value) end
                end

                row.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end end)
                UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                
                -- Init default
                local startPct = ((opts.Default or opts.Min) - opts.Min) / (opts.Max - opts.Min)
                sliderFill.Size = UDim2.new(startPct, 0, 1, 0)
            end

            function Category:CreateDropdown(opts)
                local row = createRow(opts.Name)
                local btn = Instance.new("TextButton", row)
                btn.Size, btn.Position, btn.BackgroundColor3, btn.BorderColor3, btn.BorderSizePixel = UDim2.new(0.6, 0, 1, 0), UDim2.new(0.4, 0, 0, 0), Theme.InputBg, Theme.Border, 1
                btn.Font, btn.TextSize, btn.TextColor3, btn.TextXAlignment, btn.Text = Enum.Font.SourceSans, 14, Theme.Text, Enum.TextXAlignment.Left, "  " .. (opts.Default or "Select...")
                
                -- Inline Dropdown Container
                local dropContainer = Instance.new("Frame", ItemContainer)
                dropContainer.Size, dropContainer.BackgroundColor3, dropContainer.BorderSizePixel, dropContainer.Visible = UDim2.new(1, 0, 0, 0), Theme.Panel, 0, false
                local dropLayout = Instance.new("UIListLayout", dropContainer)
                
                local expanded = false
                btn.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    dropContainer.Visible = expanded
                    if expanded then dropContainer.Size = UDim2.new(1, 0, 0, dropLayout.AbsoluteContentSize.Y) end
                end)

                for _, option in ipairs(opts.Options) do
                    local optBtn = Instance.new("TextButton", dropContainer)
                    optBtn.Size, optBtn.BackgroundColor3, optBtn.BorderColor3, optBtn.BorderSizePixel = UDim2.new(1, 0, 0, 24), Theme.Background, Theme.Border, 1
                    optBtn.Font, optBtn.TextSize, optBtn.TextColor3, optBtn.TextXAlignment, optBtn.Text = Enum.Font.SourceSans, 14, Theme.SubText, Enum.TextXAlignment.Center, option
                    
                    optBtn.MouseEnter:Connect(function() optBtn.TextColor3 = Theme.TextHighlight end)
                    optBtn.MouseLeave:Connect(function() optBtn.TextColor3 = Theme.SubText end)
                    
                    optBtn.MouseButton1Click:Connect(function()
                        btn.Text = "  " .. option
                        expanded = false; dropContainer.Visible = false
                        if opts.Callback then opts.Callback(option) end
                    end)
                end
            end

            function Category:CreateButton(opts)
                local btnFrame = Instance.new("Frame", ItemContainer)
                btnFrame.Size, btnFrame.BackgroundColor3, btnFrame.BorderColor3, btnFrame.BorderSizePixel = UDim2.new(1, 0, 0, 30), Theme.Background, Theme.Border, 1
                local btn = Instance.new("TextButton", btnFrame)
                btn.Size, btn.Position, btn.BackgroundColor3, btn.BorderColor3, btn.BorderSizePixel = UDim2.new(1, -16, 0, 20), UDim2.new(0, 8, 0, 5), Theme.Button, Theme.Border, 1
                btn.Font, btn.TextSize, btn.TextColor3, btn.Text = Enum.Font.SourceSans, 14, Theme.Text, opts.Name
                
                btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Theme.ButtonHover end)
                btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Theme.Button end)
                btn.MouseButton1Click:Connect(function() if opts.Callback then opts.Callback() end end)
            end

            return Category
        end

        return Tab
    end

    return Window
end

return StudioUI
