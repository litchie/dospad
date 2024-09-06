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


#import "DPThemeSceneView.h"

@implementation DPButton
@end

@interface DPThemeSceneView ()
@property (nonatomic, strong) NSMutableDictionary<NSString*,UIView*> *components;
@end

@implementation DPThemeSceneView

- (id)initWithFrame:(CGRect)frame scene:(DPThemeScene*)scene
{
	if (self = [super initWithFrame:frame]) {
		self.userInteractionEnabled = YES;
		self.components = [NSMutableDictionary dictionary];
		_scene = scene;
		CGFloat vw = frame.size.width;
		CGFloat vh = frame.size.height;
		CGFloat scaleX = vw / scene.size.width;
		CGFloat scaleY = vh / scene.size.height;
		CGFloat offsetX = 0;
		CGFloat offsetY = 0;
		if (scene.scaleMode == DPThemeSceneScaleNone) {
			scaleX = 1;
			scaleY = 1;
			offsetX = (vw - scene.size.width)/2;
			offsetY = (vh - scene.size.height)/2;
		} else if (scene.scaleMode == DPThemeSceneScaleAspectFill) {
			CGFloat scale = MIN(scaleX, scaleY);
			offsetX = (vw - scene.size.width * scale)/2;
			offsetY = (vh - scene.size.height * scale)/2;
			scaleX = scale;
			scaleY = scale;
		}
		
		if (scene.backgroundColor)
			self.backgroundColor = scene.backgroundColor;
		
		if (scene.backgroundImageURL) {
			self.image = [UIImage imageWithContentsOfFile:scene.backgroundImageURL.path];
		}
		for (NSDictionary *x in scene.nodes)
		{
			CGRect frame = CGRectZero;
			if (x[@"frame"]) {
				NSArray *t = x[@"frame"];
				frame.origin.x    = [t[0] floatValue] * scaleX + offsetX;
				frame.origin.y    = [t[1] floatValue] * scaleY + offsetY;
				frame.size.width  = [t[2] floatValue] * scaleX;
				frame.size.height = [t[3] floatValue] * scaleY;
			}
			BOOL hidden = [x[@"hidden"] boolValue];
			NSString *type = x[@"type"];
							
			if ([type isEqualToString:@"button"])
			{
				DPButton *btn = [[DPButton alloc] initWithFrame:frame];
				[btn setImage:[scene getImage:x[@"bg"]]
					forState:UIControlStateNormal];
				[btn setImage:[scene getImage:x[@"bg-pressed"]]
					forState:UIControlStateHighlighted];
				[self registerButton:btn name:x[@"id"]];
				btn.hidden = hidden;
				[self addSubview:btn];
			}
			else if ([type isEqualToString:@"image"])
			{
				UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
				iv.image = [scene getImage:x[@"bg"]];
				iv.hidden = hidden;
				[self addSubview:iv];
			}
			else
			{
				UIView *v = [self createComponent:frame attributes:x];
				if (v) {
					v.hidden = hidden;
					[self addSubview:v];
				}
			}
		}
	}
	return self;
}

- (UIView*)createComponent:(CGRect)frame attributes:(NSDictionary*)attrs
{
	if (self.delegate) {
		UIView *v = [self.delegate sceneView:self createComponent:frame attributes:attrs];
		if (v) return v;
	}
	return nil;
}

- (BOOL)didButtonPress:(DPButton*)button
{
	NSLog(@"didButtonPress: %@", button.name);
	if (self.delegate && [self.delegate sceneView:self didButtonPress:button]) {
		return YES;
	}
	return NO;
}

- (void)registerButton:(DPButton*)btn name:(NSString*)name
{
	if (name) {
		btn.name = name;
		self.components[name] = btn;
	}
	[btn addTarget:self action:@selector(didButtonPress:)
		forControlEvents:UIControlEventTouchUpInside];
//	[btn addTarget:self action:@selector(didButtonPress:)
//		forControlEvents:UIControlEventTouchDown];
//	[btn addTarget:self action:@selector(didButtonPress:)
//		forControlEvents:UIControlEventTouchUpOutside];
}

@end
