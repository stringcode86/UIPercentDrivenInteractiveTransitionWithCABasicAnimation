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
@end

@implementation SCViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    self.navigationController.delegate = self;
    CATransform3D transfrom = CATransform3DIdentity;
    transfrom.m34 = -1.f/500.f;
    self.view.layer.sublayerTransform = transfrom;
}

#pragma mark - Navigation controller delegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return (operation == UINavigationControllerOperationPush) ? [[SCTransition alloc] init] : nil;
}


@end
