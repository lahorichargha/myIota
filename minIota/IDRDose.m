//
//  IDRDose.m
//  iotaPad6
//
//  Created by Martin on 2011-03-25.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "IDRDose.h"


@implementation IDRDose

@synthesize name = _name;
@synthesize content = _content;

- (void)dealloc {
    self.name = nil;
    self.content = nil;
    [super dealloc];
}

static NSString *kNameKey = @"nameKey";
static NSString *kContentKey = @"contentKey";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.name = [aDecoder decodeObjectForKey:kNameKey];
        self.content = [aDecoder decodeObjectForKey:kContentKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:kNameKey];
    [aCoder encodeObject:self.content forKey:kContentKey];
}

- (void)takeAttributes:(NSDictionary *)attribs {
    self.name = [attribs valueForKey:@"name"];
}

- (void)addContent:(NSString *)chars {
    if (_content == nil) {
        _content = [[NSMutableString alloc] initWithCapacity:20];
    }
    [_content appendString:chars];
}

@end
