// Copyright (c) 2020 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import "VIDRenderModel.h"

NS_ASSUME_NONNULL_BEGIN

/// Channel in RGB map representing a displacement.
LTEnumDeclare(NSUInteger, VIDDisplacementChannel,
  /// Red channel.
  VIDDisplacementChannelRed,
  /// Green Channel.
  VIDDisplacementChannelGreen,
  /// Blue channel.
  VIDDisplacementChannelBlue
);

/// Render model for displacement processor.
@interface VIDDisplacementRenderModel : NSObject <VIDRenderModel>

#pragma mark -
#pragma mark Initialization
#pragma mark -

- (instancetype)init NS_UNAVAILABLE;

/// Initializes with given values.
- (instancetype)initWithHorizontalOffset:(CGFloat)horizontalOffset
                          verticalOffset:(CGFloat)verticalOffset
                         horizontalScale:(CGFloat)horizontalScale
                           verticalScale:(CGFloat)verticalScale
                       horizontalChannel:(VIDDisplacementChannel *)horizontalChannel
                         verticalChannel:(VIDDisplacementChannel *)verticalChannel
    NS_DESIGNATED_INITIALIZER;

/// Offset in pixel units to add to displacement map values of the horizontal axis.
@property (readonly, nonatomic) CGFloat horizontalOffset;

/// Offset in pixel units to add to displacement map values of the vertical axis.
@property (readonly, nonatomic) CGFloat verticalOffset;

/// Scale in pixel units to multiply by the displacement map values of the horizontal axis.
/// Must be positive.
@property (readonly, nonatomic) CGFloat horizontalScale;

/// Scale in pixel units to multiply by the displacement map values of the vertical axis.
/// Must be positive.
@property (readonly, nonatomic) CGFloat verticalScale;

/// The channel in displacement map representing the horizontal displacement.
@property (readonly, nonatomic) VIDDisplacementChannel *horizontalChannel;

/// The channel in displacement map representing the vertical displacement.
@property (readonly, nonatomic) VIDDisplacementChannel *verticalChannel;

@end

#pragma mark -
#pragma mark Mutable
#pragma mark -

/// Mutable version of \c VIDDisplacementRenderModel.
@interface VIDMutableDisplacementRenderModel : VIDDisplacementRenderModel

/// Offset in pixel units to add to displacement map values of the horizontal axis.
@property (readwrite, nonatomic) CGFloat horizontalOffset;

/// Offset in pixel units to add to displacement map values of the vertical axis.
@property (readwrite, nonatomic) CGFloat verticalOffset;

/// Scale in pixel units to multiply by the displacement map values of the horizontal axis.
/// Must be positive.
@property (readwrite, nonatomic) CGFloat horizontalScale;

/// Scale in pixel units to multiply by the displacement map values of the vertical axis.
/// Must be positive.
@property (readwrite, nonatomic) CGFloat verticalScale;

/// The channel in displacement map representing the horizontal displacement.
@property (readwrite, nonatomic) VIDDisplacementChannel *horizontalChannel;

/// The channel in displacement map representing the vertical displacement.
@property (readwrite, nonatomic) VIDDisplacementChannel *verticalChannel;

@end

NS_ASSUME_NONNULL_END
