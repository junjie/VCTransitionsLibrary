//
//  SwipeINteractionController.m
//  ILoveCatz
//
//  Created by Colin Eberhardt on 22/08/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "CEHorizontalSwipeInteractionController.h"

@interface CEHorizontalSwipeInteractionController ()
@property (nonatomic) BOOL transitionWillComplete;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic) CEInteractionOperation operation;
@end

@implementation CEHorizontalSwipeInteractionController

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

- (void)wireToViewController:(UIViewController *)viewController forOperation:(CEInteractionOperation)operation{
    self.operation = operation;
    self.viewController = viewController;
    [self prepareGestureRecognizerInView:viewController.view];
}


- (void)prepareGestureRecognizerInView:(UIView*)view {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [view addGestureRecognizer:panGesture];
}

- (CGFloat)completionSpeed
{
    return 1 - self.percentComplete;
}

- (void)finishInteractiveTransition
{
	[super finishInteractiveTransition];
	
	if (self.didFinishInteractiveTransition != NULL)
	{
		self.didFinishInteractiveTransition(self.viewController);
	}
}

- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer {
	if ([self.viewController respondsToSelector:@selector(allowsInteractiveDismissal)])
	{
		BOOL allowsInteractiveDismissal = [(id <CEInteractionController>)self.viewController allowsInteractiveDismissal];
		if (!allowsInteractiveDismissal)
		{
			return;
		}
	}
	
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    CGPoint vel = [gestureRecognizer velocityInView:gestureRecognizer.view];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            
            BOOL rightToLeftSwipe = vel.x < 0;
            
			if (rightToLeftSwipe)
			{
				self.swipeDirection = UISwipeGestureRecognizerDirectionLeft;
			}
			else
			{
				self.swipeDirection = UISwipeGestureRecognizerDirectionRight;
			}
			
            // perform the required navigation operation ...
            
            if (self.operation == CEInteractionOperationPop) {
                // for pop operation, fire on right-to-left
                if (rightToLeftSwipe) {
                    self.interactionInProgress = YES;
                    [self.viewController.navigationController popViewControllerAnimated:YES];
                }
            } else if (self.operation == CEInteractionOperationTab) {
                // for tab controllers, we need to determine which direction to transition
                if (rightToLeftSwipe) {
                    if (self.viewController.tabBarController.selectedIndex < self.viewController.tabBarController.viewControllers.count - 1) {
                        self.interactionInProgress = YES;
                        self.viewController.tabBarController.selectedIndex++;
                    }
                    
                } else {
                    if (self.viewController.tabBarController.selectedIndex > 0) {
                        self.interactionInProgress = YES;
                        self.viewController.tabBarController.selectedIndex--;
                    }
                }
            } else {
                // for dismiss, fire regardless of the translation direction
                self.interactionInProgress = YES;
                [self.viewController dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.interactionInProgress) {
				
				UISwipeGestureRecognizerDirection direction =
				translation.x < 0 ?
				UISwipeGestureRecognizerDirectionLeft :
				UISwipeGestureRecognizerDirectionRight;
				
				// If the swipe direction has changed from when the swipe
				// first started
				if (self.swipeDirection != direction)
				{
					self.swipeDirection = direction;
					
					if (self.cancelOnDirectionChange)
					{
						gestureRecognizer.enabled = NO;
						gestureRecognizer.enabled = YES;
					}
				}
				
                // compute the current position
                CGFloat fraction = fabsf(translation.x / 200.0);
                fraction = fminf(fmaxf(fraction, 0.0), 1.0);
                self.transitionWillComplete = (fraction > 0.5);
                
                // if an interactive transitions is 100% completed via the user interaction, for some reason
                // the animation completion block is not called, and hence the transition is not completed.
                // This glorious hack makes sure that this doesn't happen.
                // see: https://github.com/ColinEberhardt/VCTransitionsLibrary/issues/4
                if (fraction >= 1.0)
                    fraction = 0.99;
                
                [self updateInteractiveTransition:fraction];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (self.interactionInProgress) {
                self.interactionInProgress = NO;
                if (!self.transitionWillComplete || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                    [self cancelInteractiveTransition];
                }
                else {
                    [self finishInteractiveTransition];
                }
            }
            break;
        default:
            break;
    }
}


@end
