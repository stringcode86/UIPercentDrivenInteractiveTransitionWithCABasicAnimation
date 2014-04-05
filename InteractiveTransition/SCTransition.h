//
//  SCTransition.h
//  InteractiveTransition
//
//  Created by Michal Inger on 04/04/2014.
//  Copyright (c) 2014 StringCode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SCCardTranstionDirection) {
    kSCCardTransitionForwards,
    kSCCardTransitionBackwards,
};


// Swith between pure Core animation (YES) based animations
// and UIView (NO) block based animations.
// UView animations are animated smothly at the end of interective
// transition. CA animations arent WHY ?! and how to make them animate smoothly


#define USECA NO

@interface SCTransition : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property (nonatomic) SCCardTranstionDirection transitionDirection;

@property (nonatomic) BOOL shouldBeginInteractiveTransition;

- (void)handleGesture:(UIScreenEdgePanGestureRecognizer *)recognizer;

@end
