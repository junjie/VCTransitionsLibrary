//
//  CEZoomAnimationController.m
//  TransitionsDemo
//
//  Created by Colin Eberhardt on 22/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "CECardsAnimationController.h"
#import "UIView+AutoLayout.h"

@implementation CECardsPresentationController

- (void)presentationTransitionWillBegin
{
	id transitionCoordinator = [[self presentedViewController] transitionCoordinator];
	
	UIView *fromView = self.presentingViewController.view;
	UIView *toView = self.presentedView;
	
	[transitionCoordinator animateAlongsideTransitionInView:fromView
animation:^(id<UIViewControllerTransitionCoordinatorContext> context) {
	
		[UIView animateKeyframesWithDuration:0
									   delay:0
									 options:UIViewKeyframeAnimationOptionCalculationModeLinear
								  animations:^
		 {
			 // (1) push the from- view to the back
			 [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.3f animations:^{
				 fromView.layer.transform = [self fallBackwardsAndScaleDownSlightly];
				 fromView.layer.zPosition = toView.layer.zPosition + 1000;
			 }];
			 
			 // (2) send the from- view further backwards and a little upwards
			 [UIView addKeyframeWithRelativeStartTime:0.3f relativeDuration:0.4f animations:^{
				 fromView.layer.transform = [self sendFurtherBackwardsAndALittleUpward:fromView];
			 }];
		 } completion:^(BOOL finished) {
			 fromView.layer.zPosition = 0;
		 }];
	
	} completion:nil];
}


- (void)dismissalTransitionWillBegin
{
	UIView *fromView = self.presentedView;
	UIView *toView = self.presentingViewController.view;
	
	CATransform3D toViewOriginalTransformation =
	[self sendFurtherBackwardsAndALittleUpward:toView];
	
	toView.layer.transform = toViewOriginalTransformation;
	
	id transitionCoordinator = [[self presentedViewController] transitionCoordinator];

	[transitionCoordinator animateAlongsideTransitionInView:toView animation:^(id<UIViewControllerTransitionCoordinatorContext> context) {

		[UIView animateKeyframesWithDuration:0
									   delay:0
									 options:UIViewKeyframeAnimationOptionCalculationModeCubic
								  animations:^
		 {
			 
			 // animate the to- view into place
			 [UIView addKeyframeWithRelativeStartTime:0.1f relativeDuration:0.6f animations:^{
				 toView.layer.transform = [self fallBackwardsAndScaleDownSlightly];
				 toView.alpha = 1.0;

				 toView.layer.zPosition = fromView.layer.zPosition + 1000;
			 }];
			 
			 [UIView addKeyframeWithRelativeStartTime:0.7f relativeDuration:0.3f animations:^{
				 toView.layer.transform = CATransform3DIdentity;
			 }];
		 } completion:^(BOOL finished) {
			 toView.layer.zPosition = 0;
		 }];

		
	} completion:nil];
}

#define INITIAL_TRANSFORMATION_SCALE 0.95
#define M34_TRANSFORMATION 1.0/-900

-(CATransform3D)fallBackwardsAndScaleDownSlightly
{
	CATransform3D t1 = CATransform3DIdentity;
	t1.m34 = M34_TRANSFORMATION;
	t1 = CATransform3DScale(t1,
							INITIAL_TRANSFORMATION_SCALE,
							INITIAL_TRANSFORMATION_SCALE,
							1);
	
	t1 = CATransform3DRotate(t1, 15.0f * M_PI/180.0f, 1, 0, 0);
	return t1;
	
}

-(CATransform3D)sendFurtherBackwardsAndALittleUpward:(UIView*)view
{
	CATransform3D t2 = CATransform3DIdentity;
	t2.m34 = M34_TRANSFORMATION;
	t2 = CATransform3DTranslate(t2, 0, view.frame.size.height*-0.08, 0);
	t2 = CATransform3DScale(t2,
							0.6f * INITIAL_TRANSFORMATION_SCALE,
							0.6f * INITIAL_TRANSFORMATION_SCALE,
							1);
	
	return t2;
}

@end


@implementation CECardsAnimationController

- (id)init
{
	self = [super init];
	if (self)
	{
		_animationStyle = CECardsAnimateBySlidingUp;
		_opacityOfPresentingViewAfterPresentation = 0.6f;
		_scaleOfPresentingViewAfterPresentation = 0.6f;
		
		_xInsetsOfPresentedFrame = 0;
		_yInsetsOfPresentedFrame = 0;
		_maximumSizeOfPresentedFrame = CGSizeZero;
	}
	return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    if(self.reverse){
        [self executeReverseAnimation:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
    } else {
        [self executeForwardsAnimation:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
    }
	
}

-(void)executeForwardsAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView* containerView = [transitionContext containerView];

    // the current from- view frame, which is also where the to- view will be
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromVC];

	// where we'd like to- view to end up
	CGRect toFrame =
	CGRectInset(fromFrame,
				self.xInsetsOfPresentedFrame,
				self.yInsetsOfPresentedFrame);
	
	if (self.maximumSizeOfPresentedFrame.height > 0 &&
		CGRectGetHeight(toFrame) > self.maximumSizeOfPresentedFrame.height)
	{
		CGFloat difference = CGRectGetHeight(toFrame) - self.maximumSizeOfPresentedFrame.height;
		toFrame = CGRectInset(toFrame, 0, difference/2);
	}
	
	if (self.maximumSizeOfPresentedFrame.width > 0 &&
		CGRectGetWidth(toFrame) > self.maximumSizeOfPresentedFrame.width)
	{
		CGFloat difference = CGRectGetWidth(toFrame) - self.maximumSizeOfPresentedFrame.width;
		toFrame = CGRectInset(toFrame, difference/2, 0);
	}
	
	toFrame = CGRectIntegral(toFrame);
	
	[toView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[containerView addSubview:toView];
	
	[containerView addConstraintsSizingSubview:toView toWidth:CGRectGetWidth(toFrame) height:CGRectGetHeight(toFrame) withMinimumInsetsFromSelf:UIEdgeInsetsMake(self.yInsetsOfPresentedFrame, self.xInsetsOfPresentedFrame, self.yInsetsOfPresentedFrame, self.xInsetsOfPresentedFrame)];
	[containerView addConstraintsCenteringSubviewInSelf:toView];
	
	// positions the to- view off screen, depending on the animation style
    CGRect offScreenFrame;
	
	// to simulate springiness, we'll overshoot the final frame first before
	// we come to a complete rest
	CGRect intermediateFrame;
	
	switch (self.animationStyle)
	{
		case CECardsAnimateBySlidingUp:
		{
			offScreenFrame =
			CGRectOffset(toFrame, 0, fromFrame.size.height);
			
			intermediateFrame =
			CGRectOffset(toFrame, 0, -10);
			
			break;
		}
			
		case CECardsAnimateBySlidingDown:
		{
			offScreenFrame =
			CGRectOffset(toFrame, 0, -fromFrame.size.height);
			
			intermediateFrame =
			CGRectOffset(toFrame, 0, 10);
			
			break;
		}
			
		case CECardsAnimateBySlidingLeft:
		{
			offScreenFrame =
			CGRectOffset(toFrame, fromFrame.size.width, 0);
			
			intermediateFrame =
			CGRectOffset(toFrame, -10, 0);
			
			break;
		}
			
		case CECardsAnimateBySlidingRight:
		{
			offScreenFrame =
			CGRectOffset(toFrame, -fromFrame.size.width, 0);
			
			intermediateFrame =
			CGRectOffset(toFrame, 10, 0);
			
			break;
		}
			
		default:
		{
			NSAssert(0, @"Invalid animationStyle %ld", (long)self.animationStyle);
			break;
		}
	}

    toView.frame = offScreenFrame;
	
	[containerView addSubview:toView];
	
    [UIView animateKeyframesWithDuration:self.duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        // (1) push the from- view to the back
		[UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.3f animations:^{
			fromView.alpha = self.opacityOfPresentingViewAfterPresentation;
		}];
		
		// (2) send the from- view further backwards and a little upwards
		
        // slide the to- view in position depending on the animation style.
		// this is simulated with an intermediate frame since the original
		// implementation by Tope used a 'spring' animation, which does not
		// work with keyframes
        [UIView addKeyframeWithRelativeStartTime:0.6f relativeDuration:0.3f animations:^{
            toView.frame = intermediateFrame;
        }];
		
        [UIView addKeyframeWithRelativeStartTime:0.9f relativeDuration:0.1f animations:^{
            toView.frame = toFrame;
        }];

    } completion:^(BOOL finished) {
		
		BOOL cancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelled];
    }];
    
    
}

-(void)executeReverseAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    // positions the to- view behind the from- view
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromVC];
	
	CGRect toFrame = [transitionContext finalFrameForViewController:toVC];
	toView.frame = toFrame;
	
	toView.alpha = self.opacityOfPresentingViewAfterPresentation;
	
	// determine where the from- view will exit to
    CGRect frameOffScreen;

	switch (self.animationStyle)
	{
		// We need to slide back down
		case CECardsAnimateBySlidingUp:
		{
			frameOffScreen =
			CGRectOffset(fromFrame, 0, toFrame.size.height);
			break;
		}

		// We need to slide back up
		case CECardsAnimateBySlidingDown:
		{
			frameOffScreen =
			CGRectOffset(fromFrame, 0, -toFrame.size.height);
			break;
		}

		// We need to slide rightwards
		case CECardsAnimateBySlidingLeft:
		{
			frameOffScreen =
			CGRectOffset(fromFrame, toFrame.size.width, 0);
			break;
		}
			
		// We need to slide leftwards
		case CECardsAnimateBySlidingRight:
		{
			frameOffScreen =
			CGRectOffset(fromFrame, -toFrame.size.width, 0);
			break;
		}
			
		default:
		{
			NSAssert(0, @"Invalid animationStyle %ld", (long)self.animationStyle);
			break;
		}
	}
    
    [UIView animateKeyframesWithDuration:self.duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{

        // push the from- view off the bottom of the screen
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.5f animations:^{
            fromView.frame = frameOffScreen;
        }];
        
    } completion:^(BOOL finished) {
		
		BOOL cancelled = [transitionContext transitionWasCancelled];
		
		if (cancelled)
		{
//			toView.layer.transform = toViewOriginalTransformation;
            toView.alpha = self.opacityOfPresentingViewAfterPresentation;
		}
		
        [transitionContext completeTransition:!cancelled];
    }];
}

@end
