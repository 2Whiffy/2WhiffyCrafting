-- ┌─────────────────────────────────────────────────────────────────────┐
-- │  _                    _       ____            _                    │
-- │ | |    _____   _____| |___  / ___| _   _ ___| |_ ___ _ __ ___      │
-- │ | |   / _ \ \ / / _ \ / __| \___ \| | | / __| __/ _ \ '_ ` _ \     │
-- │ | |__|  __/\ V /  __/ \__ \  ___) | |_| \__ \ ||  __/ | | | | |    │
-- │ |_____\___| \_/ \___|_|___/ |____/ \__, |___/\__\___|_| |_| |_|    │
-- │                                    |___/                           │
-- └─────────────────────────────────────────────────────────────────────┘

local playerLevels = {} -- Cache for player levels

-- Get player's level for a specific skill type
local function getPlayerLevel(skillType)
    if not Config.LevelsSystem.enabled then return 1, 0 end
    
    if playerLevels[skillType] then
        return playerLevels[skillType].level, playerLevels[skillType].xp
    end
    
    -- Get from server
    local level, xp = lib.callback.await('2WhiffyCrafting:server:getPlayerLevel', false, skillType)
    
    -- Cache the result
    playerLevels[skillType] = {level = level, xp = xp}
    
    return level, xp
end

-- Check if player meets level requirement for a recipe
local function checkLevelRequirement(recipeId)
    if not Config.LevelsSystem.enabled then return true end
    
    return lib.callback.await('2WhiffyCrafting:server:checkLevelRequirement', false, recipeId)
end

-- Get all player levels
local function getAllPlayerLevels()
    if not Config.LevelsSystem.enabled then return {} end
    
    return lib.callback.await('2WhiffyCrafting:server:getAllPlayerLevels', false)
end

-- Show level up notification
local function showLevelUpNotification(skillType, newLevel, oldLevel)
    local skillLabel = Config.LevelsSystem.skillTypes[skillType].label
    
    ShowNotification(nil, ('🎉 %s Level Up! %d → %d'):format(skillLabel, oldLevel, newLevel), 'success')
    
    -- You can add more elaborate notifications here
    -- For example, using ox_lib notifications with custom styling
    if lib.notify then
        lib.notify({
            title = 'Level Up!',
            description = ('%s: %d → %d'):format(skillLabel, oldLevel, newLevel),
            type = 'success',
            duration = 5000,
            icon = 'trophy'
        })
    end
end

-- Show levels menu
local function showLevelsMenu()
    if not Config.LevelsSystem.enabled then
        ShowNotification(nil, 'Levels system is disabled', 'error')
        return
    end
    
    local levels = getAllPlayerLevels()
    if not levels then
        ShowNotification(nil, 'Failed to get levels data', 'error')
        return
    end
    
    local options = {}
    
    for skillType, data in pairs(levels) do
        local progressPercent = 0
        if data.xpForNext > 0 then
            progressPercent = math.floor((data.xp / data.xpForNext) * 100)
        end
        
        table.insert(options, {
            title = data.label,
            description = ('Level %d | XP: %d/%d (%d%%)'):format(
                data.level, 
                data.xp, 
                data.xpForNext, 
                progressPercent
            ),
            icon = skillType == 'weapons_crafting' and 'gun' or 'hammer',
            disabled = true
        })
    end
    
    if #options == 0 then
        table.insert(options, {
            title = 'No Skills Available',
            description = 'No crafting skills found',
            icon = 'info',
            disabled = true
        })
    end
    
    lib.registerContext({
        id = 'it-crafting-levels-menu',
        title = 'Crafting Levels',
        options = options
    })
    
    lib.showContext('it-crafting-levels-menu')
end

-- Events
RegisterNetEvent('2WhiffyCrafting:client:levelUp', function(skillType, newLevel, oldLevel)
    -- Update cache
    if playerLevels[skillType] then
        playerLevels[skillType].level = newLevel
    end

    -- Show notification
    showLevelUpNotification(skillType, newLevel, oldLevel)
end)

RegisterNetEvent('2WhiffyCrafting:client:showLevelsMenu', function()
    showLevelsMenu()
end)

RegisterNetEvent('2WhiffyCrafting:client:updateLevelCache', function(skillType, level, xp)
    playerLevels[skillType] = {level = level, xp = xp}
end)

-- Commands (optional - for testing/admin)
if Config.Debug then
    RegisterCommand('craftinglevels', function()
        showLevelsMenu()
    end, false)
    
    RegisterCommand('craftinglevel', function(source, args)
        if not args[1] then
            print('Usage: /craftinglevel <skillType>')
            return
        end
        
        local skillType = args[1]
        local level, xp = getPlayerLevel(skillType)
        print(('Skill: %s | Level: %d | XP: %d'):format(skillType, level, xp))
    end, false)
end

-- Exports
exports('getPlayerLevel', getPlayerLevel)
exports('checkLevelRequirement', checkLevelRequirement)
exports('getAllPlayerLevels', getAllPlayerLevels)
exports('showLevelsMenu', showLevelsMenu)

-- Clear cache on resource restart
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        playerLevels = {}
    end
end)
