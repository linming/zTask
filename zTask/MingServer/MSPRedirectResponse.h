//
//  MSPRedirectResponse.h
//  PortSite
//
//  Created by ming lin on 4/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRedirectResponse.h"

@interface MSPRedirectResponse : HTTPRedirectResponse
{
	NSString *cookie;
}

- (id)initWithPath:(NSString *)redirectPath cookie:(NSString *)cookie;

@end
