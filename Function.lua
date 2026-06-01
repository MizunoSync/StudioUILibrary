-- ╔══════════════════════════════════════════════════════╗
-- ║  StudioUILibrary  v2.0  —  MizunoSync / Gui e Cia   ║
-- ║  Full rework: better layout, polish, Studio feel    ║
-- ╚══════════════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local TextService      = game:GetService("TextService")

local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- ─── Library Object ───────────────────────────────────
local Library = {
	Version = "2.0.0",
	Theme   = {},
	Flags   = {},
	_Notifications = nil,
}

-- ─── Themes ───────────────────────────────────────────
local Themes = {
	StudioDark = {
		BG        = Color3.fromRGB(26, 27, 30),      -- outermost window
		Panel     = Color3.fromRGB(33, 34, 38),      -- sidebar / titlebar
		Card      = Color3.fromRGB(38, 39, 44),      -- section cards
		CardHead  = Color3.fromRGB(42, 44, 49),      -- card header row
		Input     = Color3.fromRGB(22, 23, 26),      -- textbox / slider track
		Hover     = Color3.fromRGB(52, 54, 60),      -- button hover
		Border    = Color3.fromRGB(58, 60, 67),      -- subtle borders
		DivLine   = Color3.fromRGB(48, 50, 56),      -- divider lines
		Text      = Color3.fromRGB(240, 240, 242),
		TextMuted = Color3.fromRGB(172, 174, 182),
		TextFaint = Color3.fromRGB(102, 105, 115),
		Accent    = Color3.fromRGB(14, 106, 210),    -- blue CTA
		AccentHov = Color3.fromRGB(38, 130, 240),
		AccentSft = Color3.fromRGB(14, 106, 210),
		TabActive = Color3.fromRGB(14, 106, 210),    -- active tab pill
		Success   = Color3.fromRGB(38, 185, 110),
		Warning   = Color3.fromRGB(222, 165, 48),
		Danger    = Color3.fromRGB(218, 80, 90),
		White     = Color3.fromRGB(255, 255, 255),
	},
	StudioLight = {
		BG        = Color3.fromRGB(218, 220, 224),
		Panel     = Color3.fromRGB(236, 238, 242),
		Card      = Color3.fromRGB(248, 249, 251),
		CardHead  = Color3.fromRGB(232, 234, 238),
		Input     = Color3.fromRGB(255, 255, 255),
		Hover     = Color3.fromRGB(210, 213, 220),
		Border    = Color3.fromRGB(190, 193, 200),
		DivLine   = Color3.fromRGB(200, 203, 210),
		Text      = Color3.fromRGB(28, 30, 36),
		TextMuted = Color3.fromRGB(75, 78, 88),
		TextFaint = Color3.fromRGB(130, 134, 145),
		Accent    = Color3.fromRGB(14, 100, 200),
		AccentHov = Color3.fromRGB(38, 124, 230),
		AccentSft = Color3.fromRGB(14, 100, 200),
		TabActive = Color3.fromRGB(14, 100, 200),
		Success   = Color3.fromRGB(32, 160, 90),
		Warning   = Color3.fromRGB(190, 130, 22),
		Danger    = Color3.fromRGB(190, 65, 75),
		White     = Color3.fromRGB(255, 255, 255),
	},
}

-- ─── Utility ──────────────────────────────────────────
local function copy(t)
	local n = {}
	for k,v in pairs(t) do n[k] = (type(v)=="table") and copy(v) or v end
	return n
end

local function tw(obj, props, dur, style)
	local info = TweenInfo.new(dur or 0.15, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(obj, info, props):Play()
end

local function new(class, props)
	local inst = Instance.new(class)
	for k,v in pairs(props or {}) do
		if k ~= "Parent" then inst[k] = v end
	end
	inst.Parent = props and props.Parent
	return inst
end

local function uiCorner(p, r)
	return new("UICorner",{Parent=p,CornerRadius=UDim.new(0,r or 6)})
end

local function uiStroke(p, col, thick, trans)
	return new("UIStroke",{Parent=p,Color=col,Thickness=thick or 1,Transparency=trans or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end

local function uiPad(p, l, r, t, b)
	return new("UIPadding",{Parent=p,PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or l or 0),PaddingTop=UDim.new(0,t or l or 0),PaddingBottom=UDim.new(0,b or t or l or 0)})
end

local function uiList(p, gap, horiz)
	return new("UIListLayout",{Parent=p,Padding=UDim.new(0,gap or 0),FillDirection=horiz and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Top,HorizontalAlignment=Enum.HorizontalAlignment.Left})
end

local function hoverBtn(btn, normal, hover)
	btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=hover},0.1) end)
	btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=normal},0.1) end)
	btn.MouseButton1Down:Connect(function() tw(btn,{BackgroundColor3=normal:Lerp(Color3.new(0,0,0),0.1)},0.05) end)
	btn.MouseButton1Up:Connect(function() tw(btn,{BackgroundColor3=hover},0.1) end)
end

-- ─── Library API ──────────────────────────────────────
function Library:SetTheme(name)
	self.Theme = copy(type(name)=="string" and (Themes[name] or Themes.StudioDark) or name)
end

function Library:SetFlag(k,v) self.Flags[k]=v end
function Library:GetFlag(k)   return self.Flags[k] end

function Library:Call(fn, ...)
	if type(fn)~="function" then return end
	local ok,err = pcall(fn, ...)
	if not ok then warn("[StudioLib] Callback error:",err) end
end

function Library:Notify(opts)
	opts = opts or {}
	local holder = self._Notifications
	if not holder then return end
	local T = self.Theme

	local accentCol = opts.Type=="Error" and T.Danger or opts.Type=="Warning" and T.Warning or T.Accent

	local frame = new("Frame",{Parent=holder,BackgroundColor3=T.Card,BorderSizePixel=0,Size=UDim2.new(1,0,0,10),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,ClipsDescendants=true})
	uiCorner(frame,7)
	uiStroke(frame,T.Border,1,0)

	-- left colour bar
	new("Frame",{Parent=frame,BackgroundColor3=accentCol,BorderSizePixel=0,Size=UDim2.new(0,3,1,0)})
	uiCorner(frame,7) -- re-clip

	local inner = new("Frame",{Parent=frame,BackgroundTransparency=1,Position=UDim2.new(0,10,0,0),Size=UDim2.new(1,-14,1,0),AutomaticSize=Enum.AutomaticSize.Y})
	uiPad(inner,0,0,9,9)
	uiList(inner,4)

	new("TextLabel",{Parent=inner,BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),Font=Enum.Font.SourceSansSemibold,Text=opts.Title or "Notification",TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.Text})
	new("TextLabel",{Parent=inner,BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.SourceSans,TextWrapped=true,Text=opts.Content or "",TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextColor3=T.TextMuted})

	tw(frame,{BackgroundTransparency=0},0.15)
	task.delay(opts.Duration or 4,function()
		if frame.Parent then
			tw(frame,{BackgroundTransparency=1},0.15)
			task.wait(0.18)
			frame:Destroy()
		end
	end)
end

function Library:SaveConfig()  return HttpService:JSONEncode(self.Flags) end
function Library:LoadConfig(j)
	local ok,d = pcall(function() return HttpService:JSONDecode(j) end)
	if ok and type(d)=="table" then for k,v in pairs(d) do self.Flags[k]=v end end
	return ok
end

-- ─── CreateWindow ─────────────────────────────────────
function Library:CreateWindow(opts)
	opts = opts or {}
	self:SetTheme(opts.Theme or "StudioDark")
	local T = self.Theme

	local W = { Library=self, Theme=T, Flags=self.Flags, Tabs={}, _current=nil, Keybind=opts.Keybind or Enum.KeyCode.RightShift }

	-- ScreenGui
	local existing = LP:WaitForChild("PlayerGui"):FindFirstChild(opts.GuiName or "StudioLibrary")
	if existing then existing:Destroy() end
	local gui = new("ScreenGui",{Name=opts.GuiName or "StudioLibrary",ResetOnSpawn=false,IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=LP:WaitForChild("PlayerGui")})
	W.Gui = gui

	-- Root window frame
	local root = new("Frame",{Parent=gui,AnchorPoint=Vector2.new(0.5,0.5),Position=opts.Position or UDim2.new(0.5,0,0.5,0),Size=opts.Size or UDim2.new(0,900,0,570),BackgroundColor3=T.BG,BorderSizePixel=0,ClipsDescendants=true})
	uiCorner(root,8)
	uiStroke(root,T.Border,1,0)
	new("UISizeConstraint",{Parent=root,MinSize=Vector2.new(720,440)})
	W.Root = root

	-- ── Title bar ──
	local tbar = new("Frame",{Parent=root,Size=UDim2.new(1,0,0,38),BackgroundColor3=T.Panel,BorderSizePixel=0})
	uiStroke(tbar,T.DivLine,1,0)
	-- bottom separator line
	new("Frame",{Parent=tbar,Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=T.DivLine,BorderSizePixel=0})

	-- accent stripe on title bar left edge
	new("Frame",{Parent=tbar,Size=UDim2.new(0,3,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0})

	new("TextLabel",{Parent=tbar,BackgroundTransparency=1,Position=UDim2.new(0,14,0,0),Size=UDim2.new(0,200,1,0),Text=opts.Title or "Studio Library",Font=Enum.Font.SourceSansBold,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.Text})
	new("TextLabel",{Parent=tbar,BackgroundTransparency=1,Position=UDim2.new(0,198,0,0),Size=UDim2.new(0,260,1,0),Text=opts.Subtitle or "v2.0",Font=Enum.Font.SourceSans,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.TextFaint})

	-- window buttons: minimise + close
	local function winBtn(offsetRight, label, col)
		local b = new("TextButton",{Parent=tbar,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-offsetRight,0.5,0),Size=UDim2.new(0,22,0,20),BackgroundColor3=col,BorderSizePixel=0,Text=label,Font=Enum.Font.SourceSansBold,TextSize=13,TextColor3=Color3.fromRGB(230,230,230)})
		uiCorner(b,4)
		return b
	end
	local closeBtn = winBtn(10,  "✕", Color3.fromRGB(196,64,72))
	local miniBtn  = winBtn(36,  "–", Color3.fromRGB(60,62,68))
	hoverBtn(closeBtn, Color3.fromRGB(196,64,72), Color3.fromRGB(215,80,88))
	hoverBtn(miniBtn,  Color3.fromRGB(60,62,68),  T.Hover)
	local minimised = false
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
	miniBtn.MouseButton1Click:Connect(function()
		minimised = not minimised
		body.Visible = not minimised
		root.Size = minimised and UDim2.new(0,root.AbsoluteSize.X,0,38) or (opts.Size or UDim2.new(0,900,0,570))
	end)

	-- ── Body ──
	local body = new("Frame",{Parent=root,Position=UDim2.new(0,0,0,38),Size=UDim2.new(1,0,1,-38),BackgroundTransparency=1})
	W._body = body

	-- ── Sidebar ──
	local sidebar = new("Frame",{Parent=body,Size=UDim2.new(0,200,1,0),BackgroundColor3=T.Panel,BorderSizePixel=0})
	new("Frame",{Parent=sidebar,Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=T.DivLine,BorderSizePixel=0})

	-- search inside sidebar
	local searchHolder = new("Frame",{Parent=sidebar,Position=UDim2.new(0,8,0,8),Size=UDim2.new(1,-16,0,26),BackgroundColor3=T.Input,BorderSizePixel=0})
	uiCorner(searchHolder,5)
	uiStroke(searchHolder,T.Border,1,0)
	new("TextLabel",{Parent=searchHolder,BackgroundTransparency=1,Position=UDim2.new(0,6,0,0),Size=UDim2.new(0,16,1,0),Text="⌕",Font=Enum.Font.SourceSans,TextSize=16,TextColor3=T.TextFaint,TextXAlignment=Enum.TextXAlignment.Left})
	local searchBox = new("TextBox",{Parent=searchHolder,Position=UDim2.new(0,22,0,0),Size=UDim2.new(1,-26,1,0),BackgroundTransparency=1,BorderSizePixel=0,PlaceholderText="Filter tabs…",Text="",ClearTextOnFocus=false,Font=Enum.Font.SourceSans,TextSize=14,TextColor3=T.Text,PlaceholderColor3=T.TextFaint})

	local tabScroll = new("ScrollingFrame",{Parent=sidebar,Position=UDim2.new(0,8,0,42),Size=UDim2.new(1,-16,1,-50),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarImageColor3=T.Border,ScrollBarThickness=3,ElasticBehavior=Enum.ElasticBehavior.Never})
	uiList(tabScroll,4)

	-- ── Content area ──
	local content = new("Frame",{Parent=body,Position=UDim2.new(0,200,0,0),Size=UDim2.new(1,-200,1,0),BackgroundColor3=T.BG,BorderSizePixel=0})
	local pageHolder = new("Frame",{Parent=content,Position=UDim2.new(0,10,0,10),Size=UDim2.new(1,-20,1,-20),BackgroundTransparency=1})

	-- ── Notification holder (top-right of screen) ──
	local notifHolder = new("Frame",{Parent=gui,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12),Size=UDim2.new(0,290,1,0),BackgroundTransparency=1})
	uiList(notifHolder,8)
	self._Notifications = notifHolder

	-- ── Drag ──
	local drag, dragInp, dragStart, startPos = false,nil,nil,nil
	tbar.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 then
			drag=true; dragStart=inp.Position; startPos=root.Position
			inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then drag=false end end)
		end
	end)
	tbar.InputChanged:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseMovement then dragInp=inp end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if drag and inp==dragInp then
			local d=inp.Position-dragStart
			root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
		end
	end)

	-- ── Keybind toggle ──
	UserInputService.InputBegan:Connect(function(inp,proc)
		if not proc and inp.KeyCode==W.Keybind then root.Visible=not root.Visible end
	end)

	-- ── Tab search filter ──
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q=searchBox.Text:lower()
		for _,tab in ipairs(W.Tabs) do
			tab._btn.Visible = q=="" or tab.Name:lower():find(q,1,true)~=nil
		end
	end)

	-- ── Window methods ──
	function W:Notify(d) self.Library:Notify(d) end
	function W:Destroy() gui:Destroy() end
	function W:SetVisible(v) root.Visible=v end
	function W:SetAccent(c)
		self.Theme.Accent=c
		self.Theme.AccentHov=c:Lerp(Color3.new(1,1,1),0.2)
	end

	function W:_selectTab(tabObj)
		for _,t in ipairs(self.Tabs) do
			local active = t==tabObj
			-- active tab: accent bg, white text, left accent bar shows
			tw(t._btn, {BackgroundColor3 = active and T.Accent or T.Panel}, 0.12)
			t._btn.TextColor3 = active and T.White or T.TextMuted
			t._accentBar.Visible = active
			t._page.Visible = active
		end
		self._current = tabObj
	end

	-- ── CreateTab ──
	function W:CreateTab(name, icon)
		local tab = { Name=name, Window=self, _sections={} }

		-- Sidebar button
		local btn = new("TextButton",{Parent=tabScroll,BackgroundColor3=T.Panel,BorderSizePixel=0,Size=UDim2.new(1,0,0,34),Text=(icon or "◼").."  "..name,Font=Enum.Font.SourceSansSemibold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.TextMuted,ClipsDescendants=true})
		uiCorner(btn,5)
		uiPad(btn,10,10,0,0)
		hoverBtn(btn,T.Panel,T.Hover)

		-- left accent bar (hidden when inactive)
		local accentBar = new("Frame",{Parent=btn,Size=UDim2.new(0,3,1,0),BackgroundColor3=T.White,BorderSizePixel=0,Visible=false})
		uiCorner(accentBar,99)

		tab._btn = btn
		tab._accentBar = accentBar

		-- Content page (2-column scrolling grid)
		local page = new("ScrollingFrame",{Parent=pageHolder,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarImageColor3=T.Border,ScrollBarThickness=4,BorderSizePixel=0,Visible=false,ElasticBehavior=Enum.ElasticBehavior.Never})
		local pageGrid = new("UIGridLayout",{Parent=page,CellSize=UDim2.new(0.5,-7,0,1),CellPadding=UDim2.new(0,12,0,12),SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Horizontal})
		uiPad(page,0,4,0,12)
		pageGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize=UDim2.new(0,0,0,pageGrid.AbsoluteContentSize.Y+12)
		end)
		tab._page = page
		tab._grid = pageGrid

		btn.MouseButton1Click:Connect(function() self:_selectTab(tab) end)
		table.insert(self.Tabs, tab)
		if #self.Tabs==1 then self:_selectTab(tab) end

		-- ── CreateSection ──
		function tab:CreateSection(title)
			local sec = { _tab=self }

			-- Card container (AutomaticSize Y)
			local card = new("Frame",{Parent=page,BackgroundColor3=T.Card,BorderSizePixel=0,Size=UDim2.new(1,0,0,10),AutomaticSize=Enum.AutomaticSize.Y})
			uiCorner(card,7)
			uiStroke(card,T.Border,1,0)

			-- Section header
			local head = new("Frame",{Parent=card,BackgroundColor3=T.CardHead,BorderSizePixel=0,Size=UDim2.new(1,0,0,28)})
			uiCorner(head,7)
			-- cover bottom corners of header
			new("Frame",{Parent=head,Position=UDim2.new(0,0,1,-7),Size=UDim2.new(1,0,0,7),BackgroundColor3=T.CardHead,BorderSizePixel=0})
			new("Frame",{Parent=head,Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=T.DivLine,BorderSizePixel=0})
			-- accent left tick on header
			new("Frame",{Parent=head,Size=UDim2.new(0,3,0.7,0),AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=T.Accent,BorderSizePixel=0})
			new("TextLabel",{Parent=head,BackgroundTransparency=1,Position=UDim2.new(0,10,0,0),Size=UDim2.new(1,-12,1,0),Font=Enum.Font.SourceSansSemibold,Text=title,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.TextMuted})

			-- body frame for elements
			local body = new("Frame",{Parent=card,BackgroundTransparency=1,Position=UDim2.new(0,10,0,34),Size=UDim2.new(1,-20,0,0),AutomaticSize=Enum.AutomaticSize.Y})
			local bl = uiList(body,7)
			uiPad(body,0,0,0,10)
			sec._body = body

			-- ── Row helpers ──
			local function row(h)
				return new("Frame",{Parent=body,BackgroundTransparency=1,Size=UDim2.new(1,0,0,h or 30)})
			end
			local function propLabel(r, txt)
				new("TextLabel",{Parent=r,BackgroundTransparency=1,Size=UDim2.new(0.44,0,1,0),Font=Enum.Font.SourceSans,Text=txt,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.TextMuted})
			end

			-- ── AddLabel ──
			function sec:AddLabel(text, opts2)
				opts2 = opts2 or {}
				local lbl = new("TextLabel",{Parent=body,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.SourceSans,Text=text,TextWrapped=true,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextColor3=opts2.Color or T.TextMuted})
				if opts2.Background then
					lbl.BackgroundTransparency=0
					lbl.BackgroundColor3=T.Input
					uiCorner(lbl,4)
					uiPad(lbl,8,8,6,6)
				end
				return lbl
			end

			-- ── AddButton ──
			function sec:AddButton(opts2)
				opts2 = opts2 or {}
				local r = row(30)
				local isPrimary = opts2.Primary
				local bgNorm = isPrimary and T.Accent or T.CardHead
				local bgHov  = isPrimary and T.AccentHov or T.Hover
				local btn2 = new("TextButton",{Parent=r,BackgroundColor3=bgNorm,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),Font=Enum.Font.SourceSansSemibold,Text=opts2.Text or "Button",TextSize=15,TextColor3=isPrimary and T.White or T.Text})
				uiCorner(btn2,5)
				uiStroke(btn2, isPrimary and T.Accent or T.Border, 1, 0)
				hoverBtn(btn2,bgNorm,bgHov)
				btn2.MouseButton1Click:Connect(function() sec._tab.Window.Library:Call(opts2.Callback) end)
				return btn2
			end

			-- ── AddToggle ──
			function sec:AddToggle(opts2)
				opts2 = opts2 or {}
				local r = row(28)
				propLabel(r, opts2.Text or "Toggle")
				local flag = opts2.Flag or opts2.Text or tostring(math.random())
				local val  = opts2.Default == true
				sec._tab.Window.Library:SetFlag(flag,val)

				local track = new("TextButton",{Parent=r,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.new(0,40,0,20),BackgroundColor3=val and T.Accent or T.Input,BorderSizePixel=0,Text=""})
				uiCorner(track,99)
				uiStroke(track,T.Border,1,0)
				local knob = new("Frame",{Parent=track,AnchorPoint=Vector2.new(0,0.5),Position=val and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0),Size=UDim2.new(0,14,0,14),BackgroundColor3=T.White,BorderSizePixel=0})
				uiCorner(knob,99)

				local obj = {}
				function obj:Set(v)
					val=v; sec._tab.Window.Library:SetFlag(flag,val)
					tw(track,{BackgroundColor3=val and T.Accent or T.Input},0.14)
					tw(knob,{Position=val and UDim2.new(1,-19,0.5,0) or UDim2.new(0,3,0.5,0)},0.14)
					sec._tab.Window.Library:Call(opts2.Callback,val)
				end
				function obj:Get() return val end
				track.MouseButton1Click:Connect(function() obj:Set(not val) end)
				return obj
			end

			-- ── AddCheckbox ──
			function sec:AddCheckbox(opts2)
				opts2 = opts2 or {}
				local r = row(24)
				local flag = opts2.Flag or opts2.Text or tostring(math.random())
				local val  = opts2.Default == true
				sec._tab.Window.Library:SetFlag(flag,val)

				local box = new("TextButton",{Parent=r,Position=UDim2.new(0,0,0.5,-9),Size=UDim2.new(0,18,0,18),BackgroundColor3=val and T.Accent or T.Input,BorderSizePixel=0,Text=val and "✔" or "",Font=Enum.Font.SourceSansBold,TextSize=13,TextColor3=T.White})
				uiCorner(box,4)
				uiStroke(box,T.Border,1,0)
				local lbl2 = new("TextButton",{Parent=r,BackgroundTransparency=1,Position=UDim2.new(0,26,0,0),Size=UDim2.new(1,-26,1,0),Text=opts2.Text or "Checkbox",Font=Enum.Font.SourceSans,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.TextMuted})

				local obj={}
				function obj:Set(v)
					val=v; sec._tab.Window.Library:SetFlag(flag,val)
					box.Text=val and "✔" or ""
					tw(box,{BackgroundColor3=val and T.Accent or T.Input},0.12)
					sec._tab.Window.Library:Call(opts2.Callback,val)
				end
				box.MouseButton1Click:Connect(function() obj:Set(not val) end)
				lbl2.MouseButton1Click:Connect(function() obj:Set(not val) end)
				return obj
			end

			-- ── AddSlider ──
			function sec:AddSlider(opts2)
				opts2 = opts2 or {}
				local r = row(48)
				r.Size = UDim2.new(1,0,0,48)
				local min2,max2 = opts2.Min or 0, opts2.Max or 100
				local dec   = opts2.Decimals or 0
				local flag  = opts2.Flag or opts2.Text or tostring(math.random())
				local val   = math.clamp(opts2.Default or min2,min2,max2)
				sec._tab.Window.Library:SetFlag(flag,val)

				-- top row: label + value
				local topRow = new("Frame",{Parent=r,BackgroundTransparency=1,Size=UDim2.new(1,0,0,18)})
				new("TextLabel",{Parent=topRow,BackgroundTransparency=1,Size=UDim2.new(0.7,0,1,0),Font=Enum.Font.SourceSans,Text=opts2.Text or "Slider",TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.TextMuted})
				local valLbl = new("TextLabel",{Parent=topRow,BackgroundTransparency=1,Position=UDim2.new(0.7,0,0,0),Size=UDim2.new(0.3,0,1,0),Font=Enum.Font.SourceSansSemibold,Text=tostring(val),TextSize=14,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=T.Text})

				-- track
				local track = new("Frame",{Parent=r,Position=UDim2.new(0,0,0,26),Size=UDim2.new(1,0,0,5),BackgroundColor3=T.Input,BorderSizePixel=0})
				uiCorner(track,99)
				uiStroke(track,T.Border,1,0)
				local fill = new("Frame",{Parent=track,Size=UDim2.new((val-min2)/(max2-min2),0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0})
				uiCorner(fill,99)
				local knob2 = new("TextButton",{Parent=track,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new((val-min2)/(max2-min2),0,0.5,0),Size=UDim2.new(0,14,0,14),BackgroundColor3=T.White,BorderSizePixel=0,Text=""})
				uiCorner(knob2,99)
				uiStroke(knob2,T.Accent,2,0)

				local obj={}; local dragging2=false
				local function round2(n) local p=10^dec; return math.round(n*p)/p end
				function obj:Set(v)
					val=math.clamp(round2(v),min2,max2)
					local pct=(val-min2)/(max2-min2)
					fill.Size=UDim2.new(pct,0,1,0)
					knob2.Position=UDim2.new(pct,0,0.5,0)
					valLbl.Text=tostring(val)
					sec._tab.Window.Library:SetFlag(flag,val)
					sec._tab.Window.Library:Call(opts2.Callback,val)
				end
				function obj:Get() return val end

				local function fromInput(inp)
					local pct=math.clamp((inp.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
					obj:Set(min2+(max2-min2)*pct)
				end
				track.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging2=true; fromInput(inp) end end)
				knob2.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging2=true end end)
				UserInputService.InputChanged:Connect(function(inp) if dragging2 and inp.UserInputType==Enum.UserInputType.MouseMovement then fromInput(inp) end end)
				UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging2=false end end)
				obj:Set(val)
				return obj
			end

			-- ── AddTextbox ──
			function sec:AddTextbox(opts2)
				opts2 = opts2 or {}
				local r = row(50)
				r.Size = UDim2.new(1,0,0,50)
				local flag = opts2.Flag or opts2.Text or tostring(math.random())

				new("TextLabel",{Parent=r,BackgroundTransparency=1,Size=UDim2.new(1,0,0,16),Font=Enum.Font.SourceSans,Text=opts2.Text or "Textbox",TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.TextMuted})
				local box2 = new("TextBox",{Parent=r,Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,26),BackgroundColor3=T.Input,BorderSizePixel=0,PlaceholderText=opts2.Placeholder or "",Text=opts2.Default or "",ClearTextOnFocus=false,Font=Enum.Font.SourceSans,TextSize=14,TextColor3=T.Text,PlaceholderColor3=T.TextFaint})
				uiCorner(box2,5)
				uiStroke(box2,T.Border,1,0)
				uiPad(box2,8,8,0,0)
				sec._tab.Window.Library:SetFlag(flag,box2.Text)
				box2.FocusLost:Connect(function(enter)
					sec._tab.Window.Library:SetFlag(flag,box2.Text)
					if not opts2.OnlyOnEnter or enter then
						sec._tab.Window.Library:Call(opts2.Callback,box2.Text)
					end
				end)
				return box2
			end

			-- ── AddDropdown ──
			function sec:AddDropdown(opts2)
				opts2 = opts2 or {}
				local r = row(28)
				local vals = opts2.Values or {}
				local flag = opts2.Flag or opts2.Text or tostring(math.random())
				local sel  = opts2.Default or vals[1] or "None"
				sec._tab.Window.Library:SetFlag(flag,sel)
				propLabel(r, opts2.Text or "Dropdown")

				local dropBtn = new("TextButton",{Parent=r,Position=UDim2.new(0.44,6,0,0),Size=UDim2.new(0.56,-6,1,0),BackgroundColor3=T.Input,BorderSizePixel=0,Text=tostring(sel).."  ▾",Font=Enum.Font.SourceSans,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.Text})
				uiCorner(dropBtn,5)
				uiStroke(dropBtn,T.Border,1,0)
				uiPad(dropBtn,8,8,0,0)

				local popup = new("Frame",{Parent=r,Position=UDim2.new(0.44,6,1,2),Size=UDim2.new(0.56,-6,0,0),BackgroundColor3=T.Card,BorderSizePixel=0,Visible=false,ZIndex=20,AutomaticSize=Enum.AutomaticSize.Y,ClipsDescendants=false})
				uiCorner(popup,6)
				uiStroke(popup,T.Border,1,0)
				uiPad(popup,4,4,4,4)
				uiList(popup,3)

				local obj2={}
				function obj2:Set(v)
					sel=v; dropBtn.Text=tostring(v).."  ▾"
					sec._tab.Window.Library:SetFlag(flag,sel)
					sec._tab.Window.Library:Call(opts2.Callback,sel)
				end
				for _,v2 in ipairs(vals) do
					local opt = new("TextButton",{Parent=popup,BackgroundColor3=T.CardHead,BorderSizePixel=0,Size=UDim2.new(1,0,0,24),Text=tostring(v2),Font=Enum.Font.SourceSans,TextSize=14,TextColor3=T.TextMuted,ZIndex=21})
					uiCorner(opt,4)
					hoverBtn(opt,T.CardHead,T.Hover)
					opt.MouseButton1Click:Connect(function() popup.Visible=false; obj2:Set(v2) end)
				end
				dropBtn.MouseButton1Click:Connect(function() popup.Visible=not popup.Visible end)
				-- close when clicking elsewhere
				game:GetService("UserInputService").InputBegan:Connect(function(inp)
					if inp.UserInputType==Enum.UserInputType.MouseButton1 and popup.Visible then
						task.wait() -- defer so button click fires first
						popup.Visible=false
					end
				end)
				return obj2
			end

			-- ── AddKeybind ──
			function sec:AddKeybind(opts2)
				opts2 = opts2 or {}
				local r = row(28)
				local flag = opts2.Flag or opts2.Text or tostring(math.random())
				local cur  = opts2.Default or Enum.KeyCode.RightShift
				local listening = false
				propLabel(r, opts2.Text or "Keybind")
				sec._tab.Window.Library:SetFlag(flag,cur)

				local kb = new("TextButton",{Parent=r,Position=UDim2.new(0.44,6,0,0),Size=UDim2.new(0.56,-6,1,0),BackgroundColor3=T.Input,BorderSizePixel=0,Text="["..cur.Name.."]",Font=Enum.Font.SourceSans,TextSize=14,TextColor3=T.Text})
				uiCorner(kb,5)
				uiStroke(kb,T.Border,1,0)
				hoverBtn(kb,T.Input,T.Hover)

				kb.MouseButton1Click:Connect(function()
					listening=true; kb.Text="[Press a key…]"; kb.TextColor3=T.Accent
				end)
				UserInputService.InputBegan:Connect(function(inp,proc)
					if proc then return end
					if listening and inp.KeyCode~=Enum.KeyCode.Unknown then
						listening=false; cur=inp.KeyCode
						kb.Text="["..cur.Name.."]"; kb.TextColor3=T.Text
						sec._tab.Window.Library:SetFlag(flag,cur)
						sec._tab.Window.Library:Call(opts2.Callback,cur)
					elseif inp.KeyCode==cur then
						sec._tab.Window.Library:Call(opts2.Pressed,cur)
					end
				end)
				return kb
			end

			-- ── AddParagraph ──
			function sec:AddParagraph(opts2)
				opts2 = opts2 or {}
				local holder2 = new("Frame",{Parent=body,BackgroundColor3=T.Input,BorderSizePixel=0,Size=UDim2.new(1,0,0,10),AutomaticSize=Enum.AutomaticSize.Y})
				uiCorner(holder2,6)
				uiStroke(holder2,T.Border,1,0)
				uiPad(holder2,10,10,8,8)
				uiList(holder2,4)
				new("TextLabel",{Parent=holder2,BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),Font=Enum.Font.SourceSansSemibold,Text=opts2.Title or "Paragraph",TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.Text})
				new("TextLabel",{Parent=holder2,BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.SourceSans,TextWrapped=true,Text=opts2.Content or "",TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextColor3=T.TextMuted})
				return holder2
			end

			-- ── AddSeparator ──
			function sec:AddSeparator(label)
				local r = row(16)
				new("Frame",{Parent=r,Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=T.DivLine,BorderSizePixel=0})
				if label and label~="" then
					local tw2 = TextService:GetTextSize(label,12,Enum.Font.SourceSansSemibold,Vector2.new(9999,9999))
					local tag2 = new("TextLabel",{Parent=r,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,tw2.X+12,0,14),BackgroundColor3=T.Card,BorderSizePixel=0,Font=Enum.Font.SourceSansSemibold,Text=label,TextSize=12,TextColor3=T.TextFaint})
				end
				return r
			end

			return sec
		end -- CreateSection

		return tab
	end -- CreateTab

	if opts.WelcomeNotification ~= false then
		task.defer(function()
			W:Notify({ Title=opts.Title or "Studio Library", Content="Loaded · Press "..W.Keybind.Name.." to toggle.", Duration=4 })
		end)
	end

	return W
end -- CreateWindow

Library:SetTheme("StudioDark")
return Library
