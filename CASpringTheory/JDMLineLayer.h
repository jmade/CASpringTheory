//
//  JDMLineLayer.h
//  CASpringTheory
//
//  Created by Justin Madewell on 9/24/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>

@import CoreGraphics;

@import QuartzCore;

@import UIKit;
#import "JDMUtility.h"
#import "POPAnimatableProperty+JDMLineLayer.h"

static NSString* kStartPoint = @"startPoint";
static NSString* kEndPoint = @"endPoint";
static NSString* kControlValue = @"controlValue";

static NSString* kControlPoint1Value = @"controlPoint1Value";
static NSString* kControlPoint2Value = @"controlPoint2Value";

static NSString* kControlPoint1MidPointOffset = @"controlPoint1MidPointOffset";
static NSString* kControlPoint2MidPointOffset = @"controlPoint2MidPointOffset";



@interface JDMLineLayer : CALayer

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGFloat controlValue;

@property (nonatomic) CGPoint originalStartPoint;
@property (nonatomic) CGPoint originalEndPoint;

@property int shapePointCount;

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;


// NEW
@property (nonatomic) CGFloat controlPoint1Value;
@property (nonatomic) CGFloat controlPoint2Value;

@property (nonatomic) CGFloat wobbleAmount;
@property (nonatomic) CGFloat wobbleAnimationAmount;

@property (nonatomic) CGFloat controlPoint1MidPointOffset;
@property (nonatomic) CGFloat controlPoint2MidPointOffset;

@property (nonatomic) CGFloat originalControlPoint1MidPointOffset;
@property (nonatomic) CGFloat originalControlPoint2MidPointOffset;



-(CGPoint)findControl1Point;
-(CGPoint)findControl2Point;

-(NSArray*)curvePoints;


-(CGPoint)curvePointAtPercentage:(CGFloat)percentage;

-(CGPoint)calculateCenterPoint;

@end
