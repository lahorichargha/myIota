//
//  IDRImage.h
//  iotaPad6
//
//  Created by Martin on 2011-03-29.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDRAttribs.h"


@interface IDRImage : NSObject <IDRAttribs, NSCoding, NSCopying> {
    
}

@property (nonatomic, retain) NSString *imageName;

- (UIImage *)image;

@end
