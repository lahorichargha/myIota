//
//  ThemeColors.h
//  minIota
//
//  Created by Martin on 2011-05-12.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ThemeColors : NSObject {
    
}

+ (ThemeColors *)themeColors;

@property (nonatomic, readonly) UIColor *toolbarColor;
@property (nonatomic, readonly) UIColor *worksheetBackground;
@property (nonatomic, readonly) UIColor *worksheetBackgroundPatientBlock;
@property (nonatomic, readonly) UIColor *entryFieldBackground;
@property (nonatomic, readonly) UIColor *valueBackground;
@property (nonatomic, readonly) UIColor *dateBackground;

@end
