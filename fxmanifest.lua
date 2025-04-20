
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


fx_version 'cerulean'
game 'gta5'

author 'KinetDev'
description 'ESX Player HUD'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/img/logo.png'
}

dependencies {
    'es_extended'
} 