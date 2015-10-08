//
//  ViewController.m
//  CASpringTheory
//
//  Created by Justin Madewell on 9/22/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "ViewController.h"

#import "JDMUtility.h"
#import "JDMLineLayer.h"
#import "FBTweakInline.h"
#import "FBTweak.h"
#import "FBTweakInlineInternal.h"
#import "FBTweakCollection.h"
#import "FBTweakStore.h"
#import "FBTweakCategory.h"

#import "FBTweakViewController.h"

#import "POPAnimatableProperty+JDMLineLayer.h"


@interface ViewController ()

@property CALayer *baseLayer;
@property CAShapeLayer *lineShapeLayer;
@property CAReplicatorLayer *replicatorLayer;
@property JDMLineLayer *lineLayer;
@property UILabel *animationTypeLabel;

@property BOOL shouldNotAnimate;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupForLineLayer];
    
    _animationTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, ScreenWidth(), 30)];
    _animationTypeLabel.textAlignment = NSTextAlignmentCenter;
    _animationTypeLabel.numberOfLines = 1;
    [self.view addSubview:_animationTypeLabel];
    
    [self updateLabelWithAnimationType:5];
    
    
    
    CGFloat remappedValue = ValueInRemappedRangeDefinedByOldMinAndMaxToNewMinAndMax(12.0, 20.0, 1.0, 50.0, 100.0);
    NSLog(@"remappedValue: %f",remappedValue);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tweaksDismissed) name:@"FBTweakShakeViewControllerDidDismissNotification" object:nil];
    
}

-(void)tweaksDismissed
{
    [_lineLayer setNeedsDisplay];
    
    [self refactorForNumberOfPoints:_lineLayer.shapePointCount];

    [self animateLines:-1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Action
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self animateLines:[[touches anyObject] locationInView:self.view].y];
}


-(void)updateLabelWithAnimationType:(int)animationType
{
    NSString *labelText;
    
    NSLog(@"animationType:%i",(int)animationType);
    
    switch (animationType) {
        case 0:
            labelText = @"Shrink To Center";
            break;
        case 1:
            labelText = @"Shrink To End";
            break;
        case 2:
            labelText = @"Shrink to Start";
            break;
        case 3:
            labelText = @"Wobble";
            break;
        case 4:
            labelText = @"Experimental";
            break;
        case 5:
            labelText = @"Awesome Bezier Application";
            
        default:
            break;
    }
    
    
    _animationTypeLabel.text = labelText;
}




-(void)animateLines:(CGFloat)yValue
{
    static int decider;
    
    if (yValue == -1.0) {
        NSLog(@"Tweaks Dissmissed");
        yValue = 0;
    }
    else
    {
        int animationType = FBTweakValue(@"Type of Animation", @"Animation Type", @"Type of Animation",0, (@{@(0) : @"Shrink to Center",
                                                                                                             @(1) : @"Shrink to End" ,
                                                                                                             @(2) : @"Shrink to Start",
                                                                                                             @(3) : @"Wobble",
                                                                                                             @(4) : @"Experimental",
                                                                                                             @(5) : @"Morph",
                                                                                                             
                                                                                                             
                                                                                                             }));
        
        
        
        
        
        if (animationType < 4) {
            
            if (decider == 0) {
                [self performAnimation:animationType];
                decider++;
                return;
            }
            else
            {
                [self returnToDefaultsAnimation];
                decider--;
                return;
            }
            
        }
        else if (animationType == 4)
        {
            NSLog(@"perform experimental only");
            [self performAnimation:4];
        }
        else
        {
            if (yValue == 0) {
                [self returnToDefaultsAnimation];
                return;
            }
            else if (yValue < _replicatorLayer.frame.origin.y)
            {
                [self addPointToShape];
                
            }
            else if (yValue > _replicatorLayer.frame.origin.y+_replicatorLayer.bounds.size.height)
            {
                [self removePointFromShape];
            }
            else
            {
            }
        }
        
        [self updateLabelWithAnimationType:animationType];

    }
    
    
    
    
}

#pragma mark -  Device Color Helper
-(UIColor*)deviceColor
{
    NSString *deviceColor;
    NSString *deviceEnclosureColor;
    
    UIDevice *device = [UIDevice currentDevice];
    
    SEL selector = NSSelectorFromString(@"deviceInfoForKey:");
    if (![device respondsToSelector:selector]) {
        selector = NSSelectorFromString(@"_deviceInfoForKey:");
    }
    
    if ([device respondsToSelector:selector]) {
        // private API! Do not use in App Store builds!
        deviceColor = [device performSelector:selector withObject:@"DeviceColor"];
        deviceEnclosureColor = [device performSelector:selector withObject:@"DeviceEnclosureColor"];
    } else {
    
    }
    
    UIColor *color = [self colorWithHexString:deviceEnclosureColor];
    
    return color;
}

#pragma mark - Color With Hex String
- (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}





#pragma mark - Main Setup Call

-(void)setupForLineLayer
{
    // setup
    CGFloat hudSize = ScreenSmaller() * .95;
    int numberOfPoints = 1;
    NSArray *config = [self makeConfigArrayForLineLayerWithPoints:numberOfPoints andOfSize:hudSize];
    
    // LINELAYER
    // Line Layer
    _lineLayer = [[JDMLineLayer
                   alloc]init];
    _lineLayer.bounds = [[config objectAtIndex:0] CGRectValue];
    _lineLayer.position = [[config objectAtIndex:1] CGPointValue];
    _lineLayer.strokeColor = [UIColor blueColor];
    _lineLayer.strokeWidth = 1.0;
    
    
    UIColor *borderColor = [self deviceColor]; // [UIColor orangeColor];
    
    _lineLayer.borderColor = borderColor.CGColor;
    _lineLayer.borderWidth = .5;
    
    _lineLayer.startPoint = [[config objectAtIndex:2] CGPointValue];
    _lineLayer.originalStartPoint = [[config objectAtIndex:2] CGPointValue];
    _lineLayer.endPoint = [[config objectAtIndex:3] CGPointValue];
    _lineLayer.originalEndPoint = [[config objectAtIndex:3] CGPointValue];
    
    _lineLayer.controlValue = 0;
    
    _lineLayer.controlPoint1Value = 0;
    _lineLayer.controlPoint2Value = 0;
    
    _lineLayer.shapePointCount = numberOfPoints;
    
    FBTweakBind(_lineLayer, borderWidth, @"Design", @"LineLayer", @"BorderWidth",0.5,0,20.0);
    FBTweakBind(_lineLayer, strokeWidth, @"Design", @"LineLayer", @"StrokeWidth",1.0,0,20.0);
    
    // create Replicator Layer
    CAReplicatorLayer * lineLayerReplicator = [CAReplicatorLayer layer];
    [lineLayerReplicator setGeometryFlipped:NO];
    [lineLayerReplicator setBounds:CGRectMake(0, 0, hudSize, hudSize)];
    [lineLayerReplicator setCornerRadius:10.0];
    [lineLayerReplicator setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:0.5].CGColor];
    [lineLayerReplicator setPosition:RectGetCenter(self.view.frame)];
    
    // Configure Replciator
    CGFloat angle = TWO_PI/(numberOfPoints);
    CATransform3D instanceRotation = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0);
    [lineLayerReplicator setInstanceCount:numberOfPoints];
    [lineLayerReplicator setInstanceTransform:instanceRotation];
    
    [lineLayerReplicator addSublayer:_lineLayer];
    [[self.view layer] addSublayer:lineLayerReplicator];
    
    _replicatorLayer = lineLayerReplicator;
    
    [self checkForWobble];
    
}

-(void)checkForWobble
{
    CGFloat wobbleFactor = _lineLayer.wobbleAmount;
    
    CGFloat newControlValue = wobbleFactor * PointDistanceFromPoint(_lineLayer.originalStartPoint, _lineLayer.originalEndPoint);
    
    [_lineLayer pop_addAnimation:[self moveControlPoint1Value:@(newControlValue)] forKey:@"checkC1Wobble"];
    [_lineLayer pop_addAnimation:[self moveControlPoint2Value:@(newControlValue)] forKey:@"checkC2Wobble"];
}












#pragma mark - Update


-(void)addPointToShape
{
    [self refactorForNumberOfPoints:++_lineLayer.shapePointCount];
}

-(void)removePointFromShape
{
   [self refactorForNumberOfPoints:--_lineLayer.shapePointCount];
}


-(void)refactorForNumberOfPoints:(int)newPointCount
{
    [self updateLineLayerForPoints:newPointCount];
    [self updateReplicatorLayerForPoints:newPointCount];
    
    [self checkForWobble];
    
    [self updatePathForLineShapeLayer];
}



-(void)updateLineLayerForPoints:(int)points
{
    
    NSArray *config = [self makeConfigArrayForLineLayerWithPoints:points andOfSize:_replicatorLayer.bounds.size.width];
    
    [_lineLayer pop_addAnimation:[self springLineLayerToNewBounds:[[config objectAtIndex:0] CGRectValue]] forKey:@"newBounds"];
    [_lineLayer pop_addAnimation:[self springLineLayerToNewPosition:[[config objectAtIndex:1] CGPointValue]] forKey:@"newPosition"];

    [_lineLayer pop_addAnimation:[self moveStartPoint:[[config objectAtIndex:2] CGPointValue]] forKey:@"moveStart"];
    [_lineLayer pop_addAnimation:[self moveEndPoint:[[config objectAtIndex:3] CGPointValue]] forKey:@"moveEnd"];
    
    _lineLayer.originalStartPoint = [[config objectAtIndex:2] CGPointValue];
    _lineLayer.originalEndPoint = [[config objectAtIndex:3] CGPointValue];
    
    
}

-(void)updateReplicatorLayerForPoints:(int)points
{
    [_replicatorLayer setInstanceCount:points];
    
    
    CGFloat angle = TWO_PI/points;
    CATransform3D instanceRotation = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0);
    [_replicatorLayer setInstanceTransform:instanceRotation];

}











#pragma mark - Logic

-(NSArray*)makeConfigArrayForLineLayerWithPoints:(int)points andOfSize:(CGFloat)size
{
    CGPoint position;
    CGPoint startPoint;
    CGPoint endPoint;
    CGRect bounds;
    
    // // //
    
    CGFloat hudSize = size;
    CGFloat lineDistance;
    
    // Shape Lines
    CGFloat numberOfLines = points;
    
    if (numberOfLines < 2) {
        numberOfLines = 2;
        lineDistance = hudSize*0.5;
    }
    
    //We need to find the Position, the Bounds, and start & end Points for the end shape
    
    // calculate the shape
    NSArray *pointsLines = PointsPlottedAroundCenter(numberOfLines, hudSize*0.5);
    
    // find the first 2 points
    CGPoint start1 = [[pointsLines objectAtIndex:1] CGPointValue];
    CGPoint end1 = [[pointsLines objectAtIndex:0] CGPointValue];
    
    // POSITION
    // find the position for the Line layer by getting the midPoint
    CGPoint firstLineMidPoint = MidPoint(start1, end1);
    position = firstLineMidPoint;
    
    // find out how long the line should be
    lineDistance = PointDistanceFromPoint(start1,end1) ;
    
    // Caluclation For LineLayer
    CGRect lineFrameRect = CGRectMake(0, 0, lineDistance, lineDistance);
    
    // get the ange of rotation the forst segment of the shape is
    CGFloat rotationAngleNeededAsDegress = GetAngle(start1, end1);
    // translate it
    CGFloat rot = -(90 - rotationAngleNeededAsDegress);
    // plot to find the start and End Points
    NSArray * pointsForPath = PointsForRectOfSizeWithRotation(lineFrameRect, rot);
    
    // find the new Rotated Start and End Points
    // STARTPOINT
    CGPoint calculatedStartPoint = MidPoint([[pointsForPath objectAtIndex:0] CGPointValue], [[pointsForPath objectAtIndex:1] CGPointValue]);
    startPoint = calculatedStartPoint;
    // ENDPOINT
    CGPoint calculatedEndPoint = MidPoint([[pointsForPath objectAtIndex:2] CGPointValue], [[pointsForPath objectAtIndex:3] CGPointValue]);
    endPoint = calculatedEndPoint;
    
    UIBezierPath *customPathForSquare = [UIBezierPath bezierPath];
    [customPathForSquare moveToPoint:[[pointsForPath objectAtIndex:0] CGPointValue]];
    [customPathForSquare addLineToPoint:[[pointsForPath objectAtIndex:1] CGPointValue]];
    [customPathForSquare addLineToPoint:[[pointsForPath objectAtIndex:2] CGPointValue]];
    [customPathForSquare addLineToPoint:[[pointsForPath objectAtIndex:3] CGPointValue]];
    [customPathForSquare addLineToPoint:[[pointsForPath objectAtIndex:0] CGPointValue]];
    [customPathForSquare closePath];
    
    // BOUNDS
    // find out the bounds for the newly rotated shape
    CGRect newBoundsForRotation = PathBoundingBox(customPathForSquare);
    CGRect lineLayerBounds = newBoundsForRotation;
    bounds = lineLayerBounds;
    
    
    // // //
    
    return @[
             [NSValue valueWithCGRect:bounds],
             [NSValue valueWithCGPoint:position],
             [NSValue valueWithCGPoint:startPoint],
             [NSValue valueWithCGPoint:endPoint],
             ];
}















#pragma mark - Animation Helpers



/* Main Animation Calls */

-(void)performAnimation:(int)animation
{
    
    switch (animation) {
        case 0:
            [self shrinkToCenterAnimation];
            break;
        case 1:
            [self shrinkToEndAnimation];
            break;
        case 2:
            [self shrinkToStartAnimation];
            break;
        case 3:
            [self startWobbleAnimation];
            break;
        case 4:
            [self performExperimentalAnimation];
            break;
            
        default:
            break;
    }
}



#pragma mark - Aninmation Functions
             
-(void)performExperimentalAnimation
{
    static int counter;
    
    if (counter == 3) {
        counter = 0;
    }
    
    switch (counter) {
        case 0:
             [self swapLineShapeLayerIn];
            NSLog(@"Swapped in ");
            break;
        case 1:
             [self strokeLineShapeAnimationTo:@(0.48)];
            NSLog(@"Animated To");
            break;
        case 2:
            [self returnStrokeOfLineShapeLayer];
            NSLog(@"Returning ");
            break;
            
        default:
            break;
    }
    counter++;
}

-(void)shrinkToCenterAnimation
{
    [self animateLineLayerToCenter];
}

-(void)shrinkToStartAnimation
{
    [self animateLineLayerToStart];
}

-(void)shrinkToEndAnimation
{
    [self animateLineLayerToEnd];
}

-(void)startWobbleAnimation
{
    CGFloat wobbleFactor = _lineLayer.wobbleAnimationAmount;
    CGFloat wobbleAmount = wobbleFactor * PointDistanceFromPoint(_lineLayer.originalStartPoint, _lineLayer.originalEndPoint);
    
    [_lineLayer pop_addAnimation:[self startControlPoint1WobbleAnimation:@(wobbleAmount)] forKey:@"wobbleC1"];
    [_lineLayer pop_addAnimation:[self startControlPoint2WobbleAnimation:@(wobbleAmount)] forKey:@"wobbleC2"];
}

-(void)returnToDefaultsAnimation
{
    [_lineLayer pop_removeAllAnimations];
    [self animateToDefualts];
}

-(void)animateToDefualts
{
    CGFloat wobbleFactor = _lineLayer.wobbleAmount;
    CGFloat newControlValue = wobbleFactor * PointDistanceFromPoint(_lineLayer.originalStartPoint, _lineLayer.originalEndPoint);

    [_lineLayer pop_addAnimation:[self moveControlPoint1Value:@(newControlValue)] forKey:@"C1WobbleDefault"];
    [_lineLayer pop_addAnimation:[self moveControlPoint2Value:@(newControlValue)] forKey:@"C2WobbleDefault"];
    
    [_lineLayer pop_addAnimation:[self moveControlPoint1MidPointOffset:@(_lineLayer.originalControlPoint1MidPointOffset)] forKey:@"C1MidDefault"];
    [_lineLayer pop_addAnimation:[self moveControlPoint2MidPointOffset:@(_lineLayer.originalControlPoint2MidPointOffset)] forKey:@"C2MidDefault"];
    
    [_lineLayer pop_addAnimation:[self moveStartPoint:_lineLayer.originalStartPoint] forKey:@"defaultStart"];
    [_lineLayer pop_addAnimation:[self moveEndPoint:_lineLayer.originalEndPoint] forKey:@"defaultEnd"];
}






#pragma mark - WOBBLE
#pragma mark -  Start Wobble

-(POPSpringAnimation*)startControlPoint1WobbleAnimation:(NSNumber*)amount
{
    POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerControlPoint1Value];
    
    BOOL shouldBeOffset = FBTweakValue(@"[5] Wobble", @"Offset Start", @"C1 Offset",NO);
    
    CGFloat offsetFloat = (-1.0 * [amount floatValue]);
    
    if (shouldBeOffset) {
        amount = @(offsetFloat);
    }

    
    POPSpringAnimation *startControlPoint1WobbleAnimation = [POPSpringAnimation animation];
    startControlPoint1WobbleAnimation.property = prop;
    startControlPoint1WobbleAnimation.toValue = amount;
    startControlPoint1WobbleAnimation.springBounciness = 12;
    startControlPoint1WobbleAnimation.springSpeed = 4;
    
    startControlPoint1WobbleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        
        if (finished) {
             [_lineLayer pop_addAnimation:[self continueControlPoint1WobbleAnimation:@(-[amount floatValue])] forKey:@"continueWobbleForControl1"];
        }
    };
    
    FBTweakBind(startControlPoint1WobbleAnimation, springBounciness, @"[5] Wobble", @"Start Wobble Control 1", @"SpringBounciness",12,12.0,20);
    FBTweakBind(startControlPoint1WobbleAnimation, springSpeed, @"[5] Wobble", @"Start Wobble Control 1", @"SpringSpeed",4,4.0,20);
    
    
    
    return startControlPoint1WobbleAnimation;
}

-(POPSpringAnimation*)startControlPoint2WobbleAnimation:(NSNumber*)amount
{
    POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerControlPoint2Value];

     BOOL shouldBeOffset = FBTweakValue(@"[5] Wobble", @"Offset Start", @"C2 Offset",NO);
    
    CGFloat offsetFloat = (-1.0 * [amount floatValue]);
    
    if (shouldBeOffset) {
        amount = @(offsetFloat);
    }

    
    POPSpringAnimation *startControlPoint2WobbleAnimation = [POPSpringAnimation animation];
    startControlPoint2WobbleAnimation.property = prop;
    startControlPoint2WobbleAnimation.toValue = amount;
    startControlPoint2WobbleAnimation.springBounciness = 12;
    startControlPoint2WobbleAnimation.springSpeed = 4;
    
    startControlPoint2WobbleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        
        if (finished) {
             [_lineLayer pop_addAnimation:[self continueControlPoint2WobbleAnimation:@(-[amount floatValue])] forKey:@"continueWobbleForControl2"];
        }
    };
    
    FBTweakBind(startControlPoint2WobbleAnimation, springBounciness, @"[5] Wobble", @"Start Wobble Control 2", @"SpringBounciness",12,12.0,20);
    FBTweakBind(startControlPoint2WobbleAnimation, springSpeed, @"[5] Wobble", @"Start Wobble Control 2", @"SpringSpeed",4,4.0,20);
    
    return startControlPoint2WobbleAnimation;
}

#pragma mark - Continue Wobble 

-(POPSpringAnimation*)continueControlPoint1WobbleAnimation:(NSNumber*)amount
{
    POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerControlPoint1Value];
    
    BOOL shouldBeOffset = FBTweakValue(@"[5] Wobble", @"Offset Continue", @"C1 Offset",NO);
    
    CGFloat offsetFloat = (-1.0 * [amount floatValue]);
    
    if (shouldBeOffset) {
        amount = @(offsetFloat);
    }

    
    POPSpringAnimation *continueControlPoint1WobbleAnimation = [POPSpringAnimation animation];
    continueControlPoint1WobbleAnimation.property = prop;
    continueControlPoint1WobbleAnimation.toValue = amount;
    continueControlPoint1WobbleAnimation.springBounciness = 12;
    continueControlPoint1WobbleAnimation.springSpeed = 4;
    continueControlPoint1WobbleAnimation.autoreverses = YES;
    continueControlPoint1WobbleAnimation.repeatForever = YES;
    
    
    FBTweakBind(continueControlPoint1WobbleAnimation, autoreverses, @"[5] Wobble", @"Continue Wobble Control 1", @"AutoReverses",YES);
    FBTweakBind(continueControlPoint1WobbleAnimation, repeatForever, @"[5] Wobble", @"Continue Wobble Control 1", @"Repeat Forever",YES);
    FBTweakBind(continueControlPoint1WobbleAnimation, springBounciness, @"[5] Wobble", @"Continue Wobble Control 1", @"SpringBounciness",12,12,500.0);
    FBTweakBind(continueControlPoint1WobbleAnimation, springSpeed, @"[5] Wobble", @"Continue Wobble Control 1", @"SpringSpeed",4,4,500.0);
    
    
    return continueControlPoint1WobbleAnimation;
}

-(POPSpringAnimation*)continueControlPoint2WobbleAnimation:(NSNumber*)amount
{
    POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerControlPoint2Value];
    
    BOOL shouldBeOffset = FBTweakValue(@"[5] Wobble", @"Offset Continue", @"C2 Offset",NO);
    
    CGFloat offsetFloat = (-1.0 * [amount floatValue]);
    
    if (shouldBeOffset) {
        amount = @(offsetFloat);
    }
    
    POPSpringAnimation *continueControlPoint2WobbleAnimation = [POPSpringAnimation animation];
    continueControlPoint2WobbleAnimation.property = prop;
    continueControlPoint2WobbleAnimation.toValue = amount;
    continueControlPoint2WobbleAnimation.springBounciness = 12;
    continueControlPoint2WobbleAnimation.springSpeed = 4;
    continueControlPoint2WobbleAnimation.autoreverses = YES;
    continueControlPoint2WobbleAnimation.repeatForever = YES;
    
    
    FBTweakBind(continueControlPoint2WobbleAnimation, autoreverses, @"[5] Wobble", @"Continue Wobble Control 2", @"AutoReverses",YES);
    FBTweakBind(continueControlPoint2WobbleAnimation, repeatForever, @"[5] Wobble", @"Continue Wobble Control 2", @"Repeat Forever",YES);
    FBTweakBind(continueControlPoint2WobbleAnimation, springBounciness, @"[5] Wobble", @"Continue Wobble Control 2", @"SpringBounciness",12,12,500.0);
    FBTweakBind(continueControlPoint2WobbleAnimation, springSpeed, @"[5] Wobble", @"Continue Wobble Control 2", @"SpringSpeed",4,4,500.0);
    
    
    return continueControlPoint2WobbleAnimation;
}


#pragma mark - CENTER

-(void)animateLineLayerToCenter
{
    CGPoint center = [_lineLayer calculateCenterPoint];
    
    [_lineLayer pop_addAnimation:[self moveStartPointToCenter:center] forKey:@"startToCenter"];
    [_lineLayer pop_addAnimation:[self moveEndPointToCenter:center] forKey:@"endToCenter"];
    
    [_lineLayer pop_addAnimation:[self moveControlPoint1MidPointOffset:@(0.5)] forKey:@"C1MidCenter"];
    [_lineLayer pop_addAnimation:[self moveControlPoint2MidPointOffset:@(0.5)] forKey:@"C2MidCenter"];
    
//    CGFloat existing1Value = _lineLayer.controlPoint1Value;
//    CGFloat existing2Value = _lineLayer.controlPoint2Value;
    
    CGPoint originalMidPoint = MidPoint(_lineLayer.originalStartPoint, _lineLayer.originalEndPoint);
    CGPoint curveMidPoint = [_lineLayer curvePointAtPercentage:0.5];
    
    CGFloat curveDistance = PointDistanceFromPoint(originalMidPoint, curveMidPoint);
    
    // check into might have something to do with wobble factor

    
    [_lineLayer pop_addAnimation:[self moveControlPoint1Value:@(curveDistance)] forKey:@"c1Center"];
    [_lineLayer pop_addAnimation:[self moveControlPoint2Value:@(curveDistance)] forKey:@"c2Center"];


    
}

-(POPSpringAnimation*)moveStartPointToCenter:(CGPoint)center
{
    POPSpringAnimation *moveStartPointToCenterAnimation = [POPSpringAnimation animation];
    moveStartPointToCenterAnimation.property = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerStartPoint];
    moveStartPointToCenterAnimation.springBounciness = 9;
    moveStartPointToCenterAnimation.springSpeed = 1;
    moveStartPointToCenterAnimation.toValue = [NSValue valueWithCGPoint:center];
    moveStartPointToCenterAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
    };
    
    FBTweakBind(moveStartPointToCenterAnimation, autoreverses, @"[1] Center Animation", @"Start", @"AutoReverses",YES);
    FBTweakBind(moveStartPointToCenterAnimation, repeatForever, @"[1] Center Animation", @"Start", @"Repeat Forever",YES);
    
    FBTweakBind(moveStartPointToCenterAnimation, springBounciness, @"[1] Center Animation", @"Start", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveStartPointToCenterAnimation, springSpeed, @"[1] Center Animation", @"Start",@"Spring Speed",1.5,0.0,20.0);
    
    return moveStartPointToCenterAnimation;
}

-(POPSpringAnimation*)moveEndPointToCenter:(CGPoint)center
{
    POPSpringAnimation *moveEndPointToCenterAnimation = [POPSpringAnimation animation];
    moveEndPointToCenterAnimation.property = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerEndPoint];
    moveEndPointToCenterAnimation.springBounciness = 9;
    moveEndPointToCenterAnimation.springSpeed = 1;
    moveEndPointToCenterAnimation.toValue = [NSValue valueWithCGPoint:center];
    
    FBTweakBind(moveEndPointToCenterAnimation, autoreverses, @"[1] Center Animation", @"End", @"AutoReverses",YES);
    FBTweakBind(moveEndPointToCenterAnimation, repeatForever, @"[1] Center Animation", @"End", @"Repeat Forever",YES);
    
    FBTweakBind(moveEndPointToCenterAnimation, springBounciness, @"[1] Center Animation", @"End", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveEndPointToCenterAnimation, springSpeed, @"[1] Center Animation", @"End",@"Spring Speed",1.5,0.0,20.0);
    
    return moveEndPointToCenterAnimation;
}

-(POPSpringAnimation*)moveControlForCenter:(NSNumber*)value
{
    POPSpringAnimation *moveControlForCenterAnimation = [POPSpringAnimation animation];
    moveControlForCenterAnimation.property = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerControlValue];
    moveControlForCenterAnimation.springBounciness = 9;
    moveControlForCenterAnimation.springSpeed = 1;
    moveControlForCenterAnimation.toValue = value;
    
    FBTweakBind(moveControlForCenterAnimation, autoreverses, @"[1] Center Animation", @"Control", @"AutoReverses",YES);
    FBTweakBind(moveControlForCenterAnimation, repeatForever, @"[1] Center Animation", @"Control", @"Repeat Forever",YES);
    
    FBTweakBind(moveControlForCenterAnimation, springBounciness, @"[1] Center Animation", @"Control", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveControlForCenterAnimation, springSpeed, @"[1] Center Animation", @"Control",@"Spring Speed",1.5,0.0,20.0);
    
    return moveControlForCenterAnimation;
}









#pragma mark - Start

-(void)animateLineLayerToStart
{
    [_lineLayer pop_addAnimation:[self moveEndPointToStart] forKey:@"endToStart"];
    
    [_lineLayer pop_addAnimation:[self moveControlPoint1MidPointOffset:@(0.0)] forKey:@"c1MidToStart"];
    [_lineLayer pop_addAnimation:[self moveControlPoint2MidPointOffset:@(0.0)] forKey:@"c2MidToStart"];
    
    [_lineLayer pop_addAnimation:[self moveControlPoint1Value:@(0)] forKey:@"C1Start"];
    [_lineLayer pop_addAnimation:[self moveControlPoint2Value:@(0)] forKey:@"C2Start"];
    
}

-(POPSpringAnimation*)moveEndPointToStart
{
    POPSpringAnimation *moveEndPointToStartAnimation = [POPSpringAnimation animation];
    moveEndPointToStartAnimation.property = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerEndPoint];
    moveEndPointToStartAnimation.springBounciness = 9;
    moveEndPointToStartAnimation.springSpeed = 1;
    moveEndPointToStartAnimation.toValue = [NSValue valueWithCGPoint:_lineLayer.originalStartPoint];
    
    FBTweakBind(moveEndPointToStartAnimation, autoreverses, @"[2] Start Animation", @"End", @"AutoReverses",YES);
    FBTweakBind(moveEndPointToStartAnimation, repeatForever, @"[2] Start Animation", @"End", @"Repeat Forever",YES);
    
    FBTweakBind(moveEndPointToStartAnimation, springBounciness, @"[2] Start Animation", @"End", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveEndPointToStartAnimation, springSpeed, @"[2] Start Animation", @"End",@"Spring Speed",1.5,0.0,20.0);
    
    return moveEndPointToStartAnimation;
}











#pragma mark - End

-(void)animateLineLayerToEnd
{
    [_lineLayer pop_addAnimation:[self moveStartPointToEnd] forKey:@"endToEnd"];
    [_lineLayer pop_addAnimation:[self moveControlPoint1Value:@(0)] forKey:@"C1End"];
    [_lineLayer pop_addAnimation:[self moveControlPoint2Value:@(0)] forKey:@"C2End"];
    
    [_lineLayer pop_addAnimation:[self moveControlPoint1MidPointOffset:@(1.0)] forKey:@"C1MidEnd"];
    [_lineLayer pop_addAnimation:[self moveControlPoint2MidPointOffset:@(1.0)] forKey:@"C2MidEnd"];

    
}

-(POPSpringAnimation*)moveStartPointToEnd
{
    POPSpringAnimation *moveStartPointToEndAnimation = [POPSpringAnimation animation];
    moveStartPointToEndAnimation.property = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerStartPoint];
    moveStartPointToEndAnimation.springBounciness = 9;
    moveStartPointToEndAnimation.springSpeed = 1;
    moveStartPointToEndAnimation.toValue = [NSValue valueWithCGPoint:_lineLayer.originalEndPoint];
    
    FBTweakBind(moveStartPointToEndAnimation, autoreverses, @"[3] End Animation", @"Start", @"AutoReverses",YES);
    FBTweakBind(moveStartPointToEndAnimation, repeatForever, @"[3] End Animation", @"Start", @"Repeat Forever",YES);
    
    FBTweakBind(moveStartPointToEndAnimation, springBounciness, @"[3] End Animation", @"Start", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveStartPointToEndAnimation, springSpeed, @"[3] End Animation", @"Start",@"Spring Speed",1.5,0.0,20.0);
    
    return moveStartPointToEndAnimation;
}

//-(POPSpringAnimation*)moveEndPointToEnd
//{
//    POPSpringAnimation *moveEndPointToEndAnimation = [POPSpringAnimation animation];
//    moveEndPointToEndAnimation.property = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerEndPoint];
//    moveEndPointToEndAnimation.springBounciness = 9;
//    moveEndPointToEndAnimation.springSpeed = 1;
//    moveEndPointToEndAnimation.toValue = [NSValue valueWithCGPoint:_lineLayer.originalEndPoint];
//    
//    FBTweakBind(moveEndPointToEndAnimation, autoreverses, @"[3] End Animation", @"End", @"AutoReverses",YES);
//    FBTweakBind(moveEndPointToEndAnimation, repeatForever, @"[3] End Animation", @"End", @"Repeat Forever",YES);
//    
//    FBTweakBind(moveEndPointToEndAnimation, springBounciness, @"[3] End Animation", @"End", @"Spring Bounciness",9.5,0.0,20.0);
//    FBTweakBind(moveEndPointToEndAnimation, springSpeed, @"[3] End Animation", @"End",@"Spring Speed",1.5,0.0,20.0);
//    
//    return moveEndPointToEndAnimation;
//}










#pragma mark -  for Defaults

-(POPSpringAnimation*)moveStartPoint:(CGPoint)toPoint
{
     POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerStartPoint];
    
    NSValue *pointValue = [NSValue valueWithCGPoint:toPoint];
    
    POPSpringAnimation *moveStartPointAnimation = [POPSpringAnimation animation];
    moveStartPointAnimation.property = prop;
    moveStartPointAnimation.springBounciness = 9;
    moveStartPointAnimation.springSpeed = 1;
    moveStartPointAnimation.toValue = pointValue;

    FBTweakBind(moveStartPointAnimation, autoreverses, @"[0] Default Animation", @"Move Start Point", @"AutoReverses",YES);
    FBTweakBind(moveStartPointAnimation, repeatForever, @"[0] Default Animation", @"Move Start Point", @"Repeat Forever",YES);
    
    FBTweakBind(moveStartPointAnimation, springBounciness, @"[0] Default Animation", @"Move Start Point", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveStartPointAnimation, springSpeed, @"[0] Default Animation", @"Move Start Point",@"Spring Speed",1.5,0.0,20.0);
    
    return moveStartPointAnimation;
}

#pragma mark - Move End Point

-(POPSpringAnimation*)moveEndPoint:(CGPoint)toPoint
{
    POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerEndPoint];
    
    NSValue *pointValue = [NSValue valueWithCGPoint:toPoint];
    
    POPSpringAnimation *moveEndSpringAnimation = [POPSpringAnimation animation];
    moveEndSpringAnimation.property = prop;
    moveEndSpringAnimation.springBounciness = 9;
    moveEndSpringAnimation.springSpeed = 1;
    moveEndSpringAnimation.toValue = pointValue;
    
    FBTweakBind(moveEndSpringAnimation, autoreverses, @"[0] Default Animation", @"Move End Point", @"AutoReverses",YES);
    FBTweakBind(moveEndSpringAnimation, repeatForever, @"[0] Default Animation", @"Move End Point", @"Repeat Forever",YES);
    
    FBTweakBind(moveEndSpringAnimation, springBounciness, @"[0] Default Animation", @"Move End Point", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveEndSpringAnimation, springSpeed, @"[0] Default Animation", @"Move End Point",@"Spring Speed",1.5,0.0,20.0);
    
    return moveEndSpringAnimation;
}


#pragma mark - Animate Control Point MidPointOffset

-(POPSpringAnimation*)moveControlPoint1MidPointOffset:(NSNumber*)toValue
{
    POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerControlPoint1MidPointOffset];
    
    POPSpringAnimation *moveControlPoint1MidPointOffsetAnimation = [POPSpringAnimation animation];
    moveControlPoint1MidPointOffsetAnimation.property = prop;
    moveControlPoint1MidPointOffsetAnimation.springBounciness = 9;
    moveControlPoint1MidPointOffsetAnimation.springSpeed = 1;
    moveControlPoint1MidPointOffsetAnimation.toValue = toValue;
   
    
    FBTweakBind(moveControlPoint1MidPointOffsetAnimation, autoreverses, @"Control Point MidPoint Offset", @"C1", @"AutoReverses",NO);
    FBTweakBind(moveControlPoint1MidPointOffsetAnimation, repeatForever, @"Control Point MidPoint Offset", @"C1", @"Repeat Forever",NO);
    
    FBTweakBind(moveControlPoint1MidPointOffsetAnimation, springBounciness, @"Control Point MidPoint Offset", @"C1", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveControlPoint1MidPointOffsetAnimation, springSpeed, @"Control Point MidPoint Offset", @"C1",@"Spring Speed",1.5,0.0,20.0);
    
    return moveControlPoint1MidPointOffsetAnimation;
}

-(POPSpringAnimation*)moveControlPoint2MidPointOffset:(NSNumber*)toValue
{
    POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerControlPoint2MidPointOffset];
    
    POPSpringAnimation *moveControlPoint2MidPointOffsetAnimation = [POPSpringAnimation animation];
    moveControlPoint2MidPointOffsetAnimation.property = prop;
    moveControlPoint2MidPointOffsetAnimation.springBounciness = 9;
    moveControlPoint2MidPointOffsetAnimation.springSpeed = 1;
    moveControlPoint2MidPointOffsetAnimation.toValue = toValue;
    
    
    FBTweakBind(moveControlPoint2MidPointOffsetAnimation, autoreverses, @"Control Point MidPoint Offset", @"C2", @"AutoReverses",NO);
    FBTweakBind(moveControlPoint2MidPointOffsetAnimation, repeatForever, @"Control Point MidPoint Offset", @"C2", @"Repeat Forever",NO);
    
    FBTweakBind(moveControlPoint2MidPointOffsetAnimation, springBounciness, @"Control Point MidPoint Offset", @"C2", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveControlPoint2MidPointOffsetAnimation, springSpeed, @"Control Point MidPoint Offset", @"C2",@"Spring Speed",1.5,0.0,20.0);
    
    return moveControlPoint2MidPointOffsetAnimation;
}





#pragma mark - Move Control Point Values

-(POPSpringAnimation*)moveControlPoint1Value:(NSNumber*)toValue
{
    POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerControlPoint1Value];
    
    BOOL shouldBeOffset = FBTweakValue(@"Design", @"Offset (Horizontal)", @"Control Value 1 Offset",NO);
    
    CGFloat offsetFloat = (-1.0 * [toValue floatValue]);
    
    if (shouldBeOffset) {
        toValue = @(offsetFloat);
    }

    
    
    POPSpringAnimation *moveControlPoint1ValueAnimation = [POPSpringAnimation animation];
    moveControlPoint1ValueAnimation.property = prop;
    moveControlPoint1ValueAnimation.springBounciness = 9;
    moveControlPoint1ValueAnimation.springSpeed = 1;
    moveControlPoint1ValueAnimation.toValue = toValue;
    FBTweakBind(moveControlPoint1ValueAnimation, autoreverses, @"Move Control Points Animation", @"C1", @"AutoReverses",NO);
    FBTweakBind(moveControlPoint1ValueAnimation, repeatForever, @"Move Control Points Animation", @"C1", @"Repeat Forever",NO);
    
    FBTweakBind(moveControlPoint1ValueAnimation, springBounciness, @"Move Control Points Animation", @"C1", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveControlPoint1ValueAnimation, springSpeed, @"Move Control Points Animation", @"C1",@"Spring Speed",1.5,0.0,20.0);
    
    return moveControlPoint1ValueAnimation;
}

-(POPSpringAnimation*)moveControlPoint2Value:(NSNumber*)toValue
{
    POPAnimatableProperty *prop = [POPAnimatableProperty JDMLineLayerAnimatablePropertyWithName:kPOPJDMLineLayerControlPoint2Value];
    
    BOOL shouldBeOffset = FBTweakValue(@"Design", @"Offset (Horizontal)", @"Control Value 2 Offset",NO);
    
    CGFloat offsetFloat = (-1.0 * [toValue floatValue]);
    
    if (shouldBeOffset) {
        toValue = @(offsetFloat);
    }

    
    POPSpringAnimation *moveControlPoint2ValueAnimation = [POPSpringAnimation animation];
    moveControlPoint2ValueAnimation.property = prop;
    moveControlPoint2ValueAnimation.springBounciness = 9;
    moveControlPoint2ValueAnimation.springSpeed = 1;
    moveControlPoint2ValueAnimation.toValue = toValue;
    
    FBTweakBind(moveControlPoint2ValueAnimation, autoreverses, @"Move Control Points Animation", @"C2", @"AutoReverses",NO);
    FBTweakBind(moveControlPoint2ValueAnimation, repeatForever, @"Move Control Points Animation", @"C2", @"Repeat Forever",NO);
    
    FBTweakBind(moveControlPoint2ValueAnimation, springBounciness, @"Move Control Points Animation", @"C2", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(moveControlPoint2ValueAnimation, springSpeed, @"Move Control Points Animation", @"C2",@"Spring Speed",1.5,0.0,20.0);
    
    return moveControlPoint2ValueAnimation;
}





#pragma mark - Position
-(POPSpringAnimation*)springLineLayerToNewPosition:(CGPoint)newPosition
{
    NSValue *toValue = [NSValue valueWithCGPoint:newPosition];
    
    POPSpringAnimation *movePositionAnimation = [POPSpringAnimation animation];
    movePositionAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerPosition];
    movePositionAnimation.toValue = toValue;
    movePositionAnimation.springBounciness = 9;
    movePositionAnimation.springSpeed = 3;
    
    FBTweakBind(movePositionAnimation, autoreverses, @"Morph Animation", @"Position", @"AutoReverses",YES);
    FBTweakBind(movePositionAnimation, repeatForever, @"Morph Animation", @"Position", @"Repeat Forever",YES);
    
    FBTweakBind(movePositionAnimation, springBounciness, @"Morph Animation", @"Position", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(movePositionAnimation, springSpeed, @"Morph Animation", @"Position",@"Spring Speed",1.5,0.0,20.0);
    
    
    
    
    
    return movePositionAnimation;
}

#pragma mark - Bounds
-(POPSpringAnimation*)springLineLayerToNewBounds:(CGRect)newBounds
{
    NSValue *toValue = [NSValue valueWithCGRect:newBounds];
    
    POPSpringAnimation *newBoundsAnimation = [POPSpringAnimation animation];
    newBoundsAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerBounds];
    newBoundsAnimation.toValue = toValue;
    newBoundsAnimation.springBounciness = 9;
    newBoundsAnimation.springSpeed = 3;
    newBoundsAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [self updatePathForLineShapeLayer];
        }
        
        
    };

    
    FBTweakBind(newBoundsAnimation, autoreverses, @"Morph Animation", @"Bounds", @"AutoReverses",YES);
    FBTweakBind(newBoundsAnimation, repeatForever, @"Morph Animation", @"Bounds", @"Repeat Forever",YES);
    
    FBTweakBind(newBoundsAnimation, springBounciness, @"Morph Animation", @"Bounds", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(newBoundsAnimation, springSpeed, @"Morph Animation", @"Bounds",@"Spring Speed",1.5,0.0,20.0);
    
    
    return newBoundsAnimation;
}






#pragma mark - CASpringAnimation

-(CASpringAnimation*)caspringJDMLineControlValue:(CGPoint)toPoint
{
    NSValue *toValue = [NSValue valueWithCGPoint:toPoint];
    
    _baseLayer.position = toPoint;
    
    CASpringAnimation *springAnimation = [CASpringAnimation animation];
    springAnimation.keyPath = @"position";
    springAnimation.toValue = toValue;
    springAnimation.mass = 1.0;
    springAnimation.stiffness = 1.0;
    springAnimation.damping = 0.5;
    springAnimation.initialVelocity = 0;
    
    
//    FBTweakBind(springAnimation, mass, @"Spring Animation", @"Position", @"Mass",1.0,1.0,500.0);
//    FBTweakBind(springAnimation, stiffness, @"Spring Animation", @"Position", @"Stiffness",100.0,1.0,500.0);
//    FBTweakBind(springAnimation, damping, @"Spring Animation", @"Position", @"Damping",10.0,1.0,500.0);
//    FBTweakBind(springAnimation, initialVelocity, @"Spring Animation", @"Position", @"InitialVelocity",0,0,500.0);
    
    
    
    
    return springAnimation;
}


// super impose a bezierPath ontop of the _lineLayer one to do the fill animation, then swap back

// create CAShapeLayer, add it to the view, but hide it, then reveal when needed

-(CAShapeLayer*)makeStrokeShapeLayer
{
    UIBezierPath *lineLayerPath = [self makePathFromLineLayer];
    
    //  CGRect largerBounds = CGRectMake(0, 0, _lineLayer.bounds.size.width+(0.5*_lineLayer.bounds.size.width),  _lineLayer.bounds.size.height+(0.5*_lineLayer.bounds.size.height));
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.name = @"STROKE_SHAPE_LAYER";
    shapeLayer.lineWidth = _lineLayer.strokeWidth;
    shapeLayer.strokeColor = _lineLayer.strokeColor.CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.position =  _lineLayer.position;
    shapeLayer.bounds = _lineLayer.bounds;
    shapeLayer.path = lineLayerPath.CGPath;
    shapeLayer.lineCap = kCALineCapRound;
    
    [_replicatorLayer addSublayer:shapeLayer];

    return shapeLayer;
    
}


-(UIBezierPath*)makePathFromLineLayer
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:[[[_lineLayer curvePoints] firstObject] CGPointValue]];
    [path addCurveToPoint:[[[_lineLayer curvePoints] lastObject] CGPointValue] controlPoint1:[[[_lineLayer curvePoints] objectAtIndex:1] CGPointValue] controlPoint2:[[[_lineLayer curvePoints] objectAtIndex:2] CGPointValue]];
    return path;
}


-(void)actionPartForStrokeAnimation
{
    _lineShapeLayer = [self makeStrokeShapeLayer];
    
}

#pragma mark - Function of the Trick 

-(void)swapLineShapeLayerIn
{
    _lineShapeLayer = [self makeStrokeShapeLayer];
    _lineLayer.opacity = 0.0;
}

-(void)swapLineShapeLayerOut
{
    NSLog(@"Swapping out");
    _lineShapeLayer.opacity = 0;
    _lineLayer.opacity = 1.0;

}



-(void)updatePathForLineShapeLayer
{
    CGRect largerBounds = CGRectMake(0, 0, _lineLayer.bounds.size.width+(0.5*_lineLayer.bounds.size.width),  _lineLayer.bounds.size.height+(0.5*_lineLayer.bounds.size.height));
    
    _lineShapeLayer.path = [self makePathFromLineLayer].CGPath;
    _lineShapeLayer.bounds = largerBounds; //_lineLayer.bounds;
    _lineShapeLayer.position = _lineLayer.position;
}

-(void)strokeLineShapeAnimationTo:(NSNumber*)toValue
{
    CGFloat endValue = 1.0 - [toValue floatValue];
    
    [_lineShapeLayer pop_addAnimation:[self strokeStartTo:toValue] forKey:@"strokeStart"];
    [_lineShapeLayer pop_addAnimation:[self strokeEndTo:@(endValue)] forKey:@"strokeEnd"];
}

-(void)returnStrokeOfLineShapeLayer
{
    [_lineShapeLayer pop_addAnimation:[self returnStrokeStart] forKey:@"returnStrokeStart"];
    [_lineShapeLayer pop_addAnimation:[self returnStrokeEnd] forKey:@"returnStrokeEnd"];

}


#pragma mark - POP Stroke Animation

-(POPSpringAnimation*)strokeStartTo:(NSNumber*)toValue
{
    POPSpringAnimation *strokeStartToAnimation = [POPSpringAnimation animation];
    strokeStartToAnimation.property = [POPAnimatableProperty propertyWithName:kPOPShapeLayerStrokeStart];
    strokeStartToAnimation.toValue = toValue;
    strokeStartToAnimation.springBounciness = 9;
    strokeStartToAnimation.springSpeed = 3;
    
    FBTweakBind(strokeStartToAnimation, autoreverses, @"Stroke", @"Start", @"AutoReverses",NO);
    FBTweakBind(strokeStartToAnimation, repeatForever, @"Stroke", @"Start", @"Repeat Forever",NO);
    FBTweakBind(strokeStartToAnimation, springBounciness, @"Stroke", @"Start", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(strokeStartToAnimation, springSpeed, @"Stroke", @"Start",@"Spring Speed",1.5,0.0,20.0);
    
    return strokeStartToAnimation;
}


-(POPSpringAnimation*)strokeEndTo:(NSNumber*)toValue
{
    POPSpringAnimation *strokeEndToAnimation = [POPSpringAnimation animation];
    strokeEndToAnimation.property = [POPAnimatableProperty propertyWithName:kPOPShapeLayerStrokeEnd];
    strokeEndToAnimation.toValue = toValue;
    strokeEndToAnimation.springBounciness = 9;
    strokeEndToAnimation.springSpeed = 3;
    
    FBTweakBind(strokeEndToAnimation, autoreverses, @"Stroke", @"End", @"AutoReverses",NO);
    FBTweakBind(strokeEndToAnimation, repeatForever, @"Stroke", @"End", @"Repeat Forever",NO);
    FBTweakBind(strokeEndToAnimation, springBounciness, @"Stroke", @"End", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(strokeEndToAnimation, springSpeed, @"Stroke", @"End",@"Spring Speed",1.5,0.0,20.0);
    
    return strokeEndToAnimation;
}

-(POPSpringAnimation*)returnStrokeStart
{
    POPSpringAnimation *returnStrokeStartAnimation = [POPSpringAnimation animation];
    returnStrokeStartAnimation.property = [POPAnimatableProperty propertyWithName:kPOPShapeLayerStrokeStart];
    returnStrokeStartAnimation.toValue = @(0);
    returnStrokeStartAnimation.springBounciness = 9;
    returnStrokeStartAnimation.springSpeed = 3;
    returnStrokeStartAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
             [self swapLineShapeLayerOut];
        }
    };

    
    FBTweakBind(returnStrokeStartAnimation, autoreverses, @"Stroke", @"Return Start", @"AutoReverses",NO);
    FBTweakBind(returnStrokeStartAnimation, repeatForever, @"Stroke", @"Return Start", @"Repeat Forever",NO);
    FBTweakBind(returnStrokeStartAnimation, springBounciness, @"Stroke", @"Return Start", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(returnStrokeStartAnimation, springSpeed, @"Stroke", @"Return Start",@"Spring Speed",1.5,0.0,20.0);
    
    return returnStrokeStartAnimation;
}

-(POPSpringAnimation*)returnStrokeEnd
{
    POPSpringAnimation *returnStrokeEndAnimation = [POPSpringAnimation animation];
    returnStrokeEndAnimation.property = [POPAnimatableProperty propertyWithName:kPOPShapeLayerStrokeEnd];
    returnStrokeEndAnimation.toValue = @(1.0);
    returnStrokeEndAnimation.springBounciness = 9;
    returnStrokeEndAnimation.springSpeed = 3;
    
    FBTweakBind(returnStrokeEndAnimation, autoreverses, @"Stroke", @"Return End", @"AutoReverses",NO);
    FBTweakBind(returnStrokeEndAnimation, repeatForever, @"Stroke", @"Return End", @"Repeat Forever",NO);
    FBTweakBind(returnStrokeEndAnimation, springBounciness, @"Stroke", @"Return End", @"Spring Bounciness",9.5,0.0,20.0);
    FBTweakBind(returnStrokeEndAnimation, springSpeed, @"Stroke", @"Return End",@"Spring Speed",1.5,0.0,20.0);
    
    return returnStrokeEndAnimation;
}






#pragma mark - New Animation 




- (void)controlPointAnimation
{
    //self.controlPointOfLine = 0;
    
    CGFloat controlPointOfLine = 0;
    
    CAShapeLayer *shape;
    POPSpringAnimation *pathSpringAnimation;
    
    
    
    CGFloat height = 300.f;
    UIBezierPath *bendiPath = [UIBezierPath bezierPath];
    
//    [bendiPath moveToPoint:CGPointMake(0, 0)];
//    [bendiPath addCurveToPoint:CGPointMake(0, height) controlPoint1:CGPointMake(0, height * 0.5) controlPoint2:CGPointMake(0, height * 0.5)];
    
    shape = [CAShapeLayer layer];
    shape.path = bendiPath.CGPath;
    shape.strokeColor = [UIColor blackColor].CGColor;
    shape.lineWidth = 10.f;
    shape.fillColor = nil;
    shape.position =CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
    [self.view.layer addSublayer:shape];
    
    //    return;
   POPAnimatableProperty *customPathChangingProperty = [POPAnimatableProperty propertyWithName:@"controlPointOfLine" initializer:^(POPMutableAnimatableProperty *prop) {
        // read value
        prop.readBlock = ^(JDMLineLayer *obj, CGFloat values[]) {
            values[0] = controlPointOfLine;
        };
        // write value
        prop.writeBlock = ^(JDMLineLayer *obj, const CGFloat values[]) {
            obj.controlValue = values[0];
            // update bezier
            [bendiPath removeAllPoints];
            [bendiPath moveToPoint:obj.originalStartPoint];
            [bendiPath addCurveToPoint:obj.originalEndPoint controlPoint1:[obj findControl1Point] controlPoint2:[obj findControl2Point]];
            
//            [label setText:[NSString stringWithFormat:@"%f", obj.controlPointOfLine]];
//            [label sizeToFit];
//            label.layer.position = self.view.center;
            shape.path = bendiPath.CGPath;
        };
        // dynamics threshold
        prop.threshold = 0.1;
    }];
    
    pathSpringAnimation = [POPSpringAnimation animation];
    pathSpringAnimation.name = @"PATHPOP";
    pathSpringAnimation.fromValue = @(-50.0);
    pathSpringAnimation.toValue =  @(0.f);
    pathSpringAnimation.springBounciness = 30.1;
    pathSpringAnimation.springSpeed = 10.4;
    pathSpringAnimation.dynamicsTension = 2000;
    pathSpringAnimation.property = customPathChangingProperty;
    [_lineLayer pop_addAnimation:pathSpringAnimation forKey:nil];
}





-(void)setupForBox
{
    _baseLayer = [self boxLayer];
}


-(CALayer*)boxLayer
{
    CALayer *boxLayer = [CALayer layer];
    boxLayer.backgroundColor = [UIColor blueColor].CGColor;
    boxLayer.frame = CGRectMake(0, 0, ScreenWidth()/2, ScreenWidth()/2);
    boxLayer.position = RectGetCenter(self.view.frame);
    
    
    [self.view.layer addSublayer:boxLayer];
    
    return boxLayer;
    
}





#pragma mark - POPDELEGATE

-(void)pop_animationDidStart:(POPAnimation *)anim
{
    NSLog(@"animation did start");
    _animationTypeLabel.textColor = [self deviceColor];
}


-(void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    _animationTypeLabel.textColor = [UIColor blackColor];
}




@end
