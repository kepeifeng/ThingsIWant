//
//  DataManager.m
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "DataManager.h"


@implementation DataManager
+ (id)sharedManager
{
    static dispatch_once_t onceQueue;
    static DataManager *dataManager = nil;
    
    dispatch_once(&onceQueue, ^{ dataManager = [[self alloc] init]; });
    return dataManager;
}

@end
