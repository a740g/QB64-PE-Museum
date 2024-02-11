' MIDI PLAYER
' Original GW-BASIC version by bisqwit (http://iki.fi/bisqwit/)
' Ported to VB-DOS by PeterSwinkels
' Ported to QB64-PE by a740g

_DEFINE A-Z AS LONG
OPTION _EXPLICIT
OPTION BASE 1
'$STATIC

'$INCLUDE:'include/adlib.bi'

CONST ADLIB_VOLUME_RANGE = &H3F
CONST DEFAULT_PITCH_BEND# = .000244140625#
CONST DEFAULT_TEMPO = 1000000
CONST DOUBLE_LINEAR_AMPLITUDE = &H8
CONST ET_SEMITONES_PER_OCTAVE# = 12#
CONST EVENT_BUFFER_SIZE = 2
CONST EVENT_TICK_FREQUENCY = 16320
CONST GP_01 = 93
CONST MAXIMUM_SIGNED_B_END = &H2000
CONST MAXIMUM_VOLUME = &H3F01
CONST MC_ALL_NOTES_OFF = &H7B
CONST MC_BEND = &H6
CONST MC_MODULATION = &H1
CONST MC_PAN = &HA
CONST MC_RESET_ALL_CONTROLLERS = &H79
CONST MC_VOLUME = &H7
CONST ME_BEND = &HE0
CONST ME_CHANNEL_MASK = &HF
CONST ME_CONTROLLER = &HB0
CONST ME_FIRST = &H80
CONST ME_INSTRUMENT = &HC0
CONST ME_MASK = &HF0
CONST ME_META = &HFF
CONST ME_NOTE_OFF = &H80
CONST ME_NOTE_ON = &H90
CONST ME_POLYPHONIC = &HA0
CONST ME_PRESSURE = &HD0
CONST ME_SONGPOSITION = &HF2
CONST ME_SONGSELECT = &HF3
CONST ME_SYSEX_END = &HF7
CONST ME_SYSEX_START = &HF0
CONST MME_END_OF_TRACK = &H2F
CONST MME_SET_TEMPO = &H51
CONST MMET_COPYRIGHT = &H2
CONST MMET_CUE = &H7
CONST MMET_GENERIC = &H1
CONST MMET_INSTRUMENT = &H4
CONST MMET_LYRIC = &H5
CONST MMET_MARKER = &H6
CONST MMET_TRACK = &H3
CONST MOP_OFF = 1
CONST MOP_PAN = 2
CONST MOP_PITCH = 3
CONST MOP_PRESSURE = 4
CONST MOP_VOLUME = 5
CONST MTHD_BLOCK_DEFAULT_LENGTH = &H6
CONST NO_CHANNEL = -1
CONST OPL_01_WAVE_ON = &H20
CONST OPL_04_IRQ_RESET = &H80
CONST OPL_04_MOD_E0 = &H0
CONST OPL_04_TIMERS_12_ON = &H60
CONST OPL_05_OPL3_OFF = &H0
CONST OPL_05_OPL3_ON = &H1
CONST OPL_ATTENUATION_MASK = &H3F
CONST OPL_BASE = &H388
CONST OPL_B0_FREQUENCY_MASK = &H3
CONST OPL_B0_BLOCK_MASK = &H1C
CONST OPL_B0_NOTE_ON = &H20
CONST OPL_BD_MEDOLIC_MODE = &H0
CONST OPL_C0_RIGHT_SPEAKER_ENABLE = &H20
CONST OPL_C0_LEFT_SPEAKER_ENABLE = &H10
CONST OPL_DATA1 = OPL_BASE + &H1
CONST OPL_DATA2 = OPL_BASE + &H3
CONST OPL_INDEX1 = OPL_BASE + &H0
CONST OPL_INDEX2 = OPL_BASE + &H2
CONST OPL_MAXIMUM_ATTENUATION = &H3F
CONST OPL_MAXIMUM_VOLUME = &H3F
CONST AMIGA_SAMPLE_RATE# = 8363#
CONST PC_SAMPLE_RATE# = 44100#
CONST AMIGA_PC_SAMPLING_RATIO# = AMIGA_SAMPLE_RATE / PC_SAMPLE_RATE
CONST PERCUSSION_ONLY = &H9
CONST PERCUSSIVE_NOTES = &H6
CONST SCREAM_TRACKER_3_NOTE_B# = 907#
CONST SIGN_14BIT = &H2000

TYPE ActiveNoteStr
    AdlibChannel AS INTEGER
    Index AS INTEGER
    Note AS INTEGER
    Volume AS INTEGER
END TYPE

TYPE ChannelStr
    ActiveIndex AS INTEGER
    Age AS LONG
    ColorV AS INTEGER
    MIDIChannel AS INTEGER
    IsOn AS INTEGER
    x AS INTEGER
    XCharacter AS INTEGER
    XColor AS INTEGER
END TYPE

TYPE ChannelInstrumentStr
    Instrument AS INTEGER
    Panning AS INTEGER
    Pitch AS INTEGER
END TYPE

TYPE ChannelSettingsStr
    Bend AS DOUBLE
    Panning AS INTEGER
    Patch AS INTEGER
    Vibrato AS INTEGER
    Volume AS INTEGER
END TYPE

TYPE MIDIStr
    BendSense AS DOUBLE
    FileH AS INTEGER
    Format AS INTEGER
    InvertedDeltaTicks AS DOUBLE
    Tempo AS DOUBLE
    TrackCount AS LONG
END TYPE

TYPE OPLStr
    DataV AS INTEGER
    Index AS INTEGER
    Operator AS INTEGER
    SubChannel AS INTEGER
END TYPE

TYPE StatusStr
    Began AS INTEGER
    LoopEnd AS INTEGER
    LoopStart AS INTEGER
    LoopWait AS LONG
    PlayWait AS LONG
    TextRow AS INTEGER
    timerHandle AS LONG
END TYPE

TYPE TrackStr
    Delay AS LONG
    Pointer AS LONG
    Status AS INTEGER
END TYPE

DIM MIDI AS MIDIStr
DIM Status AS StatusStr

DIM SHARED ActiveNoteCount(0 TO 15) AS INTEGER
DIM SHARED ActiveNoteList(0 TO 15, 0 TO 99) AS INTEGER
DIM SHARED ActiveNotes(0 TO 15, 0 TO 127) AS ActiveNoteStr
DIM SHARED Channels(0 TO 17) AS ChannelStr
DIM SHARED ChannelInstruments(0 TO 17) AS ChannelInstrumentStr
DIM SHARED ChannelSettings(0 TO 15) AS ChannelSettingsStr
DIM SHARED Instruments(0 TO 180, 0 TO 6) AS INTEGER
REDIM SHARED Loops(0 TO 0) AS TrackStr
REDIM SHARED LoopsBackup(0 TO 0) AS TrackStr
REDIM SHARED Tracks(0 TO 0) AS TrackStr

Initialize Status
Main MIDI, Status
Quit MIDI, Status
END

'The data words are:
'[0] Amplitude Modulator/Vibrato/Envelope Generator/Key Scaling Rate/Etc.
'[1] Key Scaling Level/Attenuation settings
'[2] Attack and decay rates
'[3] Sustain and release rates
'[4] Wave select settings
'[5] Feedback/connection bits
'[6] Percussive instrument (GP35..GP87) notes.

InstrumentData:
DATA &H101,&H68F,&HF2F2,&HF7F4,&H0,&H38,&H0: 'GM1:AcouGrandPiano
DATA &H101,&H4B,&HF2F2,&HF7F4,&H0,&H38,&H0: 'GM2:BrightAcouGrand
DATA &H101,&H49,&HF2F2,&HF6F4,&H0,&H38,&H0: 'GM3:ElecGrandPiano
DATA &H4181,&H12,&HF2F2,&HF7F7,&H0,&H36,&H0: 'GM4:Honky-tonkPiano
DATA &H101,&H57,&HF2F1,&HF7F7,&H0,&H30,&H0: 'GM5:Rhodes Piano
DATA &H101,&H93,&HF2F1,&HF7F7,&H0,&H30,&H0: 'GM6:Chorused Piano
DATA &H1601,&HE80,&HF2A1,&HF5F2,&H0,&H38,&H0: 'GM7:Harpsichord
DATA &H101,&H92,&HC2C2,&HF8F8,&H0,&H3A,&H0: 'GM8:Clavinet
DATA &H810C,&H5C,&HF3F6,&HF5F4,&H0,&H30,&H0: 'GM9:Celesta
DATA &H1107,&H8097,&HF2F3,&HF1F2,&H0,&H32,&H0: 'GM10:Glockenspiel
DATA &H117,&H21,&HF454,&HF4F4,&H0,&H32,&H0: 'GM11:Music box
DATA &H8198,&H62,&HF2F3,&HF6F6,&H0,&H30,&H0: 'GM12:Vibraphone
DATA &H118,&H23,&HE7F6,&HF7F6,&H0,&H30,&H0: 'GM13:Marimba
DATA &H115,&H91,&HF6F6,&HF6F6,&H0,&H34,&H0: 'GM14:Xylophone
DATA &H8145,&H8059,&HA3D3,&HF3F3,&H0,&H3C,&H0: 'GM15:Tubular Bells
DATA &H8103,&H8049,&HB575,&HF5F5,&H1,&H34,&H0: 'GM16:Dulcimer
DATA &H3171,&H92,&HF1F6,&H714,&H0,&H32,&H0: 'GM17:Hammond Organ
DATA &H3072,&H14,&HC7C7,&H858,&H0,&H32,&H0: 'GM18:Percussive Organ
DATA &HB170,&H44,&H8AAA,&H818,&H0,&H34,&H0: 'GM19:Rock Organ
DATA &HB123,&H93,&H5597,&H1423,&H1,&H34,&H0: 'GM20:Church Organ
DATA &HB161,&H8013,&H5597,&H404,&H1,&H30,&H0: 'GM21:Reed Organ
DATA &HB124,&H48,&H4698,&H1A2A,&H1,&H3C,&H0: 'GM22:Accordion
DATA &H2161,&H13,&H6191,&H706,&H1,&H3A,&H0: 'GM23:Harmonica
DATA &HA121,&H8913,&H6171,&H706,&H0,&H36,&H0: 'GM24:Tango Accordion
DATA &H4102,&H809C,&HF3F3,&HC894,&H1,&H3C,&H0: 'GM25:Acoustic Guitar1
DATA &H1103,&H54,&HF1F3,&HE79A,&H1,&H3C,&H0: 'GM26:Acoustic Guitar2
DATA &H2123,&H5F,&HF2F1,&HF83A,&H0,&H30,&H0: 'GM27:Electric Guitar1
DATA &H2103,&H8087,&HF3F6,&HF822,&H1,&H36,&H0: 'GM28:Electric Guitar2
DATA &H2103,&H47,&HF6F9,&H3A54,&H0,&H30,&H0: 'GM29:Electric Guitar3
DATA &H2123,&H54A,&H8491,&H1941,&H1,&H38,&H0: 'GM30:Overdrive Guitar
DATA &H2123,&H4A,&H9495,&H1919,&H1,&H38,&H0: 'GM31:Distorton Guitar
DATA &H8409,&H80A1,&HD120,&HF84F,&H0,&H38,&H0: 'GM32:Guitar Harmonics
DATA &HA221,&H1E,&HC394,&HA606,&H0,&H32,&H0: 'GM33:Acoustic Bass
DATA &H3131,&H12,&HF1F1,&H1828,&H0,&H3A,&H0: 'GM34:Electric Bass 1
DATA &H3131,&H8D,&HF1F1,&H78E8,&H0,&H3A,&H0: 'GM35:Electric Bass 2
DATA &H3231,&H5B,&H7151,&H4828,&H0,&H3C,&H0: 'GM36:Fretless Bass
DATA &H2101,&H408B,&HF2A1,&HDF9A,&H0,&H38,&H0: 'GM37:Slap Bass 1
DATA &H2121,&H88B,&HA1A2,&HDF16,&H0,&H38,&H0: 'GM38:Slap Bass 2
DATA &H3131,&H8B,&HF1F4,&H78E8,&H0,&H3A,&H0: 'GM39:Synth Bass 1
DATA &H3131,&H12,&HF1F1,&H1828,&H0,&H3A,&H0: 'GM40:Synth Bass 2
DATA &H2131,&H15,&H56DD,&H2613,&H1,&H38,&H0: 'GM41:Violin
DATA &H2131,&H16,&H66DD,&H613,&H1,&H38,&H0: 'GM42:Viola
DATA &H3171,&H49,&H61D1,&HC1C,&H1,&H38,&H0: 'GM43:Cello
DATA &H2321,&H804D,&H7271,&H612,&H1,&H32,&H0: 'GM44:Contrabass
DATA &HE1F1,&H40,&H6FF1,&H1621,&H1,&H32,&H0: 'GM45:Tremulo Strings
DATA &H102,&H801A,&H85F5,&H3575,&H1,&H30,&H0: 'GM46:Pizzicato String
DATA &H102,&H801D,&HF3F5,&HF475,&H1,&H30,&H0: 'GM47:Orchestral Harp
DATA &H1110,&H41,&HF2F5,&HC305,&H1,&H32,&H0: 'GM48:Timpany
DATA &HA221,&H19B,&H72B1,&H825,&H1,&H3E,&H0: 'GM49:String Ensemble1
DATA &H21A1,&H98,&H3F7F,&H703,&H101,&H30,&H0: 'GM50:String Ensemble2
DATA &H61A1,&H93,&H4FC1,&H512,&H0,&H3A,&H0: 'GM51:Synth Strings 1
DATA &H6121,&H18,&H4FC1,&H522,&H0,&H3C,&H0: 'GM52:SynthStrings 2
DATA &H7231,&H835B,&H8AF4,&H515,&H0,&H30,&H0: 'GM53:Choir Aahs
DATA &H61A1,&H90,&H7174,&H6739,&H0,&H30,&H0: 'GM54:Voice Oohs
DATA &H7271,&H57,&H7A54,&H505,&H0,&H3C,&H0: 'GM55:Synth Voice
DATA &H4190,&H0,&HA554,&H4563,&H0,&H38,&H0: 'GM56:Orchestra Hit
DATA &H2121,&H192,&H8F85,&H917,&H0,&H3C,&H0: 'GM57:Trumpet
DATA &H2121,&H594,&H8F75,&H917,&H0,&H3C,&H0: 'GM58:Trombone
DATA &H6121,&H94,&H8276,&H3715,&H0,&H3C,&H0: 'GM59:Tuba
DATA &H2131,&H43,&H629E,&H2C17,&H101,&H32,&H0: 'GM60:Muted Trumpet
DATA &H2121,&H9B,&H7F61,&HA6A,&H0,&H32,&H0: 'GM61:French Horn
DATA &H2261,&H68A,&H7475,&HF1F,&H0,&H38,&H0: 'GM62:Brass Section
DATA &H21A1,&H8386,&H7172,&H1855,&H1,&H30,&H0: 'GM63:Synth Brass 1
DATA &H2121,&H4D,&HA654,&H1C3C,&H0,&H38,&H0: 'GM64:Synth Brass 2
DATA &H6131,&H8F,&H7293,&HB02,&H1,&H38,&H0: 'GM65:Soprano Sax
DATA &H6131,&H8E,&H7293,&H903,&H1,&H38,&H0: 'GM66:Alto Sax
DATA &H6131,&H91,&H8293,&H903,&H1,&H3A,&H0: 'GM67:Tenor Sax
DATA &H6131,&H8E,&H7293,&HF0F,&H1,&H3A,&H0: 'GM68:Baritone Sax
DATA &H2121,&H4B,&H8FAA,&HA16,&H1,&H38,&H0: 'GM69:Oboe
DATA &H2131,&H90,&H8B7E,&HC17,&H101,&H36,&H0: 'GM70:English Horn
DATA &H3231,&H81,&H6175,&H1919,&H1,&H30,&H0: 'GM71:Bassoon
DATA &H2132,&H90,&H729B,&H1721,&H0,&H34,&H0: 'GM72:Clarinet
DATA &HE1E1,&H1F,&H6585,&H1A5F,&H0,&H30,&H0: 'GM73:Piccolo
DATA &HE1E1,&H46,&H6588,&H1A5F,&H0,&H30,&H0: 'GM74:Flute
DATA &H21A1,&H9C,&H7575,&HA1F,&H0,&H32,&H0: 'GM75:Recorder
DATA &H2131,&H8B,&H6584,&H1A58,&H0,&H30,&H0: 'GM76:Pan Flute
DATA &HA1E1,&H4C,&H6566,&H2656,&H0,&H30,&H0: 'GM77:Bottle Blow
DATA &HA162,&HCB,&H5576,&H3646,&H0,&H30,&H0: 'GM78:Shakuhachi
DATA &HA162,&H99,&H5657,&H707,&H0,&H3B,&H0: 'GM79:Whistle
DATA &HA162,&H93,&H7677,&H707,&H0,&H3B,&H0: 'GM80:Ocarina
DATA &H2122,&H59,&HFFFF,&HF03,&H2,&H30,&H0: 'GM81:Lead 1 squareea
DATA &H2121,&HE,&HFFFF,&HF0F,&H101,&H30,&H0: 'GM82:Lead 2 sawtooth
DATA &H2122,&H8046,&H6486,&H1855,&H0,&H30,&H0: 'GM83:Lead 3 calliope
DATA &HA121,&H45,&H9666,&HA12,&H0,&H30,&H0: 'GM84:Lead 4 chiff
DATA &H2221,&H8B,&H9192,&H2A2A,&H1,&H30,&H0: 'GM85:Lead 5 charang
DATA &H61A2,&H409E,&H6FDF,&H705,&H0,&H32,&H0: 'GM86:Lead 6 voice
DATA &H6020,&H1A,&H8FEF,&H601,&H200,&H30,&H0: 'GM87:Lead 7 fifths
DATA &H2121,&H808F,&HF4F1,&H929,&H0,&H3A,&H0: 'GM88:Lead 8 brass
DATA &HA177,&HA5,&HA053,&H594,&H0,&H32,&H0: 'GM89:Pad 1 new age
DATA &HB161,&H801F,&H25A8,&H311,&H0,&H3A,&H0: 'GM90:Pad 2 warm
DATA &H6161,&H17,&H5591,&H1634,&H0,&H3C,&H0: 'GM91:Pad 3 polysynth
DATA &H7271,&H5D,&H6A54,&H301,&H0,&H30,&H0: 'GM92:Pad 4 choir
DATA &HA221,&H97,&H4221,&H3543,&H0,&H38,&H0: 'GM93:Pad 5 bowedpad
DATA &H21A1,&H1C,&H31A1,&H4777,&H101,&H30,&H0: 'GM94:Pad 6 metallic
DATA &H6121,&H389,&H4211,&H2533,&H0,&H3A,&H0: 'GM95:Pad 7 halo
DATA &H21A1,&H15,&HCF11,&H747,&H1,&H30,&H0: 'GM96:Pad 8 sweep
DATA &H513A,&HCE,&H86F8,&H2F6,&H0,&H32,&H0: 'GM97:FX 1 rain
DATA &H2121,&H15,&H4121,&H1323,&H1,&H30,&H0: 'GM98:FX 2 soundtrack
DATA &H106,&H5B,&HA574,&H7295,&H0,&H30,&H0: 'GM99:FX 3 crystal
DATA &H6122,&H8392,&HF2B1,&H2681,&H0,&H3C,&H0: 'GM100:FX 4 atmosphere
DATA &H4241,&H4D,&HF2F1,&HF551,&H1,&H30,&H0: 'GM101:FX 5 brightness
DATA &HA361,&H8094,&H1111,&H1351,&H1,&H36,&H0: 'GM102:FX 6 goblins
DATA &HA161,&H808C,&H1D11,&H331,&H0,&H36,&H0: 'GM103:FX 7 echoes
DATA &H61A4,&H4C,&H81F3,&H2373,&H1,&H34,&H0: 'GM104:FX 8 sci-fi
DATA &H702,&H385,&HF2D2,&HF653,&H100,&H30,&H0: 'GM105:Sitar
DATA &H1311,&H800C,&HA2A3,&HE511,&H1,&H30,&H0: 'GM106:Banjo
DATA &H1111,&H6,&HF2F6,&HE641,&H201,&H34,&H0: 'GM107:Shamisen
DATA &H9193,&H91,&HEBD4,&H1132,&H100,&H38,&H0: 'GM108:Koto
DATA &H104,&H4F,&HC2FA,&H556,&H0,&H3C,&H0: 'GM109:Kalimba
DATA &H2221,&H49,&H6F7C,&HC20,&H100,&H36,&H0: 'GM110:Bagpipe
DATA &H2131,&H85,&H56DD,&H1633,&H1,&H3A,&H0: 'GM111:Fiddle
DATA &H2120,&H8104,&H8FDA,&HB05,&H2,&H36,&H0: 'GM112:Shanai
DATA &H305,&H806A,&HC3F1,&HE5E5,&H0,&H36,&H0: 'GM113:Tinkle Bell
DATA &H207,&H15,&HF8EC,&H1626,&H0,&H3A,&H0: 'GM114:Agogo Bells
DATA &H105,&H9D,&HDF67,&H535,&H0,&H38,&H0: 'GM115:Steel Drums
DATA &H1218,&H96,&HF8FA,&HE528,&H0,&H3A,&H0: 'GM116:Woodblock
DATA &H10,&H386,&HFAA8,&H307,&H0,&H36,&H0: 'GM117:Taiko Drum
DATA &H1011,&H341,&HF3F8,&H347,&H2,&H34,&H0: 'GM118:Melodic Tom
DATA &H1001,&H8E,&HF3F1,&H206,&H2,&H3E,&H0: 'GM119:Synth Drum
DATA &HC00E,&H0,&H1F1F,&HFF00,&H300,&H3E,&H0: 'GM120:Reverse Cymbal
DATA &H306,&H8880,&H56F8,&H8424,&H200,&H3E,&H0: 'GM121:Guitar FretNoise
DATA &HD00E,&H500,&H34F8,&H400,&H300,&H3E,&H0: 'GM122:Breath Noise
DATA &HC00E,&H0,&H1FF6,&H200,&H300,&H3E,&H0: 'GM123:Seashore
DATA &HDAD5,&H4095,&H5637,&H37A3,&H0,&H30,&H0: 'GM124:Bird Tweet
DATA &H1435,&H85C,&HF4B2,&H1561,&H2,&H3A,&H0: 'GM125:Telephone
DATA &HD00E,&H0,&H4FF6,&HF500,&H300,&H3E,&H0: 'GM126:Helicopter
DATA &HE426,&H0,&H12FF,&H1601,&H100,&H3E,&H0: 'GM127:Applause/Noise
DATA &H0,&H0,&HF6F3,&HC9F0,&H200,&H3E,&H0: 'GM128:Gunshot
DATA &H1110,&H44,&HF3F8,&H677,&H2,&H38,&H23: 'GP35:Ac Bass Drum
DATA &H1110,&H44,&HF3F8,&H677,&H2,&H38,&H23: 'GP36:Bass Drum 1
DATA &H1102,&H7,&HF8F9,&HFFFF,&H0,&H38,&H34: 'GP37:Side Stick
DATA &H0,&H0,&HFAFC,&H1705,&H2,&H3E,&H30: 'GP38:Acoustic Snare
DATA &H100,&H2,&HFFFF,&H807,&H0,&H30,&H3A: 'GP39:Hand Clap
DATA &H0,&H0,&HFAFC,&H1705,&H2,&H3E,&H3C: 'GP40:Electric Snare
DATA &H0,&H0,&HF6F6,&H60C,&H0,&H34,&H2F: 'GP41:Low Floor Tom
DATA &H120C,&H0,&HFBF6,&H4708,&H200,&H3A,&H2B: 'GP42:Closed High Hat
DATA &H0,&H0,&HF6F6,&H60C,&H0,&H34,&H31: 'GP43:High Floor Tom
DATA &H120C,&H500,&H7BF6,&H4708,&H200,&H3A,&H2B: 'GP44:Pedal High Hat
DATA &H0,&H0,&HF6F6,&H60C,&H0,&H34,&H33: 'GP45:Low Tom
DATA &H120C,&H0,&HCBF6,&H4302,&H200,&H3A,&H2B: 'GP46:Open High Hat
DATA &H0,&H0,&HF6F6,&H60C,&H0,&H34,&H36: 'GP47:Low-Mid Tom
DATA &H0,&H0,&HF6F6,&H60C,&H0,&H34,&H39: 'GP48:High-Mid Tom
DATA &HD00E,&H0,&H9FF6,&H200,&H300,&H3E,&H48: 'GP49:Crash Cymbal 1
DATA &H0,&H0,&HF6F6,&H60C,&H0,&H34,&H3C: 'GP50:High Tom
DATA &H70E,&H4A08,&HF4F8,&HE442,&H300,&H3E,&H4C: 'GP51:Ride Cymbal 1
DATA &HD00E,&HA00,&H9FF5,&H230,&H0,&H3E,&H54: 'GP52:Chinese Cymbal
DATA &H70E,&H5D0A,&HF5E4,&HE5E4,&H103,&H36,&H24: 'GP53:Ride Bell
DATA &H502,&HA03,&H97B4,&HF704,&H0,&H3E,&H41: 'GP54:Tambourine
DATA &H9E4E,&H0,&H9FF6,&H200,&H300,&H3E,&H54: 'GP55:Splash Cymbal
DATA &H1011,&H845,&HF3F8,&H537,&H2,&H38,&H53: 'GP56:Cow Bell
DATA &HD00E,&H0,&H9FF6,&H200,&H300,&H3E,&H54: 'GP57:Crash Cymbal 2
DATA &H1080,&HD00,&HFFFF,&H1403,&H3,&H3C,&H18: 'GP58:Vibraslap
DATA &H70E,&H4A08,&HF4F8,&HE442,&H300,&H3E,&H4D: 'GP59:Ride Cymbal 2
DATA &H206,&HB,&HF5F5,&H80C,&H0,&H36,&H3C: 'GP60:High Bongo
DATA &H201,&H0,&HC8FA,&H97BF,&H0,&H37,&H41: 'GP61:Low Bongo
DATA &H101,&H51,&HFAFA,&HB787,&H0,&H36,&H3B: 'GP62:Mute High Conga
DATA &H201,&H54,&HF8FA,&HB88D,&H0,&H36,&H33: 'GP63:Open High Conga
DATA &H201,&H59,&HF8FA,&HB688,&H0,&H36,&H2D: 'GP64:Low Conga
DATA &H1,&H0,&HFAF9,&H60A,&H3,&H3E,&H47: 'GP65:High Timbale
DATA &H0,&H80,&HF6F9,&H6C89,&H3,&H3E,&H3C: 'GP66:Low Timbale
DATA &HC03,&H880,&HF6F8,&HB688,&H3,&H3F,&H3A: 'GP67:High Agogo
DATA &HC03,&H85,&HF6F8,&HB688,&H3,&H3F,&H35: 'GP68:Low Agogo
DATA &HE,&H840,&H7776,&H184F,&H200,&H3E,&H40: 'GP69:Cabasa
DATA &H30E,&H40,&H9BC8,&H6949,&H200,&H3E,&H47: 'GP70:Maracas
DATA &HC7D7,&HDC,&H8DAD,&H505,&H3,&H3E,&H3D: 'GP71:Short Whistle
DATA &HC7D7,&HDC,&H88A8,&H404,&H3,&H3E,&H3D: 'GP72:Long Whistle
DATA &H1180,&H0,&H67F6,&H1706,&H303,&H3E,&H2C: 'GP73:Short Guiro
DATA &H1180,&H900,&H46F5,&H1605,&H302,&H3E,&H28: 'GP74:Long Guiro
DATA &H1506,&H3F,&HF700,&HF5F4,&H0,&H31,&H45: 'GP75:Claves
DATA &H1206,&H3F,&HF700,&HF5F4,&H3,&H30,&H44: 'GP76:High Wood Block
DATA &H1206,&H3F,&HF700,&HF5F4,&H0,&H31,&H3F: 'GP77:Low Wood Block
DATA &H201,&H58,&H7567,&H7E7,&H0,&H30,&H4A: 'GP78:Mute Cuica
DATA &H4241,&H845,&H75F8,&H548,&H0,&H30,&H3C: 'GP79:Open Cuica
DATA &H1E0A,&H4E40,&HFFE0,&H5F0,&H3,&H38,&H50: 'GP80:Mute Triangle
DATA &H1E0A,&H527C,&HFFE0,&H2F0,&H3,&H38,&H40: 'GP81:Open Triangle
DATA &HE,&H840,&H7B7A,&H1B4A,&H200,&H3E,&H48: 'GP82
DATA &H70E,&H400A,&H55E4,&H39E4,&H103,&H36,&H49: 'GP83
DATA &H405,&H4005,&HD6F9,&HA532,&H3,&H3E,&H46: 'GP84
DATA &H1502,&H3F,&HF700,&HF5F3,&H3,&H38,&H44: 'GP85
DATA &H201,&H4F,&HF8FA,&HB58D,&H0,&H37,&H30: 'GP86
DATA &H0,&H0,&HF6F6,&H60C,&H0,&H34,&H35: 'GP87


SUB PlayerLoop
    SHARED MIDI AS MIDIStr
    SHARED Status AS StatusStr

    IF Status.Began THEN Status.PlayWait = Status.PlayWait - 1

    DO WHILE Status.PlayWait = 0
        ProcessTrackEvents MIDI, Status
    LOOP
END SUB

FUNCTION AllocateChannel% (Instrument AS INTEGER)
    DIM AllocatedChannel AS INTEGER
    DIM CandidateChannel AS INTEGER
    DIM HighestScore AS DOUBLE
    DIM Score AS DOUBLE

    AllocatedChannel = NO_CHANNEL
    HighestScore = &H80000000
    Score = &H0
    FOR CandidateChannel = LBOUND(Channels) TO UBOUND(Channels)
        IF Channels(CandidateChannel).IsOn THEN
            Score = &H0
            IF ChannelInstruments(CandidateChannel).Instrument = Instrument THEN
                Score = Score + .2
            ELSEIF Instrument < &H80 AND ChannelInstruments(CandidateChannel).Instrument > &H7F THEN
                Score = (Score * &H2) + &H9
            END IF
        ELSE
            Score = (Score + Channels(CandidateChannel).Age) + &HBB8
        END IF

        IF Score > HighestScore THEN
            HighestScore = Score
            AllocatedChannel = CandidateChannel
        END IF
    NEXT CandidateChannel

    AllocateChannel = AllocatedChannel
END FUNCTION

SUB ChangePanning (Channel AS INTEGER, Panning AS INTEGER)
    DIM NewPanning AS INTEGER

    NewPanning = NULL
    IF Panning < &H30 THEN
        NewPanning = OPL_C0_RIGHT_SPEAKER_ENABLE
    ELSEIF Panning >= &H50 THEN
        NewPanning = OPL_C0_LEFT_SPEAKER_ENABLE
    END IF

    ChannelSettings(Channel).Panning = NewPanning
END SUB

SUB ControllerChange (Channel AS INTEGER, MIDI AS MIDIStr)
    DIM Controller AS INTEGER
    DIM DataV AS INTEGER

    Controller = ASC(INPUT$(&H1, MIDI.FileH))
    DataV = ASC(INPUT$(&H1, MIDI.FileH))

    SELECT CASE Controller
        CASE MC_MODULATION
            ChannelSettings(Channel).Vibrato = DataV
            UpdateAllLiveNotes Channel, MOP_PAN, NULL
        CASE MC_BEND
            MIDI.BendSense = DataV / MAXIMUM_SIGNED_B_END
        CASE MC_VOLUME
            ChannelSettings(Channel).Volume = DataV
        CASE MC_PAN
            ChangePanning Channel, DataV
        CASE MC_RESET_ALL_CONTROLLERS
            ResetAllControllers Channel
        CASE MC_ALL_NOTES_OFF
            UpdateAllLiveNotes Channel, MOP_VOLUME, NULL
    END SELECT
END SUB

SUB DeallocateActiveNote (Channel AS INTEGER, ActiveNote AS INTEGER)
    DIM DeactivatedNoteChannel AS INTEGER
    DIM NoteToDeactivate AS INTEGER

    NoteToDeactivate = ActiveNoteList(Channel, ActiveNote)
    ActiveNotes(Channel, NoteToDeactivate).Index = &H0
    DeactivatedNoteChannel = ActiveNotes(Channel, NoteToDeactivate).AdlibChannel
    Channels(DeactivatedNoteChannel).Age = &H0
    Channels(DeactivatedNoteChannel).IsOn = FALSE

    OPLNoteOff DeactivatedNoteChannel

    IF Channels(DeactivatedNoteChannel).XCharacter = 32 THEN
        Display 20 - DeactivatedNoteChannel, Channels(DeactivatedNoteChannel).x, 1, "."
    ELSE
        Display 20 - DeactivatedNoteChannel, Channels(DeactivatedNoteChannel).x, Channels(DeactivatedNoteChannel).XColor, CHR$(Channels(DeactivatedNoteChannel).XCharacter)
    END IF

    IF NOT ActiveNote = ActiveNoteCount(Channel) THEN
        NoteToDeactivate = ActiveNoteList(Channel, ActiveNoteCount(Channel))
        ActiveNoteList(Channel, ActiveNote) = NoteToDeactivate
        ActiveNotes(Channel, NoteToDeactivate).Index = ActiveNote
        Channels(ActiveNotes(Channel, NoteToDeactivate).AdlibChannel).ActiveIndex = ActiveNote
    END IF

    ActiveNoteCount(Channel) = ActiveNoteCount(Channel) - 1
END SUB

SUB Display (Row AS INTEGER, Column AS INTEGER, ColorV AS INTEGER, Text AS STRING)
    COLOR ColorV
    IF NOT Column = NULL THEN LOCATE , Column
    IF NOT Row = NULL THEN LOCATE Row
    PRINT Text;
END SUB

SUB DisplayKeys
    Display 1, 1, 15, "Press Q to quit"
END SUB

SUB DisplayNote (AllocatedChannel AS INTEGER, Note AS INTEGER)
    DIM x AS INTEGER
    DIM y AS INTEGER

    Channels(AllocatedChannel).x = (Note MOD 80) + 1
    Channels(AllocatedChannel).ColorV = 9 + (ChannelInstruments(AllocatedChannel).Instrument MOD &H6)
    y = 20 - AllocatedChannel
    x = Channels(AllocatedChannel).x
    Channels(AllocatedChannel).XCharacter = SCREEN(y, x, FALSE)
    Channels(AllocatedChannel).XColor = SCREEN(y, x, TRUE)
    Display y, x, Channels(AllocatedChannel).ColorV, "#"
END SUB

FUNCTION GetHertz# (Note AS INTEGER, Bend AS DOUBLE)
    GetHertz = SCREAM_TRACKER_3_NOTE_B * (2# ^ ((Note + Bend) / ET_SEMITONES_PER_OCTAVE)) * AMIGA_PC_SAMPLING_RATIO
END FUNCTION

SUB GetInstrumentData
    DIM Column AS INTEGER
    DIM Instrument AS INTEGER

    RESTORE InstrumentData
    FOR Instrument = LBOUND(Instruments, 1) TO UBOUND(Instruments, 1)
        FOR Column = LBOUND(Instruments, 2) TO UBOUND(Instruments, 2)
            READ Instruments(Instrument, Column)
        NEXT Column
    NEXT Instrument
END SUB

FUNCTION GetInvertedDeltaTicks# (TicksPerQuarterNote AS INTEGER)
    DIM InvertedDeltaTicks AS DOUBLE

    InvertedDeltaTicks = EVENT_TICK_FREQUENCY
    InvertedDeltaTicks = InvertedDeltaTicks / (TicksPerQuarterNote * 240000000#)

    GetInvertedDeltaTicks = InvertedDeltaTicks
END FUNCTION

FUNCTION GetOctave% (Hertz AS DOUBLE)
    DIM Octave AS INTEGER

    Octave = 0
    DO WHILE Hertz >= 1023.5
        Hertz = Hertz / 2
        Octave = Octave + 1024
    LOOP

    GetOctave = Octave + CINT(Hertz)
END FUNCTION

FUNCTION GetShortestDelay& (TrackCount AS LONG)
    DIM ShortestDelay AS LONG
    DIM Track AS INTEGER

    ShortestDelay = -1
    FOR Track = 0 TO TrackCount - 1
        IF Tracks(Track).Status >= 0 THEN
            IF ShortestDelay = -1 OR Tracks(Track).Delay < ShortestDelay THEN
                ShortestDelay = Tracks(Track).Delay
            END IF
        END IF
    NEXT Track

    GetShortestDelay = ShortestDelay
END FUNCTION

SUB HandleSpecialTrackEvent (MIDISpecialEvent AS INTEGER, Track AS INTEGER, MIDI AS MIDIStr, Status AS StatusStr)
    DIM Ignored AS LONG

    SELECT CASE MIDISpecialEvent
        CASE ME_SONGPOSITION
            SEEK #MIDI.FileH, SEEK(MIDI.FileH) + &H2
        CASE ME_SONGSELECT
            SEEK #MIDI.FileH, SEEK(MIDI.FileH) + &H1
        CASE ME_SYSEX_START, ME_SYSEX_END
            Ignored = ReadVariableLengthInteger(MIDI)
        CASE ELSE
            HandleSpecialTrackMetaEvent Track, MIDI, Status
    END SELECT
END SUB

SUB HandleSpecialTrackMetaEvent (Track AS INTEGER, MIDI AS MIDIStr, Status AS StatusStr)
    DIM EventType AS INTEGER
    DIM StringV AS STRING

    EventType = ASC(INPUT$(&H1, MIDI.FileH))
    StringV = INPUT$(ReadVariableLengthInteger(MIDI), MIDI.FileH)

    SELECT CASE EventType
        CASE MMET_MARKER
            IF StringV = "loopStart" THEN
                Status.LoopStart = TRUE
            ELSEIF StringV = "loopEnd" THEN
                Status.LoopEnd = TRUE
            END IF
        CASE MME_END_OF_TRACK
            Tracks(Track).Status = -1
            Status.LoopEnd = TRUE
        CASE MME_SET_TEMPO
            MIDI.Tempo = ParseBEDWord(CHR$(&H0) + StringV) * MIDI.InvertedDeltaTicks
        CASE MMET_COPYRIGHT, MMET_GENERIC, MMET_INSTRUMENT, MMET_LYRIC, MMET_MARKER, MMET_TRACK
            Status.TextRow = 3 + (Status.TextRow - 2) MOD 20
            Display Status.TextRow, 1, 8, "Meta" + STR$(EventType) + ": " + RemoveSpecialCharacters(StringV)
    END SELECT
END SUB

SUB HandleTrackEvent (Track AS INTEGER, MIDI AS MIDIStr, Status AS StatusStr)
    DIM Byte AS INTEGER
    DIM Channel AS INTEGER
    DIM MIDIEvent AS INTEGER

    SEEK #MIDI.FileH, Tracks(Track).Pointer + &H1
    Byte = ASC(INPUT$(&H1, MIDI.FileH))

    IF Byte < ME_SYSEX_START THEN
        IF IsRunningStatus(Byte) THEN
            Byte = Tracks(Track).Status OR ME_FIRST
            SEEK #MIDI.FileH, Tracks(Track).Pointer + &H1
        END IF

        Tracks(Track).Status = Byte

        Channel = Byte AND ME_CHANNEL_MASK
        MIDIEvent = Byte AND ME_MASK

        SELECT CASE MIDIEvent
            CASE ME_NOTE_OFF
                NoteOff Channel, MIDI
            CASE ME_NOTE_ON
                NoteOn Channel, Status, MIDI
            CASE ME_POLYPHONIC
                NoteTouch Channel, MIDI
            CASE ME_CONTROLLER
                ControllerChange Channel, MIDI
            CASE ME_INSTRUMENT
                ChannelSettings(Channel).Patch = ASC(INPUT$(&H1, MIDI.FileH))
            CASE ME_PRESSURE
                UpdateAllLiveNotes Channel, MOP_PRESSURE, ASC(INPUT$(&H1, MIDI.FileH))
            CASE ME_BEND
                ChannelSettings(Channel).Bend = (ReadInteger(MIDI) - SIGN_14BIT) * MIDI.BendSense
                UpdateAllLiveNotes Channel, MOP_PITCH, NULL
        END SELECT
    ELSE
        HandleSpecialTrackEvent Byte, Track, MIDI, Status
    END IF
END SUB

SUB Initialize (Status AS StatusStr)
    IF NOT Adlib_Initialize THEN
        _MESSAGEBOX "Error", "Failed to initialize Adlib emulator!"
        END
    END IF

    GetInstrumentData
    OPLReset
    OPLReset

    DIM Channel AS INTEGER
    FOR Channel = LBOUND(ChannelSettings) TO UBOUND(ChannelSettings)
        ChannelSettings(Channel).Volume = &H7F
    NEXT Channel

    Status.Began = FALSE
    Status.LoopEnd = FALSE
    Status.LoopStart = TRUE
    Status.LoopWait = 0
    Status.PlayWait = 0
    Status.TextRow = 2

    Status.timerHandle = _FREETIMER
    ON TIMER(Status.timerHandle, 705 / _SNDRATE) PlayerLoop
END SUB

FUNCTION IsRunningStatus% (Byte AS INTEGER)
    IsRunningStatus = ((Byte AND ME_FIRST) = &H0)
END FUNCTION

SUB Main (MIDI AS MIDIStr, Status AS StatusStr)
    DIM FileName AS STRING
    DIM KeyStroke AS STRING

    FileName = COMMAND$
    IF FileName = "" THEN FileName = _OPENFILEDIALOG$("Select MIDI File", , "*.mid|*.midi|*.MID|*.MIDI", "MIDI Files")

    IF LEN(FileName) = NULL THEN
        Display 1, 1, 15, "No file specified."
    ELSE
        OpenMIDI FileName, MIDI

        DisplayKeys

        TIMER(Status.timerHandle) ON ' kickstart playback

        DO
            KeyStroke = INKEY$

            SELECT CASE KeyStroke
                CASE "q", "Q"
                    EXIT DO
            END SELECT
        LOOP
    END IF
END SUB

SUB NoteOff (Channel AS INTEGER, MIDI AS MIDIStr)
    DIM ActiveNote AS INTEGER
    DIM Note AS INTEGER

    Note = ASC(INPUT$(&H1, MIDI.FileH))
    SEEK #MIDI.FileH, SEEK(MIDI.FileH) + &H1

    ChannelSettings(Channel).Bend = &H0
    ActiveNote = ActiveNotes(Channel, Note).Index
    IF NOT ActiveNote = &H0 THEN
        DeallocateActiveNote Channel, ActiveNote
    END IF
END SUB

SUB NoteOn (Channel AS INTEGER, Status AS StatusStr, MIDI AS MIDIStr)
    DIM ActiveNoteCount AS INTEGER
    DIM AllocatedChannel AS INTEGER
    DIM Instrument AS INTEGER
    DIM NoteToBePlayed AS INTEGER
    DIM TrackNote AS INTEGER
    DIM Volume AS INTEGER

    TrackNote = ASC(INPUT$(&H1, MIDI.FileH))
    Volume = ASC(INPUT$(&H1, MIDI.FileH))

    IF Volume = NULL THEN
        ActiveNoteCount = ActiveNotes(Channel, TrackNote).Index
        IF NOT ActiveNoteCount = 0 THEN
            DeallocateActiveNote Channel, ActiveNoteCount
        END IF
    ELSE
        IF ActiveNotes(Channel, TrackNote).Index = &H0 THEN
            IF Channel = PERCUSSION_ONLY THEN
                Instrument = GP_01 + TrackNote
                NoteToBePlayed = Instruments(Instrument, PERCUSSIVE_NOTES)
            ELSE
                Instrument = ChannelSettings(Channel).Patch
                NoteToBePlayed = TrackNote
            END IF

            AllocatedChannel = AllocateChannel(Instrument)

            IF Channels(AllocatedChannel).IsOn THEN
                DeallocateActiveNote Channels(AllocatedChannel).MIDIChannel, Channels(AllocatedChannel).ActiveIndex
            END IF

            Channels(AllocatedChannel).Age = &H0
            ChannelInstruments(AllocatedChannel).Instrument = Instrument
            Channels(AllocatedChannel).IsOn = TRUE
            Status.Began = TRUE

            ActiveNoteCount = ActiveNoteCount(Channel) + 1
            ActiveNoteList(Channel, ActiveNoteCount) = TrackNote
            ActiveNoteCount(Channel) = ActiveNoteCount
            ActiveNotes(Channel, TrackNote).Index = ActiveNoteCount

            ActiveNotes(Channel, TrackNote).AdlibChannel = AllocatedChannel
            ActiveNotes(Channel, TrackNote).Note = NoteToBePlayed
            ActiveNotes(Channel, TrackNote).Volume = Volume
            Channels(AllocatedChannel).MIDIChannel = Channel
            Channels(AllocatedChannel).ActiveIndex = ActiveNoteCount
            OPLPatch AllocatedChannel
            UpdateNotePan AllocatedChannel, Channel
            UpdateNoteVolume AllocatedChannel, Channel, Volume

            DisplayNote AllocatedChannel, TrackNote

            OPLNoteOn AllocatedChannel, GetHertz(TrackNote, ChannelSettings(Channel).Bend)
            UpdateNoteVolume AllocatedChannel, Channel, Volume
        END IF
    END IF
END SUB

SUB NoteTouch (Channel AS INTEGER, MIDI AS MIDIStr)
    DIM ActiveChannel AS INTEGER
    DIM Note AS INTEGER
    DIM Volume AS INTEGER

    Note = ASC(INPUT$(&H1, MIDI.FileH))
    Volume = ASC(INPUT$(&H1, MIDI.FileH))
    IF NOT ActiveNotes(Channel, Note).Index = &H0 THEN
        ActiveChannel = ActiveNotes(Channel, Note).AdlibChannel
        Display 20 - ActiveChannel, Channels(ActiveChannel).x, Channels(ActiveChannel).ColorV, "&"
        ActiveNotes(Channel, Note).Volume = Volume
        UpdateNoteVolume ActiveChannel, Channel, Volume
    END IF
END SUB

SUB OpenMIDI (FileName AS STRING, MIDI AS MIDIStr)
    DIM TicksPerQuarterNote AS INTEGER
    DIM Track AS INTEGER
    DIM TrackDelayPosition AS LONG
    DIM TrackLength AS LONG

    IF NOT _FILEEXISTS(FileName) THEN
        MIDI.FileH = 0
        ERROR 53
    ELSE
        MIDI.FileH = FREEFILE
        OPEN FileName FOR BINARY LOCK READ WRITE AS #MIDI.FileH
        IF INPUT$(&H4, MIDI.FileH) = "MThd" THEN
            IF ParseBEDWord(INPUT$(&H4, MIDI.FileH)) = MTHD_BLOCK_DEFAULT_LENGTH THEN
                MIDI.Format = ParseBEWord(INPUT$(&H2, MIDI.FileH))
                MIDI.TrackCount = ParseBEWord(INPUT$(&H2, MIDI.FileH))

                REDIM Loops(0 TO MIDI.TrackCount - 1) AS TrackStr
                REDIM LoopsBackup(0 TO MIDI.TrackCount - 1) AS TrackStr
                REDIM Tracks(0 TO MIDI.TrackCount - 1) AS TrackStr

                TicksPerQuarterNote = ParseBEWord(INPUT$(&H2, MIDI.FileH))
                MIDI.InvertedDeltaTicks = GetInvertedDeltaTicks(TicksPerQuarterNote)
                MIDI.Tempo = DEFAULT_TEMPO * MIDI.InvertedDeltaTicks
                MIDI.BendSense = DEFAULT_PITCH_BEND

                FOR Track = 0 TO MIDI.TrackCount - 1
                    IF INPUT$(&H4, MIDI.FileH) = "MTrk" THEN
                        TrackLength = ParseBEDWord(INPUT$(&H4, MIDI.FileH))
                        TrackDelayPosition = LOC(MIDI.FileH)
                        Tracks(Track).Delay = ReadVariableLengthInteger(MIDI)
                        Tracks(Track).Pointer = LOC(MIDI.FileH)
                        SEEK #MIDI.FileH, (TrackDelayPosition + TrackLength) + &H1
                    ELSE
                        ERROR 13
                    END IF
                NEXT Track
            ELSE
                ERROR 6
            END IF
        ELSE
            ERROR 13
        END IF
    END IF
END SUB

SUB OPLNoteOff (Channel AS INTEGER)
    DIM OPL AS OPLStr

    OPLSetUp Channel, OPL

    Adlib_WriteRegister &HB0 OR OPL.SubChannel, ChannelInstruments(Channel).Pitch AND (OPL_B0_FREQUENCY_MASK OR OPL_B0_BLOCK_MASK)
END SUB

SUB OPLNoteOn (Channel AS INTEGER, Hertz AS DOUBLE)
    DIM Octave AS INTEGER
    DIM OPL AS OPLStr

    Octave = GetOctave(Hertz)
    OPLSetUp Channel, OPL

    Adlib_WriteRegister &HA0 OR OPL.SubChannel, Octave AND &HFF&

    Adlib_WriteRegister &HB0 OR OPL.SubChannel, (((Octave AND &HFF00&) \ &H100&) AND (OPL_B0_FREQUENCY_MASK OR OPL_B0_BLOCK_MASK)) OR OPL_B0_NOTE_ON

    ChannelInstruments(Channel).Pitch = (Octave AND &HFF00) \ &H100&
END SUB

SUB OPLPatch (Channel AS INTEGER)
    DIM Instrument AS INTEGER
    DIM OPL AS OPLStr

    Instrument = ChannelInstruments(Channel).Instrument

    OPLSetUp Channel, OPL

    Adlib_WriteRegister &H20 + OPL.Operator, Instruments(Instrument, &H0) AND &HFF&
    Adlib_WriteRegister &H60 + OPL.Operator, Instruments(Instrument, &H2) AND &HFF&
    Adlib_WriteRegister &H80 + OPL.Operator, Instruments(Instrument, &H3) AND &HFF&
    Adlib_WriteRegister &HE0 + OPL.Operator, Instruments(Instrument, &H4) AND &HFF&

    Adlib_WriteRegister &H20 + OPL.Operator + &H3, (Instruments(Instrument, &H0) AND &HFF00&) \ &H100&
    Adlib_WriteRegister &H60 + OPL.Operator + &H3, (Instruments(Instrument, &H2) AND &HFF00&) \ &H100&
    Adlib_WriteRegister &H80 + OPL.Operator + &H3, (Instruments(Instrument, &H3) AND &HFF00&) \ &H100&
    Adlib_WriteRegister &HE0 + OPL.Operator + &H3, (Instruments(Instrument, &H4) AND &HFF00&) \ &H100&
END SUB

SUB OPLReset
    DIM OPL AS OPLStr

    OPLSetUp NULL, OPL
    Adlib_WriteRegister &H4, OPL_04_TIMERS_12_ON
    Adlib_WriteRegister &H4, OPL_04_IRQ_RESET

    OPLSetUp PERCUSSION_ONLY, OPL
    Adlib_WriteRegister &H5, OPL_05_OPL3_OFF
    Adlib_WriteRegister &H5, OPL_05_OPL3_ON
    Adlib_WriteRegister &H5, OPL_05_OPL3_OFF

    OPLSetUp NULL, OPL
    Adlib_WriteRegister &H1, OPL_01_WAVE_ON

    Adlib_WriteRegister &HBD, OPL_BD_MEDOLIC_MODE

    OPLSetUp PERCUSSION_ONLY, OPL
    Adlib_WriteRegister &H5, OPL_05_OPL3_ON

    OPLSetUp PERCUSSION_ONLY, OPL
    Adlib_WriteRegister &H4, OPL_04_MOD_E0

    OPLSilence
END SUB

SUB OPLSetUp (Channel AS INTEGER, OPL AS OPLStr)
    OPL.DataV = &H0
    OPL.Index = &H0
    OPL.Operator = &H0
    OPL.SubChannel = &H0

    SELECT CASE Channel
        CASE &H0 TO &H8
            OPL.DataV = OPL_DATA1
            OPL.Index = OPL_INDEX1
            OPL.SubChannel = Channel
        CASE &H9 TO &H11
            OPL.DataV = OPL_DATA2
            OPL.Index = OPL_INDEX2
            OPL.SubChannel = Channel - &H9
    END SELECT

    OPL.Operator = (OPL.SubChannel MOD &H3) OR (&H8 * (OPL.SubChannel \ &H3))
END SUB

SUB OPLSilence
    DIM Channel AS INTEGER

    FOR Channel = LBOUND(Channels) TO UBOUND(Channels)
        OPLNoteOff Channel
        OPLTouchReal Channel, &H0
    NEXT Channel
END SUB

SUB OPLTouchReal (Channel AS INTEGER, Volume AS INTEGER)
    DIM Attenuation AS INTEGER
    DIM Instrument AS INTEGER
    DIM KSLA AS INTEGER
    DIM OPL AS OPLStr

    Instrument = ChannelInstruments(Channel).Instrument

    OPLSetUp Channel, OPL

    KSLA = Instruments(Instrument, 1) AND &HFF&
    Attenuation = ((KSLA AND OPL_ATTENUATION_MASK) * Volume) \ OPL_MAXIMUM_VOLUME
 
    Adlib_WriteRegister &H40 + OPL.Operator, ((KSLA OR OPL_MAXIMUM_ATTENUATION) - Volume) + Attenuation

    KSLA = (Instruments(Instrument, 1) AND &HFF00&) \ &H100&
    Attenuation = ((KSLA AND OPL_ATTENUATION_MASK) * Volume) \ OPL_MAXIMUM_VOLUME

    Adlib_WriteRegister &H43 + OPL.Operator, ((KSLA OR OPL_MAXIMUM_ATTENUATION) - Volume) + Attenuation
END SUB

FUNCTION ParseBEDWord& (Buffer AS STRING)
    DIM DWord AS LONG

    DWord = ASC(MID$(Buffer, &H4, &H1))
    DWord = DWord OR (ASC(MID$(Buffer, &H3, &H1)) * &H100&)
    DWord = DWord OR (ASC(MID$(Buffer, &H2, &H1)) * &H10000)
    ParseBEDWord = DWord OR (ASC(MID$(Buffer, &H1, &H1)) * &H1000000)
END FUNCTION

FUNCTION ParseBEWord% (Buffer AS STRING)
    DIM Word AS INTEGER

    Word = ASC(MID$(Buffer, &H2, &H1))
    ParseBEWord = Word OR (ASC(MID$(Buffer, &H1, &H1)) * &H100)
END FUNCTION

SUB ProcessTrackEvents (MIDI AS MIDIStr, Status AS StatusStr)
    DIM Track AS INTEGER

    FOR Track = 0 TO MIDI.TrackCount - 1
        LoopsBackup(Track).Delay = Tracks(Track).Delay
        LoopsBackup(Track).Pointer = Tracks(Track).Pointer
        LoopsBackup(Track).Status = Tracks(Track).Status

        IF Tracks(Track).Status >= 0 AND Tracks(Track).Delay <= 0 THEN
            HandleTrackEvent Track, MIDI, Status
            IF Status.LoopEnd THEN

                ReturnToLoopStart MIDI, Status

                COLOR , 0
                CLS
                Status.TextRow = 2
                DisplayKeys
            ELSE
                Tracks(Track).Delay = Tracks(Track).Delay + ReadVariableLengthInteger(MIDI)
                Tracks(Track).Pointer = LOC(MIDI.FileH)
            END IF
        END IF
    NEXT Track

    IF Status.LoopStart THEN
        SaveLoopStart MIDI, Status
    END IF

    DO WHILE ScheduleEventsAfterDelay(GetShortestDelay(MIDI.TrackCount), MIDI, Status) < 0
    LOOP
END SUB

SUB Quit (MIDI AS MIDIStr, Status AS StatusStr)
    TIMER(Status.timerHandle) OFF
    TIMER(Status.timerHandle) FREE
    Display NULL, NULL, 9, "End!"
    OPLSilence
    CLOSE #MIDI.FileH
    Adlib_Finalize
END SUB

FUNCTION ReadInteger% (MIDI AS MIDIStr)
    DIM IntegerV AS INTEGER

    IntegerV = ASC(INPUT$(&H1, MIDI.FileH)) AND &H7F
    IntegerV = IntegerV OR (ASC(INPUT$(&H1, MIDI.FileH)) * &H80)

    ReadInteger = IntegerV
END FUNCTION

FUNCTION ReadVariableLengthInteger& (MIDI AS MIDIStr)
    DIM Byte AS INTEGER
    DIM VariableLengthInteger AS LONG

    VariableLengthInteger = &H0
    DO
        Byte = ASC(INPUT$(&H1, MIDI.FileH))
        VariableLengthInteger = (VariableLengthInteger * &H80) OR (Byte AND &H7F)
    LOOP UNTIL Byte < &H80

    ReadVariableLengthInteger = VariableLengthInteger
END FUNCTION

FUNCTION RemoveSpecialCharacters$ (Text AS STRING)
    DIM Position AS INTEGER
    DIM Result AS STRING

    Result = Text
    FOR Position = 1 TO LEN(Text)
        SELECT CASE MID$(Result, Position, 1)
            CASE IS < " ", IS > "~"
                MID$(Result, Position, 1) = "?"
        END SELECT
    NEXT Position

    RemoveSpecialCharacters = Result
END FUNCTION

SUB ResetAllControllers (Channel AS INTEGER)
    ChannelInstruments(Channel).Panning = &H0
    ChannelSettings(Channel).Bend = &H0
    ChannelSettings(Channel).Vibrato = &H0
    UpdateAllLiveNotes Channel, MOP_OFF, NULL
    UpdateAllLiveNotes Channel, MOP_PAN, NULL
END SUB

SUB ReturnToLoopStart (MIDI AS MIDIStr, Status AS StatusStr)
    DIM Track AS LONG

    FOR Track = 0 TO MIDI.TrackCount - 1
        Tracks(Track).Delay = Loops(Track).Delay
        Tracks(Track).Pointer = Loops(Track).Pointer
        Tracks(Track).Status = Loops(Track).Status
    NEXT Track

    Status.LoopEnd = FALSE
    Status.PlayWait = Status.LoopWait
END SUB

SUB SaveLoopStart (MIDI AS MIDIStr, Status AS StatusStr)
    DIM Track AS LONG

    FOR Track = 0 TO MIDI.TrackCount - 1
        Loops(Track).Delay = LoopsBackup(Track).Delay
        Loops(Track).Pointer = LoopsBackup(Track).Pointer
        Loops(Track).Status = LoopsBackup(Track).Status
    NEXT Track

    Status.LoopWait = Status.PlayWait
    Status.LoopStart = FALSE
END SUB

FUNCTION ScheduleEventsAfterDelay# (Delay AS LONG, MIDI AS MIDIStr, Status AS StatusStr)
    DIM AgeIncrease AS DOUBLE
    DIM Channel AS INTEGER
    DIM Track AS INTEGER
 
    AgeIncrease = Delay * MIDI.Tempo

    FOR Channel = LBOUND(Channels) TO UBOUND(Channels)
        Channels(Channel).Age = Channels(Channel).Age + AgeIncrease
    NEXT Channel
 
    FOR Track = 0 TO MIDI.TrackCount - 1
        Tracks(Track).Delay = Tracks(Track).Delay - Delay
    NEXT Track

    IF Status.Began THEN
        Status.PlayWait = Status.PlayWait + AgeIncrease
    END IF
 
    ScheduleEventsAfterDelay = AgeIncrease
END FUNCTION

SUB UpdateAllLiveNotes (Channel AS INTEGER, MIDIOperation AS INTEGER, Volume AS INTEGER)
    DIM ActiveChannel AS INTEGER
    DIM ActiveCount AS INTEGER
    DIM ActiveNote AS INTEGER
    DIM Note AS INTEGER

    ActiveCount = ActiveNoteCount(Channel)

    FOR ActiveNote = 1 TO ActiveCount
        Note = ActiveNoteList(Channel, ActiveNote)
        ActiveChannel = ActiveNotes(Channel, Note).AdlibChannel
        SELECT CASE MIDIOperation
            CASE MOP_OFF
                DeallocateActiveNote Channel, ActiveNote
            CASE MOP_PAN
                UpdateNotePan ActiveChannel, Channel
            CASE MOP_PITCH
                OPLNoteOn ActiveChannel, GetHertz(ActiveNotes(Channel, Note).Note, ChannelSettings(Channel).Bend)
            CASE MOP_PRESSURE
                ActiveNotes(Channel, Note).Volume = Volume
                UpdateNoteVolume ActiveChannel, Channel, ActiveNotes(Channel, Note).Volume
            CASE MOP_VOLUME
                UpdateNoteVolume ActiveChannel, Channel, ActiveNotes(Channel, Note).Volume
        END SELECT
    NEXT ActiveNote
END SUB

SUB UpdateNotePan (ActiveChannel AS INTEGER, Channel AS INTEGER)
    DIM OPL AS OPLStr

    ChannelInstruments(ActiveChannel).Panning = ChannelSettings(Channel).Panning
    OPLSetUp ActiveChannel, OPL
    Adlib_WriteRegister &HC0 + OPL.SubChannel, Instruments(ChannelInstruments(ActiveChannel).Instrument, 5) - ChannelInstruments(ActiveChannel).Panning
END SUB

SUB UpdateNoteVolume (ActiveChannel AS INTEGER, Channel AS INTEGER, Volume AS INTEGER)
    DIM UpdatedVolume AS DOUBLE

    IF Volume = &H0 THEN
        OPLTouchReal ActiveChannel, &H0
    ELSE
        UpdatedVolume = Volume * ChannelSettings(Channel).Volume
        UpdatedVolume = LOG(UpdatedVolume / MAXIMUM_VOLUME)
        UpdatedVolume = UpdatedVolume / LOG(2)
        UpdatedVolume = UpdatedVolume * DOUBLE_LINEAR_AMPLITUDE
        UpdatedVolume = UpdatedVolume + ADLIB_VOLUME_RANGE

        OPLTouchReal ActiveChannel, CINT(UpdatedVolume)
    END IF
END SUB

'$INCLUDE:'include/adlib.bas'
