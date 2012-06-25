//
//  MSPResponse.h
//  PortSite
//
//  Created by ming lin on 4/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPDataResponse.h"

@interface MSPResponse : HTTPDataResponse
{
    NSDictionary *headers;
}


- (id)initWithData:(NSData *)dataParam headers:(NSDictionary *)_headers;

@end
