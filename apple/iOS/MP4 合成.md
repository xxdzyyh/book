# MP4 合成

MP4录制过程中可能中断，所以将MP4分成两段，最后再合并。

使用 AVFoundation 中的 api 就可以。代码如下，因为没有音频，所以音频处理部分去掉了，其实和视频处理方式一样的。

```
AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
```

在导出的时候有个分辨率设置,因为我们录制的视频比较小，240 × 432 ，找不到对应的设置，也没发现可以自定义大小的，只能传预定义的几种值。

仔细看看这个方法的文档，有一句 The export will not scale the video up from a smaller size，导出的时候不会对小于指定大小的视频进行放大，所以设置一个大一点的值就能保持原有的视频大小。

```
/**
 These export options can be used to produce movie files with the specified video size.
 The export will not scale the video up from a smaller size.
 The video will be compressed using H.264 and the audio will be compressed using AAC.
 Some devices cannot support some sizes.
 */
AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset960x540];
```

### 完整代码

```
#import "CRVideoConcatViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CRVideoConcatViewController ()

@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *outPath;
@end

@implementation CRVideoConcatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.type = @"mp4";
    self.outPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"mix.mp4"];
    NSURL *firstMP4URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"d207663f9f7eb70b" ofType:@"mp4"]];
    NSURL *secondMP4URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"7a03db9b7e8fdad0" ofType:@"mp4"]];
    
    [self concatVideos:[@[firstMP4URL,secondMP4URL] mutableCopy] withOutPath:self.outPath];
}

- (void)concatVideos:(NSMutableArray *)videoFileURLs withOutPath:(NSString *)outpath {
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime totalDuration = kCMTimeZero;
    for(int i =0; i < videoFileURLs.count; i++) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoFileURLs[i]];
        
        NSError *errorVideo =nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];

        //向通道内加入视频

        BOOL isSuccess = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                             ofTrack:assetVideoTrack
                                              atTime:totalDuration
                                               error:&errorVideo];

        NSLog(@"errorVideo = %@,isSuccess = %d", errorVideo, isSuccess);
        totalDuration =CMTimeAdd(totalDuration, asset.duration);
    }

    NSURL *mergeFileURL = [NSURL fileURLWithPath:self.outPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:outpath]) {
       [[NSFileManager defaultManager] removeItemAtPath:self.outPath error:nil];
    }
    
    /**
     These export options can be used to produce movie files with the specified video size.
     The export will not scale the video up from a smaller size.
     The video will be compressed using H.264 and the audio will be compressed using AAC.
     Some devices cannot support some sizes.
     */
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset960x540];
    exporter.outputURL= mergeFileURL;

    if([self.type isEqualToString:@"mp4"]) {
       exporter.outputFileType=AVFileTypeMPEG4;
    } else {
       exporter.outputFileType=AVFileTypeQuickTimeMovie;
    }

    exporter.shouldOptimizeForNetworkUse=YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
       //导出的状态
       switch(exporter.status) {
           case AVAssetExportSessionStatusUnknown:
                NSLog(@"exporter Unknow");
           break;
           case AVAssetExportSessionStatusCancelled:
                NSLog(@"exporter Canceled");
           break;
           case AVAssetExportSessionStatusFailed:
                //导出失败
                NSLog(@"exporter Failed %@",exporter.error);
               
           break;
           case AVAssetExportSessionStatusWaiting:
                NSLog(@"exporter Waiting");
           break;
           case AVAssetExportSessionStatusExporting:
                NSLog(@"exporter Exporting");
           break;
           case AVAssetExportSessionStatusCompleted:
           			//导出成功
           			NSLog(@"exporter Completed");
           break;
        }
    }];
}

@end
```



