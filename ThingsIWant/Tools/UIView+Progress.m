//
//  UIViewController+Progress.m
//  2bulu-QuanZi
//
//  Created by Kent Peifeng Ke on 14-5-22.
//  Copyright (c) 2014年 Lolaage. All rights reserved.
//

#import "UIView+Progress.h"

#import <objc/runtime.h>
#import "HTProgressHUDImageIndicatorView.h"
#import "HTProgressHUDFadeZoomAnimation.h"
#import "KeyboardStateListener.h"
//#import "UILabel+Utility.h"

@interface UITableView (Progress)

@end

@implementation UITableView (Progress)

-(void)didAddSubview:(UIView *)subview{
    for (UIView *view in self.subviews){
        if([view isKindOfClass:[HTProgressHUD class]]){
            [self bringSubviewToFront:view];
            break;
        }
    }
}

@end

@interface UIViewController()
@property (nonatomic, strong) NSString * dismissMessage;
@property (nonatomic) BOOL isLoading;
@end

@implementation UIViewController (Progress)

#pragma mark - Properties

//- (NSString *) lastErrorMessage {
//    return objc_getAssociatedObject(self, @selector(lastErrorMessage));
//}
//
//- (void)setLastErrorMessage: (NSString *)lastErrorMessage {
//    objc_setAssociatedObject(self, @selector(lastErrorMessage), lastErrorMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//
//- (NSTimeInterval) lastErrorMessageTime {
//    return [(NSNumber *)objc_getAssociatedObject(self, @selector(lastErrorMessageTime)) doubleValue];
//}
//
//- (void)setLastErrorMessageTime: (NSTimeInterval)lastErrorMessageTime {
//    objc_setAssociatedObject(self, @selector(lastErrorMessageTime), @(lastErrorMessageTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}


-(BOOL)isLoading{
    return self.view.isLoading;
//    return [objc_getAssociatedObject(self, @selector(isLoading)) boolValue];
}

-(void)setIsLoading:(BOOL)isLoading{
    self.view.isLoading = isLoading;
//    objc_setAssociatedObject(self, @selector(isLoading), @(isLoading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
//
//-(NSString *)dismissMessage{
//    return objc_getAssociatedObject(self, @selector(dismissMessage));
//}
//
//-(void)setDismissMessage:(NSString *)dismissMessage{
//    objc_setAssociatedObject(self, @selector(dismissMessage), dismissMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}


-(HTProgressHUD *)progressView{
    return self.view.progressView;
}
-(void)startLoadingWithText:(NSString *)text{
    [self.view startLoadingWithText:text];
    
}


-(void)startLoading{
    [self.view startLoadingWithText:nil];
}

-(void)stopLoadingAnimated:(BOOL)animated{
    [self.view stopLoadingAnimated:animated];
}
-(void)stopLoading{
    [self.view stopLoading];
}

-(void)showCheckmark;
{
    [self.view showCheckmark];
}

-(void)showMessage:(NSString *)message withStatus:(LAStatus)status
{
    [self.view showMessage:message withStatus:status];
}


-(HTProgressHUD *)showMessage:(NSString *)title{

    return [self.view showMessage:title];
}

-(HTProgressHUD *)showMessage:(NSString *)title duration:(NSTimeInterval)duration
{
    return [self.view showMessage:title duration:duration];
}

-(void)displayErrorMessage:(NSString *)message forErrorCode:(NSInteger)errorCode{

    [self.view displayErrorMessage:message forErrorCode:errorCode];

}

@end

@implementation UIView (Progress)

#pragma mark - Properties

- (NSString *) lastErrorMessage {
    return objc_getAssociatedObject(self, @selector(lastErrorMessage));
}

- (void)setLastErrorMessage: (NSString *)lastErrorMessage {
    objc_setAssociatedObject(self, @selector(lastErrorMessage), lastErrorMessage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSTimeInterval) lastErrorMessageTime {
    return [(NSNumber *)objc_getAssociatedObject(self, @selector(lastErrorMessageTime)) doubleValue];
}

- (void)setLastErrorMessageTime: (NSTimeInterval)lastErrorMessageTime {
    objc_setAssociatedObject(self, @selector(lastErrorMessageTime), @(lastErrorMessageTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(BOOL)isLoading{
    return [objc_getAssociatedObject(self, @selector(isLoading)) boolValue];
}

-(void)setIsLoading:(BOOL)isLoading{
    objc_setAssociatedObject(self, @selector(isLoading), @(isLoading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(HTProgressHUD *)progressView{
    
    HTProgressHUD *_progressHUD = (HTProgressHUD *)objc_getAssociatedObject(self, @selector(progressView));
    if(!_progressHUD){
        _progressHUD = [[HTProgressHUD alloc] init];
        //        _progressHUD.animation = [HTProgressHUDFadeZoomAnimation new];
        objc_setAssociatedObject(self, @selector(progressView), _progressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _progressHUD;
}
-(void)startLoadingWithText:(NSString *)text{
    
    self.progressView.text = text;
    self.progressView.disableUserInteractionOfSuperview = YES;
    //  NSLog(@"%@", (self.progressView.animation.animationType == HTProgressHUDAnimationTypeHiding)?@"Hiding":@"Showing");
    
    if (self.isLoading == NO) {
        [self displayHUD];
    }
    
    self.isLoading = YES;
    
}
-(void)displayHUD{
    [self.progressView showInView:self];
}

-(void)startLoading{
    [self startLoadingWithText:nil];
}
-(void)stopLoadingAnimated:(BOOL)animated{
    [self.progressView hideWithAnimation:animated];
    self.isLoading = NO;
}
-(void)stopLoading{
    [self stopLoadingAnimated:YES];
}

-(void)showCheckmark;
{
    //Make sure it was called in main thread!
    
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showCheckmark];
        });
        return;
    }
    
    HTProgressHUD * hud = [[HTProgressHUD alloc] init];

    hud.indicatorView = [[HTProgressHUDImageIndicatorView alloc] initWithImage:[UIImage imageNamed:@"icon-checkmark-circled"]];
    hud.text = nil;
    hud.disableUserInteractionOfSuperview = ([self isKindOfClass:[UIScrollView class]]);
    UIGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudGestureRecognized:)];
    [hud addGestureRecognizer:gestureRecognizer];
    [hud showInView:self];
    [hud hideAfterDelay:2];
}

-(void)showMessage:(NSString *)message withStatus:(LAStatus)status{

    //Make sure it was called in main thread!
    
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMessage:message withStatus:status];
        });
        return;
    }
    
        HTProgressHUD * hud = [[HTProgressHUD alloc] init];
        
        switch (status) {
                
            case LAStatusNormal:
                hud.indicatorView = nil;
                break;
            case LAStatusSuccess:
                hud.indicatorView = [[HTProgressHUDImageIndicatorView alloc] initWithImage:[[UIImage imageNamed:@"icon-checkmark-circled"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)]];
                break;
            case LAStatusError:
            case LAStatusFailed:
                hud.indicatorView = [[HTProgressHUDImageIndicatorView alloc] initWithImage:[[UIImage imageNamed:@"icon-error-circled"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)]];
                break;
            case LAStatusWarning:
                hud.indicatorView = [[HTProgressHUDImageIndicatorView alloc] initWithImage:[[UIImage imageNamed:@"icon-warn-circled"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)]];
                break;
            default:
                break;
        }
        hud.indicatorView.tintColor = [UIColor whiteColor];
        
        hud.text = message;
        hud.disableUserInteractionOfSuperview = ([self isKindOfClass:[UIScrollView class]]);
        UIGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudGestureRecognized:)];
        [hud addGestureRecognizer:gestureRecognizer];
        [hud showInView:self];
        [hud hideAfterDelay:2];
    
}


-(HTProgressHUD *)showMessage:(NSString *)title{
    
    return [self showMessage:title duration:2];
}

-(HTProgressHUD *)showMessage:(NSString *)title duration:(NSTimeInterval)duration
{
    if (!title.length) {
        return nil;
    }

    
    HTProgressHUD * hud = [[HTProgressHUD alloc] initWithFrame:self.bounds];
    //    hud.animation = [HTProgressHUDFadeZoomAnimation new];
    
    
    UILabel * label = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.frame)*0.8, 20))];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    [label sizeToFit];
    label.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
    hud.indicatorView = [[HTProgressHUDIndicatorView alloc] initWithCustomView:label];
    
    hud.text = nil;
    hud.disableUserInteractionOfSuperview = ([self isKindOfClass:[UIScrollView class]]);
    UIGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudGestureRecognized:)];
    [hud addGestureRecognizer:gestureRecognizer];
    
    //    visibleRect.size.height -= [KeyboardStateListener ];
    
    if ([[KeyboardStateListener sharedInstance] isVisible] && [self isKindOfClass:[UIScrollView class]]) {
        CGRect visibleRect = self.bounds;
        visibleRect.size.height -= [[KeyboardStateListener sharedInstance] keyboardSize].height;
        [hud showInRect:visibleRect inView:self];
    }else{
        [hud showInView:self];
    }
    
    [hud hideAfterDelay:duration];
    return hud;
}

-(void)displayErrorMessage:(NSString *)message forErrorCode:(NSInteger)errorCode{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    //两秒内不显示重复提示
    if (timeInterval - self.lastErrorMessageTime > 2 || [message isEqualToString:self.lastErrorMessage] == false) {
        [self showMessage:message];
        self.lastErrorMessage = message;
        self.lastErrorMessageTime = timeInterval;
    }
    
}


-(void)hudGestureRecognized:(UIGestureRecognizer *)getstureRecognizer{
    
    [(HTProgressHUD *)getstureRecognizer.view hideWithAnimation:NO];
}

@end

@implementation UIView (ActivityIndicator)

-(UIActivityIndicatorView *)activityIndicator{
    UIActivityIndicatorView * spin = (UIActivityIndicatorView *)[self viewWithTag:9988873];
    if (!spin) {
        spin = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        spin.hidesWhenStopped = YES;
        spin.tag = 9988873;
        [self addSubview:spin];
        spin.center =CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
        spin.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return spin;
}
-(void)startActivityIndicator
{
    [[self activityIndicator] startAnimating];
    
}

-(void)stopActivityIndicator
{
    [[self activityIndicator] stopAnimating];
}

@end

