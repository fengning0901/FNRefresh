//
//  XER_Refresh.h
//  XER_OuterTester
//
//  Created by 冯宁 on 16/4/19.
//  Copyright © 2016年 xfenzi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNRefreshFooter.h"
#import "FNRefreshHeader.h"

typedef NS_ENUM(NSInteger, FNRefreshMainKeyType) {
    FNRefreshMainKeyTypeString = 0,
    FNRefreshMainKeyTypeNumber = 1
};

typedef NS_ENUM(NSInteger, FNRefreshEventType) {
    FNRefreshEventTypeUpDrag = 0,
    FNRefreshEventTypeDownDrag = 1
};

@class FNRefresh;

@protocol FNRefreshDelegate <NSObject>
@required
// 询问代理是否允许开始刷新，给代理一次拒绝刷新的机会
- (BOOL)shouldBeginRefreshWithRefreshView:(FNRefreshHeader*)refreshView withEventType:(FNRefreshEventType)type;
@optional
// 在调用reloadData之前调用
- (void)refresh:(FNRefresh*)refresh willReloadScrollView:(UIScrollView*)scrollView;

@end

@interface FNRefresh : NSObject

- (instancetype)initWithScrollView:(UIScrollView*)scrollView;
// 拼接新旧数组去重并且排序，之后在合适的时候调用scrollView的reloadData方法
- (void)concatOldArray:(NSArray*)oldArray newArray:(NSArray*)newArray andSortArrayWithCompareBlock:(NSComparisonResult (^)(id model1, id model2))compare concatResultBlock:(void (^)(NSArray* resultArray))resultBlock complete:(void (^)(void))complete;
// 拼接新旧数组去重但是不排序，之后在合适的时候调用scrollView的reloadData方法
- (void)concatOldArray:(NSArray*)oldArray newArray:(NSArray*)newArray withoutSortWithCompareBlock:(NSComparisonResult (^)(id model1, id model2))compare isUpDragRefresh:(BOOL)isUpDrag concatResultBlock:(void (^)(NSArray* resultArray))resultBlock complete:(void (^)(void))complete;
// 设置在scrollView停止滚动的瞬间立即调用reload，是一个延时监听动作
- (void)setNeedsRefresh;
// 在不需要调用refreshArray:WithArray:放的时候可以使用以下方法控制refreshView的出现于隐藏
- (void)pretendStartRefresh;
// 手动停止刷新
- (void)endRefresh;
// 上面的可选方法如果使用了  在控制器dealloc的时候必须调用这个方法 否则会崩溃
- (void)viewDealloc;


@property (nonatomic, weak, readonly) UIScrollView* scrollView;
// 可选参数如果要加入上拉和下拉刷新 使用加入一下属性并实现代理
@property (nonatomic, weak) id <FNRefreshDelegate> delegate;
// 可设置scrollView头部空白区域高度
@property (nonatomic, assign) CGFloat headerHeight;
// 底部高度
@property (nonatomic, assign) CGFloat bottomHeight;
// 正在刷新，可手动终止
@property (nonatomic, assign, readonly) BOOL isRefreshing;
// 每一页的数量 默认为20 这个影响到判断是否到达页尾
@property (nonatomic, assign) NSUInteger pageSize;
// 是否到达页尾，可手动修改
@property (nonatomic, assign) BOOL maybeHaveMore;
// 下拉刷新的view
@property (nonatomic, strong, readonly) FNRefreshHeader* header;
// 上拉刷新的view 默认hide  调用一次refreshArray:WithArray: 如果新数组不为空 则会显示出来
@property (nonatomic, strong, readonly) FNRefreshFooter* footer;
// 是否永久页尾时异常fotter
@property (nonatomic, assign) BOOL hideLoadingMoreFooter;
// 是否到达页尾时异常fotter
@property (nonatomic, assign) BOOL hideLoadingMoreFooterWhenToEnd;

@end
