//
//  ThemeColors.m
//  minIota
//
//  Created by Martin on 2011-05-12.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "ThemeColors.h"

// 5 colors, theme "Splash" by syork
//      255 250 198
//      222 245 189
//      163 240 171
//      103 235 195
//        9 218 229

@implementation ThemeColors

@synthesize toolbarColor = _toolbarColor;
@synthesize worksheetBackground = _worksheetBackground;
@synthesize worksheetBackgroundPatientBlock = _worksheetBackgroundPatientBlock;
@synthesize entryFieldBackground = _entryFieldBackground;
@synthesize valueBackground = _valueBackground;
@synthesize dateBackground = _dateBackground;

- (id)init {
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

+ (ThemeColors *)themeColors {
    return [[[self alloc] init] autorelease];
}

- (UIColor *)toolbarColor {
    return [UIColor colorWithRed:9.0/255.0 green:218.0/255.0 blue:229.0/255.0 alpha:1.0];
}

- (UIColor *)worksheetBackground {
    return [UIColor whiteColor];
}

- (UIColor *)worksheetBackgroundPatientBlock {
    return [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:198.0/255.0 alpha:1.0];
}

- (UIColor *)entryFieldBackground {
    return [UIColor whiteColor];
}

- (UIColor *)valueBackground {
    return [UIColor colorWithRed:163.0/255.0 green:240.0/255.0 blue:171.0/255.0 alpha:1.0];
}

- (UIColor *)dateBackground {
    return [UIColor colorWithRed:163.0/255.0 green:240.0/255.0 blue:171.0/255.0 alpha:1.0];
}

@end
