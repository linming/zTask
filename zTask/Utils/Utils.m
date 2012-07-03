//
//  Utils.m
//  PortSite
//
//  Created by ming lin on 4/23/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "Utils.h"
#import <ifaddrs.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <math.h>
#import "Reachability.h"

#define kDefaultPortNumber @"12345"

static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation Utils


+ (BOOL)isEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

+ (BOOL)isEnable3G {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

+ (NSDictionary *)localAddress
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	struct ifaddrs *addrs;
	BOOL success = (getifaddrs(&addrs) == 0);
	if (success) {
		const struct ifaddrs* cursor = addrs;
		while (cursor != NULL) {
			NSMutableString *ip;
			if (cursor->ifa_addr->sa_family == AF_INET) {
				const struct sockaddr_in *dlAddr = (const struct sockaddr_in *)cursor->ifa_addr;
				const uint8_t *base = (const uint8_t *)&dlAddr->sin_addr;
				ip = [NSMutableString new];
				for (int i = 0; i < 4; i++) {
					if (i != 0) 
						[ip appendFormat:@"."];
					[ip appendFormat:@"%d", base[i]];
				}
				[result setObject:(NSString*)ip forKey:[NSString stringWithFormat:@"%s", cursor->ifa_name]];
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
    return [result copy];
}

+ (NSInteger)getPortNumber
{
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_PORT"];
    if (!port) {
        port = kDefaultPortNumber;
        [[NSUserDefaults standardUserDefaults] setObject:port forKey:@"PORTSITE_PORT"];
    }
    return [port intValue];
}


+ (UIImage*)resizeImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
{  
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }     
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }   
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}



+ (NSString *)getPaginationHtml:(NSString *)url total:(NSInteger)total perPage:(NSInteger)perPage currentPage:(NSInteger)currentPage
{
    if (total <= perPage) {
        return @"";
    }
    if (!currentPage) {
        currentPage = 1;  
    }
    NSInteger pageCount = ceil((float)total / (float)perPage);
    
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"<div class='pagination pagination-right'><ul>"];
    
    if (pageCount <= 12 ) {
        if (currentPage == 1) {
            [str appendString:@"<li class='prev disabled'><a href='#'>«</a></li>"];
        } else {
            [str appendString:[NSString stringWithFormat:@"<li class='prev'><a href='%@?page=%d'>«</a></li>", url, currentPage - 1]];
        }
        
        for (int i = 1; i <= pageCount; i++) {
            if (i == currentPage) {
                [str appendString:[NSString stringWithFormat:@"<li class='active'><a href='#'>%d</a></li>", i]];
            } else {
                [str appendString:[NSString stringWithFormat:@"<li><a href='%@?page=%d'>%d</a></li>", url, i, i]];
            }
            
        }
        
        if (currentPage == pageCount) {
            [str appendString:@"<li class='next disabled'><a href='#'>»</a></li>"];
        } else {
            [str appendString:[NSString stringWithFormat:@"<li class='next'><a href='%@?page=%d'>»</a></li>", url, currentPage + 1]];
        }
    } else {
        if (currentPage <= 5) {
            if (currentPage == 1) {
                [str appendString:@"<li class='prev disabled'><a href='#'>«</a></li>"];
            } else {
                [str appendString:[NSString stringWithFormat:@"<li class='prev'><a href='%@?page=%d'>«</a></li>", url, currentPage - 1]];
            }
            
            for (int i = 1; i <= currentPage + 5; i++) {
                if (i == currentPage) {
                    [str appendString:[NSString stringWithFormat:@"<li class='active'><a href='#'>%d</a></li>", i]];
                } else {
                    [str appendString:[NSString stringWithFormat:@"<li><a href='%@?page=%d'>%d</a></li>", url, i, i]];
                }
            }
            [str appendString:@"<li><a href='#'>...</a></li>"];
            [str appendString:[NSString stringWithFormat:@"<li><a href='/pages/index?page=%d'>%d</a></li>", pageCount, pageCount]];
            [str appendString:[NSString stringWithFormat:@"<li class='next'><a href='/pages/index?page=%d'>»</a></li>", currentPage + 1]];
        } else if (currentPage > 5 && currentPage < pageCount - 5) {
            [str appendString:[NSString stringWithFormat:@"<li class='prev'><a href='%@?page=%d'>«</a></li>", url, currentPage - 1]];
            [str appendString:[NSString stringWithFormat:@"<li><a href='%@?page=1'>1</a></li>", url]];
            [str appendString:@"<li><a href='#'>...</a></li>"];
            for (int i = currentPage - 5; i <= currentPage + 5; i++) {
                if (i == currentPage) {
                    [str appendString:[NSString stringWithFormat:@"<li class='active'><a href='#'>%d</a></li>", i]];
                } else {
                    [str appendString:[NSString stringWithFormat:@"<li><a href='%@?page=%d'>%d</a></li>", url, i, i]];
                }
            }
            [str appendString:@"<li><a href='#'>...</a></li>"];
            [str appendString:[NSString stringWithFormat:@"<li><a href='%@?page=%d'>%d</a></li>", url, pageCount, pageCount]];
            [str appendString:[NSString stringWithFormat:@"<li class='next'><a href='%@?page=%d'>»</a></li>", url, currentPage + 1]];
        } else {
            [str appendString:[NSString stringWithFormat:@"<li class='prev'><a href='%@?page=%d'>«</a></li>", url, currentPage - 1]];
            [str appendString:[NSString stringWithFormat:@"<li><a href='%@?page=1'>1</a></li>", url]];
            [str appendString:@"<li><a href='#'>...</a></li>"];
            for (int i = currentPage - 5; i <= pageCount; i++) {
                if (i == currentPage) {
                    [str appendString:[NSString stringWithFormat:@"<li class='active'><a href='#'>%d</a></li>", i]];
                } else {
                    [str appendString:[NSString stringWithFormat:@"<li><a href='%@?page=%d'>%d</a></li>", url, i, i]];
                }
            }
            if (currentPage == pageCount) {
                [str appendString:@"<li class='next disabled'><a href='#'>»</a></li>"];
            } else {
                [str appendString:[NSString stringWithFormat:@"<li class='next'><a href='%@?page=%d'>»</a></li>", url, currentPage + 1]];
            }
        }
    }
    [str appendString:@"</ul></div>"];
    return str;
}

+ (NSString *)getProverb
{
    NSArray *proverbs = [NSArray arrayWithObjects:
                         @"Stray birds of summer come to my window to sing and fly away. \n And yellow leaves of autumn, which have no songs, flutter and fall there with a sign.", 
                         @"O troupe of little vagrants of the world, leave your footprints in my words.",
                         @"The world puts off its mask of vastness to its lover.\n It becomes small as one song, as one kiss of the eternal. ",
                         @"It is the tears of the earth that keep here smiles in bloom. ",
                         @"The mighty desert is burning for the love of a bladeof grass who shakes her head and laughs and flies away. ",
                         @"If you shed tears when you miss the sun, you also miss the stars. ",
                         @"The sands in your way beg for your song and your movement, dancing water. Will you carry the burden of their lameness? ",
                         @"Her wishful face haunts my dreams like the rain at night. ",
                         @"Once we dreamt that we were strangers. \n We wake up to find that we were dear to each other. ",
                         @"Sorrow is hushed into peace in my heart like the evening among the silent trees. ",
                         nil];
    srand(time(NULL));
    return [proverbs objectAtIndex:rand()%10];
}

+ (void)alertWithMessage:(NSString *)message
{
    /* open an alert with an OK button */
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PortSite" 
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
}
@end
