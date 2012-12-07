//
//  UIImage+WizTools.m
//  Wiz
//
//  Created by 朝 董 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIImage+WizTools.h"
#define MAX_IMAGEPIX 200.0          // max pix 200.0px  
#define MAX_IMAGEDATA_LEN 50000.0   // max data length 5K
@implementation UIImage (WizTools)
- (UIImage *)compressedImage:(float)qulity {  
    CGSize imageSize = self.size;  
    CGFloat width = imageSize.width;  
    CGFloat height = imageSize.height;  
    
    if (width <= MAX_IMAGEPIX && height <= MAX_IMAGEPIX) {  
        // no need to compress.  
        return self;  
    }  
    
    if (width == 0 || height == 0) {  
        // void zero exception  
        return self;  
    }  
    
    UIImage *newImage = nil;  
    CGFloat widthFactor = qulity / width;  
    CGFloat heightFactor = qulity / height;  
    CGFloat scaleFactor = 0.0;  
    
    if (widthFactor > heightFactor)  
        scaleFactor = heightFactor; // scale to fit height  
    else  
        scaleFactor = widthFactor; // scale to fit width  
    
    CGFloat scaledWidth  = width * scaleFactor;  
    CGFloat scaledHeight = height * scaleFactor;  
    CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);  
    
    UIGraphicsBeginImageContext(targetSize); // this will crop  
    
    CGRect thumbnailRect = CGRectZero;  
    thumbnailRect.size.width  = scaledWidth;  
    thumbnailRect.size.height = scaledHeight;  
    
    [self drawInRect:thumbnailRect];  
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();  
    
    //pop the context to get back to the default  
    UIGraphicsEndImageContext();  
    
    return newImage;  
    
}  
#define WizAbs(x) x>0?x:-x
- (UIImage*) wizCompressedImageWidth:(float)width   height:(CGFloat)height
{
    UIImage* compassImage = [self compressedImageWidth:width];
    CGRect compassRect = CGRectMake( WizAbs((compassImage.size.width -width)/2), WizAbs((compassImage.size.height -height)/2), compassImage.size.width>width?width:compassImage.size.width, compassImage.size.height>height?height:compassImage.size.height);
    CGImageRef image = CGImageCreateWithImageInRect(compassImage.CGImage, compassRect);
    compassImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return compassImage ;
}

- (UIImage *)compressedImageWidth:(float)qulity {  
    CGSize imageSize = self.size;  
    CGFloat width = imageSize.width;  
    CGFloat height = imageSize.height;  
    
    if (width <= MAX_IMAGEPIX && height <= MAX_IMAGEPIX) {  
        // no need to compress.  
        return self;  
    }  
    
    if (width == 0 || height == 0) {  
        // void zero exception  
        return self;  
    }  
    
    UIImage *newImage = nil;  
    CGFloat widthFactor = qulity / width;  
    CGFloat heightFactor = qulity / height;  
    CGFloat scaleFactor = 0.0;  
    
    if (widthFactor < heightFactor)  
        scaleFactor = heightFactor; // scale to fit height  
    else  
        scaleFactor = widthFactor; // scale to fit width  
    
    CGFloat scaledWidth  = width * scaleFactor;  
    CGFloat scaledHeight = height * scaleFactor;  
    CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);  
    
    UIGraphicsBeginImageContext(targetSize); // this will crop  
    
    CGRect thumbnailRect = CGRectZero;  
    thumbnailRect.size.width  = scaledWidth;  
    thumbnailRect.size.height = scaledHeight;  
    
    [self drawInRect:thumbnailRect];  
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();  
    
    //pop the context to get back to the default  
    UIGraphicsEndImageContext();  
    
    return newImage;
    
} 
- (NSData *)compressedData:(CGFloat)compressionQuality {  
    assert(compressionQuality <= 1.0 && compressionQuality >= 0);  
    
    return UIImageJPEGRepresentation(self, compressionQuality);  
}  

- (CGFloat)compressionQuality {  
    NSData *data = UIImageJPEGRepresentation(self, 1.0);  
    NSUInteger dataLength = [data length];  
    
    if(dataLength > MAX_IMAGEDATA_LEN) {  
        return 1.0 - MAX_IMAGEDATA_LEN / dataLength;  
    } else {  
        return 1.0;  
    }  
}  

- (NSData *)compressedData {  
    CGFloat quality = [self compressionQuality];  
    
    return [self compressedData:quality];  
}  
@end
