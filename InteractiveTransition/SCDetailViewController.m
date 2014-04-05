//
//  SCDetailViewController.m
//  InteractiveTransition
//
//  Created by Michal Inger on 04/04/2014.
//  Copyright (c) 2014 StringCode Ltd. All rights reserved.
//

#import "SCDetailViewController.h"
#import "SCTransition.h"

@interface SCDetailViewController () <UINavigationControllerDelegate>
@property (nonatomic, strong) SCTransition *transition;

@end

@implementation SCDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.delegate = self;
    UIScreenEdgePanGestureRecognizer *pop = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pop.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:pop];
}

#pragma mark - Navigation controller delegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return (operation == UINavigationControllerOperationPop) ? self.transition : nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    return (self.transition.shouldBeginInteractiveTransition) ? self.transition : nil;
}

- (void)handleGesture:(UIScreenEdgePanGestureRecognizer *)recognizer {
    self.transition.shouldBeginInteractiveTransition = YES;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.transition handleGesture:recognizer];
}

- (SCTransition *)transition {
    if (!_transition) {
        _transition = [[SCTransition alloc] init];
        _transition.transitionDirection = kSCTransitionBackwards;
    }
    return _transition;
}


@end
