// ============================================================
// === This file was created with MakeCARR.bas by RhoSigma, ===
// === use it in conjunction with its respective .bm file.  ===
// ============================================================

// --- Array(s) representing the contents of file Add16px.png
// ---------------------------------------------------------------------
static const uint32_t Add16ImgL0[] = {
    120,
    0x474E5089,0x0A1A0A0D,0x0D000000,0x52444849,0x10000000,0x10000000,0x00000608,0xFFF31F00,
    0x00000061,0x59487009,0x0B000073,0x0B000013,0x9A000113,0x0000189C,0x44499F01,0xCB385441,
    0x6EBD929D,0x85105113,0x08B675BF,0x90160528,0xC257F848,0x242D808F,0x5414548A,0x8A911688,
    0xE0B7928A,0x3DDAE23D,0x902E16E5,0x09084895,0x4169C58A,0xD66C41B2,0xBD77BDEB,0x1D628773,
    0x446D837B,0x9DCEEE98,0xD1CCCE73,0x0F52D8F1,0xD5B536DF,0x05EB5C6E,0x025F6183,0x72B300DE,
    0xD046DFDF,0xF978376A,0xB39915EC,0x25CC3118,0x761D3821,0x227F8380,0x25254800,0xD7208293,
    0xBFB1AEC5,0xAC73E410,0x283158B3,0x64083FEE,0xE06E5D8E,0x1276F657,0x6B0CDB78,0xD51C9AB6,
    0x12CEB08F,0xA57E3167,0x6F1A3842,0xB0C18380,0x0DDAB7EF,0x817D3F9E,0x32E64315,0x33AC188C,
    0xBE2FD944,0xC7199F44,0x1C0C5621,0xD02A81AE,0x8483D7BD,0x37BE5F8E,0x29718B13,0x3E432F5F,
    0xC9273CFE,0x15550D93,0x0B70E310,0x4A907B5D,0x2CC3158A,0x8E9B398F,0x8A21C718,0x4573826E,
    0xB956228C,0x4401F6FA,0x9729E017,0x7EEA888B,0x3DFB4795,0x2B0F9346,0x8D76ED60,0xB86AB707,
    0xA14120BC,0x985EA77E,0x29CC77B8,0xD2B29D09,0xC793C9F1,0x57CF0E9F,0x1EDDEEEF,0x3F05DFEF,
    0x43C0B888,0x094D1B56,0x0F3C65FD,0xC27AEDAE,0x50A262B7,0x71103974,0x06BC6721,0xF149A526,
    0x6D9CD197,0x4A2A0C1E,0x50BA2A9E,0xE013CA96,0xB2AC797B,0x202A202B,0x82ACE2A9,0xD893CDC7,
    0x65C3DFBD,0x6A8DD585,0xC10466FD,0xD3FFD860,0xC2129D58,0xFAABC0DA,0xE3E8FA0D,0x4C1873CB
};

static const uint8_t Add16ImgB[] = {
    13,
    0xFE,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,0x42,0x60,0x82
};

// --- Function to copy the array(s) into the provided string buffer.
// --- Buffer size is not checked, as MakeCARR makes sure it's sufficient.
// ---------------------------------------------------------------------
void ReadAdd16ImgData(char *Buffer)
{
    memcpy(Buffer, &Add16ImgL0[1], Add16ImgL0[0] << 2);
    Buffer += (Add16ImgL0[0] << 2);

    memcpy(Buffer, &Add16ImgB[1], Add16ImgB[0]);
}

// --- Saved full qualified output path and filename, so we've no troubles
// --- when cleaning up, even if the current working folder was changed
// --- during program runtime.
// ---------------------------------------------------------------------
char Add16ImgName[8192]; // it's a safe size for any current OS

// --- Cleanup function to delete the written file, called by the atexit()
// --- handler at program termination time, if requested by user.
// ---------------------------------------------------------------------
void KillAdd16ImgData(void)
{
    remove(Add16ImgName);
}

// --- Function to write the array(s) back into a file, will return the
// --- full qualified output path and filename on success, otherwise an
// --- empty string is returned (access/write errors, file truncated).
// ---------------------------------------------------------------------
const char *WriteAdd16ImgData(const char *FileName, int16_t AutoClean)
{
    FILE   *han = NULL; // file handle
    int32_t num = NULL; // written elements

    #ifdef QB64_WINDOWS
    if (!_fullpath(Add16ImgName, FileName, 8192)) return "";
    #else
    if (!realpath(FileName, Add16ImgName)) return "";
    #endif

    if (!(han = fopen(Add16ImgName, "wb"))) return "";
    if (AutoClean) atexit(KillAdd16ImgData);

    num = fwrite(&Add16ImgL0[1], 4, Add16ImgL0[0], han);
    if (num != Add16ImgL0[0]) {fclose(han); return "";}

    num = fwrite(&Add16ImgB[1], 1, Add16ImgB[0], han);
    if (num != Add16ImgB[0]) {fclose(han); return "";}

    fclose(han);
    return Add16ImgName;
}

