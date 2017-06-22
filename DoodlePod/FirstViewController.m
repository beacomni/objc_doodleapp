//
//  FirstViewController.m
//  DoodlePod
//
//  Created by beacomni on 6/21/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *DrawingViewImageView;
@property (strong, nonatomic) IBOutlet DrawSubView *DrawSubViewOutlet;


@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _DrawSubViewOutlet.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSaveButton:)
                                                 name:@"SaveDrawingButtonHandle"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSaveSettings:)
                                                 name:@"SaveSettingsHandle"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePhotoPick:)name:@"SetBackgroundPhotoButtonHandle"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleToggleBlink:)
                                                 name:@"ToggleBlink"
                                               object:nil];
    
    if ([_DrawSubViewOutlet savedDataAvailable]){
        [_DrawSubViewOutlet loadDrawingData];
    }
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
    [_DrawSubViewOutlet updateTrailLengthWith:[doodleLengthAsNSNumber longValue]];
    [_DrawSubViewOutlet refresh];
}

- (void)handleSaveButton:(NSNotification *)notification {
    [_DrawSubViewOutlet saveDrawingData];
}

- (void)handleSaveSettings:(NSNotification *)notification {
    [_DrawSubViewOutlet saveTrailLengthSetting];
}

- (void)handlePhotoPick:(NSNotification *)notification {
    [self selectPhoto];
}

- (void)handleToggleBlink:(NSNotification *)notification {
    [_DrawSubViewOutlet toggleBlink];
}
     

- (void) selectPhoto {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        if (status == PHAuthorizationStatusAuthorized)
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController:imagePicker animated:true completion:nil];
            }
        }
        else
        {
            //No permission. Trying to normally request it
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized)
                {
                    //User don't give us permission. Showing alert with redirection to settings
                    //Getting description string from info.plist file
                    
                    NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
                    
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:settingsAction];
                    
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                }
            }];
        }
    });
}

//this is delegate response
//  comes from registrations and
//  UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    _DrawingViewImageView.image = image;
    [_DrawingViewImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    //myTouchView.newRect = imageView.frame;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


