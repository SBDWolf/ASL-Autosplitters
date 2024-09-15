// author: SBDWolf
// v1.3


state("Doohickey-Win64-Shipping")
{
}

startup
{
    settings.Add("MAP_Tutorial_Persistent", true, "Midsummer Meadow");
    settings.Add("MAP_Temple_Persistent", true, "Tadpole Temple");
    settings.Add("MAP_Mountain_Persistent", true, "Arctic Ascent");
    settings.Add("MAP_Lakeside_Persistent", true, "Fishy Factory");
    settings.Add("MAP_Castle_Persistent", true, "Cloud Castle");
    settings.Add("MAP_Manto_Persistent", true, "Sorcerer's Sanctuary");

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

    vars.currentWorldName = vars.FNameToString(vars.WorldFName.Current);
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
}

isLoading
{
    return vars.GWorld.Current == 0;
}