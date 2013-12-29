//
//  CEZoomAnimationController.h
//  TransitionsDemo
//
//  Created by Colin Eberhardt on 22/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "CEReversibleAnimationController.h"

/// Specifies how to the presented controller is being animated
typedef enum : NSInteger {
	CECardsAnimateBySlidingUp, /*!< Slide the presented controller in from
								bottom to top */
	CECardsAnimateBySlidingDown, /*!< Slide the presented controller in from
								top to bottom */
	CECardsAnimateBySlidingLeft, /*!< Slide the presented controller in from
								  right to left */
	CECardsAnimateBySlidingRight, /*!< Slide the presented controller in from
								left to right */
} CECardsAnimation;

@interface CECardsAnimationController : CEReversibleAnimationController

/// Specifies how to the presented controller is being animated inwards. The
/// dismissal action will be in the opposite direction.
/// Default: CECardsAnimateBySlidingUp
@property (nonatomic) CECardsAnimation animationStyle;

/// Default: 0.6. Value of 0-1
@property (nonatomic) CGFloat opacityOfPresentingViewAfterPresentation;

/// Default: 0.6. Value of 0-1
@property (nonatomic) CGFloat scaleOfPresentingViewAfterPresentation;

/// Inset the presented view such that it is this number of points away from the
/// left and right edge of the presenting view. Default: 0.
@property (nonatomic) CGFloat xInsetsOfPresentedFrame;

/// Inset the presented view such that it is this number of points away from the
/// top and bottom edge of the presenting view. Default: 0.
@property (nonatomic) CGFloat yInsetsOfPresentedFrame;

@end
