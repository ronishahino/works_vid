// Copyright (c) 2020 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import <LTKit/LTPath.h>
#import <LTKit/NSBundle+Path.h>
#import <Photons/NSFileManager+FileSystem.h>
#import <Photons/NSURL+FileSystem.h>
#import <Photons/PTNFileSystemAssetManager.h>
#import <Photons/PTNImageResizer.h>

#import "VIDCompositionComponents.h"
#import "VIDCompositionComponentsMetadataFactory.h"
#import "VIDCompositionComponentsProvider.h"
#import "VIDCompositionFactory.h"
#import "VIDDisplacementRenderModel.h"
#import "VIDInterpolationDescriptor.h"
#import "VIDLayerRenderModel.h"
#import "VIDLayerSource.h"
#import "VIDMetalVideoCompositor.h"
#import "VIDRenderComponents.h"
#import "VIDRenderingSource.h"
#import "VIDRenderLayer.h"

VIDRenderLayer *VIDCreateRenderLayer(id<VIDRenderModel> model, CGSize size,
                                     NSString *inputVideoName) {
  auto interpolationDescriptor = [[VIDInterpolationDescriptor alloc]
                                  initWithGlobalRenderModel:model];

  auto filePath = [[NSBundle lt_testBundle] lt_pathForResource:inputVideoName];
  auto path = [LTPath pathWithFileURL:[NSURL fileURLWithPath:filePath]];
  auto url = [NSURL ptn_fileSystemAssetURLWithPath:path];
  auto source = [[VIDRenderingSource alloc] initWithURL:url duration:CMTimeMake(1, 2)
                                       naturalTimeScale:1 naturalSize:size
                                                   type:$(VIDSourceTypeVideo)];

  auto timeMapping = CMTimeMappingMake(CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 1)),
                                       CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 1)));
  auto layerSource = [[VIDLayerSource alloc] initWithRenderingSource:source
                                                         timeMapping:timeMapping];
  return [[VIDRenderLayer alloc] initWithLayerLevel:1 source:layerSource
                            interpolationDescriptor:interpolationDescriptor];
}

SpecBegin(video10Bit)

if ([MTLCreateSystemDefaultDevice() supportsFeatureSet:MTLFeatureSet_iOS_GPUFamily3_v1]) {
  it(@"should load 10 bit video correctly", ^{
    auto inputSize = CGSizeMake(160 ,160);

    auto layerRenderModel =[[VIDMutableLayerRenderModel alloc] initWithLayerSize:inputSize
                                                                      targetSize:inputSize];
    auto renderLayerInput = VIDCreateRenderLayer(layerRenderModel, inputSize,
                                                 @"displacement_input_video.mov");

    auto displacementModel = [[VIDDisplacementRenderModel alloc] initWithHorizontalOffset:-75
        verticalOffset:-75 horizontalScale:150 verticalScale:150
        horizontalChannel:$(VIDDisplacementChannelRed)
        verticalChannel:$(VIDDisplacementChannelRed)];
    auto renderLayerDisplacement = VIDCreateRenderLayer(displacementModel, CGSizeMake(512 ,512),
                                                        @"displacement_map_10_bit_video.mp4");

    auto renderComponents = [[VIDRenderComponents alloc]
                             initWithVideoRenderLayers:@[renderLayerInput, renderLayerDisplacement]
                             audioRenderItems:@[] backgroundColor:LTVector4(0.3)
                             sessionSize:inputSize targetSize:inputSize
                             frameDuration:CMTimeMake(1, 30)];

    auto assetManager = [[PTNFileSystemAssetManager alloc]
                         initWithFileManager:NSFileManager.defaultManager
                         imageResizer:[[PTNImageResizer alloc] init]];
    auto compositionFactory = [[VIDCompositionFactory alloc] initWithAssetManager:assetManager];
    auto metadataFactory = [[VIDCompositionComponentsMetadataFactory alloc] init];
    auto provider = [[VIDCompositionComponentsProvider alloc]
                     initWithCompositionFactory:compositionFactory
                     compositionMetadataFactory:metadataFactory];

    auto compositionComponentsSignal = [provider
                                        compositionComponentsForRenderComponents:renderComponents
                                        customVideoCompositorClass:VIDMetalVideoCompositor.class];
    auto compositionComponents = (VIDCompositionComponents *)compositionComponentsSignal.first;

    auto imageGenerator = [[AVAssetImageGenerator alloc]
                           initWithAsset:compositionComponents.composition];
    imageGenerator.videoComposition = compositionComponents.videoComposition;
    auto cgImage = lt::Ref<CGImageRef>{[imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil
                                                                   error:nil]};

    auto textureLoader = [[MTKTextureLoader alloc] initWithDevice:MTLCreateSystemDefaultDevice()];
    auto texture = [textureLoader newTextureWithCGImage:cgImage.get() options:nil error:nil];

    cv::Mat outputMat = mtb(texture).mtb_createMat;
    auto expectedMat = LTLoadMatFromBundle(NSBundle.lt_testBundle,
                                           @"displacement_10_bit_video_output.png");

    expect($(outputMat)).to.beCloseToMatPSNR($(expectedMat), 50);
  });
}

SpecEnd
