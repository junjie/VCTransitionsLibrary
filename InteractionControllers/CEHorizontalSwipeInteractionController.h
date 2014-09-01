//
//  SwipeInteractionController.h
//  ILoveCatz
//
//  Created by Colin Eberhardt on 22/08/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEBaseInteractionController.h"

/**
 A horizontal swipe interaction controller. When used with a navigation controller, a right-to-left swipe
 will cause a 'pop' navigation. When used wth a tabbar controller, right-to-left and left-to-right cause navigation
 between neighbouring tabs.
 */
@interface CEHorizontalSwipeInteractionController : CEBaseInteractionController

/// Reflects the direction of swipe. Only valid if interactionInProgress is YES
@property (nonatomic) UISwipeGestureRecognizerDirection swipeDirection;

/// Cancels the interaction if the swipe direction changes while an interaction
/// is already in progress. Default: NO
@property (nonatomic) BOOL cancelOnDirectionChange;

/// YES when the interactive transition reaches a point where it'll complete
/// when even when the gesture ends
@property (nonatomic, readonly) BOOL transitionWillComplete;

@property (nonatomic, copy) void (^didFinishInteractiveTransition)(UIViewController *fromController);

@end
