state("ClientG")
{
    /*
     * The state of the game, values can be:
     * 0 - Playing the game
     * 1 - "Mission Accomplished" / results screen
     * 2 - Main menu
     * 3 - Loading screen
     */
    byte controlStatus  : "ClientG.exe", 0x1BA3620, 0xE8;

    /*
     * The name of the map that is loaded
     */
    string24 currentMap : "ClientG.exe", 0x1BA3FC8, 0xF0, 0x7;
}

init
{

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

}

update
{

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
    return settings["resetOnRestart"] && old.controlStatus == 0 && current.controlStatus == 3;  // Restarted level
}

split
{
    return old.controlStatus == 0 && current.controlStatus == 1;
}

isLoading
{
    return true;
}
