//
//  ValueLookupCell.h
//  iotaPad6
//
//  Created by Martin on 2011-03-30.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IDRValue;

@interface ValueLookupCell : UITableViewCell {
    
}

@property (nonatomic, retain) UILabel *lblDate;
@property (nonatomic, retain) UILabel *lblValue;
@property (nonatomic, retain) UILabel *lblExtendedValue;

+ (CGFloat)heightOfCell:(IDRValue *)value;
- (void)setValueObject:(IDRValue *)value;

@end
