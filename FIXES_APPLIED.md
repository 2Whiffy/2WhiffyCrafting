# Fixes Applied to 2WhiffyCrafting

## Issues Fixed

### 1. ✅ Script Error: `attempt to index a nil value (field 'toolConfig')`

**Problem:** Code was trying to access `Config.toolConfig` but it should be `Config.LevelsSystem.toolConfig`

**Files Fixed:**
- `client/cl_menus.lua` - Lines 89, 92, 95, 96, 107
- `server/sv_crafting.lua` - Lines 268, 274, 275, 285, 293
- `client/cl_crafting.lua` - Lines 233, 236, 239

**Solution:** Changed all instances of `Config.toolConfig` to `Config.LevelsSystem.toolConfig`

### 2. ✅ ox_inventory Integration Issues

**Problem:** Items couldn't be placed because ox_inventory integration was incomplete

**Files Fixed:**
- `fxmanifest.lua` - Added `server_export 'placeCraftingTable'`
- `ox_inventory_items.lua` - Added `server.export` configuration for crafting tables
- `bridge/items/server.lua` - Added proper ox_inventory handling in `it.createUsableItem`
- `server/sv_usableitems.lua` - Enhanced debugging and export registration

**Solution:** 
- Properly registered the export in fxmanifest
- Added server export configuration to item definitions
- Fixed bridge system to handle ox_inventory correctly

### 3. ✅ Enhanced Table Placement System

**Problem:** Old placement system was clunky and didn't block movement

**File Fixed:** `client/cl_crafting.lua`

**New Features:**
- **WASD Movement:** Use W/A/S/D keys to move the table around
- **Mouse Scroll Rotation:** Use mouse scroll wheel to rotate the table (5° increments)
- **Surface Snapping:** Table automatically snaps to ground surface
- **Movement Blocking:** Player movement is disabled during placement
- **Better UI:** Clear instructions showing controls
- **Improved Controls:**
  - `W/A/S/D` - Move table
  - `Mouse Scroll` - Rotate table
  - `E` - Place table
  - `G` - Cancel placement

## Configuration Changes

### Debug Mode Enabled
- `shared/config.lua` - Set `Config.Debug = true` for troubleshooting

### Enhanced Debugging
- Added comprehensive debug messages to track ox_inventory integration
- Added test command `/testcrafting` (debug mode only)

## Setup Instructions

### For ox_inventory Users:

1. **Add items to ox_inventory:**
   - Copy items from `ox_inventory_items.lua` to your `ox_inventory/data/items.lua`
   - Make sure to include the `server.export` configuration

2. **Add item images:**
   - Place corresponding PNG images in `ox_inventory/web/images/`

3. **Restart resources:**
   ```
   restart ox_inventory
   restart 2WhiffyCrafting
   ```

4. **Test the system:**
   - Use `/testcrafting` to get a crafting table
   - Try placing it with the new controls
   - Check console for debug messages

## Debug Commands

- `/testcrafting` - Gives you a crafting table and shows system info (debug mode only)

## Expected Debug Output

When working correctly, you should see:
```
[2WhiffyCrafting] Using configured inventory: ox
[2WhiffyCrafting] ox_inventory export registered: placeCraftingTable
[placeCraftingTable] Export called!
[placeCraftingTable] Event: usingItem
[placeCraftingTable] Processing usingItem event
```

## Troubleshooting

If items still don't work:
1. Check server console for error messages
2. Verify ox_inventory is running: `ensure ox_inventory`
3. Make sure resource folder is named exactly `2WhiffyCrafting`
4. Verify items are added to ox_inventory with correct export configuration
5. Use `/testcrafting` command to test the system

## Files Modified

1. `fxmanifest.lua` - Added export declaration
2. `ox_inventory_items.lua` - Added server export configuration
3. `bridge/items/server.lua` - Fixed ox_inventory handling
4. `server/sv_usableitems.lua` - Enhanced debugging and test command
5. `shared/config.lua` - Enabled debug mode
6. `client/cl_menus.lua` - Fixed toolConfig references
7. `server/sv_crafting.lua` - Fixed toolConfig references
8. `client/cl_crafting.lua` - Fixed toolConfig references and enhanced placement system
9. `bridge/init.lua` - Enhanced inventory detection logging

## Next Steps

1. Add the items to your ox_inventory configuration
2. Restart the resources
3. Test the placement system with the new WASD controls
4. Disable debug mode once everything is working: `Config.Debug = false`

All fixes have been applied and the system should now work correctly with ox_inventory!
