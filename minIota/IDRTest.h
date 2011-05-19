//
//  IDRTest.h
//  iotaPad6
//
//  Created by Martin on 2011-03-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDRAttribs.h"

@interface IDRTest : NSObject <IDRAttribs, NSCoding>  {
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) BOOL selected;

@end
