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
#import "GIFAnimation.h"
#import "FileSystemObject.h"

@implementation GIFAnimation
@synthesize duration;
@synthesize filePath;

/****************************************************************************************** 
 *
 * Decode the frames from an animated GIF image file
 * Written april 2009 by Martin van Spanje, P-Edge media 
 * http://www.p-edge.nl
 *
 * Based on the following PHP example:
 * http://forums.devnetwork.net/viewtopic.php?f=34&t=93114
 *
 * Which uses the GIF decoder class from László Zsidi:
 * http://www.phpclasses.org/browse/package/3163.html
 * 
 * THIS CODE IS NOT OPTIMIZED AND USES GLOBAL VARIABLES, 
 * BUT IT RESEMBLES THE PHP CODE AS MUCH AS POSSIBLE FOR READABILITY.
 *
 * VARIABLE NAMES ETC. HAVE NOT BEEN CHANGED AND RESEMBLE THE PHP CODE FOR READABILITY
 *
 * Please improve and optimize at will.
 *
 */

- (int)GIFGetBytes:(int)length
{
	[GIF_buffer setData:[NSData data]];
	if ([GIF_pointer length] >= dataPointer + length) {
		[GIF_buffer setData:[GIF_pointer subdataWithRange:NSMakeRange(dataPointer, length)]];
		dataPointer += length;
		return 1;
	} else {
		return 0;
	}
}

- (void)GIFPutBytes:(NSData *)bytes
{
	[GIF_string appendData:bytes];
}

- (void)GIFReadExtensions
{
	[self GIFGetBytes:1];
	
	for ( ; ; ) {
		[self GIFGetBytes:1];
		unsigned char aBuffer[1];
		[GIF_buffer getBytes:aBuffer length:1];
        
		long u = (int)aBuffer[0];
		if (u == 0x00) {
			break;
		}
		[self GIFGetBytes:u];
		unsigned char bBuffer[u];
		[GIF_buffer getBytes:bBuffer length:u];
		
		if (u == 4) {
			[GIF_delays addObject:[NSNumber numberWithInt:(bBuffer[1] | bBuffer[2] << 8)]];
		}
	}	
}

- (void)GIFReadDescriptor
{	
	NSMutableData *GIF_screenTmp = [[NSMutableData alloc] init];
	[self GIFGetBytes:9];
	[GIF_screenTmp setData:GIF_buffer];
	
	size_t alength = [GIF_buffer length];
	unsigned char aBuffer[alength];
	[GIF_buffer getBytes:aBuffer length:alength];
	
	
	if (aBuffer[8] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
	
	unsigned char GIF_code, GIF_sort;
	
	if (GIF_colorF == 1) {
		GIF_code = (aBuffer[8] & 0x07);
		if (aBuffer[8] & 0x20) GIF_sort = 1; else GIF_sort = 0;
	} else {
		GIF_code = GIF_colorC;
		GIF_sort = GIF_sorted;
	}
	
	int GIF_size = (2 << GIF_code);
	
	
	size_t blength = [GIF_screen length];
	unsigned char bBuffer[blength];
	[GIF_screen getBytes:bBuffer length:blength];
    
	bBuffer[4] = (bBuffer[4] & 0x70);
	bBuffer[4] = (bBuffer[4] | 0x80);
	bBuffer[4] = (bBuffer[4] | GIF_code);
	
	if (GIF_sort) {
		bBuffer[4] |= 0x08;
	}
    
	[GIF_string setData:[[NSString stringWithString:@"GIF89a"] dataUsingEncoding: NSASCIIStringEncoding]];
	[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
	[self GIFPutBytes:GIF_screen];
    
	if (GIF_colorF == 1) {
		[self GIFGetBytes:(3 * GIF_size)];
		[self GIFPutBytes:GIF_buffer];
	} else {
		[self GIFPutBytes:GIF_global];
	}
	
	char endC = 0x2c;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	size_t clength = [GIF_screenTmp length];
	unsigned char cBuffer[clength];
	[GIF_screenTmp getBytes:cBuffer length:clength];
    
	cBuffer[8] &= 0x40;
    
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
	
	[self GIFPutBytes:GIF_screenTmp];
	[self GIFGetBytes:1];
	[self GIFPutBytes:GIF_buffer];
	
	for ( ; ; ) {
		[self GIFGetBytes:1];
		[self GIFPutBytes:GIF_buffer];
		
		size_t dlength = [GIF_buffer length];
		unsigned char dBuffer[1];
		[GIF_buffer getBytes:dBuffer length:dlength];
		
		long u = (int)dBuffer[0];
		if (u == 0x00) {
			break;
		}
		[self GIFGetBytes:u];
		[self GIFPutBytes:GIF_buffer];
	}
	
	endC = 0x3b;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
    
	// save the frame into the array of frames
	[GIF_framesData addObject:[GIF_string copy]];
}


// the decoder
- (void)decodeGIF:(NSData *)GIFData
// decodes GIF image data into separate frames
{
	GIF_pointer = [NSData dataWithData:GIFData];
	
	[GIF_buffer setData:[NSData data]];
	[GIF_screen setData:[NSData data]];
	[GIF_delays removeAllObjects];
	[GIF_framesData removeAllObjects];
	[GIF_string setData:[NSData data]];
	[GIF_global setData:[NSData data]];
	
	dataPointer = 0;
	frameCounter = 0;
	
	[self GIFGetBytes:6]; // GIF89a
	[self GIFGetBytes:7];; // Logical Screen Descriptor
	
	[GIF_screen setData:GIF_buffer];
	
	size_t length = [GIF_buffer length];
	unsigned char aBuffer[length];
	[GIF_buffer getBytes:aBuffer length:length];
	
	if (aBuffer[4] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
	if (aBuffer[4] & 0x08) GIF_sorted = 1; else GIF_sorted = 0;
	GIF_colorC = (aBuffer[4] & 0x07);
	GIF_colorS = 2 << GIF_colorC;
	
	if (GIF_colorF == 1) {
		[self GIFGetBytes:(3 * GIF_colorS)];
		[GIF_global setData:GIF_buffer];
	}
	
	for (int cycle = 1; cycle;) {
		if ([self GIFGetBytes:1] == 1) {
			unsigned char aBuffer[1];
			[GIF_buffer getBytes:aBuffer length:1];
            
			switch (aBuffer[0]) {
				case 0x21:
					[self GIFReadExtensions];
					break;
				case 0x2C:
					[self GIFReadDescriptor];
					break;
				case 0x3B:
					cycle = 0;
					break;
			}
		} else {
			cycle = 0;
		}
	}
	
	// clean up stuff
	[GIF_buffer setData:[NSData data]];
	[GIF_screen setData:[NSData data]];
	[GIF_string setData:[NSData data]];
	[GIF_global setData:[NSData data]];	
}

/* GIF_framesData now contains an array of NSData objects, each object is a GIF frame
 * GIF_delays now contains the delay time for each frame
 * these can be animated by using (for example) an NStimer
 *
 * ATTENTION!
 * +(UIImage *)imageWithData:(NSData *)data will not display the GIF frame correctly!
 * 
 * to solve this you need to first write the NSData for each frame to a file
 * with a ".gif" extension in the filename and then use:
 *
 * + (UIImage *)imageWithContentsOfFile:(NSString *)path
 *
 * ...to display the frame correctly. Don't ask me why but the iPhone OS garbles the image
 * because it does not know it's a GIF file.
 *
 * Anyone who can directly convert the GIF image data to a UIImage without it being garbled
 * please contact me :)
 *
 */

/*************** END OF GIF DECODING **************************/

- (int)frameCount
{
    return [GIF_framesData count];
}

- (UIImage*)getFrame:(int)index
{
    NSData *data = [GIF_framesData objectAtIndex:index];
    NSString *name = [[filePath lastPathComponent] stringByDeletingPathExtension];
    NSString *tmpname = [NSString stringWithFormat:@"%@%d.gif", name?name:@"splash", index];
    NSString *tmpfile = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpname];
    if ([data writeToFile:tmpfile atomically:NO])
    {
        return [UIImage imageWithContentsOfFile:tmpfile];
    }
    else
    {
        NSLog(@"Error get frame: %@", tmpfile);
        return nil;
    }
}

- (id)initWithGIFFile:(NSString*)path
{
    filePath = [path retain];
    GIF_buffer = [[NSMutableData alloc] init];
    GIF_screen = [[NSMutableData alloc] init];
    GIF_delays = [[NSMutableArray alloc] init];
    GIF_framesData = [[NSMutableArray alloc] init];
    GIF_string = [[NSMutableData alloc] init];
    GIF_global = [[NSMutableData alloc] init];
    
    [self decodeGIF:[NSData dataWithContentsOfFile:path]];
    
    int cnt = [self frameCount];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:cnt];
    for (int i = 0; i < cnt; i++)
    {
        UIImage *img = [self getFrame:i];
        if (img)
        {
            [images addObject:img];
        }
        else
        {
            NSLog(@"invalid frame");
        }
    }

    cnt = [GIF_delays count];
    for (int i = 0; i < cnt; i++)
    {
        NSNumber *nb = [GIF_delays objectAtIndex:i];
        if ([nb intValue] != 0)
        {
            int j;
            for (j = i - 1; j >= 0; j--)
            {
                if ([[GIF_delays objectAtIndex:j] floatValue] > 0)
                    break;
            }
            float averageDelay = [nb intValue]/1000.0f/(i-j);
            for (j++; j <= i; j++)
            {
                [GIF_delays replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:averageDelay]];
            }
        }
    }
    
    self.animationImages = images;
    if ([images count] > 0)
    {
        return [self initWithImage:[images objectAtIndex:0]];
    }
    else
    {
        return [self initWithFrame:CGRectZero];
    }
}

- (void)showFrame:(int)index
{
    if ([self.animationImages count] > index)
    {
        self.image = [self.animationImages objectAtIndex:index];
    }
}

- (void)showNextFrame
{
    if (++currentFrameIndex >= [self.animationImages count])
        return;
    [self showFrame:currentFrameIndex];
    float delay = 0.1; 
    if (duration > 0)
    {
        delay = duration / [self frameCount];
    }
    else if (currentFrameIndex < [GIF_delays count])
    {
        delay = [[GIF_delays objectAtIndex:currentFrameIndex] floatValue];
    }
    [self performSelector:@selector(showNextFrame) withObject:nil afterDelay:delay];
}

- (void)startAnimating
{
    currentFrameIndex = -1;
    [self showNextFrame];
}

- (void)stopAnimating
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(showNextFrame)
                                               object:nil];
}

- (void)dealloc 
{        
    [filePath release];
    [GIF_buffer release];
    [GIF_screen release];
    [GIF_global release];
    [GIF_string release];
    [GIF_delays release];
    [GIF_framesData release];
    [super dealloc];
}
@end
