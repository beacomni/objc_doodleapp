//
//  SecondViewController.m
//  DoodlePod
//
//  Created by beacomni on 6/21/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@property (strong, nonatomic) IBOutlet UITextField *TrailLengthTextBox;
@property (strong, nonatomic) IBOutlet UIButton *UpdateTrailLengthButton;
@property (strong, nonatomic) IBOutlet UIButton *ClearDrawingsButton;
@property (strong, nonatomic) IBOutlet UIButton *SaveDrawingButton;
@property (strong, nonatomic) IBOutlet UIButton *SaveSettingsButton;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)UpdateTrailLengthHandle:(id)sender {
    long trailLength = [_TrailLengthTextBox.text integerValue];
    NSNumber *leng = [NSNumber numberWithLong:trailLength];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTrailLengthHandle"
                                                        object: leng];
}

- (IBAction)ClearDrawingsHandle:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearDrawingsHandle"
                                                        object:self];
}

- (IBAction)SaveDrawingButtonHandle:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveDrawingButtonHandle"
                                                        object:self];
}
- (IBAction)SaveSettingsHandle:(id)sender {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveSettingsHandle"
                                                             object:self];
}

@end
