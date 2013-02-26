//
//  MyViewController.m
//  GoogleMapsCalloutViewDemo
//
//  Created by Ryan Maxwell on 15/01/13.
//  Copyright (c) 2013 Ryan Maxwell. All rights reserved.
//

#import "MyViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <SMCalloutView/SMCalloutView.h>

static const CGFloat CalloutYOffset = 50.0f;

/* Paris */
static const CLLocationDegrees DefaultLatitude = 48.856132;
static const CLLocationDegrees DefaultLongitude = 2.339004;
static const CGFloat DefaultZoom = 12.0f;

@interface MyViewController () <GMSMapViewDelegate>
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) SMCalloutView *calloutView;
@property (strong, nonatomic) UIView *emptyCalloutView;
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.calloutView = [[SMCalloutView alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self
               action:@selector(calloutAccessoryButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    self.calloutView.rightAccessoryView = button;
    
	GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:DefaultLatitude
                                                                    longitude:DefaultLongitude
                                                                         zoom:DefaultZoom];
    
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds
                                     camera:cameraPosition];
    self.mapView.delegate = self;
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    self.emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self addMarkersToMap];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    
    self.emptyCalloutView = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [self.mapView startRendering];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.mapView stopRendering];
}

- (void)addMarkersToMap {
    
    NSArray *markers = @[
        @{
            @"title": @"Eiffel Tower",
            @"info": @"A wrought-iron structure erected in Paris in 1889. With a height of 984 feet (300 m), it was the tallest man-made structure for many years.",
            @"latitude": @48.8584,
            @"longitude": @2.2946
        },
        @{
            @"title": @"Centre Georges Pompidou",
            @"info": @"Centre Georges Pompidou is a complex in the Beaubourg area of the 4th arrondissement of Paris. It was designed in the style of high-tech architecture.",
            @"latitude": @48.8607,
            @"longitude": @2.3524
        },
        @{
            @"title": @"The Louvre",
            @"info": @"The principal museum and art gallery of France, in Paris.",
            @"latitude": @48.8609,
            @"longitude": @2.3363
        },
        @{
            @"title": @"Arc de Triomphe",
            @"info": @"A ceremonial arch standing at the top of the Champs Élysées in Paris.",
            @"latitude": @48.8738,
            @"longitude": @2.2950
        },
        @{
            @"title": @"Notre Dame",
            @"info": @"A Gothic cathedral in Paris, dedicated to the Virgin Mary, built between 1163 and 1250.",
            @"latitude": @48.8530,
            @"longitude": @2.3498
        }
    ];
    
    UIImage *pinImage = [UIImage imageNamed:@"Pin"];
    
    for (NSDictionary *marker in markers) {
        GMSMarkerOptions *options = [[GMSMarkerOptions alloc] init];
        
        options.position = CLLocationCoordinate2DMake([marker[@"latitude"] doubleValue], [marker[@"longitude"] doubleValue]);
        options.title = marker[@"title"];
        options.icon = pinImage;
        options.userData = marker;
        
        options.infoWindowAnchor = CGPointMake(0.5, 0.25);
        options.groundAnchor = CGPointMake(0.5, 1.0);
        
        [self.mapView addMarkerWithOptions:options];
    }
}


- (void)calloutAccessoryButtonTapped:(id)sender {
    if (self.mapView.selectedMarker) {
        
        id<GMSMarker> marker = self.mapView.selectedMarker;
        NSDictionary *userData = marker.userData;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:userData[@"title"]
                                                            message:userData[@"info"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(id<GMSMarker>)marker {
    CLLocationCoordinate2D anchor = marker.position;
    
    CGPoint point = [mapView.projection pointForCoordinate:anchor];
    
    self.calloutView.title = marker.title;
    
    self.calloutView.calloutOffset = CGPointMake(0, -CalloutYOffset);
    
    self.calloutView.hidden = NO;
    
    CGRect calloutRect = CGRectZero;
    calloutRect.origin = point;
    calloutRect.size = CGSizeZero;
    
    [self.calloutView presentCalloutFromRect:calloutRect
                                      inView:mapView
                           constrainedToView:mapView
                    permittedArrowDirections:SMCalloutArrowDirectionDown
                                    animated:YES];
    
    return self.emptyCalloutView;
}

- (void)mapView:(GMSMapView *)pMapView didChangeCameraPosition:(GMSCameraPosition *)position {
    /* move callout with map drag */
    if (pMapView.selectedMarker != nil && !self.calloutView.hidden) {
        CLLocationCoordinate2D anchor = [pMapView.selectedMarker position];
        
        CGPoint pt = [pMapView.projection pointForCoordinate:anchor];
        
        // objectAtIndex:3 is the bottomAnchor ImageView, aka the triangle.
        UIImageView *iv = (self.calloutView.subviews)[3];
        CGFloat widthadjust = iv.frame.size.width / 2;
        CGFloat cx = iv.frame.origin.x + widthadjust;
        pt.x -= cx;
        pt.y -= iv.frame.size.height - 10 + CalloutYOffset;
        self.calloutView.frame = (CGRect) {.origin = pt, .size = self.calloutView.frame.size };
    } else {
        self.calloutView.hidden = YES;
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    self.calloutView.hidden = YES;
}

@end
