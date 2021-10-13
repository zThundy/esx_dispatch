ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

local function GetPlayersWithJob(job)
    local xPlayers = {}
    for _, source in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.job.name == job then
            table.insert(xPlayers, xPlayer.source)
        end
    end
    return xPlayers
end

RegisterServerEvent('dispatch:svNotify')
AddEventHandler('dispatch:svNotify', function(data)
    if data.job then
        if (Config.EnableWhitelistedJobs and Config.WhitelistedJobs[data.job] or true) then
            local jobPlayers = GetPlayersWithJob(data.job)
            if #jobPlayers == 0 then return end

            for _, v in pairs(jobPlayers) do
                TriggerClientEvent('dispatch:clNotify', v, data)
            end
        end
    else
        print("^1[ESX_Dispatch] ^0Error, data.job not defined")
    end
end)
