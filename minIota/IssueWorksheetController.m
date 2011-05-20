//
//  IssueWorksheetController.m
//  iotaPad6
//
//  Created by Martin on 2011-02-11.
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

#import "IssueWorksheetController.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "ItemCellIssue.h"
#import "IDRItem.h"
#import "IDRAction.h"
#import "Patient.h"
#import "Notifications.h"
#import "IDRContact.h"
#import "IotaContext.h"
#import "ValueLookupForm.h"
#import "Funcs.h"
#import "ThemeColors.h"

#ifdef IOTAMED
#import "ContactSelectOrCreateForm.h"
#endif

@implementation IssueWorksheetController

@synthesize tableView = _tableView;
@synthesize idrWorkSheet = _idrWorkSheet;
@synthesize idrBlock = _idrBlock;
@synthesize activityIndicator = _activityIndicator;

#ifdef IOTAMED
@synthesize btnContact = _btnContact;
#endif

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
    self.tableView = nil;
    self.idrWorkSheet = nil;
    self.idrBlock = nil;
    self.activityIndicator = nil;
#ifdef IOTAMED
    self.btnContact = nil;
#endif
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Configuration overrides
// -----------------------------------------------------------

// tell superclass to implement popover button for issue list in portrait
- (BOOL)usePopoverButton {
    return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark View lifecycle
// -----------------------------------------------------------

- (void)setTableHeader {

    /*
    IDRContact *currentContact = [[IotaContext getCurrentPatientContext] currentContact];
    
    if (!self.idrBlock) {
        self.tableView.tableHeaderView = nil;
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
        return;
    }
    UIView *thView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 760, 66)] autorelease];
    UILabel *thLabel = [[[UILabel alloc] initWithFrame:CGRectMake(35, 0, 710, 66)] autorelease];
    thLabel.backgroundColor = [UIColor clearColor];
    [thView addSubview:thLabel];
    
    IDRContact *issueWSContact = self.idrBlock.contact;
    
    thLabel.font = [UIFont boldSystemFontOfSize:20.0];
    thLabel.text = [issueWSContact contactAsHeader];
    
    if (issueWSContact != currentContact) {
        UIImage *image = [UIImage imageNamed:@"Lockknock.png"];
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        CGFloat w = image.size.width;
        CGFloat h = image.size.height;
        CGFloat tw = thView.frame.size.width;
        imageView.frame = CGRectMake(tw - 60, 10, w/4.0, h/4.0);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [thView addSubview:imageView];
    }
    self.tableView.tableHeaderView = thView;
    if ([self.idrBlock blockType] == eBlockTypePatient) {
        [self.tableView setBackgroundColor:[[ThemeColors themeColors] worksheetBackgroundPatientBlock]];
    }
    else {
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
    }
      */  

}



- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(obsDataChanged:) name:kObservationDataChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactChanged:) name:kContactListChangedNotification object:nil];
    [self refresh];
}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)refresh {
    [self.tableView reloadData];
    [self setTableHeader];
}

- (void)obsDataChanged:(NSNotification *)notification {
    [self refresh];
}

- (void)contactChanged:(NSNotification *)notification {
    [self refresh];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.idrBlock.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IDRItem *item = [self.idrBlock.items objectAtIndex:[indexPath row]];
    ItemCellIssue *cell = [ItemCellIssue cellForTableView:tableView idrItem:item];
    cell.itemCellDelegate = self;
    //    cell.textLabel.text = item.content;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Item cell delegate
// -----------------------------------------------------------

- (void)presentValueLookupForm:(IDRItem *)item {
    ValueLookupForm *vlf = [[[ValueLookupForm alloc] initWithNibName:@"ValueLookupForm" bundle:nil] autorelease];
    vlf.idrItem = item;
    vlf.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vlf.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:vlf animated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ItemCellIssue cellHeightForTableView:tableView idrItem:[self.idrBlock.items objectAtIndex:[indexPath row]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


// -----------------------------------------------------------
#pragma mark -
#pragma mark IotaContext delegate overrides
// -----------------------------------------------------------

- (BOOL)willSwitchFromPatient:(Patient *)oldPatient {
    return YES;
}

- (void)didSwitchToPatient:(Patient *)newPatient {
    self.idrBlock = nil;
    self.idrWorkSheet = nil;
    [self refresh];
    self.patientButton.title = [Patient buttonTitleForPatient:newPatient];
#ifdef IOTAMED
    self.btnContact.enabled = (newPatient != nil);
#endif
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Action handler
// -----------------------------------------------------------

#ifdef IOTAMED
- (void)btnContact:(id)sender {
    ContactSelectOrCreateForm *cscf = [[ContactSelectOrCreateForm alloc] initWithNibName:@"ContactSelectOrCreateForm" 
                                                                                  bundle:nil];
    cscf.modalPresentationStyle = UIModalPresentationFormSheet;
    cscf.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    cscf.target = self;
    cscf.action = @selector(afterContactForm:);
    [self presentModalViewController:cscf animated:YES];
    [cscf release];
}

- (void)afterContactForm:(NSNumber *)okOrCreate {
    if (![okOrCreate boolValue])
        return;
    [self refresh];
}
#endif

@end
