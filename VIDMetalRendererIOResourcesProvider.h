// Copyright (c) 2021 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import <MetalToolbox/MTBTexture.h>

NS_ASSUME_NONNULL_BEGIN

/// Enum representing input/output semantics of a \c VIDMetalRenderer resource.
LTEnumDeclare(NSUInteger, VIDMetalRendererIOResourceSemantics,
  /// \c VIDMetalRenderer that gets different texture for input and output textures.
  VIDMetalRendererIOResourceSemanticsOutOfPlace,
  /// \c VIDMetalRenderer that gets only output texture, and operating directly on this texture.
  VIDMetalRendererIOResourceSemanticsInPlace
);

/// Struct storing IO resources for \c VIDMetalRenderer.
typedef struct {
  /// Renderer input texture.
  MTBTexture *inputTexture;
  /// Renderer output texture.
  MTBTexture *outputTexture;
  /// \c MTLRenderPassDescriptor used in the renderer.
  MTLRenderPassDescriptor *renderPassDescriptor;
  /// Indicates whether the input and output textures refer to the same storage.
  VIDMetalRendererIOResourceSemantics *semantic;
} VIDMetalRendererIOResources;

/// A class providing \c VIDMetalRendererIOResources for \c VIDMetalRenderer object.
/// Used to encode sequence of renderers one after the other, where there are 2 textures that uses
/// as input and output, and they swap roles alternately.
@interface VIDMetalRendererIOResourcesProvider : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Creates \c VIDMetalRendererIOResources for each renderer in \c rendererIOResourcesSemanticList.
///
/// @param rendererIOResourcesSemanticList list of renderer source semantics, that should be encoded
/// one after the other by this order.
/// @param outputTexture texture to store the final output of all renderer.
/// @param helperTexture texture using as temporary texture to store an intermediate render outputs.
/// @param initialLoadAction \c MTLLoadAction to be used in the \c MTLRenderPassDescriptor of the
/// first renderer.
/// @param initialBackgroundColor color of the background to be used in the
/// \c MTLRenderPassDescriptor of the first renderer.
+ (std::vector<VIDMetalRendererIOResources>)ioResourcesWithRendererIOSemantics:
    (const std::vector<VIDMetalRendererIOResourceSemantics *> &)rendererIOResourcesSemanticList
    outputTexture:(MTBTexture *)outputTexture helperTexture:(MTBTexture *)helperTexture
    initialLoadAction:(MTLLoadAction)initialLoadAction
    initialBackgroundColor:(MTLClearColor)initialBackgroundColor;

@end

NS_ASSUME_NONNULL_END
