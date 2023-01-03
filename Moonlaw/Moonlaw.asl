// autosplitter for the critically acclaimed "Moonlaw"
// author: SBDWolf
// v1.0

state("Moonlaw")
{
    byte hasControl  : "Moonlaw.exe", 0x007D2614, 0x50, 0x1A0, 0x20; // 0 if player has no control, 1 if player has control
    byte currentScene  : "Moonlaw.exe", 0x007D2614, 0x50, 0x2B0; // is 0x05 at starting room
}

startup
{
    settings.Add("groundshredder", true, "Groundshredder");
    settings.Add("eye_spawn", true, "Eye Spawn");
    settings.Add("rodney", true, "Rodney");
    settings.Add("plasma_torizo", true, "Plasma Torizo");
    settings.Add("ending", true, "Ending");
}

split
{
    if(settings["groundshredder"] && !vars.completedSplits["groundshredder"] && current.currentScene == 0x16 && old.currentScene == 0x15) // if player is coming out of the groundshredder room
    {
        vars.completedSplits["groundshredder"] = true;
        return true;
    }
    if(settings["eye_spawn"] && !vars.completedSplits["eye_spawn"] && current.currentScene == 0x22 && old.currentScene == 0x21) // if player is coming out of the eye spawn room
    {   
        vars.completedSplits["eye_spawn"] = true;
        return true;
    }
    if(settings["rodney"] && !vars.completedSplits["rodney"] && current.currentScene == 0x3F && old.currentScene == 0x3D) // if player is coming out of the rodney room
    {
        vars.completedSplits["rodney"] = true;
        return true;
    }
    if(settings["plasma_torizo"] && !vars.completedSplits["plasma_torizo"] && current.currentScene == 0x4D && old.currentScene == 0x4C) // if player is coming out of the plasma torizo room
    {
        vars.completedSplits["plasma_torizo"] = true;
        return true;
    }
    if(settings["ending"] && !vars.completedSplits["ending"] && current.currentScene == 0x69) // if game is finally over
    {
        vars.completedSplits["ending"] = true;
        return true;
    }
    return false;
}

start
{
    if(current.currentScene == 0x05 && current.hasControl == 0x01 && old.hasControl == 0x00) // if in first room of the game and player has just gained control on that frame
    {
        // this dictionary contains the splits that have already been completed, so that if you die and go through the same segment it won't split twice
        vars.completedSplits = new Dictionary<string, bool>();
        vars.completedSplits.Add("groundshredder", false);
        vars.completedSplits.Add("eye_spawn", false);
        vars.completedSplits.Add("rodney", false);
        vars.completedSplits.Add("plasma_torizo", false);
        vars.completedSplits.Add("ending", false);
        return true;
    }
    return false;
}

reset
{
    if(current.currentScene == 0x65) // if on title screen
        return true;
    return false;
}