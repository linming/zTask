//
//  MSPDispatcher.h
//  PortSite
//
//  Created by ming lin on 4/8/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPResponse.h"
#import "MSPRequest.h"
#import "HTTPRedirectResponse.h"

@interface MSPDispatcher : NSObject

- (id)dispatch:(MSPRequest *)request;;

@end
