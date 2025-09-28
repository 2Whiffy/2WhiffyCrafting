-- Add these items to your ox_inventory/data/items.lua file

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

-- Example crafting ingredients (add these if you don't have them already)
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
