# 2WhiffyCrafting Complete Reference Guide
*Modified from original IT-Crafting by @allroundjonu*

## Item Spawn Names

### Crafting Tables/Benches
```lua
-- Standard Crafting Table
'simple_crafting_table'

-- Weapons Crafting Bench  
'weapons_crafting_table'
```

### Example Recipes (Default)
```lua
-- Standard Crafting Items
'lockpick'        -- Lockpick tool (10 XP)
'bandage'         -- Medical bandage (15 XP)

-- Weapons Crafting Items (Examples)
'weapon_pistol'   -- Pistol (50 XP, Level 5 required)
'weapon_knife'    -- Combat Knife (25 XP, Level 1 required)
```

## Server-Side Exports

### Level Management
```lua
-- Get player's current level and XP for a skill type
local level, xp = exports['2WhiffyCrafting']:getPlayerLevel(citizenid, skillType)
-- Parameters: citizenid (string), skillType (string: 'standard_crafting' or 'weapons_crafting')
-- Returns: level (number), xp (number)

-- Update player's XP (automatically handles level ups)
local success, newLevel, newXP, leveledUp = exports['2WhiffyCrafting']:updatePlayerXP(citizenid, skillType, xpGain)
-- Parameters: citizenid (string), skillType (string), xpGain (number)
-- Returns: success (boolean), newLevel (number), newXP (number), leveledUp (boolean)

-- Set player's level directly (admin function)
local success = exports['2WhiffyCrafting']:setPlayerLevel(citizenid, skillType, level)
-- Parameters: citizenid (string), skillType (string), level (number)
-- Returns: success (boolean)

-- Get all skill levels for a player
local levels = exports['2WhiffyCrafting']:getAllPlayerLevels(citizenid)
-- Parameters: citizenid (string)
-- Returns: table with skill data
--[[
Example return:
{
    ['standard_crafting'] = {
        level = 5,
        xp = 150,
        xpForNext = 200,
        label = 'Standard Crafting'
    },
    ['weapons_crafting'] = {
        level = 3,
        xp = 75,
        xpForNext = 120,
        label = 'Weapons Crafting'
    }
}
]]--

-- Reset all levels for a player
local success = exports['2WhiffyCrafting']:resetPlayerLevels(citizenid)
-- Parameters: citizenid (string)
-- Returns: success (boolean)

-- Check if player meets level requirement for a recipe
local hasRequirement = exports['2WhiffyCrafting']:checkLevelRequirement(citizenid, recipe)
-- Parameters: citizenid (string), recipe (table)
-- Returns: hasRequirement (boolean)

-- Award XP for crafting (called automatically)
exports['2WhiffyCrafting']:awardCraftingXP(citizenid, skillType, recipe)
-- Parameters: citizenid (string), skillType (string), recipe (table)
```

## Client-Side Exports

### Level Information
```lua
-- Get player's level for a skill type (client-side cached)
local level, xp = exports['2WhiffyCrafting']:getPlayerLevel(skillType)
-- Parameters: skillType (string)
-- Returns: level (number), xp (number)

-- Get all player levels (client-side)
local levels = exports['2WhiffyCrafting']:getAllPlayerLevels()
-- Returns: same format as server-side getAllPlayerLevels

-- Show the levels menu UI
exports['2WhiffyCrafting']:showLevelsMenu()

-- Check level requirement (client-side)
local hasRequirement = exports['2WhiffyCrafting']:checkLevelRequirement(recipeId)
-- Parameters: recipeId (string)
-- Returns: hasRequirement (boolean)
```

## Server-Side Events

### Level Management Events
```lua
-- Award XP to a player
TriggerEvent('2WhiffyCrafting:server:awardCraftingXP', skillType, recipeId)
-- Parameters: skillType (string), recipeId (string)
-- Note: Uses source for player identification
```

## Client-Side Events

### UI Events
```lua
-- Show levels menu
TriggerEvent('2WhiffyCrafting:client:showLevelsMenu')

-- Level up notification (triggered automatically)
RegisterNetEvent('2WhiffyCrafting:client:levelUp', function(skillType, newLevel, oldLevel)
    -- Handle level up notification
    -- Parameters: skillType (string), newLevel (number), oldLevel (number)
end)

-- Update level cache (triggered automatically)
RegisterNetEvent('2WhiffyCrafting:client:updateLevelCache', function(skillType, level, xp)
    -- Updates client-side cache
    -- Parameters: skillType (string), level (number), xp (number)
end)
```

## Database Schema

### 2whiffycrafting_levels Table
```sql
CREATE TABLE 2whiffycrafting_levels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL,
    skill_type VARCHAR(50) NOT NULL,
    level INT DEFAULT 1,
    xp INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_player_skill (citizenid, skill_type)
);
```

### 2whiffycrafting_tables Table (Existing)
```sql
-- Stores placed crafting tables
-- Columns: id, coords, rotation, owner, type, created_at
```

## XP System Details

### Item-Based XP Rewards
- XP is awarded per item crafted, not per level requirement
- Each recipe has its own `xpReward` value
- Standard crafting items: 10-20 XP typically
- Weapons crafting items: 25-100 XP typically
- No fail chances - crafting always succeeds if ingredients are available

### Level Limits (Configurable)
- Standard Crafting: Default max level 50 (configurable)
- Weapons Crafting: Default max level 25 (configurable)
- Modify in `Config.LevelsSystem.skillTypes[skillType].maxLevel`

## Configuration Structure

### Skill Types Configuration
```lua
Config.LevelsSystem.skillTypes = {
    ['standard_crafting'] = {
        label = 'Standard Crafting',
        maxLevel = 100,
        startingLevel = 1,
        startingXP = 0,
    },
    ['weapons_crafting'] = {
        label = 'Weapons Crafting',
        maxLevel = 100,
        startingLevel = 1,
        startingXP = 0,
    }
}
```

### XP Configuration
```lua
Config.LevelsSystem.xpCalculation = {
    baseXP = 100,        -- Base XP required for level 1->2
    multiplier = 0.1,    -- XP increase per level (10% per level)
}

-- Level limits (configurable)
Config.LevelsSystem.levelConfig = {
    ['standard_crafting'] = {
        maxLevel = 50,   -- Maximum level for standard crafting
    },
    ['weapons_crafting'] = {
        maxLevel = 25,   -- Maximum level for weapons crafting
    }
}
```

### Integration Configuration
```lua
Config.LevelsSystem.integration = {
    enabled = true,
    resourceName = 'your-skills-resource',
    exportName = 'updateSkillXP',
    eventName = 'skills:updateXP',
    useExport = true, -- Use export (true) or event (false)
}
```

## Admin Commands (Debug Mode Only)

```lua
-- Set player level (console/admin only)
/setcraftinglevel <citizenid> <skillType> <level>

-- Get player level (console/admin only)  
/getcraftinglevel <citizenid> <skillType>

-- Show levels menu (client)
/craftinglevels

-- Show specific skill level (client)
/craftinglevel <skillType>

-- Test levels system (server)
/testlevels
```

## Integration Examples

### QB-Core Integration
```lua
-- In your skills resource
RegisterNetEvent('it-crafting:client:levelUp', function(skillType, newLevel, oldLevel)
    local Player = QBCore.Functions.GetPlayerData()
    -- Update your QB-Core metadata or skills system
    TriggerServerEvent('qb-skills:server:updateSkill', 'crafting_' .. skillType, newLevel)
end)
```

### ESX Integration
```lua
-- In your skills resource server-side
AddEventHandler('it-crafting:levelUp', function(playerId, skillType, newLevel, oldLevel)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    -- Update your ESX skills system
    MySQL.update('UPDATE user_skills SET level = ? WHERE identifier = ? AND skill = ?', {
        newLevel, xPlayer.identifier, 'crafting_' .. skillType
    })
end)
```

### ox_inventory Integration
```lua
-- Add to ox_inventory/data/items.lua
['simple_crafting_table'] = {
    label = 'Crafting Table',
    weight = 5000,
    stack = false,
    close = true,
    description = 'A basic crafting table for creating items'
},

['weapons_crafting_table'] = {
    label = 'Weapons Crafting Bench',
    weight = 7500,
    stack = false,
    close = true,
    description = 'A specialized bench for crafting weapons'
},
```

## Recipe Configuration Format

```lua
['recipe_name'] = {
    label = 'Recipe Label',
    ingrediants = {
        ['item_name'] = {amount = 1, remove = true},  -- Consumed ingredients
        ['material'] = {amount = 2, remove = true}
    },
    tools = {
        ['hammer'] = {amount = 1, remove = false},    -- Tool category (not consumed by default)
        ['saw'] = {amount = 1, remove = true}         -- Tool that gets consumed (override)
    },
    outputs = {
        ['output_item'] = 1
    },
    processTime = 15, -- seconds
    showIngrediants = true,
    animation = {
        dict = 'animation_dict',
        anim = 'animation_name',
    },
    levelRequirement = {
        skillType = 'standard_crafting', -- or 'weapons_crafting'
        level = 1
    },
    xpReward = 10 -- XP given when crafting this item (item-based XP)
    -- Note: failChance removed - crafting always succeeds if ingredients available
    -- Note: skillCheck removed - using progress bar only
}
```

## Tool System Configuration

The tool system allows for flexible tool requirements:

```lua
Config.toolConfig = {
    enabled = true,              -- Enable/disable tool requirements globally
    consumeOnUse = false,        -- Global setting: consume tools on use (can be overridden per recipe)
    durabilityEnabled = false,   -- Enable tool durability system (future feature)

    tools = {
        ['hammer'] = {
            items = {'WEAPON_HAMMER', 'hammer', 'crafting_hammer'},  -- Any of these items work
            label = 'Hammer',
            description = 'Used for metalworking and assembly'
        },
        ['saw'] = {
            items = {'saw', 'handsaw', 'crafting_saw'},
            label = 'Saw',
            description = 'Used for cutting wood and materials'
        },
        -- Add more tool categories as needed
    }
}
```

### Tool Features:
- **Flexible Items**: Each tool category can accept multiple item types
- **Consumption Control**: Tools can be consumed or preserved per recipe
- **Global Override**: Set global consumption behavior with per-recipe overrides
- **UI Integration**: Tools show in crafting menus with status indicators
- **Validation**: Both client and server-side tool checking

## Crafting Table Configuration Format

```lua
['table_name'] = {
    target = {
        size = vector3(2.0, 1.0, 2.0),
        rotation = 90.0,
        drawSprite = true,
        interactDistance = 1.5,
    },
    label = 'Table Label',
    model = 'prop_model_name',
    restricCrafting = {
        ['onlyOnePlayer'] = true,
        ['onlyOwnerCraft'] = false,
        ['onlyOwnerRemove'] = true,
        ['zones'] = {},
        ['jobs'] = {}
    },
    skillType = 'standard_crafting', -- or 'weapons_crafting'
    recipes = {'recipe1', 'recipe2'}
}
```
