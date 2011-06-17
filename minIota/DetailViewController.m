//
//  DetailViewController.m
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

#import "DetailViewController.h"
#import "minIotaAppDelegate.h"
#import "IssueListController.h"

@implementation DetailViewController

// -----------------------------------------------------------
#pragma mark -
#pragma mark Abstract (must override)
// -----------------------------------------------------------

- (void)showPopoverButton:(UIBarButtonItem *)button {
    
}

- (void)hidePopoverButton:(UIBarButtonItem *)button {
    
}

// override only if you want the popover button to appear, but note that only one detail view
// can ever show the same popover button instance
- (BOOL)usePopoverButton {
    return NO;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Notification handlers
// -----------------------------------------------------------

- (void)showPopoverButtonNotification:(NSNotification *)notification {
    if ([self usePopoverButton]) 
        [self showPopoverButton:[[notification userInfo] objectForKey:@"button"]];
}

- (void)hidePopoverButtonNotification:(NSNotification *)notification {
    if ([self usePopoverButton])
        [self hidePopoverButton:[[notification userInfo] objectForKey:@"button"]];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Object life cycle
// -----------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self usePopoverButton]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPopoverButtonNotification:) name:@"showPopoverButton" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePopoverButtonNotification:) name:@"hidePopoverButton" object:nil];
        
        minIotaAppDelegate *appdel = (minIotaAppDelegate *)[[UIApplication sharedApplication] delegate];
        IssueListController *ilc = appdel.issueListController;
        UIBarButtonItem *button = [ilc popoverButtonItem];
        if (button)
            [self showPopoverButton:button];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    // the following doesn't hurt even if no observers have been registered, so we'll always do it
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

@end
