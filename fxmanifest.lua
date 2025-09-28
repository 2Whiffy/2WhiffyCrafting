fx_version 'cerulean'
game 'gta5'

author '2Whiffy - Modified from original by @allroundjonu'
description '2WhiffyCrafting - Advanced Crafting System with Levels'
version 'v2.0.0'

identifier '2WhiffyCrafting'

shared_script {
    '@ox_lib/init.lua',
    '@lation_ui/init.lua',
}

shared_scripts {
    'shared/config.lua',
    'bridge/init.lua',
    'shared/functions.lua',
    'locales/en.lua',
    'locales/*.lua',
    'bridge/**/shared.lua',
    '@es_extended/imports.lua',
}

client_scripts {
    'bridge/**/client.lua',
    'client/cl_menus.lua',
    'client/cl_crafting.lua',
    'client/cl_target.lua',
    'client/cl_levels.lua',
    'client/cl_notarget.lua',
    'client/cl_admin.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/**/server.lua',
    'server/classes/*.lua',
    'server/sv_setupdatabase.lua',
    'server/sv_crafting.lua',
    'server/sv_levels.lua',
    'server/sv_usableitems.lua',
    'server/sv_webhooks.lua',
    'server/sv_admin.lua',
    'server/sv_versioncheck.lua',
}

dependencies {
    'ox_lib',
    'oxmysql'
}

-- Export for ox_inventory
server_export 'placeCraftingTable'

lua54 'yes'
