// ============================================================
// === This file was created with MakeCARR.bas by RhoSigma, ===
// === use it in conjunction with its respective .bm file.  ===
// ============================================================

// --- Array(s) representing the contents of file INR-Options.bin
// ---------------------------------------------------------------------
static const uint32_t OptionsBinL0[] = {
    0,
};

static const uint8_t OptionsBinB[] = {
    20,
    0x00,0x00,0xFF,0xFF,0xFF,0xFF,0x4B,0x00,0x50,0x00,0xFF,0xFF,0x00,0x00,0x00,0x00,
    0xFF,0xFF,0x05,0x00
};

// --- Function to copy the array(s) into the provided string buffer.
// --- Buffer size is not checked, as MakeCARR makes sure it's sufficient.
// ---------------------------------------------------------------------
void ReadOptionsBinData(char *Buffer)
{
    memcpy(Buffer, &OptionsBinL0[1], OptionsBinL0[0] << 2);
    Buffer += (OptionsBinL0[0] << 2);

    memcpy(Buffer, &OptionsBinB[1], OptionsBinB[0]);
}

// --- Saved full qualified output path and filename, so we've no troubles
// --- when cleaning up, even if the current working folder was changed
// --- during program runtime.
// ---------------------------------------------------------------------
char OptionsBinName[8192]; // it's a safe size for any current OS

// --- Cleanup function to delete the written file, called by the atexit()
// --- handler at program termination time, if requested by user.
// ---------------------------------------------------------------------
void KillOptionsBinData(void)
{
    remove(OptionsBinName);
}

// --- Function to write the array(s) back into a file, will return the
// --- full qualified output path and filename on success, otherwise an
// --- empty string is returned (access/write errors, file truncated).
// ---------------------------------------------------------------------
const char *WriteOptionsBinData(const char *FileName, int16_t AutoClean)
{
    FILE   *han = NULL; // file handle
    int32_t num = NULL; // written elements

    #ifdef QB64_WINDOWS
    if (!_fullpath(OptionsBinName, FileName, 8192)) return "";
    #else
    if (!realpath(FileName, OptionsBinName)) return "";
    #endif

    if (!(han = fopen(OptionsBinName, "wb"))) return "";
    if (AutoClean) atexit(KillOptionsBinData);

    num = fwrite(&OptionsBinL0[1], 4, OptionsBinL0[0], han);
    if (num != OptionsBinL0[0]) {fclose(han); return "";}

    num = fwrite(&OptionsBinB[1], 1, OptionsBinB[0], han);
    if (num != OptionsBinB[0]) {fclose(han); return "";}

    fclose(han);
    return OptionsBinName;
}

