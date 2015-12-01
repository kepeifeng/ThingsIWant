//
//  KeyboardStateListener.h
//  2bulu-QuanZi
//
//  Created by Kent Peifeng Ke on 14/12/4.
//  Copyright (c) 2014年 Lolaage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardStateListener : NSObject {
    BOOL _isVisible;
}
+ (KeyboardStateListener *)sharedInstance;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@property (nonatomic, readonly) CGSize keyboardSize;

@end