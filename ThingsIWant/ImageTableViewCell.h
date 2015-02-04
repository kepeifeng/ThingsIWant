//
//  ImageTableViewCell.h
//  ThingsIWant
//
//  Created by Kent Peifeng Ke on 2/4/15.
//  Copyright (c) 2015 Kent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableViewCell : UITableViewCell

@property (nonatomic) NSInteger numberOfImagesPerRow;
@property (nonatomic) NSArray * images;
@property (nonatomic) CGSize imageSize;
//@property (nonatomic) CGFloat topMargin;
@end
