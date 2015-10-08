//
//  POPAnimatableProperty+JDMLineLayer.m
//  CASpringTheory
//
//  Created by Justin Madewell on 9/24/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "POPAnimatableProperty+JDMLineLayer.h"
#import "JDMLineLayer.h"

static CGFloat const kPOPJDMLineLayerThreshold = 1.0;

NSString * const kPOPJDMLineLayerStartPoint = @"startPoint";
NSString * const kPOPJDMLineLayerEndPoint = @"endPoint";
NSString * const kPOPJDMLineLayerControlValue = @"controlValue";



NSString * const kPOPJDMLineLayerControlPoint1Value = @"controlPoint1Value";
NSString * const kPOPJDMLineLayerControlPoint2Value = @"controlPoint2Value";


NSString * const kPOPJDMLineLayerControlPoint1MidPointOffset = @"controlPoint1MidPointOffset";
NSString * const kPOPJDMLineLayerControlPoint2MidPointOffset = @"controlPoint2MidPointOffset";








@implementation POPAnimatableProperty (JDMLineLayer)

+ (NSArray *)JDMLineLayerAnimatableProperties
{
    static NSArray *props;
    
    if(props == nil)
    {
        props = @[
                  
                  [POPAnimatableProperty propertyWithName:kPOPJDMLineLayerStartPoint initializer:^(POPMutableAnimatableProperty *prop) {
                      prop.readBlock = ^(JDMLineLayer *obj, CGFloat values[]) {
                          values[0] = obj.startPoint.x;
                          values[1] = obj.startPoint.y;
                      };
                      prop.writeBlock = ^(JDMLineLayer *obj, const CGFloat values[]) {
                          CGFloat currentX =  obj.startPoint.x;
                          CGFloat currentY = obj.startPoint.y;
                          currentX = values[0];
                          currentY = values[1];
                          obj.startPoint = CGPointMake(currentX, currentY);
                      };
                      prop.threshold = kPOPJDMLineLayerThreshold;
                  }],
                  
                  [POPAnimatableProperty propertyWithName:kPOPJDMLineLayerEndPoint initializer:^(POPMutableAnimatableProperty *prop) {
                      prop.readBlock = ^(JDMLineLayer *obj, CGFloat values[]) {
                          values[0] = obj.endPoint.x;
                          values[1] = obj.endPoint.y;
                      };
                      prop.writeBlock = ^(JDMLineLayer *obj, const CGFloat values[]) {
                          CGFloat currentX =  obj.endPoint.x;
                          CGFloat currentY = obj.endPoint.y;
                          currentX = values[0];
                          currentY = values[1];
                          obj.endPoint = CGPointMake(currentX, currentY);
                      };
                      prop.threshold = kPOPJDMLineLayerThreshold;
                  }],
                  
                  [POPAnimatableProperty propertyWithName:kPOPJDMLineLayerControlValue initializer:^(POPMutableAnimatableProperty *prop) {
                      prop.readBlock = ^(JDMLineLayer *obj, CGFloat values[]) {
                          values[0] = obj.controlValue;
                      };
                      prop.writeBlock = ^(JDMLineLayer *obj, const CGFloat values[]) {
                          CGFloat current =  obj.controlValue;
                          current =  values[0];
                          obj.controlValue = current;
                      };
                      prop.threshold = kPOPJDMLineLayerThreshold;
                  }],

                  [POPAnimatableProperty propertyWithName:kPOPJDMLineLayerControlPoint1Value initializer:^(POPMutableAnimatableProperty *prop) {
                      prop.readBlock = ^(JDMLineLayer *obj, CGFloat values[]) {
                          values[0] = obj.controlPoint1Value;
                      };
                      prop.writeBlock = ^(JDMLineLayer *obj, const CGFloat values[]) {
                          CGFloat current =  obj.controlPoint1Value;
                          current =  values[0];
                          obj.controlPoint1Value = current;
                      };
                      prop.threshold = kPOPJDMLineLayerThreshold;
                  }],

                  [POPAnimatableProperty propertyWithName:kPOPJDMLineLayerControlPoint2Value initializer:^(POPMutableAnimatableProperty *prop) {
                      prop.readBlock = ^(JDMLineLayer *obj, CGFloat values[]) {
                          values[0] = obj.controlPoint2Value;
                      };
                      prop.writeBlock = ^(JDMLineLayer *obj, const CGFloat values[]) {
                          CGFloat current =  obj.controlPoint2Value;
                          current =  values[0];
                          obj.controlPoint2Value = current;
                      };
                      prop.threshold = kPOPJDMLineLayerThreshold;
                  }],
                  
                  [POPAnimatableProperty propertyWithName:kPOPJDMLineLayerControlPoint1MidPointOffset initializer:^(POPMutableAnimatableProperty *prop) {
                      prop.readBlock = ^(JDMLineLayer *obj, CGFloat values[]) {
                          values[0] = obj.controlPoint1MidPointOffset;
                      };
                      prop.writeBlock = ^(JDMLineLayer *obj, const CGFloat values[]) {
                          CGFloat current =  obj.controlPoint1MidPointOffset;
                          current =  values[0];
                          obj.controlPoint1MidPointOffset = current;
                      };
                      prop.threshold = kPOPJDMLineLayerThreshold;
                  }],
                  
                  [POPAnimatableProperty propertyWithName:kPOPJDMLineLayerControlPoint2MidPointOffset initializer:^(POPMutableAnimatableProperty *prop) {
                      prop.readBlock = ^(JDMLineLayer *obj, CGFloat values[]) {
                          values[0] = obj.controlPoint2MidPointOffset;
                      };
                      prop.writeBlock = ^(JDMLineLayer *obj, const CGFloat values[]) {
                          CGFloat current =  obj.controlPoint2MidPointOffset;
                          current =  values[0];
                          obj.controlPoint2MidPointOffset = current;
                      };
                      prop.threshold = kPOPJDMLineLayerThreshold;
                  }],

                  
                  
                  
                  
                  
                  
                  ];
    }
    
    return props;
}

+(instancetype)JDMLineLayerAnimatablePropertyWithName:(NSString *)aName
{
    NSArray *props = [self JDMLineLayerAnimatableProperties];
    
    for(POPAnimatableProperty *prop in props)
    {
        if([prop.name isEqualToString:aName])
        {
            return prop;
        }
    }
    
    return nil;
    
}


@end
