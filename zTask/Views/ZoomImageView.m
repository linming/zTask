//
//  ZoomImageView.m
//  iKM
//
//  Created by Joseph on 11-10-20.
//  Copyright 2011年 tencent. All rights reserved.
//

#import "ZoomImageView.h"


@implementation ZoomImageView


@synthesize image, imageView, minZoomSize, maxZoomSize, originalZoomSize, needZoom;


#pragma mark -
#pragma mark === Intilization ===
#pragma mark -
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		self.delegate = self;
		self.minimumZoomScale = 0.5;
		self.maximumZoomScale = 2.5;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
        self.scrollEnabled = YES;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
		
		imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		imageView.contentMode = UIViewContentModeCenter;
		[self addSubview:imageView];

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer: singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer: doubleTap];
        
        [singleTap requireGestureRecognizerToFail: doubleTap];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageView:(UIImageView *)_imageView
{
    if ((self = [super initWithFrame:frame])) {
		self.delegate = self;
		self.minimumZoomScale = 0.5;
		self.maximumZoomScale = 2.5;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
        //self.contentSize = CGSizeMake(1000, 1000);
        
        self.opaque = NO;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
		
        needZoom = YES;
        
		imageView = _imageView;
        imageView.frame = CGRectMake(0, 0, 320, 480);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
		//imageView.contentMode = UIViewContentModeCenter;
		[self addSubview:imageView];
        
        [self calculateZoomSize:imageView.image];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer: singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer: doubleTap];
        
        [singleTap requireGestureRecognizerToFail: doubleTap];
    }
    return self;
}

- (void)calculateZoomSize:(UIImage *)_image{
    originalZoomSize = MAX(_image.size.height/self.frame.size.height, _image.size.width/self.frame.size.width);
    maxZoomSize = MAX(originalZoomSize, 2.0);
    minZoomSize = 1.0;
    
    if (originalZoomSize <= 1.0) {
        [self showOriginalImageWithoutZoom];
    } else {
        [self showImageWithZoom];
    }
}

- (void)showOriginalImageWithoutZoom {
    needZoom = NO;
    self.zoomScale = originalZoomSize;
    [imageView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    imageView.contentMode = UIViewContentModeCenter;
}

- (void)showImageWithZoom {
    needZoom = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark -
#pragma mark === UIScrollView Delegate ===
#pragma mark -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{	
    if (needZoom) {
        return imageView;
    } else {
        return nil;
    }
	
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if (needZoom) {
        //NSLog(@"%s", _cmd);
        CGFloat zs = scrollView.zoomScale;
        zs = MAX(zs, minZoomSize);
        zs = MIN(zs, maxZoomSize);	
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];		
        scrollView.zoomScale = zs;	
        [UIView commitAnimations];
    }
}

#pragma mark -

#pragma mark - UIGestureRecognizer
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    self.frame = CGRectZero;
    [self removeFromSuperview];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    if (needZoom) {
        CGFloat zs = self.zoomScale;
        CGFloat fitZoomSize = MIN(MAX(MIN(originalZoomSize, maxZoomSize), self.minimumZoomScale), self.maximumZoomScale);
        zs = (zs == fitZoomSize) ? minZoomSize : fitZoomSize;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];			
        self.zoomScale = zs;	
        [UIView commitAnimations];
    }
}

@end
