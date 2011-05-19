//
//  IDRBlock.m
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


#import "IDRBlock.h"
#import "NSString+iotaAdditions.h"
#import "IDRItem.h"
#import "IDRDescription.h"
#import "IDRContact.h"
#import "IDRWorksheet.h"
#import "Funcs.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface  IDRBlock ()
@property (nonatomic, retain) NSString *type;   // used in keywords for journal
@end

// -----------------------------------------------------------

@implementation IDRBlock

@synthesize type = _type;
@synthesize title = _title;
@synthesize items = _items;
@synthesize repeats = _repeats;
@synthesize templateUuid = _templateUuid;
@synthesize instanceUuid = _instanceUuid;
@synthesize description = _description;
@synthesize contact = _contact;
@synthesize worksheet = _worksheet;

- (id)init {
//    NSLog(@"creating an IDRBlock");
    if ((self = [super init])) {
        _items = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)dealloc {
    self.type = nil;
    self.items = nil;
    self.templateUuid = nil;
    self.instanceUuid = nil;
    self.description = nil;
    self.contact = nil;
    self.worksheet = nil;
    [super dealloc];
}

- (BOOL)removeSelf {
    [self.contact.idrBlocks removeObject:self];
    [self.worksheet.blocks removeObject:self];
    return YES;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Coding, copying
// -----------------------------------------------------------

static NSString *kTypeKey = @"typeKey";
static NSString *kTitleKey = @"titleKey";
static NSString *kItemsKey = @"itemsKey";
static NSString *kTemplateUuidKey = @"templateUuidKey";
static NSString *kInstanceUuidKey = @"instanceUuidKey";
static NSString *kDescriptionKey = @"descriptionKey";
static NSString *kRepeatsKey = @"repeatsKey";
static NSString *kContactKey = @"contactKey";
static NSString *kWorksheetKey = @"worksheetKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.type = [aDecoder decodeObjectForKey:kTypeKey];
        self.title = [aDecoder decodeObjectForKey:kTitleKey];
        self.items = [aDecoder decodeObjectForKey:kItemsKey];
        self.templateUuid = [aDecoder decodeObjectForKey:kTemplateUuidKey];
        self.instanceUuid = [aDecoder decodeObjectForKey:kInstanceUuidKey];
        self.description = [aDecoder decodeObjectForKey:kDescriptionKey];
        self.repeats = [aDecoder decodeBoolForKey:kRepeatsKey];
        self.contact = [aDecoder decodeObjectForKey:kContactKey];
        self.worksheet = [aDecoder decodeObjectForKey:kWorksheetKey];
        NSLog(@"decoding IDRBlock %@, %@", self.type, self.title);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSLog(@"encoding IDRBlock %@, %@", self.type, self.title);
    [aCoder encodeObject:self.type forKey:kTypeKey];
    [aCoder encodeObject:self.title forKey:kTitleKey];
    [aCoder encodeObject:self.items forKey:kItemsKey];
    [aCoder encodeObject:self.templateUuid forKey:kTemplateUuidKey];
    [aCoder encodeObject:self.instanceUuid forKey:kInstanceUuidKey];
    [aCoder encodeObject:self.description forKey:kDescriptionKey];
    [aCoder encodeBool:self.repeats forKey:kRepeatsKey];
    [aCoder encodeObject:self.contact forKey:kContactKey];
    [aCoder encodeObject:self.worksheet forKey:kWorksheetKey];
}

- (id)copyWithZone:(NSZone *)zone {
    IDRBlock *copy = [[IDRBlock allocWithZone:zone] init];
    copy.type = [[self.type copyWithZone:zone] autorelease];
    copy.title = [[self.title copyWithZone:zone] autorelease];
    copy.items = [[self.items mutableCopyWithZone:zone] autorelease];
    copy.repeats = self.repeats;
    copy.templateUuid = [[self.templateUuid copyWithZone:zone] autorelease];
    copy.instanceUuid = generateUuidString();       // unique for each copy
    copy.description = [[self.description copyWithZone:zone] autorelease];
    // when copying a block, it by default stays hooked up to the same contact and worksheet
    copy.contact = self.contact;
    copy.worksheet = self.worksheet;
    
    for (IDRItem *item in copy.items)
        item.parentBlock = copy;
    
    return copy;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Other accessors
// -----------------------------------------------------------

- (void)itemAdd:(IDRItem *)item {
    item.parentBlock = self;
    [self.items addObject:item];
}

- (enum eBlockType)blockType {
    if ([self.type isEqualToString:@"any"]) return eBlockTypeAny;
    if ([self.type isEqualToString:@"default"]) return eBlockTypeDefault;
    if ([self.type isEqualToString:@"initial"]) return eBlockTypeInitial;
    if ([self.type isEqualToString:@"qr"]) return eBlockTypeQr;
    if ([self.type isEqualToString:@"followup"]) return eBlockTypeFollowup;
    if ([self.type isEqualToString:@"patient"]) return eBlockTypePatient;
    return eBlockTypeNone;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark IDRAttribs
// -----------------------------------------------------------

- (void)takeAttributes:(NSDictionary *)attribs {
    self.type = [attribs valueForKey:@"type"];
    self.title = [attribs valueForKey:@"title"];
    self.templateUuid = [attribs valueForKey:@"templateUuid"];
    self.repeats = [[attribs valueForKey:@"repeats"] isEqualToString:@"yes"];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Debug
// -----------------------------------------------------------

- (void)dumpWithIndent:(NSUInteger)indent {
    NSLog(@"%@IDRBlock: %@, %@", [NSString spacesOfLength:indent], self.title, self.type);
    for (IDRItem *item in self.items) {
        [item dumpWithIndent:indent + 4];
    }
}

@end
