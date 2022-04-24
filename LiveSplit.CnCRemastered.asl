state("ClientG")
{
    /*
     * The internal game ticks (used to calculate game time)
     */
    uint ticks          : "ClientG.exe", 0x1B661D0, 0x18, 0x104, 0x1C, 0x0, 0x70;

    /*
     * The speed setting for the game (1-7)
     */
    byte speed          : "ClientG.exe", 0x1C98334;

    /*
     * The state of the game, values can be:
     * 0 - Playing the game
     * 1 - "Mission Accomplished" / results screen
     * 2 - Main menu
     * 3 - Loading screen
     */
    byte controlStatus  : "ClientG.exe", 0x1B81768, 0xE8;

    /*
     * The name of the map that is loaded
     */
    string24 currentMap : "ClientG.exe", 0x1B81804, 0xF0, 0x7;
}

init
{
    vars.speedDivider = 1.0;
    vars.lastKnownTicks = 0;
    vars.lastKnownTicksOld = 0;
    vars.storedGT = 0;
}

startup
{
    settings.Add("startAnyLevel", false, "Start the timer on any level");
    settings.SetToolTip("startAnyLevel", "Will start the timer at the beginning of any level (good for IL runs)");

    settings.Add("resetOnRestart", false, "Reset on Restart");
    settings.SetToolTip("resetOnRestart", "Will reset the timer if a level is restarted (good for IL runs)");
}

onStart
{
    vars.lastKnownTicks = 0;
    vars.lastKnownTicksOld = 0;
    vars.storedGT = 0;
}

update
{
    if (current.speed == 7) {
        vars.speedDivider = 1.0 / 17.0;
    } else if (current.speed == 6) {
        vars.speedDivider = 1.0 / 18.0;
    } else if (current.speed == 5) {
        vars.speedDivider = 7.0 / 180.0;
    } else {
        vars.speedDivider = (current.speed + 1) / 180.0;
    }

    if (current.ticks != 0) {
        vars.lastKnownTicks = current.ticks;
    }
    if (old.ticks != 0) {
        vars.lastKnownTicksOld = old.ticks;
    }
    if (vars.lastKnownTicks < vars.lastKnownTicksOld) {
        vars.storedGT = vars.storedGT + (vars.lastKnownTicksOld - vars.lastKnownTicks) / vars.speedDivider;
    }
}

start
{
    if (settings["startAnyLevel"]) {
	// When the loading screen ends and the game starts
        return old.controlStatus == 3 && current.controlStatus == 0;
    } else {
	// When the loading screen starts for level 1
        return (old.controlStatus != 3 && current.controlStatus == 3 && current.currentMap.Contains("CAMPAIGN_1_MA"))
		|| (current.controlStatus == 3 && !old.currentMap.Contains("CAMPAIGN_1_MA") && current.currentMap.Contains("CAMPAIGN_1_MA"));
    }
}

reset
{
    return (current.speed != old.speed) // Changed game speed
           || (settings["resetOnRestart"] && old.controlStatus == 0 && current.controlStatus == 3);  // Restarted level
}

split
{
    return old.controlStatus == 0 && current.controlStatus == 1;
}

isLoading
{
    return true;
}

gameTime
{
    return TimeSpan.FromMilliseconds(vars.storedGT + vars.lastKnownTicks / vars.speedDivider);
}
