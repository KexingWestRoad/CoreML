//
//  ViewController.m
//  CoreMLDemo
//
//  Created by 廖登科 on 2017/9/5.
//  Copyright © 2017年 dengkel. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreML/CoreML.h>
#import "UIImage+Utils.h"
#import "MobileNet.h"

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic,strong) UIView *realTimeView;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutPut;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic,strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong) UILabel *showLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAVCapturWritterConfig];
    [self setUpSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startVideoCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopVideoCapture];
}

- (void)initAVCapturWritterConfig {
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (videoDevice.isFocusPointOfInterestSupported && [videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [videoDevice lockForConfiguration:nil];
        [videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [videoDevice unlockForConfiguration];
    }
    
    AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
    
    if ([self.session canAddInput:cameraDeviceInput]) {
        [self.session addInput:cameraDeviceInput];
    }
    
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA],(id)kCVPixelBufferPixelFormatTypeKey, nil];
    [self.videoOutPut setVideoSettings:outputSettings];
    if ([self.session canAddOutput:self.videoOutPut]) {
        [self.session addOutput:self.videoOutPut];
    }
    self.videoConnection = [self.videoOutPut connectionWithMediaType:AVMediaTypeVideo];
    self.videoConnection.enabled = NO;
    [self.videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)setUpSubviews {
    [self.view addSubview:self.realTimeView];
    self.previewLayer.frame = self.realTimeView.frame;
    [self.realTimeView.layer addSublayer:self.previewLayer];
    [self.view addSubview:self.showLabel];
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoDataOutput *)videoOutPut {
    if (!_videoOutPut) {
        _videoOutPut = [[AVCaptureVideoDataOutput alloc] init];
    }
    return _videoOutPut;
}

- (UIView *)realTimeView {
    if (!_realTimeView) {
        _realTimeView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _realTimeView;
}

- (UILabel *)showLabel {
    if (!_showLabel) {
        _showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)];
        _showLabel.textAlignment = NSTextAlignmentCenter;
        _showLabel.font = [UIFont systemFontOfSize:20];
        _showLabel.textColor = [UIColor whiteColor];
        _showLabel.backgroundColor = [UIColor clearColor];
    }
    return _showLabel;
}

- (void)startVideoCapture {
    [self.session startRunning];
    self.videoConnection.enabled = YES;
    self.videoQueue = dispatch_queue_create("com.jumei.capture.input", NULL);
    [self.videoOutPut setSampleBufferDelegate:self queue:self.videoQueue];
}

- (void)stopVideoCapture {
    [self.videoOutPut setSampleBufferDelegate:nil queue:nil];
    self.videoConnection.enabled = NO;
    self.videoQueue = nil;
    [self.session stopRunning];
}

- (NSString *)predictImageScene:(UIImage *)image {
    MobileNet *mobileNet = [[MobileNet alloc] init];
    NSError *error;
    UIImage *scaledImage = [image scaleToSize:CGSizeMake(224, 224)];
    CVPixelBufferRef buffer = [image pixelBufferFromCGImage:scaledImage];
    MobileNetInput *input = [[MobileNetInput alloc] initWithImage:buffer];
    MobileNetOutput *output = [mobileNet predictionFromFeatures:input error:&error];
    return output.classLabel;
}

#pragma mark --AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    dispatch_queue_t queue = dispatch_queue_create("com.jumei.capture.output", NULL);
    dispatch_sync(queue, ^{
        CGImageRef cgImage = [UIImage imageFromSampleBuffer:sampleBuffer];
        NSString *text = [self predictImageScene:[UIImage imageWithCGImage:cgImage]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.showLabel.text = text;
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
