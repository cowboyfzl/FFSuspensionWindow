//
//  JumpView.m
//  binzhuangtu
//
//  Created by blm on 2018/11/30.
//  Copyright © 2018 BLM. All rights reserved.
//

#import "JumpView.h"

@interface JumpView() <UIGestureRecognizerDelegate, CAAnimationDelegate>
@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, strong) TapBlock tapBlock;
@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic, strong) NSMutableArray *positions;
@property (nonatomic, assign) BOOL isFinish;
@end

@implementation JumpView

+ (JumpView *)jumpViewShowWithContents:(NSArray <JumpViewModel *> *)contents position:(CGPoint)position tapBlock:(TapBlock)tapBlock{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    JumpView *view = [[JumpView alloc]initWithFrame:window.bounds];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    view.contents = contents;
    view.position = position;
    view.tapBlock = tapBlock;
    [window addSubview:view];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isFinish = false;
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgTap)];
        tapGR.delegate = self;
        [self addGestureRecognizer:tapGR];
    }
    return self;
}

- (void)bgTap {
    if (self.tapBlock) {
        self.tapBlock(nil);
        [self hide];
    }
    
}

- (void)showWith:(CurrentPosition )currentPosition {
    _views = [NSMutableArray array];
    _positions = [NSMutableArray array];
    if (!_jumpDistance) {
        _jumpDistance = 100;
    }
    
    if (!_showViewSize) {
        _showViewSize = 50;
    }
    
    if (_position.y + _showViewSize > [UIScreen mainScreen].bounds.size.height) {
        _position.y = [UIScreen mainScreen].bounds.size.height - _showViewSize;
    }
    
    if (_position.y + _showViewSize <= _showViewSize) {
        _position.y = _showViewSize;
    }
    
    if (_position.x + _showViewSize > [UIScreen mainScreen].bounds.size.width) {
        _position.x = [UIScreen mainScreen].bounds.size.width - _showViewSize;
    }
    
    if (_position.x + _showViewSize <= _showViewSize) {
        _position.x = _showViewSize;
    }
    
    NSInteger i = 1;
    for (JumpViewModel *model in _contents) {
        UIView *showView = [[UIView alloc]init];
        showView.center = _position;
        showView.bounds = CGRectMake(0, 0, _showViewSize, _showViewSize);
        showView.layer.cornerRadius = _showViewSize / 2;
        showView.layer.masksToBounds = true;
        showView.tag = i;
        CGFloat x = (_showViewSize + _jumpDistance) * cos((M_PI_2 * 1.5) * i / _contents.count - 0.6);
        CGFloat y = (_showViewSize + _jumpDistance) * sin((M_PI_2 * 1.5) * i / _contents.count - 0.6);
        CGFloat px = 0;
        CGFloat py = 0;
        switch (currentPosition) {
            case CurrentPositionTopLeft:
                px = _position.x + x;
                py = _position.y + y;
                break;
                
            case CurrentPositionTopRight:
                px = _position.x - x;
                py = _position.y + y;
                break;
            case CurrentPositionBottomLeft:
                px = x + _position.x;
                py = _position.y - y;
                break;
                
            case CurrentPositionBottomRight:
                px = _position.x - x;
                py = _position.y - y;
                break;
        }
        
        showView.center = CGPointMake(px, py);
        showView.alpha = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([[self getDelTime] floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [showView.layer addAnimation:[self showKeyFramWithCenter:CGPointMake(px, py)] forKey:nil];
        });
        [_positions addObject:@(CGPointMake(px, py))];
        [_views addObject:showView];
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, 0, showView.bounds.size.width, showView.bounds.size.height);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.text = [NSString stringWithFormat:@"%ld", (long)i];
        [showView addSubview:label];
        showView.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue:arc4random() % 255 / 255.0 alpha:1];
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        [showView addGestureRecognizer:tapGR];
        [self addSubview:showView];
        i += 1;
    }
}

- (NSString *)getDelTime {
    NSInteger del = arc4random() % 9 + 5;
    NSString *delTime = [NSString stringWithFormat:@"0.0%ld", del];
    return delTime;
}

- (CASpringAnimation *)showKeyFramWithCenter:(CGPoint )center {
    CASpringAnimation *spring = [CASpringAnimation animationWithKeyPath:@"position"];
    spring.damping = 10;
    spring.stiffness = 100;
    spring.mass = 1;
    spring.initialVelocity = 5;
    spring.duration = spring.settlingDuration;
    spring.delegate = self;
    spring.fromValue = @(_position);
    spring.toValue = @(center);
    return spring;
}

- (void)animationDidStart:(CAAnimation *)anim {
    for (NSInteger i = 0; i < _views.count; i++) {
        UIView *view = _views[i];
        [UIView animateWithDuration:0.3	 animations:^{
            view.alpha = 1;
        }];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _isFinish = true;
}

- (void)tapView:(UIGestureRecognizer *)tapGR {
    UIView *view = tapGR.view;
    NSLog(@"%ld", view.tag);
    if (self.tapBlock) {
        self.tapBlock(_contents[view.tag - 1]);
        [self hide];
    }
}

- (void)hide {
    
    [UIView animateWithDuration:0.2 animations:^{
        if (self.isFinish) {
            for (UIView *view in self.views) {
                view.center = self.position;
            }
        } else {
            self.alpha = 0.2;
        }
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [touch.view isEqual:self];
}


@end
