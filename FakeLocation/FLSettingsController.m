//
//  FLSettingsController.m
//  FakeLocation
//
//  Created by John Wong on 8/2/15.
//  Copyright (c) 2015 John Wong. All rights reserved.
//

#import "FLSettingsController.h"
#import "FLFakeConfig.h"

@interface FLSettingsController ()

@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property (weak, nonatomic) IBOutlet UITextField *latitudeText;
@property (weak, nonatomic) IBOutlet UITextField *longitudeText;
@property (weak, nonatomic) IBOutlet UISlider *delaySlider;
@property (weak, nonatomic) IBOutlet UILabel *delayLabel;

@end

@implementation FLSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    FLFakeConfig *fakeConfig = [FLFakeConfig sharedInstance];
    _enableSwitch.on = fakeConfig.enabled;
    CLLocationCoordinate2D coordinate = fakeConfig.location.coordinate;
    _latitudeText.text = [NSString stringWithFormat:@"%@", @(coordinate.latitude)];
    _longitudeText.text = [NSString stringWithFormat:@"%@", @(coordinate.longitude)];
    _delaySlider.value = fakeConfig.delay;
    _delayLabel.text = [NSString stringWithFormat:@"延迟 %@s", @(_delaySlider.value)];
}

- (IBAction)switchValueDidChange:(UISwitch *)sender {
    [FLFakeConfig sharedInstance].enabled = sender.isOn;
}

- (IBAction)tapTableView:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)sliderValueDidChange:(UISlider *)sender {
    [FLFakeConfig sharedInstance].delay = sender.value;
    _delayLabel.text = [NSString stringWithFormat:@"延迟 %@s", @(sender.value)];
}

- (IBAction)textFieldDidEnd:(UITextField *)sender {
    FLFakeConfig *fakeConfig = [FLFakeConfig sharedInstance];
    double value = [sender.text doubleValue];
    if (sender == _latitudeText) {
        [fakeConfig setLatitude:value];
    } else if (sender == _longitudeText) {
        [fakeConfig setLongitude:value];
    }
}

@end
