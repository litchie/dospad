//
//  DPMouseManager.h
//  iDOS
//  For mangaging external mouse devices with GC framework.
//
//  Created by Chaoji Li on 2021/1/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DPMouseManager;

@protocol DPMouseManagerDelegate

- (void)mouseManager:(DPMouseManager*)manager moveX:(CGFloat)x andY:(CGFloat)y;
- (void)mouseManager:(DPMouseManager*)manager button:(int)index  pressed:(BOOL)pressed;

@end

@interface DPMouseManager : NSObject
@property (nonatomic, strong) id<DPMouseManagerDelegate> delegate;

+ (DPMouseManager*)defaultManager;

@end

NS_ASSUME_NONNULL_END
