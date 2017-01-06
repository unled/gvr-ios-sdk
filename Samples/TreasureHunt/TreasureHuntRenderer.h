#import "GVRCardboardView.h"

/** TreasureHunt renderer delegate. */
@protocol TreasureHuntRendererDelegate <NSObject>
@optional

/** Called to pause the render loop because a 2D UI is overlaid on top of the renderer. */
- (void)shouldPauseRenderLoop:(BOOL)pause;

@end

/** TreasureHunt renderer. */
@interface TreasureHuntRenderer : NSObject<GVRCardboardViewDelegate>

@property (nonatomic, assign) GLKQuaternion quaternion;
@property(nonatomic, weak) id<TreasureHuntRendererDelegate> delegate;

- (void)spawnCube;

@end

