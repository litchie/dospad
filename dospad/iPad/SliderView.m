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

#import "SliderView.h"

@implementation SliderView
@synthesize position;

- (void)setPosition:(float)pos
{
    pos = MIN(MAX(pos, 0), 1);
    position = pos;
    float sliding_width = self.bounds.size.width-slider.frame.size.width;
    [UIView beginAnimations:@"sliding" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.1];
    slider.center=CGPointMake(pos*sliding_width+slider.frame.size.width/2, 
                              self.bounds.size.height/2);
    [UIView commitAnimations];
}

- (void)setActionOnSliderChange:(SEL)selector target:(NSObject*)obj
{
    callbackSelector=selector;
    callbackObject=obj;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint ptPrev=[touch previousLocationInView:self];
    CGPoint ptCurr=[touch locationInView:self];
    float sliding_width = self.bounds.size.width-slider.frame.size.width;
    [self setPosition:(position+(ptCurr.x-ptPrev.x)/sliding_width)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (callbackObject)
    {
        [callbackObject performSelector:callbackSelector];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor=[UIColor clearColor];
        slider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider"]];
        slider.userInteractionEnabled = YES;
        [self addSubview:slider];
        [self setPosition:0];
    }
    return self;
}

- (void)setSliderImage:(UIImage *)image
{
    slider.image = image;
    [slider sizeToFit];
}



@end
