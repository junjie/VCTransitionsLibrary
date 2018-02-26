//
//  CEBasePresentationController.h
//  Due
//
//  Created by Lin Junjie on 26/2/18.
//  Copyright © 2018 Lin Junjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEBasePresentationController : UIPresentationController

@property (nonatomic, copy) void (^willDismissAction)(CEBasePresentationController *presentationController);
@property (nonatomic, copy) void (^willPresentAction)(CEBasePresentationController *presentationController);

@end
