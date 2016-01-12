//
//  stationCategory.m
//  TuneInStation
//
//  Created by Liu Zhe on 1/11/16.
//  Copyright © 2016 Liu Zhe. All rights reserved.
//

#import "stationCategory.h"
#import "ValueKeyDefine.h"

@interface stationCategory()

@property (nonatomic, strong) NSString *urlString;

@property (nonatomic, strong) NSString *titleText;

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *element;

@property (nonatomic, strong) NSString *key;

@end

@implementation stationCategory

- (instancetype)initWithJSONObject:(NSDictionary *)jsDict
{
    self = [super init];
    if (self)
    {
        _urlString = [jsDict objectForKey:kCategoryURL];
        _titleText = [jsDict objectForKey:kCategoryText];
        _type = [jsDict objectForKey:kCategoryType];
        _element = [jsDict objectForKey:kCategoryElement];
        _key = [jsDict objectForKey:kCategoryKey];
    }
    return self;
}

- (NSString *)getTitle
{
    return self.titleText;
}

- (NSString *)getURL
{
    return self.urlString;
}

@end
