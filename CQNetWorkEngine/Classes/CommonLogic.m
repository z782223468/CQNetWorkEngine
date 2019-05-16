//
//  CommonLogic.m
//  NTSociety
//
//  Created by retygu on 14-8-19.
//  Copyright (c) 2014年 rety gu. All rights reserved.
//

#import "CommonLogic.h"

@implementation CommonLogic


//裁剪图片 大于600*600 裁剪
+ (NSData *)imageWithImage:(UIImage*)image
{
    UIImage *sourceImage = image;
    if( sourceImage == nil ) NSLog(@"input image not found!");
    CGSize sourceResolution;
    sourceResolution.width = CGImageGetWidth(sourceImage.CGImage);
    sourceResolution.height = CGImageGetHeight(sourceImage.CGImage);
    float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
    CGSize newSize;
    newSize.width = CGImageGetWidth(sourceImage.CGImage);
    newSize.height = CGImageGetHeight(sourceImage.CGImage);
    if(sourceTotalPixels > 360000)
    {
        newSize.width = 600 * sourceResolution.width / (sqrt(sourceTotalPixels));
        
        newSize.height = 600 * sourceResolution.height / (sqrt(sourceTotalPixels));
    }
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return UIImageJPEGRepresentation(newImage,0.5);
    
}


@end
