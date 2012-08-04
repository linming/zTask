//
//  ToggleImageControl.h
//  zTask
//
//  Created by ming lin on 6/28/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToggleImageDelegate

- (void)imageToggled:(BOOL)status;

@end

@interface ToggleImageControl : UIControl
{
    UIImageView *imageView;
    UIImage *normalImage;
    UIImage *selectedImage;
    BOOL isSelected;
}

@property (nonatomic, assign) id<ToggleImageDelegate> delegate;

- (id)initWithFrame:(CGRect)frame status:(BOOL)status;

- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)_isSelected;

@end
