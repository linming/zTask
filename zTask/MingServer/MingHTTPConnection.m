//
//  MingHTTPConnection.m
//  PortSite
//
//  Created by ming lin on 4/3/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "MingHTTPConnection.h"
#import "MSPFileResponse.h"
#import "HTTPRedirectResponse.h"
#import "HTTPLogging.h"
#import "MSPDispatcher.h"
#import "FileUtil.h"

@implementation MingHTTPConnection

// Log levels: off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	NSString *filePath = [self filePathForURI:path];
	NSString *documentRoot = [config documentRoot];
	NSString *relativePath = [filePath substringFromIndex:[documentRoot length]];
    
    NSLog(@"uri: %@", path);
    
    if ([path isEqualToString:@"/"]) {
        return [[HTTPRedirectResponse alloc] initWithPath:@"/tasks/index"];
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [[MSPFileResponse alloc] initWithFilePath:filePath forConnection:self];
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:[FileUtil getFilePath:relativePath]]) {
        return [[HTTPFileResponse alloc] initWithFilePath:[FileUtil getFilePath:relativePath] forConnection:self];
    } else {
        MSPRequest *mspRequest = [[MSPRequest alloc] initWithMessage:request                                                  
                                                                 uri:path 
                                                            filePath:filePath 
                                                        documentRoot:documentRoot 
                                                        relativePath:relativePath];

        MSPDispatcher *dispatcher = [[MSPDispatcher alloc] init];
        
        id mspResponse = [dispatcher dispatch:mspRequest];
        if (mspResponse) {
            return mspResponse;
        }
    }
	
	return [super httpResponseForMethod:method URI:path];
}


- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)relativePath
{
	return YES;
}

- (void)processBodyData:(NSData *)postDataChunk
{
    [request appendData:postDataChunk];    
}

@end
