ESX = exports["es_extended"]:getSharedObject()

local isHudShown = true
local playerData = {}
local isDead = false
local inVehicle = false
local playerStatus = {
    food = 100,
    water = 100,
    ammo = 0
}

local seatbeltOn = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    playerData = xPlayer
    UpdateHUD()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerData.job = job
    UpdateHUD()
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    playerData.job2 = job2
    UpdateHUD()
end)

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

AddEventHandler('esx:onPlayerDeath', function()
    isDead = true
    UpdateHUD()
end)

AddEventHandler('esx:onPlayerSpawn', function()
    isDead = false
    UpdateHUD()
end)

RegisterNetEvent('kd_hud:updateJobCounts')
AddEventHandler('kd_hud:updateJobCounts', function(jobCounts)
    SendNUIMessage({
        action = 'updateJobCounts',
        counts = jobCounts
    })
end)

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
        
        if isInVehicle then
            Wait(100)
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle ~= 0 then
                local fuel = GetVehicleFuelLevel(vehicle)
                local speed = GetEntitySpeed(vehicle) * 3.6
                local engineHealth = GetVehicleEngineHealth(vehicle)
                local bodyHealth = GetVehicleBodyHealth(vehicle)
                
                local engineHealthPercent = math.min(100, math.floor(engineHealth / 10))
                local bodyHealthPercent = math.min(100, math.floor(bodyHealth / 10))
                
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

function GetTimeAndDate()
    local time, date
    
    if Config.UseRealTime then
        time = os.date("%H:%M")
        date = os.date("%d/%m/%Y")
    else
        local hours = GetClockHours()
        local minutes = GetClockMinutes()
        
        if hours < 10 then
            hours = "0" .. hours
        end
        if minutes < 10 then
            minutes = "0" .. minutes
        end
        
        time = hours .. ":" .. minutes
        
        local day = GetClockDayOfMonth()
        local month = GetClockMonth() + 1
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

CreateThread(function()
    while true do
        Wait(1000)
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

CreateThread(function()
    while true do
        Wait(5000)
        if not isDead then
            TriggerServerEvent('kd_hud:requestStatus')
        end
    end
end)

function UpdateHUD()
    if not isHudShown or not playerData or not playerData.accounts then return end

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
    
    local job1 = playerData.job or {label = 'Unknown', grade_label = ''}
    local job2 = playerData.job2 or {label = 'None', grade_label = ''}
    
    local playerName = playerData.name or GetPlayerName(PlayerId())
    local playerId = GetPlayerServerId(PlayerId())
    
    local time, date = GetTimeAndDate()
    
    local vehicleStats = {}
    if inVehicle then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            local fuel = GetVehicleFuelLevel(vehicle)
            local speed = GetEntitySpeed(vehicle) * 3.6
            local engineHealth = GetVehicleEngineHealth(vehicle)
            
            vehicleStats = {
                fuel = math.floor(fuel),
                speed = math.floor(speed),
                engineHealth = math.floor(engineHealth),
                seatbelt = seatbeltOn
            }
        end
    end
    
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
    
    if inVehicle then
        SendNUIMessage({
            action = 'updateSeatbelt',
            seatbelt = seatbeltOn
        })
    end
end

RegisterCommand('togglehud', function()
    isHudShown = not isHudShown
    UpdateHUD()
end, false)

RegisterKeyMapping('togglehud', 'Toggle Player HUD', 'keyboard', 'f10')

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    
    playerData = ESX.GetPlayerData()
    UpdateHUD()
    
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

RegisterCommand("seatbelt", function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        seatbeltOn = not seatbeltOn
        SendNUIMessage({
            action = 'updateSeatbelt',
            seatbelt = seatbeltOn
        })
        
        local statusText = seatbeltOn and "bật" or "tắt"
        ESX.ShowNotification("Bạn đã " .. statusText .. " dây an toàn")
        
        TriggerServerEvent('kd_hud:syncSeatbelt', seatbeltOn)
    end
end, false)

RegisterKeyMapping('seatbelt', 'Bật/tắt dây an toàn', 'keyboard', 'G')

CreateThread(function()
    while true do
        Wait(0)
        
        local player = PlayerPedId()
        if IsPedInAnyVehicle(player, false) then
            local vehicle = GetVehiclePedIsIn(player, false)
            
            if GetPedInVehicleSeat(vehicle, -1) == player then
                if seatbeltOn then
                    DisableControlAction(0, 75, true)
                    
                    local speed = GetEntitySpeed(vehicle) * 3.6
                    if speed > 100.0 and HasEntityCollidedWithAnything(vehicle) then
                        local health = GetEntityHealth(player)
                        local newHealth = math.max(100, health - (health * 0.5))
                        SetEntityHealth(player, newHealth)
                    end
                else
                    local speed = GetEntitySpeed(vehicle) * 3.6
                    if speed > 100.0 and HasEntityCollidedWithAnything(vehicle) then
                        if math.random() < 0.8 then
                            SetPedToRagdoll(player, 5000, 5000, 0, 0, 0, 0)
                            SetEntityHealth(player, GetEntityHealth(player) - 50)
                            Wait(500)
                        end
                    end
                end
            end
        else
            if seatbeltOn then
                seatbeltOn = false
                SendNUIMessage({
                    action = 'updateSeatbelt',
                    seatbelt = false
                })
                
                TriggerServerEvent('kd_hud:syncSeatbelt', false)
            end
        end
    end
end)

RegisterNetEvent('kd_hud:syncSeatbelt')
AddEventHandler('kd_hud:syncSeatbelt', function(playerId, status)
    if playerId ~= GetPlayerServerId(PlayerId()) then
    end
end)

function UpdateVehicleInfo()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local speed = math.floor(GetEntitySpeed(vehicle) * 3.6)
        local fuel = GetVehicleFuelLevel(vehicle)
        local engineHealth = GetVehicleEngineHealth(vehicle) / 10.0
        local bodyHealth = GetVehicleBodyHealth(vehicle) / 10.0
        
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