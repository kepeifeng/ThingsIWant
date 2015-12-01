//
//  Product+CoreDataProperties.h
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Product.h"

NS_ASSUME_NONNULL_BEGIN

@interface Product (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSArray * price;
@property (nonatomic) NSTimeInterval updateTime;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nonatomic) BOOL deleted;
@property (nullable, nonatomic, retain) NSString *remoteId;

@end

NS_ASSUME_NONNULL_END
