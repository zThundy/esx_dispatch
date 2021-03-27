ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('dispatch:svNotify')
AddEventHandler('dispatch:svNotify', function(data)
    local jobPlayers = ESX.GetPlayersWithJob("police")

    for _, v in pairs(jobPlayers) do
        TriggerClientEvent('dispatch:clNotify', v, data)
    end
end)