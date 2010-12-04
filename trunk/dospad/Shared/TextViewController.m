/*
 *  Copyright (C) 2010  Chaoji Li
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


#import "TextViewController.h"
#import "Common.h"
#import "FileSystemObject.h"

@implementation TextViewController
@synthesize textView;
@synthesize filePath;


-(void)loadText
{
    self.textView.text = [NSString stringWithContentsOfFile:self.filePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
}


-(void)hideKeyboard
{
    [self.textView resignFirstResponder];
}

-(void) keyboardWillShow:(NSNotification *)note
{
    // Only available in 3.2?
    //[[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    float keyboardHeight;
    switch (self.interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            keyboardHeight = KBD_PORTRAIT_HEIGHT;
            break;
        default:
            keyboardHeight = KBD_LANDSCAPE_HEIGHT;
            break;
    }
    CGRect frame = self.textView.frame;
    frame.size.height -= keyboardHeight;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    self.textView.frame = frame;
    
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    //  CGRect keyboardBounds;
    //[[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    float keyboardHeight;
    switch (self.interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            keyboardHeight = KBD_PORTRAIT_HEIGHT;
            break;
        default:
            keyboardHeight = KBD_LANDSCAPE_HEIGHT;
            break;
    }
    
    CGRect frame = self.textView.frame;
    frame.size.height += keyboardHeight;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    self.textView.frame = frame;
    [UIView commitAnimations];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (textChanged)
    {
        [self.textView.text writeToFile:self.filePath
                             atomically:YES  
                               encoding:NSUTF8StringEncoding
                                  error:NULL];    
    }
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *fileName = [self.filePath lastPathComponent];
    self.title = fileName;
    self.textView.delegate=self;
    if (ISIPAD()) {
        self.textView.font=[UIFont fontWithName:@"Courier New" size:17];
    } else {
        self.textView.font=[UIFont fontWithName:@"Courier New" size:14];        
    }
    [self loadText];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    self.filePath=nil;
    self.textView=nil;
    [super dealloc];
}


- (void)textViewDidChange:(UITextView *)textView
{
    textChanged=YES;
}

@end
