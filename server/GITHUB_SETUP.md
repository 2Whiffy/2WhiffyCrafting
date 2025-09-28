# GitHub Repository Setup for 2WhiffyCrafting

## Version Check System Updated

The version check system has been updated to point to your GitHub repository: `https://github.com/2Whiffy/2WhiffyCrafting`

### Changes Made:

1. **Updated version check messages** to show `[2WhiffyCrafting]` instead of `[it-crafting]`
2. **Changed repository path** from `it-scripts/it-crafting` to `2Whiffy/2WhiffyCrafting`
3. **Updated version** to `v2.0.0` to reflect your enhanced version

### What You Need to Upload to GitHub:

To make the version check work properly, you need to upload a `version` file to the root of your GitHub repository with this exact content:

```json
{
    "version": "v2.0.0",
    "message": "2WhiffyCrafting - Enhanced crafting system with levels, improved placement controls (WASD + mouse scroll), and ox_inventory integration fixes"
}
```

### GitHub Repository Structure:

Your repository should have this structure:
```
2WhiffyCrafting/
├── version                    # Version file for update checking
├── README.md                  # Repository description
├── fxmanifest.lua            # Resource manifest
├── shared/
│   └── config.lua
├── client/
│   ├── cl_crafting.lua
│   ├── cl_menus.lua
│   └── ...
├── server/
│   ├── sv_crafting.lua
│   ├── sv_versioncheck.lua
│   └── ...
└── ...
```

### Expected Output:

After uploading the version file, when the resource starts, you should see:

```
======================================
[2WhiffyCrafting] - The Script is up to date!
Current Version: v2.0.0.
Branch: main.
======================================
```

### To Disable Version Check:

If you don't want version checking, set this in `shared/config.lua`:
```lua
Config.EnableVersionCheck = false
```

### Version File Location:

The version file must be uploaded to:
`https://raw.githubusercontent.com/2Whiffy/2WhiffyCrafting/main/version`

### Testing the Version Check:

1. Upload the `version` file to your GitHub repository
2. Restart the 2WhiffyCrafting resource
3. Check the server console for the version check message

### Future Updates:

When you release new versions:
1. Update the version in `fxmanifest.lua`
2. Update the version in the local `version` file
3. Update the version in the GitHub repository `version` file
4. Users will automatically be notified of updates when they restart their server

The version check system will now properly reflect your 2WhiffyCrafting branding and point to your GitHub repository!
