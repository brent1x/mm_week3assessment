
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property MKPointAnnotation *bikeAnnotation;
@property NSMutableString *directions;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.station.title;
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.bikeAnnotation = [MKPointAnnotation new];
    self.bikeAnnotation.coordinate = self.station.coordinate;
    self.bikeAnnotation.title = self.station.title;
    [self.mapView addAnnotation:self.bikeAnnotation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation) {
        return nil;
    }
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    pin.canShowCallout = YES;
    if (annotation == self.bikeAnnotation) {
        pin.image = [UIImage imageNamed:@"bikeImage"];
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    MKPlacemark *mkDest = [[MKPlacemark alloc] initWithCoordinate:self.bikeAnnotation.coordinate addressDictionary:nil];
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = [[MKMapItem alloc] initWithPlacemark:mkDest];
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *routes = response.routes;
        MKRoute *route = routes.firstObject;
        NSMutableString *directions = [NSMutableString new];
        int x = 1;
        for (MKRouteStep *step in route.steps) {
            [directions appendFormat:@"%d: %@\n", x, step.instructions];
            x++;
        }

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Directions to %@", self.bikeAnnotation.title] message:[NSString stringWithFormat:@"%@", directions] preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *dismissButton = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alertController addAction:dismissButton];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    [self.mapView showAnnotations:@[self.bikeAnnotation, self.mapView.userLocation] animated:NO];
}

@end
