//
//  DPTheme.h
//  iDOS
//
//  Created by Chaoji Li on 2020/10/26.
//

#import "DPThemeScene.h"
#import "UIColor+hexColor.h"

@interface DPTheme : NSObject

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic) int version;
@property (strong) UIColor *backgroundColor;
@property (strong) UIColor *gamepadTextColor;
@property (strong) UIColor *gamepadEditingTextColor;
- (id)initWithURL:(NSURL*)url;

- (DPThemeScene*)findSceneByName:(NSString*)name;

@end

