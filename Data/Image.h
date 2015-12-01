//
//  Image.h
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

NS_ASSUME_NONNULL_BEGIN

@interface Image : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
-(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END

#import "Image+CoreDataProperties.h"
