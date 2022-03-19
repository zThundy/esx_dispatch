ESX = nil

local disableNotifications = false
local blips = {}
local cachedBlips = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
	Citizen.Wait(100)
    end

    while ESX.GetPlayerData().job == nil do Citizen.Wait(500) end
    ESX.PlayerData = ESX.GetPlayerData()

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
    if data.priority == 1 then
        TriggerEvent("InteractSound_CL:PlayOnOne", "10-1315", 0.6)

        if data.blipname then
            CreateBlip(data)
        end
    end

    if data.priority == 2 then
        TriggerEvent("InteractSound_CL:PlayOnOne", "10-1314", 0.6)
        
        if data.blipname then
            CreateBlip(data)
        end
    end

    if data.priority == 3 then
        TriggerEvent("InteractSound_CL:PlayOnOne", "10-1315", 0.6)
        
        if data.blipname then
            CreateBlip(data)
        end
    end

    if not disableNotifications then
        SendNUIMessage({
            type = "addNewNotification",
            notification = data
        })
    end
end)

----------------------------------------
-------------- KEYMAPPING --------------
----------------------------------------

RegisterKeyMapping("opendispatch", "Open Dispatch UI", 'keyboard', "F9")
RegisterCommand("opendispatch", function()
    if not showDispatchLog and (Config.EnableWhitelistedJobs and Config.WhitelistedJobs[ESX.PlayerData.job.name] or true) then
        showDispatchLog = true
        -- SetPauseMenuActive(not showDispatchLog)
        SetNuiFocus(showDispatchLog, showDispatchLog)
        SetNuiFocusKeepInput(showDispatchLog)

        SendNUIMessage({ type = "showOldNotifications", show = showDispatchLog })
        StartLoopThread()
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
            DisableControlAction(0, 200, true)
            DisableControlAction(0, 177, true)
            DisableControlAction(0, 202, true)
            DisableControlAction(0, 322, true)

            if IsDisabledControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 194) then
                if showDispatchLog then
                    showDispatchLog = false
                    -- SetPauseMenuActive(not showDispatchLog)
                    SetNuiFocus(showDispatchLog, showDispatchLog)
                    SetNuiFocusKeepInput(showDispatchLog)

                    SendNUIMessage({ type = "showOldNotifications", show = showDispatchLog })
                end
            end
				
	    if not showDispatchLog then
		return
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

    table.insert(cachedBlips, blips[data.id])

    Citizen.CreateThreadNow(function()
        local storedId = data.id
        Citizen.Wait(data.fadeOut * 1000)

        RemoveBlip(blips[storedId])
    end)
end

-------------------------------------
----------- NUI CALLBACKS -----------
-------------------------------------

RegisterNUICallback('setGPSPosition', function(data, cb)
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
    cb("ok")
end)

RegisterNUICallback('clearNotifications', function(data, cb)
    for _, blip in pairs(cachedBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    cachedBlips = {}

    cb("ok")
end)
