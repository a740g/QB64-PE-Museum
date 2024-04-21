//----------------------------------------------------------------------------------------------------------------------
// OPL3 emulation for QB64-PE using Nuked OPL3
// Copyright (c) 2023 Samuel Gomes
//----------------------------------------------------------------------------------------------------------------------

#pragma once

#include "opl3.c"

static opl3_chip g_OPL3;

inline void __Adlib_Initialize(uint32_t sampleRate)
{
    OPL3_Reset(&g_OPL3, sampleRate);
}

inline void Adlib_WriteRegister(uint16_t reg, uint8_t v)
{
    OPL3_WriteRegBuffered(&g_OPL3, reg, v);
}

inline void __Adlib_GenerateSamples(uintptr_t buf, uint32_t frames)
{
    OPL3_GenerateStream(&g_OPL3, reinterpret_cast<int16_t *>(buf), frames);
}
