//
//  PatientContext.m
//  iotaPad6
//
//  Created by Martin on 2011-03-08.
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
/* --------------------------------------------------------------------------
 * Patientcontext contains all the data for one patient, demographics and
 * clinical data including worksheets, phases, and values.
 *
 *
 */


#import "PatientContext.h"
#import "IDRContact.h"
#import "IDRBlock.h"
#import "IDRWorksheet.h"
#import "IDRObsDefinition.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRValue.h"
#import "Notifications.h"
#import "Patient.h"
#import "NSString+iotaAdditions.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface PatientContext ()
@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation PatientContext

@synthesize dirty = _dirty;
@synthesize contacts = _contacts;
@synthesize currentContact = _currentContact;
@synthesize obsDefinitions = _obsDefinitions;
@synthesize patient = _patient;

static NSString *kContactsKey = @"contactsKey";
static NSString *kCurrentContactKey = @"contactKey";
static NSString *kObsDefinitionsKey = @"obsDefinitionsKey";
static NSString *kPatientKey = @"patientKey";

- (id)init {
    if ((self = [super init])) {
        _contacts = [[NSMutableArray alloc] initWithCapacity:5];
        _currentContact = nil;
        _obsDefinitions = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (void)dealloc {
    self.contacts = nil;
    self.currentContact = nil;
    self.obsDefinitions = nil;
    self.patient = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.contacts = [aDecoder decodeObjectForKey:kContactsKey];
        [self.contacts sortUsingSelector:@selector(compare:)];
        self.currentContact = [aDecoder decodeObjectForKey:kCurrentContactKey];
        self.obsDefinitions = [aDecoder decodeObjectForKey:kObsDefinitionsKey];
        self.patient = [aDecoder decodeObjectForKey:kPatientKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.contacts forKey:kContactsKey];
    [aCoder encodeObject:self.currentContact forKey:kCurrentContactKey];
    [aCoder encodeObject:self.obsDefinitions forKey:kObsDefinitionsKey];
    [aCoder encodeObject:self.patient forKey:kPatientKey];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (void)setDirty:(BOOL)dirty {
    _dirty = dirty;
}

- (NSMutableArray *)contacts {
    if (_contacts == nil) {
        _contacts = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return [[_contacts retain] autorelease];
}

- (IDRBlock *)blockWithTemplateUuid:(NSString *)blockTemplateUuid inWorksheetWithTemplateUuid:(NSString *)worksheetTemplateUuid {
    for (IDRContact *contact in self.contacts) {
        for (IDRBlock *block in contact.idrBlocks) {
            if ((block.worksheet != nil) &&
                [block.templateUuid isEqualToString:blockTemplateUuid] && 
                [block.worksheet.templateUuid isEqualToString:worksheetTemplateUuid])
                return block;
        }
    }
    return nil;
}

- (NSArray *)worksheetsWithTemplateUuid:(NSString *)templateUuid {
    NSMutableArray *worksheets = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
    for (IDRContact *contact in self.contacts) {
        for (IDRBlock *block in contact.idrBlocks) {
            if ((block.worksheet != nil) && [block.worksheet.templateUuid isEqualToString:templateUuid])
                [worksheets addObject:block.worksheet];
        }
    }
    return [[worksheets copy] autorelease];
}

- (void)addContactAndMakeCurrent:(IDRContact *)contact {
    [self.contacts addObject:contact];
    self.currentContact = contact;
    [self.contacts sortUsingSelector:@selector(compare:)];
}

- (IDRObsDefinition *)getOrAddObsDefinitionForName:(NSString *)name type:(NSString *)type {
    for (IDRObsDefinition *obsDef in self.obsDefinitions) {
        if ([obsDef.name isEqualToString:name])
            return obsDef;
    }
    IDRObsDefinition *newObsDef = [[[IDRObsDefinition alloc] init] autorelease];
    newObsDef.name = name;
    newObsDef.type = type;
    [self.obsDefinitions addObject:newObsDef];
    return newObsDef;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Worksheet and block functions
// -----------------------------------------------------------

// add block using current contact
- (void)addBlock:(IDRBlock *)block toExistingWorksheet:(IDRWorksheet *)worksheet customTitle:(NSString *)customTitle {
    IDRContact *contact = self.currentContact;
    NSAssert(contact != nil, @"Missing contact while adding block");
    IDRWorksheet *strippedWsCopy = [worksheet copyWithoutBlocks];
    IDRBlock *blockCopy = [block copy];
              
    // now we need to look for any preexisting worksheet, then let the user decide if
    // we want to use the preexisting or create a new 
    // TODO: let the user decide
    NSArray *existingWorksheets = [self worksheetsWithTemplateUuid:strippedWsCopy.templateUuid];
    if (existingWorksheets == nil || ([existingWorksheets count] < 1)) {
        blockCopy.worksheet = strippedWsCopy;
    }
    else {
        // TODO: let the user decide if he wants to use existing or create new
        blockCopy.worksheet = [existingWorksheets objectAtIndex:0];
    }
    
    blockCopy.title = [NSString stringWithFormat:@"%@ %@", blockCopy.title, customTitle];
    blockCopy.contact = contact;
    [contact addBlock:blockCopy];
    
    // now we need to add any missing obsdefinitions and link them to both the patient context
    // and the observations in the items in the block
    
    for (IDRItem *item in blockCopy.items) {
        if ([item hasObservation]) {
            IDRObservation *obs = item.observation;
            IDRObsDefinition *obsDef = [self getOrAddObsDefinitionForName:obs.name type:obs.type];
            obs.obsDefinition = obsDef;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kIssueListChangedNotification 
                                                        object:nil 
                                                      userInfo:[NSDictionary dictionaryWithObject:blockCopy forKey:kIssueListChangedNotificationBlockKey]];
    [strippedWsCopy release];
    [blockCopy release];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Value and observation functions
// -----------------------------------------------------------

- (IDRValue *)getCurrentValueForObsName:(NSString *)name {
    for (IDRObsDefinition *obsDef in self.obsDefinitions) {
        if ([obsDef.name isEqualToString:name]) {
            IDRValue *value = [obsDef valueForContact:[self currentContact]];
            return value;
        }
    }
    return nil;
}

- (NSArray *)getAllValuesForObsName:(NSString *)name {
    for (IDRObsDefinition *obsDef in self.obsDefinitions) {
        if ([obsDef.name isEqualToString:name]) {
            return [[obsDef.values copy] autorelease];
        }
    }
    return nil;
}

- (NSString *)replaceObsNamesInString:(NSString *)inputStr {
    if (inputStr == nil)
        return nil;
    
    // replace tokens in string with values from current contact. If no value found, put in
    // three question marks instead
    // The tokens in the input string are written as:
    //    "....this is a variable for blood pressure: $(Blodtryck), just as an example..."
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\$\\([A-Za-z]+\\)" 
                                                                           options:0 
                                                                             error:&error];
    NSMutableArray *matches = [[NSMutableArray alloc] initWithCapacity:5];
    
    [regex enumerateMatchesInString:inputStr options:0 range:NSMakeRange(0, [inputStr length]) 
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                             NSRange matchRange = [match range];
                             NSString *varName = [inputStr substringWithRange:NSMakeRange(matchRange.location + 2, matchRange.length - 3)];
                             // store found name and its range together in an array, which we stick into the array of all matches as one single element
                             // also note that you can't stick an NSRange in an array, but you can wrap it as an NSValue and then stick it there
                             NSArray *matchArray = [NSArray arrayWithObjects:varName, [NSValue valueWithRange:matchRange], nil];
                             [matches addObject:matchArray];
                         }];
    
    // now we scan through the matches backwards so we can replace the varnames without disturbing the location of those
    // still remaining, since the first (leftmost) ones will be last to be replaced
    NSString *retValue = [[inputStr copy] autorelease];
    for (int i = [matches count] - 1; i >= 0; i--) {
        NSArray *matchArray = [matches objectAtIndex:i];
        NSString *varName = [matchArray objectAtIndex:0];
        NSRange range = [[matchArray objectAtIndex:1] rangeValue];
        
        // go pick up the value, but only for the current contact
        IDRValue *value = [self getCurrentValueForObsName:varName];
        // if none found, replace with three question marks.
        NSString *valueStr = (value != nil) ? value.value : @"???";
        retValue = [retValue stringByReplacingCharactersInRange:range withString:valueStr];
    }
    [matches release];
    return retValue;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug stuff
// -----------------------------------------------------------

- (void)dumpWithIndent:(int)indent {
    NSLog(@"%@PatientContext", [NSString spacesOfLength:indent]);
    [self.patient dumpWithIndent:indent + 4];
    for (IDRContact *contact in self.contacts) 
        [contact dumpWithIndent:indent + 4];
    for (IDRObsDefinition *obsDefinition in self.obsDefinitions)
        [obsDefinition dumpWithIndent:indent + 4];
}

@end
