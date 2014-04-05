//
//  SCTransition.m
//  InteractiveTransition
//
//  Created by Michal Inger on 04/04/2014.
//  Copyright (c) 2014 StringCode Ltd. All rights reserved.
//

#import "SCTransition.h"


@interface SCTransition ()
@property (nonatomic) CGFloat completionSpeed;
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
        [self animateLayer:view.layer withCompletion:^{
            [containerView insertSubview:toViewController.view aboveSubview:fromViewController.view];
            [transitionContext completeTransition:YES];
        }];

    } else if (self.transitionDirection == kSCCardTransitionBackwards) {
        
        [containerView insertSubview:toViewController.view aboveSubview:fromViewController.view];
        [fromViewController.view removeFromSuperview];
        UIView *view = [toViewController valueForKeyPath:@"squareView"];
        [self animateLayer:view.layer withCompletion:^{
            NSLog(@"complete %@", _wasCanceled ? @"caneled" : @"finished");
            [transitionContext completeTransition:!_wasCanceled];
            if (_wasCanceled) {
                [containerView addSubview:fromViewController.view];
                [fromViewController.view removeFromSuperview];
            }
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;
    [self animateTransition:_transitionContext];
    [self pauseLayer:[transitionContext containerView].layer];

}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [_transitionContext containerView].layer.timeOffset =  _pausedTime + [self transitionDuration:_transitionContext]*percentComplete;
    [_transitionContext updateInteractiveTransition:percentComplete];
}

- (void)cancelInteractiveTransition {
    _wasCanceled = YES;
    CALayer *containerLayer =[_transitionContext containerView].layer;
    self.completionSpeed = (containerLayer.timeOffset - _pausedTime);
    [_transitionContext cancelInteractiveTransition];
    [self resumeLayer:containerLayer];
    containerLayer.speed = 1.0;
}

- (void)finishInteractiveTransition {
    _wasCanceled = NO;
    self.completionSpeed = [_transitionContext containerView].layer.timeOffset - _pausedTime;
    [_transitionContext finishInteractiveTransition];
    [self resumeLayer:[_transitionContext containerView].layer];
}

- (void)handleGesture:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:recognizer.view].x / (recognizer.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged:
            [self updateInteractiveTransition:progress];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            if (progress < 0.5){
                [self cancelInteractiveTransition];
            }else{
                [self finishInteractiveTransition];
            }
            self.shouldBeginInteractiveTransition = NO;
            break;
        }
        default:
            break;
    }
}

- (void)pauseLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
    _pausedTime = pausedTime;
}

- (void)resumeLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
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
