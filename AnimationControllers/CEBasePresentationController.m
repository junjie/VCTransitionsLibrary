//
//  CEBasePresentationController.m
//  Due
//
//  Created by Lin Junjie on 26/2/18.
//  Copyright © 2018 Lin Junjie. All rights reserved.
//

#import "CEBasePresentationController.h"

@implementation CEBasePresentationController

- (void)presentationTransitionWillBegin
{
	if (self.willPresentAction != NULL)
	{
		self.willPresentAction(self);
	}
}

- (void)dismissalTransitionWillBegin
{
	if (self.willDismissAction != NULL)
	{
		self.willDismissAction(self);
	}
}

@end
