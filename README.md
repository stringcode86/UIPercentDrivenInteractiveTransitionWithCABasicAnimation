UIPercentDrivenInteractiveTransitionWithCABasicAnimation
========================================================

This project is for demo purposes. When using gesture driven UIPercentDrivenInteractiveTransition with CABasicAnimation (or any other CAAnimation), upon finishInteractiveTransition, animation jumps to final position, rather then animating smoothly as is the case when using UIView block animation. I am trying to figure out how to animate smoothly upon finishInteractiveTransition to end when using CAAnimation.

SOLUTION

As it turns out solution is to manipulate layers begin time. I am going to try to explain the solution in bit more depth below. There are two solution one using UIPercentDrivenTransition subclass or implementing UIViewControllerInteractiveTransitioning protocol. Custom UIViewControllerInteractiveTransitioning is on the master branch and UIPercentDrivenTransition implementation is on UIPercentDrivenTransitionImplementation branch.

https://github.com/stringcode86/UIPercentDrivenInteractiveTransitionWithCABasicAnimation

EXPLANATION

UIPercentDrivenTransition uses animations in animateTransition: to implement updateInteractiveTransition: . I am guessing they simply call animateTransition: from startInteractiveTransition: and then set layer (perhaps containers view layer) speed to 0.0 and manipulate its timeOffSet. This allow them to automatically move your transition back and forward. This does it for your UIView animations. Problem with CAAnimations is their begingTime, timeOffSet, speed properties are not set correctly for some reason. If you set those to sensible values, you are able to move all animated content in containerView back and forth. I have created SCPercentDrivenTransition witch is alternative to UIPercentDrivenTransition. You only need to override animateTransition: and call handleGesture: from your gesture recognisers action calls.
