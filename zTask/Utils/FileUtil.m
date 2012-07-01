//
//  FileUtil.m
//  PortSite
//
//  Created by ming lin on 4/23/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "FileUtil.h"
#import "Utils.h"

@implementation FileUtil

+ (NSString *)getWebRoot
{
    //return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    return @"/Users/linming/Develop/zTask/zTask/Web";
}

+ (NSString *)getMspRoot
{
    //return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Msp"];
    return @"/Users/linming/Develop/zTask/zTask/Msp";
}

+ (NSString *)getFilePath:(NSString *)relativePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:relativePath];
}

+ (NSString *)makeFilePath:(NSString *)relativePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [FileUtil getFilePath:relativePath];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

+ (NSArray *)listSubDir:(NSString *)dir;
{
    NSString *fullPath = [FileUtil getFilePath:dir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager subpathsOfDirectoryAtPath:fullPath error:nil];
    NSMutableArray *subdirs = [NSMutableArray arrayWithCapacity:10];
    
    for(NSString *file in files) {
        NSString *path = [fullPath stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
        if(isDir) {
            [subdirs addObject:file];
        }
    }
    
    return [subdirs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF like %@)", @"*/*"]];
}

+ (NSArray *)listFiles:(NSString *)path
{
    NSString *fullPath = [FileUtil getFilePath:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager subpathsOfDirectoryAtPath:fullPath error:nil];
}

+ (NSArray *)listImageFiles:(NSString *)path
{
    NSString *fullPath = [FileUtil getFilePath:path];
    NSArray *extensions = [NSArray arrayWithObjects:@"jpg", @"JPG", @"png", @"PNG", @"gif", @"GIF", @"bmp", @"BMP", nil];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:nil];
    return [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", extensions]];
}

+ (NSArray *)listFilesWithFullPath:(NSString *)path
{
    NSString *fullPath = [FileUtil getFilePath:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager subpathsOfDirectoryAtPath:fullPath error:nil];
    NSMutableArray *fsarray = [NSMutableArray array];
    for (NSString *file in files) {
        [fsarray addObject:[fullPath stringByAppendingPathComponent:file]];
    }
    return [fsarray copy];
}


+ (NSString *)getMspPath:(NSString *)relativePath
{
    NSString *mspPath = [FileUtil getMspRoot];
    return [NSString stringWithFormat:@"%@%@.msp", mspPath, relativePath]; 
}

+ (BOOL)moveFiles:(NSString *)srcPath target:(NSString *)targetPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager subpathsAtPath:srcPath];
    for (NSString *file in files) {
        NSError *error; 
        NSString *srcFile = [NSString stringWithFormat:@"%@/%@", srcPath, file];
        NSString *destFile = [NSString stringWithFormat:@"%@/%@", targetPath, file];
        BOOL ret = [fileManager moveItemAtPath: srcFile toPath:destFile error:&error];
        if (!ret) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    return YES;
}

+ (NSArray *)moveUploadPhotos:(NSString *)srcPath target:(NSString *)targetPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *oriDir = [targetPath stringByAppendingPathComponent:@"ori"];
    if (![fileManager fileExistsAtPath:oriDir]) {
        [fileManager createDirectoryAtPath:oriDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *thumbDir = [targetPath stringByAppendingPathComponent:@"thumb"];
    if (![fileManager fileExistsAtPath:thumbDir]) {
        [fileManager createDirectoryAtPath:thumbDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSArray *files = [fileManager subpathsAtPath:srcPath];
    for (NSString *file in files) {
        NSError *error; 
        NSString *srcFile = [srcPath stringByAppendingPathComponent:file];
        
        NSString *destFile = [oriDir stringByAppendingPathComponent:file];
        BOOL ret = [fileManager moveItemAtPath: srcFile toPath:destFile error:&error];
        if (!ret) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        //create thumb files
        UIImage *oriImage = [UIImage imageWithContentsOfFile:destFile];
        UIImage *thumbImage = [Utils resizeImage:oriImage scaledToSizeWithSameAspectRatio:CGSizeMake(160, 160)];
        
        NSString *thumbFile = [thumbDir stringByAppendingPathComponent:file];
        if ([[destFile pathExtension] isEqualToString:@"png"]) {
            [UIImagePNGRepresentation(thumbImage) writeToFile:thumbFile atomically:YES];
        } else {
            [UIImageJPEGRepresentation(thumbImage, 1.0) writeToFile:thumbFile atomically:YES];
        }        
    }
    return files;
}


+ (NSString *)getRandomFilename:(NSString *)filename
{
    NSRange range = [filename rangeOfString:@"." options:NSBackwardsSearch];
    srand(time(0));
    if (range.location != NSNotFound){
        return [NSString stringWithFormat:@"%@_%d%@", [filename substringToIndex:range.location], (rand()%100 + 1), [filename substringFromIndex:range.location]];
    } else {
        return filename;
    }
}

+ (void)clearTmpFile
{
    [FileUtil removeAllSubFiles:@"/files/tmp"];
    [FileUtil removeAllSubFiles:@"/files/packages"];
}

+ (void)removeAllSubFiles:(NSString *)dir
{
    NSString *tmpUploadPath = [FileUtil getFilePath:dir];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *tmpFiles = [fileManager subpathsOfDirectoryAtPath:tmpUploadPath error:nil];
    for (NSString *tmpFile in tmpFiles) {
        NSString *path = [tmpUploadPath stringByAppendingPathComponent:tmpFile];
        [fileManager removeItemAtPath:path error:nil];
    }
}


@end
