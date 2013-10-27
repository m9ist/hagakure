if not Hagakure then return end
local AceGUI = LibStub("AceGUI-3.0")
local item = "\124cff0070dd\124Hitem:57925:4091:0:0:0:0:0:0:85:167:0\124h[Щит тумана]\124h\124r"

local L = {}
setmetatable(L,{
	__index =  function (table_,key)
		return key
	end,
})

local function buttOnClick(...) -- обработчик нажатия кнопки
	local i,j,button=...
	--Hagakure:Print(i, j, button)
end

local function clickItem(...)
	local i,j,button = ...
	local link = item
	SetItemRef(link,link,button)
end

local function add_nil(table_,row) -- вспомогательная функция, забивает указанную строку пустыми данными
	local link = item
	table_:SetValue(1,row,row)
	table_:SetValue(2,row,link)
	local spec, bid  = 2, 15
	table_:SetValue(3,row,10)
	table_:SetValue(4,row,60)
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

function Hagakure:TestCTable()
	local frame = AceGUI:Create("HFrame")
	local conf = Hagakure.db.profile.newTrade
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
	local count = 5
	-- for _,_ in next, Hagakure.ItemContainer do count = count+1 end
	
	-- if count==0 then frame:Hide();frame=nil; return nil, nil end
	-- и так. у нас есть заготовка, теперь создаем таблицу,
	-- забиваем в нее данные, делаем линки и тд
	local table_ = AceGUI:Create("CTable")
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
	
	for i = 1, count do add_nil(table_, i) end
	--Hagakure:Print("new line")
	table_:SetSize(7,count+10)
	table_:SetSize(7,count+1)
	table_:DeleteRow(count-1)
	--table_:SetSize(7,count)
end




















