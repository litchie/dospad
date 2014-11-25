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

- (CGFloat)keyboardHeightFromNotification:(NSNotification*)note
{
    float keyboardHeight;
	CGRect keyboardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	if (ISLANDSCAPE(self.interfaceOrientation)) {
		if (IS_IOS8) {
			keyboardHeight = keyboardFrame.size.height;
		} else {
			keyboardHeight = keyboardFrame.size.width;
		}
	} else {
		keyboardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		keyboardHeight = keyboardFrame.size.height;
	}
	return keyboardHeight;
}

- (void)adjustViewForKeyboardHeight:(CGFloat)keyboardHeight
{
	CGRect frame = CGRectZero;
	CGFloat topMargin = 0;
	frame.size.width = self.view.frame.size.width;
	frame.size.height = self.view.frame.size.height-keyboardHeight;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    self.textView.frame = frame;
    [UIView commitAnimations];
}

-(void) keyboardWillShow:(NSNotification *)note
{
	[self adjustViewForKeyboardHeight:[self keyboardHeightFromNotification:note]];
}

-(void) keyboardWillHide:(NSNotification *)note
{
	[self adjustViewForKeyboardHeight:0];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

- (void)saveFile
{
    if (textChanged)
    {
        [self.textView.text writeToFile:self.filePath
                             atomically:YES  
                               encoding:NSUTF8StringEncoding
                                  error:NULL];
    }
	self.navigationItem.rightBarButtonItem.enabled = NO;
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
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveFile)] autorelease];
	self.navigationItem.rightBarButtonItem.enabled = NO;
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
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

@end
