resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

version '1.0.0'

client_script {
	'@es_extended/locale.lua',
	'locates/sv.lua',
	'locates/en.lua',
	'config.lua',
	'client/main.lua',
	'client/functions.lua'
}

server_script {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locates/sv.lua',
	'locates/en.lua',
	'config.lua',
	'server/main.lua'
}
