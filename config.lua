Config = {}

-- This is a list of job that will receive the dispatch
-- Message
Config.ReceivingMessagesJob = {
	["police"] = true,
	["ambulance"] = true
}

-- If se to true a blip with the data given to the called server event
-- will appear on the map
Config.ShowDispatchBlip = true
-- If true a sound will be played on dispatch created (REQUIRE InteractSounds)
Config.PlaySound = true