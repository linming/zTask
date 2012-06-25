//
//  MSPFileResponse.m
//  PortSite
//
//  Created by ming lin on 6/3/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "MSPFileResponse.h"

@implementation MSPFileResponse

- (NSDictionary *)httpHeaders
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@"max-age=28800", @"Cache-Control", nil];
}


@end
