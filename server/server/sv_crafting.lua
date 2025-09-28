lib.callback.register('it-crafting:server:getRecipes', function(source, type, id)
    if Config.Debug then lib.print.info('[getRecipes] - Try to get Recipes from Table with ID:', id) end
    if type == 'table' then
        if not CraftingTables[id] then
            if Config.Debug then lib.print.error('[getRecipes | Debug] - Table with ID:', id, 'not found') end
            return nil
        end
        if Config.Debug then lib.print.info('[getRecipes | Debug] - Recipes from Table with ID:', id, 'found') end
        return CraftingTables[id]:getRecipes()
    end
    if Config.Debug then lib.print.error('[getRecipes | Debug] - type', type, 'is invalid!') end
    return nil
end)

lib.callback.register('it-crafting:server:getRecipeById', function(source, type, craftId, recipeId)

    if Config.Debug then lib.print.info('[getRecipeById] - Try to get Recipe with ID:', recipeId, 'from Table with ID:', tableId) end
    local currentTable = nil
    if type == 'table' then
        currentTable = CraftingTables
    else
        if Config.Debug then lib.print.error('[getRecipeById] - type', type, 'is invalid!') end
        return nil
    end

    if not currentTable[craftId] then
        if Config.Debug then lib.print.error('[getRecipeById] - Table with ID:', craftId, 'not found') end
        return nil
    end

    local currentPoint = currentTable[craftId]

    local recipe = currentPoint:getRecipeData(recipeId)

    if not recipe then
        if Config.Debug then lib.print.error('[getRecipeById] - Recipe with ID:', recipeId, 'not found') end
        return nil
    end

    if Config.Debug then lib.print.info('[getRecipeById] - Recipe with ID:', recipeId, 'from CraftID:', craftId, 'found') end
    return recipe
end)

lib.callback.register('it-crafting:server:getDataById', function(source, type, id)
    
    if Config.Debug then lib.print.info('[getDataById | Debug] - Try to get Table with ID:', id) end

    if type == 'table' then
        if not CraftingTables[id] then
            if Config.Debug then lib.print.error('[getDataById | Debug] - Table with ID:', id, 'not found') end
            return nil
        end
        if Config.Debug then lib.print.info('[getDataById | Debug] - Table with ID:', id, 'found') end
        return CraftingTables[id]:getData()
    end

    if Config.Debug then lib.print.error('[getDataById | Debug] - type', type, 'is invalid!') end
    return nil
end)

lib.callback.register('it-crafting:server:getTableByNetId', function(source, netId)
        
    if Config.Debug then lib.print.info('[getTableByNetId] - Try to get Table with NetID:', netId) end

    for _, processingTable in pairs(CraftingTables) do
        if processingTable.netId == netId then
            if Config.Debug then lib.print.info('[getTableByNetId] - Table with NetID:', netId, 'found') end
            return processingTable:getData()
        end
    end

    if Config.Debug then lib.print.error('[getTableByNetId] - Table with NetID:', netId, 'not found') end
    return nil
end)

lib.callback.register('it-crafting:server:getTableByOwner', function(source)

    local src = source
    local citId = it.getCitizenId(src)
    if Config.Debug then lib.print.info('[getTableByOwner] - Try to get Table with Owner:', citId) end

    local temp = {}

    for k, v in pairs(CraftingTables) do
        if v.owner == citId then
            temp[k] = v:getData()
        end
    end

    if not next(temp) then
        if Config.Debug then lib.print.error('[getTableByOwner] - Table with Owner:', source, 'not found') end
        return nil
    end

    if Config.Debug then lib.print.info('[getTableByOwner] - Table with Owner:', source, 'found') end
    return temp
end)

lib.callback.register('it-crafting:server:inUse', function(source, type, id)
    if Config.Debug then lib.print.info('[inUse] - Try to get Table with ID:', id) end

    if type == 'table' then
        if not CraftingTables[id] then
            if Config.Debug then lib.print.error('[inUse | Debug] - Table with ID:', id, 'not found') end
            return nil
        end
        if Config.Debug then lib.print.info('[inUse | Debug] - Table with ID:', id, 'found') end
        return CraftingTables[id].inUse
    end

    if Config.Debug then lib.print.error('[inUse | Debug] - type', type, 'is invalid!') end
    return nil
end)

lib.callback.register('it-crafting:server:updateUse', function(source, type, id, inUse)
    if Config.Debug then lib.print.info('[updateUse] - Try to get Table with ID:', id) end

    if type == 'table' then
        if not CraftingTables[id] then
            if Config.Debug then lib.print.error('[updateUse | Debug] - Table with ID:', id, 'not found') end
            return nil
        end
        if Config.Debug then lib.print.info('[updateUse | Debug] - Table with ID:', id, 'found') end
        CraftingTables[id]:useTable(inUse)
        return true
    end

    if Config.Debug then lib.print.error('[updateUse | Debug] - type', type, 'is invalid!') end
    return false
end)

lib.callback.register('it-crafting:server:getTables', function(source)
    local temp = {}

    for k, v in pairs(CraftingTables) do
        temp[k] = v:getData()
    end

    return temp
end)

-- Crafting points callback removed

--- Method to setup all the weedplants, fetched from the database
--- @return nil
local setupTables = function()
    local result = MySQL.query.await('SELECT * FROM it_crafting_tables')

    if not result then return false end
    
    if Config.Debug then lib.print.info('[setupTables] - Found', #result, 'tables in the database') end

    for i = 1, #result do
        local v = result[i]

        if not Config.CraftingTables[v.type] then
            MySQL.query('DELETE FROM it_crafting_tables WHERE id = :id', {
                ['id'] = v.id
            }, function()
                lib.print.info('[setupTables] - Table with ID:', v.id, 'has a invalid type, deleting it from the database') 
            end)
        elseif not v.owner then
            MySQL.query('DELETE FROM it_crafting_tables WHERE id = :id', {
                ['id'] = v.id
            }, function()
                lib.print.info('[setupTables] - Table with ID:', v.id, 'has no owner, deleting it from the database')
            end)
        else
            local coords = json.decode(v.coords)
            local currentTable = CraftingTable:new(v.id, {
                entity = nil,
                coords = vector3(coords.x, coords.y, coords.z),
                rotation = v.rotation + .0,
                owner = v.owner,
                tableType = v.type
            })


            local recipes = Config.CraftingTables[v.type].recipes
            for _, recipeId in pairs(recipes) do
                if currentTable:getRecipeData(recipeId) then
                    if Config.Debug then lib.print.info('[setupTables] - Table with ID:', v.id, 'already has recipe with ID:', recipeId) end
                else
                    if not Config.Recipes[recipeId] then
                        if Config.Debug then lib.print.error('[setupTables] - Recipe with ID:', recipeId, 'not found') end
                    else
                        local recipe = Recipe:new(recipeId, Config.Recipes[recipeId])
                        currentTable:addRecipe(recipeId, recipe)
                    end
                end
            end

            currentTable:spawn()
        end
    end
    TriggerClientEvent('it-crafting:client:syncTables', -1, CraftingTables)
    return true
end

-- Crafting points setup removed

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    while not DatabaseSetuped do
        Wait(100)
    end
    if Config.Debug then lib.print.info('Setting up Processing Tables') end
    while not setupTables() do
        Wait(100)
    end

    -- Crafting points setup removed

    updateThread()
end)

--- Thread to check if the entities are still valid
function updateThread()
    for _, craftingTable in pairs(CraftingTables) do
        if craftingTable.entity then
            -- Check if entity is still valid
            if not DoesEntityExist(craftingTable.entity) then
                if Config.Debug then lib.print.warn('[updateThread] - Table with ID:', craftingTable.id, 'entity does not exist. Try to respawn') end
                craftingTable:destroyProp()
                craftingTable:spawn()
            end
        end
    end

    -- Crafting points update removed

    SetTimeout(1000 * 60, updateThread)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    
    for _, craftinTable in pairs(CraftingTables) do
        craftinTable:delete()
    end

    -- Crafting points cleanup removed
end)

RegisterNetEvent('it-crafting:server:craftItem', function(type, data)

    local currentTable = {}
    if type == 'table' then
        currentTable = CraftingTables
    else
        lib.print.error('[Crafting] - Invalid type:', type)
        return
    end

    if not currentTable[data.tableId] then return end
    local craftingAction = currentTable[data.tableId]
    local recipe = craftingAction:getRecipeData(data.recipeId)
    if #(GetEntityCoords(GetPlayerPed(source)) - craftingAction.coords) > 10 then return end

    local player = it.getPlayer(source)
    --local tableInfos = Config.ProcessingTables[processingTables[entity].type]

    if not player then return end
    local givenItems = {}

    -- Check tool requirements first
    if Config.LevelsSystem.toolConfig.enabled and recipe.tools then
        for toolCategory, toolData in pairs(recipe.tools) do
            local hasRequiredTool = false
            local foundToolItem = nil

            -- Check if player has any of the tools in this category
            if Config.LevelsSystem.toolConfig.tools[toolCategory] then
                for _, toolItem in pairs(Config.LevelsSystem.toolConfig.tools[toolCategory].items) do
                    if it.hasItem(source, toolItem, toolData.amount) then
                        hasRequiredTool = true
                        foundToolItem = toolItem
                        break
                    end
                end
            end

            if not hasRequiredTool then
                local toolLabel = Config.LevelsSystem.toolConfig.tools[toolCategory] and Config.LevelsSystem.toolConfig.tools[toolCategory].label or toolCategory
                ShowNotification(source, ('You need a %s to craft this item'):format(toolLabel), 'error')
                return
            end

            -- Remove tool if configured to do so (either globally or per recipe)
            local shouldRemoveTool = toolData.remove
            if shouldRemoveTool == nil then
                shouldRemoveTool = Config.LevelsSystem.toolConfig.consumeOnUse
            end

            if shouldRemoveTool and foundToolItem then
                if not it.removeItem(source, foundToolItem, toolData.amount) then
                    ShowNotification(source, ('Failed to consume %s'):format(foundToolItem), 'error')
                    return
                else
                    table.insert(givenItems, {name = foundToolItem, amount = toolData.amount})
                end
            end
        end
    end

    -- Fail chance removed - crafting always succeeds if ingredients are available

    for k, v in pairs(recipe.ingrediants) do
        if v.remove then
            if not it.removeItem(source, k, v.amount) then
                ShowNotification(source, _U('NOTIFICATION__MISSING__INGIDIANT'), 'error')
                if #givenItems > 0 then
                    for _, x in pairs(givenItems) do
                        it.giveItem(source, x.name, x.amount)
                    end
                end
                return
            else
                table.insert(givenItems, {name = k, amount = v.amount})
            end
        end
    end

    for k, v in pairs(recipe.outputs) do
        it.giveItem(source, k, v)
    end

    -- Award XP for successful crafting
    if Config.LevelsSystem.enabled then
        local tableData = Config.CraftingTables[craftingAction.tableType]
        if tableData and tableData.skillType then
            local citizenid = it.getCitizenId(source)
            local recipeData = Config.Recipes[data.recipeId]
            if citizenid and recipeData then
                exports['2WhiffyCrafting']:awardCraftingXP(citizenid, tableData.skillType, recipeData)
            end
        end
    end

    local messageData = craftingAction:getData()
    messageData.recipe = recipe

    SendToWebhook(source, type, 'craft', messageData)
end)


RegisterNetEvent('it-crafting:server:removeTable', function(args)

    if not CraftingTables[args.tableId] then return end

    local craftingTable = CraftingTables[args.tableId]

    if not args.extra then
        if #(GetEntityCoords(GetPlayerPed(source)) - craftingTable.coords) > 10 then return end
        it.giveItem(source, craftingTable.tableType, 1)
    end

    MySQL.query('DELETE from it_crafting_tables WHERE id = :id', {
        ['id'] = args.tableId
    })

    local tableData = craftingTable:getData()
    SendToWebhook(source, 'table', 'remove', tableData)

    craftingTable:delete()
    TriggerClientEvent('it-crafting:client:syncTables', -1, CraftingTables)
end)

RegisterNetEvent('it-crafting:server:createNewTable', function(coords, type, rotation, metadata)
    local src = source
    local player = it.getPlayer(src)

    if not player then if Config.Debug then lib.print.error("No Player") end return end
    if #(GetEntityCoords(GetPlayerPed(src)) - coords) > Config.rayCastingDistance + 10 then return end
    local itemRemoved = false
    if it.inventory == 'ox' then
        itemRemoved = true
    else
        itemRemoved = it.removeItem(src, type, 1, metadata)
    end
    if itemRemoved then

        local id = it.generateCustomID(8)
        while CraftingTables[id] do
            id = it.generateCustomID(8)
        end
        
        MySQL.insert('INSERT INTO `it_crafting_tables` (id, coords, type, rotation, owner) VALUES (:id, :coords, :type, :rotation, :owner)', {
            ['id'] = id,
            ['coords'] = json.encode(coords),
            ['type'] = type,
            ['rotation'] = rotation,
            ['owner'] = it.getCitizenId(src)
        }, function()
            local currentTable = CraftingTable:new(id, {
                entity = nil,
                coords = coords,
                rotation = rotation,
                owner = it.getCitizenId(src),
                tableType = type
            })

            local recipes = Config.CraftingTables[type].recipes
            for _, recipeId in pairs(recipes) do
                if currentTable:getRecipeData(recipeId) then
                    if Config.Debug then lib.print.info('[setupTables] - Table with ID:', v.id, 'already has recipe with ID:', recipeId) end
                else
                    if not Config.Recipes[recipeId] then
                        if Config.Debug then lib.print.error('[setupTables] - Recipe with ID:', recipeId, 'not found') end
                    else
                        local recipe = Recipe:new(recipeId, Config.Recipes[recipeId])
                        currentTable:addRecipe(recipeId, recipe)
                    end
                end
            end

            currentTable:spawn()
            TriggerClientEvent('it-crafting:client:syncTables', -1, CraftingTables)
            local tableData = currentTable:getData()
            SendToWebhook(src, 'table', 'place', tableData)
        end)
    else
        if Config.Debug then lib.print.error("Can not remove item") end
    end
end)


RegisterNetEvent('it-crafting:server:syncparticlefx', function(status, tableId, netId, particlefx)
    TriggerClientEvent('it-crafting:client:syncparticlefx',-1, status, tableId, netId, particlefx)
end)
