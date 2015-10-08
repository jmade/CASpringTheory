//
//  JDMLineLayer.m
//  CASpringTheory
//
//  Created by Justin Madewell on 9/24/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "JDMLineLayer.h"

#import "FBTweakInline.h"
#import "FBTweak.h"
#import "FBTweakInlineInternal.h"
#import "FBTweakCollection.h"
#import "FBTweakStore.h"
#import "FBTweakCategory.h"

#import "FBTweakViewController.h"



@implementation JDMLineLayer


@dynamic startPoint,endPoint,controlValue,controlPoint1Value,controlPoint2Value,controlPoint1MidPointOffset,controlPoint2MidPointOffset;

@synthesize  fillColor, strokeColor, strokeWidth, wobbleAmount=_wobbleAmount,wobbleAnimationAmount=_wobbleAnimationAmount;


- (id)init {
    self = [super init];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.strokeColor = [UIColor blackColor];
        self.strokeWidth = 1.0;
        self.geometryFlipped = NO;
        self.shapePointCount = 3;
        self.wobbleAmount = 0;
        self.wobbleAnimationAmount = 0;
        self.controlPoint1MidPointOffset = 0.25;
        self.controlPoint2MidPointOffset = 0.75;
        
        self.originalControlPoint1MidPointOffset = 0.25;
        self.originalControlPoint2MidPointOffset = 0.75;
        
        FBTweakBind(self, wobbleAnimationAmount, @"[5] Wobble", @"[*] Wobble", @"[*] WobbleAmount",0.25,-1.0,1.0);
        FBTweakBind(self, wobbleAmount, @"Design", @"WobbleAmount", @"WobbleAmount",0.25,-1.0,1.0);
        
        FBTweakBind(self, originalControlPoint1MidPointOffset, @"Design", @"Offset Mid-Point (Veritcal)", @"C1 MidPoint",0.25,0.0,1.0);
        FBTweakBind(self, originalControlPoint2MidPointOffset, @"Design", @"Offset Mid-Point (Veritcal)", @"C2 MidPoint",0.75,0.0,1.0);
        
        
     }
    
    return self;
}


#pragma mark - Main Drawing Call
-(void)drawInContext:(CGContextRef)ctx {
    
    [self drawControlPointsInContext:ctx];
    
    [self drawForDeCasteljau:ctx];
    
    [self drawFor2Control:ctx];
    
    
}



#pragma mark - For Custom Animation

-(id<CAAction>)actionForKey:(NSString *)event {
    
    if (
        [event isEqualToString:kControlPoint1Value] ||
        [event isEqualToString:kControlPoint2Value] ||
        
        [event isEqualToString:kControlPoint1MidPointOffset] ||
        [event isEqualToString:kControlPoint2MidPointOffset] ||
        
        [event isEqualToString:kControlValue]
       )
        
    {
        
        return [self makeAnimationForKey:event];
    }

    
    
    return [super actionForKey:event];
}


-(CABasicAnimation *)makeAnimationForKey:(NSString *)key {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
    anim.fromValue = [[self presentationLayer] valueForKey:key];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim.duration = 0.25;
    
    FBTweakBind(anim, duration, @"Design", @"Animation", @"Duration",0.12,0,1.0);
    
    
    return anim;
}


- (id)initWithLayer:(id)layer {
    if (self = [super initWithLayer:layer]) {
        if ([layer isKindOfClass:[JDMLineLayer class]]) {
            JDMLineLayer *other = (JDMLineLayer *)layer;
            self.startPoint = other.startPoint;
            self.endPoint = other.endPoint;
            self.controlValue = other.controlValue;
            
            self.originalStartPoint = other.originalStartPoint;
            self.originalEndPoint = other.originalEndPoint;
            self.shapePointCount = other.shapePointCount;
            
            self.controlPoint1Value = other.controlPoint1Value;
            self.controlPoint2Value = other.controlPoint2Value;
            
            self.originalControlPoint1MidPointOffset = other.originalControlPoint1MidPointOffset;
            self.originalControlPoint2MidPointOffset = other.originalControlPoint2MidPointOffset;
            
            self.wobbleAmount = other.wobbleAmount;
           
            
            self.strokeColor = other.strokeColor;
            self.strokeWidth = other.strokeWidth;
        }
    }
    
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {

    if (
        [key isEqualToString:kStartPoint] ||
        [key isEqualToString:kEndPoint] ||
        
        [key isEqualToString:kControlPoint1Value] ||
        [key isEqualToString:kControlPoint2Value] ||
        
        [key isEqualToString:kControlPoint1MidPointOffset] ||
        [key isEqualToString:kControlPoint2MidPointOffset] ||
        
        [key isEqualToString:kControlValue]
        )
        
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}




#pragma mark - Drawing Methods For Context


// Curve
-(void)drawFor2Control:(CGContextRef)ctx
{
    CGPoint c1 = [self findControl1Point];
    CGPoint c2 = [self findControl2Point];
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.startPoint.x, self.startPoint.y);
    CGContextAddCurveToPoint(ctx, c1.x, c1.y, c2.x, c2.y, self.endPoint.x, self.endPoint.y);
   
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
    CGContextSetLineWidth(ctx, self.strokeWidth);
    
    CGContextDrawPath(ctx, kCGPathStroke);
}



#pragma mark - Control Point 1
-(CGPoint)findControl1Point
{
    CGPoint c1MidPoint = [self findCurrentMidPointForControl1];
    
    CGPoint c1;
    
    if (self.controlPoint1Value == 0) {
        
        c1 = c1MidPoint;
    }
    else
    {
        c1 =  GetPerpendicularPointForControl(self.originalStartPoint,self.originalEndPoint,c1MidPoint,self.controlPoint1Value);
        
    }
    
    return c1;
}

#pragma mark - Control Point 2

-(CGPoint)findControl2Point
{
    CGPoint c2MidPoint = [self findCurrentMidPointForControl2];
    
    CGPoint c2;
    
    if (self.controlPoint2Value == 0) {
        c2 = c2MidPoint;
    }
    else
    {
        c2 =  GetPerpendicularPointForControl(self.originalStartPoint,self.originalEndPoint,c2MidPoint,self.controlPoint2Value);
    }
    
    return c2;
}






#pragma mark - Drawing Functions




-(void)drawDots:(NSArray*)dots with:(UIColor*)color inContext:(CGContextRef)ctx
{
    CGFloat dotSize = FBTweakValue(@"Design", @"Visual",@"Dot Size",4.0,1.0,20.0);
    
    for (NSValue *pointValue in dots)
    {
        CGPoint point = [pointValue CGPointValue];
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        
        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
        
        CGContextStrokePath(ctx);
        
    }
    
}



-(CGPoint)findCurrentMidPointForControl1
{
   return GetPointAtPercentageBetweenPoints(self.originalStartPoint, self.originalEndPoint, self.controlPoint1MidPointOffset);
}

-(CGPoint)findCurrentMidPointForControl2
{    
    return GetPointAtPercentageBetweenPoints(self.originalStartPoint, self.originalEndPoint, self.controlPoint2MidPointOffset);
}




CGFloat bezierPoint(CGFloat t, CGFloat a, CGFloat b, CGFloat c, CGFloat d)
{
    CGFloat C1 = ( d - (3.0 * c) + (3.0 * b) - a );
    CGFloat C2 = ( (3.0 * c) - (6.0 * b) + (3.0 * a) );
    CGFloat C3 = ( (3.0 * b) - (3.0 * a) );
    CGFloat C4 = ( a );
    
    return ( C1*t*t*t + C2*t*t + C3*t + C4  );
}

CGFloat bezierTangent(CGFloat t, CGFloat a, CGFloat b, CGFloat c, CGFloat d)
{
    CGFloat C1 = ( d - (3.0 * c) + (3.0 * b) - a );
    CGFloat C2 = ( (3.0 * c) - (6.0 * b) + (3.0 * a) );
    CGFloat C3 = ( (3.0 * b) - (3.0 * a) );
    CGFloat C4 = ( a );
    
    return ( ( 3.0 * C1 * t* t ) + ( 2.0 * C2 * t ) + C3 );
}



//Vector3 CalculateBezierPoint(float t,
//                             Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
//{
//    float u = 1 – t;
//    float tt = t*t;
//    float uu = u*u;
//    float uuu = uu * u;
//    float ttt = tt * t;
//    
//    Vector3 p = uuu * p0; //first term
//    p += 3 * uu * t * p1; //second term
//    p += 3 * u * tt * p2; //third term
//    p += ttt * p3; //fourth term
//    
//    return p;
//}





// straight line,

CGPoint GetArbitaryPoint(CGPoint p1, CGPoint p2, CGFloat percentage)
{
    
    CGFloat x = p1.x + (p2.x-p1.x) * percentage;
    CGFloat y = p1.y + (p2.y-p1.y) * percentage;
    
    return CGPointMake(x, y);
}

CGPoint GetPointAtPercentageBetweenPoints(CGPoint p1, CGPoint p2, CGFloat percentage)
{
    
    CGFloat x = p1.x + (p2.x-p1.x) * percentage;
    CGFloat y = p1.y + (p2.y-p1.y) * percentage;
    
    return CGPointMake(x, y);
}



CGFloat bezierInterpolation(CGFloat t, CGFloat a, CGFloat b, CGFloat c, CGFloat d) {
    // see also below for another way to do this, that follows the 'coefficients'
    // idea, and is a little clearer
    CGFloat t2 = t * t;
    CGFloat t3 = t2 * t;
    return a + (-a * 3 + t * (3 * a - a * t)) * t
    + (3 * b + t * (-6 * b + b * 3 * t)) * t
    + (c * 3 - c * 3 * t) * t2
    + d * t3;
}




#pragma mark - Additional Drawing Methods


-(void)drawControlPointsInContext:(CGContextRef)ctx
{
    BOOL showControlPoints = FBTweakValue(@"Design", @"Visual", @"Show Control Points",YES);
    
    if (showControlPoints) {
        
        [self drawDots:@[
                         [NSValue valueWithCGPoint:[self findControl1Point]],
                         [NSValue valueWithCGPoint:[self findControl2Point]],
                         
                         ] with:[UIColor redColor] inContext:ctx];
        
    }
    
}





#pragma mark - Find point on a Bezier de Casteljau's Algorithm

/* 
 
 1. draw 3 lines
    a. line from startpoint to control point 1
    b. line from control point 1 to control point 2
    c. line from control point 2 to endPoint
 */

-(void)drawForDeCasteljau:(CGContextRef)ctx
{
    CGFloat percentage = FBTweakValue(@"Design", @"deCasteljau", @"% Along Curve",0.10,0.0,1.0);
    
    BOOL showDeCasteljauConfig = FBTweakValue(@"Design",@"deCasteljau", @"DeCasteljau",YES);
    BOOL showCirclesAroundControlsPoints = FBTweakValue(@"Design",@"deCasteljau", @"Control Circles",YES);
    BOOL showConnectionLines = FBTweakValue(@"Design",@"deCasteljau", @"Connection Lines",YES);
    BOOL showFirstSetDots = FBTweakValue(@"Design",@"deCasteljau", @"First Dots",YES);
    BOOL showFirstSetLines = FBTweakValue(@"Design",@"deCasteljau", @"First Lines",YES);
    BOOL showSecondSetDots = FBTweakValue(@"Design",@"deCasteljau", @"Second Dots",YES);
    BOOL showSecondSetLines = FBTweakValue(@"Design",@"deCasteljau", @"Second Lines",YES);
    BOOL showCurvePoint = FBTweakValue(@"Design",@"deCasteljau", @"Curve Point",YES);
   
    if (showDeCasteljauConfig)
    {
        if (showCirclesAroundControlsPoints) {
             [self drawCirclesAroundControlsPoints:ctx];
        }
        
        if (showConnectionLines) {
            [self drawConnectionLines:ctx];
        }
        
        if (showFirstSetDots) {
            [self drawFirstSetOfDotsAtPercentage:percentage inContext:ctx];
        }
        
        if (showFirstSetLines) {
            [self drawFirstSetOfLinesAtPercentage:percentage inContext:ctx];
        }
        
        if (showSecondSetDots) {
            [self drawSecondSetOfDotsAtPercentage:percentage inContext:ctx];
        }
        
        if (showSecondSetLines) {
             [self drawSecondSetOfLinesAtPercentage:percentage inContext:ctx];
        }
        
        if (showCurvePoint) {
            [self drawCurvePointAtPercentage:percentage inContext:ctx];
        }
    }
}


-(NSArray*)curvePoints
{
    return @[
             [NSValue valueWithCGPoint:self.originalStartPoint],
             [NSValue valueWithCGPoint:[self findControl1Point]],
             [NSValue valueWithCGPoint:[self findControl2Point]],
             [NSValue valueWithCGPoint:self.originalEndPoint],
             ];
}


-(void)drawConnectionLines:(CGContextRef)ctx
{
    CGPoint s = self.originalStartPoint;
    CGPoint e = self.originalEndPoint;
    CGPoint c1 = [self findControl1Point];
    CGPoint c2 = [self findControl2Point];
    
    UIColor *lineColor = [UIColor blackColor];
    
    CGContextBeginPath(ctx);
    
    //
    CGContextMoveToPoint(ctx, s.x, s.y);
    //
    CGContextAddLineToPoint(ctx, c1.x, c1.y);
    //
    CGContextAddLineToPoint(ctx, c2.x, c2.y);
    //
    CGContextAddLineToPoint(ctx, e.x, e.y);
    
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    CGContextStrokePath(ctx);
}

-(void)drawCirclesAroundControlsPoints:(CGContextRef)ctx
{
    NSArray *points = [self curvePoints];
    
    CGFloat dotSize = 2.0;
    UIColor *color = [UIColor blackColor];
    UIColor *fill = [UIColor lightGrayColor];
    
    for (NSValue *pointValue in points)
    {
        CGPoint point = [pointValue CGPointValue];
        
        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
        
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        CGContextStrokePath(ctx);
        CGContextSetFillColorWithColor(ctx, fill.CGColor);
        CGContextFillPath(ctx);
        
    }
}







-(void)drawFirstSetOfDotsAtPercentage:(CGFloat)percentage inContext:(CGContextRef)ctx
{
    
    // note the array is backwards as per video ?
    
    NSArray *points = @[
                        [NSValue valueWithCGPoint:GetPointAtPercentageBetweenPoints(self.originalEndPoint, [self findControl2Point], percentage)],
                        [NSValue valueWithCGPoint:GetPointAtPercentageBetweenPoints([self findControl2Point], [self findControl1Point], percentage)],
                        [NSValue valueWithCGPoint: GetPointAtPercentageBetweenPoints([self findControl1Point], self.originalStartPoint, percentage)],
                        ];
    
    
    // Config
    CGFloat dotSize = 2.0;
    UIColor *stroke  = darkenColor([UIColor purpleColor], 0.50);
    UIColor *fill = darkenColor([UIColor purpleColor], 0.50);
    
    for (NSValue *pointValue in points)
    {
        CGPoint point = [pointValue CGPointValue];
        
        CGContextBeginPath(ctx);
        
        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
        
        CGContextClosePath(ctx);
        
        CGContextSetFillColorWithColor(ctx, fill.CGColor);
        CGContextDrawPath(ctx, kCGPathFill);
        
        CGContextSetStrokeColorWithColor(ctx, stroke.CGColor);
        CGContextDrawPath(ctx, kCGPathStroke);

        
    }
}



-(void)drawFirstSetOfLinesAtPercentage:(CGFloat)percentage inContext:(CGContextRef)ctx
{
    // Config
    UIColor *stroke  = [UIColor purpleColor];
    
    CGPoint p1 = GetPointAtPercentageBetweenPoints(self.originalEndPoint, [self findControl2Point], percentage);
    CGPoint p2 = GetPointAtPercentageBetweenPoints([self findControl2Point], [self findControl1Point], percentage);
    CGPoint p3 = GetPointAtPercentageBetweenPoints([self findControl1Point], self.originalStartPoint, percentage);
    
    
    
    // Drawing
    CGContextBeginPath(ctx);

    CGContextMoveToPoint(ctx, p1.x, p1.y);
    CGContextAddLineToPoint(ctx, p2.x, p2.y);
    CGContextAddLineToPoint(ctx, p3.x, p3.y);
    
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextSetStrokeColorWithColor(ctx, stroke.CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);

}



#pragma mark - Second Set


-(void)drawSecondSetOfDotsAtPercentage:(CGFloat)percentage inContext:(CGContextRef)ctx
{
    
    // first Set
    CGPoint firstP1 = GetPointAtPercentageBetweenPoints(self.originalEndPoint, [self findControl2Point], percentage);
    CGPoint firstP2 = GetPointAtPercentageBetweenPoints([self findControl2Point], [self findControl1Point], percentage);
    CGPoint firstP3 = GetPointAtPercentageBetweenPoints([self findControl1Point], self.originalStartPoint, percentage);
    
    
    // Second
    CGPoint secondP1 = GetPointAtPercentageBetweenPoints(firstP1, firstP2, percentage);
    CGPoint secondP2 = GetPointAtPercentageBetweenPoints(firstP2, firstP3, percentage);
    
    NSArray *points = @[
                        [NSValue valueWithCGPoint:secondP1],
                        [NSValue valueWithCGPoint:secondP2],
                        ];
    
    // Config
    CGFloat dotSize = 2.0;
    UIColor *stroke  = darkenColor([UIColor greenColor], 0.50);
    UIColor *fill = darkenColor([UIColor greenColor], 0.50);
    
    
    // draw
    for (NSValue *pointValue in points)
    {
        CGPoint point = [pointValue CGPointValue];
        
        CGContextBeginPath(ctx);
        
        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
        
        CGContextClosePath(ctx);
        
        CGContextSetFillColorWithColor(ctx, fill.CGColor);
        CGContextDrawPath(ctx, kCGPathFill);
        
        CGContextSetStrokeColorWithColor(ctx, stroke.CGColor);
        CGContextDrawPath(ctx, kCGPathStroke);
        
        
    }

}

-(void)drawSecondSetOfLinesAtPercentage:(CGFloat)percentage inContext:(CGContextRef)ctx
{
    // Config
    UIColor *stroke  = [UIColor greenColor];
    
    // first Set
    CGPoint firstP1 = GetPointAtPercentageBetweenPoints(self.originalEndPoint, [self findControl2Point], percentage);
    CGPoint firstP2 = GetPointAtPercentageBetweenPoints([self findControl2Point], [self findControl1Point], percentage);
    CGPoint firstP3 = GetPointAtPercentageBetweenPoints([self findControl1Point], self.originalStartPoint, percentage);
    
    
    // Second
    CGPoint secondP1 = GetPointAtPercentageBetweenPoints(firstP1, firstP2, percentage);
    CGPoint secondP2 = GetPointAtPercentageBetweenPoints(firstP2, firstP3, percentage);

    
    
    
    // Drawing
    CGContextBeginPath(ctx);
    
    CGContextMoveToPoint(ctx, secondP1.x, secondP1.y);
    CGContextAddLineToPoint(ctx, secondP2.x, secondP2.y);
    
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextSetStrokeColorWithColor(ctx, stroke.CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);

}

-(void)drawCurvePointAtPercentage:(CGFloat)percentage inContext:(CGContextRef)ctx
{
    
    NSArray *points = @[[NSValue valueWithCGPoint:[self bezierPointAtPercentage:percentage]],];
    
    // Config
    CGFloat dotSize = 3.0;
    UIColor *stroke  = [UIColor orangeColor];
    UIColor *fill = lightenColor([UIColor orangeColor], 0.50);
    
    for (NSValue *pointValue in points)
    {
        CGPoint point = [pointValue CGPointValue];
        
        CGContextBeginPath(ctx);
        
        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
        
        CGContextClosePath(ctx);
        
        CGContextSetFillColorWithColor(ctx, fill.CGColor);
        CGContextDrawPath(ctx, kCGPathFill);
        
        CGContextSetStrokeColorWithColor(ctx, stroke.CGColor);
        CGContextDrawPath(ctx, kCGPathStroke);
        
        
    }

}


-(CGPoint)bezierPointAtPercentage:(CGFloat)percentage
{
    // first Set
    CGPoint firstP1 = GetPointAtPercentageBetweenPoints(self.originalEndPoint, [self findControl2Point], percentage);
    CGPoint firstP2 = GetPointAtPercentageBetweenPoints([self findControl2Point], [self findControl1Point], percentage);
    CGPoint firstP3 = GetPointAtPercentageBetweenPoints([self findControl1Point], self.originalStartPoint, percentage);
    
    CGPoint secondP1 = GetPointAtPercentageBetweenPoints(firstP1, firstP2, percentage);
    CGPoint secondP2 = GetPointAtPercentageBetweenPoints(firstP2, firstP3, percentage);
    
    // Curve Point!!!!!
    CGPoint thirdP1 = GetPointAtPercentageBetweenPoints(secondP1, secondP2, percentage);
    
    return thirdP1;
}


-(CGPoint)curvePointAtPercentage:(CGFloat)percentage
{
    // first Set
    CGPoint firstP1 = GetPointAtPercentageBetweenPoints(self.originalEndPoint, [self findControl2Point], percentage);
    CGPoint firstP2 = GetPointAtPercentageBetweenPoints([self findControl2Point], [self findControl1Point], percentage);
    CGPoint firstP3 = GetPointAtPercentageBetweenPoints([self findControl1Point], self.originalStartPoint, percentage);
    
    CGPoint secondP1 = GetPointAtPercentageBetweenPoints(firstP1, firstP2, percentage);
    CGPoint secondP2 = GetPointAtPercentageBetweenPoints(firstP2, firstP3, percentage);
    
    // Curve Point!!!!!
    CGPoint thirdP1 = GetPointAtPercentageBetweenPoints(secondP1, secondP2, percentage);
    
    return thirdP1;
}







#pragma mark - Math

-(CGPoint)calculateCenterPoint
{
    CGPoint theNewCenter;
    
    if (self.wobbleAmount == 0) {
        theNewCenter = MidPoint(self.originalStartPoint, self.originalEndPoint);
    }
    else {
        theNewCenter = [self bezierPointAtPercentage:0.50];
    }
        
    return  theNewCenter;

}



CGPoint(^GetPerpendicularPointForControl)(CGPoint,CGPoint,CGPoint,CGFloat) = ^(CGPoint startPoint,CGPoint endPoint,CGPoint midPoint,CGFloat distance){
    
    int startX = startPoint.x;
    int startY = startPoint.y;
    
    int stopX = endPoint.x;
    int stopY = endPoint.y;
    
    CGPoint M = midPoint;
    
    CGPoint p = CGPointMake(startX - stopX, startY - stopY);
    CGPoint n = CGPointMake(-p.y, p.x);
    int norm_length = sqrtf((n.x * n.x) + (n.y * n.y));
    n.x /= norm_length;
    n.y /= norm_length;
    
    return CGPointMake(M.x + (distance * n.x), M.y + (distance * n.y));
    
    
};



#pragma mark - New Animation Section

// try and have the start point follow the path to the center.

// have to do the fill animation of the color, 












@end
