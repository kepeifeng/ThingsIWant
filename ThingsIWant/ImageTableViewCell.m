//
//  ImageTableViewCell.m
//  ThingsIWant
//
//  Created by Kent Peifeng Ke on 2/4/15.
//  Copyright (c) 2015 Kent. All rights reserved.
//

#import "ImageTableViewCell.h"


@implementation ImageTableViewCell
{
    NSArray * _imageViews;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageSize = CGSizeMake(64, 64);
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    

}

-(void)setNumberOfImagesPerRow:(NSInteger)numberOfImagesPerRow{

    _numberOfImagesPerRow = numberOfImagesPerRow;
    [_imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray * imageViews = [[NSMutableArray alloc] initWithCapacity:self.numberOfImagesPerRow];
    CGFloat margin = (CGRectGetWidth(self.bounds)+self.imageSize.width)/(self.numberOfImagesPerRow+1) - self.imageSize.width;
    
    CGRect imageViewRect = CGRectMake(margin, (CGRectGetHeight(self.bounds)-self.imageSize.height)/2,
                                      self.imageSize.width, self.imageSize.height);
    
    for (NSInteger i = 0; i<self.numberOfImagesPerRow; i++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:(imageViewRect)];
        [self.contentView addSubview:imageView];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [imageViews addObject:imageView];
        imageViewRect.origin.x += self.imageSize.width + margin;
        
    }
    
    _imageViews = imageViews;
}



-(void)setImages:(NSArray *)images{

    _images = images;
    for (NSInteger i = 0; i< self.numberOfImagesPerRow; i++) {
        
        UIImageView * imageView = [_imageViews objectAtIndex:i];
        if (i<images.count) {
            imageView.image = [images objectAtIndex:i];
            imageView.hidden = NO;
        }else{
            imageView.image = nil;
            imageView.hidden = YES;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
