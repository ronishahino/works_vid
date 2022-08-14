// Copyright (c) 2020 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import "VIDDisplacementRenderer.metal.h"

#import <Lithography/LITMetalUtils.metal.h>
#import <Lithography/LITPassthroughVertex.metal.h>
#import <metal_stdlib>

#import "VIDColorSpaceConversion.metal.h"
#import "VIDSourceFormat.metal.h"

using namespace metal;

static constexpr sampler kMapSampler(filter::nearest, address::clamp_to_edge);
static constexpr sampler kInputTextureSampler(filter::linear, address::mirrored_repeat);

/// This function uses Lithography's YCbCr->RGB conversion, and not VideoEngine's conversions that
// assumes non-linear values.
template<typename U>
static inline vec<U, 3> sampleSourceRGB(texture2d<U> texture, texture2d<U> textureUV,
                        VIDSourceFormat format, float2 position, sampler sampler) {
  if (format == VIDSourceFormatRGBA) {
    return texture.sample(sampler, position).bgr;
  } else if (format == VIDSourceFormatBGRA) {
    return texture.sample(sampler, position).rgb;
  } else {
    U y = texture.sample(sampler, position).r;
    vec<U, 2> uv = textureUV.sample(sampler, position).rg;
    vec<U, 3> ycc(y, uv);
    vec<U, 3> rgb = format == VIDSourceFormatYUVVideoRange ?
        transformYCbCrVideoRangeToRGB(ycc) : transformYCbCrFullRangeToRGB(ycc);
    return rgb;
  }
}

template<typename U>
static inline vec<U, 2> displacementPosition(vec<U, 3> value, float horizontalOffset,
                                             float verticalOffset, float horizontalScale,
                                             float verticalScale, int horizontalChannel,
                                             int verticalChannel, uint2 imageSize) {

  vec<U, 2> displacementInPixels = vec<U, 2>(horizontalScale * value[horizontalChannel] +
                                             horizontalOffset,
                                             verticalScale * value[verticalChannel] +
                                             verticalOffset);
  auto normalizedDisplacement = divide(displacementInPixels, vec<U, 2>(imageSize));
  return normalizedDisplacement;
}

fragment half4 displacementFragmetShader(LITPassthroughVertexOut vin [[stage_in]],
    texture2d<half, access::sample> input [[texture(TextureIndex::Source)]],
    texture2d<float, access::sample> map [[texture(TextureIndex::Map)]],
    texture2d<float, access::sample> mapUV [[texture(TextureIndex::MapUV)]],
    constant Parameters &parameters [[buffer(0)]]) {
  auto mapValue = sampleSourceRGB(map, mapUV, parameters.displacementMapFormat, vin.texCoord,
                                      kMapSampler).rgb;
  auto imageSize = uint2(input.get_width(), input.get_height());
  auto displacement = displacementPosition(mapValue, parameters.horizontalOffset,
                                           parameters.verticalOffset, parameters.horizontalScale,
                                           parameters.verticalScale, parameters.horizontalChannel,
                                           parameters.verticalChannel, imageSize);

  auto value = input.sample(kInputTextureSampler, vin.texCoord + displacement);
  return value;
}
