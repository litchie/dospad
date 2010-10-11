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

#import <UIKit/UIKit.h>

#import "KeyboardView.h"
#import "KeyView.h"

@interface KeyPadCustomizeViewController : UIViewController<KeyDelegate> {
    IBOutlet KeyboardView*kbd;
    IBOutlet KeyView* k1,*k2,*k3,*k4,*k5,*k6,*k7,*k8,*k9;
    KeyView *hl;
}
@property (nonatomic,retain) KeyView* k1,*k2,*k3,*k4,*k5,*k6,*k7,*k8,*k9;

@property (nonatomic,retain) KeyboardView*kbd;
@end
