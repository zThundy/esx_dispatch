ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

RegisterServerEvent('dispatch:svNotify')
AddEventHandler('dispatch:svNotify', function(data)
    local xPlayer

    for _, v in pairs(ESX.GetPlayers()) do
        xPlayer = ESX.GetPlayerFromId(v)

        if Config.ReceivingMessagesJob[xPlayer.job.name] then
            TriggerClientEvent('dispatch:clNotify', v, data)
        end
    end
end)