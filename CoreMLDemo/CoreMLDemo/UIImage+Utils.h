//
//  UIImage+Utils.h
//  CoreMLDemo
//
//  Created by 廖登科 on 2017/9/5.
//  Copyright © 2017年 dengkel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface UIImage (Utils)
- (UIImage *)scaleToSize:(CGSize)size;
- (CVPixelBufferRef)pixelBufferFromCGImage:(UIImage *)image;
+ (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
@end
