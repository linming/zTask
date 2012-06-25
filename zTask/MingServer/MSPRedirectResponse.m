//
//  MSPRedirectResponse.m
//  PortSite
//
//  Created by ming lin on 4/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "MSPRedirectResponse.h"

@implementation MSPRedirectResponse

- (id)initWithPath:(NSString *)_redirectPath cookie:(NSString *)_cookie
{
    if ((self = [super initWithPath:_redirectPath]))
	{
        cookie = _cookie;
	}
	return self;
}

- (NSDictionary *)httpHeaders
{
	return [NSDictionary dictionaryWithObjectsAndKeys:redirectPath, @"Location", cookie, @"Set-cookie", nil];
}

@end
