/*
 *  Copyright (C) 2010  Chaoji Li
 *
 *  DOSPAD is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */


#include "keys.h"
#include "SDL.h"

KeyDesc allkeys[] = {
    {"Fn", FN_KEY},
    
    {"ESC",SDL_SCANCODE_ESCAPE},
    {"F1", SDL_SCANCODE_F1},
    {"F2", SDL_SCANCODE_F2},
    {"F3", SDL_SCANCODE_F3},
    {"F4", SDL_SCANCODE_F4},
    {"F5", SDL_SCANCODE_F5},
    {"F6", SDL_SCANCODE_F6},
    {"F7", SDL_SCANCODE_F7},
    {"F8", SDL_SCANCODE_F8},
    {"F9", SDL_SCANCODE_F9},
    {"F10", SDL_SCANCODE_F10},
    {"F11", SDL_SCANCODE_F11},
    {"F12", SDL_SCANCODE_F12},
    
    {"`~", SDL_SCANCODE_GRAVE},
    {"1!", SDL_SCANCODE_1},
    {"2@", SDL_SCANCODE_2},
    {"3#", SDL_SCANCODE_3},
    {"4$", SDL_SCANCODE_4},
    {"5%", SDL_SCANCODE_5},
    {"6^", SDL_SCANCODE_6},
    {"7&", SDL_SCANCODE_7},
    {"8*", SDL_SCANCODE_8},
    {"9(", SDL_SCANCODE_9},
    {"0)", SDL_SCANCODE_0},
    {"-_", SDL_SCANCODE_MINUS},
    {"=+", SDL_SCANCODE_EQUALS},
    {" BS ", SDL_SCANCODE_BACKSPACE},
    
    {"TAB", SDL_SCANCODE_TAB},
    {"Q", SDL_SCANCODE_Q},
    {"W", SDL_SCANCODE_W},
    {"E", SDL_SCANCODE_E},
    {"R", SDL_SCANCODE_R},
    {"T", SDL_SCANCODE_T},
    {"Y", SDL_SCANCODE_Y},
    {"U", SDL_SCANCODE_U},
    {"I", SDL_SCANCODE_I},
    {"O", SDL_SCANCODE_O},
    {"P", SDL_SCANCODE_P},
    {"[{", SDL_SCANCODE_LEFTBRACKET},
    {"]}", SDL_SCANCODE_RIGHTBRACKET},
    {"\\|", SDL_SCANCODE_BACKSLASH},
    
    {"CAPS", SDL_SCANCODE_CAPSLOCK},
    {"A", SDL_SCANCODE_A},
    {"S", SDL_SCANCODE_S},
    {"D", SDL_SCANCODE_D},
    {"F", SDL_SCANCODE_F},
    {"G", SDL_SCANCODE_G},
    {"H", SDL_SCANCODE_H},
    {"J", SDL_SCANCODE_J},
    {"K", SDL_SCANCODE_K},
    {"L", SDL_SCANCODE_L},
    {";:", SDL_SCANCODE_SEMICOLON},
    {"\'\"", SDL_SCANCODE_APOSTROPHE},
    {"ENTER", SDL_SCANCODE_RETURN},
    
    {"SHIFT", SDL_SCANCODE_LSHIFT},
    {"Z", SDL_SCANCODE_Z},
    {"X", SDL_SCANCODE_X},
    {"C", SDL_SCANCODE_C},
    {"V", SDL_SCANCODE_V},
    {"B", SDL_SCANCODE_B},
    {"N", SDL_SCANCODE_N},
    {"M", SDL_SCANCODE_M},
    {",<", SDL_SCANCODE_COMMA},
    {".>", SDL_SCANCODE_PERIOD},
    {"/?", SDL_SCANCODE_SLASH},
    {"SHIFT", SDL_SCANCODE_RSHIFT},

    {"CTRL", SDL_SCANCODE_LCTRL},
    {"ALT", SDL_SCANCODE_LALT},
    {"CTRL", SDL_SCANCODE_RCTRL},
    {"ALT", SDL_SCANCODE_RALT},
    {" ", SDL_SCANCODE_SPACE},
    
    {"LEFT",SDL_SCANCODE_LEFT},
    {"DOWN",SDL_SCANCODE_DOWN},
    {" UP ",SDL_SCANCODE_UP},
    {"RIGHT",SDL_SCANCODE_RIGHT},
    {"INS",SDL_SCANCODE_INSERT},
    {"HOME",SDL_SCANCODE_HOME},
    {"PGUP",SDL_SCANCODE_PAGEUP},
    {"PGDN",SDL_SCANCODE_PAGEDOWN},
    {"DEL",SDL_SCANCODE_DELETE},
    {"END",SDL_SCANCODE_END}
};

const char *get_key_title(int code)
{
    int i;
    for (i = 0; i < ARRAY_SIZE(allkeys); i++) {
        if (allkeys[i].code == code) {
            return allkeys[i].title;
        }
    }
    return "";
}

int get_scancode_for_char(char c, int *shift)
{
    *shift=0;
    if (c >= 'a' && c <= 'z') {
        return SDL_SCANCODE_A + c - 'a';
    } else if (c >= 'A' && c <= 'Z') {
        *shift=1;
        return SDL_SCANCODE_A + c - 'A';
    } else if (c >= '1' && c <= '9') {
        return SDL_SCANCODE_1 + c - '1';
    } else if (c == ' ') {
        return SDL_SCANCODE_SPACE;
    } else if (c == '\t') {
        return SDL_SCANCODE_TAB;
    } else {
        for (int i = 0; i < ARRAY_SIZE(allkeys); i++) {
            if (strlen(allkeys[i].title)==2) {
                if (c == allkeys[i].title[0]) {
                    return allkeys[i].code;
                } else if (c == allkeys[i].title[1]) {
                    *shift=1;
                    return allkeys[i].code;
                }
            }
        }
    }
    return -1;
}
