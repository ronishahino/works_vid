// Copyright (c) 2020 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import "VIDDisplacementRenderer.h"

#import <LTKit/LTMMInputFile.h>
#import <MetalToolbox/MTBDevice.h>

#import "VIDDisplacementRenderModel.h"
#import "VIDMetalRendererResourceProvider.h"
#import "VIDMetalRenderersExamples.h"
#import "VIDVideoCompositionInstruction.h"

DeviceSpecBegin(VIDDisplacementRenderer)

__block VIDDisplacementRenderer *renderer;
__block VIDDisplacementRenderModel *model;
__block MTBDevice *device;

beforeEach(^{
  device = [MTBDevice mtb_defaultDevice];
  renderer = [[VIDDisplacementRenderer alloc] initWithDevice:device
                                                 pixelFormat:MTLPixelFormatBGRA8Unorm];
  model = [[VIDDisplacementRenderModel alloc] initWithHorizontalOffset:-70 verticalOffset:-70
      horizontalScale:150 verticalScale:150 horizontalChannel:$(VIDDisplacementChannelRed)
      verticalChannel:$(VIDDisplacementChannelGreen)];
});

context(@"displacement", ^{
  itBehavesLike(kVIDRenderersExamples, ^{
    return @{
      kVIDRendererExamplesRendererKey: renderer,
      kVIDRendererExamplesRenderModelKey: model,
      kVIDRendererExamplesRendererInputTextureKey: @"city.png",
      kVIDRendererExamplesLayerTexturesKey: @[@"displacement_map.png"],
      kVIDRendererExamplesRendererExpectedOutputKey: @"displacement_output.png",
      kVIDRendererExamplesSwizzleExpectedOutputColors: @NO,
    };
  });

  it(@"should support YUV map", ^{
    MTLTextureDescriptor *textureDescriptor =
        [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                           width:160 height:160 mipmapped:NO];
    textureDescriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderWrite;
    auto outputTexture = mtb([device newTextureWithDescriptor:textureDescriptor]);
    auto renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPassDescriptor.colorAttachments[0].texture = outputTexture;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;

    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:device];
    auto texture = mtb([loader newTextureWithContentsOfURL:VIDURLForResource(@"city.png")
                                                   options:@{MTKTextureLoaderOptionSRGB: @NO}
                                                     error:NULL]);
    LTAssert(texture);

    auto mapY = mtb([loader newTextureWithContentsOfURL:VIDURLForResource(@"displacement_map-y.png")
                                                options:@{MTKTextureLoaderOptionSRGB: @NO}
                                                  error:NULL]);
    LTAssert(mapY);

    auto pathUV = [NSBundle.lt_testBundle pathForResource:@"displacement_map-crcb.tensor" ofType:nil
                                              inDirectory:nil];
    auto tensorUV = [[LTMMInputFile alloc] initWithPath:pathUV error:nil];
    auto descriptorUV = [MTLTextureDescriptor
        texture2DDescriptorWithPixelFormat:MTLPixelFormatRG8Unorm width:200 height:200
        mipmapped:NO];
    auto mapUV =  mtb([device newTextureWithDescriptor:descriptorUV]);
    [mapUV replaceRegion:MTLRegionMake2D(0, 0, 200, 200) mipmapLevel:0 slice:0
              withBytes:tensorUV.data bytesPerRow:200 * CV_ELEM_SIZE(CV_8UC2) bytesPerImage:0];
   LTAssert(mapUV);

    auto textureUsageDescriptorModificationBlock = ^void(MTLTextureDescriptor *descriptor) {
      descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead |
      MTLTextureUsageShaderWrite;
    };

    auto firstAuxiliaryTexture =
        [device mtb_newTextureWithPropertiesOfTexture:texture
                          descriptorModificationBlock:textureUsageDescriptorModificationBlock];
    auto halfFloatTexture =
        [device mtb_newPrivateTextureWithWidth:texture.width
                                        height:texture.height
                                   pixelFormat:MTLPixelFormatR16Float
                                         usage:outputTexture.usage];

    auto resourceProvider = [[VIDMetalRendererResourceProvider alloc]
        initWithFirstAuxiliaryTexture:firstAuxiliaryTexture
        halfFloatAuxiliaryTexture:halfFloatTexture];

    VIDMetalSourceTextures sourceTextures = {
      .sourceTexture = texture,
      .sourceTextureUV = nil,
      .sourcePixelFormat = VIDPixelBufferFormatBGRA
    };

    VIDMetalSourceTextures mapTextures = {
      .sourceTexture = mapY,
      .sourceTextureUV = mapUV,
      .sourcePixelFormat = VIDPixelBufferFormatYUVFullRange
    };

    auto source =
        [[VIDVideoCompositionSource alloc] initWithTrackID:0
                                                sourceSize:texture.mtb_cgSize
                                           sourceTransform:CGAffineTransformIdentity];
    auto layer = [[VIDVideoCompositionLayer alloc] initWithSources:@[source] renderModel:model
        timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 1))];

    auto instruction = [[VIDVideoCompositionInstruction alloc]
                        initWithTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 1))
                        layers:@[layer] sessionSize:mtb(texture).mtb_cgSize
                        backgroundColor:LTVector4(0, 0, 0, 1)];

    auto queue = [device newCommandQueue];
    MTBCommandBuffer *commandBuffer = mtb([queue commandBuffer]);

    [renderer encodeToCommandBuffer:commandBuffer inputTexture:texture
                      outputTexture:outputTexture layer:layer
               renderPassDescriptor:renderPassDescriptor layerTextures:{mapTextures}
                   resourceProvider:resourceProvider instruction:instruction time:kCMTimeZero];

    [commandBuffer mtb_commitAndWaitUntilCompleted];

    cv::Mat expected = VIDReadMat(@"displacement_yuv_map_output.png");
    cv::cvtColor(expected, expected, cv::COLOR_RGBA2BGRA);
    cv::Mat output = mtb(outputTexture).mtb_createMat;
    expect($(output)).to.beCloseToMatPSNR($(expected), 50);
  });

});

DeviceSpecEnd
