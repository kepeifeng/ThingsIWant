//
//  Note.m
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "Note.h"
#import "Product.h"

@implementation Note

- (instancetype)init
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"Note" inManagedObjectContext:[APP_DELEGATE managedObjectContext]] insertIntoManagedObjectContext:nil];
    if (self) {
        
    }
    return self;
}

// Insert code here to add functionality to your managed object subclass

@end
