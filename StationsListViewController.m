
#import "StationsListViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BikeStation.h"
#import "MapViewController.h"

@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableDictionary *bikeLocationsDictionary;
@property NSMutableArray *bikeLocationsArray;
@property NSMutableArray *stationArray;
@property CLLocationManager *locationManager;


@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bikeLocationsDictionary = [NSMutableDictionary new];
    self.bikeLocationsArray = [NSMutableArray new];
    self.stationArray = [NSMutableArray new];

    NSURL *url = [NSURL URLWithString:@"http://www.bayareabikeshare.com/stations/json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        self.bikeLocationsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.bikeLocationsArray = [self.bikeLocationsDictionary objectForKey:@"stationBeanList"];
        for (NSDictionary *dictionary in self.bikeLocationsArray) {
            BikeStation *station = [BikeStation new];
            double latitude = [[dictionary objectForKey:@"latitude"] doubleValue];
            double longitude = [[dictionary objectForKey:@"longitude" ] doubleValue];
            station.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            station.title = [dictionary objectForKey: @"stationName"];
            station.subtitle = [dictionary objectForKey:@"availableBikes"];
            [self.stationArray addObject:station];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BikeStation *station = [self.stationArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = station.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ bikes available", station.subtitle];
    return cell;
}

#pragma mark - Prepare For Segue Method

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MapViewController *mapVC = segue.destinationViewController;
    mapVC.station = self.stationArray[[self.tableView indexPathForCell:sender].row];
}

@end
