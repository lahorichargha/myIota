//
//  DetailViewControllerWithToolbar.m
//  iotaPad6
//
//  Created by Martin on 2011-02-16.
//  Copyright © 2011, MITM AB, Sweden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//  3.  Neither the name of MITM AB nor the name iotaMed®, nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY MITM AB ‘’AS IS’’ AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MITM AB BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "DetailViewControllerWithToolbar.h"
#import "Patient.h"
#import "IotaContext.h"
#import "UIView+iotaExtensions.h"

#ifdef IOTAMED
#import "PatientListController.h"
#endif

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface DetailViewControllerWithToolbar ()
@property (nonatomic, assign) BOOL keyboardIsShown;
@end


@implementation DetailViewControllerWithToolbar

@synthesize toolbar = _toolbar;
@synthesize patientButton = _patientButton;
@synthesize keyboardIsShown = _keyboardIsShown;
@synthesize viewToShrink = _viewToShrink;

- (void)dealloc {
    self.patientButton = nil;
    self.toolbar = nil;
    self.viewToShrink = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [IotaContext addObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

- (void)viewDidUnload {
    [IotaContext removeObserver:self];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];  // taking it upon myself to remove *everything*
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Popover button stuff
// -----------------------------------------------------------

- (void)showPopoverButton:(UIBarButtonItem *)button {
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    [items insertObject:button atIndex:0];
    [self.toolbar setItems:items animated:NO];
    [items release];
}

- (void)hidePopoverButton:(UIBarButtonItem *)button {
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    [items removeObject:button];
    [self.toolbar setItems:items animated:NO];
    [items release];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark IotaContextDelegate
// -----------------------------------------------------------

- (BOOL)willSwitchFromPatient:(Patient *)oldPatient {
    return YES;
}

- (void)didSwitchToPatient:(Patient *)newPatient {
    self.patientButton.title = [Patient buttonTitleForPatient:newPatient];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Keyboard handling
// -----------------------------------------------------------

- (void)keyboardWillShow:(NSNotification *)n {
    
    if (self.viewToShrink == nil || self.keyboardIsShown)
        return;
    
    // get keyboard size
    CGRect keyboardBounds;
    [[n.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
    // get orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.viewToShrink.frame;
    
    // start animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // reduce size of table view
    if (UIInterfaceOrientationIsPortrait(orientation))
        frame.size.height -= keyboardBounds.size.height;
    else
        frame.size.height -= keyboardBounds.size.width;
    
    // apply new size
    self.viewToShrink.frame = frame;
    
    // scroll the table view to see 
    UIView *fr = [self.view findFirstResponder];
    CGRect frFrame = fr.frame;
    CGRect nextFrame = [self.viewToShrink convertRect:frFrame fromView:fr];
    [self.viewToShrink scrollRectToVisible:nextFrame animated:NO];
    //    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [UIView commitAnimations];
    
    self.keyboardIsShown = YES;
//    NSLog(@"frame is now (show): %@", NSStringFromCGRect(self.viewToShrink.frame));
}

- (void)keyboardWillHide:(NSNotification *)n {
    
    if (self.viewToShrink == nil)
        return;
    
    // get keyboard size
    CGRect keyboardBounds;
    [[n.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
    
    // get orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.viewToShrink.frame;
    
    // start animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // increase size of table view
    if (UIInterfaceOrientationIsPortrait(orientation))
        frame.size.height += keyboardBounds.size.height;
    else
        frame.size.height += keyboardBounds.size.width;
    
    // apply new size
    self.viewToShrink.frame = frame;
    
    [UIView commitAnimations];
    
    self.keyboardIsShown = NO;
//    NSLog(@"frame is now (hide): %@", NSStringFromCGRect(self.viewToShrink.frame));
}


@end
