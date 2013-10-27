if not Hagakure then return end
local L = LibStub("AceLocale-3.0"):GetLocale(Hagakure.name, false)
local AceGUI = LibStub("AceGUI-3.0")

function Hagakure:IsInRaid()
	-- local is_in=UnitInRaid(Hagakure:our_name())
	local is_in = IsInRaid()
	if is_in then
		local v1,v2,v3 = GetLootMethod()
		if v1~="master" then is_in=false
		elseif Hagakure:our_name()~=Hagakure:LootMaster() then is_in=false end
	end
	if not Hagakure.db.char.raidLeader then is_in=false end
	return is_in
end

function Hagakure:GetUserDkp(input)
	local v=-1
	if Hagakure.dkpMassive[input]~=nil then v=Hagakure.dkpMassive[input] end
	if Hagakure.db.faction.alts[input]~=nil then if Hagakure.dkpMassive[Hagakure.db.faction.alts[input]]~=nil then v=Hagakure.dkpMassive[Hagakure.db.faction.alts[input]] end end
	return v
end

function Hagakure:GetSpec(input)
	if input==0 then return L["spec pass"]
	elseif input==1 then return L["spec greed"]
	elseif input==2 then return L["spec off"]
	elseif input==3 then return L["spec main"]
	elseif input==-1 then return L["spec undeff"]
	end
end

function Hagakure:LootMaster()
	local _, _, masterlooterRaidID = GetLootMethod()
	local name_ = GetRaidRosterInfo(masterlooterRaidID)
	return name_
end

function Hagakure:VersionCheck(name)
	local version=""
	local result=true
	if Hagakure.db.faction.versions[name] then version=Hagakure.db.faction.versions[name].version end
	for i,j in pairs(Hagakure.db.profile.not_accept_versions) do
		if version==j then result=false end
	end
	if version=="" then result=false end
	return result
end

--[[            Вывод лога                                      ----
--------------------------------------------------------------------
----------------------------------------------------------------]]--
function Hagakure:GetDKPLog(...)
	local name,to_do=...
	name = Hagakure.db.faction.alts[name] or name
	if not to_do then
		local out=L["All adj"]
		if name then out=string.format(L["Adj for %s"],name) end
		Hagakure:Print(out)
		
		for i,v in pairs(Hagakure.db.faction.adj) do
			local do_=true
			if name then if v.name~=name then do_=false end end
			if do_ then Hagakure:Printf("  %s  %s %d |c00ff0000 %s|r",date("%d.%m.%y %H:%M:%S",v.t),v.name,v.adj,v.reason) end
		end
	else
		local out=""
		for i,v in pairs(Hagakure.db.faction.adj) do
			out=string.format("%s\n%s  %s %d |c00ff0000 %s|r",out,v.reason,v.name,v.adj,date("%d.%m.%y %H:%M:%S",v.t))
		end
		return out
	end
end

do -- Hagakure:PrintLabel()
	local function sortBySpecBid(v1,v2)
		local out=false;
		if (v1 and v2) then
			if (v1.spec>v2.spec) then 
				out=true;
			elseif (v1.spec<v2.spec) then
				out=false;
			else
				if (v1.bid>v2.bid) then
					out=true
				elseif (v1.bid<v2.bid) then
					out=false
				else
					if (v1.user_name<v2.user_name) then
						out=true
					else
						out=false
					end
				end
			end
		end
		return out
	end

	--[[ Функция, которая создана чтобы выдать отсортированный массив по нид/пасс/ по шмотке
	-- Формат
	-- [user_name]={
	--		user_name,
	--		bid,
	--		spec,
	--		dkp,
	-- }
	------------------------------]]--
	local function getSortItem(item)
		-- Забиваем массив
		local out={}
		if item then
			if Hagakure.ItemContainer[item] then
				local k=1
				for i,j in pairs(Hagakure.ItemContainer[item].players) do
					local dkp = -1
					for _,l in next, Hagakure.DKPContainer do
						if l.name == j.name then dkp = l.dkp end
					end
					out[k]={
						user_name = j.name,
						bid = j.bid,
						spec = j.spec,
						dkp = dkp,
					}
					k=k+1
				end
				-- Сортируем
				table.sort(out,sortBySpecBid)
				-- отправляем назад
			end
		end
		return out
	end

	function Hagakure:PrintLabel(item) -- если во входящих есть линк на айтем, то выдаст только по нему инфу, иначе по всем
		local to_print="" -- на вывод

		-- local value=Hagakure:PrintItemsStatus(true)
			--	r=range,
			--	m_b=val.min_bid,
			--	m_m=val.max_bid,
			--	value=val.current_bid,
			--	spec=val.current_spec,
			--	players

		if (item) then -- по одному item
			local first=true;
			local temp=getSortItem(item)
			for k,v in pairs(temp) do
				if first then first=false else to_print=to_print.."\n" end
				if v.spec==-1 then to_print=to_print..Hagakure.db.profile.undef_color end 
				if v.spec==0 then to_print=to_print..Hagakure.db.profile.pass_color end 
				if v.spec==1 then to_print=to_print..Hagakure.db.profile.greed_color end 
				if v.spec==2 then to_print=to_print..Hagakure.db.profile.off_color end 
				if v.spec==3 then to_print=to_print..Hagakure.db.profile.main_color end 
				to_print=to_print..string.format(L["%s (%d)   %s  "],v.user_name,v.dkp,Hagakure:GetSpec(v.spec))
					if v.spec==0 then  elseif v.bid<=0 then to_print=to_print..L["no bid"] else to_print=to_print..v.bid end
				to_print=to_print.."|r"
			end
		end
		
		return to_print
	end
end

function Hagakure:ShowInfo(...) -- рисует окно с информацией
	--[[ входящие данные - 
		title - заголовок окна
		info={
			[] = {
				header = название блока текста
				text = текст
			}
		}
	]]
	local title,info = ...
	local config = Hagakure.db.profile.info_frame
	
	local frame = AceGUI:Create("HFrame")
	frame:SetWidth(config.width)
	frame:SetHeight(config.height)
	frame:SetTitle(title)
	frame:UnBlockRight(true)
	frame:SetPoint(config.align)
	frame:SetLayout("Fill")
	
	local scc = AceGUI:Create("SimpleGroup")
	local scroll = AceGUI:Create("ScrollFrame")
	scc:SetFullWidth(true)
	scc:SetFullHeight(true) -- probably?
	scc:SetLayout("Fill")
	scroll:SetLayout("Flow")
	
	for _,v in pairs(info) do
		local label = AceGUI:Create("Label")
		label:SetFont(LSM:Fetch("font",Hagakure.db.profile.font.name),Hagakure.db.profile.font.big_size)
		label:SetText(v.header)
		label:SetWidth(config.label_w)
		scroll:AddChild(label)
		
		label = AceGUI:Create("Label")
		label:SetFont(LSM:Fetch("font",Hagakure.db.profile.font.name),Hagakure.db.profile.font.small_size)
		label:SetText(v.text)
		label:SetWidth(config.label_w)
		scroll:AddChild(label)
	end
	
	scc:AddChild(scroll)
	frame:AddChild(scc)
end

function Hagakure:SendBid(...) -- Отправляем нашу ставку РЛу через виспер аддоном!
	local bid, spec, item=...

	-- начнем с начала
	-- у нас есть ставка, спек и шмотка, нам надо просто отправить сериализованный массив РЛу
	local out = {
		bid = bid,
		spec = spec,
		item = item,
	}
	
	-- Ну а теперь этот массив мы закрываем и отсылаем персональным сообщением РЛу.
	self:SendAddonMessage("updateItem", out)
end

function Hagakure:DeleteItem(item) -- remove item from memory
	if not item or item~="" then 
		self.ItemContainer[item]=nil
		if self.frameList[item] then
			self.frameList[item]:Destroy()
			self.frameList[item]=nil
			self:NewTrade()
		end
	end
end

do -- прорисовка окна торгов и связанные с ним действия
	function Hagakure:TradeWindow(input) -- рисует окно торгов на стороне клиента
		if not self.ItemContainer[input] then return false end
		if self.frameList[input] then
			self.frameList[input]:Destroy()
			self.frameList[input] = nil
			self:NewTrade()
		end
		
		self.frameList[input] = self.Window:CreateTradeWindow()
		local f = self.frameList[input]

		f:SetDKPInfo("Empty") -- устанавливает значения надписи с дкп информацией
		f.CloseFunction = function() -- функция обработки кнопки закрытия окна
			local spec, bid = f:GetSpecBid()
			Hagakure:SendBid(bid, spec, input)
		end
		f:SetScripts(f.CloseFunction) -- onClick, onEnter, onLeave
		f:SetLink(self:GetItemLink(input))
		local min_bid = self.ItemContainer[input].min_bid
		local max_bid = self.ItemContainer[input].max_bid
		f:SetSliderValues(min_bid,max_bid,1) -- установить значения слайдера
		f.roll = false
		f:SetOnChatSend(function() -- функция обработки отправки сообщения в чате
			local inp = f:GetActiveMSG()
			if inp == "/roll" then 
				f.roll = true
				RandomRoll(1,100)
			else
				self:SendAddonMessage("ItemChatMessage",self:Serialize("ChatMessage",{
					item = input,
					sender = Hagakure:our_name(),
					msg = inp,
				}),self:LootMaster())
			end
		end)

		if self:IsInRaid() or self.db.char.newTrade or (not self:IsItemUsable(self.ItemContainer[input].itemLink)) then f:Hide() end
	end

	function Hagakure:UpdateFrames()
		-- пройтись по всем фреймам и обновить значения для каждой шмотки
		for i,v in next, self.frameList do
			v:SetDKPInfo(self:PrintLabel(i))
			if self:IsInRaid() then self.Admin:UpdateAdminWindow("itemupdate",i) end
			self:NewTrade(i)
		end
	end
end

function LineLabel_OnEnter (widget)
	if widget:GetUserData('isitem') then
		GameTooltip:SetOwner (widget.frame, "ANCHOR_LEFT", -20, 0)
		GameTooltip:SetHyperlink (widget.label:GetText())
	end
end

function LineLabel_OnLeave (widget)
	GameTooltip:Hide()
end

function LineLabel_OnClick (widget)
	if Hagakure:IsInRaid() then
		Hagakure.Admin:AwardItemDialog(widget.label:GetText())
	else
		SetItemRef(widget.label:GetText(),widget.label:GetText())
	end
end

do -- Прорисовка нового окна торгов
	local function buttOnClick(...) -- обработчик нажатия кнопки
		local i,j,button=...
		Hagakure.frameList[Hagakure.Litems[j]].frame:Show()
		Hagakure.frameList[Hagakure.Litems[j]].frame.chat.frame.box:Show()
	end

	local function clickItem(...)
		local i,j,button=...
		local link=Hagakure.Litems[j]
		SetItemRef(link,link,button)
	end

	local function add_nil(table_,row,item) -- вспомогательная функция, забивает указанную строку пустыми данными
		local link = Hagakure:GetItemLink(item)
		table_:SetValue(1,row,row)
		table_:SetValue(2,row,link)
		local spec, bid  = Hagakure:GetMaxBidSpec(Hagakure.ItemContainer[item])
		table_:SetValue(3,row,Hagakure.ItemContainer[item].min_bid)
		table_:SetValue(4,row,Hagakure.ItemContainer[item].max_bid)
		table_:SetValue(5,row,Hagakure:GetSpec(spec))
		table_:SetValue(6,row,bid)
		table_:SetValue(7,row,L["no pretendents"])
		
		-- Забиваем подсказки
		table_:SetToolTip(1,row,"HyperLink",link)
		table_:SetToolTip(2,row,"HyperLink",link)
		table_:SetToolTip(3,row,"Text",string.format(L["min bid is %s"],link))
		table_:SetToolTip(4,row,"Text",string.format(L["max bid is %s"],link))
		table_:SetToolTip(5,row,"Text",L["random error"])
		table_:SetToolTip(6,row,"Text",L["random error"])
		table_:SetToolTip(7,row,"Text",L["random error"])
		
		-- Назначаем обработчик кликов
		for i=1,7 do table_:SetScript(i,row,buttOnClick) end
		table_:SetScript(2,row,clickItem)
	end

	local function on_close()
		if Hagakure.newTrade then 
			Hagakure.newTrade:Hide()
			Hagakure.newTrade=nil
			Hagakure.trade_table=nil 
			Hagakure.Litems=nil
		end
	end

	local function updateNewTradeWindow(method,item) -- запуск обновления уже юзерского окна по событию method = "update" "delete"
		if Hagakure.newTrade then
			-- Для начала разруливаем какой вид обновления запущен
			local table_=Hagakure.trade_table
			
			-- мы закрываем какую-то шмотку и ее надо удалить
			if method=="delete" and item then
				--Hagakure:Print("We are realy here")
				local id_=0
				for i,item_ in pairs(Hagakure.Litems) do if item_==item then id_=i end end
				if id_>0 then table_:DeleteRow(id_) end
				
				-- Теперь надо перенумеровать Litems
				local columns,rows=table_:GetSize()
				if columns==0 or rows==0 then
					on_close()
					return false
				end
				
				Hagakure.Litems={}
				for i=1, rows do
					Hagakure.Litems[i]=Hagakure:GetItemID(table_:GetValue(2,i))
					table_:SetValue(1,i,i)
				end
				
				
				-- И переопределить метод OnClick
				for i=1, columns do for j=1, rows do table_:SetScript(i,j,buttOnClick) end end

				-- И переделать размер
				table_:SetMaxSize(true,true)
				--Hagakure:Print(table_:GetValue(9,1))
			end
				
			-- мы обновляем шмотку просто обновить тултипы 
			if method=="update" and item then
				local text=Hagakure:PrintLabel(item)
				local id_=0
				local ic = Hagakure.ItemContainer[item]
				for i,item_ in pairs(Hagakure.Litems) do if item_==item then id_=i end end
				table_:SetToolTip(5,id_,"Text",text)
				table_:SetToolTip(6,id_,"Text",text)

				local spec, bid = Hagakure:GetMaxBidSpec(ic)
				table_:SetValue(5,id_,Hagakure:GetSpec(spec))
				table_:SetValue(6,id_,bid)
				
				-- Теперь нам надо подсказку
				table_:SetToolTip(7,id_,"Text",L["tooltip: click to show tooltip"])
				
				-- И вычисляем претендента!
				local pl = L["no pretendents"]
				local find = false
				for _,player in pairs(ic.players) do
					if player.bid == bid and player.spec == spec and bid>0 then
						if not find then pl=player.name; find=true else pl=L["more then one player"] end
					end
				end
				table_:SetValue(7,id_,pl)
			end
			
			-- Теперь вариант новой шмотки
			if method=="newitem" then
				local cols,rows=table_:GetSize()
				table_:SetSize(cols,rows+1)
				table_:SetMaxSize(true,true)
				add_nil(table_,rows+1,item)
				Hagakure.Litems[rows+1]=item
				updateNewTradeWindow("update",item)
				Hagakure.newTrade:Show()
			end  --if method==
		end -- if Hagakure:IsInRaid()
	end

	--[[ Формат вывода данных
		1 поле - номер шмотки по порядку - подсказка шмотка
		2 поле - название шмотки - подсказка шмота
		3 поле - статус (объявлена или нет)
		4 поле - мин ставка
		5 поле - макс ставка
		6 поле - текущий спек шмотки - подсказка всплывающее окошко с претендентами
		7 поле - текущая ставка на шмотку - 
		8 поле - текущий претендент на шмотку (либо [list] если дошло до макс ставки)
		9 поле - функциональная кнопка
	]]
	local function createNewTradeWindow() 
		local frame=AceGUI:Create("HFrame")
		local conf=Hagakure.db.profile.newTrade
		frame:SetTitle(L["new trade title"])
		frame:SetLayout("Fill")
		frame:SetWidth(conf.frame_w)
		frame:SetHeight(conf.frame_h)
		frame:SetPoint(conf.pos, conf.x, conf.y)
		--frame:OnClose(on_close)

		local scc = AceGUI:Create("SimpleGroup")
		local scroll = AceGUI:Create("ScrollFrame")
		scc:SetFullWidth(true)
		scc:SetFullHeight(true) -- probably?
		scc:SetLayout("Fill")
		
		scroll:SetLayout("Flow")
		
		frame:AddChild(scc)
		scc:AddChild(scroll)
		
		-- Первое - создаем локальную базу шмоток, чтобы потом было что забивать
		local count = 0
		for _,_ in next, Hagakure.ItemContainer do count = count+1 end
		
		if count==0 then frame:Hide();frame=nil; return nil, nil end
		-- и так. у нас есть заготовка, теперь создаем таблицу,
		-- забиваем в нее данные, делаем линки и тд
		local table_=AceGUI:Create("CTable")
		table_:SetDefaultSize(Hagakure.db.profile.admin.column,Hagakure.db.profile.admin.row)
		table_:SetSize(7,count)
		table_:SetCellSize(1,1,conf.col[1],conf.row)
		table_:SetCellSize(2,1,conf.col[2],conf.row)
		table_:SetCellSize(3,1,conf.col[3],conf.row)
		table_:SetCellSize(4,1,conf.col[4],conf.row)
		table_:SetCellSize(5,1,conf.col[5],conf.row)
		table_:SetCellSize(6,1,conf.col[6],conf.row)
		table_:SetCellSize(7,1,conf.col[7],conf.row)
		table_:SetMaxSize(true,true)
		scroll:AddChild(table_)
		
		count=1
		Hagakure.Litems={}
		for item,_ in pairs(Hagakure.ItemContainer) do
			-- Забиваем начальные значения
			add_nil(table_,count,item)
			
			-- Забиваем таблицу для обработчика кликов
			Hagakure.Litems[count]=item
			count=count+1
		end
		
		
		return frame, table_
	end

	function Hagakure:NewTrade(item)
		-- мы запускаем ее по факту добавления новой шмотки, либо обновления
		if not Hagakure.db.char.newTrade then return false end
		--if item then self:Printf(item) end
		
		local create_new=false
		local find=false
		
		if Hagakure.newTrade==nil then 
			create_new=true
		else
			for v,_ in pairs(Hagakure.ItemContainer) do
				local find2=false
				for _,k in pairs(Hagakure.Litems) do
					if k==v then find2=true end
				end
				if not find2 then find=true;item=v end
			end
		end
		
		if create_new then
			if Hagakure.newTrade~=nil then on_close() end
			Hagakure.newTrade,Hagakure.trade_table=createNewTradeWindow()
			for item,_ in pairs(Hagakure.ItemContainer) do updateNewTradeWindow("update",item) end
		else
			-- Либо это удаленая шмотка
			-- либо обновленная шмотка
			local method="update"
			for _,k in pairs(Hagakure.Litems) do
				local find2=false
				for v,_ in pairs(Hagakure.ItemContainer) do
					if k==v then find2=true end
				end
				if not find2 then method="delete";item=k end
			end
			if find then method="newitem" end
			updateNewTradeWindow(method,item)
		end
	end
end

function Hagakure:SendAddonMessage(...)
	local method,message,user = ...
	
	do -- подделываем необходимые операции
		if method == "AnswerVersionRequest" then
			message=Hagakure:Serialize("version",Hagakure.version)
		end
		
		if method == "RequestVersion" then
			Hagakure:Print(L["Sending request version check"])
			message=Hagakure:Serialize("RequestVersion",Hagakure.version)
		end
		
		if method == "RequestSynhronization" then
			message=Hagakure:Serialize("RequestSynhronization")
		end
		
		if method == "RequestItems" then
			message = Hagakure:Serialize("RequestItems")
			user = Hagakure:LootMaster()
		end
		
		if method == "updateItem" then
			message=Hagakure:Serialize("updateItem",message)
			user = Hagakure:LootMaster()
		end
		
		--[[
		if method == "updateItemRaid" then
			message = Hagakure:Serialize("updateItem",message)
		end
		]]
		
		if method == "closeItem" then
			message=Hagakure:Serialize("closeItem", message)
		end
		
		if method == "RequestDKPArray" then
			message=Hagakure:Serialize("RequestDKPArray")
		end
	end
	
	-- self:Print("send " .. message)
	
	if user then
		Hagakure:SendCommMessage(Hagakure.db.profile.prefix,message,"WHISPER",user)
	else
		Hagakure:SendCommMessage(Hagakure.db.profile.prefix,message,"RAID")
	end
end

function Hagakure:our_name()
	return UnitName("player")
end



















