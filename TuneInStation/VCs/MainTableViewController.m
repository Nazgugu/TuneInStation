//
//  MainTableViewController.m
//  TuneInStation
//
//  Created by Liu Zhe on 1/11/16.
//  Copyright © 2016 Liu Zhe. All rights reserved.
//

typedef NS_OPTIONS(NSInteger, tableType)
{
    tableTypeCategory = 0,
    tableTypeStations = 1
};

#define mainTableCellID     @"mainCell"

#import "MainTableViewController.h"
#import "WSProgressHUD.h"
#import "stationFetchManager.h"
#import "stationCategory.h"
#import "station.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MainTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic, strong) UIButton *errorButton;

@property (weak, nonatomic) IBOutlet UITableView *categoryTable;

@property (nonatomic, strong) NSMutableArray *resultsArr;

@property (nonatomic, strong) NSMutableArray *sectionsArr;

@property (nonatomic, strong) stationCategory *currentCategory;

@property (nonatomic, assign) tableType tableType;

@end

@implementation MainTableViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isRoot = YES;
        _tableType = tableTypeCategory;
    }
    return self;
}

- (instancetype)initWithCategory:(stationCategory *)category
{
    self = [super init];
    if (self)
    {
        _isRoot = NO;
        _currentCategory = category;
        _tableType = tableTypeStations;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self setUpNavigationTitle];
    [self initErrorView];
    // Do any additional setup after loading the view from its nib.
    if (self.resultsArr.count < 1)
    {
        self.categoryTable.hidden = YES;
        self.categoryTable.alpha = 0.0f;
    }
    [WSProgressHUD showWithMaskType:WSProgressHUDMaskTypeGradient];
    if (self.isRoot)
    {
        [self refresh];
    }
    else
    {
        [self fetchWithDecision];
    }
    
//    [[stationFetchManager sharedManager] fetchResultsWithURLString:nil InBackgroundWithBlock:^(NSArray *results, NSString *title, BOOL isCategory, NSError *error) {
//        
//    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)setUpNavigationTitle
{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    if (self.isRoot)
    {
        self.title = @"Browse";
    }
    else
    {
        self.title = [self.currentCategory getTitle];
    }
}

- (void)initTableView
{
    self.categoryTable.backgroundColor = [UIColor blackColor];
    self.categoryTable.tableFooterView = [UIView new];
    _resultsArr = [[NSMutableArray alloc] init];
    _sectionsArr = [[NSMutableArray alloc] init];
}

- (void)initErrorView
{
    _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT - 50.0f) / 2 + 65 - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height, SCREEN_WIDTH, 50.0f)];
    if (IOS9_UP)
    {
        self.errorLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:25.0f];
    }
    else
    {
        self.errorLabel.font = [UIFont systemFontOfSize:25.0f];
    }
    self.errorLabel.textColor = [UIColor whiteColor];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    [self.errorLabel setText:@"Network Error"];
    self.errorLabel.alpha = 0.0f;
    self.errorLabel.hidden = YES;
    [self.view addSubview:self.errorLabel];
    
    _errorButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 50.0f) / 2, (SCREEN_HEIGHT - 50.0f) / 2 - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height, 50.0f, 50.0f)];
    [self.errorButton setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    [self.errorButton addTarget:self action:@selector(refreshWithHud) forControlEvents:UIControlEventTouchUpInside];
    self.errorButton.alpha = 0.0f;
    self.errorButton.hidden = YES;
    [self.view addSubview:self.errorButton];
}

- (void)refreshWithHud
{
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.errorButton.alpha = 0.0f;
        self.errorLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished)
        {
            self.errorButton.hidden = YES;
            self.errorLabel.hidden = YES;
            [WSProgressHUD showWithMaskType:WSProgressHUDMaskTypeGradient];
            if (self.isRoot)
            {
                [self refresh];
            }
            else
            {
                [self fetchWithDecision];
            }
        }
    }];
}

- (void)refresh
{
    [[stationFetchManager sharedManager] fetchCategoriesInBackgroundWithBlock:^(NSArray *categories, NSError *error) {
        if (categories)
        {
            [self.resultsArr removeAllObjects];
            [self.resultsArr addObjectsFromArray:categories];
            [self.categoryTable reloadData];
            [WSProgressHUD dismiss];
            if (self.categoryTable.isHidden)
            {
                [self animateTableAppear];
            }
        }
        else
        {
            [self animateErrorView];
            dispatch_async(dispatch_get_main_queue(), ^{
                [WSProgressHUD showErrorWithStatus:@"Network Error"];
            });
        }
    }];
}

- (void)fetchWithDecision
{
    [[stationFetchManager sharedManager] fetchResultsWithURLString:[self.currentCategory getURL] InBackgroundWithBlock:^(NSArray *results, NSArray *sectionArray, NSString *title, BOOL isCategory, NSError *error) {
       if (error)
       {
           [self animateErrorView];
           dispatch_async(dispatch_get_main_queue(), ^{
               [WSProgressHUD showErrorWithStatus:@"Network Error"];
           });
       }
        else
        {
            [self.resultsArr removeAllObjects];
            [self.sectionsArr removeAllObjects];
            if (isCategory)
            {
                self.tableType = tableTypeCategory;
                [self.resultsArr addObjectsFromArray:results];
            }
            else
            {
                self.tableType = tableTypeStations;
                self.title = title;
                [self.sectionsArr addObjectsFromArray:sectionArray];
                [self.resultsArr addObjectsFromArray:results];
            }
            [self.categoryTable reloadData];
            [WSProgressHUD dismiss];
            if (self.categoryTable.isHidden)
            {
                [self animateTableAppear];
            }
        }
    }];
}

- (void)animateTableAppear
{
    if (!self.errorButton.isHidden)
    {
        self.errorButton.alpha = 0.0f;
        self.errorButton.hidden = YES;
    }
    if (!self.errorLabel.isHidden)
    {
        self.errorLabel.alpha = 0.0f;
        self.errorLabel.hidden = YES;
    }
    self.categoryTable.hidden = NO;
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.categoryTable.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateErrorView
{
    if (!self.categoryTable.isHidden)
    {
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.categoryTable.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished)
            {
                self.categoryTable.hidden = YES;
                self.errorButton.hidden = NO;
                self.errorLabel.hidden = NO;
                [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.errorButton.alpha = 1.0f;
                    self.errorLabel.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }];
    }
    else
    {
        self.errorButton.hidden = NO;
        self.errorLabel.hidden = NO;
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.errorButton.alpha = 1.0f;
            self.errorLabel.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableType == tableTypeCategory)
    {
        return 1;
    }
    else
    {
        return self.sectionsArr.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableType == tableTypeCategory)
    {
        return self.resultsArr.count;
    }
    else
    {
        NSArray *stationsArr = [self.resultsArr objectAtIndex:section];
        return stationsArr.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.tableType == tableTypeCategory)
    {
        return nil;
    }
    else
    {
        return [self.sectionsArr objectAtIndex:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainTableCellID];
    if (self.tableType == tableTypeCategory)
    {
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:mainTableCellID];
        }
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        stationCategory *stationCategory = [self.resultsArr objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [stationCategory getTitle];
    }
    else if (self.tableType == tableTypeStations)
    {
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainTableCellID];
        }
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.textColor = [UIColor lightTextColor];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        NSArray *stations = [self.resultsArr objectAtIndex:indexPath.section];
        station *theStation = [stations objectAtIndex:indexPath.row];
        cell.textLabel.text = [theStation getStationTitle];
        cell.detailTextLabel.text = [theStation getStationSubTitle];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
        cell.imageView.clipsToBounds = YES;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[theStation getImageURLString]] placeholderImage:[UIImage imageNamed:@""]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
