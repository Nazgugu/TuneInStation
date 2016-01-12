//
//  stationCategory.h
//  TuneInStation
//
//  Created by Liu Zhe on 1/11/16.
//  Copyright © 2016 Liu Zhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface stationCategory : NSObject

- (instancetype)initWithJSONObject:(NSDictionary *)jsDict;

- (NSString *)getTitle;

- (NSString *)getURL;

@end
