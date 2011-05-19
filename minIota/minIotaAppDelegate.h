//
//  minIotaAppDelegate.h
//  minIota
//
//  Created by Martin on 2011-05-09.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IssueListController;
@class DetailViewController;

@interface minIotaAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, retain) IBOutlet IssueListController *issueListController;

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;


@end
