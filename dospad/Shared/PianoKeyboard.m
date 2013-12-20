//
//  PianoKeyboard.m
//  dospad
//
//  Created by chaojili on 1/10/11.
//  Copyright 2011 Chaoji Li. All rights reserved.
//

#import "PianoKeyboard.h"
#import "keys.h"
#include "SDL.h"
#import "Common.h"

#define DRAW_OVERLAY  0
extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);

@implementation PianoKey
@synthesize title;
@synthesize pressed;
@synthesize textColor;
@synthesize type;
@synthesize keyCode;
@synthesize keyCode2;
@synthesize index;

- (void)setTitle:(NSString *)s
{
    if (title) [title release];
    title = s;
    [title retain];
    [self setNeedsDisplay];
}

- (void)setPressed:(BOOL)b
{
    pressed = b;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor=[UIColor clearColor];
        self.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.pressed = YES;
    if (keyCode > 0) SDL_SendKeyboardKey( 0, SDL_PRESSED, keyCode);
    if (keyCode2 > 0) SDL_SendKeyboardKey( 0, SDL_PRESSED, keyCode2);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.pressed = NO;
    if (keyCode2 > 0) SDL_SendKeyboardKey( 0, SDL_RELEASED, keyCode2);
    if (keyCode > 0) SDL_SendKeyboardKey( 0, SDL_RELEASED, keyCode);
}

-(void)drawRoundedRectangle:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // If you were making this as a routine, you would probably accept a rectangle
    // that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
    CGRect rrect = rect;
    
    CGFloat radius = 4;
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
    CGContextDrawPath(context, kCGPathFill);
}


- (void)drawRect:(CGRect)rect 
{

    
    if (type == PianoKeyGrid)
    {
        if (title)
        {
            UIColor *color;
            
            if (pressed)
            {
                color = [textColor colorWithAlphaComponent:0.3];
                [color set];
                [self drawRoundedRectangle:rect];
            }
            
            // Draw Title
            float fontSize = MIN(14, rect.size.height/4);
            color = [textColor colorWithAlphaComponent:(pressed?1:0.3)];
            UIFont *fnt = [UIFont systemFontOfSize:fontSize];
            CGSize size = [title sizeWithFont:fnt];
            [color set];
            [title drawInRect:CGRectMake((rect.size.width-size.width)/2, 
                                         (rect.size.height-size.height)/2,
                                         size.width, size.height) withFont:fnt];
        }
    }
    else if (pressed)
    {
        
        UIColor *color;
        if (index < 15)
        {
            color = [textColor colorWithAlphaComponent:0.5];
        }
        else
        {
            color = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        }

        CGRect indicator;
        indicator.size = CGSizeMake(8, 8);
        indicator.origin.x = (rect.size.width - indicator.size.width)/2;
        indicator.origin.y = rect.origin.y + 7;
        [color set];
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextFillEllipseInRect(c, indicator);
    }
        
#if DRAW_OVERLAY
    [[UIColor greenColor] set];
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextStrokeRect(c, rect);        
#endif
}

- (void)dealloc
{
    [title release];
    [textColor release];
    [super dealloc];
}

@end


@implementation PianoKeyboard


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (CGRect)rectForKey:(int)i
{
    if (i >= 25) return CGRectZero;
    
    if (ISIPAD()) 
    {
        if (i < 15) 
        {
            return CGRectMake(12 + i*44, 145, 44, 70);
        } 
        else 
        {
            static float blackHeight = 136;
            static float blackWidth = 40;
            static float xpos[] = 
            {
                30, 82, 162, 210, 259,
                338, 391, 470, 518, 567
            };
            return CGRectMake(xpos[i-15], 5, blackWidth, blackHeight);
        }
    } 
    else 
    {
        if (i < 15)
        {
            return CGRectMake(i*32, 104, 32, 56);
        }
        else
        {
            return CGRectZero;            
        }
    }
}

- (CGRect)rectForGrid:(int)i
{
    if (ISIPAD()) {
        static float xpos[] = {685, 740, 795, 850, 905, 960};
        static float ypos[] = {2, 56, 110, 166};
        return i < 24 ? CGRectMake(xpos[i%6], ypos[i/6], 49, 47) : CGRectZero;
    } else {
        return CGRectZero;
    }
}

- (CGRect)rectForKeyboard
{
    if (ISIPAD()) {
        return CGRectMake(0, 548, 1024, 220);
    } else {
        return CGRectMake(0, 160, 480, 160);
    }
}

- (id)initWithConfig:(NSString*)path section:(NSString*)section
{
    char buf[256];
    char title[64], keyname[64], keyname2[64];
    int index;
    char kbind[]="[piano.keybinding]";
    BOOL found=NO;
    
    self = [super initWithFrame:[self rectForKeyboard]];
    if (self == nil)
    {
        return nil;
    }
    
    FILE *fp = fopen([path UTF8String], "r");
    if (fp == NULL)
    {
        return self;
    }
    
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
            
            if (sscanf(p, "k%d=%[^,],%[^,]", &index, keyname, keyname2)==3)
            {
                if (index < MAX_PIANO_KEYS)
                {
                    keys[index] = [[PianoKey alloc] initWithFrame:[self rectForKey:index]];
                    keys[index].type = PianoKeyButton;
                    keys[index].keyCode = get_scancode_for_name(keyname);
                    keys[index].keyCode2 = get_scancode_for_name(keyname2);
                    keys[index].index = index;
                    [self addSubview:keys[index]];     
                }                
            }
            else if (sscanf(p, "k%d=%[^,]", &index, keyname)==2)
            {
                if (index < MAX_PIANO_KEYS)
                {
                    keys[index] = [[PianoKey alloc] initWithFrame:[self rectForKey:index]];
                    keys[index].type = PianoKeyButton;
                    keys[index].keyCode = get_scancode_for_name(keyname);
                    keys[index].index = index;
                    [self addSubview:keys[index]];     
                }
            }
            else if (sscanf(p, "grid%d=%[^,],%[^,],%[^,]", &index, title, keyname, keyname2)==4)
            {
                if (index < MAX_PIANO_GRIDS)
                {
                    grids[index] = [[PianoKey alloc] initWithFrame:[self rectForGrid:index]];
                    grids[index].type = PianoKeyGrid;
                    grids[index].title = [NSString stringWithUTF8String:title];
                    grids[index].keyCode = get_scancode_for_name(keyname);
                    grids[index].keyCode2 = get_scancode_for_name(keyname2);
                    grids[index].index = index;
                    [self addSubview:grids[index]];     
                }                
            }         
            else if (sscanf(p, "grid%d=%[^,],%[^,]", &index, title, keyname)==3)
            {
                if (index < MAX_PIANO_GRIDS)
                {
                    grids[index] = [[PianoKey alloc] initWithFrame:[self rectForGrid:index]];
                    grids[index].type = PianoKeyGrid;
                    grids[index].title = [NSString stringWithUTF8String:title];
                    grids[index].keyCode = get_scancode_for_name(keyname);
                    grids[index].index = index;
                    [self addSubview:grids[index]];     
                }                
            }
        }
    }
    
    fclose(fp);
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (ISIPAD()) {
        UIImage *image = [UIImage imageNamed:@"25-Keys-with-6x4-grid"];
        [image drawInRect:rect];
    } else {
        UIImage *image = [UIImage imageNamed:@"25-keys"];
        [image drawInRect:rect];
    }
}

- (void)dealloc {
    for (int i = 0; i < MAX_PIANO_KEYS; i++)
        [keys[i] release];
    for (int i = 0; i < MAX_PIANO_GRIDS; i++)
        [grids[i] release];
    [super dealloc];
}


@end
