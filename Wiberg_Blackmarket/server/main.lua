ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


--Events
RegisterServerEvent("Wiberg_Blackmarket:ModelQuantityUpdate:Server")
AddEventHandler("Wiberg_Blackmarket:ModelQuantityUpdate:Server", function(_Model)
  local _source = source
  MySQL.Async.fetchAll("SELECT Quantity FROM wiberg_Blackmarket WHERE Model=@Model", {["@Model"] = _Model}, 
    function(result) 
        if result ~= nil then
            local Quant = tonumber(result[1].Quantity) - 1
            local sdf = MySQL.Sync.execute("UPDATE wiberg_Blackmarket SET Quantity=@Quantity WHERE Model=@Model", {['@Quantity'] = Quant, ["@Model"] = _Model})
        end
	end)
end)

RegisterServerEvent("Wiberg_Blackmarket:MoneyAddRemove:Server")
AddEventHandler("Wiberg_Blackmarket:MoneyAddRemove:Server", function(_Money, _Add)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
    if _Add then
        xPlayer.addMoney(_Money)
    else
        xPlayer.removeMoney(_Money)
    end
end)

RegisterServerEvent("Wiberg_Blackmarket:SellVehicle:Server")
AddEventHandler("Wiberg_Blackmarket:SellVehicle:Server", function(_Model, _Location)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll("SELECT Price,Quantity FROM wiberg_Blackmarket WHERE Model=@Model", {["@Model"] = _Model}, 
    function(result) 
        if result ~= nil then
            local Quant = tonumber(result[1].Quantity) + 1
            local Price = result[1].Price * Config.VehicleSellProcent * 0.01
            local sdf = MySQL.Sync.execute("UPDATE wiberg_Blackmarket SET Quantity=@Quantity WHERE Model=@Model", {['@Quantity'] = Quant, ["@Model"] = _Model})
            xPlayer.addMoney(Price)
            TriggerClientEvent('esx:showAdvancedNotification', _source, Config.TitleServer, _Location["Ped"]["Name"], Config.Locale["SellVehicle"]["VehicleSold"] .. " ~g~" .. Price, 'CHAR_MP_FM_CONTACT', 1)
        end
    end)
end)

--Callbacks
ESX.RegisterServerCallback("Wiberg_Blackmarket:GetVehicles",function(source, cb)
	local source = source
	MySQL.Async.fetchAll("SELECT Model,Price,Quantity FROM wiberg_Blackmarket", nil, 
    function(result) 
        local Vehicles = {}
		if result ~= nil then
            for i=1, #result do
                table.insert(Vehicles, {Model = result[i].Model, Price = result[i].Price, Quantity = result[i].Quantity})
            end
        end
        cb(Vehicles)
	end)
end)

ESX.RegisterServerCallback("Wiberg_Blackmarket:GetQuantityModel",function(source, cb, _Model)
    local source = source
	MySQL.Async.fetchAll("SELECT * FROM wiberg_Blackmarket WHERE Model=@Model", {["@Model"] = _Model}, 
    function(result) 
        if result ~= nil then
            cb(tonumber(result[1].Quantity))
        end
	end)
end)

ESX.RegisterServerCallback("Wiberg_Blackmarket:GetModels",function(source, cb)
	local source = source
	MySQL.Async.fetchAll("SELECT Model FROM wiberg_Blackmarket", nil, 
    function(result) 
        local Models = {}
		if result ~= nil then
            for i=1, #result do
                if not ValueExistTable(Models, result[i].Model) then
                    table.insert(Models, result[i].Model)
                end
            end
        end
        cb(Models)
	end)
end)

function ValueExistTable(_Table, _Value)
    for i=1, #_Table do 
        if _Value  == _Table[i] then
            return true
        end
    end
    return false
end

