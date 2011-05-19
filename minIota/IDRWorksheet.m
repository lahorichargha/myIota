//
//  IDRWorksheet.m
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


#import "IDRWorksheet.h"
#import "NSString+iotaAdditions.h"
#import "IDRDescription.h"
#import "IDRBlock.h"
#import "Funcs.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface IDRWorksheet ()
@end


// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation IDRWorksheet

@synthesize type = _type;
@synthesize title = _title;
@synthesize fromICD10 = _fromICD10;
@synthesize toICD10 = _toICD10;
@synthesize blocks = _blocks;
@synthesize templateUuid = _templateUuid;
@synthesize instanceUuid = _instanceUuid;
@synthesize description = _description;

- (void)dealloc {
    self.type = nil;
    self.title = nil;
    self.fromICD10 = nil;
    self.toICD10 = nil;
    self.blocks = nil;
    self.templateUuid = nil;
    self.instanceUuid = nil;
    self.description = nil;
    [super dealloc];
}

- (id)init {
    if ((self = [super init])) {
        _blocks = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Coding and copying
// -----------------------------------------------------------

static NSString *kTypeKey = @"typeKey";
static NSString *kTitleKey = @"titleKey";
static NSString *kFromICD10Key = @"fromICD10Key";
static NSString *kToICD10Key = @"toICD10Key";
static NSString *kBlocksKey = @"blocksKey";
static NSString *kTemplateUuidKey = @"templateUuidKey";
static NSString *kInstanceUuidKey = @"instanceUuidKey";
static NSString *kDescriptionKey = @"descriptionKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.type = [aDecoder decodeObjectForKey:kTypeKey];
        self.title = [aDecoder decodeObjectForKey:kTitleKey];
        self.fromICD10 = [aDecoder decodeObjectForKey:kFromICD10Key];
        self.toICD10 = [aDecoder decodeObjectForKey:kToICD10Key];
        self.blocks = [aDecoder decodeObjectForKey:kBlocksKey];
        self.templateUuid = [aDecoder decodeObjectForKey:kTemplateUuidKey];
        self.instanceUuid = [aDecoder decodeObjectForKey:kInstanceUuidKey];
        self.description = [aDecoder decodeObjectForKey:kDescriptionKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.type forKey:kTypeKey];
    [aCoder encodeObject:self.title forKey:kTitleKey];
    [aCoder encodeObject:self.fromICD10 forKey:kFromICD10Key];
    [aCoder encodeObject:self.toICD10 forKey:kToICD10Key];
    [aCoder encodeObject:self.blocks forKey:kBlocksKey];
    [aCoder encodeObject:self.templateUuid forKey:kTemplateUuidKey];
    [aCoder encodeObject:self.instanceUuid forKey:kInstanceUuidKey];
    [aCoder encodeObject:self.description forKey:kDescriptionKey];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Accessors
// -----------------------------------------------------------

- (void)blockAdd:(IDRBlock *)block {
    [self.blocks addObject:block];
}

- (NSUInteger)blockCount {
    return [self.blocks count];
}

- (IDRBlock *)blockAtIndex:(NSUInteger)index {
    return [self.blocks objectAtIndex:index];
}

- (IDRBlock *)blockByTemplateUuid:(NSString *)templateUuid {
    for (IDRBlock *block in self.blocks)
        if ([block.templateUuid isEqualToString:templateUuid])
            return block;
    return nil;
}

- (IDRBlock *)blockByInstanceUuid:(NSString *)instanceUuid {
    for (IDRBlock *block in self.blocks) 
        if ([block.instanceUuid isEqualToString:instanceUuid])
            return block;
    return nil;
}

- (NSUInteger)indexOfBlock:(IDRBlock *)block {
    return [self.blocks indexOfObject:block];
}

- (void)removeBlockAtIndex:(NSUInteger)index {
    [self.blocks removeObjectAtIndex:index];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark IDRAttribs 
// -----------------------------------------------------------

- (void)takeAttributes:(NSDictionary *)attribs {
    self.type = [attribs valueForKey:@"type"];
    self.title = [attribs valueForKey:@"title"];
    self.fromICD10 = [attribs valueForKey:@"fromICD10"];
    self.toICD10 = [attribs valueForKey:@"toICD10"];
    self.templateUuid = [attribs valueForKey:@"templateUuid"];
    self.instanceUuid = [attribs valueForKey:@"instanceUuid"];  // not normally in XML
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Copying
// -----------------------------------------------------------

- (IDRWorksheet *)copyWithoutBlocks {
    IDRWorksheet *copy = [[IDRWorksheet alloc] init];
    copy.type = self.type;
    copy.title = self.title;
    copy.fromICD10 = self.fromICD10;
    copy.toICD10 = self.toICD10;
    copy.templateUuid = self.templateUuid;
    copy.instanceUuid = generateUuidString();   // create a new unique identifier
    copy.description = self.description;
    // but leave out self.blocks
    
    // since it's a "copyNnnn" method, return a fully retained object
    return copy;
}

- (id)copyWithZone:(NSZone *)zone {
    IDRWorksheet *copy = [[IDRWorksheet allocWithZone:zone] init];
    copy.type = [[self.type copyWithZone:zone] autorelease];
    copy.title = [[self.title copyWithZone:zone] autorelease];
    copy.fromICD10 = [[self.fromICD10 copyWithZone:zone] autorelease];
    copy.toICD10 = [[self.toICD10 copyWithZone:zone] autorelease];
    copy.templateUuid = [[self.templateUuid copyWithZone:zone] autorelease];
    copy.instanceUuid = generateUuidString();
    copy.description = [[self.description copyWithZone:zone] autorelease];
    return copy;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug
// -----------------------------------------------------------

- (void)dumpWithIndent:(NSUInteger)indent {
    NSLog(@"%@IDRWorksheet dump: %@", [NSString spacesOfLength:indent], self.title);
    for (IDRBlock *block in self.blocks) {
        [block dumpWithIndent:indent + 4];
    }
}




@end
