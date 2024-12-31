// author: SBDWolf
// v1.5


state("Doohickey-Win64-Shipping")
{
}

startup
{
    settings.Add("MAP_Tutorial_Persistent", true, "Midsummer Meadow");
    settings.Add("Tutorial_Warp1", false, "Midsummer Meadow Warp 1", "MAP_Tutorial_Persistent");
    settings.Add("Tutorial_Warp2", false, "Midsummer Meadow Warp 2", "MAP_Tutorial_Persistent");
    settings.Add("Tutorial_Warp3", false, "Midsummer Meadow Warp 3", "MAP_Tutorial_Persistent");
    settings.Add("Tutorial_Warp4", false, "Midsummer Meadow Warp 4", "MAP_Tutorial_Persistent");

    settings.Add("MAP_Temple_Persistent", true, "Tadpole Temple");
    settings.Add("Temple_Warp1", false, "Tadpole Temple Warp 1", "MAP_Temple_Persistent");
    settings.Add("Temple_Warp2", false, "Tadpole Temple Warp 2", "MAP_Temple_Persistent");
    settings.Add("Temple_Warp3", false, "Tadpole Temple Warp 3", "MAP_Temple_Persistent");
    settings.Add("Temple_Warp4", false, "Tadpole Temple Warp 4", "MAP_Temple_Persistent");

    settings.Add("MAP_Mountain_Persistent", true, "Arctic Ascent");
    settings.Add("Mountain_Warp1", false, "Arctic Ascent Warp 1", "MAP_Mountain_Persistent");
    settings.Add("Mountain_Warp2", false, "Arctic Ascent Warp 2", "MAP_Mountain_Persistent");
    settings.Add("Mountain_Warp3", false, "Arctic Ascent Warp 3", "MAP_Mountain_Persistent");
    settings.Add("Mountain_Warp4", false, "Arctic Ascent Warp 4", "MAP_Mountain_Persistent");

    settings.Add("MAP_Lakeside_Persistent", true, "Fishy Factory");
    settings.Add("Lakeside_Warp1", false, "Fishy Factory Warp 1", "MAP_Lakeside_Persistent");
    settings.Add("Lakeside_Warp2", false, "Fishy Factory Warp 2", "MAP_Lakeside_Persistent");
    settings.Add("Lakeside_Warp3", false, "Fishy Factory Warp 3", "MAP_Lakeside_Persistent");
    settings.Add("Lakeside_Warp4", false, "Fishy Factory Warp 4", "MAP_Lakeside_Persistent");

    settings.Add("MAP_Castle_Persistent", true, "Cloud Castle");
    settings.Add("Castle_Warp1", false, "Cloud Castle Warp 1", "MAP_Castle_Persistent");
    settings.Add("Castle_Warp2", false, "Cloud Castle Warp 2", "MAP_Castle_Persistent");
    settings.Add("Castle_Warp3", false, "Cloud Castle Warp 3", "MAP_Castle_Persistent");
    settings.Add("Castle_Warp4", false, "Cloud Castle Warp 4", "MAP_Castle_Persistent");

    settings.Add("MAP_Manto_Persistent", true, "Sorcerer's Sanctuary");
    settings.Add("Manto_Checkpoint1", false, "Sorcerer's Sanctuary Post-Manto1 Checkpoint", "MAP_Manto_Persistent");
    settings.Add("Manto_Checkpoint2", false, "Sorcerer's Sanctuary Post-Manto2 Checkpoint", "MAP_Manto_Persistent");
    settings.Add("Manto_Checkpoint3", false, "Sorcerer's Sanctuary Post-Manto3 Checkpoint", "MAP_Manto_Persistent");

    vars.checkpointNames = new Dictionary<string, string>() {
        {"0PersistentLevel.BP_Checkpoint_Respawn_C_6", "Tutorial_Warp1"},
        {"0PersistentLevel.BP_Checkpoint_Respawn_C_9", "Tutorial_Warp2"},
        {"0PersistentLevel.BP_Checkpoint_Respawn_C_5", "Tutorial_Warp3"},
        {"0PersistentLevel.BP_Checkpoint_Respawn_C_14", "Tutorial_Warp4"},

        {"1PersistentLevel.BP_Checkpoint_Respawn_C_0", "Temple_Warp1"},
        {"1PersistentLevel.BP_Checkpoint_Respawn_C_4", "Temple_Warp2"},
        {"1PersistentLevel.BP_Checkpoint_Respawn_C_17", "Temple_Warp3"},
        {"1PersistentLevel.BP_Checkpoint_Respawn_C_12", "Temple_Warp4"},

        {"2PersistentLevel.BP_Checkpoint_Respawn_C_1", "Mountain_Warp1"},
        {"2PersistentLevel.BP_Checkpoint_Respawn_C_5", "Mountain_Warp2"},
        {"2PersistentLevel.BP_Checkpoint_Respawn_C_21", "Mountain_Warp3"},
        {"2PersistentLevel.BP_Checkpoint_Respawn_C_15", "Mountain_Warp4"},

        {"3PersistentLevel.BP_Checkpoint_Respawn_C_1", "Lakeside_Warp1"},
        {"3PersistentLevel.BP_Checkpoint_Respawn_C_6", "Lakeside_Warp2"},
        {"3PersistentLevel.BP_Checkpoint_Respawn_C_21", "Lakeside_Warp3"},
        {"3PersistentLevel.BP_Checkpoint_Respawn_C_16", "Lakeside_Warp4"},

        {"4PersistentLevel.BP_Checkpoint_Respawn_C_7", "Castle_Warp1"},
        {"4PersistentLevel.BP_Checkpoint_Respawn_C_11", "Castle_Warp2"},
        {"4PersistentLevel.BP_Checkpoint_Respawn_C_15", "Castle_Warp3"},
        {"4PersistentLevel.BP_Checkpoint_Respawn_C_21", "Castle_Warp4"},

        {"5PersistentLevel.BP_Checkpoint_Respawn_C_0", "Manto_Checkpoint1"},
        {"5PersistentLevel.BP_Checkpoint_Respawn_C_6", "Manto_Checkpoint2"},
        {"5PersistentLevel.BP_Checkpoint_Respawn_C_8", "Manto_Checkpoint3"}
    };

    vars.levelIndexes = new Dictionary<string, int>() {
        {"MAP_Tutorial_Persistent", 0},        
        {"MAP_Temple_Persistent", 1},        
        {"MAP_Mountain_Persistent", 2},
        {"MAP_Lakeside_Persistent", 3},
        {"MAP_Castle_Persistent", 4},
        {"MAP_Manto_Persistent", 5}
    };


    vars.completedSplits = new HashSet<string>();

    vars.previousLevel = "";
    vars.currentWorldName = "";
}

init
{
    //
    // Using Signature Scans to find some stuff
    //
    var exe = modules.First();
    var scanner = new SignatureScanner(game, exe.BaseAddress, exe.ModuleMemorySize);

    var GWorldPtr = IntPtr.Zero;

    GWorldPtr = scanner.Scan(new SigScanTarget(3, "48 8B 1D ?? ?? ?? ?? 48 85 DB 74 ?? 41 B0 01"));
    if (GWorldPtr == IntPtr.Zero) {
        print("Could not find GWorld pointer!");
        return;
    }

    var GWorld = IntPtr.Add(GWorldPtr, game.ReadValue<int>(GWorldPtr) + 4);
    vars.GWorld = new MemoryWatcher<long>(new DeepPointer(GWorld));
    vars.SaveLevelData = new MemoryWatcher<long>(new DeepPointer(GWorld, 0x1D8, 0x250, 0x30));
    vars.SaveLevelSize = new MemoryWatcher<byte>(new DeepPointer(GWorld, 0x1D8, 0x250, 0x38));
    vars.WorldFName = new MemoryWatcher<ulong>(new DeepPointer(GWorld, 0x18));
    // i believe this property is actually {this byte} & 2 
    vars.bTriggerPostLoadMap = new MemoryWatcher<byte>(new DeepPointer(GWorld, 0x13B));

    var FNamePoolPtr = IntPtr.Zero;

    FNamePoolPtr = scanner.Scan(new SigScanTarget(7, "8B D9 74 ?? 48 8D 15 ?? ?? ?? ?? EB"));
    if (FNamePoolPtr == IntPtr.Zero) {
        print("Could not find GNames pointer!");
        return;
    }

    var FNamePool = IntPtr.Add(FNamePoolPtr, game.ReadValue<int>(FNamePoolPtr) + 4);

    //
    // End of Signature Scans
    //


    const int FNameBlockOffsetBits = 16;
    const int FNameBlockOffsets = 1 << FNameBlockOffsetBits;
    const int Stride = 2; // alignof(FNameEntry)

    var nameCache = new Dictionary<ulong, string>() { { 0, "None" } };

    // thanks to apple1417 and ero for this one
    vars.FNameToString = (Func<ulong, string>)((fName) => {
        // FName.Number
        var number          = (fName & 0xFFFFFFFF00000000) >> 0x20;

        // FName.ComparisonIndex
        var comparisonIndex = (fName & 0x00000000FFFFFFFF) >> 0x00;

        string name;
        if (!nameCache.TryGetValue(comparisonIndex, out name)) {

            // FNameEntryHandle.Block
            var blockIndex = comparisonIndex >> FNameBlockOffsetBits;

            // FNameEntryHandle.Offset
            var offset     = comparisonIndex & (FNameBlockOffsets - 1);

            // FNamePool.Entries.Blocks[Block]
            var block = game.ReadPointer(FNamePool + 0x10 + (int)blockIndex * 0x8);

            // FNamePool.Entries.Blocks[Block] + Stride * Offset
            var entry = block + Stride * (int)offset;

            // FNameEntryHeader.Len
            var length = game.ReadValue<short>(entry) >> (1 + 5); // bIsWide, LowercaseProbeHash

            // FNameEntry.AnsiName
            name = game.ReadString((entry + 2), length); // sizeof(FNameEntryHeader) = 2

            nameCache.Add(comparisonIndex, name);
        }
        return number == 0 ? name : name + "_" + (number - 1);
    });


    vars.ReadNullTerminatedString = (Func<IntPtr, string>)(ptr =>
    {
        if (ptr == IntPtr.Zero)
            return null;

        // calculate size
        int length = 0;
        char currentChar;
        while (true) {
            currentChar = memory.ReadValue<char>(ptr + length * 2);
            if (currentChar == 0)
                break;
            length++;
        }
        
        return memory.ReadString(ptr, length * 2);
    });
}

onStart
{
    vars.completedSplits.Clear();
    vars.previousLevel = "";
}

start {
    //print(vars.previousLevel);
    if ((vars.previousLevel == "MAP_SelectDifficulty_Persistent" || vars.previousLevel == "MAP_MainMenu") && vars.currentWorldName == "MAP_Tutorial_Persistent") {
        return true;
    }
    if (vars.currentWorldName != "None") {
        vars.previousLevel = vars.currentWorldName;
    }
}

update {
    vars.GWorld.Update(game);
    vars.SaveLevelData.Update(game);
    vars.SaveLevelSize.Update(game);
    vars.WorldFName.Update(game);
    vars.bTriggerPostLoadMap.Update(game);

    vars.currentWorldName = vars.FNameToString(vars.WorldFName.Current);

    //IntPtr levelEntryPtr = (IntPtr)(vars.SaveLevelData.Current + vars.levelIndexes[vars.currentWorldName] * 0x88);
    //IntPtr checkpointNameStringPtr = memory.ReadValue<IntPtr>(levelEntryPtr + 0x40);
    //string checkpointName = vars.ReadNullTerminatedString(checkpointNameStringPtr);
    //print(checkpointName);
}

split
{   
    for (int i = 0 ; i < vars.SaveLevelSize.Current ; i++) {
        // each level entry is 0x88 long. at 0x0, there's the pointer to the string containing the name of the current level.
        // if a level hasn't been unlocked yet, then that entry won't exist.
        IntPtr levelEntryPtr = (IntPtr)(vars.SaveLevelData.Current + i * 0x88);
        IntPtr stringPtr = memory.ReadValue<IntPtr>(levelEntryPtr);

        // for some reason beating the final level adds a level entry with a null string...
        if (stringPtr == IntPtr.Zero)
            continue;

        string levelName = vars.ReadNullTerminatedString(stringPtr);
        // part of the level entry struct. set to true if a level has been finished.
        bool levelFinished = memory.ReadValue<bool>(levelEntryPtr + 0x11);

        // if level has been finished and we haven't split for it yet
        if (settings[levelName] && (vars.currentWorldName == "MAP_MainMenu" || vars.currentWorldName == "MAP_Credits" || vars.currentWorldName == "MAP_Outro") && levelFinished && vars.completedSplits.Add(levelName)){
            return true;
        }
    }

    // if we hit a checkpoint that we need to split for and we haven't split for it yet
    int levelIndex = 0;
    if (vars.levelIndexes.TryGetValue(vars.currentWorldName, out levelIndex)) {
        IntPtr levelEntryPtr = (IntPtr)(vars.SaveLevelData.Current + vars.levelIndexes[vars.currentWorldName] * 0x88);
        IntPtr checkpointNameStringPtr = memory.ReadValue<IntPtr>(levelEntryPtr + 0x40);
        string checkpointName = vars.ReadNullTerminatedString(checkpointNameStringPtr);
        if (checkpointName != null) {
            string settingName = "";
            if (vars.checkpointNames.TryGetValue(levelIndex.ToString() + checkpointName, out settingName)) {
                if (settings[settingName] && vars.completedSplits.Add(settingName)) {
                    return true;
                }
            }
        }
    }

}

isLoading
{
    return ((vars.bTriggerPostLoadMap.Current & 2) == 0);
}