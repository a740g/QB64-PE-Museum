//----------------------------------------------------------------------------------------------------------------------
// OPL3 emulation for QB64-PE using Opal
// Copyright (c) 2024 Samuel Gomes
//----------------------------------------------------------------------------------------------------------------------

#pragma once

#include "opal.h"

static Opal *g_OPL3 = nullptr;

inline void __Adlib_Initialize(uint32_t sampleRate)
{
    if (sampleRate == 0)
        return;

    delete g_OPL3;
    g_OPL3 = new Opal(sampleRate);
    g_OPL3->Port(0x105, 1);
}

inline void Adlib_WriteRegister(uint16_t reg, uint8_t v)
{
    if (g_OPL3)
        g_OPL3->Port(reg, v);
}

inline void __Adlib_GenerateSamples(uintptr_t buf, uint32_t frames)
{
    if (!g_OPL3 || !buf || frames == 0)
        return;

    auto output = reinterpret_cast<int16_t *>(buf);

    for (size_t i = 0; i < frames; i++)
    {
        g_OPL3->Sample(output, output + 1);
        output += 2;
    }
}
