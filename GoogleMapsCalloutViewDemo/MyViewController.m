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

static NSString * const TitleKey = @"title";
static NSString * const InfoKey = @"info";
static NSString * const LatitudeKey = @"latitude";
static NSString * const LongitudeKey = @"longitude";

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
    
    NSArray *markerInfos = @[
        @{
            TitleKey: @"Eiffel Tower",
            InfoKey: @"A wrought-iron structure erected in Paris in 1889. With a height of 984 feet (300 m), it was the tallest man-made structure for many years.",
            LatitudeKey: @48.8584,
            LongitudeKey: @2.2946
        },
        @{
            TitleKey: @"Centre Georges Pompidou",
            InfoKey: @"Centre Georges Pompidou is a complex in the Beaubourg area of the 4th arrondissement of Paris. It was designed in the style of high-tech architecture.",
            LatitudeKey: @48.8607,
            LongitudeKey: @2.3524
        },
        @{
            TitleKey: @"The Louvre",
            InfoKey: @"The principal museum and art gallery of France, in Paris.",
            LatitudeKey: @48.8609,
            LongitudeKey: @2.3363
        },
        @{
            TitleKey: @"Arc de Triomphe",
            InfoKey: @"A ceremonial arch standing at the top of the Champs Élysées in Paris.",
            LatitudeKey: @48.8738,
            LongitudeKey: @2.2950
        },
        @{
            TitleKey: @"Notre Dame",
            InfoKey: @"A Gothic cathedral in Paris, dedicated to the Virgin Mary, built between 1163 and 1250.",
            LatitudeKey: @48.8530,
            LongitudeKey: @2.3498
        }
    ];
    
    UIImage *pinImage = [UIImage imageNamed:@"Pin"];
    
    for (NSDictionary *markerInfo in markerInfos) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        
        marker.position = CLLocationCoordinate2DMake([markerInfo[LatitudeKey] doubleValue], [markerInfo[LongitudeKey] doubleValue]);
        marker.title = markerInfo[TitleKey];
        marker.icon = pinImage;
        marker.userData = markerInfo;   
        marker.infoWindowAnchor = CGPointMake(0.5, 0.25);
        marker.groundAnchor = CGPointMake(0.5, 1.0);
        
        marker.map = self.mapView;
    }
}


- (void)calloutAccessoryButtonTapped:(id)sender {
    if (self.mapView.selectedMarker) {
        
        GMSMarker *marker = self.mapView.selectedMarker;
        NSDictionary *userData = marker.userData;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:userData[TitleKey]
                                                            message:userData[InfoKey]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
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
        
        CGPoint arrowPt = self.calloutView.backgroundView.arrowPoint;
        
        CGPoint pt = [pMapView.projection pointForCoordinate:anchor];
        pt.x -= arrowPt.x;
        pt.y -= arrowPt.y + CalloutYOffset;
        
        self.calloutView.frame = (CGRect) {.origin = pt, .size = self.calloutView.frame.size };
    } else {
        self.calloutView.hidden = YES;
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    self.calloutView.hidden = YES;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    /* don't move map camera to center marker on tap */
    mapView.selectedMarker = marker;
    return YES;
}

@end
