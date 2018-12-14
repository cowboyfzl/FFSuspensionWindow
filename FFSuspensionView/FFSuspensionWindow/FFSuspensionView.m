//
//  GestureView.m
//  Gesture
//
//  Created by fafa on 2018/12/1.
//  Copyright © 2018 fafa. All rights reserved.
//

#import "FFSuspensionView.h"

@interface FFSuspensionView() <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<FFSuspensionViewDelegate> delegate;

@property (nonatomic, assign) BOOL isHide;
@property (nonatomic, assign) BOOL isMovie;
@property (nonatomic, assign) BOOL isTap;
@property (nonatomic, strong) NSTimer *timer;;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) CGPoint originalPoint;

@property (nonatomic, copy) FFDismissBlock dismissBlock;
@property (nonatomic, copy) FFRectBlock rectBlock;
@property (nonatomic, copy) FFTapBlock tapBlock;
@property (nonatomic, copy) FFHideBlock hideBlock;
@end
static NSInteger LROffset = 15;
static NSInteger TBOffset = 35;
static NSInteger Delayed = 3;
static NSInteger DefaultSize = 50;

@implementation FFSuspensionView
NSString * _Nonnull const FFSuspensionViewTapKey = @"FFSuspensionViewTapKey";
static FFSuspensionView *_shareView;
+ (FFSuspensionView *)shareView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareView = [FFSuspensionView new];
    });
    return _shareView;
}

- (instancetype)ffSuspensionViewWithSize:(CGFloat)size Image:(UIImage *)image content:(NSString *)content sView:(UIView *)sView delegate:(id<FFSuspensionViewDelegate>)delegate {
    return [self ffSuspensionWithSize:size Image:image content:content sView:sView delegate:delegate initialPosition:InitialPositionBottomRight];
}

- (instancetype)ffSuspensionViewWithSize:(CGFloat)size sView:(UIView *)sView {
    return [self ffSuspensionWithSize:size Image:nil content:nil sView:sView delegate:nil initialPosition:InitialPositionBottomRight];
}

- (instancetype)ffSuspensionViewWithSize:(CGFloat)size sView:(UIView *)sView delegate:(nonnull id<FFSuspensionViewDelegate>)delegate {
    return [self ffSuspensionWithSize:size Image:nil content:nil sView:sView delegate:delegate initialPosition:InitialPositionBottomRight];
}

- (instancetype)ffSuspensionWithSize:(CGFloat)size Image:(UIImage *)image content:(NSString *)content sView:(UIView *)sView delegate:(id<FFSuspensionViewDelegate>)delegate initialPosition:(InitialPosition )initialPosition;
{
    self.sView = sView;
    self.delegate = delegate;
    self.image = image;
    self.content = content;
    self.initialPosition = InitialPositionBottomRight;
    self.bounds = CGRectMake(0, 0, size, size);
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hideDelayed = 3;
        _hideEdge = true;
        _isTap = false;
        self.isHide = true;
        self.isMovie = false;
        self.backgroundColor = [UIColor redColor];
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapContent)];
        tapGR.delegate = self;
        [self addGestureRecognizer:tapGR];
        
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(movePan:)];
        panGR.delegate = self;
        [self addGestureRecognizer:panGR];
        self.orientation = [UIApplication sharedApplication].statusBarOrientation;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)show {
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        self.bounds = CGRectMake(0, 0, DefaultSize, DefaultSize);
    }
    CGSize selfSize = self.bounds.size;
    CGSize sViewSize = self.sView.bounds.size;
    switch (_initialPosition) {
        case InitialPositionTopLeft:
            self.frame = CGRectMake(selfSize.width + LROffset, TBOffset, selfSize.width, selfSize.height);
            break;
            
        case InitialPositionTopRight:
            self.frame = CGRectMake(sViewSize.width - selfSize.width - LROffset, TBOffset, selfSize.width, selfSize.height);
            break;
        case InitialPositionBottomLeft:
            self.frame = CGRectMake(selfSize.width + LROffset, sViewSize.height - TBOffset - selfSize.height, selfSize.width, selfSize.height);
            break;
            
        case InitialPositionBottomRight:
            self.frame = CGRectMake(sViewSize.width - selfSize.width - LROffset, sViewSize.height - TBOffset - selfSize.height, selfSize.width, selfSize.height);
            break;
    }
    _originalPoint = CGPointMake(self.center.x / _sView.bounds.size.width, self.center.y / _sView.bounds.size.height);
    [self.sView addSubview:self];
    _isHide = false;
    if (_hideEdge) {
        [self hideWithNow:false];
    }
    
}

- (void)currentViewIsHide:(BOOL )hide {
    [_timer invalidate];
     _timer = nil;
    CGSize selfSize = self.bounds.size;
    CGSize sViewSize = self.sView.bounds.size;
    CGFloat cuttentPositionY = self.frame.origin.y;
    switch (_initialPosition) {
        case InitialPositionTopLeft:
        {
            CGFloat xPosition = hide ? -selfSize.width / 2 : LROffset;
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = CGRectMake(xPosition, cuttentPositionY, selfSize.width, selfSize.height);
            }];
        }
            break;
        case InitialPositionTopRight:
        {
            CGFloat xPosition = hide ? sViewSize.width - selfSize.width / 2 : sViewSize.width - selfSize.width - LROffset;
            
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = CGRectMake(xPosition, cuttentPositionY, selfSize.width, selfSize.height);
            }];
        }
            break;
        case InitialPositionBottomLeft:
        {
            CGFloat xPosition = hide ? -selfSize.width / 2 : LROffset;
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = CGRectMake(xPosition, cuttentPositionY, selfSize.width, selfSize.height);
            }];
        }
            break;
        case InitialPositionBottomRight:
        {
            CGFloat xPosition = hide ? sViewSize.width - selfSize.width / 2 : sViewSize.width - selfSize.width - LROffset;
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = CGRectMake(xPosition, cuttentPositionY, selfSize.width, selfSize.height);
            }];
        }
            break;
    }
    _originalPoint = CGPointMake(self.center.x / _sView.bounds.size.width, self.center.y / _sView.bounds.size.height);
    _isHide = hide;
    if (self.hideBlock) {
        self.hideBlock(self, hide);
    }
}

- (void)hideWithNow:(BOOL)isNow {
    _isTap = false;
    if (!_isHide) {
        if (isNow) {
            [self currentViewIsHide:true];
        } else {
            [self.timer fire];
        }
    }
}

- (void)tapContent {
    if (_isHide) {
        [self currentViewIsHide:false];
    } else {
        [_timer invalidate];
        _timer = nil;
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
         UIViewController *vc = [FFSuspensionView getCurrentVCFrom:rootViewController];
        if ([self.delegate respondsToSelector:@selector(ffSuspensionViewViewDelegateWithTap:currentVC:)]) {
            [self.delegate ffSuspensionViewViewDelegateWithTap:self currentVC:vc];
        }
        
        if (self.tapBlock) {
            self.tapBlock(self, vc);
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:FFSuspensionViewTapKey object:nil userInfo:@{@"VC": vc}];
        
    }
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [FFSuspensionView getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [FFSuspensionView getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

- (void)movePan:(UIPanGestureRecognizer *)pan {
    
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
        {
            CGPoint pLocation = [pan translationInView:_sView];
            CGFloat xp = self.frame.origin.x + pLocation.x;
            CGFloat yp = self.frame.origin.y + pLocation.y;
            [pan setTranslation:CGPointZero inView:_sView];
            
            if (xp < 0) {
                xp = 0;
            } else if (xp + self.bounds.size.width > _sView.bounds.size.width) {
                xp = _sView.bounds.size.width - self.bounds.size.width;
            } else {
                
            }
            
            if (yp < 0) {
                yp = 0;
            } else if (yp + self.bounds.size.height > _sView.bounds.size.height) {
                yp = _sView.bounds.size.height - self.bounds.size.height;
            } else {
                
            }
            
            self.frame = CGRectMake(xp, yp, self.bounds.size.width, self.bounds.size.height);
            if (_timer) {
                [_timer invalidate];
                _timer = nil;
            }
            
            if (self.center.x >= _sView.bounds.size.width / 2 && self.center.y <= _sView.bounds.size.height / 2) {
                self.initialPosition = InitialPositionTopRight;
            } else if(self.center.x < _sView.bounds.size.width / 2 && self.center.y <= _sView.bounds.size.height / 2) {
                self.initialPosition = InitialPositionTopLeft;
            } else if (self.center.x >= _sView.bounds.size.width / 2 && self.center.y >= _sView.bounds.size.height / 2) {
                self.initialPosition = InitialPositionBottomRight;
            } else {
                self.initialPosition = InitialPositionBottomLeft;
            }
            
            if ([self.delegate respondsToSelector:@selector(ffSuspensionViewViewDelegateWithRect:initialPosition:)]) {
                [self.delegate ffSuspensionViewViewDelegateWithRect:self.frame initialPosition:_initialPosition];
            }
            
            if (self.rectBlock) {
                self.rectBlock(self.frame, _initialPosition);
            }
            
            _originalPoint = CGPointMake(self.center.x / _sView.bounds.size.width, self.center.y / _sView.bounds.size.height);
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
            _isMovie = false;
            _isTap = false;
            [self currentViewIsHide:true];
        }
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return false;
}

- (void)dismissOrShow:(FFSuspensionViewShowType)type {
    NSInteger x = 0;
    [_timer invalidate];
    _timer = nil;
    switch (type) {
        case FFSuspensionViewShowTypeShow:
        {
            x = (_initialPosition == InitialPositionTopLeft || _initialPosition == InitialPositionBottomLeft) ?:self.sView.bounds.size.width;
            self.hidden = false;
            [UIView animateWithDuration:0.2 animations:^{
                self.center = CGPointMake(x, self.center.y);
            }];
        }
            break;
            
        case FFSuspensionViewShowTypeDismiss:
        {
            x = (_initialPosition == InitialPositionTopRight || _initialPosition == InitialPositionBottomRight) ? self.sView.bounds.size.width + self.bounds.size.width / 2 : -self.bounds.size.width / 2;
            [UIView animateWithDuration:0.2 animations:^{
                self.center = CGPointMake(x, self.center.y);
            } completion:^(BOOL finished) {
                self.hidden = true;
                if (self.dismissBlock) {
                    self.dismissBlock(self);
                }
            }];
             /// 再来一个皮的
//            if (!_isHide) {
//                [UIView animateWithDuration:0.2 animations:^{
//                    self.center = CGPointMake(self.sView.bounds.size.width + self.bounds.size.width / 2, self.center.y);
//                }];
//            } else {
//                CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//                CGPoint o = self.center;
//                CGPoint p = CGPointMake(self.center.x - self.bounds.size.width / 2 - 50, self.center.y);
//                CGPoint x = CGPointMake(_sView.bounds.size.width + self.bounds.size.width / 2, self.center.y);
//                animation.values = @[@(o),@(p), @(x)];
//                animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] , [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//                animation.duration = 0.5;
//                animation.removedOnCompletion = NO;
//                animation.repeatCount = 0;
//                animation.fillMode = kCAFillModeForwards;
//                [self.layer addAnimation:animation forKey:@""];
//            }
        }
            break;
    }
    
    
}

- (NSTimer *)timer {
    if (!_timer) {
        __weak __typeof (self)weakSelf = self;
        __block NSInteger index = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:true block:^(NSTimer * _Nonnull timer) {
            if (index == weakSelf.hideDelayed) {
                [weakSelf currentViewIsHide:true];
            }
            index += 1;
        }];
        [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer fire];
    }
    return _timer;
}

- (void)orientChange:(NSNotification *)noti {
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    if (orient == _orientation) {
        return;
    }
    
    self.center = CGPointMake(_sView.bounds.size.width * _originalPoint.x, _sView.bounds.size.height * _originalPoint.y);
    _originalPoint = CGPointMake(self.center.x / _sView.bounds.size.width, self.center.y / _sView.bounds.size.height);
    switch (orient) {
        case UIInterfaceOrientationPortrait:
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIInterfaceOrientationLandscapeRight:
            
            break;
        default:
            break;
    }
    _orientation = orient;
}

- (instancetype)dismiss:(FFDismissBlock)dismiss {
    _dismissBlock = dismiss;
    return self;
}

- (instancetype)movieRectBlock:(FFRectBlock)rectBlock {
    _rectBlock = rectBlock;
    return self;
}

- (instancetype)tapBlock:(FFTapBlock)tapBlock {
    _tapBlock = tapBlock;
    return self;
}

- (instancetype)hide:(FFHideBlock)hide {
    _hideBlock = hide;
    return self;
}

@end
