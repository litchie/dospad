/*
 *  Copyright (C) 2010-2024 Chaoji Li
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

#import "FloatingView.h"


@implementation FloatingView

- (void)setDelegate:(id <FloatingViewDelegate>)d
{
    delegate = d;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (id)initWithParent:(UIView*)parent
{
    if ((self = [self initWithFrame:parent.bounds])) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
        self.contentMode=UIViewContentModeTop;
        self.alpha=0;
        [parent addSubview:self];
    }
    return self;
}

- (void)show
{
    [UIView beginAnimations:@"ShowFloating" context:nil];
    [UIView setAnimationDuration:0.5];
    self.alpha=1;
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (delegate) {
        [delegate didFloatingView:self];
    }
    [self removeFromSuperview];
}

- (void)dismiss
{
    [UIView beginAnimations:@"DismissFloating" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:0.5];
    self.alpha=0;
    [UIView commitAnimations];    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
