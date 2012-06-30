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
    BOOL selected;
    UIImageView *imageView;
    UIImage *normalImage;
    UIImage *selectedImage;
}

@end
