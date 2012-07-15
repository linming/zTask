//
//  ZoomImageView.h
//  iKM
//
//  Created by Joseph on 11-10-20.
//  Copyright 2011年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZoomImageView: UIScrollView <UIScrollViewDelegate>
{
	UIImage *image;
	UIImageView *imageView;
    float minZoomSize;
    float maxZoomSize;
    float originalZoomSize;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imageView;
@property float minZoomSize;
@property float maxZoomSize;
@property float originalZoomSize;
@property BOOL needZoom;

- (id)initWithFrame:(CGRect)frame withImageView:_imageView;
- (void) calculateZoomSize:(UIImage *)_image;
- (void) showOriginalImageWithoutZoom;
- (void) showImageWithZoom;
@end