// Copyright (c) 2020 Lightricks. All rights reserved.
// Created by Roni Shahino.

#import "VIDDisplacementRenderModel.h"

#import <LTKitTestUtils/LTEqualityExamples.h>

#import "VIDAnimationPropertyNames.h"
#import "VIDRenderModelLogic.h"

SpecBegin(VIDDisplacementRenderModel)

__block VIDDisplacementRenderModel *model;

beforeEach(^{
  model = [[VIDDisplacementRenderModel alloc] initWithHorizontalOffset:-75 verticalOffset:-85
      horizontalScale:160 verticalScale:170 horizontalChannel:$(VIDDisplacementChannelRed)
      verticalChannel:$(VIDDisplacementChannelGreen)];
});

it(@"should be interpolatable", ^{
  VIDMutableDisplacementRenderModel *mutableModel = [model mutableCopy];
  auto properties = [VIDRenderModelLogic propertiesOfRenderModel:model
                                         withInterpolationMethod:$(VIDInterpolationMethodLinear)];
  for (NSString *key in properties) {
    [mutableModel setValue:@(7) forKeyPath:key];
  }

  expect(mutableModel.horizontalOffset).to.equal(7);
  expect(mutableModel.verticalOffset).to.equal(7);
  expect(mutableModel.horizontalScale).to.equal(7);
  expect(mutableModel.verticalScale).to.equal(7);
  expect(mutableModel.horizontalChannel).to.equal($(VIDDisplacementChannelRed));
  expect(mutableModel.verticalChannel).to.equal($(VIDDisplacementChannelGreen));
});

it(@"should return all of the non-interpolable properties", ^{
  NSSet<NSString *> *expectedProperties = [NSSet setWithArray:@[
    @instanceKeypath(VIDDisplacementRenderModel, horizontalChannel),
    @instanceKeypath(VIDDisplacementRenderModel, verticalChannel)
  ]];

  auto propertyKeys = [VIDRenderModelLogic propertiesOfRenderModel:model
                                           withInterpolationMethod:$(VIDInterpolationMethodNone)];

  expect(propertyKeys).to.equal(expectedProperties);
});

it(@"should create mutable copy", ^{
  VIDDisplacementRenderModel *originalModel = [model copy];
  VIDDisplacementRenderModel *expectedModel =
      [[VIDDisplacementRenderModel alloc] initWithHorizontalOffset:-15 verticalOffset:-16
                                                   horizontalScale:100 verticalScale:200
                                                 horizontalChannel:$(VIDDisplacementChannelGreen)
                                                   verticalChannel:$(VIDDisplacementChannelBlue)];

  VIDMutableDisplacementRenderModel *mutableModel = [model mutableCopy];
  mutableModel.horizontalOffset = -15;
  mutableModel.verticalOffset = -16;
  mutableModel.horizontalScale = 100;
  mutableModel.verticalScale = 200;
  mutableModel.horizontalChannel = $(VIDDisplacementChannelGreen);
  mutableModel.verticalChannel = $(VIDDisplacementChannelBlue);

  expect(model).to.equal(originalModel);
  expect([mutableModel copy]).to.equal(expectedModel);
});

it(@"should get the correct update method", ^{
  expect([VIDDisplacementRenderModel propertiesUpdateOperator]).to.equal(@{
    @instanceKeypath(VIDDisplacementRenderModel, horizontalOffset): $(VIDPropertyUpdateOperatorAdd),
    @instanceKeypath(VIDDisplacementRenderModel, verticalOffset): $(VIDPropertyUpdateOperatorAdd),
    @instanceKeypath(VIDDisplacementRenderModel, horizontalScale):
      $(VIDPropertyUpdateOperatorMultiply),
    @instanceKeypath(VIDDisplacementRenderModel, verticalScale):
      $(VIDPropertyUpdateOperatorMultiply)
  });
});

it(@"should create update method dictionary only once", ^{
  auto firstCall = [VIDDisplacementRenderModel propertiesUpdateOperator];
  auto secondCall = [VIDDisplacementRenderModel propertiesUpdateOperator];
  expect(firstCall == secondCall).to.beTruthy();
});

it(@"should get the correct properties for animation", ^{
  expect([VIDDisplacementRenderModel animationProperties]).to.equal(@{
    kVIDAnimationPropertyScale: @[@instanceKeypath(VIDDisplacementRenderModel, horizontalScale)],
    kVIDAnimationPropertyScale: @[@instanceKeypath(VIDDisplacementRenderModel, verticalScale)]
  });
});

it(@"should be able to set all animation properties", ^{
  VIDDisplacementRenderModel *renderModel = [[VIDDisplacementRenderModel alloc]
                                             initWithHorizontalOffset:-15 verticalOffset:-16
                                             horizontalScale:100 verticalScale:200
                                             horizontalChannel:$(VIDDisplacementChannelGreen)
                                             verticalChannel:$(VIDDisplacementChannelBlue)];

  VIDAnimationPropertiesMapping *animationProperties =
      [VIDDisplacementRenderModel animationProperties];
  for(NSArray<NSString *> *properties in animationProperties.allValues) {
    for(NSString *keypath in properties) {
      [renderModel setValue:@7 forKeyPath:keypath];
      [renderModel valueForKeyPath:keypath];
    }
  }
});

it(@"should create animation properties dictionary only once", ^{
  auto firstCall = [VIDDisplacementRenderModel animationProperties];
  auto secondCall = [VIDDisplacementRenderModel animationProperties];
  expect(firstCall == secondCall).to.beTruthy();
});

context(@"equality", ^{
  itBehavesLike(kLTEqualityExamples, ^{
    VIDDisplacementRenderModel *displacementModel = [[VIDDisplacementRenderModel alloc]
        initWithHorizontalOffset:-75 verticalOffset:-85 horizontalScale:160 verticalScale:170
        horizontalChannel:$(VIDDisplacementChannelRed)
        verticalChannel:$(VIDDisplacementChannelGreen)];

    VIDDisplacementRenderModel *identicalModel = [[VIDDisplacementRenderModel alloc]
        initWithHorizontalOffset:displacementModel.horizontalOffset
        verticalOffset:displacementModel.verticalOffset
        horizontalScale:displacementModel.horizontalScale
        verticalScale:displacementModel.verticalScale
        horizontalChannel:displacementModel.horizontalChannel
        verticalChannel:displacementModel.verticalChannel];

    VIDDisplacementRenderModel *differentHorizontalOffset = [[VIDDisplacementRenderModel alloc]
        initWithHorizontalOffset:10
        verticalOffset:displacementModel.verticalOffset
        horizontalScale:displacementModel.horizontalScale
        verticalScale:displacementModel.verticalScale
        horizontalChannel:displacementModel.horizontalChannel
        verticalChannel:displacementModel.verticalChannel];

    VIDDisplacementRenderModel *differentVerticalOffset = [[VIDDisplacementRenderModel alloc]
        initWithHorizontalOffset:displacementModel.horizontalOffset
        verticalOffset:20 horizontalScale:displacementModel.horizontalScale
        verticalScale:displacementModel.verticalScale
        horizontalChannel:displacementModel.horizontalChannel
        verticalChannel:displacementModel.verticalChannel];

    VIDDisplacementRenderModel *differentHorizontalScale = [[VIDDisplacementRenderModel alloc]
        initWithHorizontalOffset:displacementModel.horizontalOffset
        verticalOffset:displacementModel.verticalOffset
        horizontalScale:30
        verticalScale:displacementModel.verticalScale
        horizontalChannel:displacementModel.horizontalChannel
        verticalChannel:displacementModel.verticalChannel];

    VIDDisplacementRenderModel *differentVerticalScale = [[VIDDisplacementRenderModel alloc]
        initWithHorizontalOffset:displacementModel.horizontalOffset
        verticalOffset:displacementModel.verticalOffset
        horizontalScale:displacementModel.horizontalScale verticalScale:40
        horizontalChannel:displacementModel.horizontalChannel
        verticalChannel:displacementModel.verticalChannel];

    VIDDisplacementRenderModel *differentHorizontalChannel = [[VIDDisplacementRenderModel alloc]
        initWithHorizontalOffset:displacementModel.horizontalOffset
        verticalOffset:displacementModel.verticalOffset
        horizontalScale:displacementModel.horizontalScale
        verticalScale:displacementModel.verticalScale
        horizontalChannel:$(VIDDisplacementChannelBlue)
        verticalChannel:displacementModel.verticalChannel];

    VIDDisplacementRenderModel *differentVerticalChannel = [[VIDDisplacementRenderModel alloc]
        initWithHorizontalOffset:displacementModel.horizontalOffset
        verticalOffset:displacementModel.verticalOffset
        horizontalScale:displacementModel.horizontalScale
        verticalScale:displacementModel.verticalScale
        horizontalChannel:displacementModel.horizontalChannel
        verticalChannel:$(VIDDisplacementChannelRed)];

    return @{
      kLTEqualityExamplesObject: displacementModel,
      kLTEqualityExamplesEqualObject: identicalModel,
      kLTEqualityExamplesDifferentObjects: @[
        differentHorizontalOffset,
        differentVerticalOffset,
        differentHorizontalScale,
        differentVerticalScale,
        differentHorizontalChannel,
        differentVerticalChannel
      ]
    };
  });
});

SpecEnd
