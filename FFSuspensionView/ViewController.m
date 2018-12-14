//
//  ViewController.m
//  FFSuspensionView
//
//  Created by blm on 2018/12/14.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "ViewController.h"
#import "FFSuspensionView.h"
#import "JumpView.h"
@interface ViewController ()<FFSuspensionViewDelegate>
@property (nonatomic, strong) JumpView *jumpView;
@property (nonatomic, strong) FFSuspensionView *suspensionView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _suspensionView = [[[FFSuspensionView shareView]ffSuspensionViewWithSize:50 sView:[UIApplication sharedApplication].keyWindow delegate:self] dismiss:^(FFSuspensionView * _Nonnull view) {
        NSLog(@"消失了");
    }];
    _suspensionView.hideEdge = false;
    [_suspensionView show];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)ffSuspensionViewViewDelegateWithTap:(nonnull FFSuspensionView *)view currentVC:(nonnull UIViewController *)vc {
    NSArray *titles = @[@"哈哈", @"呵呵", @"嘻嘻" , @"哈哈"];
    NSMutableArray *models = [NSMutableArray array];
    for (NSString *title in titles) {
        JumpViewModel *model = [[JumpViewModel alloc]init];
        model.content = title;
        [models addObject:model];
    }
    __weak __typeof (self)weakSelf = self;
    _jumpView = [JumpView jumpViewShowWithContents:models position:view.center tapBlock:^(JumpViewModel *tapModel) {
        if (tapModel) {
            
        }
        [weakSelf.suspensionView hideWithNow:false];
    }];
    _jumpView.showViewSize = 25;
    _jumpView.jumpDistance = 50;
    CurrentPosition position = (CurrentPosition)view.initialPosition;
    [_jumpView showWith:position];
    
    NSLog(@"点击了");
}

- (IBAction)aaa:(UIButton *)sender {
     
}

- (IBAction)buttonTap:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [_suspensionView dismissOrShow:sender.isSelected ? FFSuspensionViewShowTypeDismiss : FFSuspensionViewShowTypeShow];
}

@end
