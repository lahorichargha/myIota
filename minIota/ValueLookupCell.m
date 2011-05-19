//
//  ValueLookupCell.m
//  iotaPad6
//
//  Created by Martin on 2011-03-30.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "ValueLookupCell.h"
#import "IDRValue.h"
#import "IDRContact.h"
#import "Funcs.h"
// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation ValueLookupCell

@synthesize lblDate = _lblDate;
@synthesize lblValue = _lblValue;
@synthesize lblExtendedValue = _lblExtendedValue;

#define kExtendedYOffset        40.0
#define kExtendedMarginBottom   6.0

+ (BOOL)hasUsefulExtendedInfo:(IDRValue *)value {
    return ((value.extendedValue != nil) && ([value.extendedValue length] > 0) && ![value.extendedValue isEqualToString:value.value]);
}

+ (CGFloat)heightOfCell:(IDRValue *)value {
    if ([self hasUsefulExtendedInfo:value]) {
        NSString *exValue = value.extendedValue;
        CGSize size = [exValue sizeWithFont:[UIFont systemFontOfSize:18.0] 
                      constrainedToSize:CGSizeMake(200.0, 1997.0) lineBreakMode:UILineBreakModeWordWrap];
        return size.height + kExtendedYOffset + kExtendedMarginBottom;
    }
    else
        return 34.0;

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect dateRect = CGRectMake(0.0, 0.0, 150.0, 32.0);
        self.lblDate = [[[UILabel alloc] initWithFrame:dateRect] autorelease];
        [self.contentView addSubview:self.lblDate];

        CGRect valueRect = CGRectMake(160.0, 0.0, 350.0, 32.0);
        self.lblValue = [[[UILabel alloc] initWithFrame:valueRect] autorelease];
        [self.contentView addSubview:self.lblValue];
        
        CGRect extendedValueRect = CGRectMake(160.0, kExtendedYOffset, 300.0, 32.0);
        self.lblExtendedValue = [[[UILabel alloc] initWithFrame:extendedValueRect] autorelease];
        self.lblExtendedValue.numberOfLines = 0;
        self.lblExtendedValue.lineBreakMode = UILineBreakModeWordWrap;
        self.lblExtendedValue.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.lblExtendedValue];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setValueObject:(IDRValue *)value {
    self.lblDate.text = dateshort2str(value.contact.date);
    
    // TODO: goddamn, this is ugly! I *have* to fix this more elegantly
    if ([value.value isEqualToString:@"yes"]) {
        self.lblValue.text = @"Ja";
    }
    else if ([value.value isEqualToString:@"no"]) {
        self.lblValue.text = @"Nej";
    }
    else {
        self.lblValue.text = value.value;
    }
    // end of butt ugly
    
    if ([[self class] hasUsefulExtendedInfo:value]) {
        self.lblExtendedValue.text = value.extendedValue;
        [self.lblExtendedValue sizeToFit];
        self.lblExtendedValue.hidden = NO;
    }
    else {
        self.lblExtendedValue.text = @"";   // probably superfluous
        self.lblExtendedValue.hidden = YES;
    }
}

- (void)dealloc {
    self.lblDate = nil;
    self.lblValue = nil;
    self.lblExtendedValue = nil;
    [super dealloc];
}

@end
