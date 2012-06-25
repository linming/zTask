//
//  MSPResponse.m
//  PortSite
//
//  Created by ming lin on 4/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "MSPResponse.h"
#import "AppDelegate.h"

@implementation MSPResponse

- (id)initWithData:(NSData *)dataParam headers:(NSDictionary *)_headers
{
	if((self = [super initWithData:dataParam])) {
        headers = _headers;
	}
	return self;
}


- (NSDictionary *)httpHeaders
{
    return headers;
}
 

@end
