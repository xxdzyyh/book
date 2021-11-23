## webp



镜像：https://github.com/webmproject/libwebp



```
../libwebp/bin/cwebp -q 75 -m 4 IMG_4680.PNG -o IMG_4680.webp
```



| 原图大小 | webp 大小 |       |
| -------- | --------- | ----- |
| 35K jpg  | 11K       | 0.31  |
| 39K jpg  | 11K       | 0.28  |
| 32K jpg  | 8.8K      | 0.275 |
| 41K jpg  | 12K       | 0.29  |
| 1.1M png | 87K       | 0.08  |
| 191K png | 56K       | 0.29  |
| 667K png | 55K       | 0.08  |
| 24K jpg  | 5.5K      | 0.23  |



### UIImage 和 webp 相互转换 

参考 https://github.com/SDWebImage/SDWebImageWebPCoder.git



```
@implementation UIImage (WebP)

// 可以转换成功，但是最终的图片颜色可能有问题，转换过程中，颜色空间可能设置有问题
- (NSData *)dataWebPWithQuality:(float)quality{
    int rc = WebPGetEncoderVersion();
    NSLog(@"WebP encoder version: %d", rc);

    CGImageRef imageRef = self.CGImage;
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    if (CGColorSpaceGetModel(colorSpace) != kCGColorSpaceModelRGB) {
        NSLog(@"Sorry, we need RGB");
    }
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    CFDataRef imageData = CGDataProviderCopyData(dataProvider);
    const UInt8 *rawData = CFDataGetBytePtr(imageData);

    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    uint8_t *output;
    NSUInteger stride = CGImageGetBytesPerRow(imageRef);
    size_t ret_size;

    if (quality == kWebPLossless) {
        ret_size = WebPEncodeLosslessRGB(rawData, (int)width, (int)height, (int)stride, &output);
    } else {
        ret_size = WebPEncodeRGBA(rawData, (int)width, (int)height, (int)stride, quality, &output);
    }

    if (ret_size == 0) {
        NSLog(@"Oops, no data");
    }
    CFRelease(imageData);
    CGColorSpaceRelease(colorSpace);
    NSData *data = [NSData dataWithBytes:(const void *)output length:ret_size];

    return data;
}
```



```
// SDWebImageWebPCoder 中的实现是没有问题的
- (nullable NSData *)encodedWebpDataWithQuality:(double)quality {
    CGImageRef imageRef = self.CGImage;
    
    NSData *webpData;
    if (!imageRef) {
        return nil;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || width > WEBP_MAX_DIMENSION) {
        return nil;
    }
    if (height == 0 || height > WEBP_MAX_DIMENSION) {
        return nil;
    }
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    size_t components = bitsPerPixel / bitsPerComponent;
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
    CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    BOOL byteOrderNormal = NO;
    switch (byteOrderInfo) {
        case kCGBitmapByteOrderDefault: {
            byteOrderNormal = YES;
        } break;
        case kCGBitmapByteOrder32Little: {
        } break;
        case kCGBitmapByteOrder32Big: {
            byteOrderNormal = YES;
        } break;
        default: break;
    }
    // If we can not get bitmap buffer, early return
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    if (!dataProvider) {
        return nil;
    }
    // Check colorSpace is RGB/RGBA
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    BOOL isRGB = CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB;
    
    CFDataRef dataRef;
    uint8_t *rgba = NULL; // RGBA Buffer managed by CFData, don't call `free` on it, instead call `CFRelease` on `dataRef`
    // We could not assume that input CGImage's color mode is always RGB888/RGBA8888. Convert all other cases to target color mode using vImage
    BOOL isRGB888 = isRGB && byteOrderNormal && alphaInfo == kCGImageAlphaNone && components == 3;
    BOOL isRGBA8888 = isRGB && byteOrderNormal && alphaInfo == kCGImageAlphaLast && components == 4;
    if (isRGB888 || isRGBA8888) {
        // If the input CGImage is already RGB888/RGBA8888
        dataRef = CGDataProviderCopyData(dataProvider);
        if (!dataRef) {
            return nil;
        }
        rgba = (uint8_t *)CFDataGetBytePtr(dataRef);
    } else {
        // Convert all other cases to target color mode using vImage
        vImageConverterRef convertor = NULL;
        vImage_Error error = kvImageNoError;
        
        vImage_CGImageFormat srcFormat = {
            .bitsPerComponent = (uint32_t)bitsPerComponent,
            .bitsPerPixel = (uint32_t)bitsPerPixel,
            .colorSpace = colorSpace,
            .bitmapInfo = bitmapInfo,
            .renderingIntent = CGImageGetRenderingIntent(imageRef)
        };
        vImage_CGImageFormat destFormat = {
            .bitsPerComponent = 8,
            .bitsPerPixel = hasAlpha ? 32 : 24,
            .colorSpace = [DWReplayUtils colorSpaceGetDeviceRGB],
            .bitmapInfo = hasAlpha ? kCGImageAlphaLast | kCGBitmapByteOrderDefault : kCGImageAlphaNone | kCGBitmapByteOrderDefault // RGB888/RGBA8888 (Non-premultiplied to works for libwebp)
        };
        
        convertor = vImageConverter_CreateWithCGImageFormat(&srcFormat, &destFormat, NULL, kvImageNoFlags, &error);
        if (error != kvImageNoError) {
            return nil;
        }
        
        vImage_Buffer src;
        error = vImageBuffer_InitWithCGImage(&src, &srcFormat, nil, imageRef, kvImageNoFlags);
        if (error != kvImageNoError) {
            vImageConverter_Release(convertor);
            return nil;
        }
        
        vImage_Buffer dest;
        error = vImageBuffer_Init(&dest, height, width, destFormat.bitsPerPixel, kvImageNoFlags);
        if (error != kvImageNoError) {
            vImageConverter_Release(convertor);
            free(src.data);
            return nil;
        }
        
        // Convert input color mode to RGB888/RGBA8888
        error = vImageConvert_AnyToAny(convertor, &src, &dest, NULL, kvImageNoFlags);
        
        // Free the buffer
        free(src.data);
        vImageConverter_Release(convertor);
        if (error != kvImageNoError) {
            free(dest.data);
            return nil;
        }
        
        rgba = dest.data; // Converted buffer
        bytesPerRow = dest.rowBytes; // Converted bytePerRow
        dataRef = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, rgba, bytesPerRow * height, kCFAllocatorDefault);
    }
    
    float qualityFactor = quality * 100; // WebP quality is 0-100
    // Encode RGB888/RGBA8888 buffer to WebP data
    // Using the libwebp advanced API: https://developers.google.com/speed/webp/docs/api#advanced_encoding_api
    WebPConfig config;
    WebPPicture picture;
    WebPMemoryWriter writer;
    
    if (!WebPConfigPreset(&config, WEBP_PRESET_DEFAULT, qualityFactor) ||
        !WebPPictureInit(&picture)) {
        // shouldn't happen, except if system installation is broken
        CFRelease(dataRef);
        return nil;
    }

    picture.use_argb = 0; // Lossy encoding use YUV for internel bitstream
    picture.width = (int)width;
    picture.height = (int)height;
    picture.writer = WebPMemoryWrite; // Output in memory data buffer
    picture.custom_ptr = &writer;
    WebPMemoryWriterInit(&writer);
    
    int result;
    if (hasAlpha) {
        result = WebPPictureImportRGBA(&picture, rgba, (int)bytesPerRow);
    } else {
        result = WebPPictureImportRGB(&picture, rgba, (int)bytesPerRow);
    }
    if (!result) {
        WebPMemoryWriterClear(&writer);
        CFRelease(dataRef);
        return nil;
    }
    
    result = WebPEncode(&config, &picture);
    WebPPictureFree(&picture);
    CFRelease(dataRef); // Free bitmap buffer
    
    if (result) {
        // success
        webpData = [NSData dataWithBytes:writer.mem length:writer.size];
    } else {
        // failed
        webpData = nil;
    }
    WebPMemoryWriterClear(&writer);
    
    return webpData;
}

@end
```

