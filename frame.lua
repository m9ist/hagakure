if not Hagakure then return end
local L = Hagakure:GetLocale() -- Загрузка локали
local LSM = LibStub("LibSharedMedia-3.0") -- Загружаем библиотеку для загрузки шрифтов и тд
local module_name = "HFrameCreate"
local window = Hagakure:NewModule(module_name)
window.debug = true
local fontconf = nil

--[[
	window = {
		frame = nil, -- ссылка на главный фрейм, в котором все создается/привязывается
		title = nil, -- ссылка на фрейм title
		close = nil, -- ссылка на кнопку закрытия окна
		cont = {
			item = nil,  -- ссылка на строку с линком на шмотку
			slider = nil,-- ссылка на слайдер
			spec  = nil, -- ссылка на чекбоксы со спеками
			button = nil,-- ссылка на кнопку оповещения
			list  = nil, -- ссылка на список рейда
		},
		msg   = nil, -- ссылка на строку для ввода сообщения
		msgB  = nil, -- ссылка на кнопку открытия чата
		chat  = nil, -- ссылка на фрейм с чатом, в нем же создается текст	
	}


]]--
do -- initialize addon
	function window:debug(...)
		if self.debug then
			Hagakure:Print(...)
		end
	end

	function window:debugf(...)
		if self.debug then
			Hagakure:Printf(...)
		end
	end

	function window:OnEnable()
		self.windows = {}
		fontconf = Hagakure.db.profile.font
	end
end

function window:CreateFrame() -- создает пустой фрейм с сайзером, который можно двигать
	local frame = CreateFrame("Frame", nil, UIParent)
	local fconf = Hagakure.db.profile.frame

	do -- additional functions
		local points = {}
		function frame:SavePoint(...)
			local t = {}
			t.a1, t.a2, t.a3, t.a4, t.a5 = ...
			table.insert(points,t)
			self:RenewPoints()
		end
		
		function frame:RenewPoints()
			if # points == 0 then return end
			self:ClearAllPoints()
			for _, i in next, points do
				self:SetPoint(i.a1,i.a2,i.a3,i.a4,i.a5)
			end
		end
	end
	
	do -- создание непосредственно фрейма
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetResizable(true)
		frame:SetToplevel(true)
		frame:SetClampedToScreen(true)
		frame:SetFrameStrata("FULLSCREEN_DIALOG")
		
		local FrameBackdrop = {
			bgFile = LSM:Fetch("background",fconf.background),
			edgeFile = LSM:Fetch("border",fconf.border),
			tile = false, tileSize = 0, edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
		}
		frame:SetBackdrop(FrameBackdrop)
		frame:SetMinResize(200,100)
		
		frame.sizable = 0 -- 0 если фиксирована ширина 1 если увеличивается вниз/вверх 2 если увеличивается право/влево 3 если увеличивается в 2х направлениях
	end
	
	do -- "увеличители окна"
		local sz = Hagakure.frame_configurations.sizer_styles[fconf.sizer]
		local sizer_se = CreateFrame("Frame", nil, frame)
		sizer_se:SetPoint("BOTTOMRIGHT")
		sizer_se:SetWidth(25)
		sizer_se:SetHeight(25)
		sizer_se:EnableMouse()
		
		local sizer_tx = frame:CreateTexture(nil, "ARTWORK")
		sizer_tx:SetWidth(sz.w)
		sizer_tx:SetHeight(sz.h)
		sizer_tx:SetPoint("BOTTOMRIGHT", -5, 5)
		sizer_tx:SetTexture(sz.file)
		
		local state = 0 -- если мышка на уголка - 1 если мышка нажата на уголке - 2 если мышка нажата вне уголка - 3 ну и 0 - оставшееся
		if sz.over then 
			sizer_se:SetScript("OnEnter", function() 
				if state == 0 then sizer_tx:SetTexture(sz.over); state = 1 end 
				if state == 3 then state = 2 end
			end) 
			sizer_se:SetScript("OnLeave", function() 
				if state == 1 then sizer_tx:SetTexture(sz.file); state = 0 end 
				if state == 2 then state = 3 end
			end) 
		end	
		
		sizer_se:SetScript("OnMouseDown", function()
			if sz.down then sizer_tx:SetTexture(sz.down) end
			state = 2
			local direction = nil
			if frame.sizable == 3 then direction = "BOTTOMRIGHT" end
			if frame.sizable == 1 then direction = "BOTTOM" end
			if frame.sizable == 2 then direction = "RIGHT" end
			if direction then frame:StartSizing(direction) end
		end)
		sizer_se:SetScript("OnMouseUp", function()
			frame:StopMovingOrSizing()
			if state == 2 then state = 1 end
			if state == 3 then state = 0 end
			if sz.over and state == 1 then sizer_tx:SetTexture(sz.over)
			else sizer_tx:SetTexture(sz.file) end
			frame:RenewPoints()
		end)
	end
	
	return frame
end

do -- mix functions
	function window:GetNumberNextType(t)
		local i, do_ = 1, true
		while do_ do
			local find = false
			do_ = false
			for _, j in next, self.windows do
				if j.count == i and j.type == t then find = true end
			end
			if find then do_ = true; i = i + 1 end
		end
		return i
	end

	function window:AddWindow(w)
		w.count = self:GetNumberNextType(w.type)
		
		function w:Destroy()
			for k, i in next, window.windows do
				if i == w then 
					if i.Hide then i:Hide() end
					table.remove(window.windows,k)
				end
			end
		end
		
		w.name = "Hagakure" .. w.type .. w.count
		
		table.insert(self.windows,w)
	end

	function window:GetNextTradeXY(i)
		local step = Hagakure.db.profile.bid_step
		local x = i*step
		local y = i*step
		return x,y
	end
end

function window:CreateTitle(parent)
	local titlebg = parent:CreateTexture(nil, "OVERLAY")
	local conf = Hagakure.frame_configurations.title_styles[Hagakure.db.profile.frame.title]
	titlebg:SetTexture(conf.bgFile) 
	titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
	titlebg:SetPoint("TOP", 0, 12)
	titlebg:SetWidth(100)

	local title = CreateFrame("Frame", nil, parent)
	title:EnableMouse(true)
	title:SetScript("OnMouseDown", function() parent:StartMoving() end)
	title:SetScript("OnMouseUp", function() parent:StopMovingOrSizing() end)
	title:SetAllPoints(titlebg)
	
	local titletext = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	titletext:SetPoint("TOP", titlebg, "TOP", 0, -14)
	titletext:SetFont(LSM:Fetch("font",fontconf.name),fontconf.small_size)

	-- Текстура с левой частью заголовка
	local titlebg_l = parent:CreateTexture(nil, "OVERLAY")
	titlebg_l:SetTexture(conf.leftFile) 
	titlebg_l:SetTexCoord(0.21, 0.31, 0, 0.63)
	titlebg_l:SetPoint("RIGHT", titlebg, "LEFT")
	titlebg_l:SetWidth(30)

	-- Текстура правой части заголовка
	local titlebg_r = parent:CreateTexture(nil, "OVERLAY")
	titlebg_r:SetTexture(conf.rightFile) 
	titlebg_r:SetTexCoord(0.67, 0.77, 0, 0.63)
	titlebg_r:SetPoint("LEFT", titlebg, "RIGHT")
	titlebg_r:SetWidth(30)
	
	local function setHeight()
		local h = 40
		h = (titletext:GetHeight()) + 30
		titlebg_l:SetHeight(h)
		titlebg_r:SetHeight(h)
		titlebg:SetHeight(h)
		titlebg:SetPoint("TOP", 0, h - 30)
	end
	setHeight()
	
	function titletext:SetTitle(text)
		titletext:SetText(text)
		titlebg:SetWidth((titletext:GetWidth() or 0) + 20)
		setHeight()
	end
	
	return titletext
end

function window:CreateButton(parent)
	parent = parent or UIParent
	local out = {}
	out.type = "Button"
	local name = "HagakureButton" .. self:GetNumberNextType(out.type)
	local frame = CreateFrame("Button", name, parent, "HagakureButtonTemplate")
	out.frame = frame

	local button = Hagakure.frame_configurations.button_styles[Hagakure.db.profile.frame.button]
	local textures = {
		normal = button.normal,
		highlight = button.highlight,
		pushed = button.pushed,
	}
	frame.textures=textures
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetBackdrop(nil)
	
	local text = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	text:SetFont(LSM:Fetch("font",fontconf.name),fontconf.small_size)
	text:ClearAllPoints()
	--text:SetPoint("TOPLEFT", 0,0) 
	--text:SetPoint("BOTTOMRIGHT", 0,0)
	text:SetPoint("CENTER")
	text:SetJustifyV("MIDDLE")
	text:SetJustifyH("CENTER")
	
	function out:SetText(t)
		text:SetText(t)
		frame:SetHeight(fontconf.small_size+15)
	end
	
	function out:SetTextures(normal,pushed,highlight)
		if normal then self.frame.textures.normal = normal end
		if pushed then self.frame.textures.pushed = pushed end
		if highlight then self.frame.textures.highlight = highlight end
	end
	
	function out:SetScripts(onClick, onEnter, onLeave)
		frame:SetScript("OnClick", onClick)
		frame:SetScript("OnEnter", onEnter)
		frame:SetScript("OnLeave", onLeave)
	end
	
	self:AddWindow(out)
	return out
end

function window:CreateCheckBox(parent)
	parent = parent or UIParent
	local out = {}
	out.type = "CheckBox"
	
	local frame = CreateFrame("Button", nil, parent)
	local checkbg = frame:CreateTexture(nil, "ARTWORK")
	local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	local check = frame:CreateTexture(nil, "OVERLAY")
	local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

	do -- configuration
		frame:EnableMouse(true)

		checkbg:SetWidth(24)
		checkbg:SetHeight(24)
		checkbg:SetPoint("TOPLEFT")
		checkbg:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
		checkbg:SetTexCoord(0, 1, 0, 1)

		check:SetAllPoints(checkbg)
		check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		check:SetTexCoord(0, 1, 0, 1)
		check:SetBlendMode("BLEND")

		text:SetJustifyH("LEFT")
		text:SetFont(LSM:Fetch("font",fontconf.name),fontconf.small_size)
		text:SetPoint("LEFT", checkbg, "RIGHT")

		highlight:SetTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
		highlight:SetBlendMode("ADD")
		highlight:SetAllPoints(checkbg)
		highlight:SetTexCoord(0, 1, 0, 1)
	end
	
	do -- additional functions
		function out:SetText(t)
			text:SetText(t)
			frame:SetWidth(checkbg:GetWidth()+text:GetWidth())
			frame:SetHeight(math.max(checkbg:GetHeight(),text:GetHeight()))
		end
		
		function out:SetValue(state)
			if state == nil then state = not out.state end
			out.state = state
			if state then check:Show()
			else check:Hide() end
		end
	end

	do -- cripts
		frame:SetScript("OnEnter", function() end)
		frame:SetScript("OnLeave", function() end)
		frame:SetScript("OnMouseDown", function()
			text:SetPoint("LEFT", checkbg, "RIGHT", 1, -1)
		end)
		frame:SetScript("OnMouseUp", function() 
			out:onMouseUp()
			text:SetPoint("LEFT", checkbg, "RIGHT")
		end)
	end
	
	out.onMouseUp = function() end
	out.frame = frame
	out:SetValue(false)
	self:AddWindow(out)
	return out
end

function window:CreateScroll(parent)
	local out = CreateFrame("Frame",nil,parent)
	parent:SetScrollChild(out)
	out:SetPoint("TOPLEFT")
	--out:SetPoint("TOPRIGHT")
	--out:SetWidth(parent:GetWidth())
	out:SetHeight(1)
	
	parent:EnableMouseWheel(true)
	local iii = {type = "slider"}
	self:AddWindow(iii)
	local slider = CreateFrame("Slider", iii.name, parent)
	slider:SetPoint("RIGHT")
	do -- slider
		iii.slider = slider
		slider.state = {}
		do -- slider creation
			slider:SetOrientation("VERTICAL")
			slider:SetPoint("TOPRIGHT")
			slider:SetPoint("BOTTOMRIGHT")
			slider:SetWidth(13)
			slider:SetHitRectInsets(0, 0, -10, 0)
			slider:SetBackdrop({
				bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
				edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
				tile = true, tileSize = 8, edgeSize = 8,
				insets = { left = 3, right = 3, top = 6, bottom = 6 }
			})
			slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
			slider:SetMinMaxValues(0,1000)
			slider:SetValueStep(1)
			slider:SetValue(0)
			slider:EnableMouse(true)
		end
	end
	
	out.status = false
	
	local function updateCont()
		local curr_ = parent:GetVerticalScroll()
		local max_ = parent:GetVerticalScrollRange()
		if max_ > 0 then 
			out:SetWidth(parent:GetWidth() - 15)
			out.status = true
			slider:Show()
			slider:SetValue(math.ceil(curr_/max_ * 1000))
			curr_ = math.min(curr_,max_)
		else
			out:SetWidth(parent:GetWidth())
			out.status = false
			slider:Hide()
			curr_ = 0
		end
		parent:SetVerticalScroll(curr_)
	end
	
	local function ScrollIt(value,method)
		if not out.status then return end
		local max_ = parent:GetVerticalScrollRange()
		local curr_ = parent:GetVerticalScroll()
		local next_ = 0
		if method then
			next_ = math.max(math.min(max_,curr_ + value),0)
		else
			next_ = max_ * value
		end
		slider:SetValue(math.ceil(curr_/max_ * 1000))
		parent:SetVerticalScroll(next_)
		-- self:debugf("%s %s %s %s",max_,curr_,next_,parent:GetVerticalScroll())
	end
	
	parent:SetScript("OnMouseWheel", function(_,value)
		if not out.status then return end
		local delta = 1
		if value > 0 then delta = -1 end
		ScrollIt(delta * fontconf.small_size,true)
	end) -- -1 вниз 1 - вверх
	
	slider:SetScript("OnValueChanged", function(_,val)
		ScrollIt(val / 1000)
	end)
	parent:SetScript("OnSizeChanged", updateCont)
	out:SetScript("OnSizeChanged", updateCont)
	
	return out
end

function window:CreateContainer(content)--parent)
	local out = {}

--[[	
	local frame = CreateFrame("ScrollFrame",nil,parent)
	local content = self:CreateScroll(frame)
	frame:SetPoint("TOPLEFT",10,-12)
	frame:SetPoint("BOTTOMRIGHT",-10,12)
--]]
	out.content = content
	
	do -- create out.item
		local label = content:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
		label:SetJustifyH("LEFT")
		label:SetJustifyV("TOP")
		label:SetFont(LSM:Fetch("font",fontconf.name),fontconf.big_size)
		label:SetPoint("TOPLEFT")
		--label:SetPoint("TOPRIGHT")
		label:SetWidth(content:GetWidth())
		labelF = CreateFrame("Frame",nil,content)
		labelF:SetAllPoints(label)
		labelF:EnableMouse(true)
		local function getItem()
			local txt = label:GetText()
			--[[
			local tmp = string.match(txt,"item\:%d+\:")
			if tmp then tmp = string.match(tmp,"%d+")end
			if not tmp then return end
			local link = select(2,GetItemInfo(tmp))
			return link
			--]]
			local tmp = Hagakure:ItemString(txt)
			local item = string.format("%s.%s",tmp.itemId,tmp.uniqueID)
			if item ~= "0.0" then return Hagakure:GetItemLink(item) end
		end
		labelF:SetScript("OnMouseUp", function() if getItem() then SetItemRef(getItem(),getItem()) end end)
		labelF:SetScript("OnEnter", function() if getItem() then
			GameTooltip:SetOwner (labelF, "ANCHOR_LEFT", -20, 0)
			GameTooltip:SetHyperlink (getItem())
		end end)
		labelF:SetScript("OnLeave", function() GameTooltip:Hide() end)
		out.item = label
	end
	
	do -- create out.slider
		local iii = {type = "slider"}
		self:AddWindow(iii)
		local slider = CreateFrame("Slider", iii.name, content)
		iii.slider = slider
		slider.state = {}
		do -- slider creation
			slider:SetOrientation("HORIZONTAL")
			--slider:SetWidth(content:GetWidth())
			slider:SetHeight(15)
			slider:SetPoint("TOPLEFT",out.item,"BOTTOMLEFT")
			slider:SetPoint("RIGHT")
			slider:SetHitRectInsets(0, 0, -10, 0)
			slider:SetBackdrop({
				bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
				edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
				tile = true, tileSize = 8, edgeSize = 8,
				insets = { left = 3, right = 3, top = 6, bottom = 6 }
			})
			slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
			slider:EnableMouseWheel(true)
			slider:EnableMouse(true)
		end
		
		local lowtext = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		local hightext = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		local s = {}
		s.type = "EditBox"
		self:AddWindow(s)
		local editbox = CreateFrame("EditBox", s.name, content)
		s.editbox = editbox
		do -- creating additional fields for slider
			lowtext:SetFont(LSM:Fetch("font",fontconf.name),fontconf.small_size)
			hightext:SetFont(LSM:Fetch("font",fontconf.name),fontconf.small_size)
			lowtext:SetText("B")

			editbox:SetAutoFocus(false)
			editbox:SetFont(LSM:Fetch("font",fontconf.name),fontconf.small_size)
			
			editbox:SetPoint("TOP", slider, "BOTTOM",0,0)
			lowtext:SetPoint("RIGHT", editbox, "LEFT", -3, 0)
			hightext:SetPoint("LEFT", editbox, "RIGHT", 5, 0)
			
			editbox:SetHeight(lowtext:GetHeight()+2)
			editbox:SetWidth(70)
			editbox:SetJustifyH("CENTER")
			editbox:EnableMouse(true)
			editbox:SetBackdrop({
				bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
				edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
				tile = true, edgeSize = 1, tileSize = 5,
			})
			editbox:SetBackdropColor(0, 0, 0, 0.5)
			editbox:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
			editbox:SetScript("OnEnter", function() editbox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) end)
			editbox:SetScript("OnLeave", function() editbox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8) end)
			function editbox:onEnter()
				editbox:ClearFocus() 
				local v = tonumber(editbox:GetText()) or 1
				v = math.min(math.max(v,slider.state.min_value),slider.state.max_value)
				slider:SetSliderValue(v)
			end
			editbox:SetScript("OnEnterPressed", function() editbox:onEnter() end)
			editbox:SetScript("OnEscapePressed", function() 
				editbox:ClearFocus() 
				editbox:SetText(tostring(slider.state.value))
			end)
			slider.anchor = editbox
		end
		
		do -- scripts
			slider:SetScript("OnValueChanged", function() slider:SetSliderValue(slider:GetValue()) end)
			slider:SetScript("OnEnter", function() end)
			slider:SetScript("OnLeave", function() end)
			slider:SetScript("OnMouseUp", function() end)
			slider:SetScript("OnMouseWheel", function(_,v) 
				local value
				if v > 0 then
					value = math.min(slider.state.max_value,slider.state.value + slider.state.step)
				else
					value = math.max(slider.state.min_value,slider.state.value - slider.state.step)
				end
				slider:SetSliderValue(value)
			end)
		end
		
		do -- additional functions
			function slider:SetAll(min_value, max_value, step)
				self.state.min_value = min_value or 1
				self.state.true_min_value = self.state.true_min_value or min_value
				self.state.max_value = max_value or 1000
				self.state.step = step or 1
				self:SetMinMaxValues(self.state.min_value,self.state.max_value)
				self:SetValueStep(self.state.step)
				self:SetSliderValue(self.state.value)
				hightext:SetText("- " .. tostring(self.state.max_value))
				lowtext:SetText(tostring(self.state.min_value) .. " -")
			end
			
			function slider:SetSliderValue(value)
				value = value or self.state.min_value
				local prev,res,last = self.state.min_value,nil,nil
				for i = self.state.min_value, self.state.max_value, self.state.step do
					if i == value then res = i end
					if i < value then prev = i end
					if i > value and not last then last = i end
				end
				if res == nil then
					if last == nil then res = self.state.max_value
					else res = prev	end
				end
				self.state.value = res
				self:SetValue(res)
				editbox:SetText(res)
			end
		end
		
		slider:SetAll()
		out.slider = slider
	end
	
	do -- create 4 checkboxes for specs
		local chframe = CreateFrame("Frame",nil,content) -- frame for 4 checkboxes
		chframe:SetPoint("LEFT")
		chframe:SetPoint("RIGHT")
		chframe:SetPoint("TOP",out.slider.anchor,"BOTTOM",0,-5)
		chframe:SetHeight(30)
		
		local spec = 0
		function out:GetSpec()
			return spec
		end 
		
		local pass = self:CreateCheckBox(chframe)
		pass.frame:SetPoint("TOPLEFT")
		pass.onMouseUp = function() out:SetSpec(0) end
		local greed = self:CreateCheckBox(chframe)
		greed.frame:SetPoint("TOPLEFT",pass.frame,"TOPRIGHT")
		greed.onMouseUp = function() out:SetSpec(1) end
		local off = self:CreateCheckBox(chframe)
		off.frame:SetPoint("TOPLEFT",greed.frame,"TOPRIGHT")
		off.onMouseUp = function() out:SetSpec(2) end
		local main = self:CreateCheckBox(chframe)
		main.frame:SetPoint("TOPLEFT",off.frame,"TOPRIGHT")
		main.onMouseUp = function() out:SetSpec(3) end
		
		function out:SetLabels(p,g,o,m)
			p = p or "pass"
			g = g or "greed"
			o = o or "off"
			m = m or "main"
			pass:SetText(p)
			greed:SetText(g)
			off:SetText(o)
			main:SetText(m)
			chframe:SetWidth(pass.frame:GetWidth()+greed.frame:GetWidth()+off.frame:GetWidth()+main.frame:GetWidth())
			chframe:SetHeight(math.max(pass.frame:GetHeight(),greed.frame:GetHeight(),off.frame:GetHeight(),main.frame:GetHeight()))
		end

		function out:SetSpec(s,first)
			pass:SetValue(false)
			off:SetValue(false)
			greed:SetValue(false)
			main:SetValue(false)
			local min_v = 1
			if self.slider.state.true_min_value then min_v = math.ceil(self.slider.state.true_min_value/2) end
			if s == 0 then pass:SetValue(true) end
			if s == 1 then greed:SetValue(true) end
			if s == 2 then off:SetValue(true) end
			if s == 3 then main:SetValue(true); min_v = self.slider.state.true_min_value end
			if not first then self.slider:SetAll(min_v,self.slider.state.max_value,self.slider.state.step) end
			spec = s
		end
		
		out:SetLabels()
		out:SetSpec(0,true)
		out.spec = chframe
	end
	
	do -- create button for announce
		local button = self:CreateButton(content)
		button.frame:SetPoint("TOP",out.spec,"BOTTOM")
		button.frame:Show()
		button.frame:SetSize(200,30)
		button:SetText(L["Announce bid"])
		out.button = button
	end
	
	do -- create label for dkp info 
		local label = content:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
		label:SetJustifyH("LEFT")
		label:SetJustifyV("TOP")
		label:SetFont(LSM:Fetch("font",fontconf.name),fontconf.small_size)
		label:SetPoint("TOP",out.button.frame,"BOTTOM",0,-5)
		label:SetPoint("LEFT")
		label:SetWidth(content:GetWidth())
		out.list = label
	end
	
	return out
end

function window:CreateFrameWithTitle(frameType)
	local out = {}
	out.type = frameType or "SimpleFrame"
	self:AddWindow(out)
	local conf = Hagakure.db.profile
	
	do -- create out.frame
		out.frame = self:CreateFrame()
		out.frame:SetWidth(conf.bid_w)
		out.frame:SetHeight(conf.bid_h)
		local x, y = self:GetNextTradeXY(out.count)
		out.frame:SetPoint(conf.bid_anc, conf.bid_hor + x, conf.bid_vert - y)
		out.frame.sizable = 1
	end
	
	out.title = self:CreateTitle(out.frame)
	
	local frame = CreateFrame("ScrollFrame",nil,out.frame)
	local content = self:CreateScroll(frame)
	out.content = content
	frame:SetPoint("TOPLEFT",10,-25)
	frame:SetPoint("BOTTOMRIGHT",-10,12)
	
	do -- create close button
		out.close = self:CreateButton(out.frame)
		local close = Hagakure.db.profile.frame.close
		local cf = Hagakure.frame_configurations.close_styles[close.type]
		out.close.frame:SetPoint(close.pos, close.x, close.y)
		out.close.frame:SetHeight(cf.height)
		out.close.frame:SetWidth(cf.width)
		if cf.text then
			out.close:SetText(cf.text)
		end
		out.close:SetTextures(cf.normal,cf.pushed,cf.highLight)
		out.close.frame:Show()
		out.close:SetScripts(function() out:Close() end)
	end
	
	do -- additional functions
		out.CloseFunction = function() end
		
		function out:SetTitle(l)
			self.title:SetTitle(l)
		end
		
		function out:Hide()
			self.frame:Hide()
		end
		
		function out:Show()
			self.frame:Show()
		end
		
		function out:Close()
			self:Hide()
			self:CloseFunction()
		end
	end

	return out
end

function window:CreateChat(parent) -- создает в чате контейнер с прокруткой для сообщений и едитбокс
	local out = {}
	out.type = "Chat"
	self:AddWindow(out)
	
	local s = {}
	s.type = "EditBox"
	self:AddWindow(s)
	local editbox = CreateFrame("EditBox", s.name, parent) 
	s.editbox = editbox
	do -- editbox
		editbox:SetAutoFocus(false)
		editbox:SetFont(LSM:Fetch("font",fontconf.name),fontconf.small_size)
		
		editbox:SetPoint("TOPLEFT", 8, -8)
		editbox:SetPoint("RIGHT",-10,0)
		
		editbox:SetHeight(fontconf.small_size + 3)
		editbox:SetJustifyH("LEFT")
		editbox:EnableMouse(true)
		editbox:SetBackdrop({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
			tile = true, edgeSize = 1, tileSize = 5,
		})
		editbox:SetBackdropColor(0, 0, 0, 0.5)
		editbox:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
		editbox:SetScript("OnEnter", function() editbox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) end)
		editbox:SetScript("OnLeave", function() editbox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8) end)
		editbox:SetScript("OnEnterPressed", function() editbox:onEnter() end)
		editbox:SetScript("OnEscapePressed", function() 
			editbox:ClearFocus() 
		end)
		
		editbox.OnEnter = function() end
	end

	local frame = CreateFrame("ScrollFrame", nil, parent)
	local content = self:CreateScroll(frame)
	frame:SetPoint("TOPLEFT",editbox,"BOTTOMLEFT",0, -5)
	frame:SetPoint("BOTTOMRIGHT",-10,12)

	local label = content:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	do -- create label for chat messages
		label:SetJustifyH("LEFT")
		label:SetJustifyV("TOP")
		label:SetFont(LSM:Fetch("font",fontconf.name),fontconf.small_size)
		label:SetPoint("TOPLEFT")
		--label:SetPoint("RIGHT")
		label:SetWidth(content:GetWidth())
	end

	function out:SetText(t)
		label:SetText(t)
		content:SetHeight(label:GetHeight())
		label:SetWidth(content:GetWidth())
	end
	
	out.label = label
	out.msg = editbox
	
	return out
end

function window:CreateTradeWindow(link)
	local out = self:CreateFrameWithTitle("Trade")
	out.link = link or ""
	local conf = Hagakure.db.profile
	
	out.cont = self:CreateContainer(out.content)
	
	do -- create chat window
		out.chat = self:CreateFrame()
		out.chat:SetHeight(conf.chat.height)
		out.chat:SavePoint("TOP",out.frame,"BOTTOM")
		out.chat:SavePoint("LEFT",out.frame,"LEFT")
		out.chat:SavePoint("RIGHT",out.frame,"RIGHT")
		out.chat.sizable = 1
		out.chat:Hide()
		out.chat.state = false
		
		out.msgB = self:CreateButton(out.frame)
		local butt = Hagakure.db.profile.chat.butt
		out.msgB.frame:SetPoint(butt.point, butt.x, butt.y)
		out.msgB.frame:SetHeight(butt.height)
		out.msgB.frame:SetWidth(butt.width)
		out.msgB:SetText("chat")
		out.msgB.frame:Show()
		out.msgB:SetScripts(function() if out.chat.state then out.chat:Hide() else out.chat:Show() end; out.chat.state = not out.chat.state end)

		out.msg = self:CreateChat(out.chat)
	end
	
	do -- additional functions
		function out:SetLink(l)
			self.link = l or self.link
			self.title:SetTitle(l)
			self.cont.item:SetText(string.format("%s %d-%d",self.link,self.cont.slider.state.min_value,self.cont.slider.state.max_value))
		end
		
		function out:SetDKPInfo(text)
			self.cont.list:SetText(text)
			local h = self.cont.list:GetHeight() + (self.cont.content:GetTop() - self.cont.list:GetTop())
			self.cont.content:SetHeight(h)
		end
		
		function out:SetSliderValues(minv, maxv, step)
			self.cont.slider:SetAll(minv,maxv,step) 
			self.cont.item:SetText(string.format("%s %d-%d",self.link,self.cont.slider.state.min_value,self.cont.slider.state.max_value))
		end
		
		function out:SetScripts(onClick,onEnter,onLeave)
			self.cont.button:SetScripts(function()
				self.cont.slider.anchor:onEnter()
				onClick()
			end,onEnter,onLeave)
		end
		
		function out:GetSpecBid()
			return self.cont:GetSpec(), self.cont.slider.state.value
		end
	
		function out:Hide()
			self.frame:Hide()
			self.chat:Hide()
		end
	
		local messages = {}
		function out:AddChatMSG(sender,msg)
			if msg == "" or msg == nil or sender == nil or sender == "" then return end
			table.insert(messages,{
				sender = sender,
				msg    = msg,
			})
			local out,first = "", true
			for k = # messages, 1, -1 do
				local i = messages[k]
				local tmp = "\n"
				if first then first = false; tmp = "" end
				out = string.format(L["%s%s|c<color code>%s:|r %s"],out,tmp,i.sender,i.msg)
			end
			self.msg:SetText(out)
			self.msgB:SetText("|cffff0000Read!|r")
		end

		function out:SetOnChatSend(func)
			out.msg.msg.onEnter = func
		end
		
		function out:GetActiveMSG()
			local txt = out.msg.msg:GetText()
			out.msg.msg:SetText("")
			return txt
		end
	end

	out:SetLink(out.link)
	return out
end





















