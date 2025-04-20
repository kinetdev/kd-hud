ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    print('^2[KINETDEV.COM]^7 Resource started')
end)

ESX.RegisterCommand('checkplayerhud', 'admin', function(xPlayer, args, showError)
    if not args.playerId then
        args.playerId = xPlayer.source
    end
    
    local targetPlayer = ESX.GetPlayerFromId(args.playerId)
    if not targetPlayer then
        return showError('Player not found')
    end
    
    local money = targetPlayer.getAccount('money').money
    local bank = targetPlayer.getAccount('bank').money
    local black = targetPlayer.getAccount('black_money').money
    
    TriggerClientEvent('chat:addMessage', xPlayer.source, {
        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(41, 41, 41, 0.9); border-radius: 3px;"><i class="fas fa-info-circle"></i> {0}: <br>{1}</div>',
        args = {
            'Player HUD Info for ' .. targetPlayer.getName(),
            'Cash: $' .. money .. ' | Bank: $' .. bank .. ' | Dirty Money: $' .. black .. 
            ' | Job: ' .. targetPlayer.getJob().label .. ' (' .. targetPlayer.getJob().grade_label .. ')'
        }
    })
end, true, {help = 'Check player HUD information', validate = false, arguments = {
    {name = 'playerId', help = 'Player ID (optional)', type = 'number'}
}})

RegisterServerEvent('esx_playerhud:updateHUD')
AddEventHandler('esx_playerhud:updateHUD', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    TriggerClientEvent('esx_playerhud:updateHUD', source)
end)

function GetJobCounts()
    local jobCounts = {
        police = 0,
        medic = 0,
        mechanic = 0
    }
    
    local players = ESX.GetPlayers()
    for i=1, #players do
        local xPlayer = ESX.GetPlayerFromId(players[i])
        if xPlayer then
            local job = xPlayer.job.name
            if job == 'police' then
                jobCounts.police = jobCounts.police + 1
            elseif job == 'ambulance' then
                jobCounts.medic = jobCounts.medic + 1
            elseif job == 'mechanic' then
                jobCounts.mechanic = jobCounts.mechanic + 1
            end
        end
    end
    
    return jobCounts
end

CreateThread(function()
    while true do
        Wait(5000)
        local jobCounts = GetJobCounts()
        TriggerClientEvent('kd_hud:updateJobCounts', -1, jobCounts)
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    local jobCounts = GetJobCounts()
    TriggerClientEvent('kd_hud:updateJobCounts', -1, jobCounts)
end)

RegisterNetEvent('kd_hud:requestStatus')
AddEventHandler('kd_hud:requestStatus', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local status = {
        food = 100,
        water = 100
    }
    
    TriggerClientEvent('kd_hud:updateStatus', source, status)
end)

RegisterNetEvent('esx_status:add')
AddEventHandler('esx_status:add', function(name, val)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if name == 'hunger' or name == 'thirst' then
        local status = {
            food = 100,
            water = 100
        }
        
        TriggerClientEvent('kd_hud:updateStatus', source, status)
    end
end)

RegisterNetEvent('esx_status:remove')
AddEventHandler('esx_status:remove', function(name, val)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if name == 'hunger' or name == 'thirst' then
        local status = {
            food = 100,
            water = 100
        }
        
        TriggerClientEvent('kd_hud:updateStatus', source, status)
    end
end)

RegisterNetEvent('kd_hud:syncSeatbelt')
AddEventHandler('kd_hud:syncSeatbelt', function(status)
    local src = source
    
    TriggerClientEvent('kd_hud:syncSeatbelt', -1, src, status)
end)