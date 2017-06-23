//
//  DrawSubView.m
//  DoodlePod
//
//  Created by beacomni on 6/21/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import "DrawSubView.h"

@implementation DrawSubView

//not called when used by view in storyboard
/*- (id)initWithFrame:(CGRect)frame{
 self = [super initWithFrame:frame];
 if(self){
 _drawPointsArray = [[NSMutableArray alloc] init];
 }
 
 return self;
 }*/

- (void)initializeSubView{
    _drawPointsArray = [[NSMutableArray alloc] init];
    _remoteArray = [[NSMutableArray alloc] init];
    _trailLength = 100;
    _trailLengthKey = @"trailLengthSetting";
    if([self hasTrailLengthSetting]){
        [self loadTrailLengthSetting];
    }
    
    //_taskTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateDotLightCounter) userInfo:nil repeats:YES];
    //_taskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dotMove) userInfo:nil repeats:YES];
    _pointWidth = 3;
    _pointHeight = 3;
    _isBlinkOn = false;
    _dbManager = [DBManager getSharedInstance];
    [_dbManager createDB];
    _tcpConnectionClient = [[TCPConnectionClientStuff alloc] init];
    [_tcpConnectionClient openTCPConnection:@"10.126.120.60" WithPort:4000];
    [_tcpConnectionClient set_completionHandler:^(NSString * msg){
        [self gotRemoteMessage:msg];
    }];
    
}

- (void) gotRemoteMessage:(NSString *)msg{
    NSArray *coords = [msg componentsSeparatedByString:@","];
    if(coords.count >=2){
        float x =  [coords[0] floatValue];
        float y = [coords[1] floatValue];
        [_remoteArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        [self setNeedsDisplay];
    }
}

- (void) toggleBlink{
    if(_isBlinkOn){
        [self setBlinkOff];
        _isBlinkOn = false;
        return;
    }
    [self setBlinkOn];
    _isBlinkOn = true;
}

- (void)setBlinkOn{
    _blinkTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(toggleDotSize) userInfo:nil repeats:YES];
}

- (void)setBlinkOff{
    _pointHeight = 3;
    _pointWidth = 3;
    [_blinkTimer invalidate];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(contextRef, true);
    
    CGContextSetRGBStrokeColor(contextRef,0.03, 0.90, 0.50, 1);
    CGContextSetLineWidth(contextRef, 3);
    
    /*
     CGContextBeginPath(contextRef);
     CGContextMoveToPoint(contextRef, 155, 155);
     CGContextAddLineToPoint(contextRef, 290, 190);
     CGContextDrawPath(contextRef, kCGPathStroke);
     */
    
    CGContextSetRGBFillColor(contextRef, 0.02, 0.88, 0.48, 1);
    
    //CGContextStrokeRect(contextRef, CGRectMake(50, 350, 100, 50));
    for(int i = 0;  i < _drawPointsArray.count; i++){
        if(i == _dotLightCounter)
        {
            CGPoint point = [[_drawPointsArray objectAtIndex:i] CGPointValue];
            CGContextFillEllipseInRect(contextRef, CGRectMake(point.x - 2, point.y-2, _pointWidth + 4, _pointHeight + 4));
        }
        else{
            CGPoint point = [[_drawPointsArray objectAtIndex:i] CGPointValue];
            CGContextFillEllipseInRect(contextRef, CGRectMake(point.x - 2, point.y-2, _pointWidth, _pointHeight));
        }
    };
    
    for(int i = 0;  i < _remoteArray.count; i++){
            CGPoint point = [[_remoteArray objectAtIndex:i] CGPointValue];
            CGContextFillEllipseInRect(contextRef, CGRectMake(point.x - 2, point.y-2, _pointWidth, _pointHeight));

    };
}


- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint touch = [[touches anyObject] locationInView:self];
    if(_drawPointsArray.count > _trailLength){
        [_drawPointsArray removeObjectAtIndex:0];
        [_drawPointsArray removeObjectAtIndex:0];
    }
    if(_drawPointsArray.count == _trailLength)
    {
        [_drawPointsArray removeObjectAtIndex:0];
    }
    [_tcpConnectionClient sendMessage:[NSString stringWithFormat:@"%.1f,%.1f\r\n",touch.x,touch.y]];
    [_drawPointsArray addObject:[NSValue valueWithCGPoint:touch]];
    [self setNeedsDisplay];
}

- (void) toggleDotSize{
    if(_pointHeight == 6)
    {
        _pointHeight = 3;
        _pointWidth = 3;
        return;
    }
    _pointWidth = 6;
    _pointHeight = 6;
}


- (void) updateDotLightCounter{
    if(_dotLightCounter == 0){
        _dotLightCounter = _drawPointsArray.count - 1;
        return;
    }
    _dotLightCounter--;
}

- (void)clearDrawPoints{
    _drawPointsArray = [[NSMutableArray alloc] init];
    [self refresh];
}

- (void)updateTrailLengthWith:(long)len{
    _trailLength = len;
    [self saveTrailLengthSetting];
    [self refresh];
}

- (void)refresh{
    [self setNeedsDisplay];
}

- (void)loadDrawingData{
    if(_drawPointsArray.count > 0){
        _drawPointsArray = [[NSMutableArray alloc] init];
    }
    /*NSString *path = [self getSavePath];
     NSMutableArray *undeserialized = [[NSMutableArray alloc] init];
     undeserialized = [NSMutableArray arrayWithContentsOfFile:path];
     for(int i = 0; i < undeserialized.count; i++){
     [_drawPointsArray addObject:[NSValue valueWithCGPoint:CGPointFromString(undeserialized[i])]];
     }*/
    
    int mostRecentlySaved = [_dbManager getMaxSaveSetId];
    NSMutableArray *arr = [_dbManager findAllBySaveSetId:mostRecentlySaved];
    _drawPointsArray = [_dbManager findAllBySaveSetId:mostRecentlySaved];
    
    [self refresh];
}

- (NSString *)getSavePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"appDatas"];
    return path;
}

- (void)saveDrawingData{
    NSString *path = [self getSavePath];
    NSMutableArray *forSerializing = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < _drawPointsArray.count; i++){
        NSValue *pt = _drawPointsArray[i];
        [forSerializing addObject: NSStringFromCGPoint(pt.CGPointValue)];
    }
    [forSerializing writeToFile:path atomically:YES];
    
    //save to db
    
    int newSaveSetId;
    int maxSaveId = [_dbManager getMaxSaveSetId];
    if(maxSaveId == -1){
        newSaveSetId = 1;
    }
    newSaveSetId = maxSaveId + 1;
    
    for(int i = 0; i < _drawPointsArray.count; i++){
        NSValue *point = _drawPointsArray[i];
        [_dbManager saveData:newSaveSetId position:i xcoord:point.CGPointValue.x ycoord:point.CGPointValue.y];
    }
}

- (bool)savedDataAvailable{
    NSString *path = [self getSavePath];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (void)saveTrailLengthSetting{
    //NSString *trailLengthSetting = [[NSNumber numberWithLong:_trailLength] stringValue];
    //[[NSUserDefaults standardUserDefaults] setObject:trailLengthSetting forKey:_trailLengthKey];
    [[NSUserDefaults standardUserDefaults] setInteger:_trailLength forKey:_trailLengthKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadTrailLengthSetting{
    //NSString *trailLenthSetting = [[NSUserDefaults standardUserDefaults]
    //stringForKey:_trailLengthKey];
    //_trailLength = [trailLenthSetting intValue];
    _trailLength = [[NSUserDefaults standardUserDefaults] integerForKey:_trailLengthKey];
}

- (bool)hasTrailLengthSetting{
    NSObject *isItNil = [[NSUserDefaults standardUserDefaults] objectForKey:_trailLengthKey];
    if(isItNil == nil) return false;
    return true;
}

/** TODO images saving
 - (void)savePhotoSetting{
 
 }
 
 - (void)loadPhotoSetting{
 
 }
 
 - (void)hasPhotoSetting{
 
 }
 **/

@end
