// Copyright (c) 2020 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import "VIDSourceFormat.metal.h"

/// Channel in displacement map representing a displacement.
enum DisplacementChannel : ushort {
  /// Red channel
  Red = 0,
  /// Green channel
  Green = 1,
  /// Blue channel
  Blue = 2
};

/// Textures used by fragment functions of Displacement Renderers.
enum TextureIndex {
  /// Source texture.
  Source,
  /// Map RGBA, BGRA or Y texture according to format. Displacement will be done according to
  /// RGB value of the map.
  Map,
  /// Map UV texture if format is YUV. Displacement will be done according to RGB value of the map.
  MapUV
};

/// Buffers used by fragment functions of Displacement Renderers.
enum FragmentBufferIndex {
  /// Render Parameters.
  parameters
};

/// Displacement renderer paremeters.
struct Parameters {
  /// Offset to add to displacement map values of the horizontal axis.
  float horizontalOffset;
  /// Offset to add to displacement map values of the vertical axis.
  float verticalOffset;
  /// Scale to multiply by the displacement map values of the horizontal axis. Must be positive.
  float horizontalScale;
  /// Scale to multiply by the displacement map values of the horizontal axis. Must be positive.
  float verticalScale;
  /// The channel in displacement map representing the horizontal displacement.
  DisplacementChannel horizontalChannel;
  /// The channel in displacement map representing the vertical displacement
  DisplacementChannel verticalChannel;
  /// Source format of the displacement map texture
  VIDSourceFormat displacementMapFormat;
};
