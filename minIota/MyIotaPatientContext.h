//
//  MyIotaPatientContext.h
//  iotaPad6
//
//  Created by Martin on 2011-05-16.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Patient;
@class IDRContact;
@class IDRBlock;
@class IDRObsDefinition;

@interface MyIotaPatientContext : NSObject {
    
}

@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) NSMutableArray *blocks;
@property (nonatomic, retain) NSMutableArray *contacts;
@property (nonatomic, retain) NSMutableArray *obsDefinitions;
@property (nonatomic, retain) IDRContact *currentContact;


- (id)init;
- (BOOL)addBlockIfNew:(IDRBlock *)theBlock;
- (IDRObsDefinition *)getOrAddObsDefinitionForName:(NSString *)name type:(NSString *)type;

@end
