//
//  AKPrice.h
//  ThingsIWant
//
//  Created by Kent on 11/30/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKPrice : NSObject<NSCoding>
-(instancetype)initWithDictionary:(NSDictionary *)dict;
@property (nonatomic) float value;
@property (nonatomic, strong) NSString * note;
-(NSDictionary *)getDictionaryObject;
@end
