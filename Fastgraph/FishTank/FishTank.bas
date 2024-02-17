'*****************************************************************************
'                                                                            *
'  FishTank.bas                                                              *
'                                                                            *
'  This program shows how to perform simple animation using QB64-PE.         *
'  Several types of tropical fish swim back and forth against a coral reef   *
'  background. The background image and fish sprites are stored in Base64    *
'  encoded BMP files in STRING CONSTs.                                       *
'                                                                            *
'  QB64-PE port by a740g, 2024                                               *
'  Now with 100% more bubbles!                                               *
'                                                                            *
'*****************************************************************************

$RESIZE:SMOOTH

_DEFINE A-Z AS LONG
OPTION _EXPLICIT

CONST FALSE = 0, TRUE = NOT FALSE
CONST SCALE = 3 ' have fun with this
CONST SCREENWIDTH = 320 * SCALE
CONST SCREENHEIGHT = 200 * SCALE
CONST NFISH = 11 ' total number of fish sprites
CONST NBUBBLE = 20
CONST BUBBLECOLOR = _RGB32(192, 192, 255)
CONST BUBBLEMAXRADIUS = 10
CONST BUBBLEMAXSPEED = 2

TYPE Vector2Type
    x AS LONG
    y AS LONG
END TYPE

TYPE RectangleType
    p AS Vector2Type ' position
    s AS Vector2Type ' size
END TYPE

TYPE FishType
    bmpInfo AS LONG ' which fish bitmap applies to this fish?
    p AS Vector2Type ' starting coordinates
    xMin AS LONG ' how far left (off screen) the fish can go
    xMax AS LONG ' how far right (off screen) the fish can go
    xInc AS LONG ' how fast the fish goes left and right
    yMin AS LONG ' how far up this fish can go
    yMax AS LONG ' how far down this fish can go
    yTurn AS LONG ' how long fish can go in the vertical direction before stopping or turning around
    yCount AS LONG ' counter to compare to yturn
    yInc AS LONG ' how fast the fish moves up or down
END TYPE

TYPE BubbleType
    p AS Vector2Type ' position
    r AS LONG ' radius
    s AS LONG ' speed
END TYPE

DIM AS LONG bmpCoral, bmpFishes
' There are 11 fish total, and 6 different kinds of fish. These
' arrays keep track of what kind of fish each fish is, and how each
' fish moves:
DIM fishBmpInfo(0 TO 5) AS RectangleType
DIM fish(1 TO NFISH) AS FishType
' My bubbles
DIM bubble(1 TO NBUBBLE) AS BubbleType

_TITLE "Fish Tank"

RANDOMIZE TIMER

' Switch to graphics mode
SCREEN _NEWIMAGE(SCREENWIDTH, SCREENHEIGHT, 32)
_FULLSCREEN _SQUAREPIXELS , _SMOOTH
_PRINTMODE _KEEPBACKGROUND

LoadAssets
InitFishes
InitBubbles

DO
    CLS

    GoBubbles
    _PUTIMAGE , bmpCoral, , , _SMOOTH
    GoFishes

    COLOR _RGB32(255): _PRINTSTRING (0, 0), STR$(Time_GetHertz) + " FPS"

    _DISPLAY

    _LIMIT 60
LOOP UNTIL _KEYHIT = 27

' Cleanup
_FREEIMAGE bmpFishes
_FREEIMAGE bmpCoral

SYSTEM


' Initializes all fish type
SUB InitFishes
    SHARED fish() AS FishType

    RESTORE fish_info
    DIM i AS LONG: FOR i = 1 TO NFISH
        ' We need to scale most of these to account for the increased screen resolution
        READ fish(i).bmpInfo
        READ fish(i).p.x: fish(i).p.x = fish(i).p.x * SCALE
        READ fish(i).p.y: fish(i).p.y = fish(i).p.y * SCALE
        READ fish(i).xMin: fish(i).xMin = fish(i).xMin * SCALE
        READ fish(i).xMax: fish(i).xMax = fish(i).xMax * SCALE
        READ fish(i).xInc
        READ fish(i).yMin: fish(i).yMin = fish(i).yMin * SCALE
        READ fish(i).yMax: fish(i).yMax = fish(i).yMax * SCALE
        READ fish(i).yTurn: fish(i).yTurn = fish(i).yTurn * SCALE
    NEXT i

    fish_info:
    DATA 1,-100,40,-300,600,2,40,80,50
    DATA 1,-150,60,-300,601,2,60,100,30
    DATA 2,-450,150,-800,1100,8,120,170,10
    DATA 3,-140,80,-200,1000,5,70,110,30
    DATA 3,-200,70,-200,1001,5,60,100,20
    DATA 0,520,190,-200,750,-3,160,199,10
    DATA 0,620,180,-300,800,-3,160,199,10
    DATA 5,-800,100,-900,1200,7,80,120,10
    DATA 4,800,30,-900,1400,-8,30,70,30
    DATA 2,800,130,-900,1201,-9,110,150,20
    DATA 3,-300,92,-400,900,6,72,122,10
END SUB


' Makes the fish swim around
SUB GoFishes
    SHARED bmpFishes, fishBmpInfo() AS RectangleType, fish() AS FishType

    ' put all the fish in their new positions
    DIM i AS LONG: FOR i = 1 TO NFISH
        fish(i).yCount = fish(i).yCount + 1
        IF fish(i).yCount > fish(i).yTurn THEN
            fish(i).yCount = 0
            fish(i).yInc = RND * 3 - 1
        END IF
        fish(i).p.y = fish(i).p.y + fish(i).yInc
        fish(i).p.y = Min(fish(i).yMax, Max(fish(i).p.y, fish(i).yMin))

        ' We will make no attempt to do any clipping ourselves because _PUTIMAGE already does that for us
        IF fish(i).xInc < 0 THEN
            _PUTIMAGE (fish(i).p.x, fish(i).p.y), bmpFishes, , (fishBmpInfo(fish(i).bmpInfo).p.x, fishBmpInfo(fish(i).bmpInfo).p.y)-STEP(fishBmpInfo(fish(i).bmpInfo).s.x - 1, fishBmpInfo(fish(i).bmpInfo).s.y - 1), _SMOOTH
        ELSE
            _PUTIMAGE (fish(i).p.x + fishBmpInfo(fish(i).bmpInfo).s.x - 1, fish(i).p.y)-(fish(i).p.x, fish(i).p.y + fishBmpInfo(fish(i).bmpInfo).s.y - 1), bmpFishes, , (fishBmpInfo(fish(i).bmpInfo).p.x, fishBmpInfo(fish(i).bmpInfo).p.y)-STEP(fishBmpInfo(fish(i).bmpInfo).s.x - 1, fishBmpInfo(fish(i).bmpInfo).s.y - 1), _SMOOTH
        END IF

        fish(i).p.x = fish(i).p.x + fish(i).xInc
        IF fish(i).p.x <= fish(i).xMin OR fish(i).p.x >= fish(i).xMax THEN fish(i).xInc = -fish(i).xInc
    NEXT i
END SUB


' Initializes all bubbles
SUB InitBubbles
    SHARED bubble() AS BubbleType

    ' Initialize bubbles in a way that the get created when GoBubbles() is called
    DIM i AS LONG: FOR i = 1 TO NBUBBLE
        bubble(i).p.x = -1
        bubble(i).p.y = -1
        bubble(i).r = 1
        bubble(i).s = 1
    NEXT i
END SUB


' Makes the bubbles go
SUB GoBubbles
    SHARED bubble() AS BubbleType

    ' Move and draw each bubble
    DIM i AS LONG: FOR i = 1 TO NBUBBLE
        ' Update bubble position
        bubble(i).p.y = bubble(i).p.y - bubble(i).s
        bubble(i).p.x = 1 + bubble(i).p.x - RND * 2 ' allow it to move a bit left or right

        ' Check if bubble reached top and bounce it back
        IF bubble(i).p.y < -bubble(i).r THEN
            bubble(i).r = RND * BUBBLEMAXRADIUS + 5
            bubble(i).s = RND * BUBBLEMAXSPEED + 1
            bubble(i).p.x = RND * (SCREENWIDTH \ 2) + SCREENWIDTH \ 4 ' avoid the LR edges of the screen
            bubble(i).p.y = SCREENHEIGHT + bubble(i).r ' start below the surface
        END IF

        ' Draw bubble
        CIRCLE (bubble(i).p.x, bubble(i).p.y), bubble(i).r, BUBBLECOLOR
        PSET (bubble(i).p.x - bubble(i).r \ 2, bubble(i).p.y - bubble(i).r \ 2), &HFFFFFFFF~&
    NEXT i
END SUB


SUB LoadAssets
    SHARED AS LONG bmpCoral, bmpFishes
    SHARED fishBmpInfo() AS RectangleType

    CONST SIZE_CORAL_BMP_65078~& = 65078~&
    CONST COMP_CORAL_BMP_65078%% = -1%%
    CONST DATA_CORAL_BMP_65078 = _
    "eNqUyYGm3EAUxvHvUhTU0gUsAgiCwboGi1EBKIFBAAMIIA8Q7CPsAwQLcKFAAAEVtY8QBAvIIxSd/g9QYPUbv2+cc759f/8jWd4/SaWk8Cb9kvSm" + _
    "zzT5Lf34Kv38Ilv+dz4+ZC17ijSLGKNyjvxZ2WT8M0ebYTkejyqKQlVVyXuvuq7VNI1SSur7XtfrVbfbTff7XdM06fF46Pl8KuesLCFgwAwaAwJk" + _
    "AgbMyGbGgPD6PAwYMWND1oYZIwYzYsaGbDbMGDFoxIwN2WyYMWKasGDFjqwdKxZMZsGKHdnsWLFg0oIVO7LZsWKZ1Es4wSOChscJMid4RPQmwuP0" + _
    "+uw9akQk9EqIqOFNjYiE3iRE1PCqEZHQm4SIGk2DFgkdenVIaNGYFgkdetMhoUWjFgkdetMhoW0UJBxQwIFGgQNkDijgEIxDgcPrc1GghINHkIdD" + _
    "icKUcPAIxsOhRKESDh7BeDiUqCo4nHFB0AVnOFTG4YxL0F/26gXlVRgOovgCUjijnf2v9eaKBCNSjG/8/j9CCwI6HB5ZixBCCCH8If6PgQvWCZ4j" + _
    "+q0Nhn96xEimHjDPG9y+Ep4wzLu0vP+yqZzHh2v43HXrG15E4fsA1RYvuiyfqfkd2Gjfl/wa6zIdebf5dRpvGm+DbQC/E4vcAoT8G3hZEADeJggJ" + _
    "BJKfo+v8bJJtIUASIJDvlLKSL3OLNKgf+DQIJAAJoQwkjBCS71AK9H3fZS0R0qh+4h0+/Wc8w58nxlqoVEQIJlV9hm+W53xnnKXSYMg3BEyl6KK6" + _
    "87xfOrZfPi6ExiOA6hcQwv9IrbclR5EYCMP3gGlLXe//rAsZv7YyFFB7mJwTBTbQ36Rs/r7DPxP7fK7rfz4fqB799ivml/h1kjaWOO/7g19Em2fC" + _
    "tA3C9n/0o33VP23jJjrF7vB/FU253OSHnvl9KvgZYE4/A+21Mr/d/KL8Hvn4Cb9flpIYLwHOCLkBuFr3gCN1DoXP838HR70QyhRYrRPPa0vRzlmV" + _
    "Fz4l6NTCT727E+7X+Bgv1vx68euEXOcLF4rATULQ3C8Wfkfewa200NOee1eJ/aaW5C6glWryZWFF3cQOytJvhG71mQ+vK/jRxh95KlrjWXb+z07U" + _
    "Ogt2ZLYua5PR6LlwhNLHE7y561oW2fTTa4YP5awffnGFPZ2l+wEYCz/aJzDJaYnYldql5coPKI+RgmaA/W7861QwEgOLtjnpwZrPQ4hTfO43rfBT" + _
    "pl/YfcTCj6VFoyYzfvEz+0BrW7ubn/3DiX8WSfyUhd9vet2UAlTbWich4wUUtD/4QaV0P3aO5ueAr/UTHjwgtd90j5eMsSOGnfnR5dfMqV37pbiO" + _
    "2aoJOKe1jjGvcNY4R+gKu7L2Y2/hRXQ/xd8Z86XRnjQooLUQQ3sG6X76R4J1D/HiN7yAC78bUPWTUAkexVUzymHxYc3QF062pgGASC8gPRuvfixi" + _
    "24ov6JX1r+LDbNn3B79qYFQe+aafsvRTJJJXGqDAFHCvrXsXx8fofumL8uh+SvcD0P3CIyUBoVcbu2tqXTmOfPD7Hl8/9SNf9+NTersTERsxP/EB" + _
    "KB8JCcwAxcd38MVnfmPlN5qfEt0vmh8J4m7PXqrgXH9vrkb43bbveYVSR9X7pX86OFfwRTQ/eaRg6jGQaU738xE+Ds5hfp1PCaX5tQdDJsO5Hs6B" + _
    "yhUvYXsWYc38ut2Nd55JhuU2eiyg/ksNUH4KflZA+QkwDdC/RdhDB8sPsz7Kjar7KV7AhZ8BKpndq2T1WcvZbj/v3q2XWTk6YMSDX01E81PwK0D8" + _
    "FAfUZj3q2VRvBDPdDjXjmlemhPttklLwszS5BohfGuEmPyTNb98LTnaq3jHTG6g5dT73K0D8SPOja8QE5ZfsYayP5jcU82MHgvjBQNX6wC8SRFR6" + _
    "UxGOrQAj4sVPzRNaRcvJBxI3/OAX+AnQo4cTAPHzFKD47Dlnm6mZ5ardTynkPbQCcO3nQx0V9nNRVWUzYl4P4PzQw84LyDgWH7ccyoPf0Pq+VhNU" + _
    "BbEqI8UFy++TiR+pEqdpxLufAHf3G7O92zYeW2d8sROuqh9+5afqVe0KsRY6kZ0iNs5jfsSe9Btgng2QiiEIYPklqvDpBAu/IHWEW/VPQH+2Gs7m" + _
    "Lu4HYADo2EOZfgyusAqPxXmenGj6kYjN/Ij7OWCcpwCFZX4mqEV2vvIbCz/F/QK/PsD1DhvbDqiNuA6VnwC1Ukbzu3J8zxQfcjDe5zqvBBodUPVb" + _
    "+PHdUX4KgvjVhwV75tduTr26ViCjdD9l7Qf/4JBi7nW/NqHulw7e/baED2dL3H5RbWoHeWfmX8Ta0a7COg6F4XtHqjDy+z/rSLjur7UX6amYoxnf" + _
    "UArsNN9OmjhpZLpfdoxfDKCmIi0FIBErKPLkU78cIvzObyGCX8cppH64VU0ieAJZWh/mZ/NJ80vlm+LX+PEJpaVGhAKSinwHPP9l/Fn3e0+d8Yvz" + _
    "S/ihhx+TD/zyanfzK9kj0EXDRG2Zn0b7xSds7tmXS3c9QkbJxT82AsAWnFSkg3EYvnzgJw5bP/hITRh68OvmPATF77osejtqZuLt70D1uZ+FAtKB" + _
    "+6hDtiml/VH9BFDnH/jBR1ICILo1oYsNyRqj+2W7AXgbufHrE2F+x2F+xPhFnIA9gJD0XoT0L6vJdFeZU0zvi70fIX4AMirOa823WXrw+54Fuk3S" + _
    "gOdpmQLFMz9i/D5xjSEMxZPERZeX/K+pPZW2CvjwoX6J3/JbZ42b5KLdtJ/7yUwo8RtXspy/fvNl/Dzwi9k511XB3sX867fMbyqe3/wqk6ka6V7m" + _
    "HpDFBvxaLWdUbzGmggq4m48fHfhlh/l9LiHwW7nxa8D6RDdChpKOeOynN5bxET/ZqpMdzy6BoWe6nPt1lYItRgALMVsKgu+4/jvq94bvwyl+yd5W" + _
    "FH4NWGfgdwFOTVYCiN+HvbLoBsNX0/zGr06/cUsAy3O2/p9081O/9SYc8OKzpaA8iGs+rn7wDSB+A1i09DC/im6D+GUWZVXBB2BELvFjR1j9rinH" + _
    "+LFfCOD5nzK/nix+9gQIRhOd+5lfLvA6+qvhfhHlfswz1Q9AfkQyPHyoKF/zREgmP5d++dIk1K8YiCpltPj4ZeFX6rdWnnp9tDTS/I6OPph36gef" + _
    "+4Es94igAQZ+LdhhfmV+efHoUiS+/jzbyAKYGKvfEr8ZhomWlBM2Hz8usOwXTkR482uMcD9i4TeAgR+CaX75108v/PKjg+39DND80v3SuOQqJJ/p" + _
    "oLW1HzPpY9FyTr/QuPFjRGIOExIMifgVfLYQN37w2VMtoBkgN8Fz+wu/cj+imANRP/yYsahflTacO78wPiqMH+2W9NqSc/FbNoxl+12fa3ufHjV+" + _
    "AshiSp2M+HXumywcEpVM0QUwc/iKLjB+PRgCGO4HYIQCUpYCTkOGDzWiW4v4pUYOn85hs680+TxEcONHsecLgtM0pU7zZuo283H85mqCljN85tc4" + _
    "u+bH3TUYX9DTccP93vPBhm/zVMsgLAHkkfJk/pbuN4Yz0ludWK6Fr2fM0v4iYjUgfO7Xxjp9Ub9qQL7ReOIHoCavl+6Gb/y0bSR+DZgA3vuhONOZ" + _
    "5hG+62KnVmwxcf9rvzV+b+fD7+Bv0Boias4KIFI3fmuUtn23+fAj1E9SkncOGsUCeP4yczjnglGuiYtPZ77q1w1w8JSPuPwkG2Q7qVZdfmV+VpNh" + _
    "Q2mYjG+7ig7f6QdgfN55SssPq8tpQLwVMD986xxHEr8GrMQPvkd+C772i8kMjY831ORqfyXzNvTg2/q9/bGSpAbB90lp+eG0AvxqESxlfJw69n6h" + _
    "fnHnF3Ip+JFZczFcvNWkeWSG3E4gAKhyMJg8lWD095S2+eosTHb0JvCDr6ek+B2/+8EX+JHQqFd4TfAbwATwLbF2kbgPoN/Bl0a6X5fKTRq/E6p0" + _
    "la/wO0rLdD73kw3jBo01lTg82MnRwK/Eb/SI7So67c8AeVZH9fDTLaYW03X+ioj8TFwiZ5euoyb7Zb6ssfeLiIsvuuyIvgD8NL4BZuL3AaQmb4vN" + _
    "KjoZL5+EAja1p7Tvr1tMqe/Wh6/9skr8BlD5iCd+LL+wEr0F/FuTN34dtA0PrT1/oSPXDrDSw7eYnG92i8fvGjVnqMQPPo2nfrKflheYcnpNuvZe" + _
    "E+VL/GwV/U1EFX4AeqHc7swv4MMvD/yKxy7C/Tz28+cgDxA/VnhYotY+bH5Wk4FburXhq+j4afoXANbej2LPAbHELyL++sXpF5mNca4bX1wuqNG5" + _
    "7SeCBi/Tuzr58ENw46c1If1aOLof0EQxG7j1q5Qturz8Ar5sv0np26/P0Jj6hcZmRxaXX278TqmVK3P4doD0yzQ+WRq486vi6szPACUpTiKyKjOo" + _
    "zfida/QROYCBX7/SVznaAm78BhCotfCLuPOjLsLHg2kpfql+qYD4BZt6bVGEFNowleYX3fqaKpsuQ/1Q4+AW0PzIz+CjF+i+gUzgCz/4ZKNIhpC7" + _
    "ByrF7/WSBrjho1jG1By/torm+1jFygyJ4YtWe+p3DlOalplfqV+uZFzJMr/lfD6R2T1QGUuuLuL0C/cr0nJi68d+RL8Q3vwOII2PU9xj3K8KPl+m" + _
    "yzoBk5rIzA0tFosV8OsDlbB3mN/wdTKx90Ov/VrPAfEL8TvE7+1+7J8zXVY/+JIuwgMbMo+Oyy//+Olm2ZvwgRo/IgDs96PXfvCR0sKXJLls8qb7" + _
    "cQK/w0ePeZ1ftB+A6pfw+TIdV1Q1fjWrxMqnm2XIfB2oYw7nTDTg3o8UOmaPyvzYq9j7yTDVOsrnfrHz68MbPwClJcyNqRXGwzYb628Kx75bzNGc" + _
    "CgADvrO0ztbNL9Uvhq8PzI/3+AV+8EXs/Xw/jbzN9BZTUWpSUdM0RsH8JsaP5OHaZqNzSwMkZn5sO4GSkvXLwg+nR37x0C+6iFoGyNa8RwLIhIyu" + _
    "ReXbL2LjN2F+xcIpfvC1H3wrmk/84vI7/tkvJmC79ZvHc5f7FXz4iW6q3xo/1rLfW7984rfUD8CWMb88/UL9Imh+ez9vfrBxTk7yk42f8cHWL+K3" + _
    "Nn45O/gNyI3S/Jgo0v4iNn4R6tegjByamO39nG/jx2HAZ34A4gcbiMTlt4LUCYWpg0852ohCze+tfq9JQhpG/TKTj5BzH/Nzvr2f/0n8ov0ArITP" + _
    "lun2ftTk3i/inFdHF6h+XC5+8dUvWOJ3uTu/OIKAb6dmfOr3uR4FpPn5Mh292P0CvynTphwJaGTaA5XuF68I9SOSE/Hczz4VQJH0ML8+IC6+VD8A" + _
    "q/CrhV/s/WIzUOfV/PK8T5rfiyZoSBRL/OhHUPjx2A9A5n7m1ydOQPzo1VK48AV+gPJAKn4fwFfwV14vvQX+L/02nx34yY65+A3XyYff9bz4M7+8" + _
    "8esXGWf7ei7AOYwbv/w/+AV+Dfhhgk/8OmQrEL/CL9P95jR+gPYn9HaQ0JIDj//W7/iX/KryCvfzncGlfuGA0nvN7yNifg7ofi4Yv/sdv/gd7jd8" + _
    "+N3sDPZH7ZenX+BCuB89Dr/47teHL/w4tPjFD75f/QCs737LdgbPVxpgXmPQjV86qPsJYM9ZcOxPXr/7OSASP/gF0YDf/GoJILPgxO8YP6TuAWFu" + _
    "DvNrNgybtF/G8l/yO/7Z73joZ/c/3ZkhpiOLXwDlsfd7md8YQRY0RDB/87PM7V/0Iz3Iuvx8Z/CbX5ifAaomgN/8YufHTBDEZ4B7y9/9iL98VZdf" + _
    "/t0Z1IdV65mfhvuF8NFn6czWfUXwZ8v4Jz/53PwI92vAzEXgl7nwm8DvCaErAPpCks7M0e+CrmAUAvh4xg0ffgcN7ZlfPOUDwv2gYQCBUvwQ/NHP" + _
    "LDx2fh7oSfvLYm01I8Wvij/1n/btYMlRI4ii6J6F4s7//6wXbibD3Mh5kZ0j6AirNkYATPvoFZUUaNAKCGhYy69IL34+fsj3br/LNEnj9w1AKmcg" + _
    "vlpwl8ZfwYbPGAu/Kk/Ogf1X8FP9OU1ffSiMvmNT7mDqp/2K76yMLn6/39U8Vn7AJVlWU89El0MftLynm/uZ7yi/4vvy+/W3/E6cCpMouMLabwfo" + _
    "WxLDZD9XZcrf71GkqpOad/2OX9FhCaDogOQ3L6d7tdfZGugj+1Uhc/odX35NdTf3o9TkJx1qBXWQqz8WfAVnwDRlKL7y+wKsbfLT6aeFX/Y76ILH" + _
    "AWs/AZ7La7+jTqhn0is/7CcGr+QCD5y2004cprHEM/Krdr4tp21bPw8QI79S9/5zv2AW/ASoX8ZVAI+Vn6sS+rsPL9pPYAlQAFolNC3ma779vOfC" + _
    "Dw7M2fsZsPx8oiGfVjZovXTk++VdFwOw+ywHql6whf0cOHZ87rV/Ojr7nT+sebefR1qMcXAgOe+z4BNgv0/0q6NzAEOaVRnXf/2MiD/h4CvgJaos" + _
    "+MJNnfSyn08Z0hya5pZLpirq2gT2CwEEYMfnFwW92XP+bn0xlOOc/PxMFwvlAPYXwN3lxn7ua8Ev14/2C7lWagqiVgC1AQP2vMFPAsNZLR2cz+FP" + _
    "mS8ogv3gWg5jQPtZCwQeO0sA7K9UOVL+HPwCIAAOC+VSnBYBgBqZ7WvSvl/l8MToJr94Rp1TnLXOHpYDEWAdPG9F8hPfxM9He9k7Bj9xNWtjPFBN" + _
    "GPwOvCHO4wsg+71iUkZ+uZYcDXLiG/gJUD05u8z9xPeX/NRXM6B86NRAPV6LCmHulgu/Y+E3K8YzoDiEBp7ah9YLMt/WTx+zn1bppFM/jSU0qvYz" + _
    "pgQzyuu7fkEk+PVG3wAEWUoVLqvyAw+ySZ5vyxd0r4i0cz+trtkpJ06fzr3QE6Q2bgBEkuwX46c1C78w4usar4sX7aBSlpw4xLiRb+ff7nfkE9gv" + _
    "HgJh6PAtnlCJWkqh/pCdXzyP78miXw4g/XiBQXq/bwbQlceb/dQWfq7r4l0/evUA+PJTTZj9Xm/xO4KfAI/Yf9Xs51cygIaAptIGh7oakS93371f" + _
    "iKr8+hMZA+wz8XN+/dlf4tpv+2w5+zUBlAWen3KmBIms0wVQf9xi+Fj4hZo8nFwUjUScQqBfl+fj937rh/Nv9SMD0s8UDDgi3xv8wk1dmhNXeDCf" + _
    "Lncq5/DWB/0y4MQvA2qSGW+1mVUN+PP9fB3R8OGWOjFNOAUESuLCL0++7P1yuSO/IwgWgd68Sn4HWgvV1sPHqNLYAfZ+TdEd4tfdbxhQUt2+OX7P" + _
    "+GmV/GJHoOLj7tuiCFy9mUn8EmD229fQg1dFushAQWC2Wms/CzOIX/B7rfzyPz3wEyApfu7UrR/f9otPfjq/OaAmzeyX74+dJ6RTO4mo81NWM19+" + _
    "/UCbV35Otf20lCewQDqXBaugorr57UL0C9Md4Wq+4mv+nBDARgmrqYCG9tklGrCDnx433OvXfp0J8Bj71Wat0EcY+L3i9Tr4LfhavwQ48dNS76er" + _
    "ASS//AQ9vfj3eo9f/obwvQLOTinYD0VMc4Nrv9cdfu6d+Z/Qg1xNowqyQEElowM4eg25NzqC3wBwEHtHML/1DH/8ARaeiTYg4xIs3161GwW488s7" + _
    "20+pgdavuWYqgqH1F+i537HwCwELgJgEXBebA0KJnf/0UAqGnOTKOvNd/ebzj3gCv7ozftVPQudWL4+++jgZkv2mgDqvCANg03MrgM5ff6x3Hfml" + _
    "eemkm8OTSwALhkM0uvq3qEpT5oIH/I61X37e4WOUod4PmtoxV5S570S/oBvLwEEJGqJcG8sFSH7KlXZR+Q1Lv/6jN8fkLEp4H6T8gfte4TQgWlVB" + _
    "ZV4+Z7+weeGngioE0P2X8MLpVSuMK8xmT6Ofjp0WcXs/72c/unSBaxlfAV2S84BfAAznSYAGKj9JgJKY8nc5VQac+hlfZdx9fkfvB2AGiMMsl1N3" + _
    "zQQTv6wZmqnDCJIl0Urnj1pV8OazvNtb/DJg39fXfp4EUIzgAq7Qrv084Oar5xzQj/tyAGP+Gj9PVyE/5W8DOK/c3C/jGYy09vPDW/7Fo+/wRD9g" + _
    "ei2a++UAmsq7Tf002tL0aSZ+nte6xW8AqB22fsB/ODwtLaXGD1AH3gFmPydwxTfwS5P2QPDzFp8ntmXlGwag0PZ+oKchgMeUZhS5+oGnV2MgRpWv" + _
    "AijAe/2UqpIAa5e3jPBLHVEwP8QIHdhr1gEc8pnRJV7ov0ry9HHSpA/7zt8zOrc1cLgONMTaz2N24U/98v93GA0cwJsaBdiEi8bPd8ff9lsAPu9n" + _
    "wMqfEhruNQYdWH6hDyd7m97SfBsbI2Q/AIzqScM+RALc+N0BCPrlRi9mBi5Up2N5jgKYLv7Z75kOLD9xyUBzWXHmL/ttfpFg9qf90LCifRRA5e2W" + _
    "6rWJ7W1+9H4RUAHUlvsAPY11a/yQ6eTFNLziZsA8h3Bbq4FUrnYx7Mevuy6CYILXXYC+fXvSjwaG4+f6me85vwYQLJUr5Ns6sH9R9EwLv4ELQ8jT" + _
    "7UvvYT8qWn709sP9nh5AsFotPR/AzPe0X1MJc3z85n52+8F+zxeAxrDbaLj9+KmsyXYfP4CWdA74yd/Hb93+R34fwNfe7+P3D7y729Y="

    bmpCoral = Graphics_LoadImage(Base64_LoadResourceString(DATA_CORAL_BMP_65078, SIZE_CORAL_BMP_65078, COMP_CORAL_BMP_65078), FALSE, TRUE, "memory, hq3xa", _RGB32(0))

    CONST SIZE_FISH_BMP_65078~& = 65078~&
    CONST COMP_FISH_BMP_65078%% = -1%%
    CONST DATA_FISH_BMP_65078 = _
    "eNqUiKENgFAUA+8nCKZAYzFfEzyyS74xUMyEoIQ6JNe0yXXb+03oA8zA2uAEGiPhgr7AMeX8TVU2QUVVIQlbSMZv7Y8rbgAewuQI2mEYjKP432nw" + _
    "sBAsFAKDwCBQP5VCMViMn8Kc5qcw92KwMKdCYVj3vPs5DH5X7t/fn5xz6rpOIQT1fa9hGJRSUs5Zz+dTr9dL7/db27bp8/no+/2q1qoqIWJBAcWC" + _
    "CJmIBQXVFCyIv/eyYEXBiaoTBSsWs6LgRDUnClYsWlFwopoTBSu2DTsOXKi6cGDHZnYcuFDNhQM7Nu04cKGaCwf2TVlCg4ARFAENZBoEjMhmREDz" + _
    "e4eAHiMSshJG9Aimx4iEbBJG9AjqMSIhm4QRPYYBExJmZM1ImDCYCQkzspmRMGHQhIQZ2cxImAZFCTc4eFA43CBzg4NHNB4Ot9/bObTwCIgK8Gjh" + _
    "TAuPgGgCPFo4tfAIiCbAo0XXweOOB6IeuMOjMx53PKL+qbGXHNd5HQjAHLeFAsJRrSdLyFKy/8HlKYQQ2KYd3R/uV8mS8jjPD6UYnZXoXK6HthqQ" + _
    "hP3HYIxhF2Xb3H5NuGjIqYfM/8cHXIN3u21Wsrn/AT6kHZgR4TrfroHAAHKu6kUqXvDxJ/2onQt84AyoBYt8EGHpycAcYzjqb/DD8t18vuCB5/Qf" + _
    "5XuvBxIfO7x1QPHF9M+oY06vbR2d3u0fn9fu0SP2tQEIRZtlxEZt7/hYA+Zy590UnPIN8TWmOb3qDW/5Yljl29Xv6sOMZCNyTUU9l+A6H0g0BQS1" + _
    "94H4hmu05UsuuSrd2Y32+VaoIiztu6yMILQdhMjQlvlALdMPmi1fWvjpiEiytq+p3y0Orqaih2YeW3Jdzkeg13s85kPY26SWtvJYkR9I9sfW3462" + _
    "feMzn8S06HrlGbPyXXR6SU4jzZOstA+cay3gnWYksddzXwKsx7qr3014z4ALuti16GGQTkBX7JI0tTt7es5XA12lfo2fuyMBl4fS8slMfsGnTY4x" + _
    "t8JHuyh7JJI6u73h4mdfU0KD1hoqgwM+WRYJGz75hRZJAQoz+AQYM8vndl0KFEkAxJu8aR/qA0VWRMM3BrTE0CUa8HgOfuZ7iik/9ugaek1yW7wf" + _
    "U29eWT8l6TIUY77UiZ3qIZfaP7R+IwIqIKQCTTg4eDx39w4dV/G5k3RGXC8Fmz4UxccXoF0NmCGFNyNHO+e7g/0BBjMA+/5lBpJQizt4MvZ+edvY" + _
    "Nul5DIaWqpf9i/f5NQf48XikFaHK5POF8t0jO0IWwkx38jF85K8FUxDuJ4DFb55fHWDPePCpeipg8FnE/foTHHoUoEI04aEecVcwyTTKxXRs/gQP" + _
    "CydH4gyk4Hn/3Gb+QclPB9bd6R5w8Zqqt8X6tIwrV/oR4AMpyMgsn2LGyHH9lOm0LyM+PqC9qf/gGCRYeGIScwASM8z+lQO8vXITmejCLPLUFtOn" + _
    "2NUNfPn1MYDGQ/vip3SKE/DgaytG0A28MJGFA8NbcauA5MtQtwy5qXvqn0e+qoHz+D40c1HxTHrkISBCrh7gXKqhSkzrAvBgCE4LfBb2FSuAfD4p" + _
    "sVq82OKhs4pd2MC8fTSp3/3xEBCpV8SKnwAhxS5weKUjBNV9pdr//CG/rJwWPZEi3Sm/IngJXtWqT5VSvyb1BjzV5gu5WQWsgQgRoYbUUtCtBD2g" + _
    "+GQnOD3SGn6MYV+VwmWoT5v6tR+B5f5b7ZT7CWClSTutaHuC7gQr8/zqmfhIutvPhVbSA/bHt/TQIrDzyE08LV09xN4AptszLelO2s8CRt4Aovkh" + _
    "DoX0ztXT0Nt1FbSaANMlOZ1e0smY9puDSgcWv7nZYjq8XtCtEUy92Jx0p6l9vziNH5KwfP59R5xOXU7t5vbbg6OffUsf8V1+dHoCutkfADz6+or4" + _
    "3vopHsPoNP8LeAra4/sj9VNcl+bfSCL9j906yo0UBoIw7AOEp+GhzuOj1ck3pdaUiA3pJGSl9U7/GCvjx09N4NmHXzlfZSzP36DYqhQw7nELxpZW" + _
    "gLMavsVXgoPhDb2awVt4NYM/1StC98/iVVVVVVVVVVVVVdXbW2+/G/BCdlq/Kki+Cp/gvOKgd60avjxhKdENnncUwRfBk9Le5SeyuI7rZ4LEa+AF" + _
    "3x587rYgzAcisyTJZfU8fu7csX2x7SE0MPBIGM8nIA6nBNbVU3233zVib12leke+afIIUvdwtqLegU9+Brw07F1bT/lMYqfjoFGi6/MFlv2GARww" + _
    "PYS6Mj75iQQjFPzcrv+eEci+X/l1NWP2uBK/LfimqRIeqePVx0+JTzL2M6DfJzNmDhjjR2oNiQ8nfGhLJj8xjX49Dgzovw2Y+pGcUQDilI9tzfY9" + _
    "ZmsXkQG1xcHBz7ZxJc/vMWxO4USVbVVAiQx+XR3NPJwpX3Qhh+c2jh9hv0VfIld++u2n+4t8g9vkOACSINnWTXwxhEpcgeYDuWnTSv/7GQwHuofD" + _
    "+4K2zXxYeP48gwa0lkUl5qVv7oTPajAZtHl/CDCGkKQ/aFYXVD1Z7fPeWUhowCT0tAu2cIsLz0htqi1fzpf4CYQAPXrwCjqoR2yOJP4PwEu1WC3r" + _
    "ofHbwMfmUQO0SzAMRzxFf1OvXjfWtVry5iU1fxKD7gC05AleCKpWCdB88PQh1ly8QcJRftUWAdvHx/cUT5kwBrAChCfBTXw4bbKiRSsgDK8iz4aN" + _
    "LECHz/FmQMXDYXWJZ8C58ruIMNwMWOWRQAHeE/xFwAJEAX4/ocVNeQIFeKP65LtZffLdjyiDv9if9uBAAAAAAADI/7URVFVVVVVVVVVVVVVVVVVV" + _
    "VVVVVVVVVVVVVVVVVVVVVVVVVVUVMAay6g=="

    bmpFishes = Graphics_LoadImage(Base64_LoadResourceString(DATA_FISH_BMP_65078, SIZE_FISH_BMP_65078, COMP_FISH_BMP_65078), FALSE, TRUE, "memory, hq2xb", _RGB32(0))

    RESTORE fish_bmp_info
    DIM i AS LONG: FOR i = 0 TO 5
        ' We need to scale these as well (always 2x due to our image scaler)
        READ fishBmpInfo(i).p.x: fishBmpInfo(i).p.x = fishBmpInfo(i).p.x * 2
        READ fishBmpInfo(i).p.y: fishBmpInfo(i).p.y = fishBmpInfo(i).p.y * 2
        READ fishBmpInfo(i).s.x: fishBmpInfo(i).s.x = fishBmpInfo(i).s.x * 2
        READ fishBmpInfo(i).s.y: fishBmpInfo(i).s.y = fishBmpInfo(i).s.y * 2

        ' Make some adjustments to get this in a sane format
        fishBmpInfo(i).p.y = 1 + fishBmpInfo(i).p.y - fishBmpInfo(i).s.y
    NEXT i

    fish_bmp_info:
    ' left, bottom!!!, width, height
    DATA 0,199,56,25
    DATA 64,199,54,38
    DATA 128,199,68,26
    DATA 200,199,56,30
    DATA 0,150,62,22
    DATA 80,150,68,36
END SUB


FUNCTION Max& (A AS LONG, B AS LONG)
    IF A > B THEN
        Max = A
    ELSE
        Max = B
    END IF
END FUNCTION


FUNCTION Min& (A AS LONG, B AS LONG)
    IF A < B THEN
        Min = A
    ELSE
        Min = B
    END IF
END FUNCTION


' Calculates and returns the hertz value when repeatedly called inside a loop
FUNCTION Time_GetHertz~&
    DECLARE LIBRARY
        FUNCTION GetTicks~&&
    END DECLARE

    STATIC AS _UNSIGNED LONG counter, finalFPS
    STATIC lastTime AS _UNSIGNED _INTEGER64

    DIM currentTime AS _UNSIGNED _INTEGER64: currentTime = GetTicks

    IF currentTime >= lastTime + 1000 THEN
        lastTime = currentTime
        finalFPS = counter
        counter = 0
    END IF

    counter = counter + 1

    Time_GetHertz = finalFPS
END FUNCTION


' Loads an image and returns and image handle
' fileName - filename or memory buffer of the image
' is8bpp - image will be loaded as an 8-bit image if this is true (not supported by hardware images)
' isHardware - image will be loaded as a hardware image (is8bpp must not be true for this to work)
' otherOptions - other image loading options like "memory", "adaptive" and the various image scalers
' transparentColor - if this is >= 0 then the color specified by this becomes the transparency color key
FUNCTION Graphics_LoadImage& (fileName AS STRING, is8bpp AS _BYTE, isHardware AS _BYTE, otherOptions AS STRING, transparentColor AS _INTEGER64)
    DIM handle AS LONG

    IF is8bpp THEN
        handle = _LOADIMAGE(fileName, 256, otherOptions)
    ELSE
        handle = _LOADIMAGE(fileName, 32, otherOptions)
    END IF

    IF handle < -1 THEN
        IF transparentColor >= 0 THEN _CLEARCOLOR transparentColor, handle

        IF isHardware THEN
            DIM handleHW AS LONG: handleHW = _COPYIMAGE(handle, 33)
            _FREEIMAGE handle
            handle = handleHW
        END IF
    END IF

    Graphics_LoadImage = handle
END FUNCTION


' Converts a base64 string to a normal string or binary data
FUNCTION Base64_Decode$ (s AS STRING)
    DIM srcSize AS _UNSIGNED LONG: srcSize = LEN(s)
    DIM buffer AS STRING: buffer = SPACE$((srcSize \ 4) * 3) ' preallocate complete buffer
    DIM j AS _UNSIGNED LONG: j = 1
    DIM AS _UNSIGNED _BYTE index, char1, char2, char3, char4

    DIM i AS _UNSIGNED LONG: FOR i = 1 TO srcSize STEP 4
        index = ASC(s, i): GOSUB find_index: char1 = index
        index = ASC(s, i + 1): GOSUB find_index: char2 = index
        index = ASC(s, i + 2): GOSUB find_index: char3 = index
        index = ASC(s, i + 3): GOSUB find_index: char4 = index

        ASC(buffer, j) = _SHL(char1, 2) OR _SHR(char2, 4)
        j = j + 1
        ASC(buffer, j) = _SHL(char2 AND 15, 4) OR _SHR(char3, 2)
        j = j + 1
        ASC(buffer, j) = _SHL(char3 AND 3, 6) OR char4
        j = j + 1
    NEXT i

    ' Remove padding
    IF RIGHT$(s, 2) = "==" THEN
        buffer = LEFT$(buffer, LEN(buffer) - 2)
    ELSEIF RIGHT$(s, 1) = "=" THEN
        buffer = LEFT$(buffer, LEN(buffer) - 1)
    END IF

    Base64_Decode = buffer
    EXIT FUNCTION

    find_index:
    IF index >= 65 AND index <= 90 THEN
        index = index - 65
    ELSEIF index >= 97 AND index <= 122 THEN
        index = index - 97 + 26
    ELSEIF index >= 48 AND index <= 57 THEN
        index = index - 48 + 52
    ELSEIF index = 43 THEN
        index = 62
    ELSEIF index = 47 THEN
        index = 63
    END IF
    RETURN
END FUNCTION


' This function loads a resource directly from a string variable or constant (like the ones made by Bin2Data)
FUNCTION Base64_LoadResourceString$ (src AS STRING, ogSize AS _UNSIGNED LONG, isComp AS _BYTE)
    ' Decode the data
    DIM buffer AS STRING: buffer = Base64_Decode(src)

    ' Expand the data if needed
    IF isComp THEN buffer = _INFLATE$(buffer, ogSize)

    Base64_LoadResourceString = buffer
END FUNCTION
