//
//
// Manage Key Bindings
//
//

#import <Foundation/Foundation.h>

// Use negative integers to be conflict free with
// SDL scancodes
typedef enum {
	DP_KEY_FN = -1,
	DP_KEY_THUMB = -2,
	DP_KEY_MOUSE_LEFT = -1000,
	DP_KEY_MOUSE_RIGHT,
	DP_KEY_X1,
	DP_KEY_X2

} DPKeyIndex;

NS_ASSUME_NONNULL_BEGIN

@interface DPKeyBinding : NSObject
@property (strong) NSString *text;
@property (nonatomic, strong) NSString *name;
@property DPKeyIndex index;

- (id)initWithText:(NSString*)text;
- (id)initWithKeyIndex:(DPKeyIndex)index;
- (id)initWithAttributes:(NSDictionary*)attrs;
+ (int)keyIndexFromName:(NSString*)name;
+ (NSString*)keyName:(DPKeyIndex)index;

@end

NS_ASSUME_NONNULL_END
