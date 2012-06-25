//
//  ApisMSPController.h
//  PortSite
//
//  Created by ming lin on 4/19/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "MSPController.h"
#import "AppDelegate.h"
#import "MSPRedirectResponse.h"

@interface ApisMSPController : MSPController

- (MSPRedirectResponse *)login;
- (HTTPDataResponse *)upload;

- (HTTPDataResponse *)need_passcode;
- (HTTPDataResponse *)verify_passcode;

@end
