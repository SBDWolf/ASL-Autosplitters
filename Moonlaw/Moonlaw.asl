// autosplitter for the critically acclaimed "Moonlaw"
// author: SBDWolf
// v1.0

state("Moonlaw")
{
    bool hasControl : 0x7D2614, 0x50, 0x1A0, 0x20; // true if player has control, false otherwise
    byte scene      : 0x7D2614, 0x50, 0x2B0; // is 0x05 at starting room
}

startup
{
    settings.Add("0x16", true, "Groundshredder"); // if player is coming out of the groundshredder room
    settings.Add("0x22", true, "Eye Spawn");      // if player is coming out of the eye spawn room
    settings.Add("0x3F", true, "Rodney");         // if player is coming out of the rodney room
    settings.Add("0x4D", true, "Plasma Torizo");  // if player is coming out of the plasma torizo room
    settings.Add("0x69", true, "Ending");         // if game is finally over
    
    vars.completedSplits = new HashSet<string>();
}

onStart
{
    vars.completedSplits.Clear();
}

start
{
    // if in first room of the game and player has just gained control on that frame
    return !old.hasControl && current.hasControl && current.scene == 0x05;
}

split
{
    // if scene changed, is in the settings, and has not yet been split for
    return old.scene != current.scene && settings["0x" + current.scene.ToString("X")] && vars.completedSplits.Add(current.Scene);
}

reset
{
    // if on title screen
    return old.scene != 0x65 && current.scene == 0x65;
}
