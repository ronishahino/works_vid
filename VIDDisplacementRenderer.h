// Copyright (c) 2020 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import "VIDMetalRenderer.h"

@class MTBDevice;

NS_ASSUME_NONNULL_BEGIN

/// Renderers of \c VIDDisplacementRenderer instances.
@interface VIDDisplacementRenderer : NSObject <VIDMetalRenderer>

- (instancetype)init NS_UNAVAILABLE;

/// Initializes with \c device used for rendering and \c pixelFormat as the pixel format of the
/// output texture which this renderer can render to.
- (instancetype)initWithDevice:(MTBDevice *)device pixelFormat:(MTLPixelFormat)pixelFormat
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
