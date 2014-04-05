//
//  SCTransition.m
//  InteractiveTransition
//
//  Created by Michal Inger on 04/04/2014.
//  Copyright (c) 2014 StringCode Ltd. All rights reserved.
//

#import "SCTransition.h"


@interface SCTransition ()
@property (nonatomic, weak) UIViewController *fromViewController;
@property (nonatomic, weak) UIViewController *toViewController;
@end

@implementation SCTransition {
    __weak id <UIViewControllerContextTransitioning> _transitionContext;
    CGFloat _pausedTime;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    //Get references to the view hierarchy
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.fromViewController = fromViewController;
    self.toViewController = toViewController;
    
    
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
        
        if (USECA)
            [self animateLayer:view.layer withCompletion:^{ [transitionContext completeTransition:YES]; }];
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
    [self pauseLayer:[transitionContext containerView].layer];
}
- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [super updateInteractiveTransition:percentComplete];
    [_transitionContext containerView].layer.timeOffset = percentComplete;

}
- (void)finishInteractiveTransition {
    [super finishInteractiveTransition];
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
        case UIGestureRecognizerStateEnded:
            if (progress < 0.5){
                [self cancelInteractiveTransition];
            }else{
                
                [self finishInteractiveTransition];
                [recognizer.view removeGestureRecognizer:recognizer];
            }
            self.shouldBeginInteractiveTransition = NO;
            break;
        default:
            break;
    }
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
    _pausedTime = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
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
