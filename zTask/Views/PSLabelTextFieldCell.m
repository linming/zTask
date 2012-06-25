//
//  PSLabelTextFieldCell.m
//  PortSite
//
//  Created by ming lin on 6/11/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "PSLabelTextFieldCell.h"

@implementation PSLabelTextFieldCell

@synthesize textField = _textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_textField];
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
    r.origin.x += self.textLabel.frame.size.width + 6;
    r.origin.y = 10;
    r.size.width -= self.textLabel.frame.size.width + 6;
    _textField.frame = r;
}

@end
