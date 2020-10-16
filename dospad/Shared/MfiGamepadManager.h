//
// MfiGamepadManager.h
//
// Manage Mfi (Made for iPhone) controller connection and input events.
// We support up to 4 players, each with its own configuration.
//
// - Oct 12, 2020  Chaoji
//   MFi Game Controller support was first implemented by Yoshi Sugawara.
//   Now it's reimplemented to support multiple controllers, to have a
//   intuitive keymapping UI, and to save key mapping in a local configuration file.
//
#import <GameController/GameController.h>
#import "MfiGamepadConfiguration.h"

@class MfiGamepadManager;

@protocol MfiGamepadManagerDelegate

- (void)mfiDidUpdatePlayers;
- (void)mfiButton:(MfiGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed atPlayer:(NSInteger)playerIndex;
- (void)mfiJoystickMoveWithX:(float)x y:(float)y atPlayer:(NSInteger)playerIndex;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MfiGamepadManager : NSObject
@property id<MfiGamepadManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray<GCController*> *players;

+ (MfiGamepadManager*)defaultManager;

@end

NS_ASSUME_NONNULL_END
