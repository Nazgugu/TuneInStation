//
//  station.h
//  TuneInStation
//
//  Created by Liu Zhe on 1/11/16.
//  Copyright © 2016 Liu Zhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface station : NSObject

- (instancetype)initWithStationDict:(NSDictionary *)dict;

- (NSString *)getImageURLString;

- (NSString *)getStationTitle;

- (NSString *)getStationSubTitle;

@end
