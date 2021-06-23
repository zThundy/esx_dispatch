fx_version "cerulean"
game "gta5"

version "2.0.0"
author "zThundy__"

ui_page 'html/index.html'

files {
    'html/js/*.js',
    'html/index.html',
    'html/css/*.css',
    'html/webfonts/*.ttf'
}

client_scripts {
	'config.lua',
	'client/*.lua'
}

server_script {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    "es_extended",
    
}