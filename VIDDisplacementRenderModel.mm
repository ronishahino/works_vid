// Copyright (c) 2020 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import "VIDDisplacementRenderModel.h"

#import "VIDAnimationPropertyNames.h"

NS_ASSUME_NONNULL_BEGIN

/// Channel in RGB map representing a displacement.
LTEnumImplement(NSUInteger, VIDDisplacementChannel,
  /// Red channel.
  VIDDisplacementChannelRed,
  /// Green Channel.
  VIDDisplacementChannelGreen,
  /// Blue channel.
  VIDDisplacementChannelBlue
);

@interface VIDDisplacementRenderModel ()

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

@implementation VIDDisplacementRenderModel

- (instancetype)initWithHorizontalOffset:(CGFloat)horizontalOffset
                          verticalOffset:(CGFloat)verticalOffset
                         horizontalScale:(CGFloat)horizontalScale
                           verticalScale:(CGFloat)verticalScale
                       horizontalChannel:(VIDDisplacementChannel *)horizontalChannel
                         verticalChannel:(VIDDisplacementChannel *)verticalChannel {
  if (self = [super init]) {
    _horizontalOffset = horizontalOffset;
    _verticalOffset = verticalOffset;
    _horizontalScale = horizontalScale;
    _verticalScale = verticalScale;
    _horizontalChannel = horizontalChannel;
    _verticalChannel = verticalChannel;
  }
  return self;
}

- (instancetype)initWithOther:(VIDDisplacementRenderModel *)other {
  return [self initWithHorizontalOffset:other.horizontalOffset verticalOffset:other.verticalOffset
                        horizontalScale:other.horizontalScale verticalScale:other.verticalScale
                      horizontalChannel:other.horizontalChannel
                        verticalChannel:other.verticalChannel];
}

#pragma mark -
#pragma mark VIDRenderModel
#pragma mark -

+ (VIDPropertiesInterpolationMethod *)propertiesInterpolationMethod {
  static VIDPropertiesInterpolationMethod *interpolationMethods = @{
    @instanceKeypath(VIDDisplacementRenderModel, horizontalOffset): $(VIDInterpolationMethodLinear),
    @instanceKeypath(VIDDisplacementRenderModel, verticalOffset): $(VIDInterpolationMethodLinear),
    @instanceKeypath(VIDDisplacementRenderModel, horizontalScale): $(VIDInterpolationMethodLinear),
    @instanceKeypath(VIDDisplacementRenderModel, verticalScale): $(VIDInterpolationMethodLinear),
    @instanceKeypath(VIDDisplacementRenderModel, horizontalChannel): $(VIDInterpolationMethodNone),
    @instanceKeypath(VIDDisplacementRenderModel, verticalChannel): $(VIDInterpolationMethodNone)
  };
  return interpolationMethods;
}

+ (VIDPropertiesUpdateOperator *)propertiesUpdateOperator {
  static VIDPropertiesUpdateOperator *updateOperators= @{
    @instanceKeypath(VIDDisplacementRenderModel, horizontalOffset): $(VIDPropertyUpdateOperatorAdd),
    @instanceKeypath(VIDDisplacementRenderModel, verticalOffset): $(VIDPropertyUpdateOperatorAdd),
    @instanceKeypath(VIDDisplacementRenderModel, horizontalScale):
        $(VIDPropertyUpdateOperatorMultiply),
    @instanceKeypath(VIDDisplacementRenderModel, verticalScale):
        $(VIDPropertyUpdateOperatorMultiply)
  };
  return updateOperators;
}

+ (VIDAnimationPropertiesMapping *)animationProperties {
  static VIDAnimationPropertiesMapping *animationProperties = @{
    kVIDAnimationPropertyScale: @[@instanceKeypath(VIDDisplacementRenderModel, horizontalScale)],
    kVIDAnimationPropertyScale: @[@instanceKeypath(VIDDisplacementRenderModel, verticalScale)],
  };
  return animationProperties;
}

#pragma mark -
#pragma mark NSCopying
#pragma mark -

- (VIDDisplacementRenderModel *)copyWithZone:(nullable NSZone __unused *)zone {
  if (self.class == VIDDisplacementRenderModel.class) {
    return self;
  }
  return [[VIDDisplacementRenderModel alloc] initWithOther:self];
}

#pragma mark -
#pragma mark NSMutableCopying
#pragma mark -

- (VIDMutableDisplacementRenderModel *)mutableCopyWithZone:(nullable NSZone __unused *)zone {
  return [[VIDMutableDisplacementRenderModel alloc] initWithOther:self];
}

#pragma mark -
#pragma mark NSObject
#pragma mark -

- (BOOL)isEqual:(VIDDisplacementRenderModel *)other {
  if (self == other) {
    return YES;
  }

  if (![other isKindOfClass:VIDDisplacementRenderModel.class]) {
    return NO;
  }

  return self.horizontalOffset == other.horizontalOffset &&
      self.verticalOffset == other.verticalOffset &&
      self.horizontalScale == other.horizontalScale && self.verticalScale == other.verticalScale &&
      [self.horizontalChannel isEqual:other.horizontalChannel] &&
      [self.verticalChannel isEqual:other.verticalChannel];
}

- (NSUInteger)hash {
  size_t seed = 0;

  lt::hash_combine(seed, self.horizontalOffset);
  lt::hash_combine(seed, self.verticalOffset);
  lt::hash_combine(seed, self.horizontalScale);
  lt::hash_combine(seed, self.verticalScale);
  lt::hash_combine(seed, [self.horizontalChannel hash]);
  lt::hash_combine(seed, [self.verticalChannel hash]);

  return seed;
}

@end

#pragma mark -
#pragma mark VIDMutableDisplacementRenderModel
#pragma mark -

@implementation VIDMutableDisplacementRenderModel

@dynamic horizontalOffset;
@dynamic verticalOffset;
@dynamic horizontalScale;
@dynamic verticalScale;
@dynamic horizontalChannel;
@dynamic verticalChannel;

@end

NS_ASSUME_NONNULL_END
