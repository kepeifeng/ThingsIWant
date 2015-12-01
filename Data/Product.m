//
//  Product.m
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "Product.h"

@implementation Product

// Insert code here to add functionality to your managed object subclass
- (instancetype)init
{
    NSEntityDescription * desc = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
    
    self = [super initWithEntity:desc insertIntoManagedObjectContext:nil];
    if (self) {
        
    }
    return self;
}

@end
