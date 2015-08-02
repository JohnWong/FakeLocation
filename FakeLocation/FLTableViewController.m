//
//  FLTableViewController.m
//  FakeLocation
//
//  Created by John Wong on 8/1/15.
//  Copyright (c) 2015 John Wong. All rights reserved.
//

#import "FLTableViewController.h"
#import <CoreLocation/CoreLocation.h>

// Table view cell identifiers.
NSString *const FLTableViewControllerListItemCellIdentifier = @"listItemCell";
NSString *const AAPLListViewControllerListColorCellIdentifier = @"listColorCell";

@interface FLTableViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, assign) BOOL needAuth;

@end

@implementation FLTableViewController

@synthesize refreshControl = _refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelection = NO;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:_refreshControl];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    _data = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _data.count?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FLTableViewControllerListItemCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark getter
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark action
- (void)pullToRefresh {
    _needAuth = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined;
    if (_needAuth) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.refreshControl isRefreshing]) {
        [self pullToRefresh];
    }
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (_needAuth && status != kCLAuthorizationStatusNotDetermined) {
        [self.locationManager startUpdatingLocation];
        _needAuth = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations[0];
    [self addNewResult:[NSString stringWithFormat:@"{%@, %@}", @(location.coordinate.latitude), @(location.coordinate.longitude)]];
    [self completed];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self addNewResult:error.localizedDescription];
    [self completed];
}

- (void)addNewResult:(NSString *)string {
    NSMutableArray *array = [NSMutableArray arrayWithArray:_data];
    [array insertObject:string atIndex:0];
    _data = array;
}

- (void)completed {
    [self.locationManager stopUpdatingLocation];
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

@end
