## SDWebImage

### 内存缓存

### 磁盘缓存

### 图片下载

通过 SDWebImageDownloader 来管理图片下载操作。

SDWebImageDownloader 内部有一个NSOperationQueue，每一个下载操作对应一个SDWebImageDownloaderOperation 实例，而 SDWebImageDownloaderOperation 继承自 NSOperation，可以通过 NSOperationQueue 进行管理。

```
SDWebImageDownloader
	 NSOperationQueue *downloadQueue;
	 NSMutableDictionary<NSURL *, NSOperation<SDWebImageDownloaderOperation> *>*URLOperations;
	 
	 
@interface SDWebImageDownloaderOperation : NSOperation <SDWebImageDownloaderOperation>
```





#### UIView+WebCacheOperation.h

```
/**
 These methods are used to support canceling for UIView image loading, it's designed to be used internal but not external.
 All the stored operations are weak, so it will be dalloced after image loading finished. If you need to store operations, use your own class to keep a strong reference for them.
 */
@interface UIView (WebCacheOperation)
```



#### UIView+WebCache

```
typedef NSString * SDWebImageContextOption NS_EXTENSIBLE_STRING_ENUM;
typedef NSDictionary<SDWebImageContextOption, id> SDWebImageContext;
typedef NSMutableDictionary<SDWebImageContextOption, id> SDWebImageMutableContext;

- (void)sd_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(SDWebImageOptions)options
                           context:(nullable SDWebImageContext *)context
                     setImageBlock:(nullable SDSetImageBlock)setImageBlock
                          progress:(nullable SDImageLoaderProgressBlock)progressBlock
                         completed:(nullable SDInternalCompletionBlock)completedBlock {
                         
    // 一般情况我们并不会设置context,也就是context默认为nil                    
    context = [context copy]; // copy to avoid mutable object
    NSString *validOperationKey = context[SDWebImageContextSetImageOperationKey];
    if (!validOperationKey) {
        validOperationKey = NSStringFromClass([self class]);
    }
    self.sd_latestOperationKey = validOperationKey;
    [self sd_cancelImageLoadOperationWithKey:validOperationKey];
    self.sd_imageURL = url;        
                         
    // 如果没有设置延迟加载占位图，那就显示占位图                     
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            [self sd_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:SDImageCacheTypeNone imageURL:url];
        });
    }
            
    if (url) {
    // 因为可能重新设置图片，所以progress需要重置
    // reset the progress
    NSProgress *imageProgress = objc_getAssociatedObject(self, @selector(sd_imageProgress));
    if (imageProgress) {
        imageProgress.totalUnitCount = 0;
        imageProgress.completedUnitCount = 0;
    }

#if SD_UIKIT || SD_MAC
		// self.sd_imageIndicator 是一个关联对象，默认为空。imageIndicator在加载图片是转圈
    // check and start image indicator
    [self sd_startImageIndicator];
    id<SDWebImageIndicator> imageIndicator = self.sd_imageIndicator;
#endif

		// context一般为nil，所以 manager = [SDWebImageManager sharedManager]
    SDWebImageManager *manager = context[SDWebImageContextCustomManager];
    if (!manager) {
        manager = [SDWebImageManager sharedManager];
    }

    SDImageLoaderProgressBlock combinedProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (imageProgress) {
            imageProgress.totalUnitCount = expectedSize;
            imageProgress.completedUnitCount = receivedSize;
        }
        
// 如果有必要，设置进度显示
#if SD_UIKIT || SD_MAC
        if ([imageIndicator respondsToSelector:@selector(updateIndicatorProgress:)]) {
            double progress = 0;
            if (expectedSize != 0) {
                progress = (double)receivedSize / expectedSize;
            }
            progress = MAX(MIN(progress, 1), 0); // 0.0 - 1.0
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageIndicator updateIndicatorProgress:progress];
            });
        }
#endif

        if (progressBlock) {
            progressBlock(receivedSize, expectedSize, targetURL);
        }
    };
    
    
    @weakify(self);
    id <SDWebImageOperation> operation = [manager loadImageWithURL:url options:options context:context progress:combinedProgressBlock completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        @strongify(self);
        if (!self) { return; }
        // if the progress not been updated, mark it to complete state
        if (imageProgress && finished && !error && imageProgress.totalUnitCount == 0 && imageProgress.completedUnitCount == 0) {
            imageProgress.totalUnitCount = SDWebImageProgressUnitCountUnknown;
            imageProgress.completedUnitCount = SDWebImageProgressUnitCountUnknown;
        }

#if SD_UIKIT || SD_MAC
        // check and stop image indicator
        if (finished) {
            [self sd_stopImageIndicator];
        }
#endif

        BOOL shouldCallCompletedBlock = finished || (options & SDWebImageAvoidAutoSetImage);
        BOOL shouldNotSetImage = ((image && (options & SDWebImageAvoidAutoSetImage)) ||
                                  (!image && !(options & SDWebImageDelayPlaceholder)));
        SDWebImageNoParamsBlock callCompletedBlockClojure = ^{
            if (!self) { return; }
            if (!shouldNotSetImage) {
                [self sd_setNeedsLayout];
            }
            if (completedBlock && shouldCallCompletedBlock) {
                completedBlock(image, data, error, cacheType, finished, url);
            }
        };

        // case 1a: we got an image, but the SDWebImageAvoidAutoSetImage flag is set
        // OR
        // case 1b: we got no image and the SDWebImageDelayPlaceholder is not set
        if (shouldNotSetImage) {
            dispatch_main_async_safe(callCompletedBlockClojure);
            return;
        }

        UIImage *targetImage = nil;
        NSData *targetData = nil;
        if (image) {
            // case 2a: we got an image and the SDWebImageAvoidAutoSetImage is not set
            targetImage = image;
            targetData = data;
        } else if (options & SDWebImageDelayPlaceholder) {
            // case 2b: we got no image and the SDWebImageDelayPlaceholder flag is set
            targetImage = placeholder;
            targetData = nil;
        }

#if SD_UIKIT || SD_MAC
        // check whether we should use the image transition
        SDWebImageTransition *transition = nil;
        if (finished && (options & SDWebImageForceTransition || cacheType == SDImageCacheTypeNone)) {
            transition = self.sd_imageTransition;
        }
#endif
        dispatch_main_async_safe(^{
#if SD_UIKIT || SD_MAC
            [self sd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:transition cacheType:cacheType imageURL:imageURL];
#else
            [self sd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:cacheType imageURL:imageURL];
#endif
            callCompletedBlockClojure();
        });
    }];
    [self sd_setImageLoadOperation:operation forKey:validOperationKey];
} else {
#if SD_UIKIT || SD_MAC
    [self sd_stopImageIndicator];
#endif
    dispatch_main_async_safe(^{
        if (completedBlock) {
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}];
            completedBlock(nil, nil, error, SDImageCacheTypeNone, YES, url);
        }
    });
   }                      
}
```



####  #### SDWebImageManager 

```
- (SDWebImageCombinedOperation *)loadImageWithURL:(nullable NSURL *)url
                                          options:(SDWebImageOptions)options
                                          context:(nullable SDWebImageContext *)context
                                         progress:(nullable SDImageLoaderProgressBlock)progressBlock
                                        completed:(nonnull SDInternalCompletionBlock)completedBlock {
   
   // 如果回调为nil，那建议你使用 [SDWebImagePrefetcher prefetchURLs] 来做预加载
   // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, Xcode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

		// 联合Operation = cacheOperation + loaderOperation
    SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    operation.manager = self;

		// 除非在options中指明要重试已经失败的URL，否者如果URL已失败，直接返回
    BOOL isFailedUrl = NO;
    if (url) {
        SD_LOCK(self.failedURLsLock);
        isFailedUrl = [self.failedURLs containsObject:url];
        SD_UNLOCK(self.failedURLsLock);
    }

    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}] url:url];
        return operation;
    }

    SD_LOCK(self.runningOperationsLock);
    [self.runningOperations addObject:operation];
    SD_UNLOCK(self.runningOperationsLock);
    
    // Preprocess the options and context arg to decide the final the result for manager
    SDWebImageOptionsResult *result = [self processedResultForURL:url options:options context:context];
    
    // 开始从缓存中查找图片
    // Start the entry to load image from cache
    [self callCacheProcessForOperation:operation url:url options:result.options context:result.context progress:progressBlock completed:completedBlock];

    return operation;
}



// Query cache process
- (void)callCacheProcessForOperation:(nonnull SDWebImageCombinedOperation *)operation
                                 url:(nonnull NSURL *)url
                             options:(SDWebImageOptions)options
                             context:(nullable SDWebImageContext *)context
                            progress:(nullable SDImageLoaderProgressBlock)progressBlock
                           completed:(nullable SDInternalCompletionBlock)completedBlock {
    // Grab the image cache to use
    id<SDImageCache> imageCache;
    if ([context[SDWebImageContextImageCache] conformsToProtocol:@protocol(SDImageCache)]) {
        imageCache = context[SDWebImageContextImageCache];
    } else {
        imageCache = self.imageCache;
    }
    // Check whether we should query cache
    BOOL shouldQueryCache = !SD_OPTIONS_CONTAINS(options, SDWebImageFromLoaderOnly);
    if (shouldQueryCache) {
    		// 缓存的key是通过特定的算法得到的，如果没有指定context就是url.absoluteString
        NSString *key = [self cacheKeyForURL:url context:context];
        
        // imageCache = [SDImageCache sharedImageCache];
        @weakify(operation);
        operation.cacheOperation = [imageCache queryImageForKey:key options:options context:context completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, SDImageCacheType cacheType) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during querying the cache"}] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            }
            // Continue download process
            [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:cachedImage cachedData:cachedData cacheType:cacheType progress:progressBlock completed:completedBlock];
        }];
    } else {
        // Continue download process
        [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:nil cachedData:nil cacheType:SDImageCacheTypeNone progress:progressBlock completed:completedBlock];
    }
}

#pragma mark - SDImageCache

- (id<SDWebImageOperation>)queryImageForKey:(NSString *)key options:(SDWebImageOptions)options context:(SDWebImageContext *)context completion:(SDImageCacheQueryCompletionBlock)completionBlock {
    if (!key) {
        return nil;
    }
    NSArray<id<SDImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return nil;
    } else if (count == 1) {
        return [caches.firstObject queryImageForKey:key options:options context:context completion:completionBlock];
    }
    switch (self.queryOperationPolicy) {
        case SDImageCachesManagerOperationPolicyHighestOnly: {
            id<SDImageCache> cache = caches.lastObject;
            return [cache queryImageForKey:key options:options context:context completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyLowestOnly: {
            id<SDImageCache> cache = caches.firstObject;
            return [cache queryImageForKey:key options:options context:context completion:completionBlock];
        }
            break;
        case SDImageCachesManagerOperationPolicyConcurrent: {
            SDImageCachesManagerOperation *operation = [SDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentQueryImageForKey:key options:options context:context completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        case SDImageCachesManagerOperationPolicySerial: {
            SDImageCachesManagerOperation *operation = [SDImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self serialQueryImageForKey:key options:options context:context completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        default:
            return nil;
            break;
    }
}

```







