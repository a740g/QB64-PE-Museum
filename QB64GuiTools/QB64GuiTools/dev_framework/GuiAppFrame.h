// +---------------+---------------------------------------------------+
// | ###### ###### |     .--. .         .-.                            |
// | ##  ## ##   # |     |   )|        (   ) o                         |
// | ##  ##  ##    |     |--' |--. .-.  `-.  .  .-...--.--. .-.        |
// | ######   ##   |     |  \ |  |(   )(   ) | (   ||  |  |(   )       |
// | ##      ##    |     '   `'  `-`-'  `-'-' `-`-`|'  '  `-`-'`-      |
// | ##     ##   # |                            ._.'                   |
// | ##     ###### | Sources & Documents placed under the MIT License. |
// +---------------+---------------------------------------------------+
// |                                                                   |
// | === GuiAppFrame.h ===                                             |
// |                                                                   |
// | == Some low level support functions for the GuiTools Framework.   |
// |                                                                   |
// | == To activate the regex support you just need to uncomment the   |
// | == "#define GTREGEX" line (52) below. But before doing so, please |
// | == carefully read the notes given right below this file header.   |
// |                                                                   |
// +-------------------------------------------------------------------+
// | Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
// | Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
// | any questions or suggestions. Thanx for your interest in my work. |
// +-------------------------------------------------------------------+

/// QB64 versions using an old C/C++ compiler (all before QB64 v1.3)
/// -> ancient QB64 v0.xxx (SDL/GL) 32-bit versions
/// -> regular QB64 32-bit versions (stable & development)
/// -> various QB64 64-bit versions (by Steve McNeill)
/// -> current QB64-SDL 2020 version (by Steve McNeill)
/// -----
/// Before uncommenting the "#define GTREGEX" line below, you must modify the
/// file internal\c\makeline.txt (SDL) or internal\c\makekline_win.txt (GL),
/// adding the option -std=gnu++0x to the C/C++ compiler call. Otherwise
/// you'll get a C/C++ compilation error in the IDE whenever you try to
/// compile a GuiTools based programm.
/// -----
/// Note also that regex support is very experimental in the 32-bit compiler
/// and obviously never got bugfixed or even finished. Many regex's doesn't
/// work as expected, especially the char classes.
///-------------------------------------------------------------------

/// QB64 versions using an new C/C++ compiler (starting with QB64 v1.3)
/// -> regular QB64 32-bit versions (stable & development)
/// -> regular QB64 64-bit versions (stable & development)
/// -> regular QB64-PE 32-bit versions (Phoenix Edition v0.5 and up)
/// -> regular QB64-PE 64-bit versions (Phoenix Edition v0.5 and up)
/// -----
/// Just uncomment the "#define GTREGEX" line below and then enjoy regex's
/// to its fullest extent, no additional compiler options are required.
///-------------------------------------------------------------------

//#define GTREGEX // <<<<<<<<<< enable GuiTools regex support here
/// When disabled (commented), then the RegexMatch() function below will
/// always return one (1) (ie. match all). Use the RegexIsActive() function
/// in your programs to find out, if real regex matching is available.
///-------------------------------------------------------------------

//====================================================================
//=== Cheat on QB64's error handling (internal only) =================
//====================================================================

// Make QB64 to forget it is currently handling an error, hence allowing
// for other errors to happen within an error handling routine without
// causing QB64 to abort the program with an error popup message box.
//--------------------------------------------------------------------
void QB64ErrorOff(void) {
    error_handling = 0;
}

// Restore QB64's error awareness after it was switched off.
//--------------------------------------------------------------------
void QB64ErrorOn(void) {
    error_handling = 1;
}

//====================================================================
//=== Mutual exclusion handling ======================================
//====================================================================

// Create/Open a named mutual exclusion object and wait for access right.
// Recommend naming scheme: "Global\Name-Usage-Object"
//  - Global\ ... to force creation in the global namespace
//  - Name    ... unique name such as app/lib name (eg. QB64)
//  - Usage   ... for what we need this mutex (eg. "FileAccess")
//  - Object  ... the protected object (eg. the filename)
//  In: mutex name   (STRING, add CHR$(0) to end of string)
// Out: mutex handle (_OFFSET, save & use to unlock later)
// Err: out = 0      (no name or invalid name, try w/o Global\)
//--------------------------------------------------------------------
ptrszint LockMutex(const char *mtxName) {
    if (mtxName && mtxName[0] != '\0') {
        HANDLE mtxHandle = CreateMutex(0, 0, mtxName);
        if (mtxHandle) WaitForSingleObject(mtxHandle, INFINITE);
        return (ptrszint) mtxHandle;
    }
    return 0;
}

// Release the given mutual exclusion object to grant access to the next
// process in the waiting queue. Also close the used handle for cleanup.
// There must be an UnlockMutex() for every LockMutex() of the same name.
// In: mutex handle (_OFFSET, as saved from lock call)
//--------------------------------------------------------------------
void UnlockMutex(ptrszint mtxHandle) {
    if (mtxHandle) {
        ReleaseMutex((HANDLE) mtxHandle);
        CloseHandle((HANDLE) mtxHandle);
    }
}

// Plant a named mutual exclusion object into the system, but don't wait
// for access right. Use same naming scheme as for LockMutex().
//  In: mutex name   (STRING, add CHR$(0) to end of string)
// Out: mutex handle (_OFFSET, save & use to remove later)
// Err: out = 0      (no name or invalid name, try w/o Global\)
//--------------------------------------------------------------------
ptrszint PlantMutex(const char *mtxName) {
    if (mtxName && mtxName[0] != '\0') {
        return (ptrszint) CreateMutex(0, 0, mtxName);
    }
    return 0;
}

// Close the used handle of the given mutual exclusion object. Use this
// for "planted" mutex's only. There must be a RemoveMutex() for every
// PlantMutex() of the same name to properly remove the object.
// In: mutex handle (_OFFSET, as saved from plant call)
//--------------------------------------------------------------------
void RemoveMutex(ptrszint mtxHandle) {
    if (mtxHandle) CloseHandle((HANDLE) mtxHandle);
}

// Check whether a named mutual exclusion object already/still exists in
// the system without waiting for access right. This can be used for simple
// "planted" mutex's as well as for "locked" ones. Use same naming scheme
// as for LockMutex().
//  In: mutex name (STRING, add CHR$(0) to end of string)
// Out: exist flag (INTEGER, true (-1) or false (0))
// Err: (if no name is given, then "not existing" is implied)
//--------------------------------------------------------------------
int16 CheckMutex(const char *mtxName) {
    if (mtxName && mtxName[0] != '\0') {
        int16 exFlag = 0; // error on Create... call implies "not existing"
        HANDLE mtxHandle = CreateMutex(0, 0, mtxName);
        if (mtxHandle) {
            if (GetLastError() == ERROR_ALREADY_EXISTS) exFlag = -1;
            CloseHandle(mtxHandle);
        }
        return exFlag;
    }
    return 0;
}

//====================================================================
//=== POSIX compliant directory reading ==============================
//====================================================================

#include <dirent.h>

// Prepare the specified directory for reading its entries and return
// the directory handle on success. If the directory is not available
// (not existing or no access rights), then zero is returned.
//  In: path name  (STRING, add CHR$(0) to end of string)
// Out: dir handle (_OFFSET, save & use to get/end later)
// Err: out = 0    (path not existing or no permissions)
//--------------------------------------------------------------------
ptrszint BeginDirRead(const char *pathName) {
    return (ptrszint) opendir(pathName);
}

// Return the name of the next available entry (file or sub-directory)
// from the directory specified by the given directory handle. You usually
// call this function in a loop until no more entries are found. If the
// handle is invalid or no more entries exist in the directory, then an
// empty string will be returned.
//  In: dir handle (_OFFSET, as saved from begin call)
// Out: entry name (STRING, you may want to exclude "." and ".." returns)
// Err: out = ""   (if handle is valid, then this implies "no more entries")
//--------------------------------------------------------------------
const char *GetDirEntry(ptrszint dirHandle) {
    if (!dirHandle) return "";
    struct dirent *dirEntry = readdir((DIR*) dirHandle);
    if (!dirEntry) return "";
    return (const char*) dirEntry -> d_name;
}

// Close the directory specified by the given directory handle. There
// should be a EndDirRead() for every BeginDirRead() to properly free
// all used resources.
// In: dir handle (_OFFSET, as saved from begin call)
//--------------------------------------------------------------------
void EndDirRead(ptrszint dirHandle) {
    if (dirHandle) closedir((DIR*) dirHandle);
}

//====================================================================
//=== Regular Expressions support ====================================
//====================================================================

#ifdef GTREGEX
#include <regex>
#endif

// Check whether the given string does match the given regular expression.
// The regex must match entirely to be true (ie. without any additional
// characters before or after the match), hence the use of ^ or $ for
// line start or line end respectively is not required/supported.
// See also the important notes placed at the top of this file.
//  In: string, regex (both STRINGs, add CHR$(0) to end of strings)
// Out: match         (INTEGER, 0 = no match, 1 = positive match)
// Err: out < 0       (call RegexError() to get the error message)
//--------------------------------------------------------------------
int16 RegexMatch(const char *qbStr, const char *qbRegex) {
    #ifdef GTREGEX
    int16 result;
    try {result = regex_match(qbStr, std::regex(qbRegex));}
    catch (const std::regex_error& e) {result = ~e.code();}
    return result;
    #else
    return 1; // regex support disabled, simulate a "match all"
    #endif
}

// Return a detailed error description message for any negative error code,
// which might be returned by the RegexMatch() function.
//  In: error code (INTEGER, usually the code returned by RegexMatch())
// Out: error text (STRING, description for the given error code)
//--------------------------------------------------------------------
const char *RegexError(int16 errCode) {
    #ifdef GTREGEX
    switch (~errCode) {
        // just in case somebody pass in the regular matching result as error
        case -2: {return "No error, it was a positive RegEx match."; break;}
        case -1: {return "No error, the RegEx just didn't match."; break;}
        // and now the real errors known to the regex library
        case std::regex_constants::error_collate: {return "RegEx has an invalid collating element name."; break;}
        case std::regex_constants::error_ctype: {return "RegEx has an invalid character class name."; break;}
        case std::regex_constants::error_escape: {return "RegEx has an invalid escaped character, or a trailing escape."; break;}
        case std::regex_constants::error_backref: {return "RegEx has an invalid back reference."; break;}
        case std::regex_constants::error_brack: {return "RegEx has mismatched brackets [ and ]."; break;}
        case std::regex_constants::error_paren: {return "RegEx has mismatched parentheses ( and )."; break;}
        case std::regex_constants::error_brace: {return "RegEx has mismatched braces { and }."; break;}
        case std::regex_constants::error_badbrace: {return "RegEx has an invalid range between braces { and }."; break;}
        case std::regex_constants::error_range: {return "RegEx has an invalid character range."; break;}
        case std::regex_constants::error_space: {return "Out of memory while converting RegEx into a finite state machine."; break;}
        case std::regex_constants::error_badrepeat: {return "RegEx has a repeat specifier, one of *?+{, that was not preceded by a valid token."; break;}
        case std::regex_constants::error_complexity: {return "Complexity of an attempted match exceeded a pre-set level."; break;}
        case std::regex_constants::error_stack: {return "Out of memory while trying to match the specified string."; break;}
        // everything else is unknown
        default: {return "Unknown RegEx error."; break;}
    }
    #else
    return "Sorry, this program was compiled without RegEx support.";
    #endif
}

// Check whether this program was compiled with regex support enabled.
// See also the important notes placed at the top of this file.
// Out: activation flag (INTEGER, true (-1) or false (0))
//--------------------------------------------------------------------
int16 RegexIsActive(void) {
    #ifdef GTREGEX
    return -1; // true = regex support enabled
    #else
    return 0; // false = regex support disabled
    #endif
}

//====================================================================
//=== Miscellaneous stuff ============================================
//====================================================================

// Bring the initial still untitled program window to the top of the
// Z-Order and activate it for input. Call this after a short _DELAY
// of 0.05 to 0.1 seconds to allow Windows to finish its setup first.
//--------------------------------------------------------------------
void UntitledToTop (void) {
    HWND win = FindWindowA(NULL, "Untitled");
    if (win) {
        BringWindowToTop(win); Sleep(50);
        SetForegroundWindow(win); Sleep(50);
    }
}

// This is a replacement for the _RGB function. It works for up to 8-bit
// (256 colors) images only and needs a valid image. It can limit the
// number of pens to search and uses a better color matching algorithm.
//  In: red, green, blue, image (<-1), min pen, max pen (all LONGs)
// Out: best matching pen (LONG, in given range min to max)
//--------------------------------------------------------------------
extern img_struct *img; // fwd reference
uint32 FindColor(int32 r, int32 g, int32 b, int32 i, int32 mi, int32 ma) {
    static   int32 v, v2, n1, n2, best, c, d1, d2, d3;
    register int32 *p, n, t;
    // initializing
    if (r < 0) r = 0; if (r > 255) r = 255;
    if (g < 0) g = 0; if (g > 255) g = 255;
    if (b < 0) b = 0; if (b > 255) b = 255;
    i = -i;
    p = (int32*) img[i].pal;
    if (img[i].text) n2 = 16; else n2 = img[i].mask + 1;
    if (mi <= 0) n1 = 0; else {n1 = mi; p += mi;}
    if ((ma > mi) && (n2 > ma)) n2 = ma + 1;
    // prepare variable values
    v = 120000; best = 0;
    r = (r << 8); g = (g << 8); b = (b << 8);
    for (n = n1; n < n2; n++) {
        c = *p++;
        // calc separate distances for RGB
        d1 = abs((0xFF00 & (c >> 8)) - r);
        d2 = abs((0xFF00 & c) - g);
        d3 = abs((0xFF00 & (c << 8)) - b);
        // sort distances descending
        if (d2 > d1) {t = d1; d1 = d2; d2 = t;}
        if (d3 > d1) {t = d1; d1 = d3; d3 = t;}
        if (d3 > d2) {t = d2; d2 = d3; d3 = t;}
        // calc weighted overall distance & check
        v2 = d1 + (d2 >> 1) + (d3 >> 2);
        if (v2 < v) {
            if (!v2) return n; // perfect match
            v = v2; best = n;
        } // v2
    } // n
    return best;
}

// A simple type to hold all necessary values of a shared memory object.
// Those objects can be used for easy inter process communication.
//--------------------------------------------------------------------
struct smObject {
    int32 memSize;      // size of vBuffer (shared memory region)
    HANDLE mapHandle;   // file mapping handle
    void *vBuffer;      // view of file (shared memory region)
    int8 *vFilled;      // content (*) is true, if vBuffer is filled with new data,
};                      // its use is optional and up to the communication routines

// This function will try to create a new shared memory object with the
// given name and size, on success it will return a pointer to the new
// initialized smObject structure. The used naming scheme is equal to
// the one described at LockMutex() above, but always without Global\.
// This function is used by the master process to create a new object,
// while any slave processes need to use OpenSMObject() to get access
// to the shared memory region.
//  In: object name   (STRING, add CHR$(0) to end of string)
// Out: object handle (_OFFSET, save & use it to access/remove later)
// Err: out = 0       (no name or invalid name, or out of memory)
//--------------------------------------------------------------------
ptrszint CreateSMObject(const char *smName, int32 smSize) {
    if (smName && smName[0] != '\0' && smSize > 0) {
        struct smObject *sm = 0;
        if (sm = (struct smObject*) malloc(sizeof(struct smObject))) {
            sm -> memSize = smSize;
            if (sm -> mapHandle = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, smSize + 1, smName)) {
                if (sm -> vBuffer = MapViewOfFile(sm -> mapHandle, FILE_MAP_ALL_ACCESS, 0, 0, smSize + 1)) {
                    sm -> vFilled = (int8*) sm -> vBuffer + smSize;
                    *(sm -> vFilled) = 0; // mark buffer content as obsolete
                    return (ptrszint) sm;
                }
                CloseHandle(sm -> mapHandle);
            }
            free(sm);
        }
    }
    return 0;
}

// Will remove the given shared memory object and free its resources.
// This function is used by the master process, there must be a matching
// call to RemoveSMObject() for each CreateSMObject() of the same name
// to properly remove and free the shared memory region.
// In: object handle (_OFFSET, as saved from create call)
//--------------------------------------------------------------------
void RemoveSMObject(ptrszint smObj) {
    if (smObj) {
        struct smObject *sm = (struct smObject*) smObj;
        if (sm -> vBuffer) UnmapViewOfFile(sm -> vBuffer);
        if (sm -> mapHandle) CloseHandle(sm -> mapHandle);
        free(sm);
    }
}

// This function will try to open an existing shared memory object, so
// that the calling process gets access to the shared memory region.
// This function is used by any slave processes to get access. It must
// use the very same name and size as the master process did use to
// create the object using CreateSMObject() above.
//  In: object name   (STRING, add CHR$(0) to end of string)
// Out: object handle (_OFFSET, save & use it to access/close later)
// Err: out = 0       (no name or invalid name, or out of memory)
//--------------------------------------------------------------------
ptrszint OpenSMObject(const char *smName, int32 smSize) {
    if (smName && smName[0] != '\0' && smSize > 0) {
        struct smObject *sm = 0;
        if (sm = (struct smObject*) malloc(sizeof(struct smObject))) {
            sm -> memSize = smSize;
            if (sm -> mapHandle = OpenFileMapping(FILE_MAP_ALL_ACCESS, 0, smName)) {
                if (sm -> vBuffer = MapViewOfFile(sm -> mapHandle, FILE_MAP_ALL_ACCESS, 0, 0, smSize + 1)) {
                    sm -> vFilled = (int8*) sm -> vBuffer + smSize;
                    *(sm -> vFilled) = 0; // mark buffer content as obsolete
                    return (ptrszint) sm;
                }
                CloseHandle(sm -> mapHandle);
            }
            free(sm);
        }
    }
    return 0;
}

// Will close the given shared memory object and free its resources.
// This function is used by any slave processes, there must be a matching
// call to CloseSMObject() for each OpenSMObject() of the same name to
// properly remove and free the shared memory region.
// In: object handle (_OFFSET, as saved from open call)
//--------------------------------------------------------------------
void CloseSMObject(ptrszint smObj) {
    RemoveSMObject(smObj);
}

// GuiTools specific (internal shared memory communication)
// The Put/GetSMString() routines are used to transfer messages
// between the main program and the currently active GuiView window.
// Note that shared memory access must be protected with LockMutex().
//--------------------------------------------------------------------
void PutSMString(ptrszint smObj, const char *qbStr) {
    if (smObj && qbStr) {
        struct smObject *sm = (struct smObject*) smObj;
        int32 sLen = strlen(qbStr) + 1;
        if ((!*(sm -> vFilled)) && (sLen <= sm -> memSize)) {
            memcpy(sm -> vBuffer, qbStr, sLen);
            *(sm -> vFilled) = -1; // data written, mark buffer content as new
        }
    }
}

const char *GetSMString(ptrszint smObj) {
    if (smObj) {
        struct smObject *sm = (struct smObject*) smObj;
        if (*(sm -> vFilled)) {
            *(sm -> vFilled) = 0; // data read, mark buffer content as obsolete
            return (const char*) sm -> vBuffer;
        }
    }
    return "";
}

// GuiTools specific (internal shared memory communication)
// The ImageToSM() and SMToImage() routines are used to transfer the
// palette and pixel data of 8-bit (256 colors) images between the main
// program and the currently active GuiView window.
// Note that shared memory access must be protected with LockMutex().
//--------------------------------------------------------------------
void ImageToSM(ptrszint smObj, int32 i) {
    if (smObj && i < -1) {
        struct smObject *sm = (struct smObject*) smObj;
        i = -i; int32 pSize = img[i].width * img[i].height;
        if ((!*(sm -> vFilled)) && ((pSize + 1024) <= sm -> memSize)) {
            memcpy(sm -> vBuffer, img[i].pal, 1024);
            memcpy(sm -> vBuffer + 1024, img[i].offset, pSize);
            *(sm -> vFilled) = -1; // data written, mark buffer content as new
        }
    }
}

void SMToImage(ptrszint smObj, int32 i) {
    if (smObj && i < -1) {
        struct smObject *sm = (struct smObject*) smObj;
        i = -i; int32 pSize = img[i].width * img[i].height;
        if ((*(sm -> vFilled)) && ((pSize + 1024) <= sm -> memSize)) {
            memcpy(img[i].pal, sm -> vBuffer, 1024);
            memcpy(img[i].offset, sm -> vBuffer + 1024, pSize);
            *(sm -> vFilled) = 0; // data read, mark buffer content as obsolete
        }
    }
}

