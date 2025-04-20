
-- '   ___  ____    _____   ____  _____   ________   _________     ______     ________   ____   __ __   '
-- '  |_  ||_  _|  |_   _| |_   \|_   _| |_   __  | |  _   _  |   |_   _ `.  |_   __  | |_  _| |_  _|   '
-- '    || |/ /      | |     |   \ | |     | |_ \_| |_/ | | \_|     | | `. \   | |_ \_|   \ \   / /     '
-- '    |  __'.      | |     | |\ \| |     |  _| _      | |         | |  | |   |  _| _     \ \ / /      '    
-- '   _| |  \ \_   _| |_   _| |_\   |_   _| |__/ |    _| |_       _| |_.' /  _| |__/ |     \ ' /'      '   
-- '  |____||____| |_____| |_____|\____| |________|   |_____|     |______.'  |________|      \_/'       '   
-- '                                    
-- '                            Discord: https://discord.gg/kinetdev          
-- '                            Website: https://kinetdev.com                 
-- '                            CFG Docs: https://docs.kinetdev.com           


-- ESX initialization
ESX = exports["es_extended"]:getSharedObject()

-- Initialize resource
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    print('^2[KINETDEV.COM]^7 Resource started')
end)

-- Simple check command for admins
ESX.RegisterCommand('checkplayerhud', 'admin', function(xPlayer, args, showError)
    if not args.playerId then
        args.playerId = xPlayer.source
    end
    
    local targetPlayer = ESX.GetPlayerFromId(args.playerId)
    if not targetPlayer then
        return showError('Player not found')
    end
    
    -- Get player money information
    local money = targetPlayer.getAccount('money').money
    local bank = targetPlayer.getAccount('bank').money
    local black = targetPlayer.getAccount('black_money').money
    
    -- Send information to admin
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

-- Example of how to update player HUD on certain events
RegisterServerEvent('esx_playerhud:updateHUD')
AddEventHandler('esx_playerhud:updateHUD', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Trigger client update event (useful if you need to push specific updates from server)
    TriggerClientEvent('esx_playerhud:updateHUD', source)
end)

-- Function to get job counts
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

-- Update job counts periodically
CreateThread(function()
    while true do
        Wait(5000) -- Update every 5 seconds
        local jobCounts = GetJobCounts()
        TriggerClientEvent('kd_hud:updateJobCounts', -1, jobCounts)
    end
end)

-- Update job counts when player changes job
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    local jobCounts = GetJobCounts()
    TriggerClientEvent('kd_hud:updateJobCounts', -1, jobCounts)
end)

-- Handle status update requests
RegisterNetEvent('kd_hud:requestStatus')
AddEventHandler('kd_hud:requestStatus', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Giá trị mặc định
    local status = {
        food = 100,
        water = 100
    }
    
    -- Send status back to client
    TriggerClientEvent('kd_hud:updateStatus', source, status)
end)

-- Update status when player uses items
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

-- Update status when player loses status
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

-- Đồng bộ hóa trạng thái dây an toàn
RegisterNetEvent('kd_hud:syncSeatbelt')
AddEventHandler('kd_hud:syncSeatbelt', function(status)
    local src = source
    
    -- Gửi thông tin đến tất cả người chơi
    TriggerClientEvent('kd_hud:syncSeatbelt', -1, src, status)
end) 