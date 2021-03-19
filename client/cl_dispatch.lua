ESX = nil

local disableNotifications = false
local blips = {}

Citizen.CreateThread(function()
	while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
		Citizen.Wait(100)
	end

    SendNUIMessage({
        type = "sendResourceName",
        resource = GetCurrentResourceName()
    })
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer) ESX.PlayerData = xPlayer end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job) ESX.PlayerData.job = job end)


----------------------------------
----------- MAIN EVENT -----------
----------------------------------

RegisterNetEvent('dispatch:clNotify')
AddEventHandler('dispatch:clNotify', function(data)
    data.priority = tonumber(data.priority)

    if not disableNotifications then
        if data.priority == 1 then
            if Config.PlaySound then
                TriggerEvent("InteractSound_CL:PlayOnOne", "10-1315", 0.6)
            end
    
            if Config.ShowDispatchBlip then
                CreateBlip(data)
            end
        end
    
        if data.priority == 2 then
            if Config.PlaySound then
                TriggerEvent("InteractSound_CL:PlayOnOne", "10-1314", 0.6)
            end
            
            if Config.ShowDispatchBlip then
                CreateBlip(data)
            end
        end

        SendNUIMessage({
            type = "addNewNotification",
            notification = data
        })
    end
end)

----------------------------------------
----------- SHOW LIST THREAD -----------
----------------------------------------

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do Citizen.Wait(1000) end
    ESX.PlayerData = ESX.GetPlayerData()
    
    while true do
        Citizen.Wait(0)

        if IsControlJustReleased(0, 256) and ESX.PlayerData.job.name == 'police' then
            if not showDispatchLog then
                showDispatchLog = true
                SetNuiFocus(showDispatchLog, showDispatchLog)
                SetNuiFocusKeepInput(showDispatchLog)

                SendNUIMessage({ type = "showOldNotifications", show = showDispatchLog })
                StartLoopThread()
            else
                Citizen.Wait(1000)
            end
        end
    end
end)

---------------------------------
----------- FUNCTIONS -----------
---------------------------------

function StartLoopThread()
    Citizen.CreateThread(function()
        while showDispatchLog do
            DisableAllControlActions(0)
            DisableAllControlActions(1)
            DisableAllControlActions(2)
            DisablePlayerFiring(GetPlayerPed(-1), true) -- Disable weapon firing
            
            if IsControlJustReleased(0, 200) or IsDisabledControlJustReleased(0, 200) then
                if showDispatchLog then
                    showDispatchLog = false
                    SetNuiFocus(showDispatchLog, showDispatchLog)
                    SetNuiFocusKeepInput(showDispatchLog)

                    SendNUIMessage({ type = "showOldNotifications", show = showDispatchLog })
                end
            end

            Citizen.Wait(0)
        end
    end)
end

function CreateBlip(data)
    blips[data.id] = AddBlipForCoord(data.position.x, data.position.y, data.position.z)

    SetBlipSprite(blips[data.id], data.sprite)
    SetBlipColour(blips[data.id], data.color)
    SetBlipScale(blips[data.id], 1.2)
    SetBlipAlpha(blips[data.id], 200)
       
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.blipname)
    EndTextCommandSetBlipName(blips[data.id])

    Citizen.CreateThreadNow(function()
        local storedId = data.id
        Citizen.Wait(data.fadeOut * 1000)

        RemoveBlip(blips[storedId])
    end)
end

function GetStreetAndZone()
	local plyPos = GetEntityCoords(PlayerPedId(), true)
	local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
	local street1 = GetStreetNameFromHashKey(s1)
	local street2 = GetStreetNameFromHashKey(s2)
	local zone = GetLabelText(GetNameOfZone(plyPos.x, plyPos.y, plyPos.z))
	local street = street1 .. ", " .. zone
	return street
end

function randomId()
    math.randomseed(GetCloudTimeAsInt())
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-------------------------------------
----------- NUI CALLBACKS -----------
-------------------------------------

RegisterNUICallback('setGPSPosition', function(data, cb)
    -- print(json.encode(data))
    SetNewWaypoint(data.position.x, data.position.y)
    cb("ok")
end)

RegisterNUICallback('close', function(data, cb)
    showDispatchLog = false
    SetNuiFocus(showDispatchLog, showDispatchLog)
    SetNuiFocusKeepInput(showDispatchLog)
    cb("ok")
end)

RegisterNUICallback('disableNotifications', function(data, cb)
    disableNotifications = not disableNotifications
    if disableNotifications then
        ESX.ShowNotification("~g~Dispatches are now enabled")
    else
        ESX.ShowNotification("~r~Dispatches are now disabled")
    end
    cb("ok")
end)

RegisterNUICallback('clearNotifications', function(data, cb)
    for _, blip in pairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}

    cb("ok")
end)

--------------------------------
----------- COMMANDS -----------
--------------------------------

RegisterCommand("dispatch", function(source, args)
    local priority = args[1]
    local message = ""
    for i = 2, #args do
        message = message .. " " .. args[i]
    end

    local coords = GetEntityCoords(GetPlayerPed(-1))

    local dispatch = {
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
        officer = "Test officername"
    }

    TriggerServerEvent("dispatch:svNotify", dispatch)
end)