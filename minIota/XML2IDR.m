//
//  XML2IDR.m
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

#import "XML2IDR.h"
#import "IDRWorksheet.h"
#import "IDRBlock.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRAction.h"
#import "IDRImage.h"
#import "IDRTest.h"
#import "IDRDose.h"
#import "IDRDescription.h"
#import "IotaContext.h"

// -----------------------------------------------------------
#pragma mark -
#pragma mark Local declarations
// -----------------------------------------------------------

@interface XML2IDR ()
@property (nonatomic, retain) IDRWorksheet *worksheet;
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *elementStack;
@end


// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation XML2IDR

@synthesize worksheet = _worksheet;
@synthesize parser = _parser;
@synthesize elementStack = _elementStack;

- (id)initWithParser:(NSXMLParser *)parser {
    if ((self = [super init])) {
        _worksheet = [[IDRWorksheet alloc] init];
        self.parser = parser;
        _elementStack = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)dealloc {
    self.worksheet = nil;
    self.parser = nil;
    self.elementStack = nil;
    [super dealloc];
}

+ (IDRWorksheet *)worksheetFromFileName:(NSString *)fileName {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"]];
    return [self worksheetFromXML:url];
}


+ (IDRWorksheet *)worksheetFromXML:(NSURL *)xml {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:xml];
    XML2IDR *xml2idr = [[XML2IDR alloc] initWithParser:parser];
    parser.delegate = xml2idr;
    [parser parse];
    IDRWorksheet *ws = [xml2idr.worksheet retain];
//    [ws dumpWithIndent:4];
    [parser release];
    [xml2idr release];
    return [ws autorelease];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Error handling
// -----------------------------------------------------------

- (void)fatalError:(NSString *)errorMsg parser:(NSXMLParser *)parser {
	NSString *msg = [NSString stringWithFormat:@"Line %d: %@", [parser lineNumber], errorMsg];
    NSLog(@"!!! Fatal error: %@", errorMsg);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	[parser abortParsing];
    self.parser = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString *errMsg = [NSString stringWithFormat:@"Parser error in line %d: %@", [parser lineNumber], [parseError localizedDescription]];
    NSLog(@"%@", errMsg);
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Element stack
// -----------------------------------------------------------

- (void)pushElement:(id)theElement {
    [self.elementStack addObject:theElement];
}

- (id)popElement {
    if ([self.elementStack count] < 1)
        [self fatalError:@"Element stack underflow" parser:self.parser];
    id lastObject = [[self.elementStack lastObject] retain];
    [self.elementStack removeLastObject];
    return [lastObject autorelease];
}

- (id)topOfStackElement {
    if ([self.elementStack count] < 1) {
        [self fatalError:@"Stack unexpectedly empty" parser:self.parser];
    }
    return [[[self.elementStack lastObject] retain] autorelease];
}

- (IDRWorksheet *)document {
    if ([self.elementStack count] != 1) {
        NSLog(@"stack should only contain one element, but contains instead:");
        for (id obj in self.elementStack)
            NSLog(@"on stack: %@", [obj class]);
        [self fatalError:@"Elementstack is not equal to one element after end of parsing" parser:self.parser];
        return nil;
    }
    return [self topOfStackElement];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Tag handling
// -----------------------------------------------------------


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    id <IDRAttribs> newElement = nil;
    
    if ([elementName isEqualToString:@"template"]) {
        self.worksheet = [[[IDRWorksheet alloc] init] autorelease];
        newElement = self.worksheet;
    }
    else if ([elementName isEqualToString:@"description"]) {
        newElement = [[[IDRDescription alloc] init] autorelease];
        id tos = [self topOfStackElement];
        if ([tos respondsToSelector:@selector(setDescription:)])
            [tos performSelector:@selector(setDescription:) withObject:newElement];
        else {
            [self fatalError:[NSString stringWithFormat:@"Could not add IDRDescription to top of stack element: %@", [tos class]] parser:self.parser];
            return;
        }
    }
    else if ([elementName isEqualToString:@"block"]) {
        newElement = [[[IDRBlock alloc] init] autorelease];
        id tos = [self topOfStackElement];
        if ([tos respondsToSelector:@selector(blockAdd:)]) {
            [tos performSelector:@selector(blockAdd:) withObject:newElement];
        }
        else {
            [self fatalError:[NSString stringWithFormat:@"Could not add IDRBlock to top of stack element: %@", [tos class]] parser:self.parser];
            return;
        }
        
    }
    else if ([elementName isEqualToString:@"item"]) {
        newElement = [[[IDRItem alloc] init] autorelease];
        id tos = [self topOfStackElement];
        if ([tos respondsToSelector:@selector(itemAdd:)]) {
            [tos performSelector:@selector(itemAdd:) withObject:newElement];
        }
        else {
            [self fatalError:[NSString stringWithFormat:@"Could not add IDRItem to top of stack element: %@", [tos class]] parser:self.parser];
            return;
        }
    }
    else if ([elementName isEqualToString:@"observation"]) {
        newElement = [[[IDRObservation alloc] init] autorelease];
        id tos = [self topOfStackElement];
        if ([tos respondsToSelector:@selector(setObservation:)]) {
            [tos performSelector:@selector(setObservation:) withObject:newElement];
        }
        else {
            [self fatalError:[NSString stringWithFormat:@"Could not set IDRObservation to top of stack element: %@", [tos class]] parser:self.parser];
            return;
        }
    }
    else if ([elementName isEqualToString:@"action"]) {
        newElement = [[[IDRAction alloc] init] autorelease];
        id tos = [self topOfStackElement];
        if ([tos respondsToSelector:@selector(setAction:)]) {
            [tos performSelector:@selector(setAction:) withObject:newElement];
        }
        else {
            [self fatalError:[NSString stringWithFormat:@"Could not set IDRAction to top of stack element: %@", [tos class]] parser:self.parser];
            return;
        }
    }
    
    else if ([elementName isEqualToString:@"image"]) {
        newElement = [[[IDRImage alloc] init] autorelease];
        id tos = [self topOfStackElement];
        if ([tos respondsToSelector:@selector(setIdrImage:)]) {
            [tos performSelector:@selector(setIdrImage:) withObject:newElement];
        }
        else {
            [self fatalError:[NSString stringWithFormat:@"Could not set IDRImage to top of stack element: %@", [tos class]] parser:self.parser];
            return;
        }
    }
    
    else if ([elementName isEqualToString:@"test"]) {
        newElement = [[[IDRTest alloc] init] autorelease];
        id tos = [self topOfStackElement];
        if ([tos respondsToSelector:@selector(addTest:)]) {
            [tos performSelector:@selector(addTest:) withObject:newElement];
        }
        else {
            [self fatalError:[NSString stringWithFormat:@"Could not add test to top of stack element: %@", [tos class]] parser:self.parser];
            return;
        }
    }
    
    else if ([elementName isEqualToString:@"dose"]) {
        newElement = [[[IDRDose alloc] init] autorelease];
        id tos = [self topOfStackElement];
        if ([tos respondsToSelector:@selector(addDose:)]) {
            [tos performSelector:@selector(addDose:) withObject:newElement];
        }
        else {
            [self fatalError:[NSString stringWithFormat:@"Could not add dose to top of stack element: %@", [tos class]] parser:self.parser];
            return;
        }
    }
    
    else {
        [self fatalError:[NSString stringWithFormat:@"Unknown tag in document: %@", elementName] parser:self.parser];
        return;
    }
    [newElement takeAttributes:attributeDict];
    [self pushElement:newElement];
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    [self popElement];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Content handling
// -----------------------------------------------------------

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    id tos = [self topOfStackElement];
    if ([tos respondsToSelector:@selector(addContent:)]) {
//        NSLog(@"adding characters to %@: %@", [tos class], string);
        [tos performSelector:@selector(addContent:) withObject:string];
    }
}


@end
