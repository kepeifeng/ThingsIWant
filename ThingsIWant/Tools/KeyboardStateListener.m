//
//  KeyboardStateListener.m
//  2bulu-QuanZi
//
//  Created by Kent Peifeng Ke on 14/12/4.
//  Copyright (c) 2014年 Lolaage. All rights reserved.
//

#import "KeyboardStateListener.h"

static KeyboardStateListener *sharedInstance;

@implementation KeyboardStateListener

+ (KeyboardStateListener *)sharedInstance
{
    return sharedInstance;
}

+ (void)load
{

    sharedInstance = [[self alloc] init];

}

- (BOOL)isVisible
{
    return _isVisible;
}

- (void)didShow:(NSNotification *)notification
{
    _isVisible = YES;
    NSDictionary* info = [notification userInfo];
    _keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
}

- (void)didHide:(NSNotification *)notification
{
    _isVisible = NO;
    _keyboardSize = CGSizeZero;
}

- (id)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

@end