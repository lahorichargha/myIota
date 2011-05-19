//
//  IDRBlock.h
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


#import <Foundation/Foundation.h>
#import "IDRAttribs.h"
#import "DebugDump.h"

@class IDRItem;
@class IDRDescription;
@class IDRContact;
@class IDRWorksheet;

enum eBlockType {
    eBlockTypeNone,
    eBlockTypeAny,
    eBlockTypeDefault,
    eBlockTypeInitial,
    eBlockTypeFollowup,
    eBlockTypeQr,
    eBlockTypePatient,
};


@interface IDRBlock : NSObject <IDRAttribs, DebugDump, NSCoding, NSCopying> {
    
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *templateUuid;
@property (nonatomic, retain) NSString *instanceUuid;
@property (nonatomic, assign) BOOL repeats;
@property (nonatomic, retain) IDRDescription *description;
@property (nonatomic, retain) NSMutableArray *items;

@property (nonatomic, retain) IDRContact *contact;
// if worksheet is nil, this block is a journal record
@property (nonatomic, retain) IDRWorksheet *worksheet;    


- (BOOL)removeSelf;
- (enum eBlockType)blockType;

@end
