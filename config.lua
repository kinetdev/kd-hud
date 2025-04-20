
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

Config = {}

-- Cấu hình chung
Config.Debug = false
Config.Locale = 'vi'

-- Cấu hình thời gian
Config.Time = {
    Enable = true,
    UpdateInterval = 1000, -- ms
    UseRealTime = false, -- Sử dụng thời gian thực hoặc thời gian trong game
    Format = {
        time = 'HH:mm',
        date = 'DD/MM'
    }
}

-- Cấu hình HUD
Config.HUD = {
    Enable = true,
    UpdateInterval = 1000 -- ms
}

-- Cấu hình tiền tệ
Config.Money = {
    Cash = true,
    Bank = true,
    BlackMoney = true
}

-- Cấu hình công việc
Config.Jobs = {
    Enable = true,
    MaxJobs = 2
}

-- Cấu hình trạng thái
Config.Status = {
    Enable = true,
    Health = true,
    Armor = true
}

-- Cấu hình phương tiện
Config.Vehicle = {
    Enable = true,
    Speed = true,
    Fuel = true,
    Engine = true
}

-- Cấu hình phím tắt
Config.Controls = {
    ToggleHUD = 'F7'
}

-- HUD display settings
Config.RefreshTime = 1000 -- Update HUD every 1 second
Config.UseRealTime = false -- Use real-time or game time

-- Server logo settings
Config.Logo = {
    url = '/html/logo.png', -- Path to logo file
    width = '50px',
    height = '50px',
    borderRadius = '10px', -- Border radius for square/rectangle logos (use '50%' for circle)
    borderColor = 'rgba(255, 255, 255, 0.7)',
    borderWidth = '2px',
    animation = true, -- Enable floating animation
    glow = {
        enabled = true, -- Enable glow effect around logo
        color = 'rgba(255, 255, 255, 0.3)',
        opacity = 0.7
    }
}

-- HUD colors
Config.Colors = {
    background = 'rgba(0, 0, 0, 0.7)',
    text = '#FFFFFF',
    money = '#7CFC00', -- Light green
    bank = '#4169E1', -- Royal blue
    dirty = '#FF6347'  -- Tomato red
}

-- Job counters at bottom right
Config.JobCounters = {
    enabled = true,
    jobs = {
        police = {
            icon = 'shield-alt',
            color = '#1E90FF'
        },
        ambulance = {
            icon = 'ambulance',
            color = '#FF6347'
        },
        mechanic = {
            icon = 'wrench',
            color = '#FFD700'
        }
    }
}

-- Status hub at bottom center
Config.StatusHub = {
    enabled = true,
    showFood = true,
    showWater = true,
    showArmor = true,
    showAmmo = true,
    vehicle = {
        showSpeed = true,
        showFuel = true,
        showHealth = true
    }
}

-- Controls guide at left side
Config.ControlsGuide = {
    enabled = true,
    controls = {
        {key = 'TAB', action = 'Mở kho đồ'},
        {key = 'F1', action = 'Điện thoại'},
        {key = 'F3', action = 'Hành động'},
        {key = 'F4', action = 'Ping job'},
        {key = 'G', action = 'Giây an toàn'},
        {key = 'Z', action = 'Cấp độ'}
    },
    toggleKey = 'H'
} 