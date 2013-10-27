--[[-----------------------------------------------------------------------------
Button Widget (for Hagakure (YES, I'M COPYING IT FROM ACEGUI))
Graphical Button.
-------------------------------------------------------------------------------]]
local Type, Version = "HButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local _G = _G
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Button_OnClick(frame, _,down,...)
	AceGUI:ClearFocus()
	PlaySound("igMainMenuOption")
	frame.obj:Fire("OnClick", ...)
end

local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- restore default values
		self:SetHeight(24)
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetText()
	end,

	-- ["OnRelease"] = nil,

	["SetText"] = function(self, text)
		self.text:SetText(text)
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
		else
			self.frame:Enable()
		end
	end,
	
	["SetTextures"] = function (self,normal,pushed,highlight)
		if normal then self.frame.textures.normal = normal end
		if pushed then self.frame.textures.pushed = pushed end
		if highlight then self.frame.textures.highlight = highlight end
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local name = "AceGUI30HButton" .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Button", name, UIParent, "HagakureButtonTemplate")
	frame.name=name
	local button = Hagakure.frame_configurations.button_styles[Hagakure.db.profile.frame.button]
	local textures = {
		normal = button.normal,
		highlight = button.highlight,
		pushed = button.pushed,
	}
	frame.textures=textures
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnClick", Button_OnClick)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	
	frame:SetBackdrop(nil)
	
	local text = frame:GetFontString(nil)
	text:ClearAllPoints()
	text:SetPoint("TOPLEFT", 0,0) 
	text:SetPoint("BOTTOMRIGHT", 0,0)
	text:SetJustifyV("MIDDLE")
	text:SetJustifyH("CENTER")

	local widget = {
		text  = text,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
