//
//  LinkEditorViewController.h
//  ThingsIWant
//
//  Created by Kent on 11/27/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog.h>
#import "Link.h"
@protocol LinkEditorViewControllerDelegate;
@interface LinkEditorViewController : QuickDialogController
@property (nonatomic, strong) Link * link;
@property (nonatomic, weak) id<LinkEditorViewControllerDelegate> delegate;
@end

@protocol LinkEditorViewControllerDelegate <NSObject>

-(void)linkEditorViewController:(LinkEditorViewController *)viewController didSavedLink:(Link *)link;

@end