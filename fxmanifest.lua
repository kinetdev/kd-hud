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