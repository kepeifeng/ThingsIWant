//
//  HTProgressHUDImageIndicatorView.m
//  2bulu-QuanZi
//
//  Created by Kent Peifeng Ke on 14-8-26.
//  Copyright (c) 2014年 Lolaage. All rights reserved.
//

#import "HTProgressHUDImageIndicatorView.h"

@implementation HTProgressHUDImageIndicatorView{
    UIImageView * _imageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(instancetype)initWithImage:(UIImage *)image{

    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.tintColor = self.tintColor;
    self = [super initWithCustomView:imageView];
    if (self) {
        
        _imageView = imageView;
        self.image = image;
        
    }
    return self;
}
-(void)setTintColor:(UIColor *)tintColor{
    [super setTintColor:tintColor];
    [_imageView setTintColor:tintColor];
}

-(void)setImage:(UIImage *)image{
    _imageView.image = image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
