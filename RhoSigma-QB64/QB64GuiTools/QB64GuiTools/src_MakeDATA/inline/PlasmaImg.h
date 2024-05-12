// ============================================================
// === This file was created with MakeCARR.bas by RhoSigma, ===
// === use it in conjunction with its respective .bm file.  ===
// ============================================================

// --- Array(s) representing the contents of file Plasma.jpg
// ---------------------------------------------------------------------
static const uint32_t PlasmaImgL0[] = {
    280,
    0xE0FFD8FF,0x464A1000,0x01004649,0x01000001,0x00000100,0x4300DBFF,0x02020300,0x03020203,
    0x04030303,0x05040303,0x04050508,0x070A0504,0x0C080607,0x0B0C0C0A,0x0D0B0B0A,0x0D10120E,
    0x0B0E110E,0x1016100B,0x15141311,0x0F0C1515,0x14161817,0x15141218,0x00DBFF14,0x04030143,
    0x05040504,0x09050509,0x0D0B0D14,0x14141414,0x14141414,0x14141414,0x14141414,0x14141414,
    0x14141414,0x14141414,0x14141414,0x14141414,0x14141414,0x14141414,0x14141414,0xC0FF1414,
    0x00081100,0x03600060,0x02002201,0x11030111,0x00C4FF01,0x03000019,0x00010101,0x00000000,
    0x00000000,0x05040000,0x07000306,0x2A00C4FF,0x03010010,0x03010204,0x00030204,0x00000000,
    0x02000300,0x12050104,0x23221413,0x15423206,0x11333121,0x62412452,0x1A00C4FF,0x01030001,
    0x00010101,0x00000000,0x00000000,0x04030000,0x06010205,0x1B00C4FF,0x01010111,0x01030001,
    0x00000000,0x00000000,0x12020000,0x32220403,0x00DAFF42,0x0001030C,0x11031102,0xF0003F00,
    0x335B90B7,0x86CBF753,0x598CE5DF,0x7D5D90C6,0xC2906FD0,0x95F6051F,0x8DFECB69,0xE4D0BBB3,
    0x5591B3B7,0x347E1851,0x918B2339,0xB802BC54,0xAB6CB1D6,0x66C348D3,0x7E88A4C5,0xC478883E,
    0x8F1E4CD4,0x1111A080,0x705DCF94,0x1911E34B,0xA2CF8C49,0xAAC501A6,0xB13A4441,0x1F1349EB,
    0x790CA2AF,0x9C167D94,0x4FF3F177,0xFA219F29,0x33E9ACFB,0x32579AF3,0x4A74F1E0,0xBC2E70CF,
    0x93661517,0xC8C1E8D2,0x1C8D30C1,0x7C6A2645,0xC800FF91,0x2EC32D4F,0x8A030CB5,0x6162EC61,
    0x79B0CF1A,0x7DEF76A5,0xBF316455,0x4F80AE8E,0xA98E3F22,0xFB6CAD78,0xD2C5E999,0xC1F5F83B,
    0x51E0924B,0x08EC52F8,0x0C1E4F98,0x97A35B5A,0x1CBE745F,0x9CEE64CD,0x093E4352,0xD72D0C50,
    0xE8C1440D,0x9D0D77C9,0x7EBC9318,0x8890D63C,0xA7BA13C1,0xE4303D60,0xE8BE3457,0x98E86C41,
    0xBF22085C,0xB7705FA2,0xD8AB83BC,0xB7C44197,0xC35491B3,0xD1D76FE9,0xA51D7D52,0xBD1D8CEE,
    0xBC843832,0xC8D35B3B,0x4CC7CB71,0xD5F16B09,0x8E425AEC,0xA6B90EF1,0x249F1444,0xE9C1648D,
    0xB738D21D,0x112EAAE6,0x3735B3C5,0x8400FF7B,0xF88C34BB,0x1932AA6C,0x12EEA718,0xD262EC1F,
    0xEE47D11E,0x3E52D8A2,0x3198CDF0,0xFA788274,0x1953B829,0x739EEEC8,0x33E59F03,0xFD899861,
    0x82CF1CD1,0x8E2482ED,0x18BAA589,0x6CBA238B,0xE3C7E005,0xF53B225D,0x8D185DF4,0x310FADFB,
    0x53A4059F,0x7D8C7938,0x00FFF2D0,0x105A705D,0x87E03A9E,0xE035AFEF,0xBE9E9923,0xFB5F6EEA,
    0xDCB938CD,0xE94E0A3E,0xC5EABA20,0x0ECDD69B,0x9AD9EC48,0x83CF640E,0x5D869116,0x272FCD75,
    0x960151EF,0xA3377FE8,0x2EE40C39,0x59EB3784,0xA0E90D93,0x1431DCF2,0x708BAA99,0x382952C4,
    0xB8AEDFD1,0x8D140B2A,0xA81EAB64,0x249314E2,0x4B0C5E3F,0xCD6314F6,0x0D5778E8,0xB9B3EE44,
    0xA7A23FDC,0xA09E3A65,0x7AAC12E3,0x86EAE10E,0xEFA4187B,0xC2911E73,0xDD916BBC,0xE4477E45,
    0x70052DCC,0x34572461,0x0951C33D,0x5D3A125C,0x4E744204,0x63F21D07,0xE9ED8DE6,0xE099217F,
    0x45AC1D8C,0x3F3E6826,0x1D853891,0x0195EAFA,0x187CE399,0xE7E98F88,0x90D1BB93,0x4415F9A3,
    0x538D7F2B,0xF113B61C,0x53FEEAE1,0x9FAD558B,0x9649EBB9,0x97E8EBF7,0x0EA3618A,0x14FC54A1,
    0xCE6663E9,0x78C25C89,0x0F0917D1,0x3C89B1FB,0x5C8697B1,0xA366D7D4,0x677441FD,0x79290623,
    0x4FF01F12,0xCA9C8D27,0xD92083E6,0xEE5559C8,0x439A9DED,0x713557F6,0x587EBA6A,0x7231C4A4,
    0x432DAA06,0x9C892117,0x0E6B1C5C,0xFC51E0C4,0x71FC107D,0x4B48D37B,0x1D3A2046,0x1082EABD,
    0x8A43C7DF,0xB1F9C83E,0x108F0811,0xA760ABFB,0xAC923573,0x705C0E7A,0x63F42AF2,0x07CD6CF5
};

static const uint8_t PlasmaImgB[] = {
    7,
    0x3F,0x0F,0xBE,0x08,0xB0,0xFF,0xD9
};

// --- Function to copy the array(s) into the provided string buffer.
// --- Buffer size is not checked, as MakeCARR makes sure it's sufficient.
// ---------------------------------------------------------------------
void ReadPlasmaImgData(char *Buffer)
{
    memcpy(Buffer, &PlasmaImgL0[1], PlasmaImgL0[0] << 2);
    Buffer += (PlasmaImgL0[0] << 2);

    memcpy(Buffer, &PlasmaImgB[1], PlasmaImgB[0]);
}

// --- Saved full qualified output path and filename, so we've no troubles
// --- when cleaning up, even if the current working folder was changed
// --- during program runtime.
// ---------------------------------------------------------------------
char PlasmaImgName[8192]; // it's a safe size for any current OS

// --- Cleanup function to delete the written file, called by the atexit()
// --- handler at program termination time, if requested by user.
// ---------------------------------------------------------------------
void KillPlasmaImgData(void)
{
    remove(PlasmaImgName);
}

// --- Function to write the array(s) back into a file, will return the
// --- full qualified output path and filename on success, otherwise an
// --- empty string is returned (access/write errors, file truncated).
// ---------------------------------------------------------------------
const char *WritePlasmaImgData(const char *FileName, int16_t AutoClean)
{
    FILE   *han = NULL; // file handle
    int32_t num = NULL; // written elements

    #ifdef QB64_WINDOWS
    if (!_fullpath(PlasmaImgName, FileName, 8192)) return "";
    #else
    if (!realpath(FileName, PlasmaImgName)) return "";
    #endif

    if (!(han = fopen(PlasmaImgName, "wb"))) return "";
    if (AutoClean) atexit(KillPlasmaImgData);

    num = fwrite(&PlasmaImgL0[1], 4, PlasmaImgL0[0], han);
    if (num != PlasmaImgL0[0]) {fclose(han); return "";}

    num = fwrite(&PlasmaImgB[1], 1, PlasmaImgB[0], han);
    if (num != PlasmaImgB[0]) {fclose(han); return "";}

    fclose(han);
    return PlasmaImgName;
}

