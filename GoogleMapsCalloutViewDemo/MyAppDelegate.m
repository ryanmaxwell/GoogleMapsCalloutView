//
//  MyAppDelegate.m
//  GoogleMapsCalloutViewDemo
//
//  Created by Ryan Maxwell on 15/01/13.
//  Copyright (c) 2013 Ryan Maxwell. All rights reserved.
//


#import <GoogleMaps/GoogleMaps.h>

#import "MyAppDelegate.h"

#import "MyViewController.h"

@implementation MyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GMSServices provideAPIKey:@"AIzaSyAJeE7GGeJYJF3Su-LaQS7hLKR7RA6x8F0"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[MyViewController alloc] initWithNibName:@"MyViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[MyViewController alloc] initWithNibName:@"MyViewController_iPad" bundle:nil];
    }
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

//- (void)applicationWillResignActive:(UIApplication *)application {
//
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application {
//
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application {
//    
//}

@end
