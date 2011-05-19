//
//  IDRItem.m
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

#import "IDRItem.h"
#import "NSString+iotaAdditions.h"
#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "IDRBlock.h"
#import "IDRImage.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation IDRItem

@synthesize observation = _observation;
@synthesize action = _action;
@synthesize content = _content;
@synthesize isBold = _isBold;
@synthesize indentLevel = _indentLevel;
@synthesize hasBullet = _hasBullet;
@synthesize parentBlock = _parentBlock;
@synthesize idrImage = _idrImage;

- (id)init {
    if ((self = [super init])) {
        _content = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.observation = nil;
    self.action = nil;
    self.content = nil;
    self.parentBlock = nil;
    self.idrImage = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Coding, copying
// -----------------------------------------------------------

static NSString *kObservationKey = @"observationKey";
static NSString *kActionKey = @"actionKey";
static NSString *kContentKey = @"contentKey";
static NSString *kIsBoldKey = @"isBoldKey";
static NSString *kIndentLevelKey = @"indentLevelKey";
static NSString *kHasBulletKey = @"hasBulletKey";
static NSString *kParentBlockKey = @"parentBlockKey";
static NSString *kIdrImageKey = @"idrImageKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.observation = [aDecoder decodeObjectForKey:kObservationKey];
        self.action = [aDecoder decodeObjectForKey:kActionKey];
        self.content = [aDecoder decodeObjectForKey:kContentKey];
        self.isBold = [aDecoder decodeBoolForKey:kIsBoldKey];
        self.indentLevel = [aDecoder decodeIntegerForKey:kIndentLevelKey];
        self.hasBullet = [aDecoder decodeBoolForKey:kHasBulletKey];
        self.parentBlock = [aDecoder decodeObjectForKey:kParentBlockKey];
        self.idrImage = [aDecoder decodeObjectForKey:kIdrImageKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"encoding IDRItem");
    [aCoder encodeObject:self.observation forKey:kObservationKey];
    [aCoder encodeObject:self.action forKey:kActionKey];
    [aCoder encodeObject:self.content forKey:kContentKey];
    [aCoder encodeBool:self.isBold forKey:kIsBoldKey];
    [aCoder encodeInteger:self.indentLevel forKey:kIndentLevelKey];
    [aCoder encodeBool:self.hasBullet forKey:kHasBulletKey];
    [aCoder encodeObject:self.parentBlock forKey:kParentBlockKey];
    [aCoder encodeObject:self.idrImage forKey:kIdrImageKey];
}

- (id)copyWithZone:(NSZone *)zone {
    IDRItem *copy = [[[self class] allocWithZone:zone] init];
    copy.observation = [[self.observation copyWithZone:zone] autorelease];
    copy.action = [[self.action copyWithZone:zone] autorelease];
    copy.content = [[self.content copyWithZone:zone] autorelease];
    copy.isBold = self.isBold;
    copy.indentLevel = self.indentLevel;
    copy.hasBullet = self.hasBullet;
    copy.parentBlock = self.parentBlock;        // must be set by parent after copy
    copy.idrImage = [[self.idrImage copyWithZone:zone] autorelease];
    return copy;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Set a value
// -----------------------------------------------------------

- (void)setItemValue:(NSString *)value {
    [self setItemValue:value extendedValue:nil];
}

- (void)setItemValue:(NSString *)value extendedValue:(NSString *)extendedValue {
    IDRObservation *observation = self.observation;
    IDRObsDefinition *obsDef = observation.obsDefinition;
    //    IDRBlock *block = self.parentBlock;
    //    IDRContact *contact = block.contact;
    //    [obsDef setValue:value extendedValue:extendedValue forContact:contact];
    [obsDef setValue:value];
}

- (BOOL)hasValues {
    return ([[self getValues] count] > 0);
}

- (NSArray *)getValues {
    IDRObservation *obs = self.observation;
    IDRObsDefinition *obsDef = obs.obsDefinition;
    NSArray *values = obsDef.values;
    return values;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark accessors
// -----------------------------------------------------------

- (void)addContent:(NSString *)content {
    [self.content appendString:content];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.isBold = [[attribs valueForKey:@"bold"] isEqualToString:@"yes"];
    NSString *sIndent = [attribs valueForKey:@"indentlevel"];
    self.indentLevel = (sIndent != nil) ? [sIndent intValue] : 0;
}

// true if the item has any observation defined, irrespective of if it's input or output or both
- (BOOL)hasObservation {
    return _observation != nil;
}

// true if the item has an action defined
- (BOOL)hasAction {
    return _action != nil;
}

// true if an observation is defined and an input text field is required
- (BOOL)hasInput {
    return [self hasObservation] && [self.observation hasPut];
}

// true if values are presented in retrievefields (usually at right margin)
- (BOOL)hasGet {
    return [self hasObservation] && [self.observation hasGet];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug
// -----------------------------------------------------------

- (void)dumpWithIndent:(NSUInteger)indent {
    NSLog(@"%@IDRItem: %@", [NSString spacesOfLength:indent], self.content);
    [self.observation dumpWithIndent:(indent+4)];
}

- (NSString *)description {
    NSMutableString *desc = [[NSMutableString alloc] initWithCapacity:50];
    [desc setString:@"IDRItem description:\n"];
    [desc appendFormat:@"  parentBlock:%@", [self.parentBlock description]];
    return [desc autorelease];
}

@end
