if not Config.Target then return end

-- Crafting points zones removed
local craftingTablesZones = {}


local function checkIfPlayerCanUseTable(targetType, targetData)
    local extendedCraftingData = nil
    if targetType == 'table' then
        extendedCraftingData = Config.CraftingTables[targetData.tableType]
    -- Crafting points removed
    else
        lib.print.error('Invalid craftingType:', targetType)
        return false
    end

    if extendedCraftingData.restricCrafting['onlyOwnerCraft'] and targetType == 'table' then
        if targetData.owner ~= it.getCitizenId() then
            ShowNotification(nil, _U('NOTIFICATION__NOT__ALLOWED'), 'error')
            return false
        end
    end

    if extendedCraftingData.restricCrafting['jobs'] and next(extendedCraftingData.restricCrafting['jobs']) then
        local playerJob = it.getPlayerJob()

        if not playerJob then
            lib.print.error('[checkIfPlayerCanUseTable | ERROR] - Unable to get player job')
            return false
        end

        local allowedJobs = extendedCraftingData.restricCrafting['jobs']
        if not allowedJobs[playerJob.name] then
            ShowNotification(nil, _U('NOTIFICATION__NOT__ALLOWED'), 'error')
            return false
        end

        -- check if allowedJobs[playerJob.name] is boolean or table
        if type(allowedJobs[playerJob.name]) == 'table' then
            -- Check if table contains the job grade ['police'] = {1, 2, 3, 4, 5}
            if not lib.table.contains(allowedJobs[playerJob.name], playerJob.grade_level) then
                ShowNotification(nil, _U('NOTIFICATION__NOT__ALLOWED'), 'error')
                return false
            end
        end
    end
    return true
end


local function createPointBoxTarget(targetType, targetData)
    local options = {}
    if it.target == 'ox_target' then
        if targetType == 'table' then
            options = {
                {
                    label = _U('TARGET__TABLE__LABEL'):format(targetData.label),
                    name = 'it-crafting-use-table',
                    icon = 'fas fa-eye',
                    onSelect = function(data)
                        lib.callback("it-crafting:server:getDataById", false, function(tableData)
                            if not tableData then
                                lib.print.error('[it-crafting] Unable to get table data by network id')
                            else
                                if Config.Debug then
                                    lib.print.info('[createProccessingTargets] Current table data: ', tableData)
                                end

                                if not checkIfPlayerCanUseTable('table', tableData) then return end

                                TriggerEvent('it-crafting:client:showRecipesMenu', 'table', {tableId = tableData.id})
                            end
                        end, 'table', targetData.id)
                    end,
                    distance = targetData.interactDistance
                },
                {
                    label = _U('TARGET__TABLE__REMOVE'),
                    name = 'it-crafting-remove-table',
                    icon = 'fas fa-trash',
                    onSelect = function(data)
                        lib.callback("it-crafting:server:getDataById", false, function(tableData)
                            if not tableData then
                                lib.print.error('[it-crafting] Unable to get table data by network id')
                            else
                                local extendedCraftingData = nil
                                extendedCraftingData = Config.CraftingTables[tableData.tableType]
                                if extendedCraftingData.restricCrafting['onlyOwnerRemove'] then
                                    if tableData.owner ~= it.getCitizenId() then
                                        ShowNotification(nil, _U('NOTIFICATION__NOT__ALLOWED'), 'error')
                                        return
                                    end
                                end
                                TriggerEvent('it-crafting:client:removeTable', {tableId = targetData.id})
                            end
                        end, 'table', targetData.id)
                    end,
                    distance = targetData.interactDistance
                }
            }
        elseif targetType == 'point' then
            options = {
                {
                    label = _U('TARGET__TABLE__LABEL'):format(targetData.label),
                    name = 'it-crafting-use-point',
                    icon = 'fas fa-eye',
                    onSelect = function(data)
                        lib.callback("it-crafting:server:getDataById", false, function(pointData)
                            if not pointData then
                                lib.print.error('[it-crafting] Unable to get table data by network id')
                            else
                                if Config.Debug then
                                    lib.print.info('[createProccessingTargets] Current point data: ', pointData)
                                end
                                
                                if not checkIfPlayerCanUseTable('point', pointData) then return end

                                TriggerEvent('it-crafting:client:showRecipesMenu', 'point', {tableId = pointData.id})
                            end
                        end, 'point', targetData.id)
                    end,
                    distance = targetData.interactDistance
                }
            }
        end

        local boxZone = exports.ox_target:addBoxZone({
            coords = vector3(targetData.coords.x, targetData.coords.y, targetData.coords.z + (targetData.size.z / 2)),
            size = targetData.size,
            rotation = (targetData.rotation + targetData.zoneRotation),
            debug = Config.DebugPoly,
            drawSprite = targetData.drawSprite,
            options = options,
            distance = targetData.interactDistance,
        })

        return boxZone
    elseif it.target == 'qb-target' then
        if type == 'table' then
            options = {
                {
                    label = _U('TARGET__TABLE__LABEL'),
                    icon = 'fas fa-eye',
                    action = function(entity)
                        lib.callback("it-crafting:server:getDataById", false, function(tableData)
                            if not tableData then
                                lib.print.error('[it-crafting] Unable to get table data by network id')
                            else
                                if Config.Debug then
                                    lib.print.info('[createProccessingTargets] Current table data: ', tableData)
                                end

                                if not checkIfPlayerCanUseTable('table', tableData) then return end

                                TriggerEvent('it-crafting:client:showRecipesMenu', 'table', {tableId = tableData.id})
                            end
                        end, 'table', targetData.id)
                    end
                },
                {
                    label = _U('TARGET__TABLE__REMOVE'),
                    name = 'it-crafting-remove-table',
                    icon = 'fas fa-trash',
                    action = function(entity)
                        lib.callback("it-crafting:server:removeTable", false, targetData.id)
                    end
                },
            }
        elseif type == 'point' then
            options = {
                {
                    label = _U('TARGET__TABLE__LABEL'),
                    icon = 'fas fa-eye',
                    action = function(entity)
                        lib.callback("it-crafting:server:getDataById", false, function(pointData)
                            if not pointData then
                                lib.print.error('[it-crafting] Unable to get table data by network id')
                            else
                                if Config.Debug then
                                    lib.print.info('[createProccessingTargets] Current point data: ', pointData)
                                end
                                
                                if not checkIfPlayerCanUseTable('point', pointData) then return end

                                TriggerEvent('it-crafting:client:showRecipesMenu', 'point', {tableId = pointData.id})
                            end
                        end, 'point', targetData.id)
                    end,
                }
            }
        end

        exports['qb-target']:AddBoxZone(targetData.id, vector3(targetData.coords.x, targetData.coords.y, targetData.coords.z + (targetData.size.z / 2)), targetData.size.x, targetData.size.y, {
            name = targetData.id,
            heading = (targetData.rotation + targetData.zoneRotation),
            debugPoly = Config.DebugPoly,
            maxZ = targetData.coords.z + (targetData.size.z / 2),
            minZ = targetData.coords.z,
        }, {
            options = options,
            distance = targetData.interactDistance,
        })
        return targetData.id
    else
        lib.print.error('Invalid target:', it.target)
    end
end

-- Crafting point zones function removed

RegisterNetEvent('it-crafting:client:addTableZone', function(tableType, tableId)
    local tableData = lib.callback.await('it-crafting:server:getDataById', false, 'table', tableId)

    if not tableData then return end

    if not craftingTablesZones[tableData.id] then
        local extendedTableData = Config.CraftingTables[tableType]

        RequestModel(extendedTableData.model)
        while not HasModelLoaded(extendedTableData.model) do
            Wait(100)
        end

        local min, max = GetModelDimensions(extendedTableData.model)
        -- Calculate prop dimensions
        local size = vector3(max.x - min.x, max.y - min.y, max.z - min.z)

        local pointData = {
            label = extendedTableData.label,
            id =  tableData.id,
            coords = tableData.coords,
            rotation = tableData.rotation,
            size = size, --extendedTableData.target.size or vector3(1.0, 1.0, 1.0),
            zoneRotation = extendedTableData.target.rotation or 0,
            drawSprite = extendedTableData.target.drawSprite or false,
            interactDistance = extendedTableData.target.interactDistance or 1.5,
        }
        local boxZone = createPointBoxTarget('table', pointData)
        if it.target == 'ox_target' then
            if craftingTablesZones[tableData.id] then exports.ox_target:removeZone(craftingTablesZones[tableData.id]) end
            craftingTablesZones[tableData.id] = boxZone
        elseif it.target == 'qb-target' then
            -- if craftingTablesZones[tableData.id] then exports['qb-target']:RemoveZone(tableData.id) end
            craftingTablesZones[tableData.id] = boxZone
        end
    end
end)

RegisterNetEvent('it-crafting:client:removeTableZone', function(tableId)

    if it.target == 'ox_target' then
        if craftingTablesZones[tableId] then
            exports.ox_target:removeZone(craftingTablesZones[tableId])
            craftingTablesZones[tableId] = nil
        end
    elseif it.target == 'qb-target' then
        if craftingTablesZones[tableId] then
            exports['qb-target']:RemoveZone(tableId)
            craftingTablesZones[tableId] = nil
        end
    end
end)

CreateThread(function()
    while not it.getTargetName() do
        Wait(100)
    end

    -- Crafting point zones creation removed

    local tables = lib.callback.await('it-crafting:server:getTables')
    for _, tableData in pairs(tables) do

        if not craftingTablesZones[tableData.id] then
            local extendedTableData = Config.CraftingTables[tableData.tableType]

            RequestModel(extendedTableData.model)
            while not HasModelLoaded(extendedTableData.model) do
                Wait(100)
            end

            local min, max = GetModelDimensions(extendedTableData.model)
            -- Calculate prop dimensions
            local size = vector3(max.x - min.x, max.y - min.y, max.z - min.z)

            local pointData = {
                label = extendedTableData.label,
                id =  tableData.id,
                coords = tableData.coords,
                rotation = tableData.rotation,
                size = size, --extendedTableData.target.size or vector3(1.0, 1.0, 1.0),
                zoneRotation = extendedTableData.target.rotation or 0,
                drawSprite = extendedTableData.target.drawSprite or false,
                interactDistance = extendedTableData.target.interactDistance or 1.5,
            }

            local boxZone = createPointBoxTarget('table', pointData)

            if it.target == 'ox_target' then
                if craftingTablesZones[tableData.id] then exports.ox_target:removeZone(craftingTablesZones[tableData.id]) end
                craftingTablesZones[tableData.id] = boxZone
            elseif it.target == 'qb-target' then
                -- if craftingTablesZones[tableData.id] then exports['qb-target']:RemoveZone(tableData.id) end
                craftingTablesZones[tableData.id] = boxZone
            end
        end
    end
end)



-- Remove all Targets
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    if it.getTargetName() == 'qb-target' then
        -- Crafting point zones cleanup removed

        for _, zoneId in pairs(craftingTablesZones) do
            exports['qb-target']:RemoveZone(zoneId)
        end
    elseif it.getTargetName() == 'ox_target' then

        -- Crafting point zones cleanup removed

        for _, zoneId in pairs(craftingTablesZones) do
            exports.ox_target:removeZone(zoneId)
        end
    end
end)