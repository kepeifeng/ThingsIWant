//
//  Image.h
//  ThingsIWant
//
//  Created by Kent Peifeng Ke on 2/4/15.
//  Copyright (c) 2015 Kent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Thing;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * imageId;
@property (nonatomic, retain) Thing *item;

@end
