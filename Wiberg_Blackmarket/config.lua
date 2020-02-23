Config        = {}
Config.TitleServer = "Kungastaden"

Config.VehicleSellProcent = 10

Config.Locale = {
	["BuyVehicle"] = {
		["Title"] = "Är du säker på att köpa en stulen bil",
		["Yes"] = "Ja",
		["Cancel"] = "Avbryt",
		["Price"] = "Pris",
		["Amount"] = "Antal",
		["CarModel"] = "Bil model",
		["EnoughMoney"] = "Du köpte precis en bil",
		["NotEnoughMoney"] = "Du har inte ~r~tillräckligt~s~ med pengar",
		["NotInStock"] = "Det är inte ~r~tillräckligt~s~ med bilar i lager",
		["CashCost"] = "~g~Kostnad~s~:",
		["Model"] = "~r~Model~s~:",
		["LicensePlate"] = "~b~Regplåt~s~:",
	},
	["SellVehicle"] = {
		["AreYouSure"] = "Är du säker",
		["VehicleSold"] = "Du sålde bilen för",
		["Yes"] = "Ja",
		["No"] = "Nej",
		["NotValidModel"] = "Den här bil modelen går tyvärr inte att sälja",
	},
}

Config.Locations = {
	
	[1] = {
	
		['Start'] = {
			["Pos"] = vector3(-271.24, 6072.2, 31.48), --Start location for talking with ped
			["Text"] = "Prata", --Marker text 
			["ChattingHeading"] = 346.60592651367, --Heading while chatting
		},

		['Selling'] = {
			["Pos"] = vector3(-261.4, 6061.96, 31.6), --selling location for talking with ped
			["Text"] = "Sälj", --Marker text 
		},

		["Ped"] = {
			["Pos"] = vector3(-271.48, 6074.24, 31.68) , -- Ped coords
			["Heading"] = 182.19540405273, -- Ped heading
			["Model"] = 0x8CDCC057, -- Ped model
			['Name'] = "Dastan",
		},

		["Car"] = {
			["Pos"] = vector3(-266.76, 6067.44, 31.48),
			["Heading"] = 119.70356750488,
		},

		["Scale"] = 1.0,

		["Color"] = {['r'] = 255, ['g'] = 0, ['b'] = 0},
		
	}

}

