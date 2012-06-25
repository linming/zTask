//
//  PSLabelSwitchCell.m
//  PortSite
//
//  Created by ming lin on 6/11/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "PSLabelSwitchCell.h"

@implementation PSLabelSwitchCell

@synthesize switcher=_switcher;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
        
        [self.contentView addSubview:_switcher];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    CGRect r = CGRectInset(self.contentView.bounds, 8, 8);
    r.origin.x = self.contentView.frame.size.width - _switcher.frame.size.width - 10;
    _switcher.frame = r;
}

@end
