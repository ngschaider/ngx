fx_version 'cerulean'

games {
	"gta5"
}

description 'NGX'

version '1.0.0'

lua54 "yes"

server_scripts {
	'@oxmysql/lib/MySQL.lua',

	"boot/sh_modules.lua",
	"boot/sh_main.lua",
}

client_scripts {
	"@NativeUI/NativeUI.lua",

	"boot/sh_modules.lua",
	"boot/sh_main.lua",
}

ui_page {
	'html/ui.html',
}

files {
	"modules.json",
	"modules/**/shared.lua",
	"modules/**/shared/*.lua",
	"modules/**/client.lua",
	"modules/**/client/*.lua",
}

dependencies {
	'oxmysql',
	"NativeUI",
}
