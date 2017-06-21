//
//  DrawSubView.h
//  DoodlePod
//
//  Created by beacomni on 6/21/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawSubView : UIView
- (void)initializeSubView;
- (void)clearDrawPoints;
- (void)refresh;
- (void)saveDrawingData;
- (void)loadDrawingData;
- (void)saveTrailLengthSetting;
- (bool)savedDataAvailable;
- (void)updateTrailLengthWith:(long)val;
@property NSMutableArray *drawPointsArray;
@property long trailLength;
@property NSString *trailLengthKey;
@end
