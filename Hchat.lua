local AceGUI = LibStub("AceGUI-3.0")
--[[-----------------------------------------------------------------------------
Frame Container modified for me (copied from AceGUI!!!!!
-------------------------------------------------------------------------------]]
-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: CLOSE

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local points={}

local function UP__(frame)
	if frame.sz.over then frame.line:SetTexture(frame.sz.over)
	else frame.line:SetTexture(frame.sz.file) end
end

local function DOWN__(frame)
	if frame.sz.down then 
		frame.line:SetTexture(frame.sz.down) 
	end
end

local function Button_OnClick(frame)
	if frame.obj:IsShown() then frame.obj:Hide() else frame.obj:Show() end
end

local function Frame_OnClose(frame)
	frame.obj:Fire("OnClose")
end

local function MoverSizer_OnMouseUp(mover)
	local frame = mover:GetParent()
	frame:StopMovingOrSizing()
	local self = frame.obj
	local status = self.status or self.localstatus
	status.width = frame:GetWidth()
	status.height = frame:GetHeight()
	status.top = frame:GetTop()
	status.left = frame:GetLeft()
	frame:ClearAllPoints()
	for _,v in pairs(points) do
		frame:SetPoint(v.point,v.relativeTo,v.relativePoint,v.xOffset,v.yOffset)
	end
	points={}
	UP__(frame)
end

local function SizerS_OnMouseDown(frame)
	for i=1, frame:GetParent():GetNumPoints() do
		local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetParent():GetPoint(index)
		table.insert(points,{
			point=point, 
			relativeTo=relativeTo, 
			relativePoint=relativePoint, 
			xOffset=xOffset, 
			yOffset=yOffset,})
	end
	frame:GetParent():StartSizing("BOTTOM")
	AceGUI:ClearFocus()
	DOWN__(frame:GetParent())
end

local function send_msg(self,func)
	--Hagakure:Printf("We are here with %s",self:GetText())
	if func then
		func(self:GetText())
	end
	self:SetText("")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:ApplyStatus()
		self:Hide()
	end,

	["OnRelease"] = function(self)
		self.status = nil
		wipe(self.localstatus)
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end,

	["Hide"] = function(self)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		self.frame:Show()
	end,

	["ApplyStatus"] = function(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		local conf=self.frame.conf
		self:SetWidth(conf.width)
		self:SetHeight(status.height or conf.height)
		frame.box:SetWidth(conf.width-conf.box.diff_width)
		frame.box:SetHeight(conf.box.height)
		frame:ClearAllPoints()
		frame.box:ClearAllPoints()
		if status.top and status.left then
			frame:SetPoint("TOP", UIParent, "BOTTOM", 0, status.top)
			frame:SetPoint("LEFT", UIParent, "LEFT", status.left, 0)
		else
			frame:SetPoint("CENTER")
		end
		frame.box:SetPoint("TOP",frame,"TOP",-conf.box.diff_width/2,conf.box.pos_up)
	end,

	["AddMessage"] = function (self,sender,msg)
		table.insert(self.messagelist,{
			sender=sender,
			msg=msg,
		})
		self.frame.butt:SetText("|cffff0000messages|r")
	end,
	
	["GetMessages"] = function (self)
		return self.messagelist
	end,
	
	["SetOnSend"] = function (self,func)
		local e_=self.frame.editbox
		e_:SetScript("OnEnterPressed",function (inp)
			--Hagakure:Print("Settting new function")
			send_msg(inp,func)
		end)
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

function HFrameConstructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()
	
	local conf=Hagakure.db.profile.chat
	frame.conf=Hagakure.db.profile.chat

	local FrameBackdrop = { --фон
		bgFile = LSM:Fetch("background",Hagakure.db.profile.frame.background),
		edgeFile = LSM:Fetch("border",Hagakure.db.profile.frame.border),
		tile = false, tileSize = 0, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	}

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetBackdrop(FrameBackdrop)
	frame:SetBackdropColor(0, 0, 0, 1)
	frame:SetMinResize(100, 100)
	frame:SetToplevel(true)
	frame:SetScript("OnHide", Frame_OnClose)
	
	local box = CreateFrame("Frame",nil,UIParent)
	box:EnableMouse(true)
	box:SetMovable(true)
	box:SetResizable(true)
	box:SetFrameStrata("FULLSCREEN_DIALOG")
	box:SetBackdrop(FrameBackdrop)
	box:SetBackdropColor(0, 0, 0, 1)
	box:SetToplevel(true)
	frame.box=box

	local butt = AceGUI:Create("HButton")
	butt.frame:SetParent(box)
	butt.frame:Show()
	butt:SetCallback("OnClick", Button_OnClick)
	butt:SetPoint("TOPRIGHT",frame,"TOPRIGHT",conf.butt.pos.x,conf.butt.pos.y)
	butt:SetWidth(conf.butt.width)
	butt:SetHeight(conf.butt.heigth)
	butt:SetText("|cffffff00nil|r")
	butt.obj=frame
	frame.butt=butt

	local editbox = CreateFrame("EditBox", "AceGUI-3.0EditBox"..AceGUI:GetNextWidgetNum("EditBox"), box, "InputBoxTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetTextInsets(0, 0, 3, 3)
	editbox:SetMaxLetters(256)
	editbox:SetPoint("LEFT", conf.edit.left, 0)
	editbox:SetPoint("RIGHT",conf.edit.right,0)
	editbox:SetHeight(conf.edit.height)
	editbox:SetScript("OnEnterPressed",send_msg)
	frame.editbox=editbox
	
	-- "увеличители окна"
	local sizer_se = CreateFrame("Frame", nil, frame)
	sizer_se:SetPoint("BOTTOMRIGHT")
	sizer_se:SetWidth(25)
	sizer_se:SetHeight(25)
	sizer_se:EnableMouse()
	sizer_se:SetScript("OnMouseDown", SizerS_OnMouseDown)
	sizer_se:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

	local sz = Hagakure.frame_configurations.sizer_styles[Hagakure.db.profile.frame.sizer]
	frame.sz = sz

	local line2 = sizer_se:CreateTexture(nil, "BACKGROUND")
	line2:SetWidth(sz.w)
	line2:SetHeight(sz.h)
	line2:SetPoint("BOTTOMRIGHT", -5, 5)
	line2:SetTexture(sz.file)
	frame.line = line2

	if sz.over then 
		sizer_se:SetScript("OnEnter", function() line2:SetTexture(sz.over) end) 
		sizer_se:SetScript("OnLeave", function() line2:SetTexture(sz.file) end) 
	end

	local sizer_s = CreateFrame("Frame", nil, frame)
	sizer_s:SetPoint("BOTTOMRIGHT", -25, 0)
	sizer_s:SetPoint("BOTTOMLEFT")
	sizer_s:SetHeight(25)
	sizer_s:EnableMouse(true)
	sizer_s:SetScript("OnMouseDown", SizerS_OnMouseDown)
	sizer_s:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

	--Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 10, -12)
	content:SetPoint("BOTTOMRIGHT", -10, 12)

	local widget = {
		localstatus = {},
		messagelist = {},
		content     = content,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) 
	do
		widget[method] = func
	end
	-- closebutton.obj, statusbg.obj = widget, widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType("HChat", HFrameConstructor, 1)



