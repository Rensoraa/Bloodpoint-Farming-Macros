# Bloodpoint Farming Macros!
Macros to help with the repetitive/tedious aspects of farming bloodpoints in Dead by Daylight!

> [!CAUTION]
> These macros are focused on reducing repetitive stress injures while farming--not competitive advantage. However, they are still at odds with the BHVR Terms of Use. Use them at your own risk.

## How to Use
1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Download the latest macros at https://BloodpointFarming.github.io/Bloodpoint-Farming-Macros/Bloodpoint-Farming-Macros.zip
3. Extract *everything* in the zip file.
4. Open the .ahk files you want to run. (e.g. just double click them)
5. To turn off the macro, open your system tray > right click the macro > Exit

## General Macros
### Skip Startup Screens
- Auto-clicks through the DBD startup screens.
- Times DBD startup.
- DBD must be fullscreen and visible.
- DBD does *not* need to be focused.

### Autospend
- F6 to spend BP using the [fast bloodweb tech](https://www.reddit.com/r/deadbydaylight/s/njguTZBODp).
- Supports 1080p and 1440p resolutions.
- Run windowed at these resolutions if you need to.
- Disable filters if they interfere.
- Demo: https://youtu.be/duVNbdo9qLM

### Auto Click
- Auto-clicker for spending bloodpoints.
- F6 = Toggle ON / F7 = Toggle OFF

### Ready Up
- Clicks the ready button as soon as it becomes visible.
- Disables if the user manually unreadies.
- Re-enables if the user readies up again.

### Continue
- Auto-clicks the CONTINUE button.

### Space Spam
- Spams space bar events while the actual space bar is held down.
- Useful for failing skill checks to regress a generator quickly.

### FPS Switch
- Quickly switches between 30 & 120 FPS.
- F3 = Set 30 FPS / F4 = Set 120 FPS
- UI scale must be 100%.

### FPS Switch (sleep)
- Slowly switches between 30 & 120 FPS.
- F3 = Set 30 FPS / F4 = Set 120 FPS
- This version of the FPS Switch macro can potentially work better for non-standard configurations (shaders, filters, etc).

### Match Timer
- A simple match timer that resets when the black bars at the top/bottom of the screen fully disappear.
- Window is always on top and draggable.

![Match Timer and taskbar icons](assets/match-timer.png)

### Abandon Match
- Uses the Abandon Match feature as soon as available.
- If that doesn't work, activate manually with Ctrl+Shift+A.
- UI scale must be 100%

## Killer macros
### Killer Shuffle
- Killer will repeatedly move forwards and backwards in place to allow survivors to get into chase (Spin blinding, Gen dancing, etc.).
- F2 = start dancing
- WASD = stop dancing

### Killer Hit Counter
- Show a counter for the number of times you M1.
- Useful for killers to track the number of self-care hit rotations in Reactive builds.
- Disappears after 15 seconds of no hits.
- `Ctrl+` and `Ctrl-` to manually set (if necessary)
- `Ctrl+R` to reset to 0.

### Killer Autohook
- Hooks a carried survivor when possible.
- Adds years of life to your keyboard's spacebar.
- UI scale must be 100%

## Automatic Updates
Scripts automatically check for updates and ask to update when new fixes and macros are added.

> [!IMPORTANT]  
> Updating will overwrite the whole directory, including any macro changes or new files you've added.
> If you'd prefer to manage updates manually, `git clone https://github.com/BloodpointFarming/Bloodpoint-Farming-Macros.git` instead. Scripts will not auto-update if they're run from in a git repo.
