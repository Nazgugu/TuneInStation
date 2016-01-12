//
//  stationFetchManager.m
//  TuneInStation
//
//  Created by Liu Zhe on 1/11/16.
//  Copyright © 2016 Liu Zhe. All rights reserved.
//

#import "stationFetchManager.h"
#import <AFNetworking/AFNetworking.h>
#import "ValueKeyDefine.h"
#import "stationCategory.h"
#import "station.h"

@implementation stationFetchManager

+ (instancetype)sharedManager
{
    static stationFetchManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)fetchCategoriesInBackgroundWithBlock:(categoryResultBlock)block
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown)
        {
//            NSLog(@"not reachable");
            block(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:10 userInfo:nil]);
        }
        else
        {
//            NSLog(@"reachable");
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager.operationQueue cancelAllOperations];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSString *urlString = @"http://opml.radiotime.com/?render=json";
            NSURL *url = [NSURL URLWithString:urlString];
            [manager GET:url.absoluteString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSArray *resultsArray = [NSArray new];
                resultsArray = [responseObject objectForKey:kCategoryArray];
                if (resultsArray.count == 0)
                {
                    block([NSArray new], nil);
                }
                else
                {
                    NSMutableArray *categoryList = [[NSMutableArray alloc] init];
                    for (NSDictionary *jsDict in resultsArray)
                    {
                        stationCategory *stationTypes = [[stationCategory alloc] initWithJSONObject:jsDict];
                        [categoryList addObject:stationTypes];
                    }
                    block(categoryList, nil);
                }
                NSLog(@"%@",responseObject);
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                NSLog(@"failed %@",error);
                block(nil,error);
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

}

- (void)fetchResultsWithURLString:(NSString *)urlString InBackgroundWithBlock:(stationResultBlock)block
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown)
        {
            //            NSLog(@"not reachable");
            block(nil, nil, nil, NO, [NSError errorWithDomain:NSCocoaErrorDomain code:10 userInfo:nil]);
        }
        else
        {
            //            NSLog(@"reachable");
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager.operationQueue cancelAllOperations];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSString *theURLString = [urlString stringByAppendingString:@"&render=json"];
            NSURL *url = [NSURL URLWithString:theURLString];
            [manager GET:url.absoluteString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSArray *rawResults = [responseObject objectForKey:kCategoryArray];
                if (rawResults.count > 0)
                {
                    NSDictionary *rawObject = [rawResults objectAtIndex:0];
                    if ([rawObject objectForKey:kResultChildren])
                    {
                        //this case it is stations;
                        NSMutableArray *finalResultsArray = [[NSMutableArray alloc] init];
                        NSMutableArray *sectionTitleArray = [[NSMutableArray alloc] init];
                        for (NSDictionary *rawDict in rawResults)
                        {
                            NSMutableArray *sectionStationArray = [[NSMutableArray alloc] init];
                            [sectionTitleArray addObject:[rawDict objectForKey:kCategoryText]];
                            NSArray *rawStationArray = [rawDict objectForKey:kResultChildren];
                            for (NSDictionary *rawStation in rawStationArray)
                            {
                                station *theStation = [[station alloc] initWithStationDict:rawStation];
                                [sectionStationArray addObject:theStation];
                            }
                            [finalResultsArray addObject:sectionStationArray];
                        }
                        block(finalResultsArray, sectionTitleArray, [[responseObject objectForKey:kResultHead] objectForKey:kResultTitle], YES, nil);
                    }
                    else
                    {
                        //this case it is categories
                        NSMutableArray *categoryList = [[NSMutableArray alloc] init];
                        for (NSDictionary *jsDict in rawResults)
                        {
                            stationCategory *stationTypes = [[stationCategory alloc] initWithJSONObject:jsDict];
                            [categoryList addObject:stationTypes];
                        }
                        block(categoryList, nil, [[responseObject objectForKey:kResultHead] objectForKey:kResultTitle], YES, nil);
                    }
                }
                else
                {
                    block([NSArray new], nil, nil, YES, nil);
                }
                NSLog(@"%@",responseObject);
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                //                NSLog(@"failed %@",error);
                block(nil, nil, nil, NO, error);
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end
