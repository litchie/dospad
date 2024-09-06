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
#import "GamePadView.h"
#import "keys.h"
#include "SDL.h"
#import <AudioToolbox/AudioServices.h>
#import "Common.h"
#import "DOSPadEmulator.h"

#define DRAW_OVERLAY  0


extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);

static SystemSoundID sound_joystick_button_click=0;
static SystemSoundID sound_joystick_move=0;


@implementation DPadView
@synthesize useArrowKeys;
@synthesize currentDirection;
@synthesize backgroundImage;
@synthesize centerStickImage;
@synthesize sidedStickImage;
@synthesize images;
@synthesize quiet;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        minDistance=MAX(10, frame.size.width/2 * 0.4);
        quiet = !DEFS_GET_INT(kGamePadSoundEnabled);
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
    if (backgroundImage)
    {
        [backgroundImage drawInRect:rect];
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    // If images is present, that means we have image for
    // each direction; if not, then we have to draw sided
    // stick manually
    if (useArrowsKeys || images == nil)
    {
        if (currentDirection != DPadNone && sidedStickImage != nil)
        {
            CGRect imageRect = CGRectMake(0, 0, sidedStickImage.size.width, sidedStickImage.size.height);
            
            CGContextSaveGState(c);

            // Move to the center of DPad
            float x = CGRectGetMidX(rect);
            float y = CGRectGetMidY(rect);
            CGContextTranslateCTM(c, x, y);

            // Scale it down
            float scale = rect.size.width/imageRect.size.width;
            CGContextScaleCTM(c, scale, scale);

            // Rotate to the right direction
            float angle = -M_PI/4 * (currentDirection - 1) + M_PI/2;
            CGContextRotateCTM(c, angle);

            // Finally draw the image
            imageRect.origin.x = -imageRect.size.width/2;
            imageRect.origin.y = -imageRect.size.height/2;
            CGContextDrawImage(c, imageRect, [sidedStickImage CGImage]);
            
            CGContextRestoreGState(c);
        }
        
        if (currentDirection == DPadNone && centerStickImage != nil)
        {
            CGRect imageRect;
            float x = CGRectGetMidX(rect);
            float y = CGRectGetMidY(rect);
            CGSize size = CGSizeMake(rect.size.width*0.6, rect.size.height*0.6);
            imageRect.origin.x = x - size.width/2;
            imageRect.origin.y = y - size.height/2;
            imageRect.size = size;
            [centerStickImage drawInRect:imageRect];
        }        
    }
    else
    {
        UIImage *image = [images objectAtIndex:currentDirection];
        [image drawInRect:rect];
    }

#if DRAW_OVERLAY
    float d = minDistance;
    CGContextSetRGBStrokeColor(c, 0, 1, 0, 0.5);
    CGContextSetLineWidth(c, 2);
    CGContextStrokeEllipseInRect(c, rect);
    
    CGPoint center = CGPointMake(CGRectGetMidX(rect),
                                 CGRectGetMidY(rect));
    
    // Draw Up
    if (currentDirection == DPadUp)
    {
        CGContextSetRGBStrokeColor(c, 1, 0, 0, 0.5);
    }
    else
    {
        CGContextSetRGBStrokeColor(c, 0, 1, 0, 0.5);
    }
    
    CGContextMoveToPoint(c, center.x, center.y-d);
    CGContextAddLineToPoint(c, center.x, rect.origin.y);
    CGContextStrokePath(c);
    
    // Draw Down
    if (currentDirection == DPadDown)
    {
        CGContextSetRGBStrokeColor(c, 1, 0, 0, 0.5);
    }
    else
    {
        CGContextSetRGBStrokeColor(c, 0, 1, 0, 0.5);
    }
    
    CGContextMoveToPoint(c, center.x, center.y+d);
    CGContextAddLineToPoint(c, center.x, rect.origin.y + rect.size.height);
    CGContextStrokePath(c);
    
    // Draw Left
    if (currentDirection == DPadLeft)
    {
        CGContextSetRGBStrokeColor(c, 1, 0, 0, 0.5);
    }
    else
    {
        CGContextSetRGBStrokeColor(c, 0, 1, 0, 0.5);
    }
    
    CGContextMoveToPoint(c, rect.origin.x, center.y);
    CGContextAddLineToPoint(c, center.x-d, center.y);
    CGContextStrokePath(c);
    
    // Draw Right
    if (currentDirection == DPadRight)
    {
        CGContextSetRGBStrokeColor(c, 1, 0, 0, 0.5);
    }
    else
    {
        CGContextSetRGBStrokeColor(c, 0, 1, 0, 0.5);
    }
    
    CGContextMoveToPoint(c, center.x+d, center.y);
    CGContextAddLineToPoint(c, rect.origin.x + rect.size.width, center.y);
    CGContextStrokePath(c);
#endif
}

- (float)distantFrom:(CGPoint)pt1 to:(CGPoint)pt2
{
    return sqrt( (pt1.x-pt2.x) * (pt1.x-pt2.x) + (pt1.y-pt2.y) * (pt1.y-pt2.y));
}

- (DPadDirection)directionOfPoint:(CGPoint)pt
{
    static DPadDirection eight_way_map[] = {
        DPadLeft, DPadLeftDown, DPadLeftDown, DPadDown, 
        DPadDown, DPadRightDown, DPadRightDown, DPadRight,
        DPadRight, DPadRightUp, DPadRightUp, DPadUp,
        DPadUp, DPadLeftUp, DPadLeftUp, DPadLeft
    };
    static DPadDirection four_way_map[] = {
        DPadLeft, DPadLeft, DPadDown, DPadDown, 
        DPadDown, DPadDown, DPadRight, DPadRight,
        DPadRight, DPadRight, DPadUp, DPadUp,
        DPadUp, DPadUp, DPadLeft, DPadLeft
    };
    
    CGPoint ptCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    double angle = atan2(ptCenter.y-pt.y, pt.x-ptCenter.x);
    int index =  (int)( (angle+M_PI) / (M_PI/8)) % 16;
    return useArrowsKeys?four_way_map[index]:eight_way_map[index];
}

- (void)setUseArrowKeys:(BOOL)b
{
    if (useArrowsKeys == b) return;
    
    // Before switching DPAD mode
    // Make sure our state is rest state.
    if (currentDirection != DPadNone)
    {
        [self setCurrentDirection:DPadNone];
    }
    useArrowsKeys = b;
    [self setNeedsDisplay];
}


- (void)setCurrentDirection:(DPadDirection)dir
{
    if (dir != currentDirection) 
    {
        if (useArrowsKeys)
        {
            switch (currentDirection)
            {
                case DPadLeft:
                    SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_LEFT);
                    break;
                case DPadRight:
                    SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_RIGHT);
                    break;
                case DPadUp:
                    SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_UP);
                    break;
                case DPadDown:
                    SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_DOWN);
                    break;
                default:
                    break;
            }            
            
            switch (dir)
            {
                case DPadLeft:
                    SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_LEFT);
                    break;                
                case DPadRight:
                    SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_RIGHT);
                    break;                
                case DPadUp:
                    SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_UP);
                    break;                
                case DPadDown:
                    SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_DOWN);
                    break;
                default:
                    break;
            }
        }
        
        currentDirection = dir;        
        [self setNeedsDisplay];
    }
}

- (void)playSound
{
    if (quiet) return;
    if (sound_joystick_move == 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"joystickmove" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&sound_joystick_move);
    }
    if (sound_joystick_move != 0) AudioServicesPlaySystemSound(sound_joystick_move);
}

- (void)updateJoystickAxis:(CGPoint)offset
{
    if (useArrowsKeys) 
        return;
    
    float r = (self.bounds.size.width / 2) * 0.618;
    float x = offset.x / r;
    float y = -offset.y / r;
    if (x > 1.0) x = 1.0;
    if (x < -1.0) x = -1.0;
    if (y > 1.0) y = 1.0;
    if (y < -1.0) y = -1.0;
	[[DOSPadEmulator sharedInstance] updateJoystick:0 x:x y:y];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    CGPoint ptCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self updateJoystickAxis:CGPointMake(pt.x-ptCenter.x, pt.y-ptCenter.y)];

    DPadDirection dir;
    if ([self distantFrom:pt to:ptCenter] < minDistance) {
        dir = DPadNone;
    } else {
        dir = [self directionOfPoint:pt];
    }
    
    if (dir != currentDirection)
    {
        [self playSound];        
    }
    [self setCurrentDirection:dir];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    CGPoint ptCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);

    [self updateJoystickAxis:CGPointMake(pt.x-ptCenter.x, pt.y-ptCenter.y)];
    
    DPadDirection dir;
    if ([self distantFrom:pt to:ptCenter] < minDistance) {
        dir = DPadNone;
    } else {
        dir = [self directionOfPoint:pt];
    }
    if (dir != currentDirection)
    {
        [self playSound];        
    }
    [self setCurrentDirection:dir];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateJoystickAxis:CGPointZero];
    [self setCurrentDirection:DPadNone];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint ptCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    return [self distantFrom:point to:ptCenter] < self.bounds.size.width/2;
}

@end

@implementation GamePadButton
@synthesize buttonIndex;
@synthesize pressed;
@synthesize keyCode;
@synthesize keyCode2;
@synthesize style;
@synthesize title;
@synthesize images;
@synthesize joy;
@synthesize quiet;
@synthesize showFire;
@synthesize textColor;

- (float)distantFrom:(CGPoint)pt1 to:(CGPoint)pt2
{
    return sqrt( (pt1.x-pt2.x) * (pt1.x-pt2.x) + (pt1.y-pt2.y) * (pt1.y-pt2.y));
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (style == GamePadButtonStyleCircle)
    {
        CGPoint ptCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        return [self distantFrom:point to:ptCenter] < self.bounds.size.width/2;
    }
    else
    {
        return [super pointInside:point withEvent:event];
    }
}


- (void)setTitle:(NSString *)s
{
    title = s;
    [self setNeedsDisplay];
}

- (void)setPressed:(BOOL)b
{
    pressed = b;
    [self setNeedsDisplay];
}

- (void)setStyle:(GamePadButtonStyle)s
{
    style = s;
    [self setNeedsDisplay];
}

- (void)setJoy:(BOOL)b
{
    joy = b;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor=[UIColor clearColor];
        quiet = !DEFS_GET_INT(kGamePadSoundEnabled);
        self.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.pressed=YES;
    if (!joy)
    {
        if (keyCode > 0) SDL_SendKeyboardKey( 0, SDL_PRESSED, keyCode);
        if (keyCode2 > 0) SDL_SendKeyboardKey( 0, SDL_PRESSED, keyCode2);
    }
    else
    {
    	[[DOSPadEmulator sharedInstance] joystickButton:buttonIndex pressed:YES joystickIndex:0];
    }
    
    if (!quiet)
    {
        if (sound_joystick_button_click == 0) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"joystickbtn" ofType:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&sound_joystick_button_click);
        }
        if (sound_joystick_button_click != 0) AudioServicesPlaySystemSound(sound_joystick_button_click);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.pressed=NO;
    if (!joy)
    {
        if (keyCode2 > 0) SDL_SendKeyboardKey( 0, SDL_RELEASED, keyCode2);
        if (keyCode > 0) SDL_SendKeyboardKey( 0, SDL_RELEASED, keyCode);
    }
    else
    {
    	[[DOSPadEmulator sharedInstance] joystickButton:buttonIndex pressed:NO joystickIndex:0];
    }
}

-(void)drawRoundedRectangle
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // If you were making this as a routine, you would probably accept a rectangle
    // that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
    CGRect rrect = self.bounds;
    
    CGFloat radius = 6;
    // NOTE: At this point you may want to verify that your radius is no more than half
    // the width and height of your rectangle, as this technique degenerates for those cases.
	
    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGContextAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.
	
    // In order to create the 4 arcs correctly, we need to know the min, mid and max positions
    // on the x and y lengths of the given rectangle.
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
    // Next, we will go around the rectangle in the order given by the figure below.
    //       minx    midx    maxx
    // miny    2       3       4
    // midy   1 9              5
    // maxy    8       7       6
    // Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
    // form a closed path, so we still need to close the path to connect the ends correctly.
    // Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
    // You could use a similar tecgnique to create any shape with rounded corners.
	
    //	// Start at 1
    //	CGContextMoveToPoint(context, minx, midy);
    //	// Add an arc through 2 to 3
    //	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    //	// Add an arc through 4 to 5
    //	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    //	// Add an arc through 6 to 7
    //	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    //	// Add an arc through 8 to 9
    //	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    //	// Close the path
    //	CGContextClosePath(context);
    //	// Fill & stroke the path
    //	CGContextDrawPath(context, kCGPathFillStroke);    
    CGContextSetLineWidth(context, 2);
    
    CGContextMoveToPoint(context, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    // Close the path
    CGContextClosePath(context);    
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextMoveToPoint(context, minx+radius, miny);
    CGContextAddLineToPoint(context, maxx-radius, miny);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, minx+radius, maxy);
    CGContextAddLineToPoint(context, maxx-radius, maxy);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, minx, miny+radius);
    CGContextAddLineToPoint(context, minx, maxy-radius);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, maxx, miny+radius);
    CGContextAddLineToPoint(context, maxx, maxy-radius);
    CGContextStrokePath(context);
    
}


- (void)drawRect:(CGRect)rect 
{
    int bkgIndex;
    UIColor *color = nil;
    
    if (!pressed)
    {
        color = [textColor colorWithAlphaComponent:0.3];
        bkgIndex = 0;
    }
    else
    {
        color = [textColor colorWithAlphaComponent:0.8];
        bkgIndex = 1;
    }
    
    if ([images count] > bkgIndex)
    {
        UIImage *image = [images objectAtIndex:bkgIndex];
        [image drawInRect:rect];
    }
    
    NSString *label = nil;
    if (buttonIndex >= 0)
    {
        if (joy)
        {
            label = [NSString stringWithFormat:@"%d",buttonIndex];
        }
        else
        {
            label = title;
        }
        
        if (label)
        {
            float fontSize = MIN(10, rect.size.height/4);
            
            UIFont *fnt = [UIFont systemFontOfSize:fontSize];
            CGSize size = [label sizeWithFont:fnt];
            [color set];
            [label drawInRect:CGRectMake((rect.size.width-size.width)/2, 
                                         (rect.size.height-size.height)/2,
                                         size.width, size.height) withFont:fnt];
        }
    }
    else if (showFire)
    {
        UIImage *image = [UIImage imageNamed:pressed?@"firepressed.png":@"fire.png"];
        CGSize size = [image size];
        [image drawInRect:CGRectMake((rect.size.width-size.width)/2, 
                                     (rect.size.height-size.height)/2,
                                     size.width, size.height)];
    }

#if DRAW_OVERLAY
    [[UIColor greenColor] set];
    if (style == GamePadButtonStyleCircle) {
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(c, 2);
        CGContextStrokeEllipseInRect(c, rect);        
    } else {
        [self drawRoundedRectangle];        
    }
#endif
}

@end

@implementation GamePadView
@synthesize floating;
@synthesize mode;
@synthesize dpadMovable;

- (void)updateDPadImages
{
    if (floating)
    {
        if (GamePadJoystick == mode)
        {
            NSArray *a = [NSArray arrayWithObjects:
                          [UIImage imageNamed:@"glass-centre"],
                          [UIImage imageNamed:@"glass-east"],
                          [UIImage imageNamed:@"glass-northeast"],
                          [UIImage imageNamed:@"glass-north"],
                          [UIImage imageNamed:@"glass-northwest"],
                          [UIImage imageNamed:@"glass-west"],
                          [UIImage imageNamed:@"glass-southwest"],
                          [UIImage imageNamed:@"glass-south"],
                          [UIImage imageNamed:@"glass-southeast"],
                          nil];
            dpad.backgroundImage=nil;
            dpad.centerStickImage=nil;
            dpad.sidedStickImage=nil;
            dpad.images = a;
        }
        else
        {
            dpad.backgroundImage = [UIImage imageNamed:@"dpadglass"];
            dpad.centerStickImage = nil;
            dpad.sidedStickImage = [UIImage imageNamed:@"dpadpressed"];
            dpad.images=nil;
        }
    }
    else if (GamePadDefault == mode)
    {
        dpad.backgroundImage = [UIImage imageNamed:@"dpad"];
        dpad.centerStickImage = nil;
        dpad.sidedStickImage = [UIImage imageNamed:@"dpadpressed"];
        dpad.images=nil;
    }
    else
    {
        NSArray *a = [NSArray arrayWithObjects:
                      [UIImage imageNamed:@"centre"],
                      [UIImage imageNamed:@"east"],
                      [UIImage imageNamed:@"northeast"],
                      [UIImage imageNamed:@"north"],
                      [UIImage imageNamed:@"northwest"],
                      [UIImage imageNamed:@"west"],
                      [UIImage imageNamed:@"southwest"],
                      [UIImage imageNamed:@"south"],
                      [UIImage imageNamed:@"southeast"],
                      nil];
        dpad.backgroundImage=nil;
        dpad.centerStickImage=nil;
        dpad.sidedStickImage=nil;
        dpad.images = a;
    }

}

- (void)setMode:(GamePadMode)m
{
    mode = m;
    if (m == GamePadDefault)
    {
        dpad.useArrowKeys = YES;
        for (int i = 0; i < 2; i++)
        {
            btn[i].joy = NO;
        }
    }
    else
    {
        dpad.useArrowKeys = NO;
        dpad.quiet = YES; // FIXME: Sound not natural...
        for (int i = 0; i < 2; i++)
        {
            btn[i].joy = YES;
        }        
    }
    [self updateDPadImages];
}

- (void)setFloating:(BOOL)b
{
    floating = b;
    if (b) 
    {
        NSArray *a = [NSArray arrayWithObjects:
                      [UIImage imageNamed:@"btn"],
                      [UIImage imageNamed:@"btnpressed"],nil];
        btn[0].images = a;
        btn[0].showFire = YES;
        a = [NSArray arrayWithObjects:
             [UIImage imageNamed:@"btn"],
             [UIImage imageNamed:@"btnpressed"],nil];
        for (int i = 0; i < MAX_GAMEPAD_BUTTON; i++)
        {
            btn[i].images = a;
            btn[i].textColor = [UIColor whiteColor];
        }
    }
    else
    {
        NSArray *a = [NSArray arrayWithObjects:
                      [UIImage imageNamed:@"button"],
                      [UIImage imageNamed:@"buttonpressed"],nil];
	
        btn[0].showFire = NO;
        for (int i = 0; i < MAX_GAMEPAD_BUTTON; i++)
        {
            btn[i].images = a;
            btn[i].textColor = [UIColor blackColor];
        }
    }
    [self updateDPadImages];
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Remember that the point can be outside bounds
    if (floating && dpadMovable && point.x < self.bounds.size.width/2)
    {
        return YES;
    }
    
    NSArray *subviews = self.subviews;
    for (int i = 0; i < [subviews count]; i++)
    {
        UIView *view = [subviews objectAtIndex:i];
        if ([view pointInside:[self convertPoint:point toView:view] withEvent:event])
        {
            return YES;
        }
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (floating && dpadMovable)
    {
        UITouch *touch = [touches anyObject];
        CGPoint pt = [touch locationInView:self];
        dpad.center = pt;
        [dpad touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (floating && dpadMovable)
    {
        [dpad touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (floating && dpadMovable)
    {
        [dpad touchesEnded:touches withEvent:event];
    }
}


- (id)initWithConfig:(NSString*)path section:(NSString*)section
{
    char buf[256];
    char title[64], keyname[64], keyname2[64];
    int x,y,width,height,index;
    char kbind[]="[gamepad.keybinding]";
    BOOL isOverlay = FALSE;
    
    self = [super initWithFrame:CGRectZero];
    if (self == nil)
    {
        return nil;
    }
    
    FILE *fp = fopen([path UTF8String], "r");
    if (fp==NULL)
    {
        return self;
    }
    BOOL found=NO;
    
    while (fgets(buf, 256, fp))
    {
        if (buf[0] != '[') 
            continue;
        if (strncmp(buf, [section UTF8String], [section length]) == 0) 
        {
            found = YES;
            break;
        }
    }
    
    if (found) 
    {
        while (fgets(buf, 256, fp))
        {
            char *p;
            if (buf[0] == '[') 
                break;
            if (buf[0] == '#')
                continue;
            p = buf;
            while (isblank(*p))
                p++;
            if (*p == '\0')
                continue;
            
            if (sscanf(p, "frame=%d,%d,%d,%d", &x,&y,&width,&height) == 4)
            {
                self.frame = CGRectMake(x,y,width,height);
            }
            else if (sscanf(p, "floating=%d", &index) == 1)
            {
                isOverlay = (index == 1);
            }
            else if (sscanf(p, "button%d=%d,%d,%d,%d",&index,&x,&y,&width,&height)==5)
            {
                if (index < MAX_GAMEPAD_BUTTON)
                {
                    btn[index] = [[GamePadButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
                    // Current design prefer rectangle
                    //btn[index].style=GamePadButtonStyleCircle;
                    btn[index].buttonIndex = index;
                    [self addSubview:btn[index]];     
                }
            }
            else if (sscanf(p, "dpad=%d,%d,%d,%d", &x,&y,&width,&height)==4)
            {
                dpad = [[DPadView alloc] initWithFrame:CGRectMake(x, y, width, height)];
                [self addSubview:dpad];
            }
        }
    }
    
    // Read keybindings
    rewind(fp);
    found = NO;
    while (fgets(buf, 256, fp))
    {
        if (strncmp(buf, kbind, strlen(kbind)) == 0) 
        {
            found = YES;
            break;
        }
    }
    
    if (found) 
    {
        while (fgets(buf, 256, fp))
        {
            char *p, *endp;
            if (buf[0] == '[') 
                break;
            if (buf[0] == '#')
                continue;
            p = buf;
            while (isspace(*p))
                p++;
            if (*p == '\0')
                continue;
            endp = p;
            while (*endp != '\0') endp++;
            while (isspace(*(endp-1))) endp--;
            *endp = 0;
            
            if (sscanf(p, "button%d=%[^,],%[^,],%s", &index, title, keyname, keyname2)==4)
            {
                if (index < MAX_GAMEPAD_BUTTON)
                {
                    btn[index].keyCode = get_scancode_for_name(keyname);
                    btn[index].keyCode2 = get_scancode_for_name(keyname2);
                    btn[index].title = [NSString stringWithUTF8String:title];
                }
            }
            else if (sscanf(p, "button%d=%[^,],%s", &index, title, keyname)==3)
            {
                if (index < MAX_GAMEPAD_BUTTON)
                {
                    btn[index].keyCode = get_scancode_for_name(keyname);
                    btn[index].title = [NSString stringWithUTF8String:title];
                }
            }
        }
    }
    
    fclose(fp);
    self.floating = isOverlay;
    self.mode = GamePadDefault;
    dpadMovable = (isOverlay && DEFS_GET_INT(kDPadMovable));
    return self;
}

@end
