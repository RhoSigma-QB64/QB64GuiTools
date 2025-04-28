// ============================================================
// === This file was created with MakeCARR.bas by RhoSigma, ===
// === use it in conjunction with its respective .bm file.  ===
// ============================================================

// --- Array(s) representing the contents of file INR-Stations.txt
// ---------------------------------------------------------------------
static const uint32_t StationsTxtL0[] = {
    64,
    0x99A4EE53,0x11C40733,0xD8DE6F39,0x0140D329,0xE0743A1A,0x42F178E8,0x6136194E,0x3170C4F2,
    0x33C1A087,0x7196190A,0x8BCD0631,0x1E0B0387,0x8F461254,0x2711879E,0x87317C56,0x6D30C60E,
    0xD339CA3C,0x931CA0C2,0x9C5CDB28,0x1B45E6A3,0xC4BE3338,0x61E38190,0xDE733110,0xA743A9B0,
    0x6821880C,0xF361B0D2,0x894CAAC6,0xCCDE2D14,0x9B8D26D9,0xA4D82E33,0x46C33869,0x886F930D,
    0xC351818A,0x4EA60D6E,0x1878CE93,0x100C4603,0xA42CDA53,0x4B840683,0x649A2098,0x71677AF4,
    0x69613C1A,0x4659C592,0x6CB55A27,0x4B95C2DD,0x180E0697,0xC5E86237,0x602FD7C1,0x18DF84C1,
    0x2632FC46,0xD535B144,0x926CC9AC,0x97B29B8C,0x331C74DB,0x191885F7,0xC8CC6232,0x82B4FA51,
    0x270F85C1,0x064203D6,0x2637178D,0xDB417D8F,0xBADC18F6,0x2DFEF675,0x188D46E6,0x571C6835
};

static const uint8_t StationsTxtB[] = {
    21,
    0xFA,0x10,0x20,0x00,0x00,0x51,0x42,0x36,0x34,0x4C,0x5A,0x57,0x31,0x61,0x01,0x00,
    0x00,0x15,0xF2,0xA0,0xF0
};

// --- Function to copy the array(s) into the provided string buffer.
// --- Buffer size is not checked, as MakeCARR makes sure it's sufficient.
// ---------------------------------------------------------------------
void ReadStationsTxtData(char *Buffer)
{
    memcpy(Buffer, &StationsTxtL0[1], StationsTxtL0[0] << 2);
    Buffer += (StationsTxtL0[0] << 2);

    memcpy(Buffer, &StationsTxtB[1], StationsTxtB[0]);
}

// --- Saved full qualified output path and filename, so we've no troubles
// --- when cleaning up, even if the current working folder was changed
// --- during program runtime.
// ---------------------------------------------------------------------
char StationsTxtName[8192]; // it's a safe size for any current OS

// --- Cleanup function to delete the written file, called by the atexit()
// --- handler at program termination time, if requested by user.
// ---------------------------------------------------------------------
void KillStationsTxtData(void)
{
    remove(StationsTxtName);
}

// --- Function to write the array(s) back into a file, will return the
// --- full qualified output path and filename on success, otherwise an
// --- empty string is returned (access/write errors, file truncated).
// ---------------------------------------------------------------------
const char *WriteStationsTxtData(const char *FileName, int16_t AutoClean)
{
    FILE   *han = NULL; // file handle
    int32_t num = NULL; // written elements

    #ifdef QB64_WINDOWS
    if (!_fullpath(StationsTxtName, FileName, 8192)) return "";
    #else
    if (!realpath(FileName, StationsTxtName)) return "";
    #endif

    if (!(han = fopen(StationsTxtName, "wb"))) return "";
    if (AutoClean) atexit(KillStationsTxtData);

    num = fwrite(&StationsTxtL0[1], 4, StationsTxtL0[0], han);
    if (num != StationsTxtL0[0]) {fclose(han); return "";}

    num = fwrite(&StationsTxtB[1], 1, StationsTxtB[0], han);
    if (num != StationsTxtB[0]) {fclose(han); return "";}

    fclose(han);
    return StationsTxtName;
}

