#import "DPThemeScene.h"
#import "DPThemeSceneView.h"

@class DPGamepad;
@class DPGamepadConfiguration;

typedef NS_ENUM(NSInteger, DPGamepadButtonIndex) {
    DP_GAMEPAD_BUTTON_INVALID,
    DP_GAMEPAD_BUTTON_A,
    DP_GAMEPAD_BUTTON_B,
    DP_GAMEPAD_BUTTON_DOWN,
    DP_GAMEPAD_BUTTON_L1,
    DP_GAMEPAD_BUTTON_L2,// trigger
    DP_GAMEPAD_BUTTON_LEFT,
    DP_GAMEPAD_BUTTON_R1,
    DP_GAMEPAD_BUTTON_R2,
    DP_GAMEPAD_BUTTON_RIGHT,
    DP_GAMEPAD_BUTTON_UP,
    DP_GAMEPAD_BUTTON_X,
    DP_GAMEPAD_BUTTON_Y,
    DP_GAMEPAD_BUTTON_TOTAL
};

@protocol DPGamepadDelegate
- (void)gamepad:(DPGamepad*)gamepad buttonIndex:(DPGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed;
- (void)gamepad:(DPGamepad*)gamepad didJoystickMoveWithX:(float)x y:(float)y;
@end

/*
 * A direction code has 4 bits. Each bit indicates a direction:
 *
 *    3   2    1    0
 *  Down Left Up Right
 *
 * In this way we can infer key changes with a XOR between current
 * direction and previous direction.
 *
 *          0010
 *   0110     |    0011
 *            |
 * 0100 ------+------- 0001
 *            |
 *    1100    |   1001
 *          1000
 */
typedef enum
{
	DPGamepadDPadDirectionNone      = 0,
	DPGamepadDPadDirectionRight     = 1,
	DPGamepadDPadDirectionRightUp   = 3,
	DPGamepadDPadDirectionUp        = 2,
	DPGamepadDPadDirectionLeftUp    = 6,
	DPGamepadDPadDirectionLeft      = 4,
	DPGamepadDPadDirectionLeftDown  = 12,
	DPGamepadDPadDirectionDown      = 8,
	DPGamepadDPadDirectionRightDown = 9
} DPGamepadDPadDirection;

@interface DPGamepadDPad : UIView
{
	DPGamepadDPadDirection currentDirection;
	float minDistance;
	UIImage *backgroundImage;
	NSArray *images;
	BOOL fourWay;
}
@property (weak) DPGamepad *gamepad;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) DPGamepadDPadDirection currentDirection;
@property (nonatomic, assign) BOOL fourWay;

@end

@interface DPGamepadJoystick: UIView
@property (weak) DPGamepad *gamepad;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *hatImage;
@property (nonatomic, assign) CGPoint axisPosition;
@end

typedef enum
{
    DPGamePadButtonStyleRoundedRectangle,
    DPGamePadButtonStyleCircle,
} DPGamepadButtonStyle;
    
@class DPGamepadButton;


@interface DPGamepadButton : UIView

@property (nonatomic, weak) DPGamepad* gamepad;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) DPGamepadButtonIndex buttonIndex;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) BOOL pressed;
@property (nonatomic, assign) DPGamepadButtonStyle style;
@property (nonatomic, weak) UITouch *prevtouch;

@end

////////////////////////////////////////////////////////
// MARK: DPGamepad

@interface DPGamepad : DPThemeSceneView

@property (nonatomic,assign) BOOL editing;
@property (nonatomic,assign) BOOL gravity;
@property (nonatomic,strong) id<DPGamepadDelegate> gamepadDelegate;
@property (nonatomic,readonly) NSMutableArray *buttons;
@property (nonatomic,strong) DPGamepadDPad *dpad;
@property (nonatomic,strong) DPGamepadJoystick *stick;
@property (nonatomic, assign) BOOL stickMode;
@property (nonatomic, strong) DPGamepadConfiguration *config;
- (void)applyConfiguration:(DPGamepadConfiguration*)config;

+ (NSString*)buttonIdForIndex:(DPGamepadButtonIndex)buttonIndex;
+ (DPGamepadButtonIndex)buttonIndexForId:(NSString*)buttonId;

@end
