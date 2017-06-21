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
    _trailLength = 100;
    _trailLengthKey = @"trailLengthSetting";
    if([self hasTrailLengthSetting]){
        [self loadTrailLengthSetting];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(contextRef, true);
    
    CGContextSetRGBStrokeColor(contextRef,0.03, 0.90, 0.50, .9);
    CGContextSetLineWidth(contextRef, 0.8);
    
    CGContextBeginPath(contextRef);
    CGContextMoveToPoint(contextRef, 155, 155);
    CGContextAddLineToPoint(contextRef, 290, 190);
    CGContextDrawPath(contextRef, kCGPathStroke);
    
    CGContextSetRGBFillColor(contextRef, 0.02, 0.88, 0.48, .88);
    
    CGContextStrokeRect(contextRef, CGRectMake(50, 350, 100, 50));
    
    for(int i = 0;  i < _drawPointsArray.count; i++){
        CGPoint point = [[_drawPointsArray objectAtIndex:i] CGPointValue];
        CGContextFillEllipseInRect(contextRef, CGRectMake(point.x - 2, point.y-2, 3, 3));
    }
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
    [_drawPointsArray addObject:[NSValue valueWithCGPoint:touch]];
    [self setNeedsDisplay];
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
    NSString *path = [self getSavePath];
    NSMutableArray *undeserialized = [[NSMutableArray alloc] init];
    undeserialized = [NSMutableArray arrayWithContentsOfFile:path];
    for(int i = 0; i < undeserialized.count; i++){
        [_drawPointsArray addObject:[NSValue valueWithCGPoint:CGPointFromString(undeserialized[i])]];
    }
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

@end
