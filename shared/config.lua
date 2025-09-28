Config = Config or {}
Locales = Locales or {}

-- ┌───────────────────────────────────┐
-- │  ____                           _ │
-- │ / ___| ___ _ __   ___ _ __ __ _| |│
-- │| |  _ / _ \ '_ \ / _ \ '__/ _` | |│
-- │| |_| |  __/ | | |  __/ | | (_| | |│
-- │ \____|\___|_| |_|\___|_|  \__,_|_|│
-- └───────────────────────────────────┘

--[[
    The first thing to do is to set which framework, inventory and target system the server uses
    The system will automatically detect the framework, inventory and target system if you set it to 'autodetect'
    If you are using a custom framework, inventory or target system contact the developer or add support yourself by creating a pull request
    If you need need more information about this configuration, you can read the documentation here: https://docs.it-scripts.com/scripts/it-crafting
]]

Config.Framework = 'qb-core' -- Choose your framework ('qb-core', 'es_extended', 'ND_Core' 'autodetect')
Config.Inventory = 'ox_inventory' -- Choose your inventory ('ox_inventory', 'qb-inventory', 'es_extended', 'origen_inventory', 'codem-inventory', 'autodetect')
Config.Target = 'ox_target' -- false -- Target system ('ox_target' or false to disable)

--[[
    Here you can set the language for the script, you can choose between 'en', 'es', 'de'
    If you want to add more languages, you can do this in the server/locales folder. 
    Feel free to share them with us so we can add them to the script for everyone to use.
]]

Config.Language = 'en' -- Choose your language from the locales folder

--[[
    Here you can set some generale settings regarding to the some features of the script.
    You can set the distance for the raycasting, the time a fire will burn and if the script should clear dead plants on start-up.
    You can also set the player plant limit, this is the maximum amount of plants a player can have simultaneously.
]]
Config.rayCastingDistance = 7.0 -- distance in meters
Config.UseWeightSystem = true -- Set to true to use the weight system
Config.PlayerTableLimit = 3 -- Maximum amount of tables a player can have
Config.MinDistanceToTable = 3.0 -- Minimum distance to a table to interact with it

-- Zones system has been removed

-- ┌─────────────────────────────────────────────────────────────────────┐
-- │  _                    _       ____            _                    │
-- │ | |    _____   _____| |___  / ___| _   _ ___| |_ ___ _ __ ___      │
-- │ | |   / _ \ \ / / _ \ / __| \___ \| | | / __| __/ _ \ '_ ` _ \     │
-- │ | |__|  __/\ V /  __/ \__ \  ___) | |_| \__ \ ||  __/ | | | | |    │
-- │ |_____\___| \_/ \___|_|___/ |____/ \__, |___/\__\___|_| |_| |_|    │
-- │                                    |___/                           │
-- └─────────────────────────────────────────────────────────────────────┘
Config.LevelsSystem = {
    enabled = true, -- Enable/disable the levels system

    -- Skill types for different crafting categories
    skillTypes = {
        ['standard_crafting'] = {
            label = 'Standard Crafting',
            maxLevel = 50,       -- Configurable max level
            startingLevel = 1,
            startingXP = 0,
        },
        ['weapons_crafting'] = {
            label = 'Weapons Crafting',
            maxLevel = 100,       -- Configurable max level
            startingLevel = 1,
            startingXP = 0,
        }
    },

    -- XP calculation formula: baseXP * (1 + (level * multiplier))
    xpCalculation = {
        baseXP = 200,        -- Base XP required for level 1->2
        multiplier = 0.2,    -- XP increase per level (10% per level)
    },

    -- Level configuration
    levelConfig = {
        ['standard_crafting'] = {
            maxLevel = 50,       -- Maximum level for standard crafting
        },
        ['weapons_crafting'] = {
            maxLevel = 100,       -- Maximum level for weapons crafting
        }
    },

    -- Tool configuration
    toolConfig = {
        enabled = true,              -- Enable/disable tool requirements
        consumeOnUse = false,        -- Global setting: consume tools on use (can be overridden per recipe)
        durabilityEnabled = false,   -- Enable tool durability system (future feature)

        -- Tool categories and their items
        tools = {
            ['hammer'] = {
                items = {'WEAPON_HAMMER', 'hammer', 'crafting_hammer'},
                label = 'Hammer',
                description = 'Used for metalworking and assembly'
            },
            ['saw'] = {
                items = {'saw', 'handsaw', 'crafting_saw'},
                label = 'Saw',
                description = 'Used for cutting wood and materials'
            },
            ['screwdriver'] = {
                items = {'screwdriver', 'crafting_screwdriver'},
                label = 'Screwdriver',
                description = 'Used for assembly and disassembly'
            },
            ['pliers'] = {
                items = {'pliers', 'crafting_pliers'},
                label = 'Pliers',
                description = 'Used for gripping and bending'
            },
            ['scissors'] = {
                items = {'scissors', 'crafting_scissors'},
                label = 'Scissors',
                description = 'Used for cutting fabric and materials'
            },
            ['drill'] = {
                items = {'drill', 'crafting_drill'},
                label = 'Drill',
                description = 'Used for making holes and precision work'
            },
            ['welding_torch'] = {
                items = {'welding_torch', 'torch'},
                label = 'Welding Torch',
                description = 'Used for welding and metalwork'
            },
            ['file'] = {
                items = {'file', 'metal_file'},
                label = 'File',
                description = 'Used for smoothing and shaping'
            }
        }
    },

    -- Integration settings for external resources
    integration = {
        enabled = true,                    -- Enable external integration
        resourceName = 'your-skills-resource', -- Name of your skills tracking resource
        exportName = 'updateSkillXP',     -- Export function name to call
        eventName = '2WhiffyCrafting:levelUp', -- Event name to trigger
        useExport = true,                 -- Use export (true) or event (false)
    }
}


Config.Recipes = {
    ['lockpick'] = {
        label = 'Lockpick',
        ingrediants = {
            ['scrapmetal'] = {amount = 3, remove = true},
        },
        tools = {
            ['hammer'] = {amount = 1, remove = false}, -- Uses any hammer from tool config
            ['file'] = {amount = 1, remove = false}    -- Also needs a file for shaping
        },
        outputs = {
            ['lockpick'] = 2
        },
        processTime = 15,
        showIngrediants = false,
        animation = {
            dict = 'anim@amb@drug_processors@coke@female_a@idles',
            anim = 'idle_a',
        },
        levelRequirement = {
            skillType = 'standard_crafting',
            level = 1
        },
        xpReward = 10 -- XP given when crafting this item
    },
    ['bandage'] = {
        label = 'Bandage',
        ingrediants = {
            ['cloth'] = {amount = 3, remove = true},
        },
        tools = {
            ['scissors'] = {amount = 1, remove = false} -- Uses any scissors from tool config
        },
        outputs = {
            ['bandage'] = 2
        },
        processTime = 15,
        showIngrediants = true,
        animation = {
            dict = 'anim@amb@drug_processors@coke@female_a@idles',
            anim = 'idle_a',
        },
        levelRequirement = {
            skillType = 'standard_crafting',
            level = 5
        },
        xpReward = 15 -- XP given when crafting this item
    },

    -- Example weapon recipes (add your own weapons here)
    ['weapon_pistol'] = {
        label = 'Pistol',
        ingrediants = {
            ['steel'] = {amount = 5, remove = true},
            ['gunpowder'] = {amount = 3, remove = true},
            ['weapon_parts'] = {amount = 2, remove = true}
        },
        tools = {
            ['drill'] = {amount = 1, remove = false},        -- For precision holes
            ['file'] = {amount = 1, remove = false},         -- For smoothing parts
            ['screwdriver'] = {amount = 1, remove = false}   -- For assembly
        },
        outputs = {
            ['WEAPON_PISTOL'] = 1
        },
        processTime = 30,
        showIngrediants = true,
        animation = {
            dict = 'anim@amb@drug_processors@coke@female_a@idles',
            anim = 'idle_a',
        },
        levelRequirement = {
            skillType = 'weapons_crafting',
            level = 5
        },
        xpReward = 50 -- Higher XP for weapons
    },

    ['weapon_knife'] = {
        label = 'Combat Knife',
        ingrediants = {
            ['steel'] = {amount = 2, remove = true},
            ['rubber'] = {amount = 1, remove = true}
        },
        tools = {
            ['hammer'] = {amount = 1, remove = false},       -- For shaping the blade
            ['file'] = {amount = 1, remove = false},         -- For sharpening
            ['welding_torch'] = {amount = 1, remove = false} -- For handle attachment
        },
        outputs = {
            ['WEAPON_KNIFE'] = 1
        },
        processTime = 20,
        showIngrediants = true,
        animation = {
            dict = 'anim@amb@drug_processors@coke@female_a@idles',
            anim = 'idle_a',
        },
        levelRequirement = {
            skillType = 'weapons_crafting',
            level = 1
        },
        xpReward = 25 -- Medium XP for basic weapons
    }
}

-- Crafting points system has been removed

-- ┌─────────────────────────────────────────────────────────────────────┐
-- │  ____            __ _   _               _____     _     _           │
-- │ / ___|_ __ __ _ / _| |_(_)_ __   __ _  |_   _|_ _| |__ | | ___  ___ │
-- │| |   | '__/ _` | |_| __| | '_ \ / _` |   | |/ _` | '_ \| |/ _ \/ __|│
-- │| |___| | | (_| |  _| |_| | | | | (_| |   | | (_| | |_) | |  __/\__ \│
-- │ \____|_|  \__,_|_|  \__|_|_| |_|\__, |   |_|\__,_|_.__/|_|\___||___/│
-- │                                 |___/                               │
-- └─────────────────────────────────────────────────────────────────────┘
Config.CraftingTables = { -- Create processing table
    ['simple_crafting_table'] = {
        target = {
            size = vector3(2.0, 1.0, 2.0),
            rotation = 90.0,
            drawSprite = true,
            interactDistance = 1.5,
        },
        label = 'Crafting Table', -- Label for the table
        model = 'prop_tool_bench02_ld', -- Exanples: freeze_it-scripts_empty_table, freeze_it-scripts_weed_table, freeze_it-scripts_coke_table, freeze_it-scripts_meth_table
        restricCrafting = {
            ['onlyOnePlayer'] = true, -- Only one player can use the table at a time
            ['onlyOwnerCraft'] = false, -- Only the owner of the table can use it
            ['onlyOwnerRemove'] = true, -- Only the owner of the table can remove it
            ['zones'] = {}, -- Zones where the table can be used
            ['jobs'] = {}
        },
        -- Blips removed - benches obtained elsewhere
        skillType = 'standard_crafting', -- Skill type for this table
        recipes = {'lockpick', 'bandage'}
    },
    ['weapons_crafting_table'] = {
        target = {
            size = vector3(2.5, 1.5, 2.0),
            rotation = 0.0,
            drawSprite = true,
            interactDistance = 1.5,
        },
        label = 'Weapons Crafting Bench', -- Label for the table
        model = 'gr_prop_gr_bench_01b', -- Weapons crafting bench model
        restricCrafting = {
            ['onlyOnePlayer'] = true, -- Only one player can use the table at a time
            ['onlyOwnerCraft'] = false, -- Only the owner of the table can use it
            ['onlyOwnerRemove'] = true, -- Only the owner of the table can remove it
            ['zones'] = {}, -- Zones where the table can be used
            ['jobs'] = {}
        },
        -- Blips removed - benches obtained elsewhere
        skillType = 'weapons_crafting', -- Skill type for this table
        recipes = {'weapon_pistol', 'weapon_knife'} -- Example weapon recipes
    }
}


--[[
    Debug mode, you can see all kinds of prints/logs using debug,
    but it's only for development.
]]
Config.ManualDatabaseSetup = false -- Set to true to disable the automatic database setup and check

Config.EnableVersionCheck = true -- Enable version check
Config.Branch = 'main' -- Set to 'master' to use the master branch, set to 'development' to use the dev branch
Config.Debug = false -- Set to true to enable debug mode
Config.DebugPoly = false -- Set to true to enable debug mode for PolyZone