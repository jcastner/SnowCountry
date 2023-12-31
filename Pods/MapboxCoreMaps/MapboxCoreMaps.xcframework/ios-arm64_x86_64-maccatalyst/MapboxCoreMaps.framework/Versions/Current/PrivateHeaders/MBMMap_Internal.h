// This file is generated and will be overwritten automatically.

#import <MapboxCoreMaps/MBMMap.h>
#import <MapboxCoreMaps/MBMAsyncOperationResultCallback_Internal.h>
#import <MapboxCoreMaps/MBMQueryFeatureExtensionCallback_Internal.h>
#import <MapboxCoreMaps/MBMQueryFeatureStateCallback_Internal.h>
#import <MapboxCoreMaps/MBMQueryFeaturesCallback_Internal.h>

@interface MBMMap ()
- (nonnull instancetype)initWithClient:(nonnull id<MBMMapClient>)client
                            mapOptions:(nonnull MBMMapOptions *)mapOptions
                       resourceOptions:(nonnull MBMResourceOptions *)resourceOptions;

- (void)queryRenderedFeaturesForShape:(nonnull NSArray<MBMScreenCoordinate *> *)shape
                              options:(nonnull MBMRenderedQueryOptions *)options
                             callback:(nonnull MBMQueryFeaturesCallback)callback __attribute__((deprecated));
- (void)queryRenderedFeaturesForBox:(nonnull MBMScreenBox *)box
                            options:(nonnull MBMRenderedQueryOptions *)options
                           callback:(nonnull MBMQueryFeaturesCallback)callback __attribute__((deprecated));
- (void)queryRenderedFeaturesForPixel:(nonnull MBMScreenCoordinate *)pixel
                              options:(nonnull MBMRenderedQueryOptions *)options
                             callback:(nonnull MBMQueryFeaturesCallback)callback __attribute__((deprecated));
- (nonnull MBXCancelable *)queryRenderedFeaturesForGeometry:(nonnull MBMRenderedQueryGeometry *)geometry
                                                    options:(nonnull MBMRenderedQueryOptions *)options
                                                   callback:(nonnull MBMQueryFeaturesCallback)callback __attribute((ns_returns_retained)) NS_REFINED_FOR_SWIFT;
- (void)querySourceFeaturesForSourceId:(nonnull NSString *)sourceId
                               options:(nonnull MBMSourceQueryOptions *)options
                              callback:(nonnull MBMQueryFeaturesCallback)callback;
- (void)queryFeatureExtensionsForSourceIdentifier:(nonnull NSString *)sourceIdentifier
                                          feature:(nonnull MBXFeature *)feature
                                        extension:(nonnull NSString *)extension
                                   extensionField:(nonnull NSString *)extensionField
                                             args:(nullable NSDictionary<NSString *, id> *)args
                                         callback:(nonnull MBMQueryFeatureExtensionCallback)callback;
- (void)getFeatureStateForSourceId:(nonnull NSString *)sourceId
                     sourceLayerId:(nullable NSString *)sourceLayerId
                         featureId:(nonnull NSString *)featureId
                          callback:(nonnull MBMQueryFeatureStateCallback)callback;
- (void)setMemoryBudgetForMemoryBudget:(nullable MBMMapMemoryBudget *)memoryBudget NS_REFINED_FOR_SWIFT;
+ (void)clearDataForResourceOptions:(nonnull MBMResourceOptions *)resourceOptions
                           callback:(nonnull MBMAsyncOperationResultCallback)callback;
- (void)setViewAnnotationPositionsUpdateListenerForListener:(nullable id<MBMViewAnnotationPositionsUpdateListener>)listener;
- (nonnull MBXExpected<NSNull *, NSString *> *)addViewAnnotationForIdentifier:(nonnull NSString *)identifier
                                                                      options:(nonnull MBMViewAnnotationOptions *)options __attribute((ns_returns_retained));
- (nonnull MBXExpected<NSNull *, NSString *> *)updateViewAnnotationForIdentifier:(nonnull NSString *)identifier
                                                                         options:(nonnull MBMViewAnnotationOptions *)options __attribute((ns_returns_retained));
- (nonnull MBXExpected<NSNull *, NSString *> *)removeViewAnnotationForIdentifier:(nonnull NSString *)identifier __attribute((ns_returns_retained));
- (nonnull MBXExpected<MBMViewAnnotationOptions *, NSString *> *)getViewAnnotationOptionsForIdentifier:(nonnull NSString *)identifier __attribute((ns_returns_retained));
- (nonnull NSArray<MBMCanonicalTileID *> *)tileCoverForTileCoverOptions:(nonnull MBMTileCoverOptions *)tileCoverOptions
                                                          cameraOptions:(nullable MBMCameraOptions *)cameraOptions __attribute((ns_returns_retained)) NS_REFINED_FOR_SWIFT;
@end
