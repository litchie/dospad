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

@interface GIFAnimation : UIImageView
{
    NSData *GIF_pointer;
    NSMutableData *GIF_buffer;
    NSMutableData *GIF_screen;
    NSMutableData *GIF_global;
    NSMutableData *GIF_string;
    
    NSMutableArray *GIF_delays;
    NSMutableArray *GIF_framesData;
    
    int GIF_sorted;
    int GIF_colorS;
    int GIF_colorC;
    int GIF_colorF;
    
    int dataPointer;
    int frameCounter;	
    int currentFrameIndex;
    
    NSString *filePath; /* GIF file path */
    float duration; /* GIF animation duration */
}

@property (nonatomic, assign) float duration;
@property (nonatomic, readonly) NSString *filePath;

- (id)initWithGIFFile:(NSString*)path;

@end
