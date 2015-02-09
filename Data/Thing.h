//
//  Thing.h
//  ThingsIWant
//
//  Created by Kent Peifeng Ke on 2/9/15.
//  Copyright (c) 2015 Kent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Thing : NSManagedObject

@property (nonatomic, retain) NSNumber * mainImageId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * price;

@end
