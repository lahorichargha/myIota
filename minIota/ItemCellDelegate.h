//
//  ItemCellDelegate.h
//  iotaPad6
//
//  Created by Martin on 2011-03-24.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDRItem;

@protocol ItemCellDelegate <NSObject>
- (void)presentValueLookupForm:(IDRItem *)item;
@optional
- (void)presentLabOrderForm:(IDRItem *)item;
- (void)presentReferralForm:(IDRItem *)item;
- (void)presentPrescriptionForm:(IDRItem *)item;

@end
