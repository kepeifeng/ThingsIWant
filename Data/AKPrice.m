//
//  AKPrice.m
//  ThingsIWant
//
//  Created by Kent on 11/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "AKPrice.h"

@implementation AKPrice



-(instancetype)initWithDictionary:(NSDictionary *)dict{
    if (!(self = [super init])) {
        return nil;
    }
    
    self.value = [dict[@"value"] floatValue];
    self.note = dict[@"note"];
    
    return self;
}
-(NSDictionary *)getDictionaryObject{

    return @{@"value":@(self.value),
             @"note":self.note?:@""};
}

//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeFloat:self.value forKey:@"value"];
    [encoder encodeObject:self.note forKey:@"note"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.value = [decoder decodeFloatForKey:@"value"];
        self.note = [decoder decodeObjectForKey:@"note"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    AKPrice * theCopy = [[[self class] allocWithZone:zone] init];  // use designated initializer
    
    [theCopy setValue:self.value];
    [theCopy setNote:[self.note copy]];
    
    return theCopy;
}


@end
