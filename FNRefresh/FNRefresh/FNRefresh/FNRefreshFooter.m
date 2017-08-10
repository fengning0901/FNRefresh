//
//  XER_isLoadingMoreFooter.m
//  XER
//
//  Created by 冯宁 on 12/10/15.
//  Copyright © 2015 xfenzi. All rights reserved.
//

#import "FNRefreshFooter.h"
#import "FNActivityIndicatorView.h"


@interface FNRefreshFooter ()

@property (nonatomic, strong) FNActivityIndicatorView* activityView;
@property (nonatomic, strong) UILabel* noMoreToLoad;

@end

#define screenRate ([UIScreen mainScreen].bounds.size.width  / 375.0)

@implementation FNRefreshFooter

#pragma mark - 生命函数
- (instancetype)init{
    if (self = [super init]) {
        [self setIsNoMoreToLoad:NO];
        [self setUpSubviews];
    }
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
}


#pragma mark - 接口调用
- (void)setHideLoadingMoreFooterWhenToEnd:(BOOL)hideLoadingMoreFooterWhenToEnd{
    _hideLoadingMoreFooterWhenToEnd = hideLoadingMoreFooterWhenToEnd;
    if (_hideLoadingMoreFooterWhenToEnd) {
        if (self.noMoreToLoad.hidden == NO) {
            self.noMoreToLoad.hidden = YES;
        }
    }
}

- (void)setIsNoMoreToLoad:(BOOL)isNoMoreToLoad{
    if (isNoMoreToLoad) {
        if (!_hideLoadingMoreFooterWhenToEnd) {
            self.noMoreToLoad.hidden = NO;
        }
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
    }else{
        self.noMoreToLoad.hidden = YES;
        [self.activityView startAnimating];
        self.activityView.hidden = NO;
    }
}

- (void)startLoading{
    if (!self.activityView.isAnimating) {
        [self.activityView startAnimating];
    }
}

- (void)endLoading{
    if (self.activityView.isAnimating) {
        [self.activityView stopAnimating];
    }
}

#pragma mark - 视图
- (void)setUpSubviews{
    UIView* contrainer = [[UIView alloc] init];
    [contrainer addSubview:self.activityView];
    [contrainer addSubview:self.noMoreToLoad];
    self.activityView.translatesAutoresizingMaskIntoConstraints = NO;
    self.noMoreToLoad.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"act":self.activityView,@"con":contrainer,@"noMore":self.noMoreToLoad};
    NSDictionary* metrics = @{@"actW":@(22.5*screenRate)};
    [contrainer addConstraint:[NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contrainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [contrainer addConstraint:[NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contrainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [contrainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[act(==actW)]" options:0 metrics:metrics views:dict]];
    [contrainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[act(==actW)]" options:0 metrics:metrics views:dict]];
    [contrainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[con]-(<=1)-[noMore]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dict]];
    [contrainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[con]-(<=1)-[noMore]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:dict]];
    
    [self addSubview:contrainer];
    contrainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[con(==44)]" options:0 metrics:nil views:dict]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contrainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
   
}

#pragma mark - 懒加载
- (FNActivityIndicatorView *)activityView{
    if (_activityView == nil) {
        _activityView = [[FNActivityIndicatorView alloc] init];
        [_activityView startAnimating];
    }
    return _activityView;
}

- (UILabel *)noMoreToLoad{
    if (_noMoreToLoad == nil) {
        _noMoreToLoad = [UILabel new];
        _noMoreToLoad.text = @"END";
        _noMoreToLoad.font = [UIFont systemFontOfSize:12];
        _noMoreToLoad.textAlignment = NSTextAlignmentCenter;
        _noMoreToLoad.textColor = [UIColor blackColor];
    }
    return _noMoreToLoad;
}


@end
