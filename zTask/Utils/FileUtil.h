//
//  FileUtil.h
//  PortSite
//
//  Created by ming lin on 4/23/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

+ (NSString *)getWebRoot;

+ (NSString *)getMspRoot;

+ (NSString *)getFilePath:(NSString *)relativePath;

+ (NSString *)makeFilePath:(NSString *)relativePath;

+ (NSArray *)listSubDir:(NSString *)dir;

+ (NSArray *)listFiles:(NSString *)path;

+ (NSArray *)listImageFiles:(NSString *)path;

+ (NSArray *)listFilesWithFullPath:(NSString *)path;

+ (NSString *)getMspPath:(NSString *)relativePath;

+ (BOOL)moveFiles:(NSString *)srcPath target:(NSString *)targetPath;

+ (NSArray *)moveUploadPhotos:(NSString *)srcPath target:(NSString *)targetPath;

+ (NSString *)getRandomFilename:(NSString *)filename;

+ (void)clearTmpFile;

+ (void)removeAllSubFiles:(NSString *)dir;

@end
