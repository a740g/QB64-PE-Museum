'Perusasetukset
RANDOMIZE TIMER
OPTION _EXPLICIT
_ALLOWFULLSCREEN OFF
$COLOR:32


'Dimmit
'------

'Hiiri
DIM mouse.square.x AS _UNSIGNED _BYTE
DIM mouse.square.y AS _UNSIGNED _BYTE
DIM mouse.x AS INTEGER
DIM mouse.y AS INTEGER
DIM flag.mouse.down AS _UNSIGNED _BIT
DIM mouse.button AS _BIT

'Muut
DIM t AS INTEGER
DIM tt AS INTEGER
DIM t2 AS INTEGER
DIM tt2 AS INTEGER
DIM screen1 AS INTEGER
DIM turn AS _BYTE
DIM winner AS _BYTE
DIM center.x, center.y AS INTEGER
DIM winning.text$

'Neliot
DIM square.width AS _BYTE
DIM grid.size AS _BYTE
DIM play.x AS _BYTE
DIM play.y AS _BYTE
DIM maxVal AS INTEGER
DIM x, y, i AS INTEGER
DIM maxIndices AS INTEGER
DIM winning.square(2, 5) AS _BYTE
DIM square.value(grid.size, grid.size) AS INTEGER
DIM square(grid.size + 1, grid.size + 1) AS _BYTE

'Paavalikko
DIM mouse.hover AS _BYTE
DIM grid.size.option AS _BYTE
DIM menu.option$(4)
DIM window.size.option AS _BYTE

'Asetetaan gridin ja ikkunan kokovalinta valikkoon
grid.size.option = 1
window.size.option = 1


'Paavalikko
'----------
Valikko:

'Asetetaan gridin kokovalinta valikkoon. Gridin kokovalinta maaraa itse gridin koon.
IF grid.size.option = 1 THEN grid.size = 14
IF grid.size.option = 2 THEN grid.size = 20
IF grid.size.option = 3 THEN grid.size = 26

'Asetetaan paavalikon klikattavat tekstit
menu.option$(1) = "S  T  A  R  T    G  A  M  E" 'Ensimmainen teksti

'Toinen teksti sen mukaan mika kokovalinta on valittuna
IF grid.size.option = 1 THEN menu.option$(2) = "G  R  I  D     S  I  Z  E  :    1  4  x  1  4"
IF grid.size.option = 2 THEN menu.option$(2) = "G  R  I  D     S  I  Z  E  :    2  0  x  2  0"
IF grid.size.option = 3 THEN menu.option$(2) = "G  R  I  D     S  I  Z  E  :    2  6  x  2  6"

'Kolmas teksti sen mukaan mika kokovalinta on valittuna. Tama myіs asettaa nelion koon, joka vaikuttaa ikkunan kokonaisresoluutioon. Nain voidaan valita mieluisin resoluutio sen mukaan minkalaisella resoluutiolla pelia pelataan.
IF window.size.option = 1 THEN
    menu.option$(3) = "W  I  N  D  O  W    S  I  Z  E  :    S  M  A  L  L"
    square.width = 30
END IF

IF window.size.option = 2 THEN
    menu.option$(3) = "W  I  N  D  O  W    S  I  Z  E  :    M  E  D  I  U  M"
    square.width = 50
END IF

IF window.size.option = 3 THEN
    menu.option$(3) = "W  I  N  D  O  W    S  I  Z  E  :    L  A  R  G  E"
    square.width = 70
END IF

menu.option$(4) = "Q  U  I  T" 'Neljas teksti

'Asetetaan naytto
screen1 = _NEWIMAGE(grid.size * square.width, grid.size * square.width, 32)
SCREEN screen1

'Asetetaan ikkuna keskelle nayttoa
_SCREENMOVE (_DESKTOPWIDTH - _WIDTH) / 2, (_DESKTOPHEIGHT - _HEIGHT) / 2


'Paavalikon paalooppi alkaa
'--------------------------
DO

    'Hiiri
    IF mouse.button = 0 THEN flag.mouse.down = 0 ELSE flag.mouse.down = 1 'Tyhjennetaan mouse.flagit

    'Kun hiirta liikutetaan tai klikataan, tehdaan asioita
    DO WHILE _MOUSEINPUT
        mouse.button = _MOUSEBUTTON(1) 'Tarkistetaan onko hiiren oikeaa klikattu ja tallennetaan tieto muuttujaan. -1 = klikattu, 0 = ei klikattu.

        'Tallennetaan hiiren nykyinen sijainti muuttujaan.
        mouse.x = _MOUSEX
        mouse.y = _MOUSEY

        'Lasketaan mouse.hover, eli minka valikon paalla hiiri kulloinkin on
        mouse.hover = 0

        IF mouse.x > (_WIDTH - _PRINTWIDTH(menu.option$(1))) / 2 AND mouse.x < _PRINTWIDTH(menu.option$(1)) + (_WIDTH - _PRINTWIDTH(menu.option$(1))) / 2 AND mouse.y > _HEIGHT / 2.62 AND mouse.y < _HEIGHT / 2.62 + 16 THEN mouse.hover = 1
        IF mouse.x > (_WIDTH - _PRINTWIDTH(menu.option$(2))) / 2 AND mouse.x < _PRINTWIDTH(menu.option$(2)) + (_WIDTH - _PRINTWIDTH(menu.option$(2))) / 2 AND mouse.y > _HEIGHT / 1.91 AND mouse.y < _HEIGHT / 1.91 + 16 THEN mouse.hover = 2
        IF mouse.x > (_WIDTH - _PRINTWIDTH(menu.option$(3))) / 2 AND mouse.x < _PRINTWIDTH(menu.option$(3)) + (_WIDTH - _PRINTWIDTH(menu.option$(3))) / 2 AND mouse.y > _HEIGHT / 1.5 AND mouse.y < _HEIGHT / 1.5 + 16 THEN mouse.hover = 3
        IF mouse.x > (_WIDTH - _PRINTWIDTH(menu.option$(4))) / 2 AND mouse.x < _PRINTWIDTH(menu.option$(4)) + (_WIDTH - _PRINTWIDTH(menu.option$(4))) / 2 AND mouse.y > _HEIGHT / 1.13 AND mouse.y < _HEIGHT / 1.13 + 16 THEN mouse.hover = 4
    LOOP

    'Hiiren vasenta klikataan

    'Uusi peli
    IF mouse.button = -1 AND mouse.hover = 1 AND flag.mouse.down = 0 THEN 'Jos hiirta klikataan, hiiri on ensimmaisen valikkotekstin paalla ja mouse.flagi = 0
        flag.mouse.down = 1 'Asetetaan mouse.flagi
        GOTO uusi.peli
    END IF

    'Ruudukon koko (grid size)
    IF mouse.button = -1 AND mouse.hover = 2 AND flag.mouse.down = 0 THEN 'Jos hiirta klikataan, hiiri on toisen valikkotekstin paalla ja mouse.flagi = 0

        'Muutetaan ruudukon kokovalinta
        grid.size.option = grid.size.option + 1
        IF grid.size.option = 4 THEN grid.size.option = 1

        flag.mouse.down = 1 'Asetetaan mouse.flagi
        GOTO Valikko 'Hypataan alkuun, jotta kokovalinta paivittyy
    END IF

    'Ikkunan koko (window size)
    IF mouse.button = -1 AND mouse.hover = 3 AND flag.mouse.down = 0 THEN 'Jos hiirta klikataan, hiiri on kolmannen valikkotekstin paalla ja mouse.flagi = 0

        'Muutetaan ikkunan kokovalinta
        window.size.option = window.size.option + 1
        IF window.size.option = 4 THEN window.size.option = 1

        flag.mouse.down = 1 'Asetetaan mouse.flagi
        GOTO Valikko 'Hypataan alkuun, jotta kokovalinta paivittyy
    END IF

    'Quit/Lopetus
    IF mouse.button = -1 AND mouse.hover = 4 AND flag.mouse.down = 0 THEN 'Jos hiirta klikataan, hiiri on neljannen valikkotekstin paalla ja mouse.flagi = 0
        SYSTEM 'Sammutetaan peli
    END IF


    'Paavalikon piirto alkaa
    '-----------------------
    CLS

    'Piirretaan gridi/ruudukko
    FOR t = 1 TO grid.size
        LINE (t * square.width, 0)-(t * square.width, grid.size * square.width)
        LINE (0, t * square.width)-(grid.size * square.width, t * square.width)
    NEXT t

    'Piirretaan otsikon tausta paavalikkoon
    _PRINTSTRING ((_WIDTH - _PRINTWIDTH("ллллллллллллллллллллллллллллллллллллллллллл")) / 2, _HEIGHT / 8 - 16), "ллллллллллллллллллллллллллллллллллллллллллл"
    _PRINTSTRING ((_WIDTH - _PRINTWIDTH("ллллллллллллллллллллллллллллллллллллллллллл")) / 2, _HEIGHT / 8), "ллллллллллллллллллллллллллллллллллллллллллл"
    _PRINTSTRING ((_WIDTH - _PRINTWIDTH("ллллллллллллллллллллллллллллллллллллллллллл")) / 2, _HEIGHT / 8 + 16), "ллллллллллллллллллллллллллллллллллллллллллл"

    'Piirretaan otsikko paavalikkoon
    COLOR Black
    _PRINTSTRING ((_WIDTH - _PRINTWIDTH("C    O    N    N    E    C    T    5")) / 2, _HEIGHT / 8), "C    O    N    N    E    C    T    5"

    'Piirretaan paavalikon valintatekstit jos hiiri ei ole valintatekstin paalla
    COLOR White
    _PRINTMODE _FILLBACKGROUND
    IF mouse.hover <> 1 THEN _PRINTSTRING ((_WIDTH - _PRINTWIDTH(menu.option$(1))) / 2, _HEIGHT / 2.62), menu.option$(1)
    IF mouse.hover <> 2 THEN _PRINTSTRING ((_WIDTH - _PRINTWIDTH(menu.option$(2))) / 2, _HEIGHT / 1.91), menu.option$(2)
    IF mouse.hover <> 3 THEN _PRINTSTRING ((_WIDTH - _PRINTWIDTH(menu.option$(3))) / 2, _HEIGHT / 1.5), menu.option$(3)
    IF mouse.hover <> 4 THEN _PRINTSTRING ((_WIDTH - _PRINTWIDTH(menu.option$(4))) / 2, _HEIGHT / 1.13), menu.option$(4)

    'Piirretaan paavalikon ensimmainen valintateksti, jos hiiri on tekstin paalla
    IF mouse.hover = 1 THEN
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING ((_WIDTH - _PRINTWIDTH("ллллллллллллллллллллллллллллл")) / 2, _HEIGHT / 2.62), "ллллллллллллллллллллллллллллл"
        COLOR Black
        _PRINTSTRING ((_WIDTH - _PRINTWIDTH(menu.option$(1))) / 2, _HEIGHT / 2.62), menu.option$(1)
        COLOR White
    END IF

    'Piirretaan paavalikon toinen valintateksti, jos hiiri on tekstin paalla
    IF mouse.hover = 2 THEN
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING ((_WIDTH - _PRINTWIDTH("ллллллллллллллллллллллллллллллллллллллллллллллл")) / 2, _HEIGHT / 1.91), "ллллллллллллллллллллллллллллллллллллллллллллллл"
        COLOR Black
        _PRINTSTRING ((_WIDTH - _PRINTWIDTH(menu.option$(2))) / 2, _HEIGHT / 1.91), menu.option$(2)
        COLOR White
    END IF

    'Piirretaan paavalikon kolmas valintateksti, jos hiiri on tekstin paalla
    IF mouse.hover = 3 THEN
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING ((_WIDTH - _PRINTWIDTH("лллллллллллллллллллллллллллллллллллллллллллллллллллллл")) / 2, _HEIGHT / 1.5), "лллллллллллллллллллллллллллллллллллллллллллллллллллллл"
        COLOR Black
        _PRINTSTRING ((_WIDTH - _PRINTWIDTH(menu.option$(3))) / 2, _HEIGHT / 1.5), menu.option$(3)
        COLOR White
    END IF

    'Piirretaan paavalikon neljas valintateksti, jos hiiri on tekstin paalla
    IF mouse.hover = 4 THEN
        _PRINTMODE _KEEPBACKGROUND
        _PRINTSTRING ((_WIDTH - _PRINTWIDTH("лллллллллллл")) / 2, _HEIGHT / 1.13), "лллллллллллл"
        COLOR Black
        _PRINTSTRING ((_WIDTH - _PRINTWIDTH(menu.option$(4))) / 2, _HEIGHT / 1.13), menu.option$(4)
        COLOR White
    END IF

    _PRINTMODE _KEEPBACKGROUND 'Palautetaan asetus joka pitaa taustan tekstia piirrettaessa

    _LIMIT 60
    _DISPLAY
LOOP

'Uusi peli alkaa tasta
uusi.peli:

'Nollataan muuttujat kun uusi peli alkaa
winner = 0
turn = 1
play.x = 0
play.y = 0

ERASE square: DIM square(grid.size + 1, grid.size + 1) AS _BYTE 'Nollataan nelion sisalto.

'Asetetaan reunojen yli meneva seuraava ruutu -1:ksi. Tama helpottaa tietokoneen tekemia paatoksia ja tulkintoja pelin tilanteesta.
FOR t = 0 TO grid.size + 1
    square(0, t) = -1
    square(grid.size + 1, t) = -1

    square(t, 0) = -1
    square(t, grid.size + 1) = -1
NEXT t


'Pelin paalooppi alkaa tasta
'---------------------------
mainloop:
DO
    'Hiiri
    IF mouse.button = 0 THEN flag.mouse.down = 0 ELSE flag.mouse.down = 1 'Tyhjennetaan mouse.flagit

    'Tehdaan asioita kun hiirta liikutetaan, tai klikataan
    DO WHILE _MOUSEINPUT
        mouse.button = _MOUSEBUTTON(1) 'Tarkistetaan onko hiiren oikeaa klikattu ja tallennetaan tieto muuttujaan. -1 = klikattu, 0 = ei klikattu.

        'Tallennetaan hiiren nykyinen sijainti muuttujaan.
        mouse.x = _MOUSEX
        mouse.y = _MOUSEY
    LOOP

    'Muutetaan hiiren kordinaatit ruutukordinaateiksi
    mouse.square.x = INT(mouse.x / square.width) + 1
    mouse.square.y = INT(mouse.y / square.width) + 1

    'Hiiren vasenta klikataan (mouse.flagi = 0, voittaja ei ole selvilla hiiren kohdalla oleva nelio on tyhja)
    IF mouse.button = -1 AND flag.mouse.down = 0 AND winner = 0 AND square(mouse.square.x, mouse.square.y) = 0 THEN
        square(mouse.square.x, mouse.square.y) = 1 'Asetetaan nelio pelaajan nelioksi
        turn = 2 'Asetetaan vuoro tietokoneelle
        flag.mouse.down = 1 'Asetetaan mouse.flagi
        GOSUB loppuiko.peli 'Tarkistetaan voittiko pelaaja pelin.
    END IF

    'Hiiren vasenta klikataan kun voittaja on selvilla (resetoi pelin)
    IF mouse.button = -1 AND flag.mouse.down = 0 AND winner > 0 THEN
        flag.mouse.down = 1 'Asetetaan mouse.flagi
        GOTO Valikko 'Hypataan takaisin paavalikkoon
    END IF

    GOSUB piirto 'Hypataan piirtoon
    IF turn = 2 AND winner = 0 THEN GOTO ai.turn 'Jos voittaja ei ole selvilla ja vuoro on tietokoneella, hypataan tietokoneen vuoroon
LOOP

'Tietokoneen vuoro
ai.turn:

GOSUB cpun.spottipisteet 'Kaydaan laskemassa jokaiselle ruudukolle pisteet jonka mukaan tietokone valitsee pelattavan ruudun.

'Valitaan pelattava ruudukko sen mukaan milla on eniten pisteita. Jos usealla spotilla on yhta paljon pisteita, arvotaan pelattava spotti niista.
maxVal = -999

'Vaihe1: Etsitaan maksimiarvo ruudukoista
FOR x = 1 TO grid.size
    FOR y = 1 TO grid.size
        IF square.value(x, y) > maxVal AND square(x, y) = 0 THEN
            maxVal = square.value(x, y)
        END IF
    NEXT y
NEXT x

'Vaihe2: Kerataan tiedot maksimiarvoista ja tallennetaan ne muuttujaan
REDIM maxIndices(1 TO grid.size * grid.size, 2)
i = 0
FOR x = 1 TO grid.size
    FOR y = 1 TO grid.size
        IF square.value(x, y) = maxVal AND square(x, y) = 0 THEN
            i = i + 1
            maxIndices(i, 1) = x
            maxIndices(i, 2) = y
        END IF
    NEXT y
NEXT x

'Vaihe3: Valitaan pelattava ruudukko sen mukaan mika on saannut parhaimmat pisteet. Jos kaksi tai useampi ruudukoista on saannut samat pisteet, arvotaan niiden valilta pelattava ruudukko.
IF i > 0 THEN
    DIM selectedIndex AS INTEGER
    selectedIndex = INT(RND * i) + 1
    play.x = maxIndices(selectedIndex, 1)
    play.y = maxIndices(selectedIndex, 2)
ELSE
    play.x = -1
    play.y = -1
END IF

square(play.x, play.y) = 2 'Pelataan tietokoneen valitsema ruudukko
GOSUB loppuiko.peli 'Tarkastetaan loppuiko peli
turn = 1 'Siirretaan vuoro pelaajalle
GOTO mainloop 'Hypataan takaisin paalooppiin


'Tasta alkaa pelin piirto
'------------------------
piirto:
CLS

'Piirretaan ristikko
FOR t = 1 TO grid.size
    LINE (t * square.width, 0)-(t * square.width, grid.size * square.width)
    LINE (0, t * square.width)-(grid.size * square.width, t * square.width)
NEXT t

'Piirretaan pelinappulat
FOR t = 1 TO grid.size
    FOR tt = 1 TO grid.size

        'Piirretaan pelaajan nappulat
        IF square(tt, t) = 1 THEN
            CIRCLE ((tt - 1) * (square.width) + square.width / 2, (t - 1) * (square.width) + square.width / 2), square.width / 3
            PAINT ((tt - 1) * (square.width) + square.width / 2, (t - 1) * (square.width) + square.width / 2), White
        END IF

        IF square(tt, t) = 2 THEN CIRCLE ((tt - 1) * (square.width) + square.width / 2, (t - 1) * (square.width) + square.width / 2), square.width / 3, White 'Piirretaan tietokoneen nappulat
    NEXT tt
NEXT t

'Merkitaan tietokoneen viimeisin siirto pelinappulaan
IF square(play.x, play.y) > 0 THEN
    CIRCLE ((play.x - 1) * (square.width) + square.width / 2, (play.y - 1) * (square.width) + square.width / 2), square.width / 30, White
    PAINT ((play.x - 1) * (square.width) + square.width / 2, (play.y - 1) * (square.width) + square.width / 2), White
END IF

'Piirretaan voittolinja jos voittaja on selvilla
IF winner > 0 THEN LINE ((winning.square(1, 1) - 1) * square.width + square.width / 2, (winning.square(2, 1) - 1) * square.width + square.width / 2)-((winning.square(1, 5) - 1) * square.width + square.width / 2, (winning.square(2, 5) - 1) * square.width + square.width / 2), White

'Piirretaan hiiren kohdalla oleva ympyra gridiin (jos voittaja ei ole viela selvilla).
IF winner = 0 THEN
    CIRCLE ((mouse.square.x - 1) * (square.width) + square.width / 2, (mouse.square.y - 1) * (square.width) + square.width / 2), square.width / 3
    PAINT ((mouse.square.x - 1) * (square.width) + square.width / 2, (mouse.square.y - 1) * (square.width) + square.width / 2), White
END IF

'Asetetaan voittoteksti sen mukaan kumpi voitti
IF winner = 1 THEN winning.text$ = "Player won!"
IF winner = 2 THEN winning.text$ = "Cpu won!"
IF winner = 3 THEN winning.text$ = "Tie game!"

'Jos voittaja on selvilla, tai lauta tayttynyt, piirretaan voittoteksti
IF winner > 0 THEN
    _PRINTMODE _FILLBACKGROUND
    _PRINTSTRING ((_WIDTH - _PRINTWIDTH(winning.text$)) / 2, 4), winning.text$
    _PRINTMODE _KEEPBACKGROUND
END IF

'Debug info
'Locate 1, 1
'Print "mouse x:"; mouse.x
'Locate 2, 1
'Print "mouse y:"; mouse.y;
'Locate 3, 1
'Print "slotti x:"; mouse.square.x
'Locate 4, 1
'Print "slotti y:"; mouse.square.y
'Locate 10, 1
'Print "square message:"; square.message$

'Printataan pelattavan nelion arvo
FOR t = 1 TO grid.size
    FOR tt = 1 TO grid.size
        'If square(tt, t) = 0 Then _PrintString ((tt - 1) * square.width, (t - 1) * square.width), Str$(square.value(tt, t))
    NEXT tt
NEXT t

_LIMIT 60
_DISPLAY

RETURN


'Tarkastetaan voittiko jompi kumpi pelaaja, tai tayttyiko pelilauta.
'-------------------------------------------------------------------
loppuiko.peli:

'Tayttyiko pelilauta
t2 = 0
FOR t = 1 TO grid.size
    FOR tt = 1 TO grid.size
        IF square(t, tt) > 0 THEN t2 = t2 + 1
    NEXT tt
NEXT t
IF t2 = t * tt THEN winner = 3


'Saiko pelaaja tai cpu viisi vaakaan.
FOR t = 1 TO grid.size - 4
    FOR tt = 1 TO grid.size
        IF square(t, tt) = 1 AND square(t + 1, tt) = 1 AND square(t + 2, tt) = 1 AND square(t + 3, tt) = 1 AND square(t + 4, tt) = 1 THEN winner = 1
        IF square(t, tt) = 2 AND square(t + 1, tt) = 2 AND square(t + 2, tt) = 2 AND square(t + 3, tt) = 2 AND square(t + 4, tt) = 2 THEN winner = 2

        'Asetetaan voittkokordinaatit muuttujiin
        IF winner > 0 THEN
            winning.square(1, 1) = t
            winning.square(2, 1) = tt
            winning.square(1, 2) = t + 1
            winning.square(2, 2) = tt
            winning.square(1, 3) = t + 2
            winning.square(2, 3) = tt
            winning.square(1, 4) = t + 3
            winning.square(2, 4) = tt
            winning.square(1, 5) = t + 4
            winning.square(2, 5) = tt
            RETURN
        END IF

    NEXT tt
NEXT t

'Saiko pelaaja tai cpu viisi pystyyn.
FOR t = 1 TO grid.size
    FOR tt = 1 TO grid.size - 4
        IF square(t, tt) = 1 AND square(t, tt + 1) = 1 AND square(t, tt + 2) = 1 AND square(t, tt + 3) = 1 AND square(t, tt + 4) = 1 THEN winner = 1
        IF square(t, tt) = 2 AND square(t, tt + 1) = 2 AND square(t, tt + 2) = 2 AND square(t, tt + 3) = 2 AND square(t, tt + 4) = 2 THEN winner = 2

        'Asetetaan voittkokordinaatit muuttujiin
        IF winner > 0 THEN
            winning.square(1, 1) = t
            winning.square(2, 1) = tt
            winning.square(1, 2) = t
            winning.square(2, 2) = tt + 1
            winning.square(1, 3) = t
            winning.square(2, 3) = tt + 2
            winning.square(1, 4) = t
            winning.square(2, 4) = tt + 3
            winning.square(1, 5) = t
            winning.square(2, 5) = tt + 4
            RETURN
        END IF

    NEXT tt
NEXT t

'Saiko pelaaja tai cpu viisi kulmaan.
FOR t = 1 TO grid.size - 4
    FOR tt = 1 TO grid.size - 4
        IF square(t, tt) = 1 AND square(t + 1, tt + 1) = 1 AND square(t + 2, tt + 2) = 1 AND square(t + 3, tt + 3) = 1 AND square(t + 4, tt + 4) = 1 THEN winner = 1
        IF square(t, tt) = 2 AND square(t + 1, tt + 1) = 2 AND square(t + 2, tt + 2) = 2 AND square(t + 3, tt + 3) = 2 AND square(t + 4, tt + 4) = 2 THEN winner = 2

        'Asetetaan voittkokordinaatit muuttujiin
        IF winner > 0 THEN
            winning.square(1, 1) = t
            winning.square(2, 1) = tt
            winning.square(1, 2) = t + 1
            winning.square(2, 2) = tt + 1
            winning.square(1, 3) = t + 2
            winning.square(2, 3) = tt + 2
            winning.square(1, 4) = t + 3
            winning.square(2, 4) = tt + 3
            winning.square(1, 5) = t + 4
            winning.square(2, 5) = tt + 4
            RETURN
        END IF

    NEXT tt
NEXT t

'Saiko pelaaja tai cpu viisi kulmaan2.
FOR t = 1 TO grid.size - 4
    FOR tt = 4 TO grid.size
        IF square(t, tt) = 1 AND square(t + 1, tt - 1) = 1 AND square(t + 2, tt - 2) = 1 AND square(t + 3, tt - 3) = 1 AND square(t + 4, tt - 4) = 1 THEN winner = 1
        IF square(t, tt) = 2 AND square(t + 1, tt - 1) = 2 AND square(t + 2, tt - 2) = 2 AND square(t + 3, tt - 3) = 2 AND square(t + 4, tt - 4) = 2 THEN winner = 2

        'Asetetaan voittkokordinaatit muuttujiin
        IF winner > 0 THEN
            winning.square(1, 1) = t
            winning.square(2, 1) = tt
            winning.square(1, 2) = t + 1
            winning.square(2, 2) = tt - 1
            winning.square(1, 3) = t + 2
            winning.square(2, 3) = tt - 2
            winning.square(1, 4) = t + 3
            winning.square(2, 4) = tt - 3
            winning.square(1, 5) = t + 4
            winning.square(2, 5) = tt - 4
            RETURN
        END IF

    NEXT tt
NEXT t

RETURN


'AI:n pelistrategia: Jokaiselle pelattavalle spotille annetaan pisteita ja parhaat pisteet saanut spotti pelataan. Jos useat spotit saavat samat pisteet, arvotaan pelattava spotti.
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cpun.spottipisteet:

'Pisteet:
'- Mita kauempana keskipisteesta spotti, sita enemman miinuspisteita spottiin. Taysin keskella = 0p, siita yksi johonkin suuntaan reunempaa = - 1 jne.
'- +1000 pistetta jos cpu saa slotista 5 suoran.
'- +400 pistetta jos pelaaja saa slotista 5 suoran ja cpu blokkaa sen.
'- +250 pistetta jos cpu saa slotista 4 suoran joka on molemmista paista auki.
'- +200 pistetta jos pelaaja saa slotista 4 suoran joka on molemmista paista auki ja cpu blokkaa sen.
'- +100 pistetta jos cpu saa slotista 4 suoran joka on toisesta paasta auki.
'- +50  pistetta jos pelaaja saa slotista 3 suoran joka on molemmista paista auki.
'- +40  pistetta jos pelaaja saa slotista 4 suoran joka on toisesta paasta auki ja cpu blokkaa sen.
'- -5   pistetta jos slotti on reunassa kiinni.

'Resetoi jokaisen slotin kannattavuuden arvo
ERASE square.value: DIM square.value(grid.size, grid.size) AS INTEGER

'Maaritellaan keskikohta
center.x = (grid.size - 1) / 2
center.y = (grid.size - 1) / 2

'Laske slotin arvo jokaiselle mahdolliselle pelattavalle slotille sen mukaan kuinka keskella lautaa slotti on.
FOR t2 = 1 TO grid.size
    FOR tt2 = 1 TO grid.size

        IF square(t2, tt2) > 0 THEN GOTO continue 'Jos ruutu ei ole tyhja, hypataan sen yli

        'Lasketaan miinuspisteita slottiin sen mukaan kuinka kaukana se on keskipisteesta.
        square.value(t2, tt2) = -INT(SQR((t2 - 1 - center.x) ^ 2 + (tt2 - 1 - center.y) ^ 2))

        'Optimoidaan slottien arvojen laskemista hyppaamalla yli jos slotin ymparilta jokainen ruutu on tyhja.
        IF square(t2 - 1, tt2 - 1) = 0 AND square(t2, tt2 - 1) = 0 AND square(t2 + 1, tt2 - 1) = 0 AND square(t2 - 1, tt2) = 0 AND square(t2 + 1, tt2) = 0 AND square(t2 - 1, tt2 + 1) = 0 AND square(t2, tt2 + 1) = 0 AND square(t2 + 1, tt2 + 1) = 0 THEN GOTO continue

        '- +1000 pistetta jos cpu saa slotista 5 suoran.
        square(t2, tt2) = 2 'Asetetaan valiaikaisesti tietokoneen pelinappula ruutuun

        'Saisiko cpu viisi vaakaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 4
            FOR tt = 1 TO grid.size
                IF square(t, tt) = 2 AND square(t + 1, tt) = 2 AND square(t + 2, tt) = 2 AND square(t + 3, tt) = 2 AND square(t + 4, tt) = 2 THEN square.value(t2, tt2) = square.value(t2, tt2) + 1000
            NEXT tt
        NEXT t

        'Saisiko cpu viisi pystyyn jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size
            FOR tt = 1 TO grid.size - 4
                IF square(t, tt) = 2 AND square(t, tt + 1) = 2 AND square(t, tt + 2) = 2 AND square(t, tt + 3) = 2 AND square(t, tt + 4) = 2 THEN square.value(t2, tt2) = square.value(t2, tt2) + 1000
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 4
            FOR tt = 1 TO grid.size - 4
                IF square(t, tt) = 2 AND square(t + 1, tt + 1) = 2 AND square(t + 2, tt + 2) = 2 AND square(t + 3, tt + 3) = 2 AND square(t + 4, tt + 4) = 2 THEN square.value(t2, tt2) = square.value(t2, tt2) + 1000
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan2 jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 4
            FOR tt = 4 TO grid.size
                IF square(t, tt) = 2 AND square(t + 1, tt - 1) = 2 AND square(t + 2, tt - 2) = 2 AND square(t + 3, tt - 3) = 2 AND square(t + 4, tt - 4) = 2 THEN square.value(t2, tt2) = square.value(t2, tt2) + 1000
            NEXT tt
        NEXT t

        '- +400 pistetta jos pelaaja saa slotista 5 suoran ja cpu blokkaa sen.
        square(t2, tt2) = 1 'Asetetaan valiaikaisesti pelaajan pelinappula ruutuun

        'Saisiko cpu viisi vaakaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 4
            FOR tt = 1 TO grid.size
                IF square(t, tt) = 1 AND square(t + 1, tt) = 1 AND square(t + 2, tt) = 1 AND square(t + 3, tt) = 1 AND square(t + 4, tt) = 1 THEN square.value(t2, tt2) = square.value(t2, tt2) + 400
            NEXT tt
        NEXT t

        'Saisiko cpu viisi pystyyn jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size
            FOR tt = 1 TO grid.size - 4
                IF square(t, tt) = 1 AND square(t, tt + 1) = 1 AND square(t, tt + 2) = 1 AND square(t, tt + 3) = 1 AND square(t, tt + 4) = 1 THEN square.value(t2, tt2) = square.value(t2, tt2) + 400
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 4
            FOR tt = 1 TO grid.size - 4
                IF square(t, tt) = 1 AND square(t + 1, tt + 1) = 1 AND square(t + 2, tt + 2) = 1 AND square(t + 3, tt + 3) = 1 AND square(t + 4, tt + 4) = 1 THEN square.value(t2, tt2) = square.value(t2, tt2) + 400
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan2 jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 4
            FOR tt = 4 TO grid.size
                IF square(t, tt) = 1 AND square(t + 1, tt - 1) = 1 AND square(t + 2, tt - 2) = 1 AND square(t + 3, tt - 3) = 1 AND square(t + 4, tt - 4) = 1 THEN square.value(t2, tt2) = square.value(t2, tt2) + 400
            NEXT tt
        NEXT t

        '- +250 pistetta Jos cpu saa slotista 4 suoran joka on molemmista paista auki.
        square(t2, tt2) = 2 'Asetetaan valiaikaisesti tietokoneen pelinappula ruutuun

        'Saisiko cpu nelja vaakaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size
                IF square(t - 1, tt) = 0 AND square(t, tt) = 2 AND square(t + 1, tt) = 2 AND square(t + 2, tt) = 2 AND square(t + 3, tt) = 2 AND square(t + 4, tt) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 250
            NEXT tt
        NEXT t

        'Saisiko cpu nelja pystyyn jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size
            FOR tt = 1 TO grid.size - 5
                IF square(t, tt - 1) = 0 AND square(t, tt) = 2 AND square(t, tt + 1) = 2 AND square(t, tt + 2) = 2 AND square(t, tt + 3) = 2 AND square(t, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 250
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size - 5
                IF square(t - 1, tt - 1) = 0 AND square(t, tt) = 2 AND square(t + 1, tt + 1) = 2 AND square(t + 2, tt + 2) = 2 AND square(t + 3, tt + 3) = 2 AND square(t + 4, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 250
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan2 jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 5 TO grid.size
                IF square(t - 1, tt) = 0 AND square(t, tt) = 2 AND square(t + 1, tt - 1) = 2 AND square(t + 2, tt - 2) = 2 AND square(t + 3, tt - 3) = 2 AND square(t + 4, tt - 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 250
            NEXT tt
        NEXT t

        '- +200 pistetta Jos pelaaja saa slotista 4 suoran joka on molemmista paista auki ja cpu blokkaa sen.
        square(t2, tt2) = 1 'Asetetaan valiaikaisesti pelaajan pelinappula ruutuun

        'Saisiko cpu nelja vaakaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size
                IF square(t - 1, tt) = 0 AND square(t, tt) = 1 AND square(t + 1, tt) = 1 AND square(t + 2, tt) = 1 AND square(t + 3, tt) = 1 AND square(t + 4, tt) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 200
            NEXT tt
        NEXT t

        'Saisiko cpu nelja pystyyn jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size
            FOR tt = 1 TO grid.size - 5
                IF square(t, tt - 1) = 0 AND square(t, tt) = 1 AND square(t, tt + 1) = 1 AND square(t, tt + 2) = 1 AND square(t, tt + 3) = 1 AND square(t, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 200
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size - 5
                IF square(t - 1, tt - 1) = 0 AND square(t, tt) = 1 AND square(t + 1, tt + 1) = 1 AND square(t + 2, tt + 2) = 1 AND square(t + 3, tt + 3) = 1 AND square(t + 4, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 200
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan2 jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 5 TO grid.size
                IF square(t - 1, tt) = 0 AND square(t, tt) = 1 AND square(t + 1, tt - 1) = 1 AND square(t + 2, tt - 2) = 1 AND square(t + 3, tt - 3) = 1 AND square(t + 4, tt - 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 200
            NEXT tt
        NEXT t

        '- +100 pistetta Jos cpu saa slotista 4 suoran joka on toisesta paasta auki.
        square(t2, tt2) = 2 'Asetetaan valiaikaisesti tietokoneen pelinappula ruutuun

        'Saisiko cpu nelja vaakaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size
                IF square(t - 1, tt) = 0 AND square(t, tt) = 2 AND square(t + 1, tt) = 2 AND square(t + 2, tt) = 2 AND square(t + 3, tt) = 2 AND square(t + 4, tt) = 1 THEN square.value(t2, tt2) = square.value(t2, tt2) + 100
            NEXT tt
        NEXT t

        'Saisiko cpu nelja pystyyn jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size
            FOR tt = 1 TO grid.size - 5
                IF square(t, tt - 1) = 0 AND square(t, tt) = 2 AND square(t, tt + 1) = 2 AND square(t, tt + 2) = 2 AND square(t, tt + 3) = 2 AND square(t, tt + 4) = 1 THEN square.value(t2, tt2) = square.value(t2, tt2) + 100
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size - 5
                IF square(t - 1, tt - 1) = 0 AND square(t, tt) = 2 AND square(t + 1, tt + 1) = 2 AND square(t + 2, tt + 2) = 2 AND square(t + 3, tt + 3) = 2 AND square(t + 4, tt + 4) = 1 THEN square.value(t2, tt2) = square.value(t2, tt2) + 100
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan2 jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 5 TO grid.size
                IF square(t - 1, tt) = 0 AND square(t, tt) = 2 AND square(t + 1, tt - 1) = 2 AND square(t + 2, tt - 2) = 2 AND square(t + 3, tt - 3) = 2 AND square(t + 4, tt - 4) = 1 THEN square.value(t2, tt2) = square.value(t2, tt2) + 100
            NEXT tt
        NEXT t

        '- +100 pistetta Jos cpu saa slotista 4 suoran joka on toisesta paasta auki.
        square(t2, tt2) = 2 'Asetetaan valiaikaisesti tietokoneen pelinappula ruutuun

        'Saisiko cpu nelja vaakaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size
                IF square(t - 1, tt) = 1 AND square(t, tt) = 2 AND square(t + 1, tt) = 2 AND square(t + 2, tt) = 2 AND square(t + 3, tt) = 2 AND square(t + 4, tt) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 100
            NEXT tt
        NEXT t

        'Saisiko cpu nelja pystyyn jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size
            FOR tt = 1 TO grid.size - 5
                IF square(t, tt - 1) = 1 AND square(t, tt) = 2 AND square(t, tt + 1) = 2 AND square(t, tt + 2) = 2 AND square(t, tt + 3) = 2 AND square(t, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 100
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size - 5
                IF square(t - 1, tt - 1) = 1 AND square(t, tt) = 2 AND square(t + 1, tt + 1) = 2 AND square(t + 2, tt + 2) = 2 AND square(t + 3, tt + 3) = 2 AND square(t + 4, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 100
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan2 jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 5 TO grid.size
                IF square(t - 1, tt) = 1 AND square(t, tt) = 2 AND square(t + 1, tt - 1) = 2 AND square(t + 2, tt - 2) = 2 AND square(t + 3, tt - 3) = 2 AND square(t + 4, tt - 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 100
            NEXT tt
        NEXT t

        '- +50 pistetta jos cpu saa slotista 3 suoran joka on molemmista paista auki.
        square(t2, tt2) = 2 'Asetetaan valiaikaisesti tietokoneen pelinappula ruutuun

        'Saisiko cpu viisi vaakaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 4
            FOR tt = 1 TO grid.size
                IF square(t, tt) = 0 AND square(t + 1, tt) = 2 AND square(t + 2, tt) = 2 AND square(t + 3, tt) = 2 AND square(t + 4, tt) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 50
            NEXT tt
        NEXT t

        'Saisiko cpu viisi pystyyn jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size
            FOR tt = 1 TO grid.size - 4
                IF square(t, tt) = 0 AND square(t, tt + 1) = 2 AND square(t, tt + 2) = 2 AND square(t, tt + 3) = 2 AND square(t, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 50
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 4
            FOR tt = 1 TO grid.size - 4
                IF square(t, tt) = 0 AND square(t + 1, tt + 1) = 2 AND square(t + 2, tt + 2) = 2 AND square(t + 3, tt + 3) = 2 AND square(t + 4, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 50
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan2 jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 4
            FOR tt = 4 TO grid.size
                IF square(t, tt) = 0 AND square(t + 1, tt - 1) = 2 AND square(t + 2, tt - 2) = 2 AND square(t + 3, tt - 3) = 2 AND square(t + 4, tt - 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 50
            NEXT tt
        NEXT t

        '- +40  pistetta Jos pelaaja saa slotista 4 suoran joka on toisesta paasta auki ja cpu blokkaa sen.
        square(t2, tt2) = 1 'Asetetaan valiaikaisesti pelaajan pelinappula ruutuun

        'Saisiko cpu nelja vaakaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size
                IF square(t - 1, tt) = 0 AND square(t, tt) = 1 AND square(t + 1, tt) = 1 AND square(t + 2, tt) = 1 AND square(t + 3, tt) = 1 AND square(t + 4, tt) = 2 THEN square.value(t2, tt2) = square.value(t2, tt2) + 40
            NEXT tt
        NEXT t

        'Saisiko cpu nelja pystyyn jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size
            FOR tt = 1 TO grid.size - 5
                IF square(t, tt - 1) = 0 AND square(t, tt) = 1 AND square(t, tt + 1) = 1 AND square(t, tt + 2) = 1 AND square(t, tt + 3) = 1 AND square(t, tt + 4) = 2 THEN square.value(t2, tt2) = square.value(t2, tt2) + 40
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size - 5
                IF square(t - 1, tt - 1) = 0 AND square(t, tt) = 1 AND square(t + 1, tt + 1) = 1 AND square(t + 2, tt + 2) = 1 AND square(t + 3, tt + 3) = 1 AND square(t + 4, tt + 4) = 2 THEN square.value(t2, tt2) = square.value(t2, tt2) + 40
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan2 jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 5 TO grid.size
                IF square(t - 1, tt) = 0 AND square(t, tt) = 1 AND square(t + 1, tt - 1) = 1 AND square(t + 2, tt - 2) = 1 AND square(t + 3, tt - 3) = 1 AND square(t + 4, tt - 4) = 2 THEN square.value(t2, tt2) = square.value(t2, tt2) + 40
            NEXT tt
        NEXT t

        '- +40  pistetta Jos pelaaja saa slotista 4 suoran joka on toisesta paasta auki ja cpu blokkaa sen.
        square(t2, tt2) = 1 'Asetetaan valiaikaisesti pelaajan pelinappula ruutuun

        'Saisiko cpu nelja vaakaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size
                IF square(t - 1, tt) = 2 AND square(t, tt) = 1 AND square(t + 1, tt) = 1 AND square(t + 2, tt) = 1 AND square(t + 3, tt) = 1 AND square(t + 4, tt) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 40
            NEXT tt
        NEXT t

        'Saisiko cpu nelja pystyyn jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size
            FOR tt = 1 TO grid.size - 5
                IF square(t, tt - 1) = 2 AND square(t, tt) = 1 AND square(t, tt + 1) = 1 AND square(t, tt + 2) = 1 AND square(t, tt + 3) = 1 AND square(t, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 40
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 1 TO grid.size - 5
                IF square(t - 1, tt - 1) = 2 AND square(t, tt) = 1 AND square(t + 1, tt + 1) = 1 AND square(t + 2, tt + 2) = 1 AND square(t + 3, tt + 3) = 1 AND square(t + 4, tt + 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 40
            NEXT tt
        NEXT t

        'Saisiko cpu viisi kulmaan2 jos pelaisi tahan ruutuun.
        FOR t = 1 TO grid.size - 5
            FOR tt = 5 TO grid.size
                IF square(t - 1, tt) = 2 AND square(t, tt) = 1 AND square(t + 1, tt - 1) = 1 AND square(t + 2, tt - 2) = 1 AND square(t + 3, tt - 3) = 1 AND square(t + 4, tt - 4) = 0 THEN square.value(t2, tt2) = square.value(t2, tt2) + 40
            NEXT tt
        NEXT t

        '- -5   pistetta jos slotti on reunassa kiinni.
        IF t2 = 1 OR t2 = grid.size OR tt2 = 1 OR tt2 = grid.size THEN square.value(t2, tt2) = square.value(t2, tt2) - 5

        square(t2, tt2) = 0 ' Palautetaan lapikayty slotti nollaksi

        continue:
    NEXT tt2
NEXT t2

RETURN
