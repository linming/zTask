//
//  Utils.h
//  PortSite
//
//  Created by ming lin on 4/23/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (BOOL)isEnableWIFI;

+ (BOOL)isEnable3G;

+ (NSDictionary *)localAddress;

+ (NSInteger)getPortNumber;

+ (UIImage *)resizeImage:(UIImage *)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;

+ (NSString *)getPaginationHtml:(NSString *)url total:(NSInteger)total perPage:(NSInteger)perPage currentPage:(NSInteger)currentPage;

+ (NSString *)getProverb;

+ (void)alertWithMessage:(NSString *)message;

@end
