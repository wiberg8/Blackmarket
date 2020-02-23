ESX = nil

cached = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
		PlayerData = ESX.GetPlayerData()
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  	PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  	PlayerData.job = job
end)

Citizen.CreateThread(function()
	Wait(500)
	while true do
		local Ped=GetPlayerPed(-1)
		local PedCoords=GetEntityCoords(Ped)
		f.ScreenFadeOut()
		local sleep = 500
		for index, value in pairs(Config.Locations) do
			
			local DstCheck = GetDistanceBetweenCoords(PedCoords, value['Start']['Pos'])
			if DstCheck < 6 then
				sleep = 5
				local MarkerText = "~r~".. value['Start']['Text'] .. " ~y~" .. value['Ped']['Name']
				if DstCheck < 1.5 then 
					MarkerText = "[~g~E~s~]" .. value['Start']['Text'] .. " ~y~" .. value['Ped']['Name']
					if IsControlJustPressed(0, 38) then
						f.StartChatting(value)
					end
				end 
				f.DrawMarker(value['Start']['Pos'], MarkerText, value['Scale'], value['Color'])
			end
			if IsPedInAnyVehicle(Ped, 0) then
				local Dst = GetDistanceBetweenCoords(PedCoords, value['Selling']['Pos'])
				if Dst < 15 then
					sleep = 5
					local MarkerText = "~r~".. value['Selling']['Text']
					if Dst < 5 then
						MarkerText = "[~g~E~s~]" .. value['Selling']['Text']
						if IsControlJustPressed(0, 38) then
							f.CarSellMenu(value, GetEntityModel(GetVehiclePedIsIn(Ped, 0)))
						end
						DrawMarker(20,  value['Selling']['Pos'] + vector3(0.00, 0.00, 1.5), 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200, true, false, 2, true, false, false, false)
					end
					f.DrawMarker(value['Selling']['Pos'], MarkerText, 3.0, value['Color'])
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread(function() --Create ped. set properties
		cached['MissionPed'] = {} --Table of all ped index via int
		for i=1, #Config.Locations do
			local PedCfg = Config.Locations[i]["Ped"] --Variabel it hols all values for the specific indexed location
			
			--Loads the model
			while not HasModelLoaded(PedCfg["Model"]) do
				RequestModel(PedCfg["Model"])
				Citizen.Wait(10)
			end
			
			cached["MissionPed"][i] = CreatePed(5, PedCfg["Model"], PedCfg["Pos"], PedCfg["Heading"], false) --Spawn ped assigns to indexed pos table
		
			SetEntityAsMissionEntity(cached["MissionPed"][i], true, true) --Prevent de spawning

			--Set ped props
			SetPedCombatAttributes(cached["MissionPed"][i], 46, true)                     
			SetPedFleeAttributes(cached["MissionPed"][i], 0, 0)                      
			SetBlockingOfNonTemporaryEvents(cached["MissionPed"][i], true)
		end
end)

