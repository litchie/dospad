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
#import "DosEmuThread.h"
#import "KeyboardView.h"
#import "KeyView.h"
#import "FrameskipIndicator.h"
#import "TipView.h"
#import "CommandListView.h"
#import "SliderView.h"
#import "GamePadView.h"
//#import "VKView.h"
#import "DOSPadBaseViewController.h"
#import "FloatPanel.h"

@interface DosPadViewController : DOSPadBaseViewController
<FloatingViewDelegate>
{
    // Portrait Mode
    FrameskipIndicator *fsIndicator;
    KeyboardView *keyboard;
    UIButton *btnOption,*btnBack;
    UIButton *btnMouseLeftP, *btnMouseRightP; /* portrait mode */
    UILabel *labCycles;
    SliderView *sliderInput;
    UIImageView *gamepadLight;
    UIImageView *joystiqLight;

    FrameskipIndicator *fsIndicator2;
    UILabel *labCycles2;
    FloatPanel *fullscreenPanel;
    BOOL useOriginalScreenSize;
}

- (void)refreshFullscreenPanel;
- (void)onSliderChange;
@end
