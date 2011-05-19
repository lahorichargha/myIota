//
//  IDRAction.m
//  iotaPad6
//
//  Created by Martin on 2011-03-03.
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

#import "IDRAction.h"
#import "IDRTest.h"
#import "IDRDose.h"

@implementation IDRAction

@synthesize name = _name;
@synthesize type = _type;
@synthesize cause = _cause;
@synthesize history = _history;
@synthesize status = _status;
@synthesize to = _to;
@synthesize atc = _atc;
@synthesize showAction = _showAction;
@synthesize tests = _tests;
@synthesize doses = _doses;
@synthesize templateUuid = _templateUuid;

- (void)dealloc {
    self.name = nil;
    self.type = nil;
    self.cause = nil;
    self.history = nil;
    self.status = nil;
    self.to = nil;
    self.atc = nil;
    self.tests = nil;
    self.doses = nil;
    self.templateUuid = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Copying, coding
// -----------------------------------------------------------

static NSString *kNameKey = @"nameKey";
static NSString *kTypeKey = @"typeKey";
static NSString *kCauseKey = @"causeKey";
static NSString *kHistoryKey = @"historyKey";
static NSString *kStatusKey = @"statusKey";
static NSString *kToKey = @"toKey";
static NSString *kAtcKey = @"atcKey";
static NSString *kShowActionKey = @"showActionKey";
static NSString *kTestsKey = @"testsKey";
static NSString *kDosesKey = @"dosesKey";
static NSString *kTemplateUuidKey = @"templateUuidKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.name = [aDecoder decodeObjectForKey:kNameKey];
        self.type = [aDecoder decodeObjectForKey:kTypeKey];
        self.cause = [aDecoder decodeObjectForKey:kCauseKey];
        self.history = [aDecoder decodeObjectForKey:kHistoryKey];
        self.status = [aDecoder decodeObjectForKey:kStatusKey];
        self.to = [aDecoder decodeObjectForKey:kToKey];
        self.atc = [aDecoder decodeObjectForKey:kAtcKey];
        self.showAction = [aDecoder decodeBoolForKey:kShowActionKey];
        self.tests = [aDecoder decodeObjectForKey:kTestsKey];
        self.doses = [aDecoder decodeObjectForKey:kDosesKey];
        self.templateUuid = [aDecoder decodeObjectForKey:kTemplateUuidKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:kNameKey];
    [aCoder encodeObject:self.type forKey:kTypeKey];
    [aCoder encodeObject:self.cause forKey:kCauseKey];
    [aCoder encodeObject:self.history forKey:kHistoryKey];
    [aCoder encodeObject:self.status forKey:kStatusKey];
    [aCoder encodeObject:self.to forKey:kToKey];
    [aCoder encodeObject:self.atc forKey:kAtcKey];
    [aCoder encodeBool:self.showAction forKey:kShowActionKey];
    [aCoder encodeObject:self.tests forKey:kTestsKey];
    [aCoder encodeObject:self.doses forKey:kDosesKey];
    [aCoder encodeObject:self.templateUuid forKey:kTemplateUuidKey];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (void)takeAttributes:(NSDictionary *)attribs {
    self.name = [attribs valueForKey:@"name"];
    self.type = [attribs valueForKey:@"type"];
    self.cause = [attribs valueForKey:@"cause"];
    self.history = [attribs valueForKey:@"history"];
    self.status = [attribs valueForKey:@"status"];
    self.to = [attribs valueForKey:@"to"];
    self.atc = [attribs valueForKey:@"ATC"];
    self.showAction = [[attribs valueForKey:@"showaction"] isEqualToString:@"yes"];
    self.templateUuid = [attribs valueForKey:@"templateUuid"];
}

- (void)addTest:(IDRTest *)test {
    if (_tests == nil) {
        _tests = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [_tests addObject:test];
}

- (void)addDose:(IDRDose *)dose {
    if (_doses == nil) {
        _doses = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [_doses addObject:dose];
}

@end
