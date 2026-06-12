// ============================================================
// === This file was created with MakeCARR.bas by RhoSigma, ===
// === use it in conjunction with its respective .bm file.  ===
// ============================================================

// --- Array(s) representing the contents of file Import16px.png
// ---------------------------------------------------------------------
static const uint32_t Import16ImgL0[] = {
    160,
    0x474E5089,0x0A1A0A0D,0x0D000000,0x52444849,0x10000000,0x10000000,0x00000608,0xFFF31F00,
    0x00000061,0x59487009,0x0B000073,0x0B000013,0x9A000113,0x0000189C,0x44494C02,0xCB385441,
    0x484B928D,0x86146194,0xBFFBEF9F,0x5FBC667F,0x8C654B18,0x04C84CBC,0x34B130BA,0xA49448B0,
    0x1504455A,0x5B416418,0x0909DD77,0x68222082,0x9032ED11,0x90911702,0xA510B610,0x62E83084,
    0x29498D17,0x636F2B35,0x16D7FCCE,0x16326339,0x0E6EF0BE,0xCF7879DF,0x59608E77,0xBB3EEF57,
    0xB8195754,0x04B24B88,0xAFE1EBC4,0x5FAE6FD3,0x45F07739,0xC07BF75F,0x9637F155,0x90D81363,
    0x0CF8C8C1,0xB6C0C351,0xCB0C559D,0xCC2D29B6,0xC54350E1,0xFF38D356,0x1D6D86E8,0x33D03978,
    0xB6D8009C,0xD914AE8D,0x5A406999,0xCC688852,0x95D00840,0x757348E4,0x785E69A9,0x67A07278,
    0xB2C00AF7,0x4D340291,0x269496B0,0xE11B36F8,0x0024E8D5,0xA585CDC1,0x444C9D40,0x14A42CB4,
    0xB3F60C4C,0x92853D30,0x84C9A502,0xEC9D1EBD,0x96624CCC,0xE0EA3160,0x2F800EB8,0x0B2C3001,
    0x3FE60A4D,0xEDA065BE,0x51E19304,0x35D02694,0xA4934789,0x52327578,0xFAA4647D,0x494F4AC8,
    0x024AD1FC,0x814A40D3,0xD70E4947,0xB9777884,0x08F0A98D,0x2528134A,0xD7B2FFD1,0x3F9C70A3,
    0x2C1ED100,0x8B8A4B71,0x37030D70,0xFCCC4516,0x3E497B60,0x7D2CDCD6,0x9BF28A4B,0x0B2A6C1D,
    0x4572EF2E,0xD18E3FAF,0x5C7433BC,0xB0151716,0x5A82BAAB,0x99AA8FBF,0x63739530,0x620D0D2C,
    0xF140FA7E,0x773D30F8,0x511A616E,0xE55CBA3C,0xB3AA08F8,0x76E3BFB7,0xCA997F6F,0xCACA07F2,
    0x5FB404B7,0xC7369C13,0xF7053098,0xDC683B82,0x8A5A4CDB,0xAB935D0F,0x0047C412,0xF7F20748,
    0xFB5FB6B7,0xBDC5FE3C,0xFBACE67F,0x96DC2FD8,0xF3B75ADA,0xFD3B9741,0x5F9DC173,0xF5DC9234,
    0x5A05C864,0x22011014,0x231BD9E9,0xA4F90585,0xBDD2E4E6,0xAD7D89AD,0xD0D3D8A7,0x5DEBD788,
    0x09E22EF3,0x5A648712,0x6A085226,0xAF251D8E,0x28509EBE,0x35E6CFF4,0x23699601,0x2F372084,
    0x1FBF1C8F,0x53FF2521,0x11B6C032,0x49108402,0x60175B2B,0xF3FBFE71,0xA796A6AA,0x12CB1996
};

static const uint8_t Import16ImgB[] = {
    26,
    0x52,0x1A,0xAC,0x4F,0x91,0xDF,0x95,0x32,0xF2,0xC8,0x68,0x9E,0xE8,0x3E,0x00,0x00,
    0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,0x42,0x60,0x82
};

// --- Function to copy the array(s) into the provided string buffer.
// --- Buffer size is not checked, as MakeCARR makes sure it's sufficient.
// ---------------------------------------------------------------------
void ReadImport16ImgData(char *Buffer)
{
    memcpy(Buffer, &Import16ImgL0[1], Import16ImgL0[0] << 2);
    Buffer += (Import16ImgL0[0] << 2);

    memcpy(Buffer, &Import16ImgB[1], Import16ImgB[0]);
}

// --- Saved full qualified output path and filename, so we've no troubles
// --- when cleaning up, even if the current working folder was changed
// --- during program runtime.
// ---------------------------------------------------------------------
char Import16ImgName[8192]; // it's a safe size for any current OS

// --- Cleanup function to delete the written file, called by the atexit()
// --- handler at program termination time, if requested by user.
// ---------------------------------------------------------------------
void KillImport16ImgData(void)
{
    remove(Import16ImgName);
}

// --- Function to write the array(s) back into a file, will return the
// --- full qualified output path and filename on success, otherwise an
// --- empty string is returned (access/write errors, file truncated).
// ---------------------------------------------------------------------
const char *WriteImport16ImgData(const char *FileName, int16_t AutoClean)
{
    FILE   *han = NULL; // file handle
    int32_t num = NULL; // written elements

    #ifdef QB64_WINDOWS
    if (!_fullpath(Import16ImgName, FileName, 8192)) return "";
    #else
    if (!realpath(FileName, Import16ImgName)) return "";
    #endif

    if (!(han = fopen(Import16ImgName, "wb"))) return "";
    if (AutoClean) atexit(KillImport16ImgData);

    num = fwrite(&Import16ImgL0[1], 4, Import16ImgL0[0], han);
    if (num != Import16ImgL0[0]) {fclose(han); return "";}

    num = fwrite(&Import16ImgB[1], 1, Import16ImgB[0], han);
    if (num != Import16ImgB[0]) {fclose(han); return "";}

    fclose(han);
    return Import16ImgName;
}

