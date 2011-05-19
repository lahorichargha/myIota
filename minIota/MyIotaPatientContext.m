//
//  MyIotaPatientContext.m
//  iotaPad6
//
//  Created by Martin on 2011-05-16.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "MyIotaPatientContext.h"
#import "IDRBlock.h"
#import "IDRContact.h"
#import "IDRObsDefinition.h"
#import "Patient.h"

@implementation MyIotaPatientContext

@synthesize blocks = _blocks;
@synthesize patient = _patient;
@synthesize contacts = _contacts;
@synthesize obsDefinitions = _obsDefinitions;
@synthesize currentContact = _currentContact;

- (id)init {
    if ((self = [super init])) {
        _blocks = [[NSMutableArray alloc] initWithCapacity:5];
        _contacts = [[NSMutableArray alloc] initWithCapacity:5];
        _obsDefinitions = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}


- (void)dealloc {
    self.patient = nil;
    self.blocks = nil;
    self.contacts = nil;
    self.obsDefinitions = nil;
    self.currentContact = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (BOOL)addBlockIfNew:(IDRBlock *)theBlock {
    NSString *uuid = theBlock.templateUuid;
    for (IDRBlock *block in self.blocks)
        if ([block.templateUuid isEqualToString:uuid])
            return NO;
    IDRBlock *blockCopy = [theBlock copy];
    // clear any contact, but keep worksheet and items
    blockCopy.contact = nil;
    [self.blocks addObject:blockCopy];
    [blockCopy release];
    return YES;
}

@end
