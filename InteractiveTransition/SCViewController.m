//
//  SCViewController.m
//  InteractiveTransition
//
//  Created by Michal Inger on 04/04/2014.
//  Copyright (c) 2014 StringCode Ltd. All rights reserved.
//

#import "SCViewController.h"
#import "SCTransition.h"

@interface SCViewController () <UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *squareView;
@property (nonatomic) SCTransition *transition;
@end

@implementation SCViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    self.navigationController.delegate = self;
    CATransform3D transfrom = CATransform3DIdentity;
    transfrom.m34 = -1.f/500.f;
    self.view.layer.sublayerTransform = transfrom;
    
    UIScreenEdgePanGestureRecognizer *pop = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pop.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:pop];
}

- (void)animateLayer:(CALayer *)layer withCompletion:(void(^)())block {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.fromValue = @0.0;
    animation.toValue = [NSNumber numberWithFloat:M_PI];
    animation.duration = 2.0;
    animation.fillMode = kCAFillModeBoth;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [animation setValue:block forKeyPath:@"block"];
    [layer addAnimation:animation forKey:@"transform.rotation.y"];
}


#pragma mark - Navigation controller delegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return (operation == UINavigationControllerOperationPush) ? [[SCTransition alloc] init] : nil;
}
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    return (self.transition.shouldBeginInteractiveTransition) ? self.transition : nil;
}

- (void)handleGesture:(UIScreenEdgePanGestureRecognizer *)recognizer {
    self.transition.shouldBeginInteractiveTransition = YES;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:@"toSecond" sender:self];
    }
    [self.transition handleGesture:recognizer];
}

- (SCTransition *)transition {
    if (!_transition) {
        _transition = [[SCTransition alloc] init];
        _transition.transitionDirection = kSCTransitionForwards;
    }
    return _transition;
}


@end
