local addon_name="Hagakure"

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale(addon_name, "ruRU")
if not L then return end

--[[
	Чистая секция, проверенная и пересортированная
]]

do -- chat_commands +++--- Hagakure:Getwisper(...)
	do -- Hagakure:GetAddonHelp()
		do -- for all
			L.COMMAND_INTO="|c0000ff00Возможности /hagakure:|r"
			L.COMMAND_HELP="  Справка по командам."
			L.COMMAND_TRADE_ITEMS="Показать закрытые мной окна.|r"
			L.COMMAND_MINIMAP="Введите это для активации/деактивации кнопки миникарты."
			L.COMMAND_TRADE_RESET="Введите это для сброса оконо (удаление всех окон из памяти)."
			L.COMMAND_STATUS="Показать статус текущего аукциона."
			L.COMMAND_LOOT_MASTER_INTERFACE="Включить/выключить флаг для интерфейсов лут мастера."
			L.COMMAND_CHECK_VERSION="Проверить рейд на версию аддона."
			L.COMMAND_SHOW_VERSION="Показать запомненные версии аддона в рейде."
			L.COMMAND_CLEAR_VERSION="Очистить запомненные версии аддона в рейде."
		end
		
		do -- for RL
			L.COMMAND_LOOT_MASTER="|c00ff0000Функции для лут мастера.|r"
			
			L.COMMAND_ANNOUNCE="Объявить аукцион на вещь (установленные расценки мин-макс %d-%d)."
			L.COMMAND_CLOSE="Закрыть аукцион на вещь."
			L.COMMAND_AWARD=" Отдать вещь данному игроку за текущую ставку."
			L.COMMAND_CLOSE_ALL="Закрыть все активные аукционы."
			L.COMMAND_CANCEL="Отменить аукцион на данную вещь. (без аргументов отменит все аукционы, будьте внимательнее!)"
			
			L.COMMAND_LOGGING="Включить/выключить ведение журнала событий."
			
			L.COMMAND_DKP_SET="Установка текущего ДКП пула."
			L.COMMAND_DKP_POOL="Возвращает текущий ДКП пул."
			L.COMMAND_LEADER_RAID="Показать дкп участников рейда."
			L.COMMAND_LIST=" Список участников из текущего DKP пула"

			L.COMMAND_ALTS="Показать список альтов."
			L.COMMAND_ALTS_ADD="Добавить новые данные в массив альтов."
			L.COMMAND_ALTS_DELETE="Удалить альта из списка."
			
			L.COMMAND_ADJ="Сделать поправку в DKP базе, если причина больше одного слова используйте скобки \"\""
			L.COMMAND_ADJ_CLEAR="Очистить все текущие настройки."

			L.COMMAND_LOG="Запрос журнала операций."
			L.COMMAND_LOG_CLEAR="Очистить журнал."
			L.COMMAND_PARCED_LOG="Открыть графический лог."
		end
	end
	do -- HagakureDS:OnEnter()
		L.MENU_HELP_LINE1="Хагакурэ"
		L.MENU_HELP_LINE2="Аддон для помощи лидеру рейда в распределении добычи."
		L["Right click to open menu"]="Правая кнопка открывает выпадающее меню."
		L["Middle click to open options"]="Средняя кнопка открывает опции аддона."
	end
	do -- Hagakure:TurnOnoffMinimap(...)
		L.COMMAND_MINIMAP_ENABLED="Миникарта включена!"
		L.COMMAND_MINIMAP_DISABLED="Миникарта отключена!"
	end
	do -- Hagakure:TurnOnoffLootmaster()
		L.COMMAND_RAID_MEMBER="Теперь Вы обычный участник рейда"
		L.COMMAND_LOOT_MASTER_NOW="Теперь Вы можете использовать интерфейс лут мастера, если Вы лут мастер в рейде."
	end
	do -- Hagakure:TurnOnoffLogging()
		L.COMMAND_LOG_OFF="Остановлена запись событий в журнал."
		L.COMMAND_LOG_ON="Начата запись событий в журнал."
	end
	do -- Hagakure:ShowVersion()
		L["Your current version is %s."]="Ваша текущая версия аддона - %s."
	end
	do -- Hagakure:ShowAddonVersions()
		L["  %s %s%s|r %s"]="  %s %s%s|r %s"
		L.COMMAND_VERSION_LIST="Текущие версии аддона"
	end
	do -- Hagakure:DeleteAddonVersions()
		L.COMMAND_VERSION_DELETED="  Список версий удалён!"
	end
	do -- Hagakure:PrintItemsStatus(...) ++++--  Hagakure:Getwisper(...)
		L.PRINT_STATUS_OUT1="Вещь %s диапазон %d-%d текущая максимальная ставка %d для спека %s"
		L.PRINT_STATUS_OUT2="      %s%s %s (%d) спек %s ставка %d %s%s"
		L["There are no auctions"]="Нет объявленных аукционов." --  Hagakure:Getwisper(...)
	end
	do -- Hagakure:OpenMenu(...)
		L["Hagakure menu"]="Меню Хагакурэ"
		L["Show current items"]="Показать текущие вещи"
		L["Show new trade window"]="Показать дополнительное окно торгов"
		L["Version"]="Текущая версия"
		L["Toggle minimap icon"]="Убрать иконку на миникарте"
		-- L["Turn on new trade window"]="Включить дополнительное окно торгов"
		
		L["RESET WINDOWS"]="Сбросить окна (Осторожно с этой опцией!)"
		L["You realy wanna reset windows?"]="Уверены в сбросе окон (активные аукционы закроются)?"
		L["Request again items"]="Запросить заново текущие вещи"
		L["Allert request items"]="Если вы уже получали оповещение об аукционах, используйте \"Показать текущие вещи\"! Уверены что хотите выполнить эту операцию?"
		
		L["/hcd symbiosys"] = "Симбиоз"
		L["/hcd config"] = "Конфигурация Hagakure cooldowns"
		
		do -- ML section
			L["Adjustment"]="Поправка"
			L["Copy log"]="Скопировать журнал"
			L["Copy adj"]="Скопировать поправки"
			L["Synhronize"]="Синхронизироваться!"
			L["Parced log"]="Проаналлизированный лог"
		end
		
		do -- ML in raid section
			L["run version check"]="Запустить тест версий рейда"
			L["show addon versions"]="Показать версии аддона"
			L["actions with auctions"]="Действия с аукционом"
			
			L["cancel all auctions"]="Отменить текущие аукционы"
			L["close all auctions"]="Закрыть текущие аукционы"
			L["current auctions"]="Текущие аукционы"
			
			L["close auction"]="Закрыть аукцион"
			L["cancel auction"]="Отменить аукцион"
			L["award item"]="Отдать вещь"
		end
	end
	do -- Hagakure:ResetTradesWindows(...)
		L.COMMAND_RESET_WINDOWS = "Сброс текущих окон"
	end
end

do -- func  +++--- Hagakure.Admin:WriteLog(...)
	do -- Hagakure:Wisp(...)
		L["%s /w %s !help for information"]="%s  /w %s !help для информации."
	end
	do -- Hagakure:GetSpec(...)
		L["spec pass"]="отказ"
		L["spec greed"]="не откажусь"
		L["spec off"]="второй спек"
		L["spec main"]="главный спек"
		L["spec undeff"]="спек неопределен"
	end
	do -- Hagakure:GetDKPLog(...)
		L["All adj"]="Все поправки DKP:"
		L["Adj for %s"]="Поправки DKP для %s:"
	end
	do -- Hagakure:GetLastRoll(...)  ----++++---- Hagakure.Admin:WriteLog(...)
		L["loot"]="лут" --- Hagakure.Admin:WriteLog(...)
		L["wrong roll"]="Ложный ролл"
	end
	do -- Hagakure:PrintLabel(...)
		L["%s (%d)   %s  "]="%s (%d)   %s  "
		L["no bid"]=" нет ставки"
	end
	do -- Hagakure:UpdateMessages(...)
		L["%s%s|c<color code>%s:|r %s"]="%s%s|cff00ff00%s:|r %s"
	end
	do -- Hagakure:TradeWindow(...)
		L["%s %d-%d"]="%s %d-%d"
		L["Auctions for %s."]="Аукцион на %s."
		L["Ask RL to check addon versions"]="Вы не можете читать этот текст! (нет правда, не можете [если вы все еще думаете что можете, то попросите РЛа проверить версию аддона и запросите вещи заново])"
		L["Announce bid"]="Оповестить!"
	end
	do -- New Trade window section   ++++--- updateNewTradeWindow(...)
		do -- add_nil(...)
			L["no pretendents"]="нет претендентов" -- updateNewTradeWindow(...)
			L["min bid is %s"]="Минимальная ставка на %s."
			L["max bid is %s"]="Максимальная ставка на %s."
			L["random error"]="Вы вряд ли это прочитаете, но если это случилось доведите до разработчика аддона"
		end
		do -- updateNewTradeWindow(...)
			L["tooltip: click to show tooltip"]="Кликни по второй колонке\nчтобы увидеть посказку по вещи\crtl,shift тоже работают\nКликни по остальным запустить окно торгов."
			L["more then one player"]="[больше чем один игрок]"
		end
		do -- createNewTradeWindow() 
			L["new trade title"]="Дополнительное окно торгов."
		end
	end
	do -- Hagakure:SendAddonMessage(...)
		L["Sending request version check"]="Отправка запроса версии аддона."
	end
end

do -- hagakure   --++++--+++ Hagakure.Admin:WrinteLog(...)
	L.CONFIG_DEF_ADJ_REASON="За все светлое и доброе в этой жизни"
	
	do -- Hagakure:OnEnable()
		L["raid leader functions are turned off"]=" функции РЛа не включены."
		L["You should turn on hagakure_admin!"]="  |cffff0000Вам надо включить аддон hagakure_admin, чтобы загрузить функции админа! Опция \"РЛ\" отключена автоматически!|r"
		L["Admin addon loaded version %s."]="  Функции РЛа загружены, версия - %s."
		L["Bases loaded %s."]="Базы с сайта загружены %s."
		L["Addon Hagakure loaded"]="|c00bf0000Аддон Hagakure DKP успешно загружен.|r "
		L["  Found downloaded array from %s."]="  Найден скачанный с другого игрока массив DKP от %s."

		L["current dkp from %s"]="  Текущее дкп берется из событий под тэгом %s."
		L["dkp tag not setted - def %s"]="  ДКП тэг не установлен, по умолчанию установлен на %s"
	
		L["you need check versions"]="|c00bf0000Походу это первый запуск и в рейде с этим аддоном вы еще не были, не забудьте пнуть РЛа, чтобы запустил проверку версий аддона, а то останетесь не у дел (для запуска проверки версий есть конечно же команда, но вы наверняка слишком ленивы найти ее, так что проще пнуть РЛа).|r"
	
		L["Options loaded, version is %s."]="  Загружены опции для аддона Hagakure DKP, версия аддона %s."
	end
	do -- Hagakure.console:chatCommand(...)
		L["u launch /hagakure"]="Вы запустили /hagakure "
		L["enter item to announce"]="Необходимо ввести вещь для объявления! (/hagakure announce [item link])"
		L["enter item to close"]="Необходимо ввести вещь для закрытия аукциона! (/hagakure close [item link])"
	end
	do -- Hagakure:raidUpdate()   ++++--- Hagakure:catchEvent(...) Hagakure.Admin:WriteLog(...)
		L["raid"]="рейд" -- Hagakure:catchEvent(...) Hagakure.Admin:WriteLog(...)
		L["creation"]="создание"
		L["member"]="член" -- Hagakure.Admin:WriteLog(...)
	end
	do -- Hagakure:catchEvent(...)      ++++---  Hagakure.Admin:WriteLog(...)
		L["my roll is %s"]="|cff00ffffMy roll is %s!|r"
		
		L["rolled"]="выбрасывает" --  Hagakure.Admin:WriteLog(...)
		L["roster"]="ростер"
		L["enter in"]="входит в"
		L["logged in"]="входит" --  Hagakure.Admin:WriteLog(...)
		L["enter out"]="выходит"
		L["logged out"]="выходит" --  Hagakure.Admin:WriteLog(...)
		L["joined to raid"]="присоединяется к рейд"
		L["log joined"]="присоединился" --  Hagakure.Admin:WriteLog(...)
		L["desline invite"]="отклоняет приглашение в группу"
		L["log desline"]="отказ"
		L["sending invite"]="приглашается"
		L["log inv"]="инв"
		L["raid leave"]="Вы покинули р"
		L["disband"]="дизбанд"
	end
	do -- Hagakure:Getwisper(...) 
		L["no user %s in %s"]="В записях дкп таблицы нет игрока %s (%s)."
		L["u have %d in %s"]="У Вас %d DKP в %s пуле."
		L["%s has %d DKP in %s"]="Игрок %s имеет %d DKP в %s пуле."

		L.WHISPER_HELP1="Если Вы хотите узнать свое (или чужое) дкп введите /w %s !getdkp [name] (если хотите узнать свое можно пропустить аргумент name)"
		L.WHISPER_HELP2="Если вы хотите сделать ставку на вещь, сначала вы должны определить спек, для этого: /w %s !dkp need/off/greed/pass [item link] (на пример /w %s !dkp off [item])"
		L.WHISPER_HELP3="Если вы хотите просто пасануть на все вещи введите /w %s !dkp pass"
		L.WHISPER_HELP4="Чтобы сдеать ставку на интересующую Вас вещь введите /w %s !dkp bid <your bid> [item link]  (на пример /w %s !dkp bid 20 [item])"
		L.WHISPER_HELP5="Если вы хотите получить текущую информацию по ставкам по вещи введите /w %s !info [item link] (если опустите аргумент получите информацию по всем текущим торгам), ответ придет в форме:"
		L.WHISPER_HELP6="  Не опрделелились: <player> (<dkp>), Поставили: <player> (<dkp>) - <bid> [<spec> {0=pass, 1=greed, 2=off, 3=need}]"
		
		L["%s %s (%d)"]="%s %s (%d)"
		L["%s %s (%d) - %d [%d] : "]="%s %s (%d) - %d [%d] : "
		L["inactive"]="Не опрделелились: "
		L["active"]="Поставили: "

		-- need
		L.WHISPER_ERR1="Укажите вещь, которую Вы \"need\"."
		L.WHISPER_ERR2="Вещь %s не объявлена на аукцион!" --  ++-- greed pass off bid
		L.WHISPER_SUCC1="Вы заявили \"need\" на %s."
		-- greed
		L.WHISPER_ERR3="Укажите вещь, которую Вы  \"greed\"."
		L.WHISPER_SUCC2="Вы заявили \"greed\" на %s."
		-- off
		L.WHISPER_ERR4="Укажите вещь, которую Вы \"off spec\""
		L.WHISPER_SUCC3="Вы заявили \"off spec\" на %s."
		-- pass
		L.WHISPER_SUCC4="Вы отказались от всех вещей!"
		L.WHISPER_SUCC5="Вы заявили \"pass\" на %s."
		-- bid
		L.WHISPER_ERR6="Проверьте еще раз синтаксис !dkp bid команды"
		L.WHISPER_ERR5="Вы ввели запрос с неизвестным синтаксисом"  ---- ++--- not command
	end
	do -- Hagakure:LowSpeedMessage(...)
		L["random err Hagakure:LosSpeedMessage"]="random err Hagakure:LowSpeedMessage()"
		L["Some random message (can't unpack) Hagakure:LowSpeedMessage() %s"]="Some random message (can't unpack) Hagakure:LowSpeedMessage() %s"
		L["Some random message (can't deserialize) Hagakure:LowSpeedMessage() "]="Some random message (can't deserialize) Hagakure:LowSpeedMessage() "
	end
	do -- Hagakure:GetAddonMessage(...)
		L.MESSAGE_ADDON_COMM_ERR="|c00ff0000Непонятное сообщение, срочно заскринь и выложи на форум разработчику!|r \n%s"
	end
end









