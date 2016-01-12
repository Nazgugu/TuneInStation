//
//  MainTableViewController.h
//  TuneInStation
//
//  Created by Liu Zhe on 1/11/16.
//  Copyright © 2016 Liu Zhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "stationCategory.h"

@interface MainTableViewController : UIViewController

@property (nonatomic, assign) BOOL isRoot;

- (instancetype)initWithCategory:(stationCategory *)category;

@end
