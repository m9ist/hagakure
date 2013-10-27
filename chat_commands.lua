if not Hagakure then return false end
local L = LibStub("AceLocale-3.0"):GetLocale(Hagakure.name, false)

local libc = LibStub:GetLibrary("LibCompress")

local LDB = LibStub("LibDataBroker-1.1", true) -- Загрузка няшного значка на миникарте ^^
local LDBIcon = LibStub("LibDBIcon-1.0", true) -- все еще няшный значок
local HagakureDS = LDB:NewDataObject(Hagakure.name, {type = "data source",	icon = "Interface\\AddOns\\hagakure\\icon",	text="n/a",	}) -- это наш значок на миникарте

do -- minimap
	function Hagakure:RegisterMinimap()
		LDBIcon:Register(Hagakure.name, HagakureDS, Hagakure.db.char.minimap)
	end

	function HagakureDS:OnEnter()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L.MENU_HELP_LINE1, 0, 1, 1)
		GameTooltip:AddLine(L.MENU_HELP_LINE2, 0, 1, 0)
		GameTooltip:AddLine(L["Right click to open menu"], 0, 1, 0)
		if Hagakure.Config then GameTooltip:AddLine(L["Middle click to open options"], 0, 1, 0) end
		
		GameTooltip:Show()
	end

	function HagakureDS:OnLeave()
		GameTooltip:Hide()
	end

	function HagakureDS:OnClick(button)
		if button == "LeftButton" then
		elseif button == "RightButton" then
			Hagakure:OpenMenu()
		elseif button == "MiddleButton" then
			if Hagakure.Config then Hagakure.Config:ShowOptions() end
		end
	end
end

do -- chat commands
	function Hagakure:PrintItemsStatus(value) -- распечатывает текущий статус на разрол шмота
		local temp=0
		local out={}
		for key, val in pairs(Hagakure.itemList) do
			temp=temp+1
			if (not value) then
				Hagakure:Printf(L.PRINT_STATUS_OUT1,key,val.min_bid,val.max_bid,val.current_bid,val.current_spec);
			else
				out[key]={
					r=range,
					m_b=val.min_bid,
					m_m=val.max_bid,
					value=val.current_bid,
					spec=val.current_spec,
					players={}
				}
			end
			for k, v in pairs(val.players) do
				if (not value) then
					local begin_,end_="","";
					if ((v.bid<=0 and v.spec>0)or(v.spec==-1)) then
						begin_="|c00ff0000";
						end_="|r";
					end;
					Hagakure:Printf(L.PRINT_STATUS_OUT2,begin_,k,v.name,v.dkp,v.spec,v.bid,v.id_loot,end_);
				else
					out[key].players[k]={
						name=v.name,
						spec=v.spec,
						bid=v.bid,
						dkp=v.dkp,
						id_loot=v.id_loot
					}
				end
			end
		end
		if temp==0 and not value then Hagakure:Print(L["There are no auctions"]) end
		if value then return out end
	end

	function Hagakure:TurnOnoffMinimap(state)
		if state == nil then
			Hagakure.db.char.minimap.hide = not Hagakure.db.char.minimap.hide
			if not Hagakure.db.char.minimap.hide then Hagakure:Print(L.COMMAND_MINIMAP_ENABLED) else Hagakure:Print(L.COMMAND_MINIMAP_DISABLED) end
			if Hagakure.db.char.minimap.hide then LDBIcon:Hide(Hagakure.name) else LDBIcon:Show(Hagakure.name) end
			return Hagakure.db.char.minimap.hide
		elseif state then LDBIcon:Hide(Hagakure.name) else LDBIcon:Show(Hagakure.name) end
	end

	function Hagakure:TurnOnoffLootmaster()
		if Hagakure.db.char.raidLeader then Hagakure:Print(L.COMMAND_RAID_MEMBER) else Hagakure:Print(L.COMMAND_LOOT_MASTER_NOW) end
		Hagakure.db.char.raidLeader = not Hagakure.db.char.raidLeader
		ReloadUI()
		return Hagakure.db.char.raidLeader
	end

	function Hagakure:TurnOnoffLogging()
		if Hagakure.db.char.is_logging then Hagakure:Print(L.COMMAND_LOG_OFF) else Hagakure:Print(L.COMMAND_LOG_ON) end
		Hagakure.db.char.is_logging = not Hagakure.db.char.is_logging
		return Hagakure.db.char.is_logging
	end

	function Hagakure:ShowVersion()
		if not StaticPopupDialogs["Version"] then
			StaticPopupDialogs["Version"]= {
				text = string.format(L["Your current version is %s."],Hagakure.version), 
				button1 = ACCEPT, 
				timeout = 30, 
				whileDead = 0, 
				hideOnEscape = 1, 
				OnAccept = function() end,
			}
		end
		StaticPopup_Show("Version")
	end

	function Hagakure:ShowAddonVersions()
		Hagakure:Print(L.COMMAND_VERSION_LIST)
		local t = {}
		for i,j in next, self.db.faction.versions do
			table.insert(t,{
				name = i,
				version = j.version,
				time = j.time,
			})
		end
		table.sort(t,function (v1,v2) return v1.name<v2.name end)
		
		for _,j in next,t do
			local color="|c00ff0000"
			if Hagakure:VersionCheck(j.name) then color="|c00ffff00" end
			Hagakure:Printf(L["  %s %s%s|r %s"],j.name,color,j.version,j.time)
		end
	end

	function Hagakure:DeleteAddonVersions()
		Hagakure:Print(L.COMMAND_VERSION_DELETED)
		Hagakure.db.faction.versions={}
	end

	function Hagakure:GetAddonHelp(...)
		--[[ входящие аргументы
			var =
				"console" - вывод справки в консоль
		]]
		local var = ...
		if var == "console" then
			Hagakure:Print(L.COMMAND_INTO)
			Hagakure:Print("   /hagakure help  "..L.COMMAND_HELP)
			Hagakure:Print("|c00ff00ff   /hagakure Items  "..L.COMMAND_TRADE_ITEMS)
			Hagakure:Print("   /hagakure minimap  "..L.COMMAND_MINIMAP)
			Hagakure:Print("   /hagakure RESET_WINDOWS  "..L.COMMAND_TRADE_RESET)
			Hagakure:Print("   /hagakure status  "..L.COMMAND_STATUS)
			Hagakure:Print("   /hagakure RAID_LEADER  "..L.COMMAND_LOOT_MASTER_INTERFACE)
			Hagakure:Print("   /hagakure checkVersion  "..L.COMMAND_CHECK_VERSION)
			Hagakure:Print("   /hagakure showVersion  "..L.COMMAND_SHOW_VERSION)
			Hagakure:Print("   /hagakure delVersion  "..L.COMMAND_CLEAR_VERSION)

			if Hagakure.db.char.raidLeader then
				Hagakure:Print(L.COMMAND_LOOT_MASTER)
				Hagakure:Printf("   /hagakure announce [item link] [<min bet> <max bet>] "..L.COMMAND_ANNOUNCE,Hagakure.db.profile.min_bet,Hagakure.db.profile.max_bet)
				Hagakure:Print("   /hagakure close [item link]  "..L.COMMAND_CLOSE)
				Hagakure:Print("   /hagakure award <bid> [item link] <players name>  "..L.COMMAND_AWARD)
				Hagakure:Print("   /hagakure closeAll  "..L.COMMAND_CLOSE_ALL)
				Hagakure:Print("   /hagakure cancel [item link] "..L.COMMAND_CANCEL)

				Hagakure:Print("   /hagakure LOG_ENABLED  "..L.COMMAND_LOGGING)

				Hagakure:Print("   /hagakure setDKPpool <DKPname>  "..L.COMMAND_DKP_SET)
				Hagakure:Print("   /hagakure dkp  "..L.COMMAND_DKP_POOL)
				Hagakure:Print("   /hagakure raid  "..L.COMMAND_LEADER_RAID)
				Hagakure:Print("   /hagakure list  "..L.COMMAND_LIST)

				Hagakure:Print("   /hagakure alts  "..L.COMMAND_ALTS)
				Hagakure:Print("   /hagakure addAlt <name1> <name2>  "..L.COMMAND_ALTS_ADD)
				Hagakure:Print("   /hagakure delete <alt name>  "..L.COMMAND_ALTS_DELETE)

				Hagakure:Print("   /hagakure clearAdj  "..L.COMMAND_ADJ_CLEAR)
				Hagakure:Print("   /hagakure adj <name> <adjustment> <reason>  "..L.COMMAND_ADJ)

				Hagakure:Print("   /hagakure log  "..L.COMMAND_LOG)
				Hagakure:Print("   /hagakure deleteLog  "..L.COMMAND_LOG_CLEAR)
				Hagakure:Print("   /hagakure adminLog  "..L.COMMAND_PARCED_LOG)
			end
		end
	end

	function Hagakure:ResetTradesWindows()
		Hagakure:Print(L.COMMAND_RESET_WINDOWS)
		for i in next, Hagakure.frameList do
			Hagakure.frameList[i]:Destroy()
			Hagakure.frameList[i]=nil
		end
		wipe(Hagakure.frameList)
		if Hagakure.db.char.newTrade and Hagakure.newTrade then
			Hagakure.newTrade:Hide()
			Hagakure.newTrade=nil
			Hagakure.trade_table=nil 
			Hagakure.Litems=nil
		end
		wipe(Hagakure.ItemContainer)
	end
end

function Hagakure:pack(inp)
	local libcE = libc:GetAddonEncodeTable()
	local one = libc:Compress(inp)
	if not one then return inp end
	local two = libcE:Encode(one)
	if not two then return inp end
	return two
end

function Hagakure:unpack(inp)
	local libcE = libc:GetAddonEncodeTable()
	local one = libcE:Decode(inp)
	if not one then return inp end
	local two = libc:Decompress(one)
	if not two then return inp end
	return two
end

function Hagakure:IsItemUsable(item) -- проверка подходит ли шмотка человеку
	do -- объявление необходимых массивов
		armor={ --IsEquippedItemType
			["Паладин"]={ --+
				armor={
					[1]=true,
					[2]=true,
					[3]=true,
					[4]=false,
					[5]=false,
					[6]=false,
					[7]=true,
				},
				weapon={
					[1]=true,
					[2]=true,
					[3]=false,
					[4]=true,
					[5]=true,
					[6]=true,
					[7]=true,
					[8]=false,
					[9]=false,
					[10]=false,
					[11]=false,
					[12]=false,
				}
			},
			["Жрец"]={ --+
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=false,
					[5]=false,
					[6]=true,
					[7]=false,
				},
				weapon={
					[1]=false,
					[2]=false,
					[3]=true,
					[4]=false,
					[5]=false,
					[6]=true,
					[7]=false,
					[8]=true,
					[9]=false,
					[10]=true,
					[11]=false,
					[12]=false,
				}
			},
			["Жрица"]={ --+
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=false,
					[5]=false,
					[6]=true,
					[7]=false,
				},
				weapon={
					[1]=false,
					[2]=false,
					[3]=true,
					[4]=false,
					[5]=false,
					[6]=true,
					[7]=false,
					[8]=true,
					[9]=false,
					[10]=true,
					[11]=false,
					[12]=false,
				}
			},
			["Шаман"]={
				armor={
					[1]=true,
					[2]=false,
					[3]=true,
					[4]=false,
					[5]=true,
					[6]=false,
					[7]=true,
				},
				weapon={
					[1]=false,
					[2]=true,
					[3]=true,
					[4]=true,
					[5]=false,
					[6]=true,
					[7]=true,
					[8]=true,
					[9]=false,
					[10]=false,
					[11]=false,
					[12]=false,
				}
			},
			["Воин"]={
				armor={
					[1]=true,
					[2]=true,
					[3]=true,
					[4]=false,
					[5]=false,
					[6]=false,
					[7]=false,
				},
				weapon={
					[1]=true,
					[2]=true,
					[3]=false,
					[4]=true,
					[5]=true,
					[6]=true,
					[7]=true,
					[8]=true,
					[9]=true,
					[10]=false,
					[11]=true,
					[12]=true,
				}
			},
			["Разбойник"]={
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=true,
					[5]=false,
					[6]=false,
					[7]=false,
				},
				weapon={
					[1]=false,
					[2]=true,
					[3]=false,
					[4]=false,
					[5]=true,
					[6]=true,
					[7]=true,
					[8]=true,
					[9]=true,
					[10]=false,
					[11]=true,
					[12]=true,
				}
			},
			["Разбойница"]={ --+
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=true,
					[5]=false,
					[6]=false,
					[7]=false,
				},
				weapon={
					[1]=false,
					[2]=true,
					[3]=false,
					[4]=false,
					[5]=true,
					[6]=true,
					[7]=true,
					[8]=true,
					[9]=true,
					[10]=false,
					[11]=true,
					[12]=true,
				}
				},
			["Друид"]={
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=true,
					[5]=false,
					[6]=false,
					[7]=true,
				},
				weapon={
					[1]=false,
					[2]=false,
					[3]=true,
					[4]=true,
					[5]=false,
					[6]=true,
					[7]=false,
					[8]=true,
					[9]=false,
					[10]=false,
					[11]=false,
					[12]=false,
				}
			},
			["Чернокнижник"]={ --+
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=false,
					[5]=false,
					[6]=true,
					[7]=false,
				},
				weapon={
					[1]=false,
					[2]=false,
					[3]=true,
					[4]=false,
					[5]=true,
					[6]=false,
					[7]=false,
					[8]=true,
					[9]=false,
					[10]=true,
					[11]=false,
					[12]=false,
				}
			},
			["Чернокнижница"]={ --+
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=false,
					[5]=false,
					[6]=true,
					[7]=false,
				},
				weapon={
					[1]=false,
					[2]=false,
					[3]=true,
					[4]=false,
					[5]=true,
					[6]=false,
					[7]=false,
					[8]=true,
					[9]=false,
					[10]=true,
					[11]=false,
					[12]=false,
				}
			},
			["Маг"]={ --+
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=false,
					[5]=false,
					[6]=true,
					[7]=false,
				},
				weapon={
					[1]=false,
					[2]=false,
					[3]=true,
					[4]=false,
					[5]=true,
					[6]=false,
					[7]=false,
					[8]=true,
					[9]=false,
					[10]=true,
					[11]=false,
					[12]=false,
				}
			},
			["Охотник"]={ --+
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=false,
					[5]=true,
					[6]=false,
					[7]=false,
				},
				weapon={
					[1]=true,
					[2]=true,
					[3]=true,
					[4]=false,
					[5]=true,
					[6]=false,
					[7]=true,
					[8]=true,
					[9]=true,
					[10]=false,
					[11]=true,
					[12]=true,
				}
			},
			["Охотница"]={ --+
				armor={
					[1]=true,
					[2]=false,
					[3]=false,
					[4]=false,
					[5]=true,
					[6]=false,
					[7]=false,
				},
				weapon={
					[1]=true,
					[2]=true,
					[3]=true,
					[4]=false,
					[5]=true,
					[6]=false,
					[7]=true,
					[8]=true,
					[9]=true,
					[10]=false,
					[11]=true,
					[12]=true,
				}
			},
			["Рыцарь смерти"]={ --+
				armor={
					[1]=true,
					[2]=true,
					[3]=false,
					[4]=false,
					[5]=false,
					[6]=false,
					[7]=true,
				},
				weapon={
					[1]=true,
					[2]=true,
					[3]=false,
					[4]=true,
					[5]=true,
					[6]=true,
					[7]=true,
					[8]=false,
					[9]=false,
					[10]=false,
					[11]=false,
					[12]=false,
				}
			},
		}
		itype={
			["Доспехи"]=1,
			["Хозяйственные товары"]=2, -- реги
			["Разное"]=3,
			["Оружие"]=4,
		}
		subtype={
			[1]={--доспехи
				["Разное"]=1, -- ох, тринки, кольца, неки
				["Латные"]=2,
				["Щиты"]=3,
				["Кожаные"]=4,
				["Кольчужные"]=5,
				["Тканевые"]=6, -- здесь же спина
				["Реликвия"]=7, 
			},
			[4]={--оружие
				["Двуручные мечи"]=1,
				["Двуручные топоры"]=2,
				["Посохи"]=3,
				["Двуручное дробящее"]=4,
				["Одноручные мечи"]=5,
				["Одноручное дробящее"]=6,
				["Одноручные топоры"]=7,
				["Кинжалы"]=8,
				["Луки"]=9,
				["Жезлы"]=10,
				["Арбалеты"]=11,
				["Метательное"]=12,
			},
			[3]={--Разное
				["Хлам"]=1, --сюда токены идут
				["Верховые животные"]=2, --
			},
		}
		different={--слот куда одеваются Доспехи+разное
			["INVTYPE_TRINKET"]=1,
			["INVTYPE_CLOAK"]=2,
			["INVTYPE_FINGER"]=3,
			["INVTYPE_NECK"]=4,
			["INVTYPE_HOLDABLE"]=5, -- ох
			["INVTYPE_SHIELD"]=6, -- щит
		}
	end
	local class,_=UnitClass("player")
	local itemString=string.match(item,"item[%-?%d:]+")
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemString)
	if not itemName then return false end -- no link in local database, can't do nothing
	local is_usable=false
	if armor[class] then
		if itype[itemType]==1 then
			local stype=subtype[1][itemSubType]
			if not stype then Hagakure:Printf("|cffff0000Not defined subtype for %s!!|r")
			elseif stype==1 and different[itemEquipLoc] then is_usable=true
			elseif stype==6 and different[itemEquipLoc] then is_usable=true
			elseif armor[class].armor[stype] then is_usable=true end
		elseif itype[itemType]==4 then
			local stype=subtype[4][itemSubType]
			if armor[class].weapon[stype] then is_usable=true end
		else is_usable=true end
	else Hagakure:Printf("|cffff0000Your class not defined! Say it to your RL.|r") end
	
	if itemLink and is_usable then
		local stats=GetItemStats(itemLink)
		if stats["ITEM_MOD_AGILITY_SHORT"] and (class=="Паладин" or class=="Жрец" or class=="Жрица" or class=="Воин" or class=="Чернокнижник" or class=="Чернокнижница" or class=="Маг" or class=="Рыцарь смерти") then is_usable=false end
		if stats["ITEM_MOD_INTELLECT_SHORT"] and (class=="Воин" or class=="Разбойник" or class=="Разбойница" or class=="Охотник" or class=="Охотница" or class=="Рыцарь смерти") then is_usable=false end
		if stats["ITEM_MOD_STRENGTH_SHORT"] and (class=="Жрец" or class=="Жрица" or class=="Чернокнижник" or class=="Чернокнижница" or class=="Маг" or class=="Шаман" or class=="Друид" or class=="Разбойник" or class=="Разбойница" or class=="Охотник" or class=="Охотница") then is_usable=false end
	
		if string.find(itemName,"завоевателя") and not (class=="Паладин" or class=="Жрец" or class=="Жрица" or class=="Чернокнижник" or class=="Чернокнижница") then is_usable=false end -- пал жрец варлок
		if string.find(itemName,"защитника") and not (class=="Воин" or class=="Охотник" or class=="Охотница" or class=="Шаман") then is_usable=false end -- воин охотник шаман
		if string.find(itemName,"покорителя") and not (class=="Разбойник" or class=="Разбойница" or class=="Рыцарь смерти" or class=="Маг" or class=="Друид") then is_usable=false end -- рога дк маг дру
	end
	return is_usable
end

--[[ Прорисовка меню и функции связанных с нею  --
--------------------------------------------------
----------------------------------------------]]--
function Hagakure:OpenMenu(window)
	if not self.menU then
		self.menU = CreateFrame("Frame","")
	end
	local menu=self.menU
	
	menu.displayMode = "MENU"
	local info = {}
	menu.initialize = function (self, level)
		if not level then return end
		wipe(info)
		if level==1 then
			info.isTitle=1
			info.notCheckable = 1
			info.text=L["Hagakure menu"]
			UIDropDownMenu_AddButton(info, level)

			wipe(info)
			info.disabled = 1
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)
			
			wipe(info)
			info.text=L["Show current items"]
			info.notCheckable = 1
			info.func = function () Hagakure.console:chatCommand("showItems") end
			UIDropDownMenu_AddButton(info, level)
			
			if Hagakure.db.char.newTrade then 
				wipe(info)
				info.notCheckable = 1
				info.text=L["Show new trade window"]
				info.func = function () if Hagakure.newTrade then Hagakure.newTrade:Show() else Hagakure:NewTrade() end end
				UIDropDownMenu_AddButton(info, level)
			end
			
			wipe(info)
			info.text=L["Version"]
			info.notCheckable = 1
			info.func = function () Hagakure:ShowVersion() end
			UIDropDownMenu_AddButton(info, level)
			
			wipe(info)
			info.text=L["Toggle minimap icon"]
			info.notCheckable = 1
			info.func = function () Hagakure:TurnOnoffMinimap() end
			UIDropDownMenu_AddButton(info, level)
			
			--[[
			wipe(info)
			info.text=L["Turn on new trade window"]
			info.Checkable=1
			info.checked = Hagakure.db.char.newTrade
			info.func=function() Hagakure.db.char.newTrade=not Hagakure.db.char.newTrade end
			UIDropDownMenu_AddButton(info, level)
			]]
			
			wipe(info)
			info.disabled = 1
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			wipe(info)
			info.text=L["RESET WINDOWS"]
			info.func = function()
				StaticPopupDialogs["Confirm"]= {
					text = L["You realy wanna reset windows?"], 
					button1 = ACCEPT, 
					showAlert = true,
					button2 = CANCEL,
					timeout = 30, 
					whileDead = 0, 
					hideOnEscape = 1, 
					OnAccept = function() Hagakure:ResetTradesWindows() end,
				}
				StaticPopup_Show("Confirm")
			end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			wipe(info)
			info.text=L["Request again items"]
			info.func = function()
				if not StaticPopupDialogs["Confirm3"] then
					StaticPopupDialogs["Confirm3"]= {
						text = L["Allert request items"], 
						button1 = ACCEPT, 
						showAlert = true,
						button2 = CANCEL,
						timeout = 30, 
						whileDead = 0, 
						hideOnEscape = 1, 
						OnAccept = function() Hagakure:SendAddonMessage("RequestItems") end,
					}
				end
				StaticPopup_Show("Confirm3")
			end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)
			
			if HCoold then
				wipe(info)
				info.disabled = 1
				info.notCheckable = 1
				UIDropDownMenu_AddButton(info, level)
				
				wipe(info)
				info.text = L["/hcd symbiosys"]
				info.notCheckable = 1
				info.func = function () HCoold:SymbiosysTrakingList() end
				UIDropDownMenu_AddButton(info, level)
				
				wipe(info)
				info.text = L["/hcd config"]
				info.notCheckable = 1
				info.func = function () HCoold:RunConfig() end
				UIDropDownMenu_AddButton(info, level)
			end
			
			wipe(info)
			info.disabled = 1
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)
			
			if Hagakure.db.char.raidLeader then
				wipe(info)
				info.text=L["Adjustment"]
				info.notCheckable = 1
				info.colorCode="|cffff0000"
				info.func = function () Hagakure.Admin:Adj() end
				UIDropDownMenu_AddButton(info, level)
				
				wipe(info)
				info.text=L["Copy log"]
				info.notCheckable = 1
				info.func = function () Hagakure.Admin:CopyLog() end
				UIDropDownMenu_AddButton(info, level)

				wipe(info)
				info.text=L["Copy adj"]
				info.notCheckable = 1
				info.func = function () Hagakure.Admin:CopyAdj() end
				UIDropDownMenu_AddButton(info, level)

				wipe(info)
				info.text=L["Synhronize"]
				info.notCheckable = 1
				info.func = function () Hagakure.Admin:Synhronize() end
				UIDropDownMenu_AddButton(info, level)
				
				wipe(info)
				info.text=L["Parced log"]
				info.notCheckable = 1
				info.func = function () Hagakure.Admin:GetAdminLog() end
				UIDropDownMenu_AddButton(info, level)
			end
			
			if Hagakure:IsInRaid() then
				wipe(info)
				info.text=L["run version check"]
				info.notCheckable = 1
				info.func = function () Hagakure.console:chatCommand("checkVersion") end
				UIDropDownMenu_AddButton(info, level)

				wipe(info)
				info.text=L["show addon versions"]
				info.notCheckable = 1
				info.func = function () Hagakure:ShowAddonVersions () end
				UIDropDownMenu_AddButton(info, level)
				
				wipe(info)
				info.disabled = 1
				info.notCheckable = 1
				UIDropDownMenu_AddButton(info, level)
				
				wipe(info)
				info.text=L["actions with auctions"]
				info.hasArrow = 1
				info.value = "auctions"
				info.notCheckable = 1
				UIDropDownMenu_AddButton(info, level)
			end
			
			wipe(info)
			info.text         = CLOSE
			info.func         = function() CloseDropDownMenus() end
			info.checked      = nil
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)
		end
		if level==2 then
			if type(UIDROPDOWNMENU_MENU_VALUE)=="string" then
				if UIDROPDOWNMENU_MENU_VALUE=="auctions" then
					wipe(info)
					info.text=L["cancel all auctions"]
					info.notCheckable = 1
					info.func = function () Hagakure.console:chatCommand("cancel") end
					UIDropDownMenu_AddButton(info, level)

					wipe(info)
					info.text=L["close all auctions"]
					info.notCheckable = 1
					info.func = function () Hagakure.console:chatCommand("closeAll") end
					UIDropDownMenu_AddButton(info, level)
					
					wipe(info)
					info.text=L["current auctions"]
					info.hasArrow = 1
					info.notCheckable = 1
					info.value = "items" -- Сюда вообще любое значение запихать можно
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end
		if level==3 then
			local iter = Hagakure.Admin:ItemIterator()
			for i,_ in iter() do
				wipe(info)
				info.text=select(1,GetItemInfo(string.match(i,"%d+")))
				info.value = i
				info.hasArrow = 1
				info.notCheckable = 1
				UIDropDownMenu_AddButton(info, level)
			end
		end
		if level==4 then
			wipe(info)
			info.text=L["close auction"]
			info.notCheckable = 1
			info.func = function () Hagakure.Admin:ItemClose(UIDROPDOWNMENU_MENU_VALUE) end
			UIDropDownMenu_AddButton(info, level)
			
			wipe(info)
			info.text=L["cancel auction"]
			info.notCheckable = 1
			info.func = function () Hagakure.Admin:ItemCancel(UIDROPDOWNMENU_MENU_VALUE) end
			UIDropDownMenu_AddButton(info, level)
			
			wipe(info)
			info.text=L["award item"]
			info.notCheckable = 1
			info.func = function () Hagakure.Admin:AwardItemDialog(UIDROPDOWNMENU_MENU_VALUE) end
			UIDropDownMenu_AddButton(info, level)
		end
	end
	
	local x,y = GetCursorPosition(UIParent);
	ToggleDropDownMenu(1, nil, menu, "UIParent", x / UIParent:GetEffectiveScale() , y / UIParent:GetEffectiveScale())
end

function Hagakure:ItemString(item)
	local empty = {
		itemId = 0,
		enchantId = 0,
		jewelId1 = 0,
		jewelId2 = 0,
		jewelId3 = 0,
		jewelId4 = 0,
		suffixId = 0,
		uniqueID = 0,
		linkLevel = 0,
		reforgeId = 0,
		number11 = 0,
	}
	if not item then return empty end
	local out=string.match(item,"item[%-?%d:]+")
	if not out then return empty end
	local inp = {}
	for i in string.gmatch(out,"[%d]+") do table.insert(inp,i) end
	out={
		itemId = inp[1],
		enchantId = inp[2],
		jewelId1 = inp[3],
		jewelId2 = inp[4],
		jewelId3 = inp[5],
		jewelId4 = inp[6],
		suffixId = inp[7],
		uniqueID = inp[8],
		linkLevel = inp[9],
		reforgeId = inp[10],
		number11 = inp[11],
	}
	return out
end

function Hagakure:GetItemLink(item)
	local _,_,id, uniqid = string.find(item,"^(%d+)\.(%d+)$")
	local itemName = select(1,GetItemInfo(tonumber(id))) or "nothing here"
	local out = string.format("|cffff0000|Hitem:%s:0:0:0:0:0:0:0:%s:0:0|h\[%s\]|h|r",id,uniqid,itemName)

	local itemLink = select(2,GetItemInfo(string.match(item,"^%d+")))
	if not itemLink then return out end
	local i, count = 0, 0
	local i1, i2 = "", ""
	while string.find(itemLink,":%d+",i+1) do
		i = string.find(itemLink,":%d+",i+1)
		count = count+1
		if count == 8 then
			i1 = string.sub(itemLink,1,i)
		end
		if count == 9 then
			i2 = string.sub(itemLink,i)
		end
	end
	local uniqID = string.gsub(item,"^%d+\.","")
	out = string.format("%s%s%s",i1,uniqID,i2)
	return out
end

function Hagakure:GetItemID(itemLink)
	local i = Hagakure:ItemString(itemLink)
	local item = string.format("%s.%s",i.itemId,i.uniqueID)
	return item
end

function Hagakure:GetMaxBidSpec(ic)
	local max_bid, max_spec = 0, 0
	for _,i in next, ic.players do
		if max_spec < i.spec then
			max_spec = i.spec
			max_bid = i.bid
		elseif max_spec == i.spec then max_bid = math.max(max_bid,i.bid) end
	end
	return max_spec, max_bid
end

function Hagakure:Print(...)
	self.console:Print(...)
end

function Hagakure:Printf(...)
	self.console:Printf(...)
end

function Hagakure:NumRaidMembers()
	if not IsInRaid() then return 0 end
	return GetNumGroupMembers(LE_PARTY_CATEGORY_HOME)
end














