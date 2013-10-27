if not Hagakure then return false end
local AceGUI = LibStub("AceGUI-3.0")
local conf = Hagakure.frame_configurations

--[[-----------------------------------------------------------------------------
Frame Container modified for me (copied from AceGUI!!!!!
-------------------------------------------------------------------------------]]
-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: CLOSE
local Type, Version = "HFrame", 2
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Button_OnClick(frame)
	PlaySound("gsTitleOptionExit")
	frame.obj:Hide()
	frame.obj:Fire("OnClose")
end

local function Frame_OnClose(frame)
	frame.obj:Fire("OnHide")
end

local function Frame_OnMouseDown(frame)
	AceGUI:ClearFocus()
end

local function Title_OnMouseDown(frame)
	frame:GetParent():StartMoving()
	AceGUI:ClearFocus()
end

local function UP__(frame)
	if frame.sz.over then frame.line:SetTexture(frame.sz.over)
	else frame.line:SetTexture(frame.sz.file) end
end

local function DOWN__(frame)
	if frame.sz.down then 
		frame.line:SetTexture(frame.sz.down) 
	end
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
	UP__(frame)
end

local function SizerSE_OnMouseDown(frame)
	frame:GetParent():StartSizing("BOTTOMRIGHT")
	AceGUI:ClearFocus()
	DOWN__(frame:GetParent())
end

local function SizerS_OnMouseDown(frame)
	frame:GetParent():StartSizing("BOTTOM")
	AceGUI:ClearFocus()
	DOWN__(frame:GetParent())
end

local function SizerE_OnMouseDown(frame) 
	frame:GetParent():StartSizing("RIGHT")
	AceGUI:ClearFocus()
	DOWN__(frame:GetParent())
end

local function StatusBar_OnEnter(frame)
	frame.obj:Fire("OnEnterStatusBar")
end

local function StatusBar_OnLeave(frame)
	frame.obj:Fire("OnLeaveStatusBar")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnClose"] = function (self,func)
		--Hagakure:Print(type(func))
		--frame:SetScript("OnHide", Frame_OnClose)
		self.frame:SetScript("OnHide", func)
	end,
	
	["OnAcquire"] = function(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:SetTitle()
		--self:SetStatusText()
		self:ApplyStatus()
		self:Show()
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

	["SetTitle"] = function(self, title)
		self.titletext:SetText(title)
		self.titlebg:SetWidth((self.titletext:GetWidth() or 0) + 10)
	end,

	["Hide"] = function(self)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		self.frame:Show()
	end,

	-- called to set an external table to store status in
	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end,

	["ApplyStatus"] = function(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 700)
		self:SetHeight(status.height or 500)
		frame:ClearAllPoints()
		if status.top and status.left then
			frame:SetPoint("TOP", UIParent, "BOTTOM", 0, status.top)
			frame:SetPoint("LEFT", UIParent, "LEFT", status.left, 0)
		else
			frame:SetPoint("CENTER")
		end
	end,
	
	["UnBlockRight"] = function (self,is)
		if is then
			self.frame.sizer_se:SetScript("OnMouseDown",SizerSE_OnMouseDown)
			self.frame.sizer_e:Show()
		else
			self.frame.siser_se:SetScript("OnMouseDown", SizerS_OnMouseDown)
			self.frame.sizer_e:Hide()
		end
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	
	local FrameBackdrop = { --фон
		bgFile = LSM:Fetch("background",Hagakure.db.profile.frame.background),
		edgeFile = LSM:Fetch("border",Hagakure.db.profile.frame.border),
		tile = false, tileSize = 0, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	}
	
	frame:SetBackdrop(FrameBackdrop)
	frame:SetBackdropColor(0, 0, 0, 1)
	frame:SetMinResize(400, 200)
	frame:SetToplevel(true)
	frame:SetScript("OnHide", Frame_OnClose)
	frame:SetScript("OnMouseDown", Frame_OnMouseDown)

	local closebutton = AceGUI:Create("HButton")--CreateFrame("Button", "terafadf", frame, "UIPanelCloseButton")
	closebutton:SetCallback("OnClick", Button_OnClick)
	closebutton.frame:SetParent(frame)
	closebutton.frame:Show()
	local close = Hagakure.db.profile.frame.close
	closebutton:SetPoint(close.pos, close.x, close.y)
	closebutton:SetHeight(conf.close_styles[close.type].height)
	closebutton:SetWidth(conf.close_styles[close.type].width)
	if conf.close_styles[close.type].text then
		closebutton:SetText(conf.close_styles[close.type].text)
	end
	closebutton:SetTextures(conf.close_styles[close.type].normal,conf.close_styles[close.type].pushed,conf.close_styles[close.type].highLight)

	local titlebg = frame:CreateTexture(nil, "OVERLAY")
	titlebg:SetTexture(conf.title_styles[Hagakure.db.profile.frame.title].bgFile)
	titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
	titlebg:SetPoint("TOP", 0, 12)
	titlebg:SetWidth(100)
	titlebg:SetHeight(40)

	local title = CreateFrame("Frame", nil, frame)
	title:EnableMouse(true)
	title:SetScript("OnMouseDown", Title_OnMouseDown)
	title:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
	title:SetAllPoints(titlebg)
	
	local titletext = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	titletext:SetPoint("TOP", titlebg, "TOP", 0, -14)

	-- “екстура с левой частью заголовка
	local titlebg_l = frame:CreateTexture(nil, "OVERLAY")
	titlebg_l:SetTexture(conf.title_styles[Hagakure.db.profile.frame.title].leftFile)
	titlebg_l:SetTexCoord(0.21, 0.31, 0, 0.63)
	titlebg_l:SetPoint("RIGHT", titlebg, "LEFT")
	titlebg_l:SetWidth(30)
	titlebg_l:SetHeight(40)

	-- “екстура правой части заголовка
	local titlebg_r = frame:CreateTexture(nil, "OVERLAY")
	titlebg_r:SetTexture(conf.title_styles[Hagakure.db.profile.frame.title].rightFile)
	titlebg_r:SetTexCoord(0.67, 0.77, 0, 0.63)
	titlebg_r:SetPoint("LEFT", titlebg, "RIGHT")
	titlebg_r:SetWidth(30)
	titlebg_r:SetHeight(40)

	-- "увеличители окна"
	local sizer_se = CreateFrame("Frame", nil, frame)
	sizer_se:SetPoint("BOTTOMRIGHT")
	sizer_se:SetWidth(25)
	sizer_se:SetHeight(25)
	sizer_se:EnableMouse()
	sizer_se:SetScript("OnMouseDown", SizerS_OnMouseDown)
	sizer_se:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
	frame.sizer_se=sizer_se
	
	local sz = conf.sizer_styles[Hagakure.db.profile.frame.sizer]
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

	local sizer_e = CreateFrame("Frame", nil, frame)
	sizer_e:SetPoint("BOTTOMRIGHT", 0, 25)
	sizer_e:SetPoint("TOPRIGHT")
	sizer_e:SetWidth(25)
	sizer_e:EnableMouse(true)
	sizer_e:SetScript("OnMouseDown", SizerE_OnMouseDown)
	sizer_e:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
	sizer_e:Hide()
	frame.sizer_e=sizer_e

	--Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 10, -22)
	content:SetPoint("BOTTOMRIGHT", -10, 12)

	local widget = {
		localstatus = {},
		titletext   = titletext,
		titlebg     = titlebg,
		content     = content,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) 
	do
		widget[method] = func
	end
	-- closebutton.obj, statusbg.obj = widget, widget
	closebutton.obj = widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)



