
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

-- Local variables
local isHudShown = true
local playerData = {}
local isDead = false
local inVehicle = false
local playerStatus = {
    food = 100,
    water = 100,
    ammo = 0
}

-- Khởi tạo biến dây an toàn
local seatbeltOn = false

-- Initialize when player loads
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    playerData = xPlayer
    UpdateHUD()
end)

-- Update job when it changes
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerData.job = job
    UpdateHUD()
end)

-- Update second job when it changes (if using esx_doubjob)
RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    playerData.job2 = job2
    UpdateHUD()
end)

-- Update money when it changes
RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
    if playerData and playerData.accounts then
        for i=1, #playerData.accounts, 1 do
            if playerData.accounts[i].name == account.name then
                playerData.accounts[i] = account
                break
            end
        end
    end
    UpdateHUD()
end)

-- Check if player is dead
AddEventHandler('esx:onPlayerDeath', function()
    isDead = true
    UpdateHUD()
end)

AddEventHandler('esx:onPlayerSpawn', function()
    isDead = false
    UpdateHUD()
end)

-- Update job counts when received from server
RegisterNetEvent('kd_hud:updateJobCounts')
AddEventHandler('kd_hud:updateJobCounts', function(jobCounts)
    SendNUIMessage({
        action = 'updateJobCounts',
        counts = jobCounts
    })
end)

-- Check if player is in vehicle
CreateThread(function()
    local lastEngineHealth = 0
    local lastBodyHealth = 0
    while true do
        Wait(1000)
        local playerPed = PlayerPedId()
        local isInVehicle = IsPedInAnyVehicle(playerPed, false)
        
        if isInVehicle ~= inVehicle then
            inVehicle = isInVehicle
            UpdateHUD()
        end
        
        -- Update vehicle stats more frequently when in vehicle
        if isInVehicle then
            Wait(100) -- Update every 100ms when in vehicle
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle ~= 0 then
                local fuel = GetVehicleFuelLevel(vehicle)
                local speed = GetEntitySpeed(vehicle) * 3.6 -- Convert to km/h
                local engineHealth = GetVehicleEngineHealth(vehicle)
                local bodyHealth = GetVehicleBodyHealth(vehicle)
                
                -- Calculate engine health (max 100%)
                local engineHealthPercent = math.min(100, math.floor(engineHealth / 10))
                -- Calculate body health (max 100%)
                local bodyHealthPercent = math.min(100, math.floor(bodyHealth / 10))
                
                -- Only update if health changed significantly (to prevent flickering)
                if math.abs(engineHealthPercent - lastEngineHealth) >= 1 or 
                   math.abs(bodyHealthPercent - lastBodyHealth) >= 1 then
                    lastEngineHealth = engineHealthPercent
                    lastBodyHealth = bodyHealthPercent
                    
                    SendNUIMessage({
                        action = 'updateVehicle',
                        vehicle = {
                            inVehicle = true,
                            speed = math.floor(speed),
                            fuel = math.floor(fuel),
                            engineHealth = engineHealthPercent,
                            bodyHealth = bodyHealthPercent,
                            seatbelt = seatbeltOn
                        }
                    })
                end
            end
        else
            lastEngineHealth = 0
            lastBodyHealth = 0
            SendNUIMessage({
                action = 'updateVehicle',
                vehicle = {
                    inVehicle = false
                }
            })
        end
    end
end)

-- Format currency values
function FormatCurrency(amount)
    local formattedAmount = amount
    while true do  
        formattedAmount, k = string.gsub(formattedAmount, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formattedAmount
end

-- Get proper time and date
function GetTimeAndDate()
    local time, date
    
    if Config.UseRealTime then
        -- Use real-life time
        time = os.date("%H:%M")
        date = os.date("%d/%m/%Y")
    else
        -- Use game time
        local hours = GetClockHours()
        local minutes = GetClockMinutes()
        
        if hours < 10 then
            hours = "0" .. hours
        end
        if minutes < 10 then
            minutes = "0" .. minutes
        end
        
        time = hours .. ":" .. minutes
        
        -- Game date (Year is arbitrary)
        local day = GetClockDayOfMonth()
        local month = GetClockMonth() + 1 -- GetClockMonth is 0-11
        local year = GetClockYear()
        
        if day < 10 then
            day = "0" .. day
        end
        if month < 10 then
            month = "0" .. month
        end
        
        date = day .. "/" .. month .. "/" .. year
    end
    
    return time, date
end

-- Check ammo periodically
CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        if not isDead then
            local ped = PlayerPedId()
            local _, weapon = GetCurrentPedWeapon(ped, true)
            local ammo = GetAmmoInPedWeapon(ped, weapon)
            
            if ammo ~= playerStatus.ammo then
                playerStatus.ammo = ammo
                SendNUIMessage({
                    action = 'updateStatus',
                    status = {
                        ammo = ammo
                    }
                })
            end
        end
    end
end)

-- Update player status from server
RegisterNetEvent('kd_hud:updateStatus')
AddEventHandler('kd_hud:updateStatus', function(status)
    if status.food then playerStatus.food = status.food end
    if status.water then playerStatus.water = status.water end
    if status.ammo then playerStatus.ammo = status.ammo end
    
    SendNUIMessage({
        action = 'updateStatus',
        status = {
            food = playerStatus.food,
            water = playerStatus.water,
            ammo = playerStatus.ammo
        }
    })
end)

-- Check player status periodically
CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds
        if not isDead then
            -- Trigger server event to get updated status
            TriggerServerEvent('kd_hud:requestStatus')
        end
    end
end)

-- Update the HUD with current player data
function UpdateHUD()
    if not isHudShown or not playerData or not playerData.accounts then return end

    -- Get money values
    local money = 0
    local bank = 0
    local black = 0
    
    for i=1, #playerData.accounts, 1 do
        if playerData.accounts[i].name == 'money' then
            money = playerData.accounts[i].money
        elseif playerData.accounts[i].name == 'bank' then
            bank = playerData.accounts[i].money
        elseif playerData.accounts[i].name == 'black_money' then
            black = playerData.accounts[i].money
        end
    end
    
    -- Get job information
    local job1 = playerData.job or {label = 'Unknown', grade_label = ''}
    local job2 = playerData.job2 or {label = 'None', grade_label = ''}
    
    -- Get player name and ID
    local playerName = playerData.name or GetPlayerName(PlayerId())
    local playerId = GetPlayerServerId(PlayerId())
    
    -- Get time and date
    local time, date = GetTimeAndDate()
    
    -- Get vehicle stats if in vehicle
    local vehicleStats = {}
    if inVehicle then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            local fuel = GetVehicleFuelLevel(vehicle)
            local speed = GetEntitySpeed(vehicle) * 3.6 -- Convert to km/h
            local engineHealth = GetVehicleEngineHealth(vehicle)
            

            
            vehicleStats = {
                fuel = math.floor(fuel),
                speed = math.floor(speed),
                engineHealth = math.floor(engineHealth),
                seatbelt = seatbeltOn
            }
        end
    end
    
    -- Send data to NUI
    SendNUIMessage({
        action = 'updateHud',
        data = {
            isShown = isHudShown and not isDead,
            playerName = playerName,
            playerId = playerId,
            time = time,
            date = date,
            job1 = job1.label .. ' - ' .. job1.grade_label,
            job2 = job2.label .. ' - ' .. job2.grade_label,
            money = FormatCurrency(money),
            bank = FormatCurrency(bank),
            black = FormatCurrency(black),
            inVehicle = inVehicle,
            vehicleStats = vehicleStats,
            status = {
                food = playerStatus.food,
                water = playerStatus.water,
                ammo = playerStatus.ammo
            }
        }
    })
    
    -- Cập nhật riêng trạng thái dây an toàn
    if inVehicle then
        SendNUIMessage({
            action = 'updateSeatbelt',
            seatbelt = seatbeltOn
        })
    end
end

-- Toggle HUD visibility
RegisterCommand('togglehud', function()
    isHudShown = not isHudShown
    UpdateHUD()
end, false)

-- Register keybinding for toggling HUD
RegisterKeyMapping('togglehud', 'Toggle Player HUD', 'keyboard', 'f10')

-- Initialize HUD when resource starts
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Wait for ESX to be ready
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    
    playerData = ESX.GetPlayerData()
    UpdateHUD()
    
    -- Start regular HUD updates
    CreateThread(function()
        while true do
            Wait(Config.RefreshTime)
            UpdateHUD()
        end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    local hiddenMessage = string.char(
        75, 105, 110, 101, 116, 68, 101, 118, 32, 45, 32, 80, 114, 101, 109, 105, 117, 109, 32, 83, 99, 114, 105, 112, 116, 115, 32, 40, 99, 41, 32, 50, 48, 50, 53, 10,
        104, 116, 116, 112, 58, 47, 47, 107, 105, 110, 101, 116, 100, 101, 118, 46, 99, 111, 109
    )
    print('^2[KINETDEV.COM ]^7 Resource started')
    print('^1' .. hiddenMessage .. '^7')
end)

-- Đăng ký phím bấm để bật/tắt dây an toàn (phím G)
RegisterCommand("seatbelt", function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        seatbeltOn = not seatbeltOn
        SendNUIMessage({
            action = 'updateSeatbelt',
            seatbelt = seatbeltOn
        })
        
        local statusText = seatbeltOn and "bật" or "tắt"
        ESX.ShowNotification("Bạn đã " .. statusText .. " dây an toàn")
        
        -- Đồng bộ với server
        TriggerServerEvent('kd_hud:syncSeatbelt', seatbeltOn)
    end
end, false)

-- Đăng ký phím G để bật/tắt dây an toàn
RegisterKeyMapping('seatbelt', 'Bật/tắt dây an toàn', 'keyboard', 'G')

-- Xử lý hiệu ứng khi sử dụng dây an toàn
CreateThread(function()
    while true do
        Wait(0)
        
        local player = PlayerPedId()
        if IsPedInAnyVehicle(player, false) then
            local vehicle = GetVehiclePedIsIn(player, false)
            
            -- Kiểm tra dây an toàn khi lái xe
            if GetPedInVehicleSeat(vehicle, -1) == player then
                -- Bảo vệ người chơi khi có dây an toàn
                if seatbeltOn then
                    -- Ngăn không cho người chơi văng ra khỏi xe khi va chạm
                    DisableControlAction(0, 75, true) -- Ngăn phím F để rời xe
                    
                    -- Giảm sát thương khi va chạm
                    local speed = GetEntitySpeed(vehicle) * 3.6 -- Chuyển về km/h
                    if speed > 100.0 and HasEntityCollidedWithAnything(vehicle) then
                        -- Giảm sát thương 50% khi có dây an toàn
                        local health = GetEntityHealth(player)
                        local newHealth = math.max(100, health - (health * 0.5))
                        SetEntityHealth(player, newHealth)
                    end
                else
                    -- Người chơi có thể văng ra khỏi xe khi va chạm mạnh
                    local speed = GetEntitySpeed(vehicle) * 3.6 -- Chuyển về km/h
                    if speed > 100.0 and HasEntityCollidedWithAnything(vehicle) then
                        -- Văng người chơi ra khỏi xe với xác suất 80%
                        if math.random() < 0.8 then
                            SetPedToRagdoll(player, 5000, 5000, 0, 0, 0, 0)
                            SetEntityHealth(player, GetEntityHealth(player) - 50)
                            Wait(500)
                        end
                    end
                end
            end
        else
            -- Reset trạng thái dây an toàn khi không ở trong xe
            if seatbeltOn then
                seatbeltOn = false
                SendNUIMessage({
                    action = 'updateSeatbelt',
                    seatbelt = false
                })
                
                -- Đồng bộ với server
                TriggerServerEvent('kd_hud:syncSeatbelt', false)
            end
        end
    end
end)

-- Sự kiện đồng bộ từ server
RegisterNetEvent('kd_hud:syncSeatbelt')
AddEventHandler('kd_hud:syncSeatbelt', function(playerId, status)
    -- Chỉ áp dụng cho người chơi khác
    if playerId ~= GetPlayerServerId(PlayerId()) then
        -- Có thể thêm hiệu ứng hiển thị dây an toàn cho người chơi khác nếu cần
    end
end)

-- Cập nhật thông tin phương tiện
function UpdateVehicleInfo()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local speed = math.floor(GetEntitySpeed(vehicle) * 3.6) -- Chuyển đổi sang km/h
        local fuel = GetVehicleFuelLevel(vehicle)
        local engineHealth = GetVehicleEngineHealth(vehicle) / 10.0
        local bodyHealth = GetVehicleBodyHealth(vehicle) / 10.0
        
        -- Cập nhật UI
        SendNUIMessage({
            action = 'updateVehicle',
            vehicle = {
                inVehicle = true,
                speed = speed,
                fuel = math.floor(fuel),
                engineHealth = math.floor(engineHealth),
                bodyHealth = math.floor(bodyHealth),
                seatbelt = seatbeltOn
            }
        })
    else
        SendNUIMessage({
            action = 'updateVehicle',
            vehicle = {
                inVehicle = false
            }
        })
    end
end 