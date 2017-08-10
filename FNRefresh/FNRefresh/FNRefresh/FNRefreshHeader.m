//
//  XER_PullDownRefresh.m
//  XER_PullDownRefresh
//
//  Created by 冯宁 on 1/4/16.
//  Copyright © 2016 xfenzi. All rights reserved.
//

#import "FNRefreshHeader.h"
#import "FNActivityIndicatorView.h"
#import "FNEasingKeyFrame.h"

@interface FNRefreshHeader ()

@property (nonatomic, strong) FNActivityIndicatorView* loadingView;
@property (nonatomic, weak) UIScrollView* scrollView;
@property (nonatomic, strong) NSTimer* goBackTimer;
@property (nonatomic, strong) NSTimer* goDownTimer;
@property (nonatomic, strong) CADisplayLink* downAniTimer;
@property (nonatomic, strong) CADisplayLink* resetTimer;
@property (nonatomic, strong) NSArray<NSValue*>* downArray;
@property (nonatomic, assign) unsigned long downIndex;
@property (nonatomic, strong) NSArray<NSValue*>* resetArray;
@property (nonatomic, assign) unsigned long resetIndex;
@end

#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define screenRate (screenWidth  / 375.0)

@implementation FNRefreshHeader

- (instancetype)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, -64, [UIScreen mainScreen].bounds.size.width, 64);
        [self setUpSubviews];
        
    }
    return self;
}

- (void)setHeaderHeight:(CGFloat)headerHeight{
    _headerHeight = headerHeight;
    self.frame = CGRectMake(0, self.frame.origin.y , [UIScreen mainScreen].bounds.size.width, 64);
}

- (void)setUpSubviews{
    [self addSubview:self.loadingView];
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary* dict = @{@"view":self,@"loading":self.loadingView};
    NSDictionary* metrics = @{@"actW":@(22.5*screenRate)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view]-(<=0)-[loading(==actW)]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-(<=0)-[loading(==actW)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:dict]];
}

- (void)updateAnimationWithOffset:(CGFloat)offset{
    [self.superview sendSubviewToBack:self];
    if (offset > 0 - _headerHeight) {
        self.frame = CGRectMake(0, -64, screenWidth, 64);
    }else {
        if (offset > -64 - _headerHeight) {
            self.frame = CGRectMake(0, - 64 , screenWidth, 64);
        }else{
            // + (self.scrollView.contentInset.top - _headerHeight) 这个需要加  因为在down 动画中 top 和 _headerHeight 是不一致的 会导致offset 出现偏大的情况
            self.frame = CGRectMake(0, (offset + _headerHeight + (self.scrollView.contentInset.top - _headerHeight)), screenWidth, 64);
        }
        if(offset < -64 - _headerHeight){
            if (self.refreshing) {
                return;
            }
            [self startRefresh];
        }
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    if ([[newSuperview class] isSubclassOfClass:[UIScrollView class]]) {
        self.scrollView = (UIScrollView*)newSuperview;
    }
}

- (void)didMoveToSuperview{
    [self.superview sendSubviewToBack:self];
}

- (void)startRefresh{
    [self.superview sendSubviewToBack:self];
    if ([self.delegate respondsToSelector:@selector(shouldBeginRefresh)]) {
        BOOL canBegin = [self.delegate shouldBeginRefresh];
        if (canBegin) {
            if (self.refreshing) {
                return;
            }
            _refreshing = YES;
            [self beginLoading];
            if (self.scrollView) {
                if (!self.scrollView.dragging && !self.scrollView.tracking) {
                    [self downScrollView];
                }else{
                    if (!self.goDownTimer) {
                        __weak typeof(self) weakSelf = self;
                        self.goDownTimer = [NSTimer timerWithTimeInterval:0.0001 target:weakSelf selector:@selector(downScrollView) userInfo:nil repeats:YES];
                        [[NSRunLoop currentRunLoop] addTimer:self.goDownTimer forMode:NSRunLoopCommonModes];
                        [self.goDownTimer fire];
                    }
                }
            }
        }
    }
}

- (void)downScrollView{
    if (!self.scrollView.dragging && !self.scrollView.tracking) {
        self.isDowning = YES;
        if (self.goDownTimer) {
            [self.goDownTimer invalidate];
            self.goDownTimer = nil;
        }
        if (self.scrollView.window) {
            if (!self.downAniTimer) {
                NSMutableArray* mArray = [NSMutableArray array];
                CGFloat offsetY = self.scrollView.contentOffset.y;
                CGFloat distence = -(_headerHeight + 64) - offsetY;
                for (float i = 0.0; i < 20.0; i++) {
                    [mArray addObject:[NSValue valueWithCGPoint:CGPointMake(self.scrollView.contentOffset.x, offsetY + [FNEasingKeyFrame singleKeyFrameForAnimationType:FNEasingKeyFrameAnimationTypeCubicEaseOut withProgressRate:i / 19.0] * distence)]];
                }
                self.downArray = mArray.copy;
                self.downIndex = 0;
                __weak typeof(self) weakSelf = self;
                self.downAniTimer = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(downAnimation)];
                [self.downAniTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
                [self downAniTimer];
            }
        }else{
            self.scrollView.contentInset = UIEdgeInsetsMake(_headerHeight+64,self.scrollView.contentInset.left , self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
            if (self.scrollView.contentOffset.x == 0 && self.scrollView.contentOffset.y == 0) {
                self.scrollView.contentOffset = CGPointZero;
            }
            self.frame = CGRectMake(0, -64, [UIScreen mainScreen].bounds.size.width, 64);
            self.isDowning = NO;
        }
    }
}

- (void)downAnimation{
    if (self.downIndex < 19) {
        [self.scrollView setContentOffset:self.downArray[self.downIndex].CGPointValue animated:NO];
        self.scrollView.contentInset = UIEdgeInsetsMake(-self.downArray[self.downIndex].CGPointValue.y, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
        self.downIndex ++;
    }else{
        [self.downAniTimer removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.downAniTimer invalidate];
        self.downAniTimer = nil;
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -_headerHeight - 64);
        self.scrollView.contentInset = UIEdgeInsetsMake(_headerHeight+64,self.scrollView.contentInset.left , self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
        self.isDowning = NO;
    }
}

- (void)endRefresh{
    [self.superview sendSubviewToBack:self];
    if (self.scrollView) {
        if (!self.scrollView.dragging && !self.scrollView.decelerating && !self.scrollView.tracking && self.isDowning == NO) {
            [self _resetScrollView];
        }else{
            if (!self.goBackTimer) {
                __weak typeof(self) weakSelf = self;
                self.goBackTimer = [NSTimer timerWithTimeInterval:0.05 target:weakSelf selector:@selector(resetScrollView) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.goBackTimer forMode:NSRunLoopCommonModes];
            }
        }
    }
}

- (void)resetScrollView{
    if (!self.scrollView.dragging && !self.scrollView.decelerating && !self.scrollView.tracking && self.isDowning == NO) {
        [self _resetScrollView];
    }
}

- (void)_resetScrollView{
    [self.goBackTimer invalidate];
    self.goBackTimer = nil;
    [self endLoading];
    
    if (self.scrollView.window) {
        if (!self.resetTimer) {
            NSMutableArray* mArray = [NSMutableArray array];
            CGFloat nowTop = self.scrollView.contentInset.top;
            CGFloat distence = nowTop - _headerHeight;
            for (float i = 0.0; i < 20.0; i++) {
                [mArray addObject:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(nowTop - [FNEasingKeyFrame singleKeyFrameForAnimationType:FNEasingKeyFrameAnimationTypeCubicEaseOut withProgressRate:i / 19.0] * distence, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right)]];
            }
            self.resetArray = mArray.copy;
            self.resetIndex = 0;
            __weak typeof(self) weakSelf = self;
            self.resetTimer = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(resetAnimation:)];
            [self.resetTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [self resetAnimation:nil];
        }
    }else{
        self.scrollView.contentInset = UIEdgeInsetsMake(_headerHeight ,  self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
        self.frame = CGRectMake(0,-64, [UIScreen mainScreen].bounds.size.width, 64);
        self.loadingView.transform = CGAffineTransformIdentity;
        _refreshing = NO;
    }
}

- (void)resetAnimation:(CADisplayLink*)timer{
    if (self.resetIndex < 19) {
        self.scrollView.contentInset = self.resetArray[self.resetIndex].UIEdgeInsetsValue;
        self.resetIndex ++;
    }else{
        self.scrollView.contentInset = UIEdgeInsetsMake(_headerHeight, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
        self.loadingView.transform = CGAffineTransformIdentity;
        _refreshing = NO;
        [self.resetTimer removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.resetTimer invalidate];
        self.resetTimer = nil;
    }
}

- (void)animateResetScrollView{
    if ((long)self.scrollView.contentInset.top > (long)_headerHeight) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.scrollView.contentInset.top - 64.0 / 24.0 > _headerHeight) {
                self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top - 64.0 / 24.0, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
            }else{
                self.scrollView.contentInset = UIEdgeInsetsMake(_headerHeight, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right);
            }
            [self updateAnimationWithOffset:self.scrollView.contentOffset.y];
            [self animateResetScrollView];
        });
    }else{
        self.loadingView.transform = CGAffineTransformIdentity;
        _refreshing = NO;
    }
}

- (void)beginLoading{
    [self.loadingView startAnimating];
}

- (void)endLoading{
    [self.loadingView stopAnimating];
}

- (FNActivityIndicatorView *)loadingView{
    if (_loadingView == nil) {
        _loadingView = [[FNActivityIndicatorView alloc] init];
    }
    return _loadingView;
}

@end
