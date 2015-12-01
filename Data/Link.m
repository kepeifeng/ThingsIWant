//
//  Link.m
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "Link.h"
#import "Product.h"

@implementation Link

- (instancetype)init
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"Link" inManagedObjectContext:[APP_DELEGATE managedObjectContext]] insertIntoManagedObjectContext:nil];
    if (self) {
        
    }
    return self;
}


@end
