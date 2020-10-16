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


#ifndef KEYS_H
#define KEYS_H
#define ARRAY_SIZE(a)  (sizeof(a)/sizeof(a[0]))

#define FN_KEY  -1
#include "SDL.h"
#undef main
typedef struct KeyDesc_t {
    const char *title;
    int code;
} KeyDesc;

int get_scancode_for_name(const char *name);
const char *get_key_title(int code);
int get_scancode_for_char(char c, int *shift);
#endif
