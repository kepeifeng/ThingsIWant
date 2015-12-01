//
//  NoteEditorViewController.h
//  ThingsIWant
//
//  Created by Kent on 11/27/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog.h>
#import "Note.h"

@protocol NoteEditorViewControllerDelegate;
@interface NoteEditorViewController : UIViewController
@property (nonatomic, strong) Note * note;
@property (nonatomic, weak) id<NoteEditorViewControllerDelegate> delegate;
@end

@protocol NoteEditorViewControllerDelegate <NSObject>

-(void)noteEditorViewController:(NoteEditorViewController *)viewController didSavedNote:(Note *)note;

@end