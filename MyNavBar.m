//
//  MyNavBar.m
//  minIota
//
//  Created by Martin on 2011-05-21.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "MyNavBar.h"


@implementation MyNavBar

- (void)drawRect:(CGRect)rect {
    UIInterfaceOrientation uio = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(uio)) {
        if (self.frame.size.width < 700) {
            // this is in popover
            [super drawRect:rect];
            return;
        }
    }
    UIImage *image = [UIImage imageNamed:@"bbg.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
