//
//  CountIndicator.m
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "CountIndicator.h"

#define    kIndColor_R     0.5f
#define    kIndColor_G     0.5f
#define    kIndColor_B     0.5f
#define    kIndColor_A     1.0f

@implementation CountIndicator

@synthesize fontSize, width, indicatorText;

// Initialise
- (id)initWithPoint:(CGPoint)xy andFontSize:(CGFloat)fs andWidth:(CGFloat)wth
{
	// Set up the frame
	CGRect frame;
	frame.origin.x = xy.x;
	frame.origin.y = xy.y;
	frame.size.width = wth;
	frame.size.height = fs;
    
	// Get initialised with given frame size and set defaults
	if (self = [super initWithFrame:frame]) {
		self.fontSize = fs;
		self.indicatorText = [NSMutableString stringWithFormat:@""];
	}
    
	return self;
}

// Custom drawing
- (void)drawRect:(CGRect)rect
{
	// Get graphics context
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// Calculate line position
	CGFloat startPosX = rect.size.height / 2;
	CGFloat startPosY = rect.size.height / 2;
	CGFloat endPosX = rect.size.width - startPosX;
	CGFloat endPosY = startPosY;
    
	// Get the size of the text area based on the string (we need this to centre the text)
	CGSize textSize = [self.indicatorText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:self.fontSize]];
    
	// Set the stroke colour
	CGContextSetRGBStrokeColor(context, kIndColor_R, kIndColor_G, kIndColor_B, kIndColor_A);
    
	// Draw the line and cap the ends
	CGContextMoveToPoint(context, startPosX, startPosY);
	CGContextAddLineToPoint(context, endPosX, endPosY);	
	CGContextSetLineWidth(context, rect.size.height);	
	CGContextSetLineCap(context, 1);
	CGContextStrokePath(context);
    
	// Show text
	CGAffineTransform transform = CGAffineTransformMake( 1.0,0.0, 0.0, -1.0, 0.0, 0.0  );
	CGContextSetTextMatrix(context, transform);
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSelectFont(context, "Helvetica", self.fontSize, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode(context, kCGTextFill);
    
	// Center the text in the indicator bubble
	CGContextSetTextPosition(context, (rect.size.width/2)-(textSize.width/2), (rect.size.height) - 2.0f );
	CGContextSetShouldSmoothFonts(context, false);
	CGContextShowText(context, [self.indicatorText UTF8String], strlen([self.indicatorText UTF8String]));
}

@end
