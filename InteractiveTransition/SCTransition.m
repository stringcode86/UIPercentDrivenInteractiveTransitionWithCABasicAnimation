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
@property (nonatomic, weak) id <UIViewControllerContextTransitioning> transitionContext;
@end

@implementation SCTransition {
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
        UIView *view = [toViewController valueForKeyPath:@"squareView"];
        fromViewController.view.alpha = 0.5;
            [self animateLayer:view.layer withCompletion:^{
                if (_wasCanceled) {
                    [containerView addSubview:fromViewController.view];
                    fromViewController.view.alpha = 1.0;
                    [toViewController.view removeFromSuperview];
                }
                [transitionContext completeTransition:!_wasCanceled];
                _wasCanceled = NO;
            }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return (self.transitionDirection == kSCCardTransitionForwards) ? 0.5 : 5.0;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;
    [self animateTransition:_transitionContext];
    [self pauseLayer:[transitionContext containerView].layer];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [_transitionContext updateInteractiveTransition:percentComplete];
    [_transitionContext containerView].layer.timeOffset =  _pausedTime + [self transitionDuration:_transitionContext]*percentComplete;
}

- (void)cancelInteractiveTransition {
    _wasCanceled = YES;
    [_transitionContext cancelInteractiveTransition];
    CALayer *containerLayer =[_transitionContext containerView].layer;
    containerLayer.speed = -1.0;
    containerLayer.beginTime = CACurrentMediaTime();
}

- (void)finishInteractiveTransition {
    _wasCanceled = NO;
    [_transitionContext finishInteractiveTransition];
    [self resumeLayer:[_transitionContext containerView].layer];
}


- (void)handleGesture:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:recognizer.view].x / (recognizer.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            [self updateInteractiveTransition:progress];
            break;
        case UIGestureRecognizerStateEnded:{
            if (progress < 0.5){
                self.completionSpeed = (1.0-progress);
                [self cancelInteractiveTransition];
            }else{
                self.completionSpeed = progress;
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
    animation.removedOnCompletion = YES;
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
