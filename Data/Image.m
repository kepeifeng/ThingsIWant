//
//  Image.m
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "Image.h"
#import "Product.h"
#import "FileHelper.h"

@implementation Image

// Insert code here to add functionality to your managed object subclass
- (instancetype)init
{
    NSEntityDescription * desc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
    
    self = [super initWithEntity:desc insertIntoManagedObjectContext:nil];
    if (self) {
        
    }
    return self;
}

-(NSString *)filePath{

    if (self.filename.length) {
        return [[FileHelper imageFolder] stringByAppendingPathComponent:self.filename];
    }else if(self.uuid.length){
        return [[FileHelper imageFolder] stringByAppendingPathComponent:self.uuid];
    }
    return nil;
}
@end
