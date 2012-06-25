//
//  MSPRequest.h
//  PortSite
//
//  Created by ming lin on 4/16/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPMessage.h"

@interface MSPRequest : NSObject

@property(nonatomic, retain) HTTPMessage *message;
@property(nonatomic, retain) NSString *uri;
@property(nonatomic, retain) NSString *filePath;
@property(nonatomic, retain) NSString *documentRoot;
@property(nonatomic, retain) NSString *relativePath;

@property(nonatomic, retain) NSString *uploadFilePath;
@property(nonatomic, retain) NSString *uploadFileUri;

@property(nonatomic, retain) NSMutableDictionary *params;

- (id)initWithMessage:(HTTPMessage *)message uri:(NSString *)uri filePath:(NSString *)filePath documentRoot:(NSString *)documentRoot relativePath:(NSString *)relativePath;

@end
