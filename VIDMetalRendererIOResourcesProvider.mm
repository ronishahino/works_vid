// Copyright (c) 2021 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import "VIDMetalRendererIOResourcesProvider.h"

NS_ASSUME_NONNULL_BEGIN

LTEnumImplement(NSUInteger, VIDMetalRendererIOResourceSemantics,
  /// \c VIDMetalRenderer that gets different texture for input and output textures.
  VIDMetalRendererIOResourceSemanticsOutOfPlace,
  /// \c VIDMetalRenderer that gets only output texture, and operating directly on this texture.
  VIDMetalRendererIOResourceSemanticsInPlace
);

@implementation VIDMetalRendererIOResourcesProvider

+ (MTLRenderPassDescriptor *)intermediateRenderPassDescriptorWithTexture:(MTBTexture *)texture {
  auto renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
  renderPassDescriptor.colorAttachments[0].texture = texture;
  renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
  renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
  return renderPassDescriptor;
}

+ (MTLRenderPassDescriptor *)initialRenderPassDescriptorWithTexture:(MTBTexture *)texture
                                                  initialLoadAction:(MTLLoadAction)initialLoadAction
                                                    backgroundColor:(MTLClearColor)backgroundColor {
  auto renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
  renderPassDescriptor.colorAttachments[0].texture = texture;
  renderPassDescriptor.colorAttachments[0].clearColor = backgroundColor;
  renderPassDescriptor.colorAttachments[0].loadAction = initialLoadAction;
  renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
  return renderPassDescriptor;
}

+ (std::vector<VIDMetalRendererIOResources>)ioResourcesWithRendererIOSemantics:
    (const std::vector<VIDMetalRendererIOResourceSemantics *> &)rendererIOResourcesSemanticList
    outputTexture:(MTBTexture *)outputTexture helperTexture:(MTBTexture *)helperTexture
    initialLoadAction:(MTLLoadAction)initialLoadAction
    initialBackgroundColor:(MTLClearColor)initialBackgroundColor {
  std::vector<VIDMetalRendererIOResources> renderIOResourcesList;
  renderIOResourcesList.reserve(rendererIOResourcesSemanticList.size());

  if (rendererIOResourcesSemanticList.empty()) {
    return renderIOResourcesList;
  }

  auto currentOutputRenderPassDescriptor =
      [self intermediateRenderPassDescriptorWithTexture:outputTexture];
  auto intermediateTextureRenderPassDescriptor =
      [self intermediateRenderPassDescriptorWithTexture:helperTexture];

  auto currentOutput = outputTexture;
  auto intermediateTexture = helperTexture;
  for (auto i = (int)rendererIOResourcesSemanticList.size() - 1; i > 0; i--) {
    auto sourceSemantic = rendererIOResourcesSemanticList[i];
    renderIOResourcesList.push_back(VIDMetalRendererIOResources {
      .inputTexture = [self getInputTextureWithCurrentOutput:currentOutput
                                         intermediateTexture:intermediateTexture
                                              sourceSemantic:sourceSemantic],
      .outputTexture = currentOutput,
      .renderPassDescriptor = currentOutputRenderPassDescriptor,
      .semantic = sourceSemantic
    });

    if (sourceSemantic.value == VIDMetalRendererIOResourceSemanticsOutOfPlace) {
      std::swap(currentOutput, intermediateTexture);
      std::swap(currentOutputRenderPassDescriptor, intermediateTextureRenderPassDescriptor);
    }
  }

  auto initialInputTexture = [self
                              getInputTextureWithCurrentOutput:currentOutput
                              intermediateTexture:intermediateTexture
                              sourceSemantic:rendererIOResourcesSemanticList[0]];
  renderIOResourcesList.push_back(VIDMetalRendererIOResources {
    .inputTexture = initialInputTexture,
    .outputTexture = currentOutput,
    .renderPassDescriptor = [self initialRenderPassDescriptorWithTexture:currentOutput
                                                       initialLoadAction:initialLoadAction
                                                         backgroundColor:initialBackgroundColor],
    .semantic = rendererIOResourcesSemanticList[0]
  });

  std::reverse(renderIOResourcesList.begin(), renderIOResourcesList.end());
  return renderIOResourcesList;
}

+ (MTBTexture *)getInputTextureWithCurrentOutput:(MTBTexture *)currentOutput
    intermediateTexture:(MTBTexture *)intermediateTexture
    sourceSemantic:(VIDMetalRendererIOResourceSemantics *)sourceSemantic {
  switch (sourceSemantic.value) {
    case VIDMetalRendererIOResourceSemanticsInPlace: {
      return currentOutput;
    }
    case VIDMetalRendererIOResourceSemanticsOutOfPlace: {
      return intermediateTexture;
    }
    default: {
      LTParameterAssert(false,
                        @"Unexpected VIDMetalRendererIOResourceSemantics value");
    }
  }
}

@end

NS_ASSUME_NONNULL_END
