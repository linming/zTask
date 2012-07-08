//
//  ToggleImageControl.m
//  zTask
//
//  Created by ming lin on 6/28/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "ToggleImageControl.h"

@implementation ToggleImageControl

- (id)initWithFrame:(CGRect)frame status:(BOOL)status
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        normalImage = [UIImage imageNamed: @"uncheck.png"];
        selectedImage = [UIImage imageNamed: @"check.png"];
        imageView = [[UIImageView alloc] initWithImage: (status ? selectedImage : normalImage)];
        [imageView setFrame:CGRectMake(0, 0, 24, 24)];
        [self addSubview:imageView];
        
        [self addTarget:self action:@selector(toggleImage) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"ToggleImageControl viewDidLoad");
}

- (void)toggleImage {
    NSLog(@"ToggleImageControl toggleImage");
    isSelected = !isSelected;
    imageView.image = (isSelected ? selectedImage : normalImage); 
    
    // Use NSNotification or other method to notify data model about state change.
    // Notification example:
    NSDictionary *dict = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: self.tag] forKey: @"CellCheckToggled"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CellCheckToggled" object: self userInfo: dict];
    
}

- (BOOL)isSelected
{
    return isSelected;
}

- (void)setIsSelected:(BOOL)_isSelected
{
    isSelected = _isSelected;
    imageView.image = (isSelected ? selectedImage : normalImage); 
}

@end
