//
//  SCTransition.m
//  InteractiveTransition
//
//  Created by Michal Inger on 04/04/2014.
//  Copyright (c) 2014 StringCode Ltd. All rights reserved.
//

#import "SCTransition.h"


@interface SCTransition ()
@end

@implementation SCTransition {
    __weak id <UIViewControllerContextTransitioning> _transitionContext;
    CGFloat _pausedTime;
    BOOL _wasCanceled;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.transitionDirection == kSCCardTransitionForwards) {
        UIView *view = [fromViewController valueForKeyPath:@"squareView"];
        
        void(^block)() = ^{
            [containerView insertSubview:toViewController.view aboveSubview:fromViewController.view];
            [fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        };
        
        if (USECA)
            [self animateLayer:view.layer withCompletion:block];
        else
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                view.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
            } completion:^(BOOL finished) { block();}];
        
    } else if (self.transitionDirection == kSCCardTransitionBackwards) {
        [containerView insertSubview:toViewController.view aboveSubview:fromViewController.view];
        [fromViewController.view removeFromSuperview];
        UIView *view = [toViewController valueForKeyPath:@"squareView"];
        fromViewController.view.alpha = 0.5;
        if (USECA)
            [self animateLayer:view.layer withCompletion:^{
                if (_wasCanceled) [containerView addSubview:fromViewController.view];
                [transitionContext completeTransition:!_wasCanceled];
                _wasCanceled = NO;
            }];
        else
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            view.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];

    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super startInteractiveTransition:transitionContext];
    _transitionContext = transitionContext;
}

- (void)finishInteractiveTransition {
    [super finishInteractiveTransition];
    CALayer *layer = [_transitionContext containerView].layer;
    layer.speed = 1.0;
    layer.beginTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - layer.timeOffset;
}

- (void)cancelInteractiveTransition {
    _wasCanceled = YES;
    [super cancelInteractiveTransition];
    CALayer *layer = [_transitionContext containerView].layer;
    layer.speed = -1.0;
    layer.beginTime = CACurrentMediaTime();
}

- (void)handleGesture:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:recognizer.view].x / (recognizer.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged:
            [self updateInteractiveTransition:progress];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            if (progress < 0.5){
                self.completionSpeed = [self transitionDuration:_transitionContext]*(1.0 - progress);
                [self cancelInteractiveTransition];
            }else{
                self.completionSpeed = [self transitionDuration:_transitionContext]*progress;
                [self finishInteractiveTransition];
                [recognizer.view removeGestureRecognizer:recognizer];
            }
            self.shouldBeginInteractiveTransition = NO;
            break;
        default:
            break;
    }
}
- (void)animateLayer:(CALayer *)layer withCompletion:(void(^)())block {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.fromValue = @0.0;
    animation.toValue = [NSNumber numberWithFloat:M_PI];
    animation.duration = [self transitionDuration:_transitionContext];
    animation.fillMode = kCAFillModeBoth;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [animation setValue:block forKeyPath:@"block"];
    [layer addAnimation:animation forKey:@"transform.rotation.y"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    void(^block)() = [anim valueForKeyPath:@"block"];
    if (block){
        block();
    }
}

@end
