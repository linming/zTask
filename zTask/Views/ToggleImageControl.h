//
//  ToggleImageControl.h
//  zTask
//
//  Created by ming lin on 6/28/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToggleImageControl : UIControl
{
    UIImageView *imageView;
    UIImage *normalImage;
    UIImage *selectedImage;
    BOOL isSelected;
}


- (id)initWithFrame:(CGRect)frame status:(BOOL)status;

- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)_isSelected;

@end
