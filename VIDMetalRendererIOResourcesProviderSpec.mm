// Copyright (c) 2022 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import "VIDMetalRendererIOResourcesProvider.h"

#import <MetalToolbox/MTBTexture.h>

/// Data class storing \c VIDMetalRendererIOResources data.
/// This class needed to pass arguments to shared examples, which don't play nicely with structs
/// containing pointers as \c VIDMetalRendererIOResources.

@interface VIDMetalRendererIOResourcesData : NSObject

@property (readonly, nonatomic) MTBTexture *inputTexture;
@property (readonly, nonatomic) MTBTexture *outputTexture;
@property (readonly, nonatomic) MTLRenderPassDescriptor *renderPassDescriptor;

@end

@implementation VIDMetalRendererIOResourcesData

- (instancetype)initWithInputTexture:(MTBTexture *)inputTexture
                       outputTexture:(MTBTexture *)outputTexture
                renderPassDescriptor:(MTLRenderPassDescriptor *)renderPassDescriptor {
  if ((self = [super init])) {
    _inputTexture = inputTexture;
    _outputTexture = outputTexture;
    _renderPassDescriptor = renderPassDescriptor;
  }
  return self;
}

@end

static NSString *kVIDMetalRendererIOResourcesProviderExample =
    @"VIDMetalRendererIOResourcesProviderExample";

SharedExamplesBegin(VIDMetalRendererIOResourcesProvider)

sharedExamples(kVIDMetalRendererIOResourcesProviderExample, ^(NSDictionary *data) {
  it(@"should provide correct IO resources", ^{
    MTBTexture *outputTexture = data[@"outputTexture"];
    MTBTexture *helperTexture = data[@"helperTexture"];

    NSArray<VIDMetalRendererIOResourceSemantics *> *semantics = data[@"semantics"];
    NSArray<VIDMetalRendererIOResourcesData *> *expectedResources = data[@"expectedResources"];
    std::vector<VIDMetalRendererIOResourceSemantics *> semanticsVector;
    for (VIDMetalRendererIOResourceSemantics *semantic in semantics) {
      semanticsVector.push_back(semantic);
    }

    auto resources = [VIDMetalRendererIOResourcesProvider
                      ioResourcesWithRendererIOSemantics:semanticsVector outputTexture:outputTexture
                      helperTexture:helperTexture initialLoadAction:MTLLoadActionDontCare
                      initialBackgroundColor:MTLClearColorMake(0, 0, 0, 1)];

    expect(resources.size()).to.equal(expectedResources.count);
    for (size_t i = 0; i < std::min(resources.size(), expectedResources.count); i++) {
      expect(resources[i].inputTexture).to.equal(expectedResources[i].inputTexture);
      expect(resources[i].outputTexture).to.equal(expectedResources[i].outputTexture);
      expect(resources[i].renderPassDescriptor.colorAttachments[0].texture).to
        .equal(resources[i].outputTexture);
    }

    // should always have output texture as the output of the final resource
    expect(resources.back().outputTexture).to.equal(outputTexture);
  });

});

SharedExamplesEnd

SpecBegin(VIDMetalRendererIOResourcesProvider)

__block MTBTexture *outputTexture;
__block MTBTexture *helperTexture;

beforeEach(^{
  auto device = [MTBDevice mtb_defaultDevice];
  outputTexture = [device mtb_newSharedTextureWithWidth:50 height:50
                                            pixelFormat:MTLPixelFormatRGBA8Unorm
                                                  usage:MTLTextureUsageShaderRead];

  helperTexture = [device mtb_newTextureWithPropertiesOfTexture:outputTexture];
});

afterEach(^{
  outputTexture = nil;
  helperTexture = nil;
});

itBehavesLike(kVIDMetalRendererIOResourcesProviderExample, ^NSDictionary * _Nonnull{
  auto semantics = @[
    $(VIDMetalRendererIOResourceSemanticsOutOfPlace),
    $(VIDMetalRendererIOResourceSemanticsInPlace),
    $(VIDMetalRendererIOResourceSemanticsOutOfPlace)
  ];

  auto expectedResources = @[
    [[VIDMetalRendererIOResourcesData alloc] initWithInputTexture:outputTexture
                                                    outputTexture:helperTexture
                                             renderPassDescriptor:nil],
    [[VIDMetalRendererIOResourcesData alloc] initWithInputTexture:helperTexture
                                                    outputTexture:helperTexture
                                             renderPassDescriptor:nil],
    [[VIDMetalRendererIOResourcesData alloc] initWithInputTexture:helperTexture
                                                    outputTexture:outputTexture
                                             renderPassDescriptor:nil],
  ];

  return @{
    @"outputTexture" : outputTexture,
    @"helperTexture": helperTexture,
    @"semantics" : semantics,
    @"expectedResources": expectedResources,
  };
});

itBehavesLike(kVIDMetalRendererIOResourcesProviderExample, ^NSDictionary * _Nonnull{
  auto semantics = @[
    $(VIDMetalRendererIOResourceSemanticsOutOfPlace),
    $(VIDMetalRendererIOResourceSemanticsOutOfPlace)
  ];

  auto expectedResources = @[
    [[VIDMetalRendererIOResourcesData alloc] initWithInputTexture:outputTexture
                                                    outputTexture:helperTexture
                                             renderPassDescriptor:nil],
    [[VIDMetalRendererIOResourcesData alloc] initWithInputTexture:helperTexture
                                                    outputTexture:outputTexture
                                             renderPassDescriptor:nil]
  ];

  return @{
    @"outputTexture" : outputTexture,
    @"helperTexture": helperTexture,
    @"semantics" : semantics,
    @"expectedResources": expectedResources,
  };
});

itBehavesLike(kVIDMetalRendererIOResourcesProviderExample, ^NSDictionary * _Nonnull {
  auto semantics = @[
    $(VIDMetalRendererIOResourceSemanticsInPlace),
    $(VIDMetalRendererIOResourceSemanticsInPlace),
  ];

  auto expectedResources = @[
    [[VIDMetalRendererIOResourcesData alloc] initWithInputTexture:outputTexture
                                                    outputTexture:outputTexture
                                             renderPassDescriptor:nil],
    [[VIDMetalRendererIOResourcesData alloc] initWithInputTexture:outputTexture
                                                    outputTexture:outputTexture
                                             renderPassDescriptor:nil]
  ];

  return @{
    @"outputTexture" : outputTexture,
    @"helperTexture": helperTexture,
    @"semantics" : semantics,
    @"expectedResources": expectedResources,
  };
});

SpecEnd
