# 2WhiffyCrafting Implementation Summary
*Modified from original IT-Crafting by @allroundjonu*

## Changes Made

### ✅ 1. Removed Blips and Shop Functionality
- **Blips**: Completely removed from both crafting tables
- **Shops**: Confirmed no shop functionality exists - benches obtained externally
- **Result**: Clean system focused purely on crafting functionality

### ✅ 2. Item-Based XP System
- **XP per Item**: Each recipe now has individual `xpReward` values
- **No Fail Chances**: Removed all `failChance` logic - crafting always succeeds
- **Configurable Levels**: Separate max levels for each skill type

### ✅ 3. Configurable Level Limits
```lua
-- In shared/config.lua
Config.LevelsSystem.skillTypes = {
    ['standard_crafting'] = {
        maxLevel = 50,  -- Configurable
    },
    ['weapons_crafting'] = {
        maxLevel = 25,  -- Configurable
    }
}
```

## Item Spawn Names for ox_inventory

### Crafting Tables
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

### Example Recipe Items
```lua
-- Standard crafting ingredients
['scrapmetal'] = { label = 'Scrap Metal', weight = 100 },
['cloth'] = { label = 'Cloth', weight = 50 },
['scissors'] = { label = 'Scissors', weight = 200 },

-- Weapons crafting ingredients  
['steel'] = { label = 'Steel', weight = 500 },
['gunpowder'] = { label = 'Gunpowder', weight = 100 },
['weapon_parts'] = { label = 'Weapon Parts', weight = 300 },
['rubber'] = { label = 'Rubber', weight = 150 },
```

## Skills Resource Integration

### Server-Side Integration Example
```lua
-- In your skills resource server file
RegisterNetEvent('2WhiffyCrafting:levelUp', function(playerId, skillType, newLevel, oldLevel)
    local Player = GetPlayer(playerId) -- Your framework's get player function
    
    -- Update your skills system
    if skillType == 'standard_crafting' then
        -- Update standard crafting skill
        UpdatePlayerSkill(Player, 'crafting', newLevel)
    elseif skillType == 'weapons_crafting' then
        -- Update weapons crafting skill
        UpdatePlayerSkill(Player, 'weapons', newLevel)
    end
end)
```

### Configuration for External Integration
```lua
-- In shared/config.lua
Config.LevelsSystem.integration = {
    enabled = true,
    resourceName = 'your-skills-resource',
    exportName = 'updateSkillXP',
    eventName = 'skills:updateXP',
    useExport = true, -- Set to false to use events instead
}
```

## Key Exports for Skills Resource

### Get Player Level
```lua
local level, xp = exports['2WhiffyCrafting']:getPlayerLevel(citizenid, skillType)
```

### Update Player XP
```lua
local success, newLevel, newXP, leveledUp = exports['2WhiffyCrafting']:updatePlayerXP(citizenid, skillType, xpAmount)
```

### Set Player Level (Admin)
```lua
local success = exports['2WhiffyCrafting']:setPlayerLevel(citizenid, skillType, level)
```

### Get All Player Levels
```lua
local allLevels = exports['2WhiffyCrafting']:getAllPlayerLevels(citizenid)
```

## XP Values by Item

### Standard Crafting
- `lockpick`: 10 XP (Level 1 required)
- `bandage`: 15 XP (Level 5 required)

### Weapons Crafting (Examples)
- `weapon_knife`: 25 XP (Level 1 required)
- `weapon_pistol`: 50 XP (Level 5 required)

## Level Requirements

### Standard Crafting (Max Level 50)
- Level 1: Basic items (lockpick)
- Level 5: Medical items (bandage)
- Level 10+: Advanced items (add your own)

### Weapons Crafting (Max Level 25)
- Level 1: Basic weapons (knife)
- Level 5: Pistols
- Level 10+: Advanced weapons (add your own)

## Database Tables

### 2whiffycrafting_levels
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

## Files Modified/Created

### Modified Files
- `shared/config.lua` - Added levels system, removed blips, added XP per item
- `server/sv_crafting.lua` - Removed fail chances, added XP awarding
- `client/cl_crafting.lua` - Added level requirement checking
- `client/cl_menus.lua` - Added level requirement display
- `server/classes/class_craftingTable.lua` - Removed blip creation

### New Files
- `server/sv_levels.lua` - Complete levels system
- `client/cl_levels.lua` - Client-side levels interface
- `CRAFTING_REFERENCE.md` - Complete API reference
- `LEVELS_INTEGRATION.md` - Integration guide
- `IMPLEMENTATION_SUMMARY.md` - This summary

### Removed Files
- `client/cl_blips.lua` - No longer needed
- `server/classes/class_craftingPoint.lua` - Previously removed

## Next Steps

1. **Add items to ox_inventory** using the spawn names provided
2. **Configure your skills resource** to use the exports and events
3. **Add weapon recipes** to the weapons crafting table
4. **Test the integration** using the provided exports
5. **Customize XP values** and level requirements as needed

## Testing Commands (Debug Mode)

```lua
-- Server console
/setcraftinglevel <citizenid> <skillType> <level>
/getcraftinglevel <citizenid> <skillType>

-- Client
/craftinglevels  -- Show levels menu
/testlevels      -- Run test script
```

The system is now ready for production use with full external integration support!
