//
//  IDRObservation.m
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

#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "NSString+iotaAdditions.h"
#import "IotaContext.h"
#import "MyIotaPatientContext.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

static NSString *kDirectionGet = @"get";
static NSString *kDirectionPut = @"put";
static NSString *kDirectionGetPut = @"getput";

@implementation IDRObservation

@synthesize name = _name;
@synthesize type = _type;
@synthesize direction = _direction;
@synthesize obsDefinition = _obsDefinition;
@synthesize options = _options;

- (void)dealloc {
    self.name = nil;
    self.type = nil;
    self.direction = nil;
    self.obsDefinition = nil;
    self.options = nil;
    [super dealloc];
}

- (IDRObsDefinition *)obsDefinition {
    if (_obsDefinition == nil) {
        MyIotaPatientContext *miCtx = [IotaContext getCurrentMyIotaPatientContext];
        _obsDefinition = [[miCtx getOrAddObsDefinitionForName:self.name type:self.type] retain];
    }
    return [[_obsDefinition retain] autorelease];
}

- (void)setObsDefinition:(IDRObsDefinition *)obsDefinition {
    if (_obsDefinition != obsDefinition) {
        [_obsDefinition release];
    }
    _obsDefinition = [obsDefinition retain];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Coding, copying
// -----------------------------------------------------------

static NSString *kNameKey = @"nameKey";
static NSString *kTypeKey = @"typeKey";
static NSString *kDirectionKey = @"directionKey";
static NSString *kObsDefinitionKey = @"obsDefinitionKey";
static NSString *kOptionsKey = @"optionsKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.name = [aDecoder decodeObjectForKey:kNameKey];
        self.type = [aDecoder decodeObjectForKey:kTypeKey];
        self.direction = [aDecoder decodeObjectForKey:kDirectionKey];
        self.obsDefinition = [aDecoder decodeObjectForKey:kObsDefinitionKey];
        self.options = [aDecoder decodeObjectForKey:kOptionsKey];
        NSLog(@"Decoding IDRObservation name: %@", self.name);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"Encoding IDRObservation name: %@", self.name);
    [aCoder encodeObject:self.name forKey:kNameKey];
    [aCoder encodeObject:self.type forKey:kTypeKey];
    [aCoder encodeObject:self.direction forKey:kDirectionKey];
    [aCoder encodeObject:self.obsDefinition forKey:kObsDefinitionKey];
    [aCoder encodeObject:self.options forKey:kOptionsKey];
}

// when copying, don't copy the obsdefinition pointer, since the definition remains the same

- (id)copyWithZone:(NSZone *)zone {
    IDRObservation *copy = [[[self class] alloc] init];
    copy.name = [[self.name copyWithZone:zone] autorelease];
    copy.type = [[self.type copyWithZone:zone] autorelease];
    copy.direction = [[self.direction copyWithZone:zone] autorelease];
    copy.obsDefinition = self.obsDefinition;
    
    // TODO: think about options, shouldn't they actually be in obsDefinition instead?
    copy.options = [[self.options copyWithZone:zone] autorelease];
    return copy;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------


- (void)takeAttributes:(NSDictionary *)attribs {
    // the name is redundant, but the obsdefinition is only created later, so we need this
    self.name = [attribs valueForKey:@"name"];
    self.type = [attribs valueForKey:@"type"];
    self.direction = [attribs valueForKey:@"direction"];
}

- (BOOL)hasGetPut {
    return [self.direction isEqualToString:kDirectionGetPut];
}

- (BOOL)hasGet {
    return [self.direction isEqualToString:kDirectionGet] || [self hasGetPut];
}

- (BOOL)hasPut {
    return [self.direction isEqualToString:kDirectionPut] || [self hasGetPut];
}

- (BOOL)isNumeric {
    return ([self.type isEqualToString:@"numeric"]);
}

- (BOOL)isCheck {
    return ([self.type isEqualToString:@"check"]);
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug stuff
// -----------------------------------------------------------

- (void)dumpWithIndent:(NSUInteger)indent {
    NSLog(@"%@IDRObservation: %@, %@", [NSString spacesOfLength:indent], self.name, self.direction);
    [self.obsDefinition dumpWithIndent:indent + 4];
}


@end
