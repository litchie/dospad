//
//  SoundEffect.m
//
//  Created by Chaoji Li on 2020/9/2.
//  Copyright © 2020 Chaoji Li. All rights reserved.
//

#import "SoundEffect.h"
#import <AudioToolbox/AudioServices.h>

static NSMutableDictionary *_sounds = nil;
@implementation SoundEffect

+ (void)play:(NSString *)name
{
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"play_sound"])
		return;
		
	if (_sounds == nil)
		_sounds = [NSMutableDictionary dictionary];
	SystemSoundID soundId = 0;
	if (!_sounds[name])
	{
	    NSURL *url = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"sounds/%@.mp3", name]];
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
