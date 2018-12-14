//
//  JumpView.h
//  binzhuangtu
//
//  Created by blm on 2018/11/30.
//  Copyright © 2018 BLM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JumpViewModel.h"
typedef NS_ENUM(NSInteger, CurrentPosition) {
    /// 左上
    CurrentPositionTopLeft,
    /// 右上
    CurrentPositionTopRight,
    /// 左下
    CurrentPositionBottomLeft,
    /// 右下
    CurrentPositionBottomRight,
};

typedef void(^TapBlock)(JumpViewModel *tapModel);
@interface JumpView : UIView

/**
 初始化方法

 @param contents 内容
 @param position 中心点
 @param tapBlock 点击回调
 @return 当前对象
 */
+ (JumpView *)jumpViewShowWithContents:(NSArray <JumpViewModel *> *)contents position:(CGPoint)position tapBlock:(TapBlock)tapBlock;
/// 跳跃距离 default 100
@property (nonatomic, assign) CGFloat jumpDistance;
/// 弹出按钮尺寸 default 50
@property (nonatomic, assign) CGFloat showViewSize;
/**
 消失
 */
- (void)hide;

/**
 展示
 */
- (void)showWith:(CurrentPosition )currentPosition;
@end
