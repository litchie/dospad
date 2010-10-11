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

#ifndef COMMON_H
#define COMMON_H

//#define CYDIA
#define THREADED

#define DONATE_URL @"http://www.litchie.net/donate/dospad-donate.html"

#include "keys.h"
#include "cmd_history.h"

#define kFirstRun     @"firstRun"
#define kTransparency @"transparency"
#define kTransparencyDefault 0.3

#define kFullscreenKeypad @"fullscreenKeypad"
#define kForceAspect @"ForceAspect"
#define kDisableKeySound @"DisableKeySound"
#define kMouseSpeed @"MouseSpeed"

#define kK1 @"k1"
#define kK2 @"k2"
#define kK3 @"k3"
#define kK4 @"k4"
#define kK5 @"k5"
#define kK6 @"k6"
#define kK7 @"k7"
#define kK8 @"k8"
#define kK9 @"k9"

#define ISIPAD()  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define DEFS_GET_INT(name)  [[NSUserDefaults standardUserDefaults] integerForKey:name]
#define DEFS_SET_INT(name,value) [[NSUserDefaults standardUserDefaults] setInteger:value forKey:name]
#define MAX_HISTORY_ITEMS 20

#endif

