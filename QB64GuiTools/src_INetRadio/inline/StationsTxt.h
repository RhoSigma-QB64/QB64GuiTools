// ============================================================
// === This file was created with MakeCARR.bas by RhoSigma, ===
// === use it in conjunction with its respective .bm file.  ===
// ============================================================

// --- Array(s) representing the contents of file INR-Stations.txt
// ---------------------------------------------------------------------
static const uint32_t StationsTxtL0[] = {
    168,
    0x79405A4B,0x92040703,0xDCD06734,0x84079309,0xD2643094,0x00A069BC,0x703A1D0D,0xC178BC74,
    0x3A1CCD26,0x90B8DC65,0x9AE29123,0xB8CE6E34,0xCDA6F318,0xDF13930B,0xE371B0BC,0x391C0C06,
    0x5394845E,0x1BCC0C26,0xB0CC6234,0x1A499169,0xD68A653B,0x4402D100,0x4031180C,0xE6F3694C,
    0x20341D0D,0xA3D18494,0x8D4622C7,0x49A85F1C,0x1925B2B9,0xB67F3D37,0xE5F2D189,0x6432310B,
    0x25F1CD10,0x6D1C0C86,0x9A38CCE0,0xA68DA974,0xAD4EA34F,0xD6EB357A,0x34407AAE,0xCD86C329,
    0xD38C3B9B,0x719B01E0,0x40B5C763,0xA8FCB255,0x985BE994,0x80E06862,0xDDC62371,0x2AFB7BBC,
    0xB039FA40,0xC4411053,0xA6C379CC,0x4310488E,0xFC79A4D0,0xB165B706,0xDCF8E999,0xE033D67C,
    0xC2E3A11A,0x46BCD1A8,0xFD7CBD6A,0xD54C16BE,0x5CAD562A,0x419082BD,0xE08DC5E3,0x659AC998,
    0xE6AD2639,0xDCC5CBB6,0x06A311A8,0x2DABE88D,0x02099C46,0x2099184A,0x023EC4CB,0x36184C59,
    0xBC5F2B93,0xC97D363C,0x9FF30693,0xF966539C,0x0301FF99,0x1C86216C,0xC14FA064,0xC89C18FB,
    0x089AD8C1,0xC501A543,0xB638903B,0x8E099C12,0x6E5BF70D,0xC42D0A35,0xF4FC3ED0,0xC6A9F0EB,
    0x09AC937C,0xAE1C46CA,0xA44E36B8,0x1F19C528,0x36A60974,0x0EEC831C,0xA0542F17,0x14348A3E,
    0xDE293632,0x110D6318,0xA78E140B,0x71FA8112,0x93972141,0x9435CA63,0x978A68B4,0x89A230C2,
    0x89F884D8,0x6084100E,0xCA322463,0x17C76390,0x0CA318D2,0xADA85C19,0xF0CC308D,0xD8B8C891,
    0x374E0314,0xC28394E4,0x4F985ABC,0x44FB3281,0xE637CD53,0x370C2398,0x0DE3C8CB,0x33BCEB43,
    0xFCCD3DCF,0x29493D73,0x4587144D,0x4CD46BA7,0x023A9F48,0xA29437CC,0x3689402A,0x3E4F53C5,
    0xAE1404FD,0x8A555A33,0x22243652,0x1CD654D5,0xA7CD333D,0x0A883A0A,0xB598DD30,0x0D415B53,
    0x88830E14,0x465814CB,0x04155587,0x2FE0D02A,0x60E034D9,0x714FD6B6,0x32AB2985,0xDAB6F388,
    0x362DAF53,0x6A5234DB,0x3D7048D7,0xB859F3ED,0x8D3770E8,0x574C8D7B,0x9A403BD8,0xAF560403,
    0x9F4EAA52,0xADC3CD7C,0x549DFC39,0x448781D7,0x173205E3,0xAFBB7806,0xC10F1CAE,0xA338E439,
    0x68E54985,0xE4986209,0x178D4398,0x22CE8B56,0x51000080,0x4C343642,0x6731575A,0x50000004
};

static const uint8_t StationsTxtB[] = {
    3,
    0x07,0xFB,0x11
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

