//
//  SyncManager.h
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModel.h"

@protocol SyncManagerDelegate;
@interface SyncManager : NSObject
+ (instancetype)sharedManager;

@property (nonatomic, weak) id<SyncManagerDelegate> delegate;

-(void)sync;
@end

@protocol SyncManagerDelegate <NSObject>
@optional
-(void)syncManagerDidFinishSync:(SyncManager *)syncManager;

@end
