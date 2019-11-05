/*
 * Copyright (c) 2011-2019 HERE Europe B.V.
 * All rights reserved.
 */

#import "MainViewController.h"
#import <NMAKit/NMAKit.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet NMAMapView* mapView;
@property (weak, nonatomic) IBOutlet UIButton* createRouteButton;
@property (nonatomic) NMACoreRouter* router;
@property (nonatomic) NMAMapRoute* mapRoute;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // create geo coordinate
    NMAGeoCoordinates* geoCoordCenter =
        [[NMAGeoCoordinates alloc] initWithLatitude:49.260327 longitude:-123.115025];
    // set map view with geo center
    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
    // set zoom level
    self.mapView.zoomLevel = 13.2;
    self.createRouteButton.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

- (void)createRoute
{
    // Create an NSMutableArray to add two stops
    NSMutableArray* stops = [[NSMutableArray alloc] initWithCapacity:4];

    // START: 4350 Still Creek Dr
    NMAGeoCoordinates* hereBurnaby =
        [[NMAGeoCoordinates alloc] initWithLatitude:49.259149 longitude:-123.008555];
    // END: Langley BC
    NMAGeoCoordinates* langley =
        [[NMAGeoCoordinates alloc] initWithLatitude:49.0736 longitude:-122.559549];
    [stops addObject:hereBurnaby];
    [stops addObject:langley];

    // Create an NMARoutingMode, then set it to find the fastest truck route - see https://developer.here.com/documentation/ios-premium/dev_guide/topics/routing-truck.html
    NMARoutingMode* routingMode =
        [[NMARoutingMode alloc] initWithRoutingType:NMARoutingTypeFastest
                                      transportMode:NMATransportModeTruck
                                     routingOptions:1];
    
    # set truck routing options - see https://developer.here.com/documentation/ios-premium/api_reference_jazzy/Classes/NMARoutingMode.html
    routingMode.vehicleLength = 18.25f;
    routingMode.vehicleHeight = 3.6f;
    routingMode.vehicleWidth = 2.55f;
    routingMode.trailersCount = 1;
    routingMode.hazardousGoods = 0;
    routingMode.truckRestrictionsMode = 0;
    routingMode.avoidDifficultTurns = 1;
    routingMode.truckType = 0;

    // Initialize the NMACoreRouter
    if ( !self.router )
    {
        self.router = [[NMACoreRouter alloc] init];
    }

    // Trigger the route calculation
    [self.router
        calculateRouteWithStops:stops
                    routingMode:routingMode
                completionBlock:^( NMARouteResult* routeResult, NMARoutingError error ) {
                  if ( !error )
                  {
                      if ( routeResult && routeResult.routes.count >= 1 )
                      {
                          // Let's add the 1st result onto the map
                          NMARoute* route = routeResult.routes[0];
                          self.mapRoute = [NMAMapRoute mapRouteWithRoute:route];
                          [self.mapView addMapObject:self.mapRoute];

                          // In order to see the entire route, we orientate the map view
                          // accordingly
                          [self.mapView setBoundingBox:route.boundingBox
                                         withAnimation:NMAMapAnimationLinear];
                      }
                      else
                      {
                          NSLog( @"Error:route result returned is not valid" );
                      }
                  }
                  else
                  {
                      NSLog( @"Error:route calculation returned error code %d", (int)error );
                  }
                }];
}

- (IBAction)buttonDidClicked:(id)sender
{
    // Clear map if previous results are still on map, otherwise proceed to creating route
    if ( self.mapRoute )
    {
        [self.mapView removeMapObject:self.mapRoute];
        self.mapRoute = nil;
    }
    else
    {
        [self createRoute];
    }
}

@end
