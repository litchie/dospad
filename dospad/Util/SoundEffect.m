/*
 *  Copyright (C) 2020-2024 Chaoji Li
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


#import "SoundEffect.h"
#import <AudioToolbox/AudioServices.h>

static NSMutableDictionary *_sounds = nil;
@implementation SoundEffect

+ (void)play:(NSString *)name
{
	if (_sounds == nil)
		_sounds = [NSMutableDictionary dictionary];
	SystemSoundID soundId = 0;
	if (!_sounds[name])
	{
	    NSURL *url = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:name];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundId);
		_sounds[name] = @(soundId);
	}
	
	soundId = [(NSNumber*)_sounds[name] unsignedIntValue];
	if (soundId != 0)
	{
		AudioServicesPlaySystemSound(soundId);
	}
}

@end
