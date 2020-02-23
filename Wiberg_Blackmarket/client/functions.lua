f = {}



f.SellVehicle = function()
	
end

f.StartChatting = function(_Location)
	local LocationStart = _Location['Start']
	local Ped = PlayerPedId()
	local anim_lib = "missheistdockssetup1ig_5@base"
	local anim_dict = "workers_talking_base_dockworker1"
	
	f.ScreenFadeIn() --Fades in screnn
	FreezeEntityPosition(Ped, true) --Frezzes ped pos under the chatting
	SetEntityHeading(Ped, LocationStart["ChattingHeading"])
	f.SetCoords(Ped, LocationStart['Pos'])

	f.ScreenFadeOut() --Fades outs screen
	
	--Animation
	f.RequestAnimDict(anim_lib)
	TaskPlayAnim(Ped, anim_lib, anim_dict, 3.0 , 0.5, -1, 31, 1.0, 0, 0)
	
	Citizen.Wait(6000)

	--Clear ped tasks
	ClearPedTasks(Ped)
	ClearPedSecondaryTask(Ped)

	FreezeEntityPosition(Ped, false) --Unfrezzes ped pos when they stop chatting
	f.BuyCarMenu(_Location)
end

f.AuthorizeVehicleModelForSellerLocation = function(_Model, _Location) --Exempel "comet", Config.Locations[1]['Start']
	local VehicleTable = _Location['AuthorizedVehicles']

	for k, v in VehicleTable do 
		if _Model == v['Model'] then
			return true
		end
	end

	return false
end

f.BuyCarMenu = function(_Location)
	ESX.UI.Menu.CloseAll()

	ESX.TriggerServerCallback("Wiberg_Blackmarket:GetVehicles", function(Vehicles)
		local elements = {}

		for index, value in pairs(Vehicles) do 
			local TmpModel = value["Model"]
			local TmpPrice = value["Price"]
			local TmpQuantity = value["Quantity"]
			if tonumber(value["Quantity"]) > 0 then
				table.insert(elements, {label = Config.Locale["BuyVehicle"]["CarModel"] .. ":" .. f.ToColor("Green", TmpModel) .. " | " .. Config.Locale["BuyVehicle"]["Price"] .. ":" .. f.ToColor('Green', ESX.Math.GroupDigits(TmpPrice)) ..  " | " .. Config.Locale["BuyVehicle"]["Amount"] .. ":" .. f.ToColor('Green', TmpQuantity), 
											Model = TmpModel, Price = TmpPrice, Quantity = TmpQuantity})
			end
		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'Kasda',
			{
				title    = 'Bilar',
				align    = 'center',
				elements = elements
			},
			function(data, menu)
				local Car = {}
				Car.Model = data.current.Model
				Car.Price = tonumber(data.current.Price)
				Car.Quantity = tonumber(data.current.Quantity)
				f.BuyVehicle(Car, _Location)
				menu.close()
			end,
		function(data, menu)
			menu.close()
		end)
	end)
end

f.BuyVehicle = function(_Car, _Location) --_Car table contains Model Price Quantity
	local elements = {}
	table.insert(elements, {label = Config.Locale['BuyVehicle']["Yes"], value = "yes"})
	table.insert(elements, {label = Config.Locale['BuyVehicle']["Cancel"], value = "no"})

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'Wiberg_BuyVehicle',
		{
			title    = Config.Locale["BuyVehicle"]["Title"],
			align    = 'center',
			elements = elements
		},
		function(data, menu)
			local CurrentAction = data.current.value
			if CurrentAction == "yes" then
				if f.MoneyCheck(_Car.Price) then --Does player have enough money
					ESX.TriggerServerCallback("Wiberg_Blackmarket:GetQuantityModel", function(_Quantity) --Quantity is more than 0 allow to buy car
						if _Quantity > 0 then
							--Spawns and warps ped into vehicle
							local Vehicle = f.SpawnVehicle(_Car, _Location)
							TriggerServerEvent("Wiberg_Blackmarket:MoneyAddRemove:Server", _Car.Price, false)
							f.NotifyPlayer("~r~" .. _Location["Ped"]["Name"], Config.Locale["BuyVehicle"]["EnoughMoney"] .. "\n" ..Config.Locale["BuyVehicle"]["CashCost"] .. " ~y~" .. ESX.Math.GroupDigits(_Car.Price) .. "~s~\n" .. Config.Locale["BuyVehicle"]["LicensePlate"] .. " ~y~" .. GetVehicleNumberPlateText(Vehicle) .. "~s~\n" .. Config.Locale["BuyVehicle"]["Model"] .. " ~y~" .. _Car.Model .. "~s~") --Sends notify
							TriggerServerEvent("Wiberg_Blackmarket:ModelQuantityUpdate:Server", _Car.Model)--Updates the bought model quantity with -1
						else
							f.NotifyPlayer(_Location["Ped"]["Name"], Config.Locale['NotInStock'])
						end 
					end, _Car.Model)
				else
					f.NotifyPlayer(_Location["Ped"]["Name"], Config.Locale["BuyVehicle"]['NotEnoughMoney'])
				end
			end
			menu.close()
		end,
	function(data, menu)
		menu.close()
	end)
end

f.CarSellMenu = function(_Location, _Model)
	ESX.TriggerServerCallback('Wiberg_Blackmarket:GetModels', function(_Models)
		local Correct = false
		local Vehicle_Model

		for i=1, #_Models do
			if GetHashKey(_Models[i]) == _Model then
				Correct = true
				Vehicle_Model = _Models[i]
				break
			end
		end
	
		if Correct then
			local elements = {}

			table.insert(elements, {label = Config.Locale["SellVehicle"]["Yes"], sell = true})
			table.insert(elements, {label = Config.Locale["SellVehicle"]["No"], sell = false})
			ESX.UI.Menu.Open(
				'default', GetCurrentResourceName(), 'Wiberg_BuyVehicle',
				{
					title    = Config.Locale["SellVehicle"]["AreYouSure"],
					align    = 'center',
					elements = elements
				},
				function(data, menu)
					local current = data.current

					menu.close()

					if current.sell then
						TriggerServerEvent("Wiberg_Blackmarket:SellVehicle:Server", Vehicle_Model, _Location)
						local Vehicle = GetVehiclePedIsIn(PlayerPedId(), 0)			
						TaskLeaveVehicle(PlayerPedId(), Vehicle, 0)
						Citizen.Wait(1000)
						DeleteVehicle(Vehicle)	
					end
				end,
			function(data, menu)
				menu.close()
			end)
		else
			f.NotifyPlayer(_Location["Ped"]["Name"], Config.Locale["SellVehicle"]["NotValidModel"])
		end
	end)
end




f.DrawMarker = function(_Coords, _Txt, _Scale, _Color) --Combines drawtext3d, drawmarker 
 	ESX.Game.Utils.DrawText3D(_Coords, _Txt, 0.6)
	DrawMarker(6, _Coords-vector3(0.0,0.0,0.975), 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 
				_Scale, _Scale, _Scale, _Color['r'], _Color['g'], _Color['b'], 155, 0, false, false, 0, false, false, false, false)
end

f.SpawnVehicle = function(_Car, _Location)
	RequestModel(_Car.Model)
	while not HasModelLoaded(_Car.Model) do
		Citizen.Wait(1)
	end
	local Pos = _Location["Car"]["Pos"]
	Vehicle = CreateVehicle(_Car.Model, Pos["x"], Pos["y"], Pos["z"], _Location["Car"]["Heading"], true, true)
	TaskWarpPedIntoVehicle(GetPlayerPed(-1), Vehicle, -1)
	return Vehicle
end

f.ToColor = function(_Color, _String)
	return '<span style="color:' .. _Color .. ';">' .. _String .. '</span>'
end

f.RequestAnimDict = function(_anim_lib) --Requests the specified animation libary
	RequestAnimDict(_anim_lib)
	while not HasAnimDictLoaded(_anim_lib) do
		Citizen.Wait(0)
	end
end

f.SetCoords = function(_Ped, _Vec)
	SetEntityCoords(_Ped, _Vec - vector3(0.0,0.0,0.975), false, false, false, false)
end

f.ScreenFadeIn = function() --Set screen fade in
	DoScreenFadeOut(1200)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    Wait(1500)
end

f.ScreenFadeOut = function()
	DoScreenFadeIn(1200)
end

f.NotifyPlayer = function(Titel, Msg)
  ESX.ShowAdvancedNotification(Config.TitleServer,  Titel, Msg, 'CHAR_MP_FM_CONTACT', 1)
end

f.MoneyCheck = function(money)
    local playerMoney = ESX.GetPlayerData()["money"]
	return playerMoney >= money
end