# ox_inventory Setup Instructions for 2WhiffyCrafting

## Problem
Items in inventory cannot be placed/used because ox_inventory integration is not properly configured.

## Solution Steps

### 1. Add Items to ox_inventory
You need to add the crafting table items to your `ox_inventory/data/items.lua` file.

**Location:** `resources/[ox]/ox_inventory/data/items.lua`

Add these items to the items table:

```lua
-- 2WhiffyCrafting Tables
['simple_crafting_table'] = {
    label = 'Crafting Table',
    weight = 5000,
    stack = false,
    close = true,
    description = 'A basic crafting table for creating items. Place it down to start crafting.',
    client = {
        image = 'simple_crafting_table.png', -- Add this image to ox_inventory/web/images/
    },
    server = {
        export = '2WhiffyCrafting.placeCraftingTable'
    }
},

['weapons_crafting_table'] = {
    label = 'Weapons Crafting Bench',
    weight = 7500,
    stack = false,
    close = true,
    description = 'A specialized bench for crafting weapons. Requires weapons crafting skill.',
    client = {
        image = 'weapons_crafting_table.png', -- Add this image to ox_inventory/web/images/
    },
    server = {
        export = '2WhiffyCrafting.placeCraftingTable'
    }
},

-- Crafting ingredients (add these if you don't have them already)
['scrapmetal'] = {
    label = 'Scrap Metal',
    weight = 100,
    stack = true,
    close = true,
    description = 'Pieces of scrap metal that can be used for crafting.',
    client = {
        image = 'scrapmetal.png',
    }
},

['cloth'] = {
    label = 'Cloth',
    weight = 50,
    stack = true,
    close = true,
    description = 'Soft fabric material used for crafting.',
    client = {
        image = 'cloth.png',
    }
},

['scissors'] = {
    label = 'Scissors',
    weight = 200,
    stack = false,
    close = true,
    description = 'Sharp cutting tool used for crafting.',
    client = {
        image = 'scissors.png',
    }
},

-- Weapons crafting ingredients
['steel'] = {
    label = 'Steel',
    weight = 500,
    stack = true,
    close = true,
    description = 'High-quality steel for weapon crafting.',
    client = {
        image = 'steel.png',
    }
},

['gunpowder'] = {
    label = 'Gunpowder',
    weight = 100,
    stack = true,
    close = true,
    description = 'Explosive powder used in weapon manufacturing.',
    client = {
        image = 'gunpowder.png',
    }
},

['weapon_parts'] = {
    label = 'Weapon Parts',
    weight = 300,
    stack = true,
    close = true,
    description = 'Various mechanical parts for weapon assembly.',
    client = {
        image = 'weapon_parts.png',
    }
},

['rubber'] = {
    label = 'Rubber',
    weight = 150,
    stack = true,
    close = true,
    description = 'Flexible rubber material for grips and handles.',
    client = {
        image = 'rubber.png',
    }
},

-- Crafting Tools
['WEAPON_HAMMER'] = {
    label = 'Hammer',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A heavy tool used for crafting and construction.',
    client = {
        image = 'weapon_hammer.png',
    }
},

['hammer'] = {
    label = 'Crafting Hammer',
    weight = 800,
    stack = false,
    close = true,
    description = 'A specialized hammer for crafting work.',
    client = {
        image = 'hammer.png',
    }
},

['saw'] = {
    label = 'Hand Saw',
    weight = 600,
    stack = false,
    close = true,
    description = 'A sharp saw for cutting materials.',
    client = {
        image = 'saw.png',
    }
},

['screwdriver'] = {
    label = 'Screwdriver',
    weight = 200,
    stack = false,
    close = true,
    description = 'A precision tool for assembly work.',
    client = {
        image = 'screwdriver.png',
    }
},

['pliers'] = {
    label = 'Pliers',
    weight = 300,
    stack = false,
    close = true,
    description = 'Gripping tool for bending and holding.',
    client = {
        image = 'pliers.png',
    }
},

['drill'] = {
    label = 'Electric Drill',
    weight = 1200,
    stack = false,
    close = true,
    description = 'A power tool for making precise holes.',
    client = {
        image = 'drill.png',
    }
},

['welding_torch'] = {
    label = 'Welding Torch',
    weight = 1500,
    stack = false,
    close = true,
    description = 'A high-temperature tool for welding metals.',
    client = {
        image = 'welding_torch.png',
    }
},

['file'] = {
    label = 'Metal File',
    weight = 250,
    stack = false,
    close = true,
    description = 'A tool for smoothing and shaping metal.',
    client = {
        image = 'file.png',
    }
},
```

### 2. Add Item Images
Add the corresponding PNG images to `ox_inventory/web/images/` folder:
- simple_crafting_table.png
- weapons_crafting_table.png
- scrapmetal.png
- cloth.png
- scissors.png
- steel.png
- gunpowder.png
- weapon_parts.png
- rubber.png
- weapon_hammer.png
- hammer.png
- saw.png
- screwdriver.png
- pliers.png
- drill.png
- welding_torch.png
- file.png

### 3. Restart Resources
After making these changes:
1. Restart ox_inventory: `restart ox_inventory`
2. Restart 2WhiffyCrafting: `restart 2WhiffyCrafting`

### 4. Test the Items
1. Give yourself a crafting table: `/giveitem simple_crafting_table 1`
2. Try to use it from your inventory
3. Check the server console for debug messages (debug mode is now enabled)

### 5. Troubleshooting
If items still don't work, follow these steps:

1. **Check server console for error messages** when starting the resource
2. **Verify ox_inventory is running**: `ensure ox_inventory`
3. **Test the debug command**: `/testcrafting` (this will give you a crafting table and show debug info)
4. **Look for these debug messages in console**:
   - `[2WhiffyCrafting] Using configured inventory: ox`
   - `[2WhiffyCrafting] ox_inventory export registered: placeCraftingTable`
   - When using an item: `[placeCraftingTable] Export called!`

5. **Common Issues**:
   - **Resource name mismatch**: Make sure your resource folder is named exactly `2WhiffyCrafting`
   - **ox_inventory not detecting items**: Restart ox_inventory after adding items
   - **Export not working**: Check that the export line in items.lua is exactly: `export = '2WhiffyCrafting.placeCraftingTable'`
   - **Framework detection**: Make sure qb-core is running and detected

6. **Manual verification**:
   ```
   # In server console, check if export exists:
   # This should return a function, not nil
   exports['2WhiffyCrafting']:placeCraftingTable
   ```

### 6. Debug Output Example
When working correctly, you should see:
```
[2WhiffyCrafting] Using configured inventory: ox
[2WhiffyCrafting] ox_inventory export registered: placeCraftingTable
[placeCraftingTable] Export called!
[placeCraftingTable] Event: usingItem
[placeCraftingTable] Processing usingItem event
```

## Important Notes
- The `server.export` field in the item definition tells ox_inventory to call the `placeCraftingTable` export from the `2WhiffyCrafting` resource when the item is used
- Debug mode is now enabled to help troubleshoot issues
- The export is declared in the fxmanifest.lua file
- Use `/testcrafting` command to test the system (debug mode only)
