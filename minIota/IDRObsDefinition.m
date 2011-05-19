//
//  IDRObsDefinition.m
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


#import "IDRObsDefinition.h"
#import "IDRValue.h"
#import "IDRContact.h"
#import "NSString+iotaAdditions.h"
#import "Funcs.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IDRObsDefinition ()
@end

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation IDRObsDefinition

@synthesize name = _name;
@synthesize isNumeric = _isNumeric;
@synthesize isCheck = _isCheck;
@synthesize values = _values;
@synthesize type = _type;

- (id)init {
    if ((self = [super init])) {
        _values = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)dealloc {
    self.values = nil;
    self.name = nil;
    self.type = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Copying, coding
// -----------------------------------------------------------

static NSString *kNameKey = @"nameKey";
static NSString *kValuesKey = @"valuesKey";
static NSString *kTypeKey = @"typeKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.name = [aDecoder decodeObjectForKey:kNameKey];
        self.values = [aDecoder decodeObjectForKey:kValuesKey];
        self.type = [aDecoder decodeObjectForKey:kTypeKey];
        NSLog(@"Decoding IDRObsDefinition: %@", self.name);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"Encoding IDRObsDefinition: %@", self.name);
    [aCoder encodeObject:self.name forKey:kNameKey];
    [aCoder encodeObject:self.values forKey:kValuesKey];
    [aCoder encodeObject:self.type forKey:kTypeKey];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (BOOL)isNumeric {
    return ([self.type isEqualToString:@"numeric"]);
}

- (BOOL)isCheck {
    return ([self.type isEqualToString:@"check"]);
}

- (void)valueAdd:(IDRValue *)value {
    [self.values addObject:value];
}

- (NSUInteger)valueCount {
    return [self.values count];
}

- (IDRValue *)valueAtIndex:(NSUInteger)index {
    return [self.values objectAtIndex:index];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    
}

- (IDRValue *)valueForOrBeforeContact:(IDRContact *)contact {
    NSLog(@"%@ valueForOrBeforeContact: %@", self.name, date2str(contact.date));
    IDRValue *value = [self valueForContact:contact];
    if (value == nil)
        value = [self valueBeforeContact:contact];
    return value;
}

- (IDRValue *)valueForContact:(IDRContact *)contact {
    for (IDRValue *value in self.values)
        if (value.contact == contact)
            return value;
    return nil;
}

// used for get fields
- (IDRValue *)valueBeforeContact:(IDRContact *)contact {
    [self.values sortUsingSelector:@selector(compare:)];
//    NSLog(@"looking for values for %@ before contact date %@", self.name, date2str(contact.date));
//    NSLog(@"values we have:");
//    for (IDRValue *val in self.values) {
//        NSLog(@"  value: %@ at date: %@", val.value, date2str(val.contact.date));
//    }
    
    NSEnumerator *revEnum = [self.values reverseObjectEnumerator];
    IDRValue *val;
    while ((val = [revEnum nextObject])) {
//        NSLog(@"comparing contact date: %@ with values in storage date: %@ for obsDef: %@", date2str(contact.date), date2str(val.contact.date), self.name);
        if ([val.contact.date compare:contact.date] == NSOrderedAscending)
            return val;
    }
    return nil;
}

- (NSArray *)valuesForContact:(IDRContact *)contact {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:5];
    for (IDRValue *value in self.values) {
        if (value.contact == contact)
            [arr addObject:value];
    }
    return [arr autorelease];
}

- (IDRValue *)anyValue {
    if (self.values && [self.values count] > 0)
        return [self.values objectAtIndex:0];
    else
        return nil;
}

// value replaces any preexisting value, no contact is interesting
- (void)setValue:(NSString *)value {
    IDRValue *idrValue = [[[IDRValue alloc] init] autorelease];
    idrValue.value = value;
    [self.values removeAllObjects];
    [self.values addObject:idrValue];
}

/*
- (void)setValue:(NSString *)value forContact:(IDRContact *)contact {
    [self setValue:value extendedValue:nil forContact:contact];
}

- (void)setValue:(NSString *)value extendedValue:(NSString *)extendedValue forContact:(IDRContact *)contact {
    IDRValue *val = [self valueForContact:contact];
    if (val == nil) {
        val = [[IDRValue alloc] init];
        val.contact = contact;
        val.value = value;
        val.extendedValue = extendedValue;
        val.obsDefinition = self;
        [self.values addObject:val];
        [val release];
    }
    else {
        val.value = value;
        val.extendedValue = extendedValue;
    }
}
*/
// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug stuff
// -----------------------------------------------------------

- (void)dumpWithIndent:(NSUInteger)indent {
    NSLog(@"%@IDRObsDefinition: %@", [NSString spacesOfLength:indent], self.name);
    for (IDRValue *value in self.values) 
        [value dumpWithIndent:indent + 4];
}


@end
