local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local Library = {
	Version = "1.0.0",
	Theme = {},
	Flags = {},
	Connections = {},
	Notifications = nil,
}

local Themes = {
	StudioDark = {
		Background = Color3.fromRGB(32, 33, 36),
		Surface = Color3.fromRGB(42, 43, 47),
		Surface2 = Color3.fromRGB(49, 51, 56),
		Surface3 = Color3.fromRGB(56, 58, 64),
		Border = Color3.fromRGB(68, 70, 77),
		Text = Color3.fromRGB(245, 245, 245),
		TextMuted = Color3.fromRGB(202, 202, 202),
		TextFaint = Color3.fromRGB(144, 146, 153),
		Accent = Color3.fromRGB(11, 105, 208),
		Accent2 = Color3.fromRGB(45, 141, 255),
		Success = Color3.fromRGB(35, 179, 95),
		Warning = Color3.fromRGB(220, 160, 52),
		Danger = Color3.fromRGB(216, 90, 98),
	},
	StudioLight = {
		Background = Color3.fromRGB(232, 234, 237),
		Surface = Color3.fromRGB(246, 247, 249),
		Surface2 = Color3.fromRGB(255, 255, 255),
		Surface3 = Color3.fromRGB(223, 225, 229),
		Border = Color3.fromRGB(186, 190, 197),
		Text = Color3.fromRGB(33, 36, 41),
		TextMuted = Color3.fromRGB(74, 78, 86),
		TextFaint = Color3.fromRGB(104, 110, 120),
		Accent = Color3.fromRGB(12, 100, 197),
		Accent2 = Color3.fromRGB(37, 124, 230),
		Success = Color3.fromRGB(37, 148, 84),
		Warning = Color3.fromRGB(189, 132, 23),
		Danger = Color3.fromRGB(190, 73, 82),
	},
}

local function deepCopy(tbl)
	local new = {}
	for k, v in pairs(tbl) do
		new[k] = typeof(v) == "table" and deepCopy(v) or v
	end
	return new
end

local function tween(object, properties, duration)
	local info = TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tw = TweenService:Create(object, info, properties)
	tw:Play()
	return tw
end

local function create(className, props)
	local instance = Instance.new(className)
	for key, value in pairs(props or {}) do
		if key ~= "Parent" then
			instance[key] = value
		end
	end
	instance.Parent = props and props.Parent or nil
	return instance
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Parent = parent,
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function corner(parent, radius)
	return create("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or 6),
	})
end

local function padding(parent, left, right, top, bottom)
	return create("UIPadding", {
		Parent = parent,
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or left or 0),
		PaddingTop = UDim.new(0, top or left or 0),
		PaddingBottom = UDim.new(0, bottom or top or left or 0),
	})
end

local function listLayout(parent, spacing, horizontal)
	return create("UIListLayout", {
		Parent = parent,
		Padding = UDim.new(0, spacing or 0),
		FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	})
end

local function textSize(text, size, font)
	return game:GetService("TextService"):GetTextSize(text, size, font, Vector2.new(1000, 1000))
end

local function makeButtonHover(button, normal, hover)
	button.MouseEnter:Connect(function()
		tween(button, {BackgroundColor3 = hover}, 0.12)
	end)
	button.MouseLeave:Connect(function()
		tween(button, {BackgroundColor3 = normal}, 0.12)
	end)
end

function Library:GetTheme(name)
	return deepCopy(Themes[name] or Themes.StudioDark)
end

function Library:SetTheme(nameOrTheme)
	if typeof(nameOrTheme) == "string" then
		self.Theme = self:GetTheme(nameOrTheme)
	elseif typeof(nameOrTheme) == "table" then
		self.Theme = deepCopy(nameOrTheme)
	end
	return self.Theme
end

function Library:SetFlag(flag, value)
	self.Flags[flag] = value
end

function Library:GetFlag(flag)
	return self.Flags[flag]
end

function Library:SafeCallback(callback, ...)
	if typeof(callback) ~= "function" then
		return
	end
	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[StudioLibrary] Callback error:", err)
	end
end

function Library:CreateScreenGui(name)
	local existing = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(name)
	if existing then
		existing:Destroy()
	end

	local gui = create("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
	})

	return gui
end

function Library:Notify(options)
	options = options or {}
	local holder = self.Notifications
	if not holder then
		return
	end

	local theme = self.Theme
	local toast = create("Frame", {
		Parent = holder,
		BackgroundColor3 = theme.Surface,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
	})
	corner(toast, 6)
	stroke(toast, theme.Border, 1, 0)
	padding(toast, 10, 10, 10, 10)

	local bar = create("Frame", {
		Parent = toast,
		BackgroundColor3 = options.Type == "Error" and theme.Danger or options.Type == "Warning" and theme.Warning or theme.Accent2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 3, 1, 0),
	})
	corner(bar, 6)

	local title = create("TextLabel", {
		Parent = toast,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -18, 0, 18),
		Font = Enum.Font.SourceSansSemibold,
		Text = options.Title or "Notification",
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = theme.Text,
	})

	local content = create("TextLabel", {
		Parent = toast,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 18),
		Size = UDim2.new(1, -18, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Enum.Font.SourceSans,
		TextWrapped = true,
		Text = options.Content or "",
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = theme.TextMuted,
	})

	toast.BackgroundTransparency = 1
	toast.Size = UDim2.new(1, 12, 0, content.TextBounds.Y + 34)
	tween(toast, {BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, content.TextBounds.Y + 34)}, 0.18)

	task.delay(options.Duration or 4, function()
		if toast.Parent then
			tween(toast, {BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 0)}, 0.18)
			task.wait(0.2)
			toast:Destroy()
		end
	end)
end

function Library:CreateWindow(options)
	options = options or {}
	self:SetTheme(options.Theme or "StudioDark")

	local theme = self.Theme
	local window = {}
	window.Library = self
	window.Theme = theme
	window.Flags = self.Flags
	window.Tabs = {}
	window.CurrentTab = nil
	window.Keybind = options.Keybind or Enum.KeyCode.RightShift

	local gui = self:CreateScreenGui(options.GuiName or "StudioLibrary")
	window.Gui = gui

	local root = create("Frame", {
		Parent = gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = options.Position or UDim2.new(0.5, 0, 0.5, 0),
		Size = options.Size or UDim2.new(0, 880, 0, 560),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
	})
	corner(root, 8)
	stroke(root, theme.Border, 1, 0)
	window.Root = root

	create("UISizeConstraint", {
		Parent = root,
		MinSize = Vector2.new(700, 420),
	})

	local titleBar = create("Frame", {
		Parent = root,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 34),
	})
	corner(titleBar, 8)
	create("Frame", {
		Parent = titleBar,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -8),
		Size = UDim2.new(1, 0, 0, 8),
	})
	stroke(titleBar, theme.Border, 1, 0)

	local title = create("TextLabel", {
		Parent = titleBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -80, 1, 0),
		Text = options.Title or "Studio Library",
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = theme.Text,
	})

	local subtitle = create("TextLabel", {
		Parent = titleBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 176, 0, 0),
		Size = UDim2.new(0, 180, 1, 0),
		Text = options.Subtitle or "Roblox Studio style",
		Font = Enum.Font.SourceSans,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = theme.TextFaint,
	})

	local closeButton = create("TextButton", {
		Parent = titleBar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 22, 0, 22),
		BackgroundColor3 = theme.Surface2,
		BorderSizePixel = 0,
		Text = "✕",
		Font = Enum.Font.SourceSansBold,
		TextSize = 14,
		TextColor3 = theme.TextMuted,
	})
	corner(closeButton, 4)
	stroke(closeButton, theme.Border, 1, 0)
	makeButtonHover(closeButton, theme.Surface2, theme.Surface3)
	closeButton.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	local body = create("Frame", {
		Parent = root,
		Position = UDim2.new(0, 0, 0, 34),
		Size = UDim2.new(1, 0, 1, -34),
		BackgroundTransparency = 1,
	})

	local sidebar = create("Frame", {
		Parent = body,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 190, 1, 0),
	})
	stroke(sidebar, theme.Border, 1, 0)

	local searchBox = create("TextBox", {
		Parent = sidebar,
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(1, -20, 0, 28),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		PlaceholderText = "Search tabs",
		Text = "",
		ClearTextOnFocus = false,
		Font = Enum.Font.SourceSans,
		TextSize = 14,
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.TextFaint,
	})
	corner(searchBox, 5)
	stroke(searchBox, theme.Border, 1, 0)
	padding(searchBox, 8, 8, 0, 0)

	local tabScroll = create("ScrollingFrame", {
		Parent = sidebar,
		Position = UDim2.new(0, 10, 0, 46),
		Size = UDim2.new(1, -20, 1, -56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollBarImageColor3 = theme.Border,
		ScrollBarThickness = 4,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	})
	listLayout(tabScroll, 6, false)

	local contentHolder = create("Frame", {
		Parent = body,
		Position = UDim2.new(0, 190, 0, 0),
		Size = UDim2.new(1, -190, 1, 0),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
	})

	local contentPageHolder = create("Frame", {
		Parent = contentHolder,
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(1, -24, 1, -24),
		BackgroundTransparency = 1,
	})

	local notificationHolder = create("Frame", {
		Parent = gui,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 14),
		Size = UDim2.new(0, 280, 1, -28),
		BackgroundTransparency = 1,
	})
	listLayout(notificationHolder, 8, false)
	self.Notifications = notificationHolder

	local dragging, dragInput, dragStart, startPosition = false, nil, nil, nil
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPosition = root.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == window.Keybind then
			root.Visible = not root.Visible
		end
	end)

	function window:SetVisible(visible)
		root.Visible = visible
	end

	function window:SetAccent(color)
		self.Theme.Accent = color
		self.Theme.Accent2 = color:Lerp(Color3.new(1, 1, 1), 0.2)
	end

	function window:Notify(data)
		self.Library:Notify(data)
	end

	function window:Destroy()
		gui:Destroy()
	end

	function window:SelectTab(tabObj)
		for _, tab in ipairs(self.Tabs) do
			tab.Button.BackgroundColor3 = tab == tabObj and self.Theme.Accent or self.Theme.Surface2
			tab.Button.TextColor3 = tab == tabObj and Color3.fromRGB(255, 255, 255) or self.Theme.TextMuted
			tab.Page.Visible = tab == tabObj
		end
		self.CurrentTab = tabObj
	end

	function window:CreateTab(name, iconText)
		local tab = {}
		tab.Window = self
		tab.Sections = {}
		tab.Name = name

		local tabButton = create("TextButton", {
			Parent = tabScroll,
			BackgroundColor3 = self.Theme.Surface2,
			Size = UDim2.new(1, 0, 0, 32),
			AutomaticSize = Enum.AutomaticSize.None,
			BorderSizePixel = 0,
			Text = string.format("%s  %s", iconText or "◼", name),
			Font = Enum.Font.SourceSansSemibold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = self.Theme.TextMuted,
		})
		corner(tabButton, 5)
		stroke(tabButton, self.Theme.Border, 1, 0)
		padding(tabButton, 10, 10, 0, 0)
		makeButtonHover(tabButton, self.Theme.Surface2, self.Theme.Surface3)

		local page = create("ScrollingFrame", {
			Parent = contentPageHolder,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.fromOffset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarImageColor3 = self.Theme.Border,
			ScrollBarThickness = 5,
			Visible = false,
			BorderSizePixel = 0,
		})
		local grid = create("UIGridLayout", {
			Parent = page,
			CellSize = UDim2.new(0.5, -8, 0, 240),
			CellPadding = UDim2.new(0, 12, 0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		create("UIPadding", {
			Parent = page,
			PaddingBottom = UDim.new(0, 10),
		})

		grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.fromOffset(0, grid.AbsoluteContentSize.Y + 10)
		end)

		tab.Button = tabButton
		tab.Page = page

		tabButton.MouseButton1Click:Connect(function()
			self:SelectTab(tab)
		end)

		function tab:CreateSection(titleText)
			local section = {}
			section.Tab = self
			section.Elements = {}

			local card = create("Frame", {
				Parent = page,
				BackgroundColor3 = self.Window.Theme.Surface,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 240),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			corner(card, 6)
			stroke(card, self.Window.Theme.Border, 1, 0)

			local header = create("TextLabel", {
				Parent = card,
				BackgroundColor3 = self.Window.Theme.Surface2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 28),
				Font = Enum.Font.SourceSansSemibold,
				Text = titleText,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = self.Window.Theme.Text,
			})
			corner(header, 6)
			create("Frame", {
				Parent = header,
				BackgroundColor3 = self.Window.Theme.Surface2,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, -6),
				Size = UDim2.new(1, 0, 0, 6),
			})
			padding(header, 10, 10, 0, 0)
			stroke(header, self.Window.Theme.Border, 1, 0)

			local bodyFrame = create("Frame", {
				Parent = card,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 36),
				Size = UDim2.new(1, -20, 1, -46),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			local bodyLayout = listLayout(bodyFrame, 8, false)
			bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				bodyFrame.Size = UDim2.new(1, -20, 0, bodyLayout.AbsoluteContentSize.Y)
				card.Size = UDim2.new(1, 0, 0, bodyLayout.AbsoluteContentSize.Y + 46)
			end)

			section.Card = card
			section.Body = bodyFrame

			local function baseRow(height)
				local row = create("Frame", {
					Parent = bodyFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, height or 32),
				})
				return row
			end

			local function labelRow(row, text)
				create("TextLabel", {
					Parent = row,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.42, 0, 1, 0),
					Font = Enum.Font.SourceSans,
					Text = text,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = section.Tab.Window.Theme.TextMuted,
				})
			end

			function section:AddLabel(text, options)
				options = options or {}
				local label = create("TextLabel", {
					Parent = bodyFrame,
					BackgroundColor3 = options.Background and section.Tab.Window.Theme.Surface2 or Color3.new(),
					BackgroundTransparency = options.Background and 0 or 1,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					Font = Enum.Font.SourceSans,
					Text = text,
					TextWrapped = true,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextColor3 = options.Color or section.Tab.Window.Theme.TextMuted,
				})
				if options.Background then
					corner(label, 4)
					stroke(label, section.Tab.Window.Theme.Border, 1, 0)
					padding(label, 8, 8, 8, 8)
				end
				return label
			end

			function section:AddButton(options)
				options = options or {}
				local row = baseRow(32)
				local button = create("TextButton", {
					Parent = row,
					BackgroundColor3 = options.Primary and section.Tab.Window.Theme.Accent or section.Tab.Window.Theme.Surface2,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
					Font = Enum.Font.SourceSansSemibold,
					Text = options.Text or "Button",
					TextSize = 15,
					TextColor3 = options.Primary and Color3.new(1,1,1) or section.Tab.Window.Theme.Text,
				})
				corner(button, 5)
				stroke(button, section.Tab.Window.Theme.Border, 1, 0)
				makeButtonHover(button, button.BackgroundColor3, options.Primary and section.Tab.Window.Theme.Accent2 or section.Tab.Window.Theme.Surface3)
				button.MouseButton1Click:Connect(function()
					section.Tab.Window.Library:SafeCallback(options.Callback)
				end)
				return button
			end

			function section:AddToggle(options)
				options = options or {}
				local row = baseRow(30)
				labelRow(row, options.Text or "Toggle")
				local flag = options.Flag or options.Text or tostring(math.random())
				local value = options.Default == true
				section.Tab.Window.Library:SetFlag(flag, value)

				local toggleButton = create("TextButton", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0, 42, 0, 22),
					BackgroundColor3 = value and section.Tab.Window.Theme.Accent or section.Tab.Window.Theme.Surface2,
					BorderSizePixel = 0,
					Text = "",
				})
				corner(toggleButton, 999)
				stroke(toggleButton, section.Tab.Window.Theme.Border, 1, 0)

				local knob = create("Frame", {
					Parent = toggleButton,
					BackgroundColor3 = Color3.fromRGB(240, 240, 240),
					BorderSizePixel = 0,
					Position = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
					Size = UDim2.new(0, 16, 0, 16),
				})
				corner(knob, 999)

				local object = {}
				function object:Set(newValue)
					value = newValue
					section.Tab.Window.Library:SetFlag(flag, value)
					tween(toggleButton, {BackgroundColor3 = value and section.Tab.Window.Theme.Accent or section.Tab.Window.Theme.Surface2}, 0.15)
					tween(knob, {Position = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.15)
					section.Tab.Window.Library:SafeCallback(options.Callback, value)
				end
				function object:Get()
					return value
				end
				toggleButton.MouseButton1Click:Connect(function()
					object:Set(not value)
				end)
				return object
			end

			function section:AddCheckbox(options)
				options = options or {}
				local row = baseRow(24)
				local flag = options.Flag or options.Text or tostring(math.random())
				local value = options.Default == true
				section.Tab.Window.Library:SetFlag(flag, value)

				local box = create("TextButton", {
					Parent = row,
					Position = UDim2.new(0, 0, 0.5, -9),
					Size = UDim2.new(0, 18, 0, 18),
					BackgroundColor3 = value and section.Tab.Window.Theme.Accent or section.Tab.Window.Theme.Background,
					BorderSizePixel = 0,
					Text = value and "✔" or "",
					Font = Enum.Font.SourceSansBold,
					TextSize = 14,
					TextColor3 = Color3.new(1,1,1),
				})
				corner(box, 4)
				stroke(box, section.Tab.Window.Theme.Border, 1, 0)

				local label = create("TextButton", {
					Parent = row,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 26, 0, 0),
					Size = UDim2.new(1, -26, 1, 0),
					Text = options.Text or "Checkbox",
					Font = Enum.Font.SourceSans,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = section.Tab.Window.Theme.TextMuted,
				})

				local object = {}
				function object:Set(newValue)
					value = newValue
					section.Tab.Window.Library:SetFlag(flag, value)
					box.Text = value and "✔" or ""
					box.BackgroundColor3 = value and section.Tab.Window.Theme.Accent or section.Tab.Window.Theme.Background
					section.Tab.Window.Library:SafeCallback(options.Callback, value)
				end
				local function flip()
					object:Set(not value)
				end
				box.MouseButton1Click:Connect(flip)
				label.MouseButton1Click:Connect(flip)
				return object
			end

			function section:AddSlider(options)
				options = options or {}
				local row = baseRow(44)
				local min = options.Min or 0
				local max = options.Max or 100
				local decimals = options.Decimals or 0
				local flag = options.Flag or options.Text or tostring(math.random())
				local value = math.clamp(options.Default or min, min, max)
				section.Tab.Window.Library:SetFlag(flag, value)

				local title = create("TextLabel", {
					Parent = row,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 16),
					Font = Enum.Font.SourceSans,
					Text = options.Text or "Slider",
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = section.Tab.Window.Theme.TextMuted,
				})
				local valueLabel = create("TextLabel", {
					Parent = row,
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -60, 0, 0),
					Size = UDim2.new(0, 60, 0, 16),
					Font = Enum.Font.SourceSansSemibold,
					Text = tostring(value),
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextColor3 = section.Tab.Window.Theme.Text,
				})

				local bar = create("Frame", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 24),
					Size = UDim2.new(1, 0, 0, 6),
					BackgroundColor3 = section.Tab.Window.Theme.Surface2,
					BorderSizePixel = 0,
				})
				corner(bar, 999)
				stroke(bar, section.Tab.Window.Theme.Border, 1, 0)

				local fill = create("Frame", {
					Parent = bar,
					Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
					BackgroundColor3 = section.Tab.Window.Theme.Accent,
					BorderSizePixel = 0,
				})
				corner(fill, 999)

				local knob = create("TextButton", {
					Parent = bar,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
					Size = UDim2.new(0, 14, 0, 14),
					BackgroundColor3 = Color3.fromRGB(245, 245, 245),
					BorderSizePixel = 0,
					Text = "",
				})
				corner(knob, 999)
				stroke(knob, section.Tab.Window.Theme.Accent, 2, 0)

				local draggingSlider = false
				local object = {}
				local function round(num)
					local power = 10 ^ decimals
					return math.round(num * power) / power
				end
				function object:Set(newValue)
					value = math.clamp(round(newValue), min, max)
					local pct = (value - min) / (max - min)
					fill.Size = UDim2.new(pct, 0, 1, 0)
					knob.Position = UDim2.new(pct, 0, 0.5, 0)
					valueLabel.Text = tostring(value)
					section.Tab.Window.Library:SetFlag(flag, value)
					section.Tab.Window.Library:SafeCallback(options.Callback, value)
				end
				function object:Get()
					return value
				end
				local function updateFromInput(input)
					local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					object:Set(min + ((max - min) * pct))
				end
				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = true
						updateFromInput(input)
					end
				end)
				knob.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = true
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
						updateFromInput(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = false
					end
				end)
				object:Set(value)
				return object
			end

			function section:AddTextbox(options)
				options = options or {}
				local row = baseRow(56)
				labelRow(row, options.Text or "Textbox")
				local flag = options.Flag or options.Text or tostring(math.random())
				local box = create("TextBox", {
					Parent = row,
					Position = UDim2.new(0.42, 8, 0, 0),
					Size = UDim2.new(0.58, -8, 0, 28),
					BackgroundColor3 = section.Tab.Window.Theme.Background,
					BorderSizePixel = 0,
					PlaceholderText = options.Placeholder or "Enter text",
					Text = options.Default or "",
					ClearTextOnFocus = false,
					Font = Enum.Font.SourceSans,
					TextSize = 14,
					TextColor3 = section.Tab.Window.Theme.Text,
					PlaceholderColor3 = section.Tab.Window.Theme.TextFaint,
				})
				corner(box, 5)
				stroke(box, section.Tab.Window.Theme.Border, 1, 0)
				padding(box, 8, 8, 0, 0)
				section.Tab.Window.Library:SetFlag(flag, box.Text)
				box.FocusLost:Connect(function(enterPressed)
					section.Tab.Window.Library:SetFlag(flag, box.Text)
					if not options.OnlyOnEnter or enterPressed then
						section.Tab.Window.Library:SafeCallback(options.Callback, box.Text)
					end
				end)
				return box
			end

			function section:AddDropdown(options)
				options = options or {}
				local row = baseRow(32)
				local values = options.Values or {}
				local flag = options.Flag or options.Text or tostring(math.random())
				local selected = options.Default or values[1] or "None"
				section.Tab.Window.Library:SetFlag(flag, selected)
				labelRow(row, options.Text or "Dropdown")

				local drop = create("TextButton", {
					Parent = row,
					Position = UDim2.new(0.42, 8, 0, 0),
					Size = UDim2.new(0.58, -8, 0, 28),
					BackgroundColor3 = section.Tab.Window.Theme.Background,
					BorderSizePixel = 0,
					Text = tostring(selected) .. "  ▾",
					Font = Enum.Font.SourceSans,
					TextSize = 14,
					TextColor3 = section.Tab.Window.Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				corner(drop, 5)
				stroke(drop, section.Tab.Window.Theme.Border, 1, 0)
				padding(drop, 8, 8, 0, 0)

				local list = create("Frame", {
					Parent = row,
					Position = UDim2.new(0.42, 8, 0, 32),
					Size = UDim2.new(0.58, -8, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = section.Tab.Window.Theme.Surface,
					BorderSizePixel = 0,
					Visible = false,
					ZIndex = 10,
				})
				corner(list, 5)
				stroke(list, section.Tab.Window.Theme.Border, 1, 0)
				local l = listLayout(list, 4, false)
				padding(list, 4, 4, 4, 4)

				local object = {}
				function object:Set(newValue)
					selected = newValue
					drop.Text = tostring(selected) .. "  ▾"
					section.Tab.Window.Library:SetFlag(flag, selected)
					section.Tab.Window.Library:SafeCallback(options.Callback, selected)
				end
				for _, value in ipairs(values) do
					local opt = create("TextButton", {
						Parent = list,
						BackgroundColor3 = section.Tab.Window.Theme.Surface2,
						Size = UDim2.new(1, 0, 0, 24),
						BorderSizePixel = 0,
						Text = tostring(value),
						Font = Enum.Font.SourceSans,
						TextSize = 14,
						TextColor3 = section.Tab.Window.Theme.TextMuted,
					})
					corner(opt, 4)
					opt.MouseButton1Click:Connect(function()
						list.Visible = false
						object:Set(value)
					end)
				end
				drop.MouseButton1Click:Connect(function()
					list.Visible = not list.Visible
				end)
				return object
			end

			function section:AddKeybind(options)
				options = options or {}
				local row = baseRow(32)
				local flag = options.Flag or options.Text or tostring(math.random())
				local current = options.Default or Enum.KeyCode.RightShift
				local listening = false
				labelRow(row, options.Text or "Keybind")

				local bindBtn = create("TextButton", {
					Parent = row,
					Position = UDim2.new(0.42, 8, 0, 0),
					Size = UDim2.new(0.58, -8, 0, 28),
					BackgroundColor3 = section.Tab.Window.Theme.Background,
					BorderSizePixel = 0,
					Text = current.Name,
					Font = Enum.Font.SourceSans,
					TextSize = 14,
					TextColor3 = section.Tab.Window.Theme.Text,
				})
				corner(bindBtn, 5)
				stroke(bindBtn, section.Tab.Window.Theme.Border, 1, 0)
				section.Tab.Window.Library:SetFlag(flag, current)

				bindBtn.MouseButton1Click:Connect(function()
					listening = true
					bindBtn.Text = "Press a key..."
				end)

				UserInputService.InputBegan:Connect(function(input, processed)
					if processed then
						return
					end
					if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
						listening = false
						current = input.KeyCode
						bindBtn.Text = current.Name
						section.Tab.Window.Library:SetFlag(flag, current)
						section.Tab.Window.Library:SafeCallback(options.Callback, current)
					elseif input.KeyCode == current then
						section.Tab.Window.Library:SafeCallback(options.Pressed, current)
					end
				end)
				return bindBtn
			end

			function section:AddParagraph(options)
				options = options or {}
				local holder = create("Frame", {
					Parent = bodyFrame,
					BackgroundColor3 = section.Tab.Window.Theme.Surface2,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 60),
					AutomaticSize = Enum.AutomaticSize.Y,
				})
				corner(holder, 5)
				stroke(holder, section.Tab.Window.Theme.Border, 1, 0)
				padding(holder, 8, 8, 8, 8)
				create("TextLabel", {
					Parent = holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					Font = Enum.Font.SourceSansSemibold,
					Text = options.Title or "Paragraph",
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = section.Tab.Window.Theme.Text,
				})
				create("TextLabel", {
					Parent = holder,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 18),
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Font = Enum.Font.SourceSans,
					TextWrapped = true,
					Text = options.Content or "",
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextColor3 = section.Tab.Window.Theme.TextMuted,
				})
				return holder
			end

			function section:AddSeparator(text)
				local row = baseRow(18)
				create("Frame", {
					Parent = row,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = section.Tab.Window.Theme.Border,
					BorderSizePixel = 0,
				})
				if text and text ~= "" then
					local size = textSize(text, 13, Enum.Font.SourceSansSemibold)
					local tag = create("TextLabel", {
						Parent = row,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0, size.X + 12, 0, 16),
						BackgroundColor3 = section.Tab.Window.Theme.Surface,
						BorderSizePixel = 0,
						Font = Enum.Font.SourceSansSemibold,
						Text = text,
						TextSize = 13,
						TextColor3 = section.Tab.Window.Theme.TextFaint,
					})
				end
				return row
			end

			return section
		end

		table.insert(self.Tabs, tab)
		if not self.CurrentTab then
			self:SelectTab(tab)
		end
		return tab
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(searchBox.Text)
		for _, tab in ipairs(window.Tabs) do
			tab.Button.Visible = query == "" or string.find(string.lower(tab.Name), query, 1, true) ~= nil
		end
	end)

	if options.WelcomeNotification ~= false then
		task.defer(function()
			window:Notify({
				Title = options.Title or "Studio Library",
				Content = "Loaded successfully. Press " .. tostring(window.Keybind.Name) .. " to toggle the menu.",
				Duration = 4,
			})
		end)
	end

	return window
end

function Library:LoadConfig(json)
	local ok, data = pcall(function()
		return HttpService:JSONDecode(json)
	end)
	if ok and typeof(data) == "table" then
		for key, value in pairs(data) do
			self.Flags[key] = value
		end
	end
	return ok
end

function Library:SaveConfig()
	return HttpService:JSONEncode(self.Flags)
end

Library:SetTheme("StudioDark")

return Library
