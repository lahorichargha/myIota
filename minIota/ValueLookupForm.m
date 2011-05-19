//
//  ValueLookupForm.m
//  iotaPad6
//
//  Created by Martin on 2011-03-25.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "ValueLookupForm.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRValue.h"
#import "IDRContact.h"
#import "ValueLookupCell.h"
#import "Funcs.h"

#define kListSegment    0
#define kGrafSegment    1

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation ValueLookupForm

@synthesize tableView = _tableView;
@synthesize idrItem = _idrItem;
@synthesize segControl = _segControl;
@synthesize grafView = _grafView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.idrItem = nil;
    self.tableView = nil;
    self.segControl = nil;
    self.grafView = nil;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    BOOL numeric = [self.idrItem.observation isNumeric];
    self.segControl.hidden = !numeric;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.grafView.hidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}
// -----------------------------------------------------------
#pragma mark -
#pragma mark Actions
// -----------------------------------------------------------

- (IBAction)segmentedChanged:(id)sender {
    self.grafView.hidden = !([self.segControl selectedSegmentIndex] == kGrafSegment);
}

- (IBAction)btnClose:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource
// -----------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.idrItem getValues] count];
}

- (UILabel *)makeLabelAtX:(CGFloat)x atY:(CGFloat)y wide:(CGFloat)wide tag:(NSUInteger)tag {
    UILabel *lbl = [[[UILabel alloc] initWithFrame:CGRectMake(x, 3.0, wide, 32.0)] autorelease];
    lbl.tag = tag;
    return lbl;
}


#define kDateTag            1001
#define kValueTag           1002
#define kExtendedValueTag   1003

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    
    ValueLookupCell *cell = (ValueLookupCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[ValueLookupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    IDRValue *value = [[self.idrItem getValues] objectAtIndex:[indexPath row]];
    [cell setValueObject:value];
    
    return cell;
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate
// -----------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IDRValue *value = [[self.idrItem getValues] objectAtIndex:[indexPath row]];
    return [ValueLookupCell heightOfCell:value];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


@end
