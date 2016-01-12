//
//  station.m
//  TuneInStation
//
//  Created by Liu Zhe on 1/11/16.
//  Copyright © 2016 Liu Zhe. All rights reserved.
//

#import "station.h"
#import "ValueKeyDefine.h"

@interface station()

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *subtitle;

@property (nonatomic, strong) NSString *imageURL;

@end

@implementation station

- (instancetype)initWithStationDict:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        _title = [dict objectForKey:kStationTitle];
        _subtitle = [dict objectForKey:kStationSubTitle];
        _imageURL = [dict objectForKey:kStationImageURL];
    }
    return self;
}

- (NSString *)getImageURLString
{
    return self.imageURL;
}

- (NSString *)getStationTitle
{
    return self.title;
}

- (NSString *)getStationSubTitle
{
    return self.subtitle;
}

@end
