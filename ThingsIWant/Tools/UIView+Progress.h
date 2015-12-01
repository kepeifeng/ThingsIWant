//
//  UIViewController+Progress.h
//  2bulu-QuanZi
//
//  Created by Kent Peifeng Ke on 14-5-22.
//  Copyright (c) 2014年 Lolaage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTProgressHUD.h"


#define MESSAGE_CONFIRM_CANCEL_CREATE_ACTIVITY @"你确定要取消该活动吗?"
#define MESSAGE_CONFIRM_CANCEL_CREATE_TEAM @"确定要取消创建圈子吗?"

typedef NS_ENUM(NSUInteger, LAStatus) {
    LAStatusNormal,
    LAStatusSuccess,
    LAStatusFailed,
    LAStatusError,
    LAStatusWarning,
};

@protocol LAHUDProtocol <NSObject>

@property (nonatomic, strong, readonly) HTProgressHUD *progressView;
@property (nonatomic) BOOL isLoading;
-(void)startLoadingWithText:(NSString *)text;
-(void)startLoading;
-(void)stopLoading;
-(void)stopLoadingAnimated:(BOOL)animated;

-(void)showCheckmark;


-(void)showMessage:(NSString *)message withStatus:(LAStatus)status;
-(void)displayErrorMessage:(NSString *)message forErrorCode:(NSInteger)errorCode;

-(HTProgressHUD *)showMessage:(NSString *)title;
-(HTProgressHUD *)showMessage:(NSString *)title duration:(NSTimeInterval)duration;

@end

#pragma mark - UIViewController

@interface UIViewController (Progress)<UIAlertViewDelegate, LAHUDProtocol>

//The loading progress HUD view
@property (nonatomic, strong, readonly) HTProgressHUD *progressView;


@end

#pragma mark - UIView


@interface UIView (Progress)<LAHUDProtocol>


@end

@interface UIView (ActivityIndicator)

//-(void)enableActivityIndicator:(BOOL)enable;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;

@end


