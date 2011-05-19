//
//  IDRDose.h
//  iotaPad6
//
//  Created by Martin on 2011-03-25.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDRAttribs.h"

@interface IDRDose : NSObject <IDRAttribs, NSCoding> {
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableString *content;

@end
