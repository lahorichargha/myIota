//
//  NSString+iotaAdditions.m
//  iotaPad1
//
//  Created by mw on 2010-06-23.
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

#import "NSString+iotaAdditions.h"


@implementation NSString (iotaNSString)


// from stackoverflow, originally from OmniFrameworks
+ (NSString *)spacesOfLength:(unsigned int)aLength {
	static NSMutableString *spaces = nil;
	static NSLock *spacesLock;
	static unsigned int spacesLength = 0;
	
	if (!spaces) {
		spaces = [@"                " mutableCopy];	// 16 spaces
		spacesLength = [spaces length];
		spacesLock = [[NSLock alloc] init];
	}
	
	if (spacesLength < aLength) {
		[spacesLock lock];
		while (spacesLength < aLength) {
			[spaces appendString:spaces];	// doubling each time
			spacesLength += spacesLength;
		}
		[spacesLock unlock];
	}
	return [spaces substringToIndex:aLength];
}

- (NSString *)trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)iotaNormalize {
	NSArray *decomp = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSMutableArray *decompMutable = [[decomp mutableCopy] autorelease];
	for (NSString *s in decomp)
		if ([s length] == 0)
			[decompMutable removeObject:s];
	NSString *reduced = [decompMutable componentsJoinedByString:@" "];
	return reduced;
}	
	
- (BOOL)iotaIsNonEmpty {
	return ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0);
}

- (BOOL)iotaIsYes {
	return ([self caseInsensitiveCompare:@"yes"] == NSOrderedSame);
}

- (NSString *)setterName {
    // convert a property name to the correct setter name
    // by capitalizing the first letter then prefixing "set"
    
    NSMutableString *result = [[[NSMutableString alloc] initWithString:@"set"] autorelease];
    [result appendString:[[self substringToIndex:1] uppercaseString]];
    if ([self length] > 1)
        [result appendString:[self substringFromIndex:1]];
    [result appendString:@":"];
    return [[result copy] autorelease];
}
	
@end
