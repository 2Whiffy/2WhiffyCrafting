-- ┌─────────────────────────────────────────────────────────────────────┐
-- │  _                    _       ____            _                    │
-- │ | |    _____   _____| |___  / ___| _   _ ___| |_ ___ _ __ ___      │
-- │ | |   / _ \ \ / / _ \ / __| \___ \| | | / __| __/ _ \ '_ ` _ \     │
-- │ | |__|  __/\ V /  __/ \__ \  ___) | |_| \__ \ ||  __/ | | | | |    │
-- │ |_____\___| \_/ \___|_|___/ |____/ \__, |___/\__\___|_| |_| |_|    │
-- │                                    |___/                           │
-- └─────────────────────────────────────────────────────────────────────┘

local playerLevels = {} -- Cache for player levels

-- Initialize levels system
local function initializeLevelsSystem()
    if not Config.LevelsSystem.enabled then return end
    
    -- Create table if it doesn't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS 2whiffycrafting_levels (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            skill_type VARCHAR(50) NOT NULL,
            level INT DEFAULT 1,
            xp INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY unique_player_skill (citizenid, skill_type)
        )
    ]])
    
    if Config.Debug then
        lib.print.info('[Levels System] Initialized successfully')
    end
end

-- Calculate XP required for a specific level
local function calculateXPForLevel(level)
    if level <= 1 then return 0 end
    
    local baseXP = Config.LevelsSystem.xpCalculation.baseXP
    local multiplier = Config.LevelsSystem.xpCalculation.multiplier
    
    local totalXP = 0
    for i = 1, level - 1 do
        totalXP = totalXP + math.floor(baseXP * (1 + (i * multiplier)))
    end
    
    return totalXP
end

-- Get player's current level and XP for a skill type
local function getPlayerLevel(citizenid, skillType)
    if not Config.LevelsSystem.enabled then return 1, 0 end
    
    -- Check cache first
    local cacheKey = citizenid .. '_' .. skillType
    if playerLevels[cacheKey] then
        return playerLevels[cacheKey].level, playerLevels[cacheKey].xp
    end
    
    -- Get from database
    local result = MySQL.query.await('SELECT level, xp FROM 2whiffycrafting_levels WHERE citizenid = ? AND skill_type = ?', {
        citizenid, skillType
    })
    
    if result and result[1] then
        local level = result[1].level
        local xp = result[1].xp
        
        -- Cache the result
        playerLevels[cacheKey] = {level = level, xp = xp}
        
        return level, xp
    else
        -- Initialize new player
        local startingLevel = Config.LevelsSystem.skillTypes[skillType].startingLevel
        local startingXP = Config.LevelsSystem.skillTypes[skillType].startingXP
        
        MySQL.insert('INSERT INTO 2whiffycrafting_levels (citizenid, skill_type, level, xp) VALUES (?, ?, ?, ?)', {
            citizenid, skillType, startingLevel, startingXP
        })
        
        -- Cache the result
        playerLevels[cacheKey] = {level = startingLevel, xp = startingXP}
        
        return startingLevel, startingXP
    end
end

-- Update player's XP and level
local function updatePlayerXP(citizenid, skillType, xpGain)
    if not Config.LevelsSystem.enabled then return false end
    
    local currentLevel, currentXP = getPlayerLevel(citizenid, skillType)
    local newXP = currentXP + xpGain
    local newLevel = currentLevel
    
    -- Check for level ups
    local maxLevel = Config.LevelsSystem.skillTypes[skillType].maxLevel
    while newLevel < maxLevel do
        local xpForNextLevel = calculateXPForLevel(newLevel + 1)
        if newXP >= xpForNextLevel then
            newLevel = newLevel + 1
        else
            break
        end
    end
    
    -- Update database
    MySQL.update('UPDATE 2whiffycrafting_levels SET level = ?, xp = ? WHERE citizenid = ? AND skill_type = ?', {
        newLevel, newXP, citizenid, skillType
    })
    
    -- Update cache
    local cacheKey = citizenid .. '_' .. skillType
    playerLevels[cacheKey] = {level = newLevel, xp = newXP}
    
    -- Check if player leveled up
    if newLevel > currentLevel then
        if Config.Debug then
            lib.print.info('[Levels System] Player', citizenid, 'leveled up in', skillType, 'from', currentLevel, 'to', newLevel)
        end
        
        -- Trigger level up event
        local src = it.getPlayerFromCitizenId and it.getPlayerFromCitizenId(citizenid) or nil
        if src then
            TriggerClientEvent('2WhiffyCrafting:client:levelUp', src, skillType, newLevel, currentLevel)
        end
    end
    
    -- External integration
    if Config.LevelsSystem.integration.enabled then
        local src = it.getPlayerFromCitizenId and it.getPlayerFromCitizenId(citizenid) or nil
        if src then
            if Config.LevelsSystem.integration.useExport then
                -- Use export
                exports[Config.LevelsSystem.integration.resourceName][Config.LevelsSystem.integration.exportName](src, skillType, xpGain, newLevel, newXP)
            else
                -- Use event
                TriggerEvent(Config.LevelsSystem.integration.eventName, src, skillType, xpGain, newLevel, newXP)
            end
        end
    end
    
    return true, newLevel, newXP, (newLevel > currentLevel)
end

-- Check if player meets level requirement for a recipe
local function checkLevelRequirement(citizenid, recipe)
    if not Config.LevelsSystem.enabled then return true end
    if not recipe.levelRequirement then return true end
    
    local playerLevel = getPlayerLevel(citizenid, recipe.levelRequirement.skillType)
    return playerLevel >= recipe.levelRequirement.level
end

-- Award XP for crafting
local function awardCraftingXP(citizenid, skillType, recipe)
    if not Config.LevelsSystem.enabled then return end

    -- Use XP reward from the recipe itself
    local xpReward = recipe.xpReward or 0
    if xpReward <= 0 then return end

    updatePlayerXP(citizenid, skillType, xpReward)

    if Config.Debug then
        lib.print.info('[Levels System] Awarded', xpReward, 'XP to', citizenid, 'for', skillType, 'from recipe', recipe.label)
    end
end

-- Callbacks
lib.callback.register('2WhiffyCrafting:server:getPlayerLevel', function(source, skillType)
    local player = it.getPlayer(source)
    if not player then return 1, 0 end

    return getPlayerLevel(it.getCitizenId(source), skillType)
end)

lib.callback.register('2WhiffyCrafting:server:checkLevelRequirement', function(source, recipeId)
    local player = it.getPlayer(source)
    if not player then return false end

    local recipe = Config.Recipes[recipeId]
    if not recipe then return false end

    return checkLevelRequirement(it.getCitizenId(source), recipe)
end)

lib.callback.register('2WhiffyCrafting:server:getAllPlayerLevels', function(source)
    local player = it.getPlayer(source)
    if not player then return {} end

    local citizenid = it.getCitizenId(source)
    local levels = {}

    for skillType, _ in pairs(Config.LevelsSystem.skillTypes) do
        local level, xp = getPlayerLevel(citizenid, skillType)
        levels[skillType] = {
            level = level,
            xp = xp,
            xpForNext = calculateXPForLevel(level + 1),
            label = Config.LevelsSystem.skillTypes[skillType].label
        }
    end

    return levels
end)

-- Events
RegisterNetEvent('2WhiffyCrafting:server:awardCraftingXP', function(skillType, recipeId)
    local src = source
    local player = it.getPlayer(src)
    if not player then return end

    local recipe = Config.Recipes[recipeId]
    if not recipe then return end

    awardCraftingXP(it.getCitizenId(src), skillType, recipe)
end)

-- Additional exports for external integration
exports('getAllPlayerLevels', function(citizenid)
    if not Config.LevelsSystem.enabled then return {} end

    local levels = {}
    for skillType, _ in pairs(Config.LevelsSystem.skillTypes) do
        local level, xp = getPlayerLevel(citizenid, skillType)
        levels[skillType] = {
            level = level,
            xp = xp,
            xpForNext = calculateXPForLevel(level + 1),
            label = Config.LevelsSystem.skillTypes[skillType].label
        }
    end
    return levels
end)

exports('setPlayerLevel', function(citizenid, skillType, level)
    if not Config.LevelsSystem.enabled then return false end
    if not Config.LevelsSystem.skillTypes[skillType] then return false end

    local maxLevel = Config.LevelsSystem.skillTypes[skillType].maxLevel
    if level > maxLevel then level = maxLevel end
    if level < 1 then level = 1 end

    local xpForLevel = calculateXPForLevel(level)

    MySQL.update('UPDATE 2whiffycrafting_levels SET level = ?, xp = ? WHERE citizenid = ? AND skill_type = ?', {
        level, xpForLevel, citizenid, skillType
    })

    -- Update cache
    local cacheKey = citizenid .. '_' .. skillType
    playerLevels[cacheKey] = {level = level, xp = xpForLevel}

    return true
end)

exports('resetPlayerLevels', function(citizenid)
    if not Config.LevelsSystem.enabled then return false end

    MySQL.query('DELETE FROM 2whiffycrafting_levels WHERE citizenid = ?', {citizenid})

    -- Clear cache for this player
    for skillType, _ in pairs(Config.LevelsSystem.skillTypes) do
        local cacheKey = citizenid .. '_' .. skillType
        playerLevels[cacheKey] = nil
    end

    return true
end)

-- Main exports
exports('getPlayerLevel', getPlayerLevel)
exports('updatePlayerXP', updatePlayerXP)
exports('checkLevelRequirement', checkLevelRequirement)
exports('awardCraftingXP', awardCraftingXP)

-- Initialize on resource start
CreateThread(function()
    Wait(1000) -- Wait for database connection
    initializeLevelsSystem()
end)

-- Admin commands (if debug is enabled)
if Config.Debug then
    RegisterCommand('setcraftinglevel', function(source, args)
        if source == 0 or it.hasPermission(source, 'admin') then -- Console or admin only
            if #args < 3 then
                print('Usage: /setcraftinglevel <citizenid> <skillType> <level>')
                return
            end

            local citizenid = args[1]
            local skillType = args[2]
            local level = tonumber(args[3])

            if not level or level < 1 then
                print('Invalid level')
                return
            end

            local success = exports['it-crafting']:setPlayerLevel(citizenid, skillType, level)
            if success then
                print(('Set %s %s level to %d'):format(citizenid, skillType, level))
            else
                print('Failed to set level')
            end
        end
    end, true)

    RegisterCommand('getcraftinglevel', function(source, args)
        if source == 0 or it.hasPermission(source, 'admin') then -- Console or admin only
            if #args < 2 then
                print('Usage: /getcraftinglevel <citizenid> <skillType>')
                return
            end

            local citizenid = args[1]
            local skillType = args[2]

            local level, xp = exports['it-crafting']:getPlayerLevel(citizenid, skillType)
            print(('Player %s %s: Level %d, XP %d'):format(citizenid, skillType, level, xp))
        end
    end, true)
end

-- Clear cache when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    local player = it.getPlayer(src)
    if not player then return end

    local citizenid = it.getCitizenId(src)

    -- Clear cache for this player
    for skillType, _ in pairs(Config.LevelsSystem.skillTypes) do
        local cacheKey = citizenid .. '_' .. skillType
        playerLevels[cacheKey] = nil
    end
end)
