-- [[ ROBLOX STUDIO ULTRA EXPANDED UI LIBRARY ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local Library = {}
Library.Theme = {
	Background = Color3.fromRGB(36, 36, 36),
	Topbar = Color3.fromRGB(45, 45, 45),
	Sidebar = Color3.fromRGB(30, 30, 30),
	Accent = Color3.fromRGB(0, 135, 220),
	AccentHover = Color3.fromRGB(0, 160, 255),
	Text = Color3.fromRGB(230, 230, 230),
	TextDark = Color3.fromRGB(160, 160, 160),
	ElementBg = Color3.fromRGB(46, 46, 46),
	ElementHover = Color3.fromRGB(53, 53, 53),
	Border = Color3.fromRGB(55, 55, 55),
	NotificationBg = Color3.fromRGB(28, 28, 33)
}

-- Custom Global Tweener
local function Tween(instance, duration, properties, style, direction)
	style = style or Enum.EasingStyle.Quad
	direction = direction or Enum.EasingDirection.Out
	local info = TweenInfo.new(duration, style, direction)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

-- Draggable implementation
local function MakeDraggable(topbar, object)
	local dragging, dragInput, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
			object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- [[ NOTIFICATION CORE ]] --
local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = "StudioNotificationEngine"
NotificationGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui or script.Parent
local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Parent = NotificationGui
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.Padding = UDim.new(0, 10)
local NotificationPadding = Instance.new("UIPadding")
NotificationPadding.Parent = NotificationGui
NotificationPadding.PaddingBottom = UDim.new(0, 20)
NotificationPadding.PaddingRight = UDim.new(0, 20)

function Library:Notify(title, message, duration)
	title = title or "Notification"
	message = message or "Action triggered successfully."
	duration = duration or 4

	local Card = Instance.new("Frame")
	Card.Size = UDim2.new(0, 280, 0, 70)
	Card.BackgroundColor3 = Library.Theme.NotificationBg
	Card.BackgroundTransparency = 1
	Card.BorderSizePixel = 0
	Card.Parent = NotificationGui

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Card

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Library.Theme.Accent
	Stroke.Thickness = 1
	Stroke.Transparency = 1
	Stroke.Parent = Card

	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Size = UDim2.new(1, -20, 0, 25)
	TitleLbl.Position = UDim2.new(0, 10, 0, 5)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.Text = title
	TitleLbl.TextColor3 = Library.Theme.Text
	TitleLbl.Font = Enum.Font.GothamBold
	TitleLbl.TextSize = 13
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TitleLbl.Parent = Card

	local MsgLbl = Instance.new("TextLabel")
	MsgLbl.Size = UDim2.new(1, -20, 0, 35)
	MsgLbl.Position = UDim2.new(0, 10, 0, 25)
	MsgLbl.BackgroundTransparency = 1
	MsgLbl.Text = message
	MsgLbl.TextColor3 = Library.Theme.TextDark
	MsgLbl.Font = Enum.Font.Gotham
	MsgLbl.TextSize = 12
	MsgLbl.TextWrapped = true
	MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
	MsgLbl.TextYAlignment = Enum.TextYAlignment.Top
	MsgLbl.Parent = Card

	Tween(Card, 0.3, {BackgroundTransparency = 0})
	Tween(Stroke, 0.3, {Transparency = 0})

	task.delay(duration, function()
		Tween(Card, 0.3, {BackgroundTransparency = 1})
		Tween(Stroke, 0.3, {Transparency = 1})
		Tween(TitleLbl, 0.3, {TextTransparency = 1})
		Tween(MsgLbl, 0.3, {TextTransparency = 1})
		task.wait(0.3)
		Card:Destroy()
	end)
end

-- [[ MAIN WINDOW FRAMEWORK ]] --
function Library:CreateWindow(windowTitle)
	windowTitle = windowTitle or "Studio MasterSuite"

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "UltraStudioLibrary"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui or script.Parent

	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0, 650, 0, 420)
	MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
	MainFrame.BackgroundColor3 = Library.Theme.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 8)
	MainCorner.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Library.Theme.Border
	MainStroke.Thickness = 1
	MainStroke.Parent = MainFrame

	-- Top Header Bar
	local Topbar = Instance.new("Frame")
	Topbar.Size = UDim2.new(1, 0, 0, 40)
	Topbar.BackgroundColor3 = Library.Theme.Topbar
	Topbar.BorderSizePixel = 0
	Topbar.Parent = MainFrame
	MakeDraggable(Topbar, MainFrame)

	local TopbarCover = Instance.new("Frame")
	TopbarCover.Size = UDim2.new(1, 0, 0, 10)
	TopbarCover.Position = UDim2.new(0, 0, 1, -10)
	TopbarCover.BackgroundColor3 = Library.Theme.Topbar
	TopbarCover.BorderSizePixel = 0
	TopbarCover.Parent = Topbar

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -100, 1, 0)
	Title.Position = UDim2.new(0, 16, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = windowTitle
	Title.TextColor3 = Library.Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 14
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Topbar

	-- Close Actions
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 40, 0, 40)
	CloseBtn.Position = UDim2.new(1, -40, 0, 0)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "✕"
	CloseBtn.TextColor3 = Library.Theme.TextDark
	CloseBtn.Font = Enum.Font.GothamMedium
	CloseBtn.TextSize = 14
	CloseBtn.Parent = Topbar

	CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, 0.1, {TextColor3 = Color3.fromRGB(255, 80, 80)}) end)
	CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, 0.1, {TextColor3 = Library.Theme.TextDark}) end)
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

	-- Navigation Sidebar
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 150, 1, -40)
	Sidebar.Position = UDim2.new(0, 0, 0, 40)
	Sidebar.BackgroundColor3 = Library.Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = MainFrame

	local SideBorder = Instance.new("Frame")
	SideBorder.Size = UDim2.new(0, 1, 1, 0)
	SideBorder.Position = UDim2.new(1, -1, 0, 0)
	SideBorder.BackgroundColor3 = Library.Theme.Border
	SideBorder.BorderSizePixel = 0
	SideBorder.Parent = Sidebar

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.Parent = Sidebar

	local SidebarPadding = Instance.new("UIPadding")
	SidebarPadding.PaddingTop = UDim.new(0, 10)
	SidebarPadding.PaddingLeft = UDim.new(0, 8)
	SidebarPadding.PaddingRight = UDim.new(0, 8)
	SidebarPadding.Parent = Sidebar

	-- Viewport Container
	local ContainerHolder = Instance.new("Frame")
	ContainerHolder.Size = UDim2.new(1, -150, 1, -40)
	ContainerHolder.Position = UDim2.new(0, 150, 0, 40)
	ContainerHolder.BackgroundTransparency = 1
	ContainerHolder.Parent = MainFrame

	local Window = {Tabs = {}, FirstTab = nil, ActiveTab = nil}

	-- [[ TAB COMPONENT GENERATOR ]] --
	function Window:CreateTab(tabName)
		tabName = tabName or "Dashboard"

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 4
		Page.ScrollBarImageColor3 = Library.Theme.Accent
		Page.Parent = ContainerHolder

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Padding = UDim.new(0, 8)
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Parent = Page

		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingTop = UDim.new(0, 12)
		PagePadding.PaddingLeft = UDim.new(0, 14)
		PagePadding.PaddingRight = UDim.new(0, 14)
		PagePadding.PaddingBottom = UDim.new(0, 12)
		PagePadding.Parent = Page

		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
		end)

		-- Nav Button Design
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 34)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = tabName
		TabBtn.Font = Enum.Font.GothamMedium
		TabBtn.TextSize = 13
		TabBtn.TextColor3 = Library.Theme.TextDark
		TabBtn.TextXAlignment = Enum.TextXAlignment.Left
		TabBtn.Parent = Sidebar

		local TabBtnCorner = Instance.new("UICorner")
		TabBtnCorner.CornerRadius = UDim.new(0, 4)
		TabBtnCorner.Parent = TabBtn

		local TabBtnPadding = Instance.new("UIPadding")
		TabBtnPadding.PaddingLeft = UDim.new(0, 12)
		TabBtnPadding.Parent = TabBtn

		local function Focus()
			for _, entry in pairs(Window.Tabs) do
				entry.Page.Visible = false
				Tween(entry.Btn, 0.15, {BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDark})
			end
			Page.Visible = true
			Tween(TabBtn, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = Library.Theme.ElementBg, TextColor3 = Library.Theme.Accent})
			Window.ActiveTab = Page
		end

		TabBtn.MouseButton1Click:Connect(Focus)

		if not Window.FirstTab then
			Window.FirstTab = Page
			Focus()
		end

		table.insert(Window.Tabs, {Page = Page, Btn = TabBtn})

		local Tab = {}

		-- [[ EXTENSION 1: TEXT BOX INPUT SYSTEM ]] --
		function Tab:AddTextBox(label, placeholder, callback)
			label = label or "Text Entry"
			placeholder = placeholder or "Type here..."
			callback = callback or function() end

			local BoxFrame = Instance.new("Frame")
			BoxFrame.Size = UDim2.new(1, 0, 0, 42)
			BoxFrame.BackgroundColor3 = Library.Theme.ElementBg
			BoxFrame.Parent = Page

			local Corner = Instance.new("UICorner")
			Corner.CornerRadius = UDim.new(0, 5)
			Corner.Parent = BoxFrame

			local TitleLbl = Instance.new("TextLabel")
			TitleLbl.Size = UDim2.new(0, 180, 1, 0)
			TitleLbl.Position = UDim2.new(0, 12, 0, 0)
			TitleLbl.BackgroundTransparency = 1
			TitleLbl.Text = label
			TitleLbl.TextColor3 = Library.Theme.Text
			TitleLbl.Font = Enum.Font.GothamMedium
			TitleLbl.TextSize = 13
			TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
			TitleLbl.Parent = BoxFrame

			local InputBox = Instance.new("TextBox")
			InputBox.Size = UDim2.new(1, -210, 0, 26)
			InputBox.Position = UDim2.new(1, -192, 0.5, -13)
			InputBox.BackgroundColor3 = Library.Theme.Sidebar
			InputBox.Text = ""
			InputBox.PlaceholderText = placeholder
			InputBox.TextColor3 = Library.Theme.Text
			InputBox.PlaceholderColor3 = Library.Theme.TextDark
			InputBox.Font = Enum.Font.Gotham
			InputBox.TextSize = 12
			InputBox.ClipsDescendants = true
			InputBox.Parent = BoxFrame

			local BoxCorner = Instance.new("UICorner")
			BoxCorner.CornerRadius = UDim.new(0, 4)
			BoxCorner.Parent = InputBox

			local BoxStroke = Instance.new("UIStroke")
			BoxStroke.Color = Library.Theme.Border
			BoxStroke.Thickness = 1
			BoxStroke.Parent = InputBox

			InputBox.Focused:Connect(function() Tween(BoxStroke, 0.15, {Color = Library.Theme.Accent}) end)
			InputBox.FocusLost:Connect(function(enterPressed)
				Tween(BoxStroke, 0.15, {Color = Library.Theme.Border})
				task.spawn(callback, InputBox.Text, enterPressed)
			end)

			local InputHandler = {}
			function InputHandler:GetText() return InputBox.Text end
			function InputHandler:SetText(newTxt) InputBox.Text = newTxt; task.spawn(callback, newTxt, false) end
			return InputHandler
		end

		-- [[ EXTENSION 2: DROP-DOWN SELECTOR ]] --
		function Tab:AddDropdown(label, optionsList, callback)
			label = label or "Dropdown Selector"
			optionsList = optionsList or {}
			callback = callback or function() end

			local Expanded = false

			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Size = UDim2.new(1, 0, 0, 42)
			DropdownFrame.BackgroundColor3 = Library.Theme.ElementBg
			DropdownFrame.ClipsDescendants = true
			DropdownFrame.Parent = Page

			local BaseCorner = Instance.new("UICorner")
			BaseCorner.CornerRadius = UDim.new(0, 5)
			BaseCorner.Parent = DropdownFrame

			local Clicker = Instance.new("TextButton")
			Clicker.Size = UDim2.new(1, 0, 0, 42)
			Clicker.BackgroundTransparency = 1
			Clicker.Text = ""
			Clicker.Parent = DropdownFrame

			local TitleLbl = Instance.new("TextLabel")
			TitleLbl.Size = UDim2.new(1, -50, 0, 42)
			TitleLbl.Position = UDim2.new(0, 12, 0, 0)
			TitleLbl.BackgroundTransparency = 1
			TitleLbl.Text = label
			TitleLbl.TextColor3 = Library.Theme.Text
			TitleLbl.Font = Enum.Font.GothamMedium
			TitleLbl.TextSize = 13
			TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
			TitleLbl.Parent = DropdownFrame

			local ArrowIcon = Instance.new("TextLabel")
			ArrowIcon.Size = UDim2.new(0, 30, 0, 42)
			ArrowIcon.Position = UDim2.new(1, -40, 0, 0)
			ArrowIcon.BackgroundTransparency = 1
			ArrowIcon.Text = "▼"
			ArrowIcon.TextColor3 = Library.Theme.TextDark
			ArrowIcon.Font = Enum.Font.Gotham
			ArrowIcon.TextSize = 11
			ArrowIcon.Parent = DropdownFrame

			local OptionsHolder = Instance.new("Frame")
			OptionsHolder.Size = UDim2.new(1, -20, 1, -47)
			OptionsHolder.Position = UDim2.new(0, 10, 0, 42)
			OptionsHolder.BackgroundTransparency = 1
			OptionsHolder.Parent = DropdownFrame

			local DropdownLayout = Instance.new("UIListLayout")
			DropdownLayout.Padding = UDim.new(0, 4)
			DropdownLayout.Parent = OptionsHolder

			local function RenderOptions()
				for _, child in pairs(OptionsHolder:GetChildren()) do
					if child:IsA("TextButton") then child:Destroy() end
				end

				for _, selection in pairs(optionsList) do
					local OptBtn = Instance.new("TextButton")
					OptBtn.Size = UDim2.new(1, 0, 0, 30)
					OptBtn.BackgroundColor3 = Library.Theme.Sidebar
					OptBtn.BorderSizePixel = 0
					OptBtn.Text = selection
					OptBtn.TextColor3 = Library.Theme.Text
					OptBtn.Font = Enum.Font.Gotham
					OptBtn.TextSize = 12
					OptBtn.Parent = OptionsHolder

					local OptCorner = Instance.new("UICorner")
					OptCorner.CornerRadius = UDim.new(0, 4)
					OptCorner.Parent = OptBtn

					OptBtn.MouseButton1Click:Connect(function()
						TitleLbl.Text = label .. " - (" .. selection .. ")"
						Expanded = false
						Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 42)})
						Tween(ArrowIcon, 0.2, {Rotation = 0})
						task.spawn(callback, selection)
					end)
				end
			end

			RenderOptions()

			Clicker.MouseButton1Click:Connect(function()
				Expanded = not Expanded
				if Expanded then
					local targetHeight = 47 + DropdownLayout.AbsoluteContentSize.Y
					Tween(DropdownFrame, 0.25, {Size = UDim2.new(1, 0, 0, targetHeight)})
					Tween(ArrowIcon, 0.25, {Rotation = 180})
				else
					Tween(DropdownFrame, 0.2, {Size = UDim2.new(1, 0, 0, 42)})
					Tween(ArrowIcon, 0.2, {Rotation = 0})
				end
			end)

			local DropdownControls = {}
			function DropdownControls:Refresh(newOptionsTable)
				optionsList = newOptionsTable
				RenderOptions()
				if Expanded then
					local targetHeight = 47 + DropdownLayout.AbsoluteContentSize.Y
					DropdownFrame.Size = UDim2.new(1, 0, 0, targetHeight)
				end
			end
			return DropdownControls
		end

		-- [[ EXTENSION 3: DYNAMIC BIND SYSTEM ]] --
		function Tab:AddKeybind(label, defaultKey, callback)
			label = label or "Keybind Target"
			local currentBind = defaultKey or Enum.KeyCode.E
			callback = callback or function() end

			local Binding = false

			local BindFrame = Instance.new("Frame")
			BindFrame.Size = UDim2.new(1, 0, 0, 42)
			BindFrame.BackgroundColor3 = Library.Theme.ElementBg
			BindFrame.Parent = Page

			local Corner = Instance.new("UICorner")
			Corner.CornerRadius = UDim.new(0, 5)
			Corner.Parent = BindFrame

			local TitleLbl = Instance.new("TextLabel")
			TitleLbl.Size = UDim2.new(0, 200, 1, 0)
			TitleLbl.Position = UDim2.new(0, 12, 0, 0)
			TitleLbl.BackgroundTransparency = 1
			TitleLbl.Text = label
			TitleLbl.TextColor3 = Library.Theme.Text
			TitleLbl.Font = Enum.Font.GothamMedium
			TitleLbl.TextSize = 13
			TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
			TitleLbl.Parent = BindFrame

			local BindBtn = Instance.new("TextButton")
			BindBtn.Size = UDim2.new(0, 90, 0, 26)
			BindBtn.Position = UDim2.new(1, -102, 0.5, -13)
			BindBtn.BackgroundColor3 = Library.Theme.Sidebar
			BindBtn.Text = currentBind.Name
			BindBtn.TextColor3 = Library.Theme.Accent
			BindBtn.Font = Enum.Font.Code
			BindBtn.TextSize = 12
			BindBtn.Parent = BindFrame

			local BtnCorner = Instance.new("UICorner")
			BtnCorner.CornerRadius = UDim.new(0, 4)
			BtnCorner.Parent = BindBtn

			BindBtn.MouseButton1Click:Connect(function()
				Binding = true
				BindBtn.Text = "..."
				BindBtn.TextColor3 = Library.Theme.TextDark
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if processed then return end
				if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
					currentBind = input.KeyCode
					Binding = false
					BindBtn.Text = currentBind.Name
					BindBtn.TextColor3 = Library.Theme.Accent
				elseif not Binding and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentBind then
					task.spawn(callback, currentBind)
				end
			end)
		end

		-- [[ EXTENSION 4: COLLAPSIBLE ACCORDION SECTION ]] --
		function Tab:AddSection(sectionHeader)
			sectionHeader = sectionHeader or "Category"

			local DynamicSection = Instance.new("Frame")
			DynamicSection.Size = UDim2.new(1, 0, 0, 35)
			DynamicSection.BackgroundTransparency = 1
			DynamicSection.Parent = Page

			local Layout = Instance.new("UIListLayout")
			Layout.Padding = UDim.new(0, 6)
			Layout.Parent = DynamicSection

			local HeaderBtn = Instance.new("TextButton")
			HeaderBtn.Size = UDim2.new(1, 0, 0, 30)
			HeaderBtn.BackgroundTransparency = 1
			HeaderBtn.Text = "▼ " .. sectionHeader
			HeaderBtn.TextColor3 = Library.Theme.TextDark
			HeaderBtn.Font = Enum.Font.GothamBold
			HeaderBtn.TextSize = 12
			HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left
			HeaderBtn.Parent = DynamicSection

			local SubPage = Instance.new("Frame")
			SubPage.Size = UDim2.new(1, 0, 0, 0)
			SubPage.BackgroundTransparency = 1
			SubPage.ClipsDescendants = true
			SubPage.Parent = DynamicSection

			local SubLayout = Instance.new("UIListLayout")
			SubLayout.Padding = UDim.new(0, 6)
			SubLayout.Parent = SubPage

			local Open = true

			local function RenderHeight()
				if Open then
					SubPage.Size = UDim2.new(1, 0, 0, SubLayout.AbsoluteContentSize.Y)
					DynamicSection.Size = UDim2.new(1, 0, 0, SubLayout.AbsoluteContentSize.Y + 35)
				else
					SubPage.Size = UDim2.new(1, 0, 0, 0)
					DynamicSection.Size = UDim2.new(1, 0, 0, 35)
				end
			end

			SubLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RenderHeight)

			HeaderBtn.MouseButton1Click:Connect(function()
				Open = not Open
				HeaderBtn.Text = (Open and "▼ " or "► ") .. sectionHeader
				RenderHeight()
			end)

			-- Map standard methods into the sections proxy target layout scope
			local SectionProxy = {}
			function SectionProxy:AddButton(text, cb) return Tab.AddButton({Page = SubPage}, text, cb) end
			function SectionProxy:AddToggle(text, start, cb) return Tab.AddToggle({Page = SubPage}, text, start, cb) end
			function SectionProxy:AddSlider(text, mn, mx, df, cb) return Tab.AddSlider({Page = SubPage}, text, mn, mx, df, cb) end
			function SectionProxy:AddTextBox(label, plcholder, cb) return Tab.AddTextBox({Page = SubPage}, label, plcholder, cb) end
			return SectionProxy
		end

		-- [[ EXTENSION 5: COMPACT SEPARATOR SYSTEM ]] --
		function Tab:AddDivider()
			local DivFrame = Instance.new("Frame")
			DivFrame.Size = UDim2.new(1, 0, 0, 2)
			DivFrame.BackgroundColor3 = Library.Theme.Border
			DivFrame.BorderSizePixel = 0
			DivFrame.Parent = Page
		end

		-- [[ PRE-EXISTING RETROFITTED CORE COMPONENTS ]] --
		function Tab:AddButton(text, callback)
			local targetPage = self.Page or Page
			text = text or "Action Button"
			callback = callback or function() end

			local ButtonFrame = Instance.new("TextButton")
			ButtonFrame.Size = UDim2.new(1, 0, 0, 38)
			ButtonFrame.BackgroundColor3 = Library.Theme.ElementBg
			ButtonFrame.AutoButtonColor = false
			ButtonFrame.Text = ""
			ButtonFrame.Parent = targetPage

			local BCorner = Instance.new("UICorner")
			BCorner.CornerRadius = UDim.new(0, 5)
			BCorner.Parent = ButtonFrame

			local BText = Instance.new("TextLabel")
			BText.Size = UDim2.new(1, -20, 1, 0)
			BText.Position = UDim2.new(0, 12, 0, 0)
			BText.BackgroundTransparency = 1
			BText.Text = text
			BText.Font = Enum.Font.GothamSemibold
			BText.TextColor3 = Library.Theme.Text
			BText.TextSize = 13
			BText.TextXAlignment = Enum.TextXAlignment.Left
			BText.Parent = ButtonFrame

			ButtonFrame.MouseEnter:Connect(function() Tween(ButtonFrame, 0.1, {BackgroundColor3 = Library.Theme.ElementHover}) end)
			ButtonFrame.MouseLeave:Connect(function() Tween(ButtonFrame, 0.1, {BackgroundColor3 = Library.Theme.ElementBg}) end)
			ButtonFrame.MouseButton1Down:Connect(function() task.spawn(callback) end)
		end

		function Tab:AddToggle(text, defaultState, callback)
			local targetPage = self.Page or Page
			text = text or "Toggle Feature"
			defaultState = defaultState or false
			callback = callback or function() end

			local Toggled = defaultState

			local ToggleFrame = Instance.new("TextButton")
			ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
			ToggleFrame.BackgroundColor3 = Library.Theme.ElementBg
			ToggleFrame.AutoButtonColor = false
			ToggleFrame.Text = ""
			ToggleFrame.Parent = targetPage

			local TCorner = Instance.new("UICorner")
			TCorner.CornerRadius = UDim.new(0, 5)
			TCorner.Parent = ToggleFrame

			local TText = Instance.new("TextLabel")
			TText.Size = UDim2.new(1, -60, 1, 0)
			TText.Position = UDim2.new(0, 12, 0, 0)
			TText.BackgroundTransparency = 1
			TText.Text = text
			TText.Font = Enum.Font.GothamMedium
			TText.TextColor3 = Library.Theme.Text
			TText.TextSize = 13
			TText.TextXAlignment = Enum.TextXAlignment.Left
			TText.Parent = ToggleFrame

			local Box = Instance.new("Frame")
			Box.Size = UDim2.new(0, 20, 0, 20)
			Box.Position = UDim2.new(1, -32, 0.5, -10)
			Box.BackgroundColor3 = Library.Theme.Sidebar
			Box.Parent = ToggleFrame

			local BoxCorner = Instance.new("UICorner")
			BoxCorner.CornerRadius = UDim.new(0, 4)
			BoxCorner.Parent = Box

			local Check = Instance.new("Frame")
			Check.Size = UDim2.new(0, 0, 0, 0)
			Check.Position = UDim2.new(0.5, 0, 0.5, 0)
			Check.BackgroundColor3 = Library.Theme.Accent
			Check.Parent = Box

			local CheckCorner = Instance.new("UICorner")
			CheckCorner.CornerRadius = UDim.new(0, 3)
			CheckCorner.Parent = Check

			local function Update(state)
				if state then
					Tween(Check, 0.12, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0.5, -6, 0.5, -6)})
				else
					Tween(Check, 0.12, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
				end
				task.spawn(callback, state)
			end
			Update(Toggled)

			ToggleFrame.MouseButton1Click:Connect(function() Toggled = not Toggled; Update(Toggled) end)
		end

		function Tab:AddSlider(text, min, max, default, callback)
			local targetPage = self.Page or Page
			text = text or "Slider Scale"
			min = min or 0
			max = max or 100
			default = math.clamp(default or min, min, max)
			callback = callback or function() end

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, 0, 0, 48)
			SliderFrame.BackgroundColor3 = Library.Theme.ElementBg
			SliderFrame.Parent = targetPage

			local SCorner = Instance.new("UICorner")
			SCorner.CornerRadius = UDim.new(0, 5)
			SCorner.Parent = SliderFrame

			local SText = Instance.new("TextLabel")
			SText.Size = UDim2.new(1, -100, 0, 25)
			SText.Position = UDim2.new(0, 12, 0, 4)
			SText.BackgroundTransparency = 1
			SText.Text = text
			SText.Font = Enum.Font.GothamMedium
			SText.TextColor3 = Library.Theme.Text
			SText.TextSize = 13
			SText.TextXAlignment = Enum.TextXAlignment.Left
			SText.Parent = SliderFrame

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size = UDim2.new(0, 60, 0, 25)
			ValueLabel.Position = UDim2.new(1, -72, 0, 4)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(default)
			ValueLabel.Font = Enum.Font.Code
			ValueLabel.TextColor3 = Library.Theme.Accent
			ValueLabel.TextSize = 13
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.Parent = SliderFrame

			local SliderBar = Instance.new("TextButton")
			SliderBar.Size = UDim2.new(1, -24, 0, 6)
			SliderBar.Position = UDim2.new(0, 12, 1, -14)
			SliderBar.BackgroundColor3 = Library.Theme.Sidebar
			SliderBar.Text = ""
			SliderBar.Parent = SliderFrame

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			Fill.BackgroundColor3 = Library.Theme.Accent
			Fill.BorderSizePixel = 0
			Fill.Parent = SliderBar

			local Sliding = false
			local function UpdateValue(input)
				local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
				local absoluteVal = math.floor(min + (percentage * (max - min)))
				ValueLabel.Text = tostring(absoluteVal)
				Fill.Size = UDim2.new(percentage, 0, 1, 0)
				task.spawn(callback, absoluteVal)
			end

			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true; UpdateValue(input) end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if Sliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateValue(input) end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
			end)
		end

		return Tab
	end

	return Window
end

return Library
