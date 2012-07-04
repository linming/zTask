//
//  MenuCell.m
//  zTask
//
//  Created by ming lin on 7/5/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSLog(@"set accessoryType");
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"frame: %@", self.accessoryView.frame);
    
    CGRect r = self.accessoryView.frame;
    r.origin.x -= 120;
    self.accessoryView.frame = r;
    NSLog(@"set layoutSubviews");
    if (self.accessoryView) {
        NSLog(@"has accessory view");
        CGRect r = self.accessoryView.frame;
        r.origin.x -= 120;
        self.accessoryView.frame = r;
    } else {
        UIView* defaultAccessoryView = nil;
        for (UIView* subview in self.subviews) {
            if (subview != self.textLabel && 
                subview != self.detailTextLabel && 
                subview != self.backgroundView && 
                subview != self.contentView &&
                subview != self.selectedBackgroundView &&
                subview != self.imageView) {
                defaultAccessoryView = subview;
                break;
            }
        }
        CGRect r = defaultAccessoryView.frame;
        r.origin.x -= 8;
        defaultAccessoryView.frame = r;
    }

}

@end
