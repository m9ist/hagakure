--[[-----------------------------------------------------------------------------
Heading Widget
-------------------------------------------------------------------------------]]
local Type, Version = "CTable", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

local cell, tc = {}, {}
cell.data = {}
tc.data = {}

local function printF(...)
	Hagakure:Printf(...)
end

local def = {
	table = {
		width = 400,
		height = 100,
		rows = 2,
		columns = 4,
	},
	cell = {
		width = 100,
		height = 50,
	},
}

function cell.new(i,j,parent)
	frame = parent.parent or UIParent
	local out = {}
	setmetatable(out,cell.data)
	
	out.column = i
	out.row = j
	out.parent = parent
	out.width = 0
	out.height = 0
	out.enable = true
	out.value = ""
	out.mouse = "out"
	out.down = false
	out.tooltip = {
		type = "nil", -- HyperLink
		value = "", -- text
	}
	
	do -- function section
		do -- changing size
			function out:SetWidth(width)
				self.width = width or self.width
				self.frame:SetWidth(self.width)
			end
			
			function out:SetHeight(height)
				self.height = height or self.height
				self.frame:SetHeight(self.height)
			end
			
			function out:SetSize(width, height)
				self:SetWidth(width)
				self:SetHeight(height)
			end
			
			function out:GetHeight()	
				return self.height
			end
			
			function out:GetWidth()
				return self.width
			end
			
			function out:GetSize()
				return self.width, self.height
			end
			
			function out:SetPoint(a1,method)
				if getmetatable(a1) == getmetatable(self) then
					if method == nil or method == 1 then self.frame:SetPoint("TOPLEFT",a1.frame,"TOPRIGHT") end
					if method == 2 then self.frame:SetPoint("TOPLEFT",a1.frame,"BOTTOMLEFT") end
					return
				end
				if a1 == nil then self.frame:SetPoint("TOPLEFT") end
			end
			
			function out:Hide()
				self.frame:Hide()
			end
			
			function out:Show()
				self.frame:Show()
			end
			
			function out:GetCoord()
				return self.column, self.row
			end
		end
		do -- some mix
			function out:Enable(state)
				if state ~= nil then self.enable = state else self.enable = true end
				
				self:CheckTexture()
			end
			
			function out:SetToolTip(t_, val)
				self.tooltip.type = t_
				self.tooltip.value = val
			end
			
			function out:IsEnable()
				return self.enable
			end
			
			function out:SetValue(val)
				self.value = val or ""
				self.text:SetText(val)
			end
			
			function out:GetValue()
				--Hagakure:Print(self.value)
				return self.value
			end
			
			function out:SetScript(i, j, func)
				self.frame:SetScript("OnMouseUp", function (_,button) 
					out:OnClick(button)
					if self.mouse == "out" then return end
					func(i,j,button) 
				end)
			end
		end
	end
	
	do -- GUI section
		local f = CreateFrame("Frame",nil,frame)
		out.frame = f
		out:SetSize(out.parent.state.defw,out.parent.state.defh)
		
		local highlight_img = f:CreateTexture(nil,"ARTWORK")
		highlight_img:SetPoint("TOPLEFT",f,0,2)
		highlight_img:SetPoint("BOTTOMRIGHT",f,0,6)
		highlight_img:Hide()
		highlight_img:SetTexture("Interface\\AddOns\\hagakure\\second\\UI-QuestLogTitleHighlight")
		--highlight_img:SetDrawLayer("HIGHLIGHT", 7)
		highlight_img:SetAlpha(0.7)
		
		local img = f:CreateTexture(nil,"BACKGROUND")
		img:SetAllPoints()
		function out:changeState(push, in_, parent)
			if push == "up" then self.down = false elseif push == "down" then self.down = true end
			self.mouse = in_ or self.mouse
			if not self.enable then
				img:SetTexture( "Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Disabled" )
			else
				if self.down and self.mouse == "in" then
					img:SetTexture( "Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Down" )
				else
					img:SetTexture( "Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Up" )
				end
				
				if self.mouse == "in" and parent then
					highlight_img:Show()
				else highlight_img:Hide() end
			end
			--Hagakure:Print(parent,self.mouse)
			if self.parent and not parent then self.parent:HighLight(self.row,self.mouse) end
			-- Hagakure:Print(push,in_)
		end
		function out:CheckTexture()
			self:changeState()--"up","out")
		end
		out:changeState(nil,nil,true)
		
		function out:OnClick(button)
			self:changeState("up",self.mouse)
		end
		f:SetScript("OnMouseUp", function()
			out:changeState("up",out.mouse)
		end)
		f:SetScript("OnMouseDown", function()
			out:changeState("down",out.mouse)
		end)
		
		f:SetScript("OnEnter", function()
			GameTooltip:SetOwner(f, "ANCHOR_BOTTOM", 0, -30)
			--Hagakure:Print(out.tooltip.type)
			if out.tooltip.type=="HyperLink" then
				--Hagakure:Print("link")
				GameTooltip:SetHyperlink(out.tooltip.value)
			elseif out.tooltip.type=="Text" then 
				--Hagakure:Print(v_.tooltip.value) 
				GameTooltip:AddLine(out.tooltip.value)
			end
			GameTooltip:Show()
			out:changeState(nil,"in")
		end)
		f:SetScript("OnLeave", function() 
			GameTooltip:Hide() 
			out:changeState(nil,"out")
		end)
		
		local text = f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
		out.text = text
		text:SetText("")--"PRIVEEE" .. i .. j)
		text:SetJustifyH("LEFT")
		text:SetJustifyV("TOP")
		--text:SetAllPoints()
		text:SetPoint("TOPLEFT",f,5,-2)
		text:SetPoint("BOTTOMRIGHT",f,0,0)
	end
	
	return out
end

function tc.new(parent)  -- [i][j] i - колонка j - строчка
	local out = {}
	setmetatable(out,tc.data)
	out.data = {}
	out.cont = {}
	out.state = {
		rows = 0,
		columns = 0,
		defw = 0,
		defh = 0,
	}
	out.parent = parent
	
	do -- function section
		function out:SetSize(columns,rows)
			rows = tonumber(rows) or 0
			columns = tonumber(columns) or 0
			if rows < 0 then rows = 0 end
			if columns < 0 then columns = 0 end
			wipe(self.data)
			if rows == 0 or columns == 0 then
				self:Hide()
				wipe(self.cont)
				self.state.rows = 0
				self.state.columns = 0
				return
			end
			for i, cell in next, self.cont do
				local c,r = cell:GetCoord()
				if r > rows or c > columns then
					cell:Hide()
					self.cont[i] = nil
				else
					if not self.data[c] then self.data[c] = {} end
					self.data[c][r] = cell
				end
			end
			for i = 1, columns do
				for j = 1, rows do
					if not self.data[i] then self.data[i] = {} end
					if not self.data[i][j] then 
						local c = cell.new(i,j,out)
						table.insert(self.cont,c)
						if j > 1 then 
							c:SetWidth(self.data[i][j-1]:GetWidth()) 
						end
						if i > 1 then c:SetHeight(self.data[i-1][j]:GetHeight()) 
						end
						self.data[i][j] = c
					end
				end
			end
			self.state.rows = rows
			self.state.columns = columns
			self:SetAllPoints()
		end
		
		function out:SetAllPoints()
			local ai1, aij = nil, nil
			for j = 1, self.state.rows do
				aij = nil
				for i = 1, self.state.columns do
					local c = self.data[i][j]
					if ai1 == nil then 
						ai1 = c
						aij = c
						c:SetPoint()
					elseif aij == nil then 
						aij = c
						c:SetPoint(ai1,2)
						ai1 = c
					else
						c:SetPoint(aij)
						aij = c
					end
				end
			end
		end
		
		function out:Hide()
			for _,i in next, self.cont do
				i:Hide()
			end
		end
		
		function out:SetCellSize(i,j,w,h)
			if self:Check(i,j) then
				for k = 1, self.state.columns do self.data[k][j]:SetHeight(h) end
				for k = 1, self.state.rows do self.data[i][k]:SetWidth(w) end
			end 
		end
		
		function out:DeleteRow(row)
			if row > self.state.rows or row < 1 then return false end
			self.data = {}
			for k, cell in next, self.cont do
				if cell.row == row then
					cell:Hide()
					self.cont[k] = nil
				else
					if cell.row > row then
						cell.row = cell.row - 1
					end
					if not self.data[cell.column] then self.data[cell.column] = {} end
					self.data[cell.column][cell.row] = cell
				end
			end
			self.state.rows = self.state.rows - 1
			self:SetAllPoints()
		end
		
		function out:SetDefCellSize(w,h)
			self.state.defw = w or self.state.defw
			self.state.defh = h or self.state.defh
		end
	
		function out:Check(i,j)
			if self.data[i] then
				if self.data[i][j] then return true end
			end
			return false
		end
		
		function out:HighLight(row, in_)
			if not self:Check(1,row) then return end
			for i = 1, self.state.columns do
				self.data[i][row].mouse = in_
				self.data[i][row]:changeState(nil,nil,true)
			end
		end
	end
	
	do -- functions with value/tooltips
		function out:SetValue(i, j, val)
			if self:Check(i,j) then self.data[i][j]:SetValue(val) end 
		end
		
		function out:GetValue(i, j)
			if self:Check(i,j) then return self.data[i][j]:GetValue() end
		end
		
		function out:SetToolTip(i,j,type_, val)
			if self:Check(i,j) then
				if (type_ == "HyperLink") or (type_ == "Text") or (type_ == "nil") then
					self.data[i][j]:SetToolTip(type_, val)
					return true
				end
			end
			return false
		end
	
		function out:SetScript(i,j,func)
			if self:Check(i, j) then
				self.data[i][j]:SetScript(i, j, func)
			end
		end
	end
	
	return out
end

--[[-----------------------------------------------------------------------------
Mix functions
-------------------------------------------------------------------------------]]
local function CheckCellVisible(widget)
	if not widget.tt.state then return end
	local mw, mh = 0, 0
	for i = 1, widget.tt.state.columns do
		local w = 0
		mh = 0
		for j = 1, widget.tt.state.rows do
			local c = widget.tt.data[i][j]
			local h = 0
			w, h = c:GetSize()
			mh = mh + h
			if mw + w > widget.state.width or mh > widget.state.height then c:Hide() else c:Show() end
			--printF("w=%d h=%d i=%d j=%d",mw,mw+h,i,j)
		end
		mw = mw + w
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		local tt = tc.new(self.frame)
		self.tt = tt
		tt:SetSize()
		self.SetFrameSize(self)
		self.SetDefaultSize(self)
	end,
	
	["DeleteRow"] = function (self,row)
		self.tt:DeleteRow(row)
	end,
	
	["DeleteColumn"] = function (self,column)
	end,

	["SetScript"] = function (self,i,j,func)
		self.tt:SetScript(i,j,func)
	end,
	
	["SetMaxSize"] = function (self, max_height, max_width) -- устанавливает максимальную ширину/высоту фрейма
		local mw, mh = 0, 0
		if self.tt.state.columns == 0 or self.tt.state.rows == 0 then return end
		for i = 1, self.tt.state.columns do mw = mw + self.tt.data[i][1]:GetWidth() end
		for j = 1, self.tt.state.rows do mh = mh + self.tt.data[1][j]:GetHeight() end
		mw = mw + 1
		mh = mh + 1
		if not max_height then mh = nil end
		if not max_width then mw = nil end
		-- printF("--- %d %d",mw, mh)
		self:SetFrameSize(mw , mh)
	end,
	
	["SetSize"] = function (self, columns, rows)
		self.tt:SetSize(columns,rows)
	end,
	
	["SetValue"] = function (self, i, j, value)
		self.tt:SetValue(i,j,value)
	end,
	
	["GetValue"] = function (self, i, j)
		return self.tt:GetValue(i,j)
	end,
	
	["GetSize"] = function (self)
		return self.tt.state.columns, self.tt.state.rows
	end,
	
	["GetCellSize"] = function (self, i, j)
	end,
	
	["SetFrameSize"] = function (self, width, height)
		local h = self.frame:GetParent():GetHeight()
		local w = self.frame:GetParent():GetWidth()
		width = width or w
		height = height or h
		-- printF("+++ %d %d",width, height)
		self.state.height = height or self.state.height
		self.state.width = width or self.state.width
		self.frame:SetSize(self.state.width,self.state.height)
		CheckCellVisible(self)
	end,
	
	["SetDefaultSize"] = function (self, width, height) -- SetDefaultSize
		self.state.def.width = width or self.state.def.width
		self.state.def.height = height or self.state.def.height
		self.tt:SetDefCellSize(self.state.def.width, self.state.def.height)
	end,
	
	["SetCellSize"] = function (self, i, j, width, height) -- устанавливает ширину/высоту €чейки
		for i_ = 1, self.tt.state.columns do self.tt:SetCellSize(i_,j,nil,height) end
		for j_ = 1, self.tt.state.rows do self.tt:SetCellSize(i,j_,width,nil) end
		self:SetFrameSize()
	end,
	
	["SetToolTip"] = function (self, i, j, t_, v_)
		self.tt:SetToolTip(i,j,t_,v_)
	end,
	
	["GetToolTip"] = function (self, i, j)
	end,
	
	["Disable"] = function (self, i, j, state)
		if self.tt:Check(i,j) then
			local cell = self.tt.data[i][j]
			if state == nil then state = cell:IsEnable() end
			cell:Enable(not state)
		end
	end,
	
	["IsDisabled"] = function (self, i, j)
		if self.tt:Check(i,j) then
			local cell = self.tt.data[i][j]
			return not cell:IsEnable()
		end
	end,
	
	["OnWidthSet"] = function(self, width)
		--self.SetFrameSize(self)
	end,

	["OnHeightSet"] = function(self, height)
		--self.SetFrameSize(self)
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
	
	local state = {
		width = def.table.width,
		height = def.table.height,
		rows = def.table.rows,
		columns = def.table.columns,
		def = {
			width = def.cell.width,
			height = def.cell.height,
		},
	}
	
	local widget = {
		tt		= table_,
		state	= state,
		frame   = frame,
		type    = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
