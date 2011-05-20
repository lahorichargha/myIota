//
//  ItemCellController.m
//  iotaPad6
//
//  Created by Martin on 2011-03-04.
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


/* --------------------------------------------------------------------------
 * There are several kinds of cell possible, each with another layout:
 *
 *  Simple content, no observation nor retrieval of values. The text occupies
 *  almost full width.
 *
 *  Content with retrieval, but no data entry. The text occupies medium wide width
 *  and rightmost you'll find two retrieval fields for the old values.
 *
 *  Content with numeric data entry in the observation and two retrieval fields. To the
 *  left, the content is in its medium narrow form.
 *
 *  Content with string data entry and two retrieval fields. The content is in its narrowest
 *  form.
 *
 *  Content with data entry, but no retrieval. The content is in its narrowest or medium narrow form
 *  depending on if it's string or numeric entry, respectively, 
 *  and the data entry field lines up with other entry fields, so the rightmost part
 *  of the cell is empty.
 *
 */


#import "ItemCell.h"
#import "BulletView.h"
#import "IDRItem.h"
#import "IDRObservation.h"
#import "IDRObsDefinition.h"
#import "IDRValue.h"
#import "IDRItem.h"
#import "IDRImage.h"
#import "IDRAction.h"
#import "NSString+iotaAdditions.h"
#import "Funcs.h"
#import "IDRContact.h"
#import "IDRBlock.h"
#import "Notifications.h"
#import "IotaContext.h"
#import "IDRWorksheet.h"
#import "ThemeColors.h"

#define TAG_LBLCONTENT  1001
#define TAG_TEXTFIELD   1002
#define TAG_LBLVALUE    1003
#define TAG_LBLDATE     1004
#define TAG_IMAGE       1005
#define TAG_BULLET      1006
#define TAG_CHECKVIEW   1007

static float kNormalFontSize = 14.0;
static float kBoldFontSize = 18.0;
//static float kBoldHeight = 44.0;

static float kValueOffsetFromTop = 1.0;
static float kValueOffsetFromRight = 200.0;
static float kValueWidth = 90.0;
static float kValueHeight = 20.0;

static float kDateOffsetFromTop = 1.0;
static float kDateOffsetFromRight = 100.0;
static float kDateWidth = 95.0;
static float kDateHeight = 20.0;

static float kInputOffsetFromTop = 1.0;
static float kInputOffsetRightEndFromRight = 210; 
//static float kInputFontSize = 14.0;
static float kInputWidthWide = 200.0;
static float kInputWidthNarrow = 150.0;
static float kInputHeight = 26.0;

//static float kRetrieveOffsetFromTop = 1.0;
//static float kRetrieveFontSize = 12.0;
//static float kRetrieveWidth = 90.0;
//static float kRetrieveHeight = 22.0;

//static float kPadHeight = 6.0;
static float kIndentSize = 20.0;

static float kContentTextOffsetFromLeft = 5.0;
static float kContentTextOffsetFromTop = 3.0;
//static float kTextViewFontSize = 14.0;

// indicate the right margin for the content text in different situation
// the width depends on right margin *and* indent
static float kNarrowRight = 200.0;
static float kMediumNarrowRight = 300.0;
static float kMediumWideRight = 400.0;
static float kWideRight = 600.0;

//static float kMinimumCellHeight = 32.0; is now settable in user defaults

//static float kSpacing = 5.0;		// between input and retrieves and retrieves and margin

//static float kBulletDistance = 8.0;	// how much to the left of the text that the bullet is shown
//static float kBulletFromTop = 10.0;
//static float kBulletWidth = 4.0;
//static float kBulletHeight = 4.0;

// images

//static float kImageXOffset = 300.0;
static float kImageXOffsetFromRight = 50.0;
static float kImageTopMargin = 8.0;
static float kImageBottomMargin = 8.0;
//static float kImageLeftMargin = 12.0;

static float kMinRightMargin = 5.0;

// check view
static float kCheckViewWidth = 50.0;

enum eCellContents {
    ecPureText,
    ecTextWithGet,
    ecTextWithGetAndPutNumeric,
    ecTextWithGetAndPutString,
    ecTextWithGetAndPutCheck,
    ecTextWithImage
};

// -----------------------------------------------------------
#pragma mark -
#pragma mark Lifecycle
// -----------------------------------------------------------

@implementation ItemCell

@synthesize isActive = _isActive;
@synthesize idrItem = _idrItem;
@synthesize lblContent = _lblContent;
@synthesize textField = _textField;
@synthesize lblValue = _lblValue;
@synthesize lblDate = _lblDate;
@synthesize itemImageView = _itemImageView;
@synthesize bulletView = _bulletView;
@synthesize checkView = _checkView;
@synthesize itemCellDelegate = _itemCellDelegate;

- (UIView *)viewOfClass:(Class)cls frame:(CGRect)frame tag:(NSUInteger)tag {
    UIView *view = [[cls alloc] initWithFrame:frame];
    view.tag = tag;
    [self.contentView addSubview:view];
    return [view autorelease];
}

- (id)init {
    if ((self = [super init])) {
        CGRect defaultRect = CGRectMake(0,0,100,20);
        self.lblContent = (UILabel *)[self viewOfClass:[UILabel class] frame:defaultRect tag:TAG_LBLCONTENT];
        self.lblContent.userInteractionEnabled = YES;
        
        self.textField = (UITextField *)[self viewOfClass:[UITextField class] frame:defaultRect tag:TAG_TEXTFIELD];
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        self.textField.delegate = self;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        UIToolbar *tb = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 10, 30)] autorelease];
        tb.barStyle = UIBarStyleBlackTranslucent;
        UIBarButtonItem *bbispacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
        UIImage *microImage = [UIImage imageNamed:@"tape4.png"];
        UIBarButtonItem *bbirec = [[[UIBarButtonItem alloc] initWithImage:microImage style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        UIBarButtonItem *bbiplay = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:nil action:nil] autorelease];
        UIBarButtonItem *bbicamera = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:nil] autorelease];
        tb.items = [NSArray arrayWithObjects:bbirec, bbispacer, bbicamera, bbispacer, bbiplay, nil];
        
        self.textField.inputAccessoryView = tb;
        
        
        self.lblValue = (UILabel *)[self viewOfClass:[UILabel class] frame:defaultRect tag:TAG_LBLVALUE];
        self.lblValue.backgroundColor = [[ThemeColors themeColors] valueBackground];
        self.lblValue.userInteractionEnabled = YES;
        
        self.lblDate = (UILabel *)[self viewOfClass:[UILabel class] frame:defaultRect tag:TAG_LBLDATE];
        self.lblDate.backgroundColor = [[ThemeColors themeColors] dateBackground];
        
        self.itemImageView = (UIImageView *)[self viewOfClass:[UIImageView class] frame:CGRectMake(0, 0, 200.0, 200.0) tag:TAG_IMAGE];
        self.itemImageView.userInteractionEnabled = YES;
        
        self.bulletView = (BulletView *)[self viewOfClass:[BulletView class] frame:defaultRect tag:TAG_BULLET];
        
        self.checkView = (UILabel *)[self viewOfClass:[UILabel class] frame:defaultRect tag:TAG_CHECKVIEW];
        self.checkView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    self.idrItem = nil;
    self.lblContent = nil;
    self.textField = nil;
    self.lblValue = nil;
    self.lblDate = nil;
    self.itemImageView = nil;
    self.bulletView = nil;
    self.checkView = nil;
    self.itemCellDelegate = nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Convenience constructors
// -----------------------------------------------------------

// TODO: split the creation of the cell into different cell lines, so that they don't need
// reconfiguration in the layout routine, at the cost of more queued cells.

+ (ItemCell *)cellForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    static NSString *cellId = @"itemCellID";
    ItemCell *cell = (ItemCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[ItemCell alloc] init] autorelease];
        cell.lblContent.backgroundColor = [UIColor clearColor];
        cell.checkView.backgroundColor = [UIColor clearColor];
    }
    cell.idrItem = idrItem;
    cell.lblContent.text = [idrItem.content iotaNormalize];
    cell.lblContent.font = (idrItem.isBold) ? [UIFont boldSystemFontOfSize:kBoldFontSize] : [UIFont systemFontOfSize:kNormalFontSize];

    IDRItem *item = idrItem;
    IDRBlock *block = item.parentBlock;
    NSAssert(block != nil, @"Item has no parent");
    if (item.idrImage != nil) {
        NSLog(@"Image name: %@", item.idrImage.imageName);
        cell.imageView.image = [item.idrImage image];
        CGSize idrImageSize = [[item.idrImage image] size];
        CGRect newFrame = CGRectMake(0, 0, idrImageSize.width, idrImageSize.height);
        cell.imageView.frame = newFrame;
        NSLog(@"hi");
    }
    if ([item hasObservation]) {
        IDRObservation *observation = item.observation;
        IDRObsDefinition *obsDef = observation.obsDefinition;
        IDRContact *contact = block.contact;
//        IDRValue *value = [obsDef valueForContact:contact];
        IDRValue *value = [obsDef anyValue];
        if ([item hasInput]) {
            if ([item.observation isCheck]) {
                if ([value.value isEqualToString:@"yes"])
                    cell.checkView.text = @"Ja";
                else if ([value.value isEqualToString:@"no"])
                    cell.checkView.text = @"Nej";
                else
                    cell.checkView.text = @"?";
            }
            else {
                cell.textField.text = value.value;
            }
        }
        if ([item hasGet]) {
            NSLog(@"hasGet for obs %@", obsDef.name);
            IDRValue *getValue;
            if ([item hasInput]) 
                getValue = [obsDef valueBeforeContact:contact];
            else {
                // a sole 'get' means we should display the most recent value, such as sent referral or quality regs
                getValue = [obsDef valueForOrBeforeContact:contact];
            }
            if (getValue != nil) {
                cell.lblValue.text = getValue.displayValue;
                cell.lblDate.text = dateshort2str(getValue.contact.date);
            }
        }
    }
    if ([item hasAction]) {
        cell.lblContent.textColor = [UIColor blueColor];
    }
    return cell;
}

+ (enum eCellContents)contentType:(IDRItem *)idrItem {
    if ([idrItem.idrImage image] != nil)
        return ecTextWithImage;
    if (![idrItem hasObservation])
        return ecPureText;
    if (![idrItem hasInput])
        return ecTextWithGet;
    if ([idrItem.observation isNumeric])
        return ecTextWithGetAndPutNumeric;
    if ([idrItem.observation isCheck])
        return ecTextWithGetAndPutCheck;
    return ecTextWithGetAndPutString;
}

+ (CGFloat)contentRightMargin:(IDRItem *)idrItem {
    switch ([self contentType:idrItem]) {
        case ecPureText:
            return kWideRight;
        case ecTextWithGet:
            return kMediumWideRight;
        case ecTextWithGetAndPutNumeric:
            return kMediumNarrowRight;
        case ecTextWithGetAndPutString:
            return kNarrowRight;
        case ecTextWithImage:
            return kMediumWideRight;
        case ecTextWithGetAndPutCheck:
            return kMediumWideRight;
        default:
            return kNarrowRight;
    }
}

+ (UIFont *)boldContentFont {
    return [UIFont boldSystemFontOfSize:kBoldFontSize];
}

+ (UIFont *)normalContentFont {
    return [UIFont systemFontOfSize:kNormalFontSize];
}

+ (UIFont *)contentFontBold:(BOOL)bold {
    return (bold) ? [self boldContentFont] : [self normalContentFont];
}

+ (CGFloat)contentLeftMargin:(IDRItem *)idrItem {
    return idrItem.indentLevel * kIndentSize + kContentTextOffsetFromLeft;
}

+ (CGFloat)cellHeightForTableView:(UITableView *)tableView idrItem:(IDRItem *)idrItem {
    CGFloat contentWidth = [self contentRightMargin:idrItem] - [self contentLeftMargin:idrItem];
    
    CGFloat formWidth = tableView.frame.size.width;
    contentWidth = fminf(contentWidth, formWidth - kMinRightMargin);
    
    NSString *sContent = [idrItem.content iotaNormalize];
    CGSize size = [sContent sizeWithFont:[self contentFontBold:idrItem.isBold] constrainedToSize:CGSizeMake(contentWidth, 1997.0) lineBreakMode:UILineBreakModeWordWrap];
    size.height += kContentTextOffsetFromTop;
    UIImage *image = [idrItem.idrImage image];
    if (image != nil) {
        CGFloat imageHeight = image.size.height + kImageTopMargin + kImageBottomMargin;
        size.height = fmax(size.height, imageHeight);
    }
    CGFloat minCellHeight = [IotaContext minRowHeight];
    return fmax(minCellHeight, size.height);
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Helper stuff
// -----------------------------------------------------------

- (IDRValue *)getValueObject {
    IDRItem *item = self.idrItem;
    IDRBlock *block = item.parentBlock;
    NSAssert((block != nil), @"Item has no parent");
    if ([item hasObservation]) {
        IDRObservation *observation = item.observation;
        IDRObsDefinition *obsDef = observation.obsDefinition;
        IDRValue *value = [obsDef anyValue];
//        IDRContact *contact = block.contact;
//        IDRValue *value = [obsDef valueForContact:contact];
        return value;
    }
    else
        return nil;
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Layout
// -----------------------------------------------------------

- (void)slideViewToX:(CGFloat)xOffset rightMargin:(CGFloat)rightMargin view:(UIView *)view {
    view.frame = CGRectMake(xOffset, view.frame.origin.y, rightMargin - xOffset, view.frame.size.height);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat currentWidth = self.frame.size.width;
    CGFloat contentLeftMargin = [[self class] contentLeftMargin:self.idrItem];
    CGFloat contentRightMargin = [[self class] contentRightMargin:self.idrItem];
    
    CGFloat formWidth = self.contentView.frame.size.width;
    contentRightMargin = fminf(contentRightMargin, formWidth - kMinRightMargin);
    
    self.bulletView.hidden = !self.idrItem.hasBullet;
    

    switch ([[self class] contentType:self.idrItem]) {
        case ecTextWithImage:
            self.textField.hidden = YES;
            self.lblValue.hidden = YES;
            self.lblDate.hidden = YES;
            self.itemImageView.hidden = NO;
            self.checkView.hidden = YES;
            break;
        case ecPureText:
            self.textField.hidden = YES;
            self.lblValue.hidden = YES;
            self.lblDate.hidden = YES;
            self.itemImageView.hidden = YES;
            self.checkView.hidden = YES;
            break;
        case ecTextWithGet:
            self.textField.hidden = YES;
            self.lblValue.hidden = NO;
            self.lblDate.hidden = NO;
            self.itemImageView.hidden = YES;
            self.checkView.hidden = YES;
            break;
        case ecTextWithGetAndPutNumeric:
            self.textField.hidden = NO;
            self.textField.frame = CGRectMake(currentWidth - kInputOffsetRightEndFromRight - kInputWidthNarrow, 
                                              kInputOffsetFromTop, kInputWidthNarrow, kInputHeight);
            self.lblValue.hidden = NO;
            self.lblDate.hidden = NO;
            self.itemImageView.hidden = YES;
            self.checkView.hidden = YES;
            break;
        case ecTextWithGetAndPutString:
            self.textField.hidden = NO;
            self.textField.frame = CGRectMake(currentWidth - kInputOffsetRightEndFromRight - kInputWidthWide, 
                                              kInputOffsetFromTop, kInputWidthWide, kInputHeight);
            self.lblValue.hidden = NO;
            self.lblDate.hidden = NO;
            self.itemImageView.hidden = YES;
            self.checkView.hidden = YES;
            break;
        case ecTextWithGetAndPutCheck:
            self.textField.hidden = YES;
            self.lblValue.hidden = NO;
            self.lblDate.hidden = NO;
            self.itemImageView.hidden = YES;
            self.checkView.hidden = NO;
            break;
        default:
            break;
    }
    
    if (!self.isActive) {
        self.lblValue.hidden = YES;
        self.lblDate.hidden = YES;
        self.checkView.hidden = YES;
        self.textField.hidden = YES;
    }

    [self slideViewToX:contentLeftMargin rightMargin:contentRightMargin view:self.lblContent];
    
    if (self.isActive) {
        self.lblValue.frame = CGRectMake(currentWidth - kValueOffsetFromRight, kValueOffsetFromTop, kValueWidth, kValueHeight);
        self.lblDate.frame = CGRectMake(currentWidth - kDateOffsetFromRight, kDateOffsetFromTop, kDateWidth, kDateHeight);
    }
    
    self.lblContent.frame = CGRectMake(contentLeftMargin, kContentTextOffsetFromTop, contentRightMargin - contentLeftMargin, 20);
    self.lblContent.numberOfLines = 0;
    self.lblContent.lineBreakMode = UILineBreakModeWordWrap;
    [self.lblContent sizeToFit];
    
    if (self.isActive) {
        self.checkView.frame = CGRectMake(currentWidth - kInputOffsetRightEndFromRight - kCheckViewWidth, kInputOffsetFromTop, 
                                      kCheckViewWidth, kInputHeight);
        self.checkView.userInteractionEnabled = YES;
    }
    
    if ((self.idrItem.idrImage != nil) && ([self.idrItem.idrImage image] != nil)) {
        CGSize imageSize = [self.idrItem.idrImage image].size;
        self.imageView.frame = CGRectMake(currentWidth - kImageXOffsetFromRight - imageSize.width, 0, imageSize.width, imageSize.height);
    }
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Text field delegate
// -----------------------------------------------------------

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)setValue:(NSString *)value {
    [self.idrItem setItemValue:value];
}

// the item should only be enabled for edit if the contact the item belongs
// to is the same as the current contact according to the context
- (BOOL)isItemCurrentlyEnabled {
#ifdef MINIOTA
    return YES;
#endif
#ifdef IOTAMED
    if (!self.isActive)
        return NO;
    IDRContact *currentContact = [[IotaContext getCurrentPatientContext] currentContact];
    IDRContact *itemContact = self.idrItem.parentBlock.contact;
    return (currentContact == itemContact);
#endif
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    @try {
        if (![self isItemCurrentlyEnabled]) {
            NSString *msg;
            if (!self.isActive)
                msg = @"Du kan bara föra in information i en mall om den lagts till en patientjournal som issue";
            else 
                msg = @"Du kan inte ändra i textfältet eftersom den valda kontakten inte är densamma som issue kontakten";
            UIAlertView *aw = [[[UIAlertView alloc] 
                            initWithTitle:@"Information" 
                            message: msg
                            delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
            [aw show];
            return NO;
        }
        else {
            // need to hang on to the item cell even if the cell has scrolled away from view
            // and the subviews have been released, else crashes on resignFirstResponder
            // TODO: I wonder what happens if the system
            // reuses the cell while I'm still hanging on to it... huh...
            // IOW, I don't think this is a good solution.
            [self retain]; 
            return YES;
        }
    }
    @catch (NSException *ex) {
        NSLog(@"*** Exception: %@", ex);
        return NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *newText = textField.text;
    [self setValue:newText];
    [[NSNotificationCenter defaultCenter] postNotificationName:kObservationDataChangedNotification object:nil];
    [self release];
}


// -----------------------------------------------------------
#pragma mark -
#pragma mark Lookups
// -----------------------------------------------------------

- (void)doValueLookup {
    [self.itemCellDelegate presentValueLookupForm:self.idrItem];
}

// -----------------------------------------------------------
#pragma mark -
#pragma mark Touch stuff
// -----------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.isActive)
        return;
    
    UITouch *touch = [touches anyObject];

    // note that the textfield is handled elsewhere
    BOOL tagIsEditTag = (touch.view.tag == TAG_CHECKVIEW) || (touch.view.tag == TAG_IMAGE) ||
                    ((touch.view.tag == TAG_LBLCONTENT) && [self.idrItem hasAction]);
    if (tagIsEditTag && (![self isItemCurrentlyEnabled])) {
        UIAlertView *aw = [[[UIAlertView alloc] 
                           initWithTitle:@"Information" 
                                 message:@"Du kan inte ändra i innehållet eftersom den valda kontakten inte är densamma som issue kontakten" 
                            delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [aw show];
        return;
    }
        
    NSLog(@"Eeek! Somebody touched me at tag: %d! for %@", touch.view.tag, self.idrItem.observation.obsDefinition.name);
    
    switch (touch.view.tag) {
        case TAG_LBLCONTENT:
        case TAG_IMAGE:
            // no actions in minIota
//            if ([self.idrItem hasAction]) {
//                NSString *type = self.idrItem.action.type;
//                if ([type isEqualToString:@"lab"]) {
//                    [self doLabAction];
//                }
//                else if ([type isEqualToString:@"prescription"]) {
//                    [self doPrescriptionAction];
//                }
//                else if ([type isEqualToString:@"referral"]) {
//                    [self doReferralAction];
//                }
//                else if ([type isEqualToString:@"block"]) {
//                    [self doBlockAction];
//                }
//            }
            break;
        case TAG_CHECKVIEW: {
            IDRValue *value = [self getValueObject];
            if ((value == nil) || [value.value isEqualToString:@""])
                [self setValue:@"yes"];
            else if ([value.value isEqualToString:@"yes"])
                [self setValue:@"no"];
            else
                [self setValue:@""];
            [self setNeedsLayout];
            [[NSNotificationCenter defaultCenter] postNotificationName:kObservationDataChangedNotification object:nil];
            break;
        }
            
//        case TAG_IMAGE:
//            break;
        case TAG_LBLVALUE:
            if ([self.idrItem hasGet]) {
                [self doValueLookup];
            }
            break;
        default:
            break;
    }
    
}

@end
