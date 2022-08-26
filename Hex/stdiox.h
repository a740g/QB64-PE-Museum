// Made available under the MIT license, see LICENSE for details

#include <ncurses.h>

int autorefresh_term = TRUE;

int termin_keybuf[1000];
int termin_keystart = 0;
int termin_keyend = 0;

struct mouse_message
{
  int16 x;
  int16 y;
  uint32 buttons;
  int16 movementx;
  int16 movementy;
};
mouse_message termin_mouse_messages[65536]; // a circular buffer of mouse messages
int32 termin_last_mouse_message = 0;
int32 termin_current_mouse_message = 0;
int32 termin_mouse_hideshow_called = 0;

int getkey(int block)
{
  int key;
  if (termin_keystart == termin_keyend)
  { // empty ring buffer
    if (block)
      nodelay(stdscr, FALSE);
    else
      nodelay(stdscr, TRUE);
    key = getch();
    // if key is mouse event add to mouse buffer
  }
  else
  {
    key = termin_keybuf[termin_keystart++];
    if (termin_keystart > 1000)
      termin_keystart = 0;
  }
  if (key == ERR)
    key = 0;
  return key;
}

int inkeyx(int32 *extended)
{
  int key = getkey(FALSE);
  switch (key)
  {
  case KEY_PPAGE:
    *extended = 73;
    return 0;
  case KEY_NPAGE:
    *extended = 81;
    return 0;
  case KEY_UP:
    *extended = 72;
    return 0;
  case KEY_DOWN:
    *extended = 80;
    return 0;
  case KEY_LEFT:
    *extended = 75;
    return 0;
  case KEY_RIGHT:
    *extended = 77;
    return 0;
  case KEY_HOME:
    *extended = 151;
    return 0;
  case KEY_BACKSPACE:
    return 8;
  case KEY_F(1):
    *extended = 59;
    return 0;
  case KEY_F(2):
    *extended = 60;
    return 0;
  case KEY_F(3):
    *extended = 61;
    return 0;
  case KEY_F(4):
    *extended = 62;
    return 0;
  case KEY_F(5):
    *extended = 63;
    return 0;
  case KEY_F(6):
    *extended = 64;
    return 0;
  case KEY_F(7):
    *extended = 65;
    return 0;
  case KEY_F(8):
    *extended = 66;
    return 0;
  case KEY_F(9):
    *extended = 67;
    return 0;
  case KEY_F(10):
    *extended = 68;
    return 0;
  case KEY_F(11):
    *extended = 133;
    return 0;
  case KEY_F(12):
    *extended = 134;
    return 0;
  case KEY_DC:
    *extended = 83;
    return 0;
  case KEY_IC:
    *extended = 82;
    return 0;
  default:
    *extended = 0;
    return key;
  }
}

void displayx()
{
  autorefresh_term = FALSE;
  refresh();
}

void printx(char *s)
{
  printw(s);
  if (autorefresh_term)
    refresh();
}

int32 acs(int cp437byte)
{
  switch (cp437byte)
  {
  case 179:
    return ACS_VLINE;
  case 196:
    return ACS_HLINE;
  case 218:
    return ACS_ULCORNER;
  case 191:
    return ACS_URCORNER;
  case 192:
    return ACS_LLCORNER;
  case 217:
    return ACS_LRCORNER;
  default:
    return cp437byte;
  }
}
void printstringx(int x, int y, char *s)
{
  int oldy, oldx; // to restore cursor
  getyx(stdscr, oldy, oldx);
  move(y - 1, x - 1); // ncurses starts at (0,0); QB starts at (1,1)
  printw(s);
  move(oldy, oldx);
}

void locatex(int row, int col)
{
  move(row - 1, col - 1); // ncurses starts at (0,0); QB starts at (1,1)
}

void showcursor() { curs_set(1); }
void hidecursor() { curs_set(0); }

int32 screenx(int y, int x)
{
  char c[2];
  int oldy, oldx; // to restore cursor
  getyx(stdscr, oldy, oldx);
  move(y - 1, x - 1);
  innstr(c, 2); // length is 1, plus an implicit NUL.
  move(oldy, oldx);
  return c[0];
}

void colorx(int fg, int bg)
{
  static int curfg = 7;
  static int curbg = 0;
  int blink = 0;
  int bright = 0;

  if (!has_colors())
    return;
  if (fg > 31 || bg > 8)
  {
    error(5);
    return;
  }
  if (fg == -1)
    fg = curfg;
  if (bg == -1)
    bg = curbg;
  curfg = fg;
  curbg = bg;

  if (fg == 8 && bg == 0)
  {
    attron(COLOR_PAIR(7));
    attron(A_DIM);
    return;
  }

  if (fg & 16)
  { // is bit 5 set?
    blink = 1;
    fg = fg & (0xff - 16); // turn off bit 4
  }
  if (fg & 8)
  { // is bit 4 set?
    bright = 1;
    fg = fg & (0xff - 8); // turn off bit 3
  }

  if (bright)
    attroff(A_DIM);
  else
    attron(A_DIM);
  if (blink)
    attron(A_BLINK);
  else
    attroff(A_BLINK);

  if (fg == 0 && bg == 0)
  { // special case
    attron(COLOR_PAIR(64));
  }
  else
  {
    attron(COLOR_PAIR(bg * 8 + fg));
  }
}

void clsx()
{
  erase();
  if (autorefresh_term)
    refresh();
}

int32 maxcol()
{
  int32 row, col;
  getmaxyx(stdscr, row, col);
  return col;
}

int32 maxrow()
{
  int32 row, col;
  getmaxyx(stdscr, row, col);
  return row;
}

int32 csrlinx()
{
  int32 row, col;
  getyx(stdscr, row, col);
  return row + 1;
}

int32 posx()
{
  int32 row, col;
  getyx(stdscr, row, col);
  return col + 1;
}

void finishx()
{
  endwin();
}

void initx()
{
  initscr();
  cbreak();
  nonl();
  keypad(stdscr, TRUE);
  noecho();
  if (has_colors())
  {
    bkgdset(A_NORMAL | COLOR_PAIR(0));
    start_color();
    init_pair(1, COLOR_BLUE, COLOR_BLACK);
    init_pair(2, COLOR_GREEN, COLOR_BLACK);
    init_pair(3, COLOR_CYAN, COLOR_BLACK);
    init_pair(4, COLOR_RED, COLOR_BLACK);
    init_pair(5, COLOR_MAGENTA, COLOR_BLACK);
    init_pair(6, COLOR_YELLOW, COLOR_BLACK);
    init_pair(7, COLOR_WHITE, COLOR_BLACK);

    init_pair(8, COLOR_BLACK, COLOR_BLUE);
    init_pair(9, COLOR_BLUE, COLOR_BLUE);
    init_pair(10, COLOR_GREEN, COLOR_BLUE);
    init_pair(11, COLOR_CYAN, COLOR_BLUE);
    init_pair(12, COLOR_RED, COLOR_BLUE);
    init_pair(13, COLOR_MAGENTA, COLOR_BLUE);
    init_pair(14, COLOR_YELLOW, COLOR_BLUE);
    init_pair(15, COLOR_WHITE, COLOR_BLUE);

    init_pair(16, COLOR_BLACK, COLOR_GREEN);
    init_pair(17, COLOR_BLUE, COLOR_GREEN);
    init_pair(18, COLOR_GREEN, COLOR_GREEN);
    init_pair(19, COLOR_CYAN, COLOR_GREEN);
    init_pair(20, COLOR_RED, COLOR_GREEN);
    init_pair(21, COLOR_MAGENTA, COLOR_GREEN);
    init_pair(22, COLOR_YELLOW, COLOR_GREEN);
    init_pair(23, COLOR_WHITE, COLOR_GREEN);

    init_pair(24, COLOR_BLACK, COLOR_CYAN);
    init_pair(25, COLOR_BLUE, COLOR_CYAN);
    init_pair(26, COLOR_GREEN, COLOR_CYAN);
    init_pair(27, COLOR_CYAN, COLOR_CYAN);
    init_pair(28, COLOR_RED, COLOR_CYAN);
    init_pair(29, COLOR_MAGENTA, COLOR_CYAN);
    init_pair(30, COLOR_YELLOW, COLOR_CYAN);
    init_pair(31, COLOR_WHITE, COLOR_CYAN);

    init_pair(32, COLOR_BLACK, COLOR_RED);
    init_pair(33, COLOR_BLUE, COLOR_RED);
    init_pair(34, COLOR_GREEN, COLOR_RED);
    init_pair(35, COLOR_CYAN, COLOR_RED);
    init_pair(36, COLOR_RED, COLOR_RED);
    init_pair(37, COLOR_MAGENTA, COLOR_RED);
    init_pair(38, COLOR_YELLOW, COLOR_RED);
    init_pair(39, COLOR_WHITE, COLOR_RED);

    init_pair(40, COLOR_BLACK, COLOR_MAGENTA);
    init_pair(41, COLOR_BLUE, COLOR_MAGENTA);
    init_pair(42, COLOR_GREEN, COLOR_MAGENTA);
    init_pair(43, COLOR_CYAN, COLOR_MAGENTA);
    init_pair(44, COLOR_RED, COLOR_MAGENTA);
    init_pair(45, COLOR_MAGENTA, COLOR_MAGENTA);
    init_pair(46, COLOR_YELLOW, COLOR_MAGENTA);
    init_pair(47, COLOR_WHITE, COLOR_MAGENTA);

    init_pair(48, COLOR_BLACK, COLOR_YELLOW);
    init_pair(49, COLOR_BLUE, COLOR_YELLOW);
    init_pair(50, COLOR_GREEN, COLOR_YELLOW);
    init_pair(51, COLOR_CYAN, COLOR_YELLOW);
    init_pair(52, COLOR_RED, COLOR_YELLOW);
    init_pair(53, COLOR_MAGENTA, COLOR_YELLOW);
    init_pair(54, COLOR_YELLOW, COLOR_YELLOW);
    init_pair(55, COLOR_WHITE, COLOR_YELLOW);

    init_pair(56, COLOR_BLACK, COLOR_WHITE);
    init_pair(57, COLOR_BLUE, COLOR_WHITE);
    init_pair(58, COLOR_GREEN, COLOR_WHITE);
    init_pair(59, COLOR_CYAN, COLOR_WHITE);
    init_pair(60, COLOR_RED, COLOR_WHITE);
    init_pair(61, COLOR_MAGENTA, COLOR_WHITE);
    init_pair(62, COLOR_YELLOW, COLOR_WHITE);
    init_pair(63, COLOR_WHITE, COLOR_WHITE);

    init_pair(64, COLOR_BLACK, COLOR_BLACK);

    if (can_change_color())
    {
      init_color(COLOR_BLACK, 0, 0, 0);
      init_color(COLOR_BLUE, 0, 0, 667);
      init_color(COLOR_GREEN, 0, 667, 0);
      init_color(COLOR_CYAN, 0, 667, 667);
      init_color(COLOR_RED, 667, 0, 0);
      init_color(COLOR_MAGENTA, 667, 0, 667);
      init_color(COLOR_YELLOW, 667, 667, 0);
      init_color(COLOR_WHITE, 667, 667, 667);
    }
  }
}
