//
//  XER_Refresh.m
//  XER_OuterTester
//
//  Created by 冯宁 on 16/4/19.
//  Copyright © 2016年 xfenzi. All rights reserved.
//

#import "FNRefresh.h"
#import "FNEasingKeyFrame.h"

@interface FNRefresh () <FNRefreshHeaderDelegate>
@property (nonatomic, strong) FNRefreshHeader* header;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) BOOL needRefresh;
@property (nonatomic, strong) FNRefreshFooter* footer;
@property (nonatomic, strong) NSNumber* modelCount;
@property (nonatomic, assign) BOOL isPretending;
@property (nonatomic, assign) BOOL needsHandleRefresh;
@property (nonatomic, assign) BOOL needRefreshAgain;
@property (nonatomic, assign) BOOL isUpDragRefreshing;
@property (nonatomic, assign) BOOL isDownDragRefreshing;
@property (nonatomic, strong) CADisplayLink* haveMoreLink;
@property (nonatomic, assign) int haveMoreIndex;
@property (nonatomic, strong) CADisplayLink* noMoreLink;
@property (nonatomic, assign) int noMoreIndex;
@property (nonatomic, strong) NSTimer* haveMoreAnimateTimer;
@property (nonatomic, copy) void (^prepareReloadFunction)(void);
@end

@implementation FNRefresh

#define RESET_ANIMATE_LENGTH 24.0
static NSArray<NSNumber*>* haveMoreAnimateArray;
static NSArray<NSNumber*>* noMoreAnimateArray;
+ (void)initialize{
    if (self == [FNRefresh class]) {
        [self calculateAnimateArray];
    }
}

+ (void)calculateAnimateArray {
    NSMutableArray* mArray = [NSMutableArray array];
    for (int i = 0; i < RESET_ANIMATE_LENGTH; i++) {
        [mArray addObject:[NSNumber numberWithDouble:[FNEasingKeyFrame singleKeyFrameForAnimationType:FNEasingKeyFrameAnimationTypeCubicEaseInOut withProgressRate:i / RESET_ANIMATE_LENGTH] * 44.0]];
    }
    haveMoreAnimateArray = mArray.copy;
    [mArray removeAllObjects];
    for (int i = 0; i < RESET_ANIMATE_LENGTH; i++) {
        [mArray addObject:[NSNumber numberWithDouble:[FNEasingKeyFrame singleKeyFrameForAnimationType:FNEasingKeyFrameAnimationTypeCubicEaseInOut withProgressRate:1.0 - i / RESET_ANIMATE_LENGTH] * 44.0]];
    }
    noMoreAnimateArray = mArray.copy;
}

- (instancetype)initWithScrollView:(UIScrollView*)scrollView {
    if (self = [super init]) {
        self.scrollView = scrollView;
        self.pageSize = 20;
        self.bottomHeight = 0;
        self.maybeHaveMore = YES;
        self.needsHandleRefresh = NO;
        self.hideLoadingMoreFooter = NO;
        self.isUpDragRefreshing = NO;
        self.isDownDragRefreshing = NO;
        self.modelCount = [NSNumber numberWithUnsignedInteger:0];
        self.footer.hidden = YES;
    }
    return self;
}

- (instancetype)init{
    NSAssert(1, @"请使用- (instancetype)initWithMainKey:(NSString*)key");
    return self;
}

- (void)setHideLoadingMoreFooterWhenToEnd:(BOOL)hideLoadingMoreFooterWhenToEnd{
    self.footer.hideLoadingMoreFooterWhenToEnd = YES;
}

- (void)concatOldArray:(NSArray*)oldArray newArray:(NSArray*)newArray andSortArrayWithCompareBlock:(NSComparisonResult (^)(id model1, id model2))compare concatResultBlock:(void (^)(NSArray* resultArray))resultBlock complete:(void (^)(void))complete {
    self.prepareReloadFunction = nil;
    if (!self.isRefreshing) {
        self.isRefreshing = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* old = oldArray;
        if (oldArray == nil) {
            old = [NSArray array];
        }
        NSArray* new = newArray;
        if (newArray == nil) {
            new = [NSArray array];
        }
        if (![old isKindOfClass:[NSArray class]] || ![new isKindOfClass:[NSArray class]]) {
            return;
        }
        NSMutableArray* mArray = [NSMutableArray arrayWithArray:old];
        // 从旧array里面删除重复的
        for (id newModel in new) {
            for (id oldModel in old) {
                if (compare(newModel, oldModel) == 0) {
                    [mArray removeObject:oldModel];
                }
            }
        }
        NSMutableArray* mNew = [NSMutableArray arrayWithArray:mArray.copy];
        [mNew addObjectsFromArray:new];
        // 排序
        [mNew sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return -compare(obj1, obj2);
        }];
        old = mNew.copy;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (new.count == 0) {
                self.maybeHaveMore = NO;
            }else{
                self.maybeHaveMore = YES;
            }
            void (^block)(void) = ^(){
                resultBlock(old);
                if (complete) {
                    @try {
                        complete();
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }
                }
            };
            self.prepareReloadFunction = [block copy];
            self.modelCount = [NSNumber numberWithUnsignedInteger:old.count];
            if (!self.scrollView.isDecelerating && !self.scrollView.isDragging && !self.scrollView.isTracking && !self.header.isDowning) {
                [self refreshScrollView];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.needRefresh = YES;
                });
            }
        });
    });
}
- (void)concatOldArray:(NSArray*)oldArray newArray:(NSArray*)newArray withoutSortWithCompareBlock:(NSComparisonResult (^)(id model1, id model2))compare isUpDragRefresh:(BOOL)isUpDrag concatResultBlock:(void (^)(NSArray* resultArray))resultBlock complete:(void (^)(void))complete {
    self.prepareReloadFunction = nil;
    if (!self.isRefreshing) {
        self.isRefreshing = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* old = oldArray;
        if (oldArray == nil) {
            old = [NSArray array];
        }
        NSArray* new = newArray;
        if (newArray == nil) {
            new = [NSArray array];
        }
        if (![old isKindOfClass:[NSArray class]] || ![new isKindOfClass:[NSArray class]]) {
            return;
        }
        NSMutableArray* mArray = [NSMutableArray arrayWithArray:old];
        // 从旧array里面删除重复的
        NSInteger removeCount = 0;
        for (id newModel in new) {
            for (id oldModel in old) {
                if (compare(newModel, oldModel) == 0) {
                    [mArray removeObject:oldModel];
                    removeCount ++;
                }
            }
        }
        NSMutableArray* mNew = nil;
        if (isUpDrag) {
            mNew = [NSMutableArray arrayWithArray:mArray.copy];
            [mNew addObjectsFromArray:new];
        }else{
            mNew = [NSMutableArray arrayWithArray:new];
            removeCount = 0;
        }
        old = mNew.copy;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (new.count == 0) {
                self.maybeHaveMore = NO;
            }else{
                self.maybeHaveMore = YES;
            }
            __weak typeof(self) weakSelf = self;
            void (^block)(void) = ^(){
                resultBlock(old);
                if (removeCount == newArray.count && newArray.count != 0) {
                    weakSelf.needRefreshAgain = YES;
                    [weakSelf beginRefreshing:weakSelf.header withEventType:FNRefreshEventTypeUpDrag];
                }
                if (complete) {
                    @try {
                        complete();
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }
                }
            };
            self.prepareReloadFunction = [block copy];
            self.modelCount = [NSNumber numberWithUnsignedInteger:old.count];
            if (!self.scrollView.isDecelerating && !self.scrollView.isDragging && !self.scrollView.isTracking && !self.header.isDowning) {
                [self refreshScrollView];
            }else{
                self.needRefresh = YES;
            }
            
        });
    });
}

#pragma mark - header 相关

- (void)setNeedsRefresh {
    if (self.isRefreshing) {
        return;
    }
    if (!self.scrollView.isDecelerating && !self.scrollView.isDragging && !self.scrollView.isTracking && !self.header.isDowning) {
        [self refreshScrollView];
    }else{
        if (!self.timer) {
            self.needRefresh = YES;
            __weak typeof(self) weakSelf = self;
            self.timer = [NSTimer timerWithTimeInterval:1.0/60.0 target:weakSelf selector:@selector(observeDraggingSO) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        }
    }
}

- (void)pretendStartRefresh {
    self.isPretending = YES;
    [self.header startRefresh];
}
- (void)endRefresh {
    if (self.isRefreshing) {
        self.isRefreshing = NO;
    }
}

- (void)setIsRefreshing:(BOOL)isRefreshing {
    _isRefreshing = isRefreshing;
    if (_isRefreshing) {
        // 开启timer 监听
        if (!self.timer) {
            __weak typeof(self) weakSelf = self;
            self.timer = [NSTimer timerWithTimeInterval:1.0/60.0 target:weakSelf selector:@selector(observeDraggingSO) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        }
    }else{
        [self.timer invalidate];
        self.timer = nil;
        self.isUpDragRefreshing = NO;
        self.isDownDragRefreshing = NO;
        if (self.header.refreshing) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.header endRefresh];
            });
        }
        self.isPretending = NO;
        if (self.needRefreshAgain) {
            self.needRefreshAgain = NO;
            [self beginRefreshing:self.header withEventType:FNRefreshEventTypeUpDrag];
        }
    }
}

- (void)observeDraggingSO{
    if (self.needRefresh) {
        if (!self.scrollView.isDragging && !self.scrollView.isDecelerating && !self.scrollView.isTracking && !self.header.isDowning) {
            [self refreshScrollView];
        }
    }
}

- (void)refreshScrollView{
    if ([self.scrollView respondsToSelector:@selector(reloadData)]) {
        if (self.prepareReloadFunction) {
            @try {
                self.prepareReloadFunction();
            } @catch (NSException *exception) {
                
            } @finally {
                self.prepareReloadFunction = nil;
            }
        }
        if ([self.delegate respondsToSelector:@selector(refresh:willReloadScrollView:)]) {
            [self.delegate refresh:self willReloadScrollView:self.scrollView];
        }
        [self.scrollView performSelector:@selector(reloadData)];
    }
    self.isRefreshing = NO;
    self.needRefresh = NO;
    [self.footer setIsNoMoreToLoad:!_maybeHaveMore];
    if (self.modelCount.unsignedIntegerValue > 0 && !self.hideLoadingMoreFooter) {
        if (!_hideLoadingMoreFooter) {
            self.footer.hidden = NO;
        }
    }else{
        self.footer.hidden = YES;
    }
}

- (BOOL)shouldBeginRefresh{
    return [self beginRefreshing:self.header withEventType:FNRefreshEventTypeDownDrag];
}

- (BOOL)beginRefreshing:(FNRefreshHeader*)header withEventType:(FNRefreshEventType)type{
    if (self.isRefreshing) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(shouldBeginRefreshWithRefreshView:withEventType:)]) {
        if (self.isPretending) {
            self.isUpDragRefreshing = NO;
            self.isDownDragRefreshing = YES;
            if (!self.isRefreshing) {
                self.isRefreshing = YES;
            }
            return YES;
        }
        BOOL canBegin = [self.delegate shouldBeginRefreshWithRefreshView:self.header withEventType:type];
        if (self.isRefreshing != canBegin) {
            self.isRefreshing = canBegin;
        }
        if (type == FNRefreshEventTypeUpDrag) {
            self.isUpDragRefreshing = YES;
            self.isDownDragRefreshing = NO;
        }else{
            self.isDownDragRefreshing = YES;
            self.isUpDragRefreshing = NO;
        }
        return canBegin;
    }else{
        return NO;
    }
}

- (void)viewDealloc{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    [_scrollView removeObserver:self forKeyPath:@"frame"];
}

- (void)setHideLoadingMoreFooter:(BOOL)hideLoadingMoreFooter{
    _hideLoadingMoreFooter = hideLoadingMoreFooter;
    self.footer.hidden = hideLoadingMoreFooter;
}

- (void)setScrollView:(UIScrollView *)scrollView{
    if (!scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [_scrollView removeObserver:self forKeyPath:@"contentSize"];
        [_scrollView removeObserver:self forKeyPath:@"frame"];
        _scrollView = nil;
        [self.footer removeFromSuperview];
        [self.header removeFromSuperview];
        return;
    }
    _scrollView = scrollView;
    [_scrollView addSubview:self.header];
    self.header.frame = CGRectMake(0, self.headerHeight - 64, _scrollView.bounds.size.width, 64);
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [_scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    _scrollView.contentInset = UIEdgeInsetsMake(self.headerHeight, _scrollView.contentInset.left, _scrollView.contentInset.bottom > self.bottomHeight ? _scrollView.contentInset.bottom : self.bottomHeight, _scrollView.contentInset.right);
    
    [_scrollView addSubview:self.footer];
}

- (void)setHeaderHeight:(CGFloat)headerHeight{
    _headerHeight = headerHeight;
    self.header.headerHeight = _headerHeight;
    self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top + headerHeight, self.scrollView.contentInset.left, _scrollView.contentInset.bottom > self.bottomHeight ? _scrollView.contentInset.bottom : self.bottomHeight, self.scrollView.contentInset.right);
}



- (void)setMaybeHaveMore:(BOOL)maybeHaveMore{
    _maybeHaveMore = maybeHaveMore;
    // 刷新都放在不滑动的时候
    [self doHaveMoreAnimate];
}

- (void)doHaveMoreAnimate{
    if (!self.scrollView.isDecelerating && !self.scrollView.isDragging && !self.scrollView.isTracking && !self.header.isDowning) {
        [self.footer setIsNoMoreToLoad:!_maybeHaveMore];
        if ([self.scrollView isKindOfClass:[UIScrollView class]]) {
            if (_maybeHaveMore) {
                [self startHaveMore];
            }else{
                [self startNoMore];
            }
        }
        [self.haveMoreAnimateTimer invalidate];
        self.haveMoreAnimateTimer = nil;
    }else{
        if (!self.haveMoreAnimateTimer) {
            self.needRefresh = YES;
            __weak typeof(self) weakSelf = self;
            self.haveMoreAnimateTimer = [NSTimer timerWithTimeInterval:1.0/60.0 target:weakSelf selector:@selector(doHaveMoreAnimate) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.haveMoreAnimateTimer forMode:NSRunLoopCommonModes];
            [self.haveMoreAnimateTimer fire];
        }
    }
}

- (void)startHaveMore{
    if (self.scrollView.contentInset.bottom >= self.bottomHeight + 44) {
        return;
    }
    self.haveMoreIndex = 0;
    self.haveMoreLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(haveMoreAnimate)];
    [self.haveMoreLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)haveMoreAnimate{
    if (self.haveMoreIndex >= RESET_ANIMATE_LENGTH) {
        [self.haveMoreLink invalidate];
        self.haveMoreLink = nil;
        return;
    }
    [self.scrollView setContentInset:UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.bottomHeight + haveMoreAnimateArray[self.haveMoreIndex++].doubleValue, self.scrollView.contentInset.right)];
}

- (void)startNoMore{
    if (self.scrollView.contentInset.bottom <= self.bottomHeight) {
        return;
    }
    self.noMoreIndex = 0;
    self.noMoreLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(noMoreAnimate)];
    [self.noMoreLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)noMoreAnimate{
    if (self.noMoreIndex >= RESET_ANIMATE_LENGTH) {
        [self.noMoreLink invalidate];
        self.noMoreLink = nil;
        return;
    }
    [self.scrollView setContentInset:UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.bottomHeight + noMoreAnimateArray[self.noMoreIndex++].doubleValue, self.scrollView.contentInset.right)];
}

- (FNRefreshHeader *)header{
    if (_header == nil) {
        _header = [[FNRefreshHeader alloc] init];
        _header.delegate = self;
    }
    return _header;
}

- (FNRefreshFooter *)footer{
    if (_footer == nil) {
        _footer = [[FNRefreshFooter alloc] init];
    }
    return _footer;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        NSValue* new = change[@"new"];
        CGFloat realOffset = new.CGPointValue.y + _headerHeight - self.scrollView.contentInset.top;
        [self.header updateAnimationWithOffset:realOffset];
        CGFloat contentSizeHeight = self.scrollView.contentSize.height;
        CGFloat pageHeight = self.scrollView.frame.size.height;
        if (realOffset + pageHeight * 2 > contentSizeHeight && self.maybeHaveMore) {
            [self beginRefreshing:self.header withEventType:FNRefreshEventTypeUpDrag];
        }
        if (self.footer.window && CGRectIntersectsRect([self.footer convertRect:self.footer.bounds toView:self.footer.window], self.footer.window.bounds)) {
            [self.footer startLoading];
        }else{
            [self.footer endLoading];
        }
        return;
    }
    if ([keyPath isEqualToString:@"contentSize"]) {
        self.footer.frame = CGRectMake(0, self.scrollView.contentSize.height, self.scrollView.frame.size.width, 44);
    }
    if ([keyPath isEqualToString:@"frame"]) {
        self.header.frame = CGRectMake(0, self.headerHeight - 64, _scrollView.bounds.size.width, 64);
        self.footer.frame = CGRectMake(0, self.scrollView.contentSize.height, self.scrollView.frame.size.width, 44);
    }
}


@end
