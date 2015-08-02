    //
//  CLLocationManager+FLFake.m
//  FakeLocation
//
//  Created by John Wong on 8/2/15.
//  Copyright (c) 2015 John Wong. All rights reserved.
//

#import "CLLocationManager+FLFake.h"
#import <objc/runtime.h>
#import "FLFakeConfig.h"

@implementation CLLocationManager (FLFake)

+ (void)load {
    Method originMethod = class_getInstanceMethod([CLLocationManager class], @selector(startUpdatingLocation));
    Method swizzleMethod = class_getInstanceMethod([CLLocationManager class], @selector(fl_startUpdatingLocation));
    method_exchangeImplementations(originMethod, swizzleMethod);
}

- (void)fl_startUpdatingLocation {
    NSLog(@"Start updating location");
    FLFakeConfig *fakeConfig = [FLFakeConfig sharedInstance];
    if (fakeConfig.enabled) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
                NSArray *locations = @[fakeConfig.location];
                if (!fequalzero(fakeConfig.delay)) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fakeConfig.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.delegate locationManager:self didUpdateLocations:locations];
                    });
                } else {
                    [self.delegate locationManager:self didUpdateLocations:locations];
                }
            } else {
                
            }
        }
    } else {
        [self fl_startUpdatingLocation];
    }
}

@end
