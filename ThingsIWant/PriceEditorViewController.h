//
//  PriceEditorViewController.h
//  ThingsIWant
//
//  Created by Kent on 11/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog/QuickDialog.h>
#import "AKPrice.h"
@protocol PriceEditorViewControllerDelegate;
@interface PriceEditorViewController : QuickDialogController
@property (nonatomic, strong) AKPrice * price;
@property (nonatomic, weak) id<PriceEditorViewControllerDelegate> delegate;
@end

@protocol PriceEditorViewControllerDelegate <NSObject>

-(void)priceEditorViewController:(PriceEditorViewController *)viewController didSavedPrice:(AKPrice *)price;

@end
