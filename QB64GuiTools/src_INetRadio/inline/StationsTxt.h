// ============================================================
// === This file was created with MakeCARR.bas by RhoSigma, ===
// === use it in conjunction with its respective .bm file.  ===
// ============================================================

// --- Array(s) representing the contents of file INR-Stations.txt
// ---------------------------------------------------------------------
static const uint32_t StationsTxtL0[] = {
    200,
    0x79405A4B,0x92040703,0xDCD06734,0x84079309,0xD2643094,0x00A069BC,0x703A1D0D,0xC178BC74,
    0x3A1CCD26,0x90B8DC65,0x9AE29123,0xB8CE6E34,0xCDA6F318,0xDF13930B,0xE371B0BC,0x391C0C06,
    0x5394845E,0x1BCC0C26,0xB0CC6234,0x9D0A7169,0xBA287430,0x88849101,0x2C351AC5,0xA7634932,
    0x201AD14C,0x0188805A,0x29880623,0xA1BCDE6D,0x92840683,0x58F47A30,0xE391A8C4,0x5729350B,
    0xA6E324B6,0x3136CFE7,0x217CBE5A,0xA20C8646,0x90C4BE39,0x9C0DA381,0x62AD5419,0x6B95A1B5,
    0xE5573210,0xA6539D2C,0x163A48CD,0xAA98E465,0xACD5EAA0,0x0D7EBB5B,0xD9ECB63B,0x34416BB4,
    0xCD86C329,0xD3AC3B9B,0x719B69E0,0x40BC4763,0x18FCB255,0x985F31DA,0x80E06862,0x61062371,
    0x7F1588C3,0xB21A2C66,0x419432E4,0xB9BCCE5E,0x8FDFE2F3,0x33110441,0x3A9B0DE7,0x410C4122,
    0x1BF5E693,0xE6DFB6F1,0x3773E3A6,0x6B8DDF5D,0xA30BF704,0xC91AFDC6,0x3ECE270F,0xC9E4747F,
    0xD1BBAB95,0x67B380AC,0x8AB9FFD0,0xAD166B25,0x64203D5A,0x637178D0,0x73B8EE3D,0xABB18E59,
    0x317D6F5B,0xA8C46A37,0x72FF6341,0x47B9CFFF,0x73196E9F,0xF3AF02C0,0x4099A22C,0x990C2280,
    0x08ED1BA8,0x8308C4D8,0xBB6AD98D,0x3EB836E8,0x8324E92C,0xB2C93C70,0xF1E8CEFA,0xC86216C7,
    0x2C8B0641,0x244661A2,0x2272546D,0x226B46CB,0xC482950C,0xF2F748B0,0x3826723A,0xBEAEA4B6,
    0xB29CA2E5,0xB4AE054A,0xB48A4688,0xAE4BB1CC,0xB64F435A,0xB31B6826,0x38DAF7BD,0xEF34A293,
    0xD74D832C,0x4DC3BB60,0x12B0152A,0x346F1ACB,0xDE293474,0x310D6318,0xA78F6487,0x341A8132,
    0x93EB4349,0x1835D2C3,0x054E5385,0x0C2978A6,0x4D189A23,0x00E89F88,0x46360841,0x3FBA4322,
    0x8C63485F,0xE1706432,0x30C236BB,0x84975043,0x5A8C558B,0x8E55B8DD,0x216B0D28,0x20154745,
    0x835533CA,0x37D5F56D,0x8C2398E6,0xE3C8CB59,0xDD73650D,0x575FD7B5,0x6CC4361D,0x87166DB7,
    0x368BFB67,0x38601A06,0xB96BD56A,0x37D4623A,0x47EB0AAE,0xD5E5C489,0x25856057,0xF033AFB6,
    0x365B6ABD,0x5DB75A24,0x97822CE6,0xE55D7A5A,0x54D7892A,0xB0A4037A,0x56432CCA,0xA95BD226,
    0x0DC97F0C,0x7562DCF8,0x8DAF0D7D,0x61D68617,0x56B62019,0x020D1B62,0xDD518A81,0x73601908,
    0x0E098607,0x5703DC83,0x9E1D7765,0x2354DE41,0x340A8D1E,0x8E5998CA,0xB9B8E034,0xEE4960DC,
    0x998DACCB,0x86E80386,0x5ABA25A5,0x22A66156,0x4E66948D,0x47A7B303,0xA585F9D6,0x330A5A52,
    0x7784E1AC,0x9A403BEB,0xC97B8403,0x9F572ABA,0xAF63CE12,0xB6D6E239,0x1D0FBB60,0xDC178D03,
    0xB96E01B6,0x572B5C21,0xE390E723,0x95B4168C,0x61C225A3,0x350E6392,0x3F6E585E,0x1A233938
};

static const uint8_t StationsTxtB[] = {
    19,
    0x20,0x00,0x00,0x51,0x42,0x36,0x34,0x4C,0x5A,0x57,0x31,0x90,0x05,0x00,0x00,0xDA,
    0x03,0xAB,0x76
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

