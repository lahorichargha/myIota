//
//  MyToolBar.m
//  minIota
//
//  Created by Martin on 2011-05-21.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "MyToolBar.h"


@implementation MyToolBar


- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"bbg.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
