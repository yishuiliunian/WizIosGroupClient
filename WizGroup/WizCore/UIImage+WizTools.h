//
//  UIImage+WizTools.h
//  Wiz
//
//  Created by 朝 董 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WizTools)
- (UIImage *)compressedImage:(float)qulity;  
- (UIImage *)compressedImageWidth:(float)qulity;
- (CGFloat)compressionQuality;  
- (UIImage*) wizCompressedImageWidth:(float)width   height:(CGFloat)height;
- (NSData *)compressedData;
- (NSData *)compressedData:(CGFloat)compressionQuality;  
@end
