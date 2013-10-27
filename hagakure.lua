local addon_name="Hagakure"
Hagakure = LibStub("AceAddon-3.0"):NewAddon(addon_name,"AceEvent-3.0","AceComm-3.0","AceSerializer-3.0","AceTimer-3.0") -- Создаем аддон средствами WoW Ace 3.0
Hagakure.name = addon_name

Hagakure.console = LibStub("AceConsole-3.0") -- Загруска библиотеки по работе с консолью. 
local AceGUI = LibStub("AceGUI-3.0") -- Загрузка библлиотеки по работе с интерфейсом
function Hagakure:GetLocale()
	local L = LibStub("AceLocale-3.0"):GetLocale(Hagakure.name, true) -- загрузка локали аддона
	if L == nil then 
		L = {}
		setmetatable(L,{
			__index =  function (table_,key)
				return key
			end,
		})
	end
	return L
end
local L = Hagakure:GetLocale()
local J = nil -- инициализация переменной под локаль админки, если аддон будет загружен
LSM = LibStub("LibSharedMedia-3.0") -- Загружаем библиотеку для загрузки шрифтов и тд

do--config
	ABCDE = "АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя"
	--ABCDE = "KaldohNf"
	
	local config={
		our_name= UnitName("player"),
		undef_color="|c00c3c3c3",
		pass_color="|c00c3c3c3",
		greed_color="|c00ffff80",
		off_color="|c0000ff00",
		main_color="|c00ff0000",
		min_bet=10,
		max_bet=60,
		prefix="HagakureDKP",
		prefix_new_channel="HagakureNew",
		
		bid_h=200,
		bid_w=400,
		bid_label=330,
		
		bid_anc="TOPLEFT",
		bid_hor=100,
		bid_vert=-100,
		bid_step=70,
		
		delay=1,
		delay_start=6,
		delay_is_start=false,
		wisperDelay = 5,
		
		frame = {
			background = "Blizzard Dialog Background",
			border = "Blizzard Dialog",
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",

			close = {
				pos = "BOTTOMRIGHT",
				x = -20,
				y = 5,
				type = "first",
			},

			title = "first",
			button = "first",
			sizer = "first",
		},
		
		chat = {
			height = 200,
			butt={
				width=80,
				height=20,
				point = "TOPRIGHT",
				x=-5,
				y=-5,
			},
		},
		
		font = {
			name = "Arial Narrow",
			big_size = 18,
			small_size = 12,
		},
		
		chat_offset={},
		
		default_adj_reason=L.CONFIG_DEF_ADJ_REASON,
		default_dkp="Cata3",
		
		newTrade={
			frame_w=800,
			frame_h=200,
			pos="TOP",
			x=100,
			y=-200,
			row=20,
			col={
				[1]=20,
				[2]=300,
				[3]=35,
				[4]=35,
				[5]=100,
				[6]=50,
				[7]=200,
			},
		},
		
		admin={
			l_w=200,
			ch_b=30,
			b=40,
			ed=70,
			frame_w=830,
			frame_h=300,
			p_h=40,
			p_w=40,
			btn_w=150,
			btn_h=40,
			pos="TOP",
			x=300,
			y=-100,
			column=100,
			row=20,
			bet_up=5,
			col={
				[1]=30,
				[2]=300,
				[3]=30,
				[4]=50,
				[5]=50,
				[6]=60,
				[7]=50,
				[8]=200,
				[9]=40,
			},
			logWindow={
				col={
					[1]=30,
					[2]=120,
					[3]=70,
					[4]=140,
					[5]=300,
					[6]=60,
				},
				row=20,
				size={
					x=780,
					y=800,
				},
				pos={
					anc="TOP",
					x=-450,
					y=-100,
				},
				max_diff_time=900,
			},
			preLogWindow={
				w=350,
				h=250,
				pos="CENTER",
				x=0,
				y=0,
				l_w=120,
				l_h=20,
				box_w=70,
				btn1_w=130,
				btn_w=100,
				btn1_h=30,
				btn_h=30,
			},
			disenchWindow = {
				w = 250,
				h = 350,
				pos = "CENTER",
				x = -300,
				y = 200,
				btn_w = 80,
				btn_h = 20,
				drop_w = 180,
				l_w = 70,
				l_h = 30,
				box_w = 40,
			},
		},
		
		award={
			pos="TOP",
			x=-230,
			y=-100,
			w=200,
			h=150,
			btn_w=70,
			btn_h=20,
			l_w=190,
			l_h=40,
			drop_w=180,
			box_w=80,
			box_w2=200,
		},

		test_frame = {
			w=400,
			h=200,
			pos = {
				align="RIGHT",
				x=-50,
				y=0,
			},
			label_w = 350,
			butt_w = 150,
			butt_h = 50,
		},
		
		info_frame = {
			align = "RIGHT",
			width = 350,
			height = 300,
			label_w = 300,
		},
		
		config_frame = {
			width = 700,
			height = 600,
		},
		
		version="0.1.0",
	}
	
	local frame ={
		close_styles = {},
		title_styles = {},
		button_styles = {},
		sizer_styles = {},
	}
	
	config.not_accept_versions={
		"0.1.0",
		"0.1.1",
		"0.1.2",
		"0.1.3",
		"0.1.4",
		"0.1.5",
		"1.0.1",
		"1.0.2",
		"1.0.3",
		"1.0.4",
		"1.0.5",
		"1.0.6",
		"1.0.7",
		"1.1.0",
		"1.1.1",
		"1.1.2",
		"1.1.3",
	}
	
	do -- frame options
		do -- title
			frame.title_styles["second"] = {
				bgFile="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Header",
				leftFile="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Header",
				rightFile="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Header",
			}
			frame.title_styles["first"] = {
				bgFile="Interface\\DialogFrame\\UI-DialogBox-Header",
				leftFile="Interface\\DialogFrame\\UI-DialogBox-Header",
				rightFile="Interface\\DialogFrame\\UI-DialogBox-Header",
			}
		end
		do -- button
			frame.button_styles["first"] = {
				normal="Interface\\Buttons\\UI-DialogBox-Button-Up",
				disabled="Interface\\Buttons\\UI-DialogBox-Button-Disabled",
				pushed="Interface\\Buttons\\UI-DialogBox-Button-Down",
				highlight="Interface\\Buttons\\UI-DialogBox-Button-Highlight",
				edgeFile="Interface\\Buttons\\UI-Button-Borders",
				bgFile="Interface\\Buttons\\UI-DialogBox-Button-Up",
			}
			frame.button_styles["second"] = {
				normal="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Up",
				disabled="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Disabled",
				pushed="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Down",
				highlight="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Highlight",
			}
			frame.close_styles["first"] = {
				normal="Interface\\Buttons\\UI-DialogBox-Button-Up",
				disabled="Interface\\Buttons\\UI-DialogBox-Button-Disabled",
				pushed="Interface\\Buttons\\UI-DialogBox-Button-Down",
				highlight="Interface\\Buttons\\UI-DialogBox-Button-Highlight",
				width=80,
				height=20,
				text=CLOSE,
			}
			frame.close_styles["second"] = {
				pushed = "Interface\\AddOns\\hagakure\\second\\UI-CheckBox-Check-Disabled",
				normal = "Interface\\AddOns\\hagakure\\second\\UI-CheckBox-Check",
				highlight="",
				--highLight = "Interface\\AddOns\\hagakure\\second\\UI-CheckBox-Check-Disabled",
				width=60,
				height=40,
			}
			frame.close_styles["third"] = {
				normal="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Up",
				--disabled="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Disabled",
				pushed="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Down",
				highlight="Interface\\AddOns\\hagakure\\second\\UI-DialogBox-Button-Highlight",
				width=80,
				height=20,
				text=CLOSE,
			}
		end
		do -- sizer
			frame.sizer_styles["second"] = {
				file = "",
				w = 8,
				h = 8,
			}
			frame.sizer_styles["first"] = {
				file = "Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down",
				over = "Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight",
				down = "Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up",
				w = 16,
				h = 16,
			}
		end
	end
	Hagakure.frame_configurations = frame
	
	defaults = {
		profile =  config,
	}
end

--[[------------------------------Формат сообщений - общения между аддонами
-- value1 - тип события ("updateItem","newItem","makeBid","chooseSpec","fullUpdateItem","version"
-- value2 - массив события 
--    newItem,updateItem - Hagakure.itemList[item] с только модифицированными полями!
--    closeItem  - item name  - закрытие торгов на шмотку
--    version - ответ на запрос версии
--    fullUpdateItem - заново обновленная шмотка
--    RequestVersion - запрос версии
--    RequestItems - запрос шмоток по новой
--    ChatMessage - сообщение в чат вещи
--    RequestSynhronization - Запрос на синхронизацию
--    RequestDKPArray - Запрос массива дкп
-----------------------------]]--

local bufferMessages = {}
local buffetMessagesTimer = nil
function Hagakure:Wisp(...)
	local user_,mess_, tr_ = ...
	local send = mess_ or ""
	if not tr_ then	send = string.format(L["%s /w %s !help for information"],mess_,self:LootMaster()) end
	table.insert(bufferMessages, send)
	if buffetMessagesTimer then self:CancelTimer(buffetMessagesTimer, true) end
	buffetMessagesTimer = self:ScheduleTimer(function() buffetMessagesTimer = nil; wipe(bufferMessages) end,self.db.profile.wisperDelay)
	SendChatMessage(send,"WHISPER",GetDefaultLanguage(user_),user_)
end

local function chatFilter(self,event,msg,author, ...)
	if not Hagakure:IsInRaid() then return false end
	local out = false
	
	for _, i in next, bufferMessages do
		if i == msg then out = true end
	end
	
	if string.find(msg,"!dkp") then out = true end
	if string.find(msg,"!getdkp") then out = true end

	if out then return true end
end

function Hagakure:OnInitialize() -- Функция будет вызвана при загрузке аддона, то есть при входе персонажа в игру.
	self.db = LibStub("AceDB-3.0"):New("hagakureDB", defaults) -- инициализация хранилища данных
	-- self.db.profile.default_adj_reason=L.CONFIG_DEF_ADJ_REASON

	-----------------------------
	-- В будущем сюда можно будет добавить каналы для проверки версии (пример - EPGP lootmaster)
	-----------------------------

	self:RegisterMinimap()
	self:RegisterChannels()
end

function Hagakure:RegisterChannels() -- пишем функцию, чтобы перерегистрировать каналы для общения в случае смены типа общения
	self:RegisterComm(Hagakure.db.profile.prefix,"GetAddonMessage")  -- регистрируем канал для общения
	
	self:RegisterComm(Hagakure.db.profile.prefix_new_channel,"SpeedChannelMessage") -- регистрируем новый канал для общения
end

function Hagakure:OnEnable() -- Функция будет вызвана при включении аддона
	local download_date = L["raid leader functions are turned off"]
	local Hellow_World=""
	if self.db.char.raidLeader then
		if not self.Admin then 
			Hellow_World=string.format(L["You should turn on hagakure_admin!"])
			self.db.char.raidLeader = false
		else
			Hellow_World=string.format(L["Admin addon loaded version %s."],self.Admin.version)
			download_date=string.format(L["Bases loaded %s."],DKPInfo["date"])
			J = LibStub("AceLocale-3.0"):GetLocale(self.Admin.name, false)
		end
	end

	if Hellow_World~="" then Hellow_World="\n"..Hellow_World end
	Hellow_World=string.format(L["Addon Hagakure loaded"].."%s%s", download_date, Hellow_World) -- приветсвенное сообщение с выводом даты последней загрузки DKP с сайта
	if self.db.faction.downloadDKP then Hellow_World=string.format("%s\n"..L["  Found downloaded array from %s."],Hellow_World,date("%m.%d.%y %H:%M:%S",self.db.faction.downloadDKP.date)) end
	
	self.console:RegisterChatCommand("hagakure", "chatCommand") -- регистрируем команду /hagakure
	self.console:RegisterChatCommand("hagakure2", "configCommand") -- регистрируем команду /hagakure2
	self:RegisterEvent("LOOT_OPENED","LootOpen") -- регистрируем событие "полутать моба"
	self:RegisterEvent("LOOT_SLOT_CLEARED","RenewLootWindow") -- регистрируем событие "кто-то что-то лутнул"
	self:RegisterEvent("CHAT_MSG_WHISPER","Getwisper") -- регистрируем событие получения личного сообщения
	self:RegisterEvent("CHAT_MSG_SYSTEM","catchEvent") -- обработчик /roll login / logout
	self:RegisterEvent("GROUP_ROSTER_UPDATE","raidUpdate") -- обработчик обновления рейда -- RAID_ROSTER_UPDATE old?
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED","ItemInfoReceived") -- обработчик получение информации по шмотке
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER",chatFilter) --Перехватчик сообщений из виспера, чтобы потом очистить их
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM",chatFilter) --Перехватчик сообщений из виспера, чтобы потом очистить их
	
	-- проверяем инициализацию переменной и при необходимости задаем начальное значение
	do	
		if self.db.char.raidLeader then
			if self.db.faction.dkpName then -- dkp pool name
				Hellow_World=string.format("%s\n"..L["current dkp from %s"],Hellow_World, self.db.faction.dkpName)
			else 
				Hellow_World=string.format("%s\n"..L["dkp tag not setted - def %s"],Hellow_World,self.db.profile.default_dkp)
				self.db.faction.dkpName=self.db.profile.default_dkp
			end
		end

		self.db.faction.alts = self.db.faction.alts or {}
		self.db.faction.adj = self.db.faction.adj or {}
		self.db.faction.log = self.db.faction.log or {}
		self.db.faction.disenchList = self.db.faction.disenchList or {}
		
		if self.db.faction.versions==nil then -- list of addon versions of other raid members
			self.db.faction.versions={}
			Hellow_World=string.format("%s\n"..L["you need check versions"],Hellow_World)
		end
		
		self.db.char.raid = {} -- Обнуляем рейдовую группу, лучше лишний раз лог зафлудить, чем думать об исключениях
		
		if not self.db.char.minimap then -- инициализация минимапы
			self.db.char.minimap = {
				hide = false,
				minimapPos = 250,
				radius = 80,
			}
		end

		-- Инициализируем необходимые вспомогательные массивы
		self.dkpMassive = {}
		self.frameList = {}
		self.frameCount=0

		self.ItemContainer = {}
		self.DKPContainer = {}
	end
	
	if self.db.char.minimap then 
		self:TurnOnoffMinimap(self.db.char.minimap.hide)
	else
		self:TurnOnoffMinimap(true)
	end
	
	self.version = GetAddOnMetadata(self.name,"Version")
	if self.Config then 
		self.Config:RegisterOptions()
		Hellow_World=string.format("%s\n"..L["Options loaded, version is %s."],Hellow_World,self.Config.version)
	end
	
	do -- проверяем наличие конфигураций
		local conf = Hagakure.frame_configurations
		local frame = Hagakure.db.profile.frame
		--[[
			frame = {
				close = {
					type = "first",
				},
				title = "first",
				button = "first",
				sizer = "first",
			}
			local frame ={
				close_styles = {},
				title_styles = {},
				button_styles = {},
				sizer_styles = {},
			}
		--]]
		if not conf.close_styles[frame.close.type] then frame.close.type = "first" end
		if not conf.title_styles[frame.title] then frame.title = "first" end
		if not conf.button_styles[frame.button] then frame.button = "first" end
		if not conf.sizer_styles[frame.sizer] then frame.sizer = "first" end
	end
	
	Hagakure.Window = Hagakure:GetModule("HFrameCreate")
	self:Print(Hellow_World)
end  -- OnEnable

function Hagakure:OnDisable() -- Функция будет вызвана при выключении аддона
end

function Hagakure.console:chatCommand(input) --Обработка команды /hagakure 
	Hagakure:Print( L["u launch /hagakure"].. input)
	local command = Hagakure.console:GetArgs(input, 1)
	
	if not command or command == "" or command == "help" then Hagakure:GetAddonHelp("console") end -- help section
	if command=="minimap" then Hagakure:TurnOnoffMinimap()end -- disable/enable minimap button
	
	if Hagakure.db.char.raidLeader then
		if command=="adminLog" then Hagakure.Admin:GetAdminLog() end
		if command=="clearAdj" then Hagakure.Admin:ClearAdj() end
		if command=="LOG_ENABLED" then Hagakure:TurnOnoffLogging() end  -- turn on/off logging events
		if command=="log" then Hagakure.Admin:GetHagakureLog() end
		if command=="raid" then Hagakure.Admin:ShowRaidDKP() end -- print raid dkp section
		if command=="deleteLog" then Hagakure.Admin:DeleteLog() end
		if command=="list" then Hagakure.Admin:ShowDKPList() end -- list section
		if command == "dkp" then Hagakure.Admin:DKPPoolActions("consolePoolPrint") end
		if command=="alts" then Hagakure.Admin:ShowAlts() end -- printing alts list
		if command=="delete" then Hagakure.Admin:DeleteAlt(select(2,Hagakure.console:GetArgs(input, 2))) end -- delete from alts list section

		if command=="setDKPpool" then 
			local _,dkp_pool_name = Hagakure.console:GetArgs(input, 2)
			Hagakure.Admin:DKPPoolActions("consoleSetDKPpool",dkp_pool_name)
		end
		
		if command=="addAlt" then 
			local _,v1,v2 = Hagakure.console:GetArgs(input, 3)
			v1 = v1 or ""
			v2 = v2 or ""
			Hagakure.Admin:AddAlt(v1,v2)
		end -- addAlt section
		
		if command=="adj" then 
			local _, name_,adj_,reason_=Hagakure.console:GetArgs(input, 4)
			if name_ and tonumber(adj_) then Hagakure.Admin:MakeAdj(name_,adj_,reason_)
			else
				-- если нет имени, просто выводим все поправки
				if not name_ then Hagakure:GetDKPLog() end
				
				-- если нет причины, то проверяем adj_, тогда выводим лог поправок по юзеру
				if name_ then Hagakure:GetDKPLog(name_) end
			end
		end
	end
	
	if command=="RAID_LEADER" then Hagakure:TurnOnoffLootmaster() end -- turn on/off loot master flag
	if command=="RESET_WINDOWS" then Hagakure:ResetTradesWindows() end  -- reset current windows and count of it
	if command=="delVersion" then Hagakure:DeleteAddonVersions() end
	if command=="showVersion" then Hagakure:ShowAddonVersions () end
	if UnitInRaid(Hagakure:our_name()) and command=="checkVersion" then Hagakure:SendAddonMessage("RequestVersion") end
	if command=="status" then Hagakure:PrintItemsStatus() end -- print status of items auction
	
	if Hagakure:IsInRaid() then -- функционал в рейде для мастер лутера
		if command=="award" then
			local _, bid, item, player = Hagakure.console:GetArgs(input,4)
			Hagakure.Admin:ItemAward(item,player,bid)
		end
	
		if command=="cancel" then  
			local _,item = Hagakure.console:GetArgs(input,2)
			if item then Hagakure.Admin:ItemCancel(item)
			else
				local iter = Hagakure.Admin:ItemIterator()
				for i in iter() do
					Hagakure.Admin:ItemCancel(i)
				end
			end
		end
		
		if command=="announce" then   
			local _,item_ann,v1,v2 = Hagakure.console:GetArgs(input, 4)
			if item_ann==nil or item_ann=="" then Hagakure:Print(L["enter item to announce"])
			else
				v1 = tonumber(v1) or Hagakure.db.profile.min_bet
				v2 = tonumber(v2) or Hagakure.db.profile.max_bet
				Hagakure.Admin:AnnounceItem(item_ann,v1,v2)
			end
		end -- announce item
		
		if command=="close" then    
			local _,item_close = Hagakure.console:GetArgs(input, 2)
			if item_close==nil or item_close=="" then Hagakure:Print(L["enter item to close"]);
			else Hagakure.Admin:CloseItem(item_close) end
		end -- close item

		if command=="closeAll" then    
			for i,v in pairs(Hagakure.itemList) do
				Hagakure.Admin:CloseItem(i)
			end
		end -- close item
	end --   if (in_raid)

	if command=="showItems" then    -- показывает все закрытые шмотки, или одну конкретную, если указан линк
		for i,j in pairs(Hagakure.frameList) do
			Hagakure.frameList[i].frame:Show()
			if Hagakure.frameList[i].frame.chat then Hagakure.frameList[i].frame.chat.frame.box:Show() end
		end
	end
end

--[[-------   Обработка висперов   --------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
---------------------------------------------------------------]]--
function Hagakure:Getwisper(...) -- обработчик висперов !dkp need/greed/off/pass/bid <x> [item]
	--if true then return false end
	if not Hagakure.db.char.raidLeader then return false end

	local _, msg, user = ...
	local command=Hagakure.console:GetArgs(msg,1)
	local err_=false
	local silence=false

	-- запрос дкп по 
	if command=="!getdkp" then
		_,msg=Hagakure.console:GetArgs(msg,2)
		if not msg then msg="" end
		
		-- новый блок по выдаче дкп по запросу
		local name_dkp=user;
		if msg~="" then name_dkp=msg end
		
		local dkp_=Hagakure:GetUserDkp(name_dkp)
		
		if dkp_==-1 then 
			Hagakure:Wisp(user,string.format(L["no user %s in %s"], name_dkp, Hagakure.db.faction.dkpName),true)
		else
			if name_dkp==user then
				Hagakure:Wisp(user,string.format(L["u have %d in %s"], dkp_,Hagakure.db.faction.dkpName),true)
			else
				Hagakure:Wisp(user,string.format(L["%s has %d DKP in %s"],name_dkp, dkp_, Hagakure.db.faction.dkpName),true)
			end
		end
	end
	
	if command=="!help" then
		err_=false
		Hagakure:Wisp(user,string.format(L.WHISPER_HELP1,Hagakure:LootMaster()),true)
		Hagakure:Wisp(user,string.format(L.WHISPER_HELP2,Hagakure:LootMaster(),Hagakure:LootMaster()),true)
		Hagakure:Wisp(user,string.format(L.WHISPER_HELP3,Hagakure:LootMaster()),true)
		Hagakure:Wisp(user,string.format(L.WHISPER_HELP4,Hagakure:LootMaster(),Hagakure:LootMaster()),true)
		Hagakure:Wisp(user,string.format(L.WHISPER_HELP5,Hagakure:LootMaster()),true)
		Hagakure:Wisp(user,L.WHISPER_HELP6,true)
	end
	
	-- Запрос информации по разыгрываемой шмотке
	if command=="!info" and Hagakure:IsInRaid() then 
		_,msg = self.console:GetArgs(msg,2)
		
		self.Admin:GiveInfoUser(msg,user)
	end

	--[[
						Большой блок с разруливанием need/greed/off/pass/bid
	]]--
	if command=="!dkp" and self:IsInRaid() then 
		self.Admin:WisperBid(msg,user)
	end -- if in_raid and !dkp
end

function Hagakure:catchEvent(...)
	local _, sender = ...
	if string.find(sender,L["rolled"]) then
		local temp=string.sub(sender,1,string.find(sender," ")-1)
		local temp2=string.gsub(sender,temp.." ","")
		local temp3=string.gsub(temp2,string.sub(temp2,1,string.find(temp2," ")-1).." ","")
		temp2=string.sub(temp2,1,string.find(temp2," ")-1)
		local temp4=string.gsub(temp3,string.sub(temp3,1,string.find(temp3," ")-1).." ","")
		temp3=string.sub(temp3,1,string.find(temp3," ")-1)
		if temp==Hagakure:our_name() and temp4=="(1-100)" then
			for item,v in pairs(Hagakure.frameList) do
				if v.roll == true then 
					Hagakure:SendAddonMessage("ItemChatMessage",Hagakure:Serialize("ChatMessage",{
						item=item,
						sender=Hagakure:our_name(),
						msg = string.format(L["my roll is %s"],temp3),
					}),Hagakure:LootMaster())
					v.roll=false
				end
			end
		end
	end
	
	if not Hagakure.db.char.raidLeader then return false end
	
	if string.find(sender,L["rolled"]) then
		local temp=string.sub(sender,1,string.find(sender," ")-1)
		local temp2=string.gsub(sender,temp.." ","")
		local temp3=string.gsub(temp2,string.sub(temp2,1,string.find(temp2," ")-1).." ","")
		temp2=string.sub(temp2,1,string.find(temp2," ")-1)
		local temp4=string.gsub(temp3,string.sub(temp3,1,string.find(temp3," ")-1).." ","")
		temp3=string.sub(temp3,1,string.find(temp3," ")-1)
		Hagakure.Admin:WriteLog(L["rolled"], temp, temp3, temp4)
	end
	
	if string.find(sender,L["enter in"]) then
		local temp=string.sub(sender,1,string.find(sender,L["enter in"])-1)
		temp=string.sub(string.sub(temp,string.find(temp,'[',1,true)+1,-1),1,string.find(string.sub(temp,string.find(temp,'[',1,true)+1,-1),']',1,true)-1)
		if Hagakure.db.char.raid[temp]~=nil then
			Hagakure.Admin:WriteLog(L["logged in"], temp, 0,0)
			Hagakure.db.char.raid[temp].is_online=true
		end
	end
	
	if string.find(sender,L["enter out"]) then
		local temp=string.sub(sender,1,string.find(sender," ")-1)
		if Hagakure.db.char.raid[temp]~=nil then
			Hagakure.Admin:WriteLog(L["logged out"],temp,0,0)
			Hagakure.db.char.raid[temp].is_online=false
		end
	end
	
	if string.find(sender,L["joined to raid"]) then
		local temp=string.sub(sender,1,string.find(sender,L["joined to raid"])-2)
		Hagakure.Admin:WriteLog(L["log joined"],temp,0,0)
		Hagakure.db.char.raid[temp]={
			in_online=true,
		}
		if not Hagakure:VersionCheck(temp) and Hagakure:IsInRaid() then Hagakure.console:chatCommand("checkVersion") end
	end
	
	if string.find(sender,L["desline invite"]) then
		local temp=string.sub(sender,1,string.find(sender,L["desline invite"])-2)
		Hagakure.Admin:WriteLog(L["log desline"],temp,0,0)
	end
	
	if string.find(sender,L["sending invite"]) then
		local temp=string.sub(sender,1,string.find(sender,L["sending invite"])-2)
		Hagakure.Admin:WriteLog(L["log inv"],temp,0,0)
	end
	
	if string.match(sender,L["raid leave"]) then
		Hagakure.Admin:WriteLog(L["raid"],L["disband"],0,0)
	end
end

function Hagakure:raidUpdate() -- обработчик события - обновился состав рейда
	if not Hagakure.db.char.raidLeader then return false end
	
	local count=0
	
	for i,j in pairs(Hagakure.db.char.raid) do
		count=count+1
		if i and j then 
			local out="false"
			if j.is_online then out="true" end
		end
	end
	
	if UnitInRaid(Hagakure:our_name()) then -- Мы в рейде
		-- Если мы в рейде, то возможно два варианта - либо мы только присоединились к рейду
		-- и тогда нам надо собрать список членов рейда
		-- Либо кто-то присоединился к рейду
		-- Либо кто-то ушел в оффлайн? (не регистрирует)
		-- Либо кто-то зашел онлайн (регистрирует дважды)
		-- Итого оффлайн мы регистрируем через ивент и там делаем запись, 
		-- а онлайн регаем тут, волантеры будут вне системы ;/
		
		-- Мы только присоединились к рейду (массив рейда пустой)
		if count==0 then Hagakure.Admin:WriteLog(L["raid"],L["creation"],0,0) end
		
		local g15, g68 = {}, {}
		for i = 1, self:NumRaidMembers() do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
			-- Hagakure:Print(name)
			if count == 0 then
				if not online then online = false end
				Hagakure.db.char.raid[name]={
					is_online = online,
				}
				local out = 0
				if online then out = 1 end
				Hagakure.Admin:WriteLog(L["member"],name,out,0)
			end
			
			-- новая секция для слежения перемещений людей в рейде
			if subgroup > 5 then table.insert(g68, name) else table.insert(g15, name) end
		end
		
		table.sort(g68)
		table.sort(g15)
		local out = "1-5"
		for _, i in next, g15 do out = string.format("%s;%s",out,i) end
		out = out .. "|6+"
		for _, i in next, g68 do out = string.format("%s;%s",out,i) end
		Hagakure.Admin:WriteLog(L["roster"],Hagakure:our_name(),0,out)
		
	else -- Мы не в рейде
		-- Расхуячили рейд, надо обнулять массив
		Hagakure.db.char.raid={}
	end
end

--[[ Here is your temp code!!!!1
]]--
function Hagakure.console:configCommand(input) -- обработчик /hagakure2
-- [[
	Hagakure:ItemString(input)
	Hagakure:Print(Hagakure:GetItemID(input))
	local tmp = Hagakure:GetItemLink(Hagakure:GetItemID(input))
	Hagakure:Print(string.gsub(input,"\124","\124\124"))
	Hagakure:Print(string.gsub(tmp,"\124","\124\124"))
--]]
--[[
	local f = Hagakure.Window:CreateTradeWindow()

	f:SetDKPInfo("Empty") -- устанавливает значения надписи с дкп информацией
	f.CloseFunction = function() -- функция обработки кнопки закрытия окна
		local spec, bid = f:GetSpecBid()
		-- Hagakure:SendBid(bid, spec, input)
	end
	f:SetScripts(f.CloseFunction) -- onClick, onEnter, onLeave
	f:SetLink(input)--Hagakure:GetItemLink(input))
	local min_bid = 10 --self.ItemContainer[input].min_bid
	local max_bid = 60 --self.ItemContainer[input].max_bid
	f:SetSliderValues(min_bid,max_bid,1) -- установить значения слайдера
	f.roll = false
	f:SetOnChatSend(function() -- функция обработки отправки сообщения в чате
		local inp = f:GetActiveMSG()
		if inp == "/roll" then 
			f.roll = true
			RandomRoll(1,100)
		else
		end
	end)
--]]


end

--[[    Начало блока общения между аддонами       ---
-----------------------------------------------------
-----------------------------------------------------
-------------------------------------------------]]--
function Hagakure:GetAddonMessage(...)
	local prefix, message, distribution, sender = ...
	local sucs, in_value1, in_value2=Hagakure:Deserialize(message) -- разбиваем входящее сообщение на тип и само тело сообщения
	
	if not sucs then Hagakure:Printf(L.MESSAGE_ADDON_COMM_ERR,message); return false end
	
	
	------------------------
	--- Начало супер большого блока по обработке сообщений
	------------------------
	do -- version check
		-- Пришла массовая рассылка на запрос версии аддона
		if in_value1=="RequestVersion" and distribution=="RAID" then
			Hagakure:SendAddonMessage("AnswerVersionRequest")
		end
		
		-- Пришла рассылка от рейдера как ответ на запрос версии аддона
		-- Поддержка проверки версии от старых аддонов
		if in_value1=="version" then
			local w,m,d,y= CalendarGetDate()
			Hagakure.db.faction.versions[sender]={
				version=in_value2,
				time = string.format("%d.%d.%d",d,m,y),
			}
		end
	end
	
	-- Итого мы сверились версиями, теперь наша задача - проверить совместимость версий
	-- if Hagakure:VersionCheck(sender) then Hagakure:Print("Version of "..sender.." is ok.") else Hagakure:Print("Version of "..sender.." is not ok.") end
	if not Hagakure:VersionCheck(sender) then return false end
	-- Теперь обрабатываем, есть несколько вариантов начнем с банальных

	if in_value1=="ChatMessage" and distribution=="RAID" and sender==Hagakure:LootMaster() then
		if Hagakure.ItemContainer[in_value2.item] then 
			Hagakure.frameList[in_value2.item]:AddChatMSG(in_value2.sender,in_value2.msg)
		end
	end
	
	if in_value1=="closeItem" and sender==Hagakure:LootMaster() then
		--self:Print("closeItem")
		Hagakure:DeleteItem(in_value2)
	end
	
	if Hagakure:IsInRaid() then
		-- Пришло обновление по шмотке от члена рейда
		if in_value1=="updateItem" and distribution=="WHISPER" then 
			-- self:Print("updateItem")
			Hagakure.Admin:AplyUserBid(sender,in_value2.bid,in_value2.spec,in_value2.item)
		end
		
		-- Пришел запрос на переотправку текущих шмоток
		if in_value1=="RequestItems" and distribution=="WHISPER" then
			Hagakure.Admin:ReRequestItems(sender)
		end
		
		--[[ Формат сообщения
			{
				item=link,
				msg=msg,
				sender=sender
			}
		]]
		-- Пришло виспером сообщение в чат шмотки
		if in_value1=="ChatMessage" and distribution=="WHISPER" then
			-- проверяем объявлена ли данная шмотка
			if Hagakure.ItemContainer[in_value2.item] then
				-- и отсылаем это сообщение через рейд
				Hagakure:SendAddonMessage("ItemChatMessage",Hagakure:Serialize(in_value1,in_value2))
			end
		end
	end

	if Hagakure.db.char.raidLeader then
		if in_value1=="RequestSynhronization" then
			if in_value2 then Hagakure.Admin:Synhronize(1,in_value2) else Hagakure.Admin:Synhronize(2,sender) end
		end
		
		if in_value1=="RequestDKPArray" then
			if in_value2 then Hagakure.Admin:DownloadDKP(4,in_value2) else Hagakure.Admin:DownloadDKP(3,sender) end
		end
	end
end

--[[ Админка       ---------------------
----------------------------------------
----------------------------------------
------------------------------------]]--
function Hagakure:LootOpen(input) -- обработчик лута моба
	if Hagakure:IsInRaid() then
		if not Hagakure.Admin.masterLootFrameNew then  -- Если окно не существует - мы его создаем, если существует, то делаем видимым и обновляем контент
			Hagakure.Admin.masterLootFrameNew,Hagakure.Admin.masterLootTable=Hagakure.Admin:CreateAdminWindow() 
			--[[ Ну и на последок проверка на "дурака"
				Если у нас есть уже объявленые аукционы, то для каждой шмотки там запускаем обновление окна админа]]
			if Hagakure.ItemContainer then for item,_ in pairs(Hagakure.ItemContainer) do Hagakure.Admin:UpdateAdminWindow("itemupdate",item) end end
		else
			Hagakure.Admin.masterLootFrameNew:Show()
			Hagakure.Admin:UpdateAdminWindow("loot")
		end 
	end
end

function Hagakure:RenewLootWindow()
	if Hagakure:IsInRaid() then
		Hagakure.Admin:UpdateAdminWindow("loot")
	end
end

local function new_item(arr)
	local out = string.format("%s.%s",arr[1],arr[2])
	local ic={
		id = arr[1],
		uniq_id = arr[2],
		itemLink = Hagakure:GetItemLink(out),
		min_bid=arr[3] or 0,
		max_bid=arr[4] or 1000,
		players={},
	}
	for _,i in next, Hagakure.DKPContainer do
		table.insert(ic.players,{
			name = i.name,
			spec = -1,
			bid = -1,
		})
	end
	Hagakure.ItemContainer[out] = ic
	Hagakure:TradeWindow(out)
	Hagakure:UpdateFrames()
end

function Hagakure:SpeedChannelMessage(...)
	local _, message, distribution, sender = ...
	if not message then return false end
	msg = Hagakure:unpack(message)
	--msg = message
	--self:Printf("%s",msg)
	
	local do_ = true
	local count = 0
	while do_ do -- findind all !dkp !item and !bid in string
		do_ = false
		count = count+1
		local stop_count = 200
		if count > stop_count then return false end

		--Hagakure.ItemContainer = {}
		--Hagakure.DKPContainer = {}
		
		if string.find(msg,"^!dkp") then
			do_ = true
			msg = string.gsub(msg,"^!dkp","")
			local dkp_arr = {}
			local circle = true
			while circle do
				local str = string.match(msg,"^[" .. ABCDE .. "]+\:[-]?%d+\^")
				if str then 
					circle = true
					count = count+1
					if count > stop_count then return false end
					msg = string.gsub(msg,"^[" .. ABCDE .. "]+\:[-]?%d+\^","")
					local name = string.match(str,"[" .. ABCDE .. "]+")
					local dkp = string.match(str,"[-]?%d+")
					dkp = tonumber(dkp) or -1
					-- self:Printf("%d dkp %s=%d",count,name,dkp)
					table.insert(dkp_arr,{
						name = name,
						dkp = dkp,
					})
				else
					circle = false
				end
			end
			table.sort(dkp_arr,function (v1,v2) return v1.name<v2.name end)
			self.DKPContainer = dkp_arr
		end
		
		if string.find(msg,"^!bid") then
			do_ = true
			local str = string.match(msg,"^!bid%d+\:%d+\-[" .. ABCDE .. "]+\.%d+\*%d+\^")
			if str == nil then self:Printf("|cffff0000found !bid but don't found full string! %s|r",str) end
			msg = string.gsub(msg,"^!bid%d+\:%d+\-[" .. ABCDE .. "]+\.%d+\*%d+\^","")
			local name = string.match(str,"[" .. ABCDE .. "]+")
			local i_ = {}
			for i in string.gmatch(str,"%d+") do table.insert(i_,tonumber(i)) end
			--Hagakure:Printf("found bid %s %d:%d spec=%d %d",name, i_[1],i_[2],i_[3],i_[4])
			local item = string.format("%d.%d",i_[1],i_[2])
			if not self.ItemContainer[item] then new_item({i_[1],i_[2]}) end
			local f = false
			for _,i in next, self.ItemContainer[item].players do
				if i.name == name then
					i.spec = i_[3]
					i.bid = i_[4]
					f = true
				end
			end
			if not f then
				-- Если не нашли игрока по разным причинам, то 
				table.insert(self.ItemContainer[item].players,{
					name = name,
					spec = i_[3],
					bid = i_[4],
				})
			end
			self:UpdateFrames()
		end
		
		if string.find(msg,"^!item") then
			do_ = true
			local str = string.match(msg,"^!item%d+\:%d+\.%d+\*%d+\^")
			msg = string.gsub(msg,"^!item%d+\:%d+\.%d+\*%d+\^","")
			str = string.gsub(str,"^!item","")
			local arr = {}
			for i in string.gmatch(str,"%d+") do table.insert(arr,tonumber(i)) end
			--self:Printf("found item  %d %d %d %d",arr[1],arr[2],arr[3],arr[4])

			local itID = string.format("%d.%d",arr[1],arr[2])
			--self:Print(itID)
			if not self.ItemContainer[itID] then
				new_item(arr)
			else
				local ic = self.ItemContainer[itID]
				ic.id = arr[1]
				ic.uniq_id = arr[2]
				ic.itemLink = Hagakure:GetItemLink(itID)
				ic.min_bid = arr[3] or 0
				ic.max_bid = arr[4] or 1000
				self.frameList[itID]:SetLink(ic.itemLink)
				self.frameList[itID]:SetSliderValues(ic.min_bid,ic.max_bid,1)
			end
		end
		
	end
end

function Hagakure:SendSpeedMsg(...)
	local method,message,user = ...
	message = self:pack(message)
	if not user then self:SendCommMessage(self.db.profile.prefix_new_channel,message,"RAID")
	else self:SendCommMessage(self.db.profile.prefix_new_channel,message,"WHISPER",user) end
	--self:Print("Send msg")
end

function Hagakure:ItemInfoReceived(...)
	-- Нам надо пройтись по окнам торгов и доп окну торгов и обновить все значения линков
	for item,k in next, self.frameList do
		local ic = self.ItemContainer[item]
		local iLink = self:GetItemLink(item)
		if ic.itemLink ~= iLink then
			-- меняем ссылку в окне
			ic.itemLink = iLink
			k:SetLink(iLink)
			-- меняем ссылки в доп окне торгов
			if self.Litems then for i,j in next,self.Litems do
				self.trade_table:SetValue(2,i,self:GetItemLink(j))
			end end
			if (not (Hagakure:IsInRaid() or Hagakure.db.char.newTrade)) and self:IsItemUsable(iLink) then k:Show() end
		end
	end
end




















