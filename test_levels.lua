-- Test script for the levels system
-- This file can be used to test the levels system functionality
-- Remove this file after testing

-- Test configuration
local testCitizenId = "TEST123"
local testSkillType = "standard_crafting"

-- Test functions
local function testLevelsSystem()
    print("=== Testing Crafting Levels System ===")
    
    -- Test 1: Get initial level
    print("\n1. Testing initial level...")
    local level, xp = exports['it-crafting']:getPlayerLevel(testCitizenId, testSkillType)
    print(("Initial level: %d, XP: %d"):format(level, xp))
    
    -- Test 2: Award XP
    print("\n2. Testing XP award...")
    local testRecipe = {
        levelRequirement = {
            skillType = testSkillType,
            level = 1
        }
    }
    exports['it-crafting']:awardCraftingXP(testCitizenId, testSkillType, testRecipe)
    
    -- Test 3: Check new level
    print("\n3. Testing level after XP...")
    level, xp = exports['it-crafting']:getPlayerLevel(testCitizenId, testSkillType)
    print(("New level: %d, XP: %d"):format(level, xp))
    
    -- Test 4: Set level directly
    print("\n4. Testing direct level set...")
    local success = exports['it-crafting']:setPlayerLevel(testCitizenId, testSkillType, 5)
    print(("Set level success: %s"):format(tostring(success)))
    
    -- Test 5: Verify level set
    print("\n5. Testing level verification...")
    level, xp = exports['it-crafting']:getPlayerLevel(testCitizenId, testSkillType)
    print(("Final level: %d, XP: %d"):format(level, xp))
    
    -- Test 6: Get all levels
    print("\n6. Testing get all levels...")
    local allLevels = exports['it-crafting']:getAllPlayerLevels(testCitizenId)
    for skillType, data in pairs(allLevels) do
        print(("Skill: %s, Level: %d, XP: %d/%d"):format(skillType, data.level, data.xp, data.xpForNext))
    end
    
    -- Test 7: Level requirement check
    print("\n7. Testing level requirement check...")
    local hasRequirement = exports['it-crafting']:checkLevelRequirement(testCitizenId, testRecipe)
    print(("Has requirement: %s"):format(tostring(hasRequirement)))
    
    -- Test 8: Reset levels
    print("\n8. Testing level reset...")
    local resetSuccess = exports['it-crafting']:resetPlayerLevels(testCitizenId)
    print(("Reset success: %s"):format(tostring(resetSuccess)))
    
    print("\n=== Test Complete ===")
end

-- Register test command
RegisterCommand('testlevels', function()
    if Config.LevelsSystem.enabled then
        testLevelsSystem()
    else
        print("Levels system is disabled in config")
    end
end, true)

print("Test script loaded. Use /testlevels to run tests.")
