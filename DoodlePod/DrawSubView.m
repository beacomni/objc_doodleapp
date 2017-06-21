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
    [_drawPointsArray addObject:[NSValue valueWithCGPoint:touch]];
    if(_drawPointsArray.count > _trailLength){
        [_drawPointsArray removeObjectAtIndex:0];
    }
    [self setNeedsDisplay];
}

- (void)clearDrawPoints{
    _drawPointsArray = [[NSMutableArray alloc] init];
    [self refresh];
}

- (void)updateTrailLengthWith:(long)len{
    _trailLength = len;
}

- (void)refresh{
        [self setNeedsDisplay];
}

@end
