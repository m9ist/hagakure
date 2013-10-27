--[[-----------------------------------------------------------------------------
Heading Widget
-------------------------------------------------------------------------------]]
local Type, Version = "HTable", 20
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

local function GetPozSize(inp,i,j)
	local poz, size = {x=0,y=0}, {}
	local v_=nil
	for k,v in pairs(inp.table_) do if v.pos.i==i and v.pos.j==j then v_=v end end -- ищем нашу €чейку
	--[[
	for k=1,i-1 do
		for v=1,j-1 do
			local w,h=inp:GetCellSize(k,v)
			poz.x=inp.space.x+w+poz.x
			poz.y=inp.space.y+h+poz.y
		end
	end
	]]
	for k=1,i-1 do
		local w,h=inp:GetCellSize(k,j)
		poz.x=inp.space.x+w+poz.x
	end
	for k=1,j-1 do
		local w,h=inp:GetCellSize(i,k)
		poz.y=-inp.space.y-h+poz.y
	end
	size=v_.size
	--Hagakure:Print("GetPozSize i="..i.." j="..j.." poz="..poz.x.." "..poz.y.." size="..size.width.." "..size.height)
	return poz,size
end

local function buttOnEnter(inp,i,j)
	--Hagakure:Print("Enter "..i.." "..j)
	local v_=nil
	for s,v in pairs(inp.table_) do
		for k=1, inp.columns do
			if v.pos.i==k and v.pos.j==j then v.label:LockHighlight() end
		end
		--if v.pos.j==1 and v.pos.i==i then v.label:LockHighlight() end
		if v.pos.i==i and v.pos.j==j then v_=v end
	end
	if v_ then
		GameTooltip:SetOwner (v_.label, "ANCHOR_BOTTOM", 0, -30)
		if v_.tooltip.type=="HyperLink" then
			GameTooltip:SetHyperlink(v_.tooltip.value)
		elseif v_.tooltip.type=="Text" then 
			--Hagakure:Print(v_.tooltip.value) 
			GameTooltip:AddLine(v_.tooltip.value)
			GameTooltip:Show()
		end
	end
end

local function buttOnLeave(inp,i,j)
	--Hagakure:Print("Leave "..i.." "..j)
	for s,v in pairs(inp.table_) do
		for k=1, inp.columns do
			if v.pos.i==k and v.pos.j==j then v.label:UnlockHighlight() end
		end
		--if v.pos.j==1 and v.pos.i==i then v.label:UnlockHighlight() end
	end
	GameTooltip:Hide()
end

local function makeLabel(inp,i,j,size)
	--Hagakure:Print("Making "..i.." "..j)
	--[[
	local pos={
		x=(i-1)*inp.def_size.width,
		y=(1-j)*inp.def_size.height,
	}
	]]
	local pos={x=0,y=0,}
	
	if i>1 then
		local poz,size=GetPozSize(inp, i-1,j)
		pos.x=poz.x+size.width+inp.space.x
	end
	if j>1 then
		local poz,size=GetPozSize(inp, i,j-1)
		pos.y=poz.y+size.height+inp.space.y
	end
	
	local butt = CreateFrame("Button", nil, inp.frame, "UIPanelButtonTemplate")
	--closebutton:SetScript("OnClick", Button_OnClick)
	--Hagakure:Print("Making "..i.." "..j.." poz.x="..pos.x.." poz.y-"..pos.y.." w="..size.w.." h="..size.h)
	butt:SetPoint("TOPLEFT", pos.x, pos.y)
	butt:SetHeight(size.h)
	butt:RegisterForClicks("LeftButtonUp","RightButtonUp")
	butt:SetWidth(size.w)
	butt:SetText("")
	local text = butt:GetFontString(nil)
	text:ClearAllPoints()
	text:SetPoint("TOPLEFT", 3,0) 
	text:SetPoint("BOTTOMRIGHT", 0,0)
	text:SetJustifyV("MIDDLE")
	text:SetJustifyH("LEFT")
	butt:SetNormalTexture("Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Up") -- Sets the texture used for the button's normal state
	butt:SetPushedTexture("Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Down") --Sets the texture used when the button is pushed
	butt:SetDisabledTexture("Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Disabled") --Sets the texture used when the button is disabled
	butt:SetHighlightTexture("Interface\\AddOns\\hagakure\\second\\UI-QuestLogTitleHighlight") --Sets the texture used when the button is highlighted
	--butt:SetBackdrop(backdrop)
	butt:SetScript("OnEnter",function(self) buttOnEnter(inp,i,j) end)
	butt:SetScript("OnLeave",function(self) buttOnLeave(inp,i,j) end)
	
	return butt
end

local function updateLabel(inp,label,poz,size,pos)
	--Hagakure:Print("enter update labe with "..poz.x.." "..poz.y)
	label:SetPoint("TOPLEFT", poz.x, poz.y)
	label:SetScript("OnEnter",function(self) buttOnEnter(inp,pos.i,pos.j) end)
	label:SetScript("OnLeave",function(self) buttOnLeave(inp,pos.i,pos.j) end)
	label:SetHeight(size.height)
	label:SetWidth(size.width)
end

local function checkFrame(inp) -- пр€чет/показывает "лишние записи"
	-- ≈сли poz+size>size of frame, то мы пр€чем данную кнопенцию
	for k,v in pairs(inp.table_) do 
		local poz,size=GetPozSize(inp,v.pos.i, v.pos.j)
		if (poz.x+size.width>inp.frame:GetWidth()) or (size.height-poz.y>inp.frame:GetHeight()) then 
			v.label:Hide() 
			--Hagakure:Print("Hiding poz={"..poz.x..":"..poz.y.."} size={"..size.width..","..size.height.."} frame size="..inp.frame:GetWidth()..":"..inp.frame:GetHeight())
		end
		if (poz.x+size.width<inp.frame:GetWidth()) and (size.height-poz.y<inp.frame:GetHeight()) then v.label:Show() end
	end
end

local function frameUpdate(inp)
	for k,v in pairs(inp.table_) do
		local poz,size=GetPozSize(inp,v.pos.i,v.pos.j)
		updateLabel(inp,v.label,poz,size,v.pos)
	end
	checkFrame(inp)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
	end,
	
	["DeleteRow"] = function (self,row)
		--Hagakure:Print("DELETE?")
		-- «апускаем цикл присваивани€ значений следующей строчки этой
		for j=row+1,self.rows do
			for i=1,self.columns do
				-- теперь дл€ каждой (i,j-1) и (i,j) ищем их id в table_
				local id1,id2=-1,-1
				for id, temp in pairs(self.table_) do
					if temp.pos.i==i and temp.pos.j==j then id2=id end
					if temp.pos.i==i and temp.pos.j==j-1 then id1=id end
					if j==row+1 then temp.label:Hide() end
				end
				-- ј теперь присваиваем (i,j-1) значение (i,j)
				if id1>-1 and id2>-1 then
					--Hagakure:Print("id1 "..id1.." id2 "..id2.." "..self.table_[id1].pos.i.." "..self.table_[id1].pos.j.." "..self.table_[id2].pos.i.." "..self.table_[id2].pos.j)
					--Hagakure:Print("before id1 with j="..self.table_[id1].pos.j.." and id2 with j="..self.table_[id2].pos.j)
					to_del=self.table_[id1]
					self.table_[id1]=self.table_[id2]
					self.table_[id2]=to_del
					self.table_[id1].pos.j=j-1
					self.table_[id2].pos.j=j
					--Hagakure:Print("__now id1 with j="..self.table_[id1].pos.j.." and id2 with j="..self.table_[id2].pos.j)
				end
			end
		end
		-- Ќу и не забываем уменьшить размер на 1 ^^
		self:SetSize(self.columns,self.rows-1)
	end,
	
	["DeleteColumn"] = function (self,column)
	end,

	["SetScript"] = function (self,i,j,func)
		for _,v in pairs(self.table_) do
			if v.pos.i==i and v.pos.j==j then
				v.label:SetScript("OnClick",function (self,button) func(i,j,button) end)
			end
		end
	end,
	
	["SetMaxSize"] = function (self, max_height, max_width) -- устанавливает максимальную ширину/высоту фрейма
		local cols,rows=self:GetSize()
		if cols==0 or rows==0 then return false end
		local poz,size=GetPozSize(self,self.columns, self.rows)
		--Hagakure:Print(poz.x+size.width.." "..size.height-poz.y)
		if max_height==true then self:SetFrameSize(self.width+self.space.x,size.height-poz.y+self.space.y) end
		if max_width==true then self:SetFrameSize(poz.x+size.width+self.space.x,self.height+self.space.y) end
		checkFrame(self)
	end,
	
	["SetSize"] = function (self, columns, rows)
		if rows<0 or columns<0 then return false end
		if self.rows~=rows or self.columns~=columns then
			-- Ўаг первый, если строчка или столбец пусты, то таблицу нафиг обнул€ем
			if rows==0 or columns==0 then 
				-- ƒл€ начала скрыть!
				for _,j in pairs(self.table_) do j.label:Hide() end
				self.table_={}
				self.rows=0
				self.columns=0
			else
				-- Ўаг второй - обрезаем лишние €чейки
				for i,j in pairs(self.table_) do -- прогон€ем цикл и удал€ем все те значени€, которые обрезаютс€
					--Hagakure:Print("("..j.pos.j..">"..rows.."<"..self.rows..") or ("..j.pos.i..">"..columns.."<"..self.columns..")")
					if (rows<self.rows and j.pos.j>rows) or (columns<self.columns and j.pos.i>columns) then
						self.table_[i].label:Hide()
						self.table_[i].label=nil
						self.table_[i]=nil
						--Hagakure:Print(j.pos.i.." "..j.pos.j.."  DELETE") 
					end
				end
				if rows<self.rows then self.rows=rows end
				if columns<self.columns then self.columns=columns end			
				
				-- шаг третий - осталось добавить €чейки
				if columns>self.columns then -- если не хватает колонок, то дл€ всех текущих строк добавл€ем колонки
					for j=1, self.rows do
						for i=self.columns+1, columns do
							local h=self.def_size.height
							if (i-1)>0 then 
								_,h=self:GetCellSize(i-1,j)
							end
							table.insert(self.table_,{
								value="",
								toolrip={},
								pos={
									i=i,
									j=j,
								},
								size={
									width=self.def_size.width,
									height=h,
								},
								tooltip={
									type="",
									value="",
								},
								label=makeLabel(self,i,j,{w=self.def_size.width,h=h,}),
							})
						end
					end
					self.columns=columns
				end
				
				-- шаг четвертый - добавл€ем строки ко всем столбцам
				if rows>self.rows then
					for i=1, self.columns do
						for j=self.rows+1, rows do
							local w=self.def_size.width
							if (j-1)>0 then 
								w,_=self:GetCellSize(i,j-1)
							end
							table.insert(self.table_,{
								value="",
								toolrip={},
								pos={
									i=i,
									j=j,
								},
								size={
									width=w,
									height=self.def_size.height,
								},
								tooltip={
									type="",
									value="",
								},
								label=makeLabel(self,i,j,{w=w,h=self.def_size.height,}),
							})
						end
					end
					self.rows=rows
				end
			end
		end
		--Hagakure:Print("col+row="..self.columns.." "..self.rows)
		frameUpdate(self)
	end,
	
	["SetValue"] = function (self, i,j,value)
		if i and j and value then
			for k,v in pairs(self.table_) do
				if v.pos.i==i and v.pos.j==j then 
					v.value=value 
					v.label:SetText(value)
				end
			end
		end
	end,
	
	["GetValue"] = function (self, i, j)
		if i and j then
			for k,v in pairs(self.table_) do
				if v.pos.i==i and v.pos.j==j then return v.value end
			end
		end
		return nil
	end,
	
	["GetSize"] = function (self)
		return self.columns,self.rows
	end,
	
	["GetCellSize"] = function (self,i,j)
		for _,v in pairs(self.table_) do if v.pos.i==i and v.pos.j==j then return v.size.width, v.size.height end end
		return 0,0 -- width height of cell
	end,
	
	["SetFrameSize"] = function (self, width, height)
		self.frame:SetWidth(width)
		self.width=width
		self.frame:SetHeight(height)
		self.height=height
		checkFrame(self)
	end,
	
	["SetDefaultSize"] = function (self,width, height)
		self.def_size.width=width
		self.def_size.height=height
	end,
	
	["SetCellSize"] = function (self,i,j,width,height) -- устанавливает ширину/высоту €чейки
		if not j then j=0 end
		if not j then i=0 end
		if not width then width=self.def_size.width end
		if not height then height=self.def_size.height end
		for k,v in pairs(self.table_) do
			if v.pos.i==i then v.size.width=width end
			if v.pos.j==j then v.size.height=height end
		end
		frameUpdate(self)
	end,
	
	["SetToolTip"] = function (self,i,j,t_,v_)
		local out=nil
		for k,v in pairs(self.table_) do if v.pos.i==i and v.pos.j==j then out=v end end
		if t_=="HyperLink" and v_ then out.tooltip={
				type="HyperLink",
				value=v_,
			}
			--Hagakure:Print("Done...")
		elseif t_=="Text" and v_ then out.tooltip={
				type="Text",
				value=v_,
			}
		end
	end,
	
	["GetToolTip"] = function (self,i,j)
		local out=nil
		for _,v in pairs(self.table_) do if v.pos.i==i and v.pos.j==j then out=v end end
		return v.tooltip
	end,
	
	["Disable"] = function (self,i,j)
		for _,v in pairs(self.table_) do if v.pos.i==i and v.pos.j==j then if v.label:IsEnabled() then v.label:Disable() else v.label:Enable() end end end
	end,
	
	["IsDisabled"] = function (self,i,j)
		for _,v in pairs(self.table_) do if v.pos.i==i and v.pos.j==j then return v.label:IsEnabled() end end
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]


local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	
	local table_={}
	--[[‘ормат таблицы table_
		[i]={ -- добавл€ем через table.insert()
			value = ""
			tooltip = {
				type = "HyperLink" -- type of tooltip
				value = link/"text"
			}
			pos = {
				i= 0 - column 
				j= 0 - row
			}
			size = {
				width = 0
				height = 0
			}
			label -- то что пойдет непосредственно на экран
		}
	]]--
	local rows=0
	local columns=0
	local width=200
	local height=200
	local space={
		x=1,
		y=1,
	}
	local def_size={
		width=100,
		height=20,
	}
	
	frame:SetWidth(width)
	frame:SetHeight(height)
	
	local widget = {
		space   = space,
		def_size= def_size,
		width   = width,
		height  = height,
		columns = columns,
		rows    = rows,
		table_  = table_,
		frame   = frame,
		type    = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
