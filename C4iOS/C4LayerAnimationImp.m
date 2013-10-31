//
//  C4LayerAnimationImp.m
//  C4iOS
//
//  Created by travis on 2013-10-31.
//  Copyright (c) 2013 Slant. All rights reserved.
//

#import "C4LayerAnimationImp.h"

/*
 The C4LayerAnimation protocol requires some private properties
 Here, we list the private properties.
 These need to be manually copied into each new class that conforms to C4LayerAnimation.
 It's a pain, but this small conformance allows for a significantly lighter code-base.
 */
@interface C4LayerAnimationImp ()
@property (nonatomic) CGFloat rotationAngle, rotationAngleX, rotationAngleY;
@end

static C4LayerAnimationImp *sharedC4LayerAnimationImp = nil;

@implementation C4LayerAnimationImp
/*
 The C4LayerAnimation protocol requires the synthesis of some public properties.
 Here we list the private properties that need to be synthesized.
 These synths need to be manually copied into each class that conforms to C4LayerAnimation.
 It's a pain, but this small conformance allows for a significantly lighter code-base.
 */
@synthesize animationOptions = _animationOptions, currentAnimationEasing = _currentAnimationEasing,
repeatCount = _repeatCount, animationDuration = _animationDuration,
allowsInteraction = _allowsInteraction, repeats = _repeats;
@synthesize perspectiveDistance = _perspectiveDistance;

//This class is a singleton, we will only ever need to call one version of it
+(C4LayerAnimationImp *)sharedManager {
    if (sharedC4LayerAnimationImp == nil) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ { sharedC4LayerAnimationImp = [[super allocWithZone:NULL] init];
        });
    }
    return sharedC4LayerAnimationImp;
}

//This method should only ever be copied by another class
//The other class will then run this method
//This method should never be run by the class itself
+(void)copyMethods {
    //get a count of the number of methods in this class
    unsigned int methodListCount;
    //get the list of methods
    Method *methodList = class_copyMethodList([C4LayerAnimationImp class], &methodListCount);
    //cycle through all the methods in the list
    for(int i = 0; i < methodListCount; i ++) {
        //grab the current method
        Method m = methodList[i];
        //get the method's name
        SEL name = method_getName(m);
        //get the method's implementation
        IMP implementation = method_getImplementation(m);
        //get the method's types
        const char *types = method_getTypeEncoding(m);
        //convert the name to a string
        NSString *selectorName = NSStringFromSelector(method_getName(m));
        //check the selector name
        if(![selectorName isEqualToString:@".cxx_destruct"]) {
            //if the selector name is NOT .cxx_destruct
            //replace the implmentation of the method m in the current class
            //with the current method's implementation
            class_replaceMethod([self class], name, implementation, types);
        }
    }
}

#pragma mark C4Layer Animation Methods
-(CABasicAnimation *)setupBasicAnimationWithKeyPath:(NSString *)keyPath {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.duration = self.animationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:self.currentAnimationEasing];
    animation.autoreverses = self.autoreverses;
    animation.repeatCount = self.repeats ? FOREVER : 0;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    return animation;
}

-(CGFloat)animationDuration {
    return _animationDuration + 0.0001f;
}

-(void)setAnimationOptions:(NSUInteger)animationOptions {
    if((animationOptions & LINEAR) == LINEAR) {
        _currentAnimationEasing = kCAMediaTimingFunctionLinear;
    } else if((animationOptions & EASEOUT) == EASEOUT) {
        _currentAnimationEasing = kCAMediaTimingFunctionEaseOut;
    } else if((animationOptions & EASEIN) == EASEIN) {
        _currentAnimationEasing = kCAMediaTimingFunctionEaseIn;
    } else if((animationOptions & EASEINOUT) == EASEINOUT) {
        _currentAnimationEasing = kCAMediaTimingFunctionEaseInEaseOut;
    } else {
        _currentAnimationEasing = kCAMediaTimingFunctionDefault;
    }
    
    if((animationOptions & AUTOREVERSE) == AUTOREVERSE) self.autoreverses = YES;
    else self.autoreverses = NO;
    
    if((animationOptions & REPEAT) == REPEAT) _repeats = YES;
    else _repeats = NO;
    
    if((animationOptions & ALLOWSINTERACTION) == ALLOWSINTERACTION) _allowsInteraction = YES;
    else _allowsInteraction = NO;
}

-(void)setPerspectiveDistance:(CGFloat)perspectiveDistance {
    _perspectiveDistance = perspectiveDistance;
    CATransform3D t = self.transform;
    if(perspectiveDistance != 0.0f) t.m34 = 1/self.perspectiveDistance;
    else t.m34 = 0.0f;
    self.transform = t;
}

-(void)animateBackgroundColor:(CGColorRef)_backgroundColor {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"backgroundColor"];
    animation.fromValue = (id)self.backgroundColor;
    animation.toValue = (__bridge id)_backgroundColor;
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.backgroundColor = _backgroundColor;
            [self removeAnimationForKey:@"animateBackgroundColor"];
        }];
    }
    [self addAnimation:animation forKey:@"animateBackgroundColor"];
    [CATransaction commit];
}

-(void)animateBorderColor:(CGColorRef)_borderColor {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"borderColor"];
    animation.fromValue = (id)self.borderColor;
    animation.toValue = (__bridge id)_borderColor;
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.borderColor = _borderColor;
            [self removeAnimationForKey:@"animateBorderColor"];
        }];
    }
    [self addAnimation:animation forKey:@"animateBorderColor"];
    [CATransaction commit];
}

-(void)animateBackgroundFilters:(NSArray *)_backgroundFilters {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"backgroundFilters"];
    animation.fromValue = self.backgroundFilters;
    animation.toValue = _backgroundFilters;
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.backgroundFilters = _backgroundFilters;
            [self removeAnimationForKey:@"animateBackgroundFilters"];
        }];
    }
    [self addAnimation:animation forKey:@"animateBackgroundFilters"];
    [CATransaction commit];
}

-(void)animateBorderWidth:(CGFloat)_borderWidth {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"borderWidth"];
    animation.fromValue = @(self.borderWidth);
    animation.toValue = @(_borderWidth);
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.borderWidth = _borderWidth;
            [self removeAnimationForKey:@"animateBorderWidth"];
        }];
    }
    [self addAnimation:animation forKey:@"animateBorderWidth"];
    [CATransaction commit];
}

-(void)animateCompositingFilter:(id)_compositingFilter {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"compositingFilter"];
    animation.fromValue = self.compositingFilter;
    animation.toValue = _compositingFilter;
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.compositingFilter = _compositingFilter;
            [self removeAnimationForKey:@"animateCompositingFilter"];
        }];
    }
    [self addAnimation:animation forKey:@"animateCompositingFilter"];
    [CATransaction commit];
}

-(void)animateContents:(CGImageRef)_image {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"contents"];
    animation.fromValue = self.contents;
    animation.toValue = (__bridge id)_image;
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.contents = (__bridge id)_image;
            [self removeAnimationForKey:@"animateContents"];
        }];
    }
    [self addAnimation:animation forKey:@"animateContents"];
    [CATransaction commit];
}

-(void)animateCornerRadius:(CGFloat)_cornerRadius {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"cornerRadius"];
    animation.fromValue = @(self.cornerRadius);
    animation.toValue = @(_cornerRadius);
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.cornerRadius = _cornerRadius;
            [self removeAnimationForKey:@"animateCornerRadius"];
        }];
    }
    [self addAnimation:animation forKey:@"animateCornerRadius"];
    [CATransaction commit];
}

-(void)animateLayerTransform:(CATransform3D)newTransform {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"sublayerTransform"];
    animation.fromValue = [NSValue valueWithCATransform3D:self.sublayerTransform];
    animation.toValue = [NSValue valueWithCATransform3D:newTransform];
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.sublayerTransform = newTransform;
            [self removeAnimationForKey:@"sublayerTransform"];
        }];
    }
    [self addAnimation:animation forKey:@"sublayerTransform"];
    [CATransaction commit];
}

-(void)animateRotation:(CGFloat)newRotationAngle {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(self.rotationAngle);
    animation.toValue = @(newRotationAngle);
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.rotationAngle = newRotationAngle;
            [self.delegate rotationDidFinish:newRotationAngle];
            [self removeAnimationForKey:@"animateRotationZ"];
        }];
    }
    [self addAnimation:animation forKey:@"animateRotationZ"];
    [CATransaction commit];
}

-(void)animateRotationX:(CGFloat)newRotationAngle {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"transform.rotation.x"];
    animation.fromValue = @(self.rotationAngleX);
    animation.toValue = @(newRotationAngle);
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.transform = CATransform3DRotate(self.transform,
                                                 newRotationAngle - self.rotationAngleX,
                                                 1,
                                                 0,
                                                 0);
            self.rotationAngleX = newRotationAngle;
            [self removeAnimationForKey:@"animateRotationX"];
        }];
    }
    [self addAnimation:animation forKey:@"animateRotationX"];
    [CATransaction commit];
}

-(void)animateRotationY:(CGFloat)newRotationAngle {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"transform.rotation.y"];
    animation.fromValue = @(self.rotationAngleY);
    animation.toValue = @(newRotationAngle);
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.transform =    CATransform3DRotate(self.transform,
                                                    newRotationAngle - self.rotationAngleY,
                                                    0,
                                                    1,
                                                    0);
            self.rotationAngleY = newRotationAngle;
            [self removeAnimationForKey:@"animateRotationY"];
        }];
    }
    [self addAnimation:animation forKey:@"animateRotationY"];
    [CATransaction commit];
}

-(void)animateShadowColor:(CGColorRef)_shadowColor {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"shadowColor"];
    animation.fromValue = (id)self.shadowColor;
    animation.toValue = (__bridge id)_shadowColor;
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.shadowColor = _shadowColor;
            [self removeAnimationForKey:@"animateShadowColor"];
        }];
    }
    [self addAnimation:animation forKey:@"animateShadowColor"];
    [CATransaction commit];
}

-(void)animateShadowOffset:(CGSize)_shadowOffset {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"shadowOffset"];
    animation.fromValue = [NSValue valueWithCGSize:self.shadowOffset];
    animation.toValue = [NSValue valueWithCGSize:_shadowOffset];
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.shadowOffset = _shadowOffset;
            [self removeAnimationForKey:@"animateShadowOffset"];
        }];
    }
    [self addAnimation:animation forKey:@"animateShadowOffset"];
    [CATransaction commit];
}

-(void)animateShadowOpacity:(CGFloat)_shadowOpacity {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"shadowOpacity"];
    animation.fromValue = @(self.shadowOpacity);
    animation.toValue = @(_shadowOpacity);
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.shadowOpacity = _shadowOpacity;
            [self removeAnimationForKey:@"animateShadowOpacity"];
        }];
    }
    [self addAnimation:animation forKey:@"animateShadowOpacity"];
    [CATransaction commit];
}

-(void)animateShadowPath:(CGPathRef)_shadowPath {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"shadowPath"];
    animation.fromValue = (id)self.shadowPath;
    animation.toValue = (__bridge id)_shadowPath;
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.shadowPath = _shadowPath;
            [self removeAnimationForKey:@"animateShadowPath"];
        }];
    }
    [self addAnimation:animation forKey:@"animateShadowPath"];
    [CATransaction commit];
}

-(void)animateShadowRadius:(CGFloat)_shadowRadius {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"shadowRadius"];
    animation.fromValue = @(self.shadowRadius);
    animation.toValue = @(_shadowRadius);
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.shadowRadius = _shadowRadius;
            [self removeAnimationForKey:@"animateShadowRadius"];
        }];
    }
    [self addAnimation:animation forKey:@"animateShadowRadius"];
    [CATransaction commit];
}

-(void)animateZPosition:(CGFloat)_zPosition {
    [CATransaction begin];
    CABasicAnimation *animation = [self setupBasicAnimationWithKeyPath:@"zPosition"];
    animation.fromValue = @(self.zPosition);
    animation.toValue = @(_zPosition);
    if (animation.repeatCount != FOREVER && !self.autoreverses) {
        [CATransaction setCompletionBlock:^ {
            self.zPosition = _zPosition;
            [self removeAnimationForKey:@"animateZPosition"];
        }];
    }
    [self addAnimation:animation forKey:@"animateZPosition"];
    [CATransaction commit];
}

@end
