//
//  IDRContact.m
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
 * A contact is an instance, a meeting, with the patient. Could be regarded
 * as a "session". Every observation value is connected to a contact.
 * Through the connection with a contact, the observation value becomes dated.
 *
 *
 */


#import "IDRContact.h"
#import "IDRBlock.h"
#import "IDRValue.h"
#import "Funcs.h"
#import "NSString+iotaAdditions.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IDRContact ()

@end


// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation IDRContact

@synthesize date = _date;
@synthesize nameOfDoctor = _nameOfDoctor;
@synthesize idrValues = _idrValues;
@synthesize idrBlocks = _idrBlocks;

- (void)dealloc {
    self.date = nil;
    self.idrValues = nil;
    self.idrBlocks = nil;
    self.nameOfDoctor = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Coding, copying
// -----------------------------------------------------------

static NSString *kDateKey = @"dateKey";
static NSString *kValuesKey = @"valuesKey";
static NSString *kBlocksKey = @"blocksKey";
static NSString *kNameOfDoctorKey = @"nameOfDoctorKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.date = [aDecoder decodeObjectForKey:kDateKey];
        self.idrValues = [aDecoder decodeObjectForKey:kValuesKey];
        self.idrBlocks = [aDecoder decodeObjectForKey:kBlocksKey];
        self.nameOfDoctor = [aDecoder decodeObjectForKey:kNameOfDoctorKey];
        NSLog(@"Decoding contact, IDRValues: %d, IDRBlocks: %d", [self.idrValues count], [self.idrBlocks count]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"Encoding contact, IDRValues: %d, IDRBlocks: %d", [self.idrValues count], [self.idrBlocks count]);
    [aCoder encodeObject:self.date forKey:kDateKey];
    [aCoder encodeObject:self.idrValues forKey:kValuesKey];
    [aCoder encodeObject:self.idrBlocks forKey:kBlocksKey];
    [aCoder encodeObject:self.nameOfDoctor forKey:kNameOfDoctorKey];
}

- (NSComparisonResult)compare:(IDRContact *)otherContact {
    return [self.date compare:otherContact.date];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (NSMutableArray *)idrBlocks {
    if (_idrBlocks == nil) {
        _idrBlocks = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return [[_idrBlocks retain] autorelease];
}

- (NSString *)contactAsHeader {
    if (self.date || self.nameOfDoctor)
        return [NSString stringWithFormat:@"%@, %@", date2str(self.date), self.nameOfDoctor];
    else
        return @"";
}

- (void)addBlock:(IDRBlock *)block {
    [self.idrBlocks addObject:block];
    block.contact = self;
}

- (void)dumpWithIndent:(int)indent {
    NSLog(@"%@Contact: %@", [NSString spacesOfLength:indent], [self contactAsHeader]);
    for (IDRValue *value in self.idrValues)
        [value dumpWithIndent:(indent + 4)];
    for (IDRBlock *block in self.idrBlocks)
        [block dumpWithIndent:(indent + 4)];
}

@end
