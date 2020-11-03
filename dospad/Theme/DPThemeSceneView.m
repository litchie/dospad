//
//  DPThemeSceneView.m
//  iDOS
//
//  Created by Chaoji Li on 2020/10/28.
//

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
