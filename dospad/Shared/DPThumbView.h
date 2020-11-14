//
//  DPThumbView.h
//  iDOS
//
//  Used for embedding in a floating view so that it can be dragged
//  around and toggle the visibility of the floating view.
//
//  Created by Chaoji Li on 2020/11/10.
//

#import <UIKit/UIKit.h>

@class DPThumbView;

NS_ASSUME_NONNULL_BEGIN

@protocol DPThumbViewDelegate

- (void)thumbViewDidMove:(DPThumbView*)thumbView;
- (void)thumbViewDidStop:(DPThumbView*)thumbView;

@end

@interface DPThumbView : UILabel
@property BOOL showThumbOnly;
@property (nonatomic, weak) id<DPThumbViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
