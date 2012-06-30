//
//  CountIndicator.h
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountIndicator : UIView {
	CGFloat fontSize;
	CGFloat width;
	NSMutableString *indicatorText;
}

@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat width;
@property (nonatomic, retain) NSMutableString *indicatorText;

- (id)initWithPoint:(CGPoint)xy andFontSize:(CGFloat)fs andWidth:(CGFloat)wth;

@end