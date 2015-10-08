//
//  POPAnimatableProperty+JDMLineLayer.h
//  CASpringTheory
//
//  Created by Justin Madewell on 9/24/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "POPAnimatableProperty.h"
#import "pop.h"
@import Foundation;

extern NSString * const kPOPJDMLineLayerStartPoint;
extern NSString * const kPOPJDMLineLayerEndPoint;
extern NSString * const kPOPJDMLineLayerControlValue;

extern NSString * const kPOPJDMLineLayerControlPoint1MidPointOffset;
extern NSString * const kPOPJDMLineLayerControlPoint1Value;

extern NSString * const kPOPJDMLineLayerControlPoint2MidPointOffset;
extern NSString * const kPOPJDMLineLayerControlPoint2Value;



@interface POPAnimatableProperty (JDMLineLayer)

+ (instancetype)JDMLineLayerAnimatablePropertyWithName:(NSString *)aName;

@end
