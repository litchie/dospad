//
//  DPThemeScene.h
//  iDOS
//
//  Created by Chaoji Li on 2020/10/27.
//
@class DPTheme;

typedef enum {
	DPThemeSceneScaleNone,
	DPThemeSceneScaleAspectFill,
	DPThemeSceneScaleFill
} DPThemeSceneScaleMode;

@interface DPThemeScene : NSObject
@property (nonatomic, strong) NSURL *backgroundImageURL;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) NSArray<NSDictionary*> *nodes;
@property CGSize size;
@property (nonatomic, readonly) BOOL isPortrait;
@property (nonatomic, weak) DPTheme *theme;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) DPThemeSceneScaleMode scaleMode;

- (id)initWithAttributes:(NSDictionary*)attrs theme:(DPTheme*)theme;
- (UIImage*)getImage:(NSString*)name;
- (NSObject*)getAttribute:(NSString*)name;
@end

