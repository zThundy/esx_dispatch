Config = {}

-- if enabled, the script will check and enable dispatch notifications only
-- to players that have specific jobs
Config.EnableWhitelistedJobs = true

-- this will be the list of jobs that will be able to receive
-- notifications if the above is enabled
Config.WhitelistedJobs = {
	["police"] = true,
	["ambulance"] = true
}

--[[
    INFO

    Inside the data table passed as argument in the dispatch:svNotify server event, should be included:

    @code = is just a graphic thing that will be shown on the top left corner of the notification
    @street = is a string and you can use the function written down to get it (client side obviusly)
    @id = is a random generated id. keep in mind: it must be unique
    @priority = can be 1, 2 or 3 and will show the notification in different types every time
    @position = should be a table containing the 3 axes for the blip and the position
    @blipname = will be the blip name for the blip on the map. You can also not include it to disable the blip on the map
    @color = will be the color for the blip
    @sprite = will be the sprite of the blip
    @fadeOut = will be the time needed to remove the blip from the map (in seconds)
    @duration = will be the time needed to remove the notification from the top right of the screen
    @officer = will be the name of the player calling (or whatever you want)
    @job = is the job that will allow all players with that job to receive this specific notification

    {
        code = "10-40",
        street = GetStreetAndZone(),
        id = randomId(),
        priority = priority,
        title = message,
        position = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        blipname = "Test dispatch",
        color = 2,
        sprite = 304,
        fadeOut = 30,
        duration = 10000,
        officer = "Test officername",
        job = "police"
    }
]]

--[[
	FUNCTION FOR STREETS (clientside)

	function GetStreetAndZone()
        local coords = GetEntityCoords(GetPlayerPed(-1))
        local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, coords.x, coords.y, coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
        local street1 = GetStreetNameFromHashKey(s1)
        local street2 = GetStreetNameFromHashKey(s2)
        local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
        local street = street1 .. ", " .. zone
        return street
    end
]]