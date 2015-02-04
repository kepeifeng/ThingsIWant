//
//  UIFont+Customize.m
//  ThingsIWant
//
//  Created by Kent Peifeng Ke on 2/4/15.
//  Copyright (c) 2015 Kent. All rights reserved.
//

#import "UIFont+Customize.h"

@implementation UIFont (Customize)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (UIFont *)systemFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:size];
}

+ (UIFont *)lightSystemFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:size];
}

+ (UIFont *)boldSystemFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:size];
}

+ (UIFont *)preferredFontForTextStyle:(NSString *)style
{
    if ([style isEqualToString:UIFontTextStyleBody])
        return [UIFont systemFontOfSize:17];
    if ([style isEqualToString:UIFontTextStyleHeadline])
        return [UIFont boldSystemFontOfSize:17];
    if ([style isEqualToString:UIFontTextStyleSubheadline])
        return [UIFont systemFontOfSize:15];
    if ([style isEqualToString:UIFontTextStyleFootnote])
        return [UIFont systemFontOfSize:13];
    if ([style isEqualToString:UIFontTextStyleCaption1])
        return [UIFont systemFontOfSize:12];
    if ([style isEqualToString:UIFontTextStyleCaption2])
        return [UIFont systemFontOfSize:11];
    return [UIFont systemFontOfSize:17];
}

#pragma clang diagnostic pop

@end