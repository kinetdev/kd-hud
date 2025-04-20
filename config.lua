
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

Config.Debug = false
Config.Locale = 'vi'

Config.Time = {
    Enable = true,
    UpdateInterval = 1000,
    UseRealTime = false,
    Format = {
        time = 'HH:mm',
        date = 'DD/MM'
    }
}

Config.HUD = {
    Enable = true,
    UpdateInterval = 1000
}

Config.Money = {
    Cash = true,
    Bank = true,
    BlackMoney = true
}

Config.Jobs = {
    Enable = true,
    MaxJobs = 2
}

Config.Status = {
    Enable = true,
    Health = true,
    Armor = true
}

Config.Vehicle = {
    Enable = true,
    Speed = true,
    Fuel = true,
    Engine = true
}

Config.Controls = {
    ToggleHUD = 'F7'
}

Config.RefreshTime = 1000
Config.UseRealTime = false

Config.Logo = {
    url = '/html/logo.png',
    width = '50px',
    height = '50px',
    borderRadius = '10px',
    borderColor = 'rgba(255, 255, 255, 0.7)',
    borderWidth = '2px',
    animation = true,
    glow = {
        enabled = true,
        color = 'rgba(255, 255, 255, 0.3)',
        opacity = 0.7
    }
}

Config.Colors = {
    background = 'rgba(0, 0, 0, 0.7)',
    text = '#FFFFFF',
    money = '#7CFC00',
    bank = '#4169E1',
    dirty = '#FF6347'
}

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