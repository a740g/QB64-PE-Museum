// ============================================================
// === This file was created with MakeCARR.bas by RhoSigma, ===
// === use it in conjunction with its respective .bm file.  ===
// ============================================================

// --- Array(s) representing the contents of file gtprefs.bin
// ---------------------------------------------------------------------
static const unsigned int32 PresetsL0[] = {
    152,
    0x69489E46,0x00024B02,0x14A45000,0x09054231,0x12242911,0x07433802,0x66329C8E,0x9310B8E6,
    0x90880DC6,0x1C924722,0x90E29149,0x80A84529,0x08F09008,0xC262379B,0xE43171B0,0x73394C4D,
    0x49EA2244,0x77500671,0x00895542,0x000AADD0,0x2212BB77,0xA9666002,0xAA664419,0xC33662EC,
    0x77001DCC,0xEA2A2176,0x2AAEE7AE,0x11DDDC55,0x11110DD1,0x44EEAA22,0x132553B8,0x00667F80,
    0x3595DB30,0x7A92D213,0xEBEDF2F7,0xC0E02FF7,0x2E130782,0x04A4386C,0x2C1A0C0B,0x80007020,
    0x220D0180,0xE0900818,0x2B94C9E4,0xC29C265B,0x32990D26,0x85F08672,0xE88E0612,0xE4C27223,
    0xCE06A171,0x67B2C399,0xFB6DAED3,0xBADCEE36,0xFDEBFE4B,0xCD6F612F,0x0C2A5D2C,0x69344673,
    0xB0CE55BE,0xB59AA3C9,0xA7BBD86B,0xFD6EAF53,0xBDD9763A,0x3957064F,0xE3E9A13C,0xA15C5DA3,
    0x194A06C9,0xB3D7D990,0x7DFEEF6F,0xE21384EE,0xB9CE16FA,0xE421F8B8,0x136927CD,0x3794C41B,
    0x6F3CCA6D,0xFC3FFAFD,0xB82A0980,0x6DB68320,0xC47D9987,0x1D075109,0x46E1BC74,0xB10D7A72,
    0x21D11C1A,0x218820D8,0x48A2388A,0x4FF7020F,0x218D9D84,0x206C4E07,0xA86997A7,0x87A051C9,
    0x2378DA24,0x4899D58E,0x50008A5F,0x741E0651,0x1057B864,0xC6D1D46C,0x591C6947,0x3A4D8E63,
    0x3B60E4F9,0x7119B776,0x865719FD,0x3184427E,0xA4661AC6,0x201B06C1,0x1C072794,0x25081E34,
    0x19AA699A,0xA26D6F92,0x4C7DDDE8,0x1D0731A4,0xC651A476,0xD48A431D,0x88721844,0x6B9322E1,
    0x8DA83A0A,0x6549BE52,0x31E44342,0x927A8B86,0x8169E1B4,0xA5293A12,0xE3DA1A0B,0xC1946810,
    0xE06F18A5,0x7C0828E1,0x10A2E9FA,0x86E1DE2C,0xBAAA95A4,0xC2976EAA,0x7414DC49,0x19D1F1C8,
    0xE45486A0,0x792E4991,0xFABDAB26,0x146FE0EA,0x001DF94D,0x8774E537,0xA1B065A6,0xBC6F6AA7,
    0x64194761,0xB52BFAA4,0x2AE606D5,0x78B10AA2,0xCC734646,0x60796A01,0x1D46F14A,0xAD31A067,
    0xCBAAE9B5,0xF6276FA6,0x64184528,0xAD86F1A4,0xE7315121,0x8194751C,0x5AFDBAEE,0x004263BB
};

static const unsigned int8 PresetsB[] = {
    18,
    0x01,0x00,0x51,0x42,0x36,0x34,0x4C,0x5A,0x57,0x31,0xB8,0x12,0x00,0x00,0x75,0xD0,
    0x30,0x05
};

// --- Saved full qualified output path and filename, so we've no troubles
// --- when cleaning up, even if the current working folder was changed
// --- during program runtime.
// ---------------------------------------------------------------------
char PresetsName[8192]; // it's a safe size for any current OS

// --- Cleanup function to delete the written file, called by the atexit()
// --- handler at program termination time, if requested by user.
// ---------------------------------------------------------------------
void KillPresetsData(void)
{
    remove(PresetsName);
}

// --- Function to write the array(s) back into a file, will return the
// --- full qualified output path and filename on success, otherwise an
// --- empty string is returned (access/write errors, file truncated).
// ---------------------------------------------------------------------
const char *WritePresetsData(const char *FileName, int16 AutoClean)
{
    FILE *han = NULL; // file handle
    int32 num = NULL; // written elements

    #ifdef QB64_WINDOWS
    if (!_fullpath(PresetsName, FileName, 8192)) return "";
    #else
    if (!realpath(FileName, PresetsName)) return "";
    #endif

    if (!(han = fopen(PresetsName, "wb"))) return "";
    if (AutoClean) atexit(KillPresetsData);

    num = fwrite(&PresetsL0[1], 4, PresetsL0[0], han);
    if (num != PresetsL0[0]) {fclose(han); return "";}

    num = fwrite(&PresetsB[1], 1, PresetsB[0], han);
    if (num != PresetsB[0]) {fclose(han); return "";}

    fclose(han);
    return PresetsName;
}

