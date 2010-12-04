//
//  Copyright 2010 Chaoji Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertPrompt : UIAlertView 
{
    UITextField *textField;
}
@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;
@end


@interface AlertMessage: UIAlertView
{

}

+(void)show:(NSString *)title;
+(void)show:(NSString *)title message:(NSString*)msg;

@end

@interface AlertConfirm: UIAlertView
{
    
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag;

@end

