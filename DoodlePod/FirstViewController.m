//
//  FirstViewController.m
//  DoodlePod
//
//  Created by beacomni on 6/21/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (strong, nonatomic) IBOutlet DrawSubView *DrawSubViewOutlet;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _DrawSubViewOutlet.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.9];
    [_DrawSubViewOutlet initializeSubView];
    
    //[[self tabBarController] viewControllers]
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleClearDrawings:)
                                                 name:@"ClearDrawingsHandle"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLengthChange:)
                                                 name:@"UpdateTrailLengthHandle"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleClearDrawings:(NSNotification *)notification {
    [_DrawSubViewOutlet clearDrawPoints];
}

-(void)handleLengthChange:(NSNotification *)notification {
        NSNumber *doodleLengthAsNSNumber = [notification object];
        [_DrawSubViewOutlet setTrailLength:[doodleLengthAsNSNumber longValue]];
        [_DrawSubViewOutlet refresh];
    }

@end


