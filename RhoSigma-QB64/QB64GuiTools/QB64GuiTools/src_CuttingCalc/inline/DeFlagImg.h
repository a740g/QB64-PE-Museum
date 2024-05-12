// ============================================================
// === This file was created with MakeCARR.bas by RhoSigma, ===
// === use it in conjunction with its respective .bm file.  ===
// ============================================================

// --- Array(s) representing the contents of file de20px.gif
// ---------------------------------------------------------------------
static const uint32_t DeFlagImgL0[] = {
    160,
    0x38464947,0x00206139,0x00E60014,0x00000000,0xFFFFFFFF,0xF2F200FF,0x00EEEE00,0xE200ECEC,
    0xD7D700E2,0x00D2D200,0xC800D1D1,0xB6B600C8,0x00B5B500,0xA700AFAF,0xA5A500A7,0x00A2A200,
    0x97009898,0x8C8C0097,0x00818100,0x7B007F7F,0x7A7A007B,0x006E6E00,0x62006B6B,0x61610062,
    0x00606000,0x4C005050,0x4545004C,0x00414100,0xFF02FFFF,0xFFFF0CFF,0x1EFFFF0F,0xFF27FFFF,
    0xFFFF29FF,0x3CFFFF35,0xEE0000FF,0x00C80000,0x0000A200,0xFF00007F,0x27FF0F0F,0x3535FF27,
    0xA43C3CFF,0xA3A3A4A4,0x9F9F9FA3,0x999C9C9C,0x98989999,0x97979798,0x8E959595,0x8B8B8E8E,
    0x8686868B,0x82858585,0x77778282,0x76767677,0x6F737373,0x6C6C6F6F,0x6B6B6B6C,0x61696969,
    0x5D5D6161,0x5B5B5B5D,0x575A5A5A,0x4C4C5757,0x4A4A4A4C,0x40494949,0x3D3D4040,0x3C3C3C3D,
    0x393A3A3A,0x37373939,0x35353537,0x2A303030,0x27272A2A,0x1B1B1B27,0x12141414,0x10101212,
    0x0F0F0F10,0x0A0D0D0D,0xFFFF0A0A,0x000000FF,0x00000000,0x00000000,0x00000000,0x00000000,
    0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,
    0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,
    0x00000000,0x00000000,0x00000000,0x04F92100,0x5F000001,0x00002C00,0x00200000,0x07000014,
    0x333680F9,0x3A393432,0x8A898887,0x413C3A8B,0x3B5D5249,0x3B383537,0x9A99983E,0x403E9C9B,
    0x005D5348,0x3C3B3D3F,0xAAA9433F,0x43ADACAB,0x005B5147,0x42444600,0xBA4C4A45,0xBEBDBCBB,
    0xB35A524C,0x4C4B4D00,0xCA58564E,0xCECDCCCB,0x00C35E58,0x5754504F,0xDAD9D25C,0xD6D4D9DB,
    0xE1E1DCD8,0x2F30314F,0xEAE9292E,0x29EDECEB,0x2D2C2B2A,0xEEE7E5D3,0xF2F0EEF7,0xF8E8E6F4,
    0xCDF4E9FF,0x200FD723,0xECFC8140,0x9087C419,0xF985C2A0,0x71440DE2,0x0108C4A2,0xDC6A3318,
    0x010051C8,0x4C2A1005,0xA3B168A3,0x431F8EC9,0x8262A802,0x06018884,0x499CCA62,0x0481A6B3,
    0x0060260D,0x01442590,0x081E0C04,0xA8B44A1D,0x2C1107D1,0xEB30E868,0x170902C0,0x4A9D4832
};

static const uint8_t DeFlagImgB[] = {
    28,
    0xB5,0xAA,0xD5,0x0C,0x1B,0x3C,0x80,0x00,0x31,0xCB,0x01,0x05,0x0E,0x1F,0xB6,0x8A,
    0x1D,0x4B,0xB6,0x6C,0x59,0x71,0x68,0xD3,0x06,0x02,0x00,0x3B
};

// --- Function to copy the array(s) into the provided string buffer.
// --- Buffer size is not checked, as MakeCARR makes sure it's sufficient.
// ---------------------------------------------------------------------
void ReadDeFlagImgData(char *Buffer)
{
    memcpy(Buffer, &DeFlagImgL0[1], DeFlagImgL0[0] << 2);
    Buffer += (DeFlagImgL0[0] << 2);

    memcpy(Buffer, &DeFlagImgB[1], DeFlagImgB[0]);
}

// --- Saved full qualified output path and filename, so we've no troubles
// --- when cleaning up, even if the current working folder was changed
// --- during program runtime.
// ---------------------------------------------------------------------
char DeFlagImgName[8192]; // it's a safe size for any current OS

// --- Cleanup function to delete the written file, called by the atexit()
// --- handler at program termination time, if requested by user.
// ---------------------------------------------------------------------
void KillDeFlagImgData(void)
{
    remove(DeFlagImgName);
}

// --- Function to write the array(s) back into a file, will return the
// --- full qualified output path and filename on success, otherwise an
// --- empty string is returned (access/write errors, file truncated).
// ---------------------------------------------------------------------
const char *WriteDeFlagImgData(const char *FileName, int16_t AutoClean)
{
    FILE   *han = NULL; // file handle
    int32_t num = NULL; // written elements

    #ifdef QB64_WINDOWS
    if (!_fullpath(DeFlagImgName, FileName, 8192)) return "";
    #else
    if (!realpath(FileName, DeFlagImgName)) return "";
    #endif

    if (!(han = fopen(DeFlagImgName, "wb"))) return "";
    if (AutoClean) atexit(KillDeFlagImgData);

    num = fwrite(&DeFlagImgL0[1], 4, DeFlagImgL0[0], han);
    if (num != DeFlagImgL0[0]) {fclose(han); return "";}

    num = fwrite(&DeFlagImgB[1], 1, DeFlagImgB[0], han);
    if (num != DeFlagImgB[0]) {fclose(han); return "";}

    fclose(han);
    return DeFlagImgName;
}

