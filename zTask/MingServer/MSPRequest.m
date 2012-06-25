//
//  MSPRequest.m
//  PortSite
//
//  Created by ming lin on 4/16/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "MSPRequest.h"
#import "FileUtil.h"

@implementation MSPRequest

@synthesize message, uri, filePath, documentRoot, relativePath, uploadFilePath, uploadFileUri, params;

- (id)initWithMessage:(HTTPMessage *)newMessage uri:(NSString *)newUri filePath:(NSString *)newFilePath documentRoot:(NSString *)newDocumentRoot relativePath:(NSString *)newRelativePath
{
    self.message = newMessage;
    self.uri = newUri;
    self.filePath = newFilePath;
    self.documentRoot = newDocumentRoot;
    self.relativePath = newRelativePath;
    
    params = [NSMutableDictionary dictionary];
    
    //parse cookie
    if ([message headerField:@"Cookie"]) {
        NSString *cookie = [message headerField:@"Cookie"];
        NSArray *chunks = [cookie componentsSeparatedByString:@";"];
        for (NSString *chunk in chunks) {
            NSArray *kv = [chunk componentsSeparatedByString:@"="];
            if ([kv count] == 2) {
                [params setObject:[kv objectAtIndex:1] forKey:[kv objectAtIndex:0]];
            }
        }
    }
    
    //process file upload
    NSString *filename = nil;
    if ([message headerField:@"file_fileName"]) {
        filename = [message headerField:@"file_fileName"];
    } else if ([message headerField:@"file_name"]) {
        filename = [message headerField:@"file_name"];
    }
    
    if (filename) {
        filename = [FileUtil getRandomFilename:filename];
        //NSLog(@"new filename: %@", filename);
        uploadFileUri = [NSString stringWithFormat:@"/files/tmp/%@", filename];
        uploadFilePath = [FileUtil getFilePath:uploadFileUri];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error; 

        BOOL ret = [fileManager createDirectoryAtPath:[FileUtil getFilePath:@"/files/tmp"] withIntermediateDirectories:true attributes:nil error:nil];
        if (!ret) {
            NSLog(@"create dir error: %@", [error localizedDescription]);
        }
        //NSLog(@"uploadFilePath: %@", uploadFilePath);
        ret = [fileManager createFileAtPath:uploadFilePath contents:[message body] attributes:nil];
        if (!ret) {
            NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
        }
    }
    
    //parse get query
    
    if (message.url.query) {
        NSArray *chunks = [message.url.query componentsSeparatedByString:@"&"];
        for (NSString *chunk in chunks) {
            NSArray *kv = [chunk componentsSeparatedByString:@"="];
            if ([kv count] == 2) {
                NSString *value = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [params setObject:value forKey:[kv objectAtIndex:0]];
            }
        }
    }
    
    //parse post body
    if (message.body) {
        NSString *postStr = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
        NSArray *chunks = [postStr componentsSeparatedByString:@"&"];
        for (NSString *chunk in chunks) {
            NSArray *kv = [chunk componentsSeparatedByString:@"="];
            if ([kv count] == 2) {
                NSMutableString *s = [NSMutableString stringWithString:[kv objectAtIndex:1]];
                [s replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [s length])];
                NSString *value = [s stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [params setObject:value forKey:[kv objectAtIndex:0]];
            }
        }
    }
    
    return self;
}

@end
