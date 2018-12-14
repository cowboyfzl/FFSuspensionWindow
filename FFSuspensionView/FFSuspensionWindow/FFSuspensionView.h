//
//  GestureView.h
//  Gesture
//
//  Created by fafa on 2018/12/1.
//  Copyright © 2018 fafa. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * _Nonnull const FFSuspensionViewTapKey;

typedef NS_ENUM(NSInteger, InitialPosition) {
    /// 左上
    InitialPositionTopLeft,
    /// 右上
    InitialPositionTopRight,
    /// 左下
    InitialPositionBottomLeft,
    /// 右下
    InitialPositionBottomRight,
};

typedef NS_ENUM(NSInteger, FFSuspensionViewShowType) {
    /// 消失
    FFSuspensionViewShowTypeDismiss,
    /// 显示
    FFSuspensionViewShowTypeShow,
};

@class FFSuspensionView;
@protocol FFSuspensionViewDelegate <NSObject>

@optional
/**
 当前手势View的位置

 @param rect 位置和尺寸
 @param initialPosition 属于那片区域
 */
- (void)ffSuspensionViewViewDelegateWithRect:(CGRect )rect initialPosition:(InitialPosition )initialPosition;

/**
 点击后的回调

 @param view 当前view
 @param vc 当前CV
 */
- (void)ffSuspensionViewViewDelegateWithTap:(FFSuspensionView *)view currentVC:(UIViewController *)vc;

@end

typedef void(^FFRectBlock)(CGRect rect, InitialPosition initialPosition);
typedef void(^FFTapBlock)(FFSuspensionView *view, UIViewController *currentVC);
typedef void(^FFHideBlock)(FFSuspensionView *view, BOOL isHide);
typedef void(^FFDismissBlock)(FFSuspensionView *view);
@interface FFSuspensionView : UIView

/**
 单例

 @return FFSuspensionView
 */
+ (FFSuspensionView *)shareView;

/**
 自定义方法
 
 @param size 宽高（圆形的所以只需要一个边长）
 @param image 图片
 @param content 内容
 @param sView 父视图
 @param delegate 代理
 @return 对象
 */
- (instancetype)ffSuspensionViewWithSize:(CGFloat )size Image:(UIImage * _Nullable )image content:(NSString * _Nullable)content sView:(UIView *_Nonnull)sView delegate:(id<FFSuspensionViewDelegate>)delegate;

/**
 自定义方法

 @param image 图片
 @param content 内容
 @param sView 父视图
 @param delegate 代理
 @param initialPosition 位置
 @return 实例
 */
- (instancetype)ffSuspensionWithImage:(UIImage *_Nullable)image content:(NSString *_Nullable)content sView:(UIView *)sView delegate:(id<FFSuspensionViewDelegate>)delegate initialPosition:(InitialPosition )initialPosition;


/**
 自定义方法

 @param size 尺寸
 @param sView 父视图
 @param delegate 代理
 @return 实例
 */
-(instancetype)ffSuspensionViewWithSize:(CGFloat )size sView:(UIView *_Nonnull)sView delegate:(id<FFSuspensionViewDelegate>)delegate;

/**
 自定义方法

 @param size h尺寸
 @param sView 父视图
 @return 实例
 */
-(instancetype)ffSuspensionViewWithSize:(CGFloat )size sView:(UIView *_Nonnull)sView;

/// 当前image
@property (nonatomic, strong) UIImage *image;
/// 当前content
@property (nonatomic, copy) NSString *content;
/// 出现后是否隐藏
@property (nonatomic, assign, getter=isHideEdge) BOOL hideEdge;
/// 初始位置(默认右下角)
@property (nonatomic, assign) InitialPosition initialPosition;
/// 延时隐藏默认3秒
@property (nonatomic, assign) NSInteger hideDelayed;
/// sView
@property (nonatomic, weak) UIView *sView;
/**
 显示
 */
- (void)show;

/**
 回到边缘

 @param isNow 是否立即隐藏
 */
- (void)hideWithNow:(BOOL )isNow;


/**
 是否完全消失

 @param type 是否消失
 */
- (void)dismissOrShow:(FFSuspensionViewShowType )type;

/**
 移动回调

 @param rectBlock 尺寸和方位
 @return 实例
 */
- (instancetype)movieRectBlock:(FFRectBlock )rectBlock;

/**
 点击回调

 @param tapBlock 点击返回的当前实例和当前VC
 @return 实例
 */
- (instancetype)tapBlock:(FFTapBlock )tapBlock;

/**
 消失后回调
 
 @param dismiss 消失返回当前实例
 @return 实例
 */
- (instancetype)dismiss:(FFDismissBlock )dismiss;

/**
 隐藏或出现后回调
 
 @param hide 隐藏回调返回当前实例
 @return 实例
 */
- (instancetype)hide:(FFHideBlock )hide;
@end

NS_ASSUME_NONNULL_END
