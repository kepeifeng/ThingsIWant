//
//  Image+CoreDataProperties.h
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Image.h"

NS_ASSUME_NONNULL_BEGIN

@interface Image (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *filename;
@property (nonatomic) float height;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nonatomic) float width;
@property (nonatomic) NSTimeInterval updateTime;
@property (nonatomic) BOOL deleted;
@property (nullable, nonatomic, retain) NSString *productId;

@end

NS_ASSUME_NONNULL_END
