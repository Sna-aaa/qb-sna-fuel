fx_version 'cerulean'
game 'gta5'

description 'QB Sna Fuel'

author 'Sna'

version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}

dependencies {
  'qb-target'
}

lua54 'yes'
