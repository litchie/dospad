//
//  DPGamepadConfiguration.h
//  iDOS
//
//  Created by Chaoji Li on 2020/11/1.
//


#import "DPGamepad.h"
#import "DPKeyBinding.h"

NS_ASSUME_NONNULL_BEGIN
@interface DPGamepadConfiguration : NSObject
@property (strong) NSURL *fileURL;
- (id)initWithURL:(NSURL*)url;
- (DPKeyBinding*)bindingForButton:(DPGamepadButtonIndex)buttonIndex;
- (void)setBinding:(DPKeyBinding*)binding forButton:(DPGamepadButtonIndex)buttonIndex;
- (void)setHidden:(BOOL)hidden forButton:(DPGamepadButtonIndex)buttonIndex;
- (BOOL)isButtonHidden:(DPGamepadButtonIndex)buttonIndex;
- (NSString*)titleForButtonIndex:(DPGamepadButtonIndex)buttonIndex;
- (void)setTitle:(NSString*)title forButton:(DPGamepadButtonIndex)buttonIndex;
- (BOOL)save;
@end

NS_ASSUME_NONNULL_END
