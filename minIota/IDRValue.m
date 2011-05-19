//
//  IDRValue.m
//  iotaPad6
//
//  Created by Martin on 2011-03-07.
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
 * An IDRValue represents a value and a point in time. It can be
 * reused in any number of worksheets. It is refered to by an IDRObservationDefinition
 * which contains the name label and other similar stuff.
 * An IDRObservation object defines a particular occurrence of an IDRObservationDefinition
 * in a worksheet and contains indications of input/output.
 *
 *
 */


#import "IDRValue.h"
#import "IDRObsDefinition.h"
#import "IDRContact.h"
#import "NSString+iotaAdditions.h"

@implementation IDRValue

@synthesize value = _value;
@synthesize extendedValue = _extendedValue;
@synthesize contact = _contact;
@synthesize obsDefinition = _obsDefinition;

static NSString *kValueKey = @"valueKey";
static NSString *kExtendedValueKey = @"extendedValueKey";
static NSString *kContactKey = @"contactKey";
static NSString *kObsDefinitionKey = @"obsDefinitionKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.value = [aDecoder decodeObjectForKey:kValueKey];
        self.extendedValue = [aDecoder decodeObjectForKey:kExtendedValueKey];
        self.contact = [aDecoder decodeObjectForKey:kContactKey];
        self.obsDefinition = [aDecoder decodeObjectForKey:kObsDefinitionKey];
        NSLog(@"Decoding value: %@ for obsdef name: %@", self.value, _obsDefinition.name);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"Encoding value: %@ for obsdef name: %@", self.value, _obsDefinition.name);
    [aCoder encodeObject:self.value forKey:kValueKey];
    [aCoder encodeObject:self.extendedValue forKey:kExtendedValueKey];
    [aCoder encodeObject:self.contact forKey:kContactKey];
    [aCoder encodeObject:self.obsDefinition forKey:kObsDefinitionKey];
}

- (void)dealloc {
    self.value = nil;
    self.extendedValue = nil;
    self.contact = nil;
    self.obsDefinition = nil;
    [super dealloc];
}

- (NSComparisonResult)compare:(IDRValue *)other {
    return [self.contact compare:other.contact];
}

- (NSString *)displayValue {
    if ([self.value isEqualToString:@"yes"])
        return @"Ja";
    else if ([self.value isEqualToString:@"no"])
        return @"Nej";
    else
        return self.value;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug stuff
// -----------------------------------------------------------

- (void)dumpWithIndent:(NSUInteger)indent {
    NSLog(@"%@IDRValue: %@ (no more recursion)", [NSString spacesOfLength:indent], self.value);
}


@end
