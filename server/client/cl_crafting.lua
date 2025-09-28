local crafting = false

local processingFx = {}

local RotationToDirection = function(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosOfRotX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end

local RayCastCamera = function(dist)
    local camRot = GetGameplayCamRot()
    local camPos = GetGameplayCamCoord()
    local dir = RotationToDirection(camRot)
    local dest = camPos + (dir * dist)
    local ray = StartShapeTestRay(camPos, dest, 17, -1, 0)
    local _, hit, endPos, surfaceNormal, entityHit = GetShapeTestResult(ray)
    if hit == 0 then endPos = dest end
    return hit, endPos, entityHit, surfaceNormal
end




local placeCraftingTable = function(ped, tableItem, coords, rotation, metadata)

    local extendedItemData = Config.CraftingTables[tableItem]
    if not extendedItemData then
        if Config.Debug then lib.print.error('[placeCraftingTable | Debug] Invalid tableItem:', tableItem) end
        return
    end

    local tables = lib.callback.await('it-crafting:server:getTables', false)

    if tables then
        for _, table in pairs(tables) do
            local tableCoords = table.coords
            local distance = #(coords - tableCoords)
            if distance <= Config.MinDistanceToTable then
                ShowNotification(nil, _U('NOTIFICATION__TO__CLOSE'), 'error')
                TriggerEvent('it-crafting:client:syncRestLoop', false)
                if it.inventory == 'ox' then
                    it.giveItem(tableItem, 1, metadata)
                end
                return
            end
        end
    end

    local playerTables = lib.callback.await('it-crafting:server:getTableByOwner', false)
    if Config.PlayerTableLimit ~= -1 and playerTables then

        local playerTableCount = 0
        for _, table in pairs(playerTables) do
            if table.owner == it.getCitizenId() then
                playerTableCount = playerTableCount + 1
            end
        end

        if playerTableCount >= Config.PlayerTableLimit then
            ShowNotification(nil, _U('NOTIFICATION__MAX__TABLES'), 'error')
            TriggerEvent('it-crafting:client:syncRestLoop', false)
            if it.inventory == 'ox' then
                it.giveItem(tableItem, 1, metadata)
            end
            return
        end
    end


    -- Zone restrictions have been removed

    RequestAnimDict('amb@medic@standing@kneel@base')
    RequestAnimDict('anim@gangops@facility@servers@bodysearch@')
    while 
        not HasAnimDictLoaded('amb@medic@standing@kneel@base') or
        not HasAnimDictLoaded('anim@gangops@facility@servers@bodysearch@')
    do 
        Wait(0)
    end

    TaskPlayAnim(ped, 'amb@medic@standing@kneel@base', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 8.0, -1, 48, 0, false, false, false)


    if ShowProgressBar({
        duration = 5000,
        label = _U('PROGRESSBAR__PLACE__TABLE'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
    }) then
        TriggerServerEvent('it-crafting:server:createNewTable', coords, tableItem, rotation, metadata)

        ClearPedTasks(ped)
        RemoveAnimDict('amb@medic@standing@kneel@base')
        RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
    else
        ShowNotification(nil, _U('NOTIFICATION_CANCELED'), "error")
        ClearPedTasks(ped)
        RemoveAnimDict('amb@medic@standing@kneel@base')
        RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
        if it.inventory == 'ox' then
            it.giveItem(tableItem, 1, metadata)
        end
    end
    TriggerEvent('it-crafting:client:syncRestLoop', false)
end

RegisterNetEvent('it-crafting:client:placeCraftingTable', function(tableItem, metadata)
    local ped = PlayerPedId()
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
        ShowNotification(nil, _U('NOTIFICATION__IN__VEHICLE'), "error")
        return
    end

    local hashModel = GetHashKey(Config.CraftingTables[tableItem].model)
    RequestModel(hashModel)
    while not HasModelLoaded(hashModel) do Wait(0) end
    
    TriggerEvent('it-crafting:client:syncRestLoop', true)

    -- Enhanced placement UI
    lib.showTextUI('[W/A/S/D] Move Table | [Mouse Scroll] Rotate | [E] Place | [G] Cancel', {
        position = "left-center",
        icon = "hammer",
    })

    -- Initial placement position
    local coords = GetEntityCoords(ped)
    local forwardVector = GetEntityForwardVector(ped)
    local startX = coords.x + (forwardVector.x * 2.0)
    local startY = coords.y + (forwardVector.y * 2.0)
    local _, groundZ = GetGroundZFor_3dCoord(startX, startY, coords.z + 5.0, true)

    local table = CreateObject(hashModel, startX, startY, groundZ, false, false, false)
    SetEntityCollision(table, false, false)
    SetEntityAlpha(table, 150, true)

    local rotation = GetEntityHeading(ped)
    SetEntityHeading(table, rotation)

    local placed = false
    local currentX, currentY = startX, startY
    local moveSpeed = 0.05

    while not placed do
        Wait(0)

        -- Disable player movement during placement
        DisableControlAction(0, 30, true) -- A/Left
        DisableControlAction(0, 31, true) -- S/Back
        DisableControlAction(0, 32, true) -- W/Forward
        DisableControlAction(0, 33, true) -- D/Right
        DisableControlAction(0, 34, true) -- Turn Left
        DisableControlAction(0, 35, true) -- Turn Right
        DisableControlAction(0, 21, true) -- Sprint
        DisableControlAction(0, 22, true) -- Jump
        DisableControlAction(0, 36, true) -- Ctrl (Duck)

        -- Movement with WASD (using both control IDs and direct key checks)
        local moved = false

        -- Try both control mapping and direct key detection
        if IsControlPressed(0, 32) or IsDisabledControlPressed(0, 32) then -- W (Forward/North)
            currentY = currentY + moveSpeed
            moved = true
            if Config.Debug then lib.print.info('[Placement] Moving Forward (W)') end
        end
        if IsControlPressed(0, 31) or IsDisabledControlPressed(0, 31) then -- S (Back/South)
            currentY = currentY - moveSpeed
            moved = true
            if Config.Debug then lib.print.info('[Placement] Moving Back (S)') end
        end
        if IsControlPressed(0, 30) or IsDisabledControlPressed(0, 30) then -- A (Left/West)
            currentX = currentX - moveSpeed
            moved = true
            if Config.Debug then lib.print.info('[Placement] Moving Left (A)') end
        end
        if IsControlPressed(0, 33) or IsDisabledControlPressed(0, 33) then -- D (Right/East)
            currentX = currentX + moveSpeed
            moved = true
            if Config.Debug then lib.print.info('[Placement] Moving Right (D)') end
        end

        -- Rotation with mouse scroll
        if IsControlJustPressed(0, 14) then -- Mouse scroll up
            rotation = rotation + 5.0
            if rotation >= 360.0 then rotation = 0.0 end
        end
        if IsControlJustPressed(0, 15) then -- Mouse scroll down
            rotation = rotation - 5.0
            if rotation < 0.0 then rotation = 355.0 end
        end

        -- Surface snapping - always snap to ground
        local _, newGroundZ = GetGroundZFor_3dCoord(currentX, currentY, coords.z + 10.0, true)

        -- Update table position and rotation
        SetEntityCoords(table, currentX, currentY, newGroundZ)
        SetEntityHeading(table, rotation)

        -- Debug output for position
        if moved and Config.Debug then
            lib.print.info('[Placement] Table position: X=' .. string.format("%.2f", currentX) .. ', Y=' .. string.format("%.2f", currentY) .. ', Z=' .. string.format("%.2f", newGroundZ))
        end

        -- Place table with E
        if IsControlJustPressed(0, 38) then -- E
            placed = true
            lib.hideTextUI()
            DeleteObject(table)
            placeCraftingTable(ped, tableItem, vector3(currentX, currentY, newGroundZ), rotation, metadata)
            return
        end

        -- Cancel with G
        if IsControlJustPressed(0, 47) then -- G
            placed = true
            lib.hideTextUI()
            DeleteObject(table)
            TriggerEvent('it-crafting:client:syncRestLoop', false)
            if it.inventory == 'ox' then
                it.giveItem(tableItem, 1, metadata)
            end
            return
        end
    end

    SetModelAsNoLongerNeeded(hashModel)
end)

-- Debug command to test controls
if Config.Debug then
    RegisterCommand('testcontrols', function()
        CreateThread(function()
            lib.print.info('[Debug] Testing WASD controls for 10 seconds...')
            lib.print.info('[Debug] Press W/A/S/D keys to test detection')
            local startTime = GetGameTimer()
            while GetGameTimer() - startTime < 10000 do
                Wait(100) -- Reduced frequency to avoid spam
                if IsControlPressed(0, 32) or IsDisabledControlPressed(0, 32) then
                    lib.print.info('[Debug] W key (Forward) detected!')
                end
                if IsControlPressed(0, 31) or IsDisabledControlPressed(0, 31) then
                    lib.print.info('[Debug] S key (Back) detected!')
                end
                if IsControlPressed(0, 30) or IsDisabledControlPressed(0, 30) then
                    lib.print.info('[Debug] A key (Left) detected! Control ID: 30')
                end
                if IsControlPressed(0, 33) or IsDisabledControlPressed(0, 33) then
                    lib.print.info('[Debug] D key (Right) detected!')
                end
            end
            lib.print.info('[Debug] Control test finished.')
        end)
    end, false)
end

RegisterNetEvent('it-crafting:client:craftItem', function(craftingType, args)
    if Config.Debug then lib.print.info('Crafting Item:', craftingType, args) end

    local craftingData = lib.callback.await('it-crafting:server:getDataById', false, craftingType, args.craftId)
    local recipe = lib.callback.await('it-crafting:server:getRecipeById', false, craftingType, args.craftId, args.recipeId)
    if crafting then return end

    local extendedCraftingData = nil
    if craftingType == 'table' then
        extendedCraftingData = Config.CraftingTables[craftingData.tableType]
    else
        lib.print.error('Invalid craftingType:', craftingType)
        return
    end

    -- Check tool requirements
    if Config.LevelsSystem.toolConfig.enabled and recipe.tools then
        for toolCategory, toolData in pairs(recipe.tools) do
            local hasRequiredTool = false
            local toolLabel = Config.LevelsSystem.toolConfig.tools[toolCategory] and Config.LevelsSystem.toolConfig.tools[toolCategory].label or toolCategory

            -- Check if player has any of the tools in this category
            if Config.LevelsSystem.toolConfig.tools[toolCategory] then
                for _, toolItem in pairs(Config.LevelsSystem.toolConfig.tools[toolCategory].items) do
                    if it.hasItem(toolItem, toolData.amount) then
                        hasRequiredTool = true
                        break
                    end
                end
            end

            if not hasRequiredTool then
                ShowNotification(nil, ('You need a %s to craft this item'):format(toolLabel), 'error')
                return
            end
        end
    end

    -- Check level requirement
    if Config.LevelsSystem.enabled and recipe.levelRequirement then
        local hasRequirement = lib.callback.await('2WhiffyCrafting:server:checkLevelRequirement', false, args.recipeId)
        if not hasRequirement then
            local skillLabel = Config.LevelsSystem.skillTypes[recipe.levelRequirement.skillType].label
            ShowNotification(nil, ('You need %s level %d to craft this item'):format(skillLabel, recipe.levelRequirement.level), 'error')
            return
        end
    end

    local input = lib.inputDialog(_U('INPUT__AMOUNT__HEADER'), {
        {type = 'number', text = _U('INPUT__AMOUNT__TEXT'), desciption = _U('INPUT__AMOUNT__DESCRIPTION'), require = true, min = 1}
    })

    if not input then
        ShowNotification(nil, _U('NOTIFICATION__NO__AMOUNT'), 'error')
        return
    end

    TriggerEvent('it-crafting:client:syncRestLoop', true)
    local amount = tonumber(input[1])
    for item, itemData in pairs(recipe.ingrediants) do
        if itemData.remove then
            if not it.hasItem(item, itemData.amount * amount) then
                ShowNotification(nil, _U('NOTIFICATION__MISSING__INGIDIANT'), 'error')
                crafting = false
                TriggerEvent('it-crafting:client:syncRestLoop', false)
                return
            end
        else
            if not it.hasItem(item, itemData.amount) then
                ShowNotification(nil, _U('NOTIFICATION__MISSING__INGIDIANT'), 'error')
                crafting = false
                TriggerEvent('it-crafting:client:syncRestLoop', false)
                return
            end
        end
    end

    if extendedCraftingData.restricCrafting['onlyOnePlayer'] then
        local inUse = lib.callback.await('it-crafting:server:inUse', false, craftingType,  args.craftId)
        
        if inUse then
            ShowNotification(nil, _U('NOTIFICATION__TABLE__IN__USE'), 'error')
            return
        end
    end

    local craftingUpdated = lib.callback.await('it-crafting:server:updateUse', false, craftingType, args.craftId, true)

    if not craftingUpdated then
        ShowNotification(nil, _U('NOTIFICATION__TABLE__IN__USE'), 'error')
        return
    end

    crafting = true

    local ped = PlayerPedId()
    TaskTurnPedToFaceCoord(ped, craftingData.coords.x, craftingData.coords.y, craftingData.coords.z, 1.0)
    Wait(200)
    
    RequestAnimDict(recipe.animation.dict)
    while not HasAnimDictLoaded(recipe.animation.dict) do
        Wait(0)
    end
    TaskPlayAnim(ped, recipe.animation.dict, recipe.animation.anim, 8.0, 8.0, -1, 1, 0, false, false, false)

    if recipe.particlefx then
        if Config.Debug then lib.print.info('Calling ParticleFX Sync [start]') end
        TriggerServerEvent("it-crafting:server:syncparticlefx", true, craftingData.id, craftingData.netId, recipe.particlefx)
    end

    if Config.Debug then lib.print.info('Crafting with Recipe:', recipe) end

    -- Skill checks removed - using progress bar only
    for i = 1, amount do
        if Config.UseWeightSystem then
            if not it.canCarryItems(recipe.outputs) then
                ShowNotification(nil, _U('NOTIFICATION__CANT__CARRY'), 'error')
                break
            end
        end
        if lib.progressBar({
            duration = recipe.processTime * 1000,
            label = _U('PROGRESSBAR__CRAFT__ITEM'),
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
        }) then
            TriggerServerEvent('it-crafting:server:craftItem', craftingType, {tableId = args.craftId, recipeId = args.recipeId})
        else
            ShowNotification(nil, _U('NOTIFICATION__CANCELED'), "error")
            break
        end
        Wait(1000)
    end
    crafting = false
    ClearPedTasks(ped)
    RemoveAnimDict(recipe.animation.dict)
    local craftingUpdated = lib.callback.await('it-crafting:server:updateUse', false, craftingType, args.craftId, false)
    if recipe.particlefx then
        if Config.Debug then lib.print.info('Calling ParticleFX Sync [stop]') end
        TriggerServerEvent("it-crafting:server:syncparticlefx", false, craftingData.id, nil, nil)
    end
    TriggerEvent('it-crafting:client:syncRestLoop', false)
end)

RegisterNetEvent('it-crafting:client:removeTable', function(args)

    local tableData = lib.callback.await('it-crafting:server:getDataById', false, 'table', args.tableId)
    local entity = NetworkGetEntityFromNetworkId(tableData.netId)

    if Config.UseWeightSystem then
        if not it.canCarryItem(tableData.tableType, 1) then
            ShowNotification(nil, _U('NOTIFICATION__CANT__CARRY'), 'error')
            return
        end
    end

    TriggerEvent('it-crafting:client:syncRestLoop', true)

    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, entity, 1.0)
    Wait(200)

    RequestAnimDict('amb@medic@standing@kneel@base')
    RequestAnimDict('anim@gangops@facility@servers@bodysearch@')
    while 
        not HasAnimDictLoaded('amb@medic@standing@kneel@base') or
        not HasAnimDictLoaded('anim@gangops@facility@servers@bodysearch@')
    do 
        Wait(0) 
    end
    TaskPlayAnim(ped, 'amb@medic@standing@kneel@base', 'base', 8.0, 8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 8.0, -1, 48, 0, false, false, false)

    if ShowProgressBar({
        duration = 5000,
        label = _U('PROGRESSBAR__REMOVE__TABLE'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
    }) then
        TriggerServerEvent('it-crafting:server:removeTable', {tableId = args.tableId})
        ClearPedTasks(ped)
        RemoveAnimDict('amb@medic@standing@kneel@base')
        RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
    else
        ShowNotification(nil, _U('NOTIFICATION__CANCELED'), "error")
        ClearPedTasks(ped)
        RemoveAnimDict('amb@medic@standing@kneel@base')
        RemoveAnimDict('anim@gangops@facility@servers@bodysearch@')
    end
    TriggerEvent('it-crafting:client:syncRestLoop', false)
end)

local getTableCenter = function(tableEntity)
    -- Get the table's position
    local tablePos = GetEntityCoords(tableEntity)
    
    -- Get the table's dimensions
    local min, max = GetModelDimensions(GetEntityModel(tableEntity))
    
    -- Calculate the center of the table
    local centerX = (min.x + max.x) / 2
    local centerY = (min.y + max.y) / 2
    local centerZ = (min.z + max.z) / 2
    
    -- Calculate the world coordinates of the center
    local centerPos = vector3(tablePos.x + centerX, tablePos.y + centerY, tablePos.z + centerZ)
    
    -- Get the table's rotation
    local tableRot = GetEntityRotation(tableEntity)
    
    return centerPos, tableRot
end

local function CreateSmokeEffect(status, tableId, netId, particleFx)
    if status then
        local entity = NetworkGetEntityFromNetworkId(netId)
        
        local entityCenterCoords, entityRotation = getTableCenter(entity)

        RequestNamedPtfxAsset(particleFx.dict)
        while not HasNamedPtfxAssetLoaded(particleFx.dict) do
            Wait(0)
        end
        UseParticleFxAssetNextCall(particleFx.dict)
   
        local offsetX = 0.0
        local offsetY = -0.5

        -- Adjust the offset based on the table's rotation
        if math.abs(entityRotation.z) > 45 and math.abs(entityRotation.z) < 135 then
            offsetX = -0.5
            offsetY = 0.0
        end

        processingFx[tableId] = StartParticleFxLoopedAtCoord(particleFx.particle, entityCenterCoords.x + offsetX, entityCenterCoords.y + offsetY, entityCenterCoords.z, entityRotation.x, entityRotation.y, entityRotation.z, particleFx.scale, false, false, false, 0)

        SetParticleFxLoopedColour(processingFx[tableId], particleFx.color.r, particleFx.color.g, particleFx.color.b, 0)
    else
        if processingFx[tableId] ~= nil then
            if Config.Debug then print('Stopping ParticleFX') end
            StopParticleFxLooped(processingFx[tableId], 0)
            processingFx[tableId] = nil
        end
    end
end

RegisterNetEvent('it-crafting:client:syncparticlefx', function(status, tableId, netId, particlefx)
    if status then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local targetEntity = NetworkGetEntityFromNetworkId(netId)

        local targetCoords  = GetEntityCoords(targetEntity)
        local distance = #(playerCoords - targetCoords)
        if distance <= 100 then
            CreateSmokeEffect(status, tableId, netId, particlefx)
        end
    else
        CreateSmokeEffect(status, tableId, netId, particlefx)
    end
end)