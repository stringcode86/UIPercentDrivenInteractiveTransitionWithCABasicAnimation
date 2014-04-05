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
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic ) CGFloat completionSpeed;
@property UIViewAnimationCurve completionCurve;
@property (nonatomic, weak) CALayer *animLayer;
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
    self.containerView = containerView;
    
    if (self.transitionDirection == kSCCardTransitionForwards) {

        [containerView insertSubview:toViewController.view aboveSubview:fromViewController.view];
        toViewController.view.transform = CGAffineTransformMakeTranslation(0.0, toViewController.view.bounds.size.height);
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             toViewController.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];

    } else if (self.transitionDirection == kSCCardTransitionBackwards) {
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             fromViewController.view.transform = CGAffineTransformMakeTranslation(0.0, fromViewController.view.bounds.size.height);
                         }
                         completion:^(BOOL finished) {
                             NSLog(@"completed");
                            [_transitionContext completeTransition:YES];
                         }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;
    [self animateTransition:_transitionContext];
    self.animLayer = self.containerView.layer;
    [self pauseLayer:self.animLayer];

}
- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    self.animLayer.timeOffset =  _pausedTime + [self transitionDuration:_transitionContext]*percentComplete;
    [_transitionContext updateInteractiveTransition:percentComplete];
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
                [_transitionContext completeTransition:NO];
            }else{
                self.completionSpeed =  [self transitionDuration:_transitionContext]*progress;
                [_transitionContext finishInteractiveTransition];
                [self resumeLayer:self.animLayer];
            }
            self.shouldBeginInteractiveTransition = NO;
            break;
        }
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
