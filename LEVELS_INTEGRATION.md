# Crafting Levels System Integration Guide

## Overview
The it-crafting script now includes a comprehensive levels system with separate tracking for standard crafting and weapons crafting. This system is fully configurable and can integrate with external skill tracking resources.

## Configuration

### Basic Setup
The levels system is configured in `shared/config.lua` under `Config.LevelsSystem`:

```lua
Config.LevelsSystem = {
    enabled = true, -- Enable/disable the levels system
    
    skillTypes = {
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
    },
    
    -- XP calculation and rewards...
}
```

### External Integration
To integrate with your existing skills resource:

```lua
integration = {
    enabled = true,
    resourceName = 'your-skills-resource',
    exportName = 'updateSkillXP',
    eventName = 'skills:updateXP',
    useExport = true, -- Use export (true) or event (false)
}
```

## Exports Available

### Server-side Exports

#### Get Player Level
```lua
local level, xp = exports['it-crafting']:getPlayerLevel(citizenid, skillType)
```

#### Update Player XP
```lua
local success, newLevel, newXP, leveledUp = exports['it-crafting']:updatePlayerXP(citizenid, skillType, xpGain)
```

#### Set Player Level (Admin)
```lua
local success = exports['it-crafting']:setPlayerLevel(citizenid, skillType, level)
```

#### Get All Player Levels
```lua
local levels = exports['it-crafting']:getAllPlayerLevels(citizenid)
```

#### Reset Player Levels
```lua
local success = exports['it-crafting']:resetPlayerLevels(citizenid)
```

#### Check Level Requirement
```lua
local hasRequirement = exports['it-crafting']:checkLevelRequirement(citizenid, recipe)
```

#### Award Crafting XP
```lua
exports['it-crafting']:awardCraftingXP(citizenid, skillType, recipe)
```

### Client-side Exports

#### Get Player Level (Client)
```lua
local level, xp = exports['it-crafting']:getPlayerLevel(skillType)
```

#### Show Levels Menu
```lua
exports['it-crafting']:showLevelsMenu()
```

#### Get All Player Levels (Client)
```lua
local levels = exports['it-crafting']:getAllPlayerLevels()
```

## Recipe Configuration

Add level requirements to recipes:

```lua
['your_recipe'] = {
    label = 'Your Recipe',
    -- ... other recipe config
    levelRequirement = {
        skillType = 'standard_crafting', -- or 'weapons_crafting'
        level = 10
    }
}
```

## Crafting Table Configuration

Assign skill types to crafting tables:

```lua
['your_table'] = {
    -- ... other table config
    skillType = 'standard_crafting', -- or 'weapons_crafting'
    recipes = {'your_recipe'}
}
```

## Events

### Client Events

#### Level Up Notification
```lua
RegisterNetEvent('it-crafting:client:levelUp', function(skillType, newLevel, oldLevel)
    -- Handle level up notification
end)
```

#### Show Levels Menu
```lua
TriggerEvent('it-crafting:client:showLevelsMenu')
```

### Server Events

#### Award XP
```lua
TriggerEvent('it-crafting:server:awardCraftingXP', skillType, recipeId)
```

## Database

The system automatically creates the `it_crafting_levels` table:

```sql
CREATE TABLE it_crafting_levels (
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

## Admin Commands (Debug Mode Only)

When `Config.Debug = true`, the following commands are available:

- `/setcraftinglevel <citizenid> <skillType> <level>` - Set a player's level
- `/getcraftinglevel <citizenid> <skillType>` - Get a player's level
- `/craftinglevels` - Show your levels menu (client)
- `/craftinglevel <skillType>` - Show specific skill level (client)

## Integration Examples

### With QB-Core Skills
```lua
-- In your skills resource
RegisterNetEvent('it-crafting:levelUp', function(skillType, newLevel, oldLevel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Update your skills system
    Player.Functions.SetMetaData('crafting_' .. skillType, newLevel)
end)
```

### With ESX Skills
```lua
-- In your skills resource
AddEventHandler('it-crafting:levelUp', function(playerId, skillType, newLevel, oldLevel)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    
    -- Update your skills system
    MySQL.update('UPDATE user_skills SET level = ? WHERE identifier = ? AND skill = ?', {
        newLevel, xPlayer.identifier, 'crafting_' .. skillType
    })
end)
```

## Customization

The levels system is highly configurable. You can:

- Add new skill types
- Modify XP calculations
- Change level requirements
- Customize integration methods
- Add custom notifications
- Modify the UI/UX

All configuration is centralized in `shared/config.lua` for easy management.
