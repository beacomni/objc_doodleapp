//
//  SecondViewController.m
//  DoodlePod
//
//  Created by beacomni on 6/21/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UITextField *TrailLengthTextBox;
@property (weak, nonatomic) IBOutlet UIButton *UpdateTrailLengthButton;
@property (weak, nonatomic) IBOutlet UIButton *ClearDrawingsButton;

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

@end
