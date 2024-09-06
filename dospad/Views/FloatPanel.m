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

#import "FloatPanel.h"
#import "Common.h"

@interface SmoothBar : UIView
{
    
}
@end

@implementation SmoothBar

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIImage *image = (ISIPAD() ? [UIImage imageNamed:@"landbarblank~iPad"] :
                      [UIImage imageNamed:@"landbarblank"]);
    
    [image drawInRect:rect];
    /*
    CGContextRef c = UIGraphicsGetCurrentContext();
    [[UIColor grayColor] set];
    CGContextMoveToPoint(c, 0, 0);
    CGContextAddLineToPoint(c, rect.size.width, 0);
    CGContextAddLineToPoint(c, rect.size.width-rect.size.height, rect.size.height);
    CGContextAddLineToPoint(c, rect.size.height, rect.size.height);
    CGContextFillPath(c);*/
}

@end


@implementation FloatPanel
@synthesize contentView;
@synthesize autoHide;
@synthesize autoHideInterval;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        self.backgroundColor=[UIColor clearColor];
        self.clipsToBounds=YES;
        // Initialization code
        contentView = [[SmoothBar alloc] initWithFrame:self.bounds];
        [self addSubview:contentView];
        CGPoint pt = contentView.center;
        contentView.center = CGPointMake(pt.x, pt.y - contentView.frame.size.height);
        autoHide = YES;
        
        if (ISIPAD())
        {
            btnAutoHide = [[UIButton alloc] initWithFrame:CGRectMake(0,0,48,24)];
            [btnAutoHide setImage:[UIImage imageNamed:@"unsticky~ipad"] forState:UIControlStateNormal];
            [btnAutoHide addTarget:self
                            action:@selector(toggleAutoHide) 
                  forControlEvents:UIControlEventTouchUpInside];
            btnAutoHide.center = CGPointMake(635, 18);
            [contentView addSubview:btnAutoHide];            
        }
        else
        {
            btnAutoHide = [[UIButton alloc] initWithFrame:CGRectMake(0,0,48,24)];
            [btnAutoHide setImage:[UIImage imageNamed:@"unsticky"] forState:UIControlStateNormal];
            [btnAutoHide addTarget:self
                            action:@selector(toggleAutoHide) 
                  forControlEvents:UIControlEventTouchUpInside];
            btnAutoHide.center = CGPointMake(432, 12);
            [contentView addSubview:btnAutoHide];
        }
        autoHideInterval=3;
    }
    return self;
}
             
- (void)toggleAutoHide
{
    [self setAutoHide:!autoHide];
}


- (void)resetAutoHideTimer
{
    if (autoHide)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContent) object:nil];
        [self performSelector:@selector(hideContent) withObject:nil afterDelay:autoHideInterval];
    }
}

- (void)setItems:(NSArray*)itemArray
{
    float marginx = (ISIPAD()?95:66);
    float marginy_bot = (ISIPAD()?10:7);
 
    float w = (contentView.frame.size.width-marginx*2) / ([itemArray count]);
    float h = contentView.frame.size.height - marginy_bot;
 
    if (items != nil)
    {
        for (UIView *v in items) 
            [v removeFromSuperview];
    }
    items = itemArray;
    
    for (int i = 0; i < [itemArray count]; i++)
    {
        UIView * v = [itemArray objectAtIndex:i];
        v.center = CGPointMake(marginx+w*i+w/2,h/2);
        [contentView addSubview:v];
        if ([v isKindOfClass:[UIControl class]])
        {
//            [(UIControl*)v addTarget:self action:@selector(resetAutoHideTimer)
//                    forControlEvents:UIControlEventTouchDown];
            [(UIControl*)v addTarget:self action:@selector(resetAutoHideTimer)
                    forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)setAutoHide:(BOOL)b
{
    autoHide = b;
    if (b)
    {
        [btnAutoHide setImage:[UIImage imageNamed:ISIPAD()?@"unsticky~ipad.png":@"unsticky.png"]
                     forState:UIControlStateNormal];
        [self performSelector:@selector(hideContent) withObject:nil afterDelay:autoHideInterval];
    }
    else
    {
        [btnAutoHide setImage:[UIImage imageNamed:ISIPAD()?@"sticky~ipad.png":@"sticky.png"]
                     forState:UIControlStateNormal]; 
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContent) object:nil];
    }
}

- (void)hideContent
{
    if (!isContentShowing)
        return;
    isContentShowing = NO;
    [UIView beginAnimations:nil context:nil];
    CGPoint pt = contentView.center;
    contentView.center = CGPointMake(pt.x, pt.y - contentView.frame.size.height);
    [UIView commitAnimations];    
}

- (void)showContent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContent) object:nil];
    if (autoHide)
    {
        [self performSelector:@selector(hideContent) withObject:nil afterDelay:autoHideInterval];
    }
    if (!isContentShowing)
    {
        isContentShowing = YES;
        [UIView beginAnimations:nil context:nil];
        CGPoint pt = contentView.center;
        contentView.center = CGPointMake(pt.x, pt.y + contentView.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self showContent];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
