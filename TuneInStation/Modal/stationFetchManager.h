//
//  stationFetchManager.h
//  TuneInStation
//
//  Created by Liu Zhe on 1/11/16.
//  Copyright © 2016 Liu Zhe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^categoryResultBlock) (NSArray *categories, NSError *error);
typedef void (^stationResultBlock) (NSArray *results, NSArray *sectionArray, NSString *title, BOOL isCategory, NSError *error);

@interface stationFetchManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchCategoriesInBackgroundWithBlock:(categoryResultBlock)block;

- (void)fetchResultsWithURLString:(NSString *)urlString InBackgroundWithBlock:(stationResultBlock)block;

@end
