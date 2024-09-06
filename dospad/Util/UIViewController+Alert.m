/*
 *  Copyright (C) 2017-2024 Chaoji Li
 *
 *  DOSPAD is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */


#import "UIViewController+Alert.h"

@implementation UIViewController(Alert)

- (void)alert:(NSString *)title
{
	[self alert:title message:nil];
}

- (void)alert:(NSString *)title message:(NSString*)msg
{
	UIAlertController * alertController = [UIAlertController
										   alertControllerWithTitle:title
										   message: msg
										   preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"OK"
														style:UIAlertActionStyleDefault
													  handler:^(UIAlertAction *action)
								{
								}]];
	
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)alert:(NSString *)title message:(NSString *)message confirm:(void(^)(BOOL ok))completion
{
	UIAlertController * alertController = [UIAlertController
										   alertControllerWithTitle:title
										   message: message
										   preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
														style:UIAlertActionStyleDefault
													  handler:^(UIAlertAction *action)
								{
									completion(YES);
								}]];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
														style:UIAlertActionStyleCancel
													  handler:^(UIAlertAction *action)
								{
									completion(NO);
								}]];
	
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertTextFieldDidBegin:(UITextField *)textField
{
    NSString *t = textField.text;
    if (t.pathExtension.length > 0) {
        UITextPosition *pos = [textField positionFromPosition:[textField beginningOfDocument] offset:t.length - t.pathExtension.length-1];
        [textField setSelectedTextRange:[textField textRangeFromPosition:pos toPosition:pos]];
    }
}

- (NSString *)trimString:(NSString*)str {
    NSCharacterSet *characterSet=[NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange rangeOfLastWantedCharacter = [str rangeOfCharacterFromSet:[characterSet invertedSet]
        options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [str substringToIndex:rangeOfLastWantedCharacter.location+1];
}


- (void)alert:(NSString *)title message:(NSString *)message options:(NSDictionary*)options prompt:(void(^)(NSString* text))completion
{
    if (options == nil) options = @{};

	UIAlertController * alertController;
	
    alertController = [UIAlertController
        alertControllerWithTitle: title
        message: message
        preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		if (options[@"text"]) {
			textField.text = options[@"text"];
            if (options[@"is_filename"]) {
               [textField addTarget:self
                           action:@selector(alertTextFieldDidBegin:)
                    forControlEvents:UIControlEventEditingDidBegin];
            }
		}
        //textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

	// Add OK action
    [alertController addAction:
     [UIAlertAction actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action)
      {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        completion(namefield.text);
    }]];
    
	// Add CANCEL action
	[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
														style:UIAlertActionStyleCancel
													  handler:^(UIAlertAction *action){
													  completion(nil);
													  }]];
	
	[self presentViewController:alertController animated:YES completion:nil];

}

- (void)alert:(NSString*) title message:(NSString*)message
    actions:(NSArray*)actions source:(id)source
{
    UIAlertController *alertController;
    
    alertController = [UIAlertController
        alertControllerWithTitle:title
        message:message
        preferredStyle:UIAlertControllerStyleActionSheet];

    for (UIAlertAction *action in actions)
    {
        [alertController addAction:action];
    }
        
    [alertController addAction:[UIAlertAction
        actionWithTitle:NSLocalizedString(@"Cancel",nil)
        style:UIAlertActionStyleCancel
        handler:nil]];
    
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
    [self presentViewController:alertController animated:YES completion:nil];

    if ([source isKindOfClass:UIBarButtonItem.class])
    {
        popPresenter.barButtonItem = (UIBarButtonItem*)source;
    }
    else if ([source isKindOfClass:UIView.class])
    {
        UIView *sourceView = (UIView*)source;
        popPresenter.sourceView = sourceView;
        popPresenter.sourceRect = sourceView.bounds;
    }
    else
    {
        NSLog(@"alert: invalid source");
    }
}

@end
