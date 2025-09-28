local getMetadata = function(itemData)
    if not itemData then return nil end
    local encodedData = json.encode(itemData)
    if it.inventory == 'ox' then
        return itemData.metadata or nil
    elseif it.core == "qb-core" then
        return itemData.info or nil
    elseif it.core == "esx" then
        return itemData.metadata or nil
    end
end


if it.inventory == 'ox' then
    exports('placeCraftingTable', function(event, item, inventory, slot, data)

        if Config.Debug then
            lib.print.info('[placeCraftingTable] Export called!')
            lib.print.info('[placeCraftingTable] Event:', event)
            lib.print.info('[placeCraftingTable] Item:', json.encode(item))
            lib.print.info('[placeCraftingTable] Inventory:', json.encode(inventory))
        end

        local prTable = item.name
        --[[ if not it.hasItem(inventory.id, prTable, 1) then
            if Config.Debug then lib.print.error('Player does not have the item', prTable) end
            return
        end ]]

        if event == 'usingItem' then
            if Config.Debug then lib.print.info('[placeCraftingTable] Processing usingItem event') end
            local src = inventory.id
            local metadata = getMetadata(item)
            if Config.Debug then lib.print.info('[placeCraftingTable] Table metadata:', json.encode(metadata)) end
            TriggerClientEvent('it-crafting:client:placeCraftingTable', src, prTable, metadata)
        else
            if Config.Debug then lib.print.info('[placeCraftingTable] Event not handled:', event) end
        end
    end)

    if Config.Debug then lib.print.info('[2WhiffyCrafting] ox_inventory export registered: placeCraftingTable') end
else
    for crTable, _ in pairs(Config.CraftingTables) do
        it.createUsableItem(crTable, function(source, data)
            local src = source
            if it.hasItem(src, crTable, 1) then
                local metadata = getMetadata(data)
                if Config.Debug then lib.print.info('Table metadata', metadata) end
                TriggerClientEvent('it-crafting:client:placeCraftingTable', src, crTable, metadata)
            end
        end)
    end
end

-- Debug command to test the system
if Config.Debug then
    RegisterCommand('testcrafting', function(source, args, rawCommand)
        local src = source
        lib.print.info('[DEBUG] Testing crafting system for player: ' .. src)
        lib.print.info('[DEBUG] Framework: ' .. (it.core or 'unknown'))
        lib.print.info('[DEBUG] Inventory: ' .. (it.inventory or 'unknown'))
        lib.print.info('[DEBUG] Target: ' .. (it.target or 'none'))

        -- Test giving a crafting table
        if it.giveItem(src, 'simple_crafting_table', 1) then
            lib.print.info('[DEBUG] Successfully gave crafting table to player')
        else
            lib.print.error('[DEBUG] Failed to give crafting table to player')
        end
    end, false)
end
