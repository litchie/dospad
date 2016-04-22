//
//  Copyright 2010 Chaoji Li. All rights reserved.
//

#import "AlertPrompt.h"
#define TEXT(s) NSLocalizedString(@s,@"")

@implementation AlertPrompt
@synthesize textField;
@synthesize enteredText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(20,50,245,30)];
        [theTextField setBackgroundColor:[UIColor whiteColor]];
        theTextField.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;

        [self addSubview:theTextField];
        self.textField = theTextField;
        
        NSString *ver = [[UIDevice currentDevice] systemVersion];
        int verNumber = [ver intValue];
        if (verNumber < 4) {
            CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 60.0);
            [self setTransform:moveUp];
        }
    }
    return self;
}
- (void)show
{
    [textField becomeFirstResponder];
    [super show];
}
- (NSString *)enteredText
{
    return textField.text;
}
@end


@implementation AlertMessage

+(void)show:(NSString *)title
{
    [AlertMessage show:title message:nil];
}

+(void)show:(NSString *)title message:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:title];
    if (msg) [alert setMessage:msg];
    [alert addButtonWithTitle:TEXT("OK")];
    [alert show];   
}

@end

@implementation AlertConfirm

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag
{
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:TEXT("Cancel") otherButtonTitles:TEXT("OK"), nil])
    {
        [self setTag:tag];
    }
    return self;
}

@end

