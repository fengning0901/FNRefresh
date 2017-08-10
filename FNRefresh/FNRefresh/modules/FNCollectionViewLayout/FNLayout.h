//
//  FNLayout.h
//  FNCollectionViewLayoutDemo
//
//  Created by 冯宁 on 2017/8/10.
//  Copyright © 2017年 demo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FNLayoutDirection) {
    FNLayoutDirectionVertical,
    FNLayoutDirectionHorizontal
};

@class FNLayout;
@protocol FNLayoutDelegate <NSObject>
@required
// 组数
- (NSInteger)layoutNumberOfSection:(FNLayout*)layout;
// 组内元素数
- (NSInteger)layout:(FNLayout*)layout numberOfItemsForSection:(NSInteger)section;
// 元素尺寸
- (CGSize)layout:(FNLayout*)layout sizeForCellAtIndexPath:(NSIndexPath*)indexPath;

@optional
// 固定布局方向相反方向的侧边长度
- (CGFloat)layout:(FNLayout*)layout absoluteSideForSection:(NSUInteger)section;
// 首行缩进
- (CGFloat)layout:(FNLayout*)layout firstLinendentation:(NSUInteger)section;
// header高度
- (CGSize)layout:(FNLayout*)layout sizeForHeaderForSection:(NSUInteger)section;
// footer高度
- (CGSize)layout:(FNLayout*)layout sizeForFooterForSection:(NSUInteger)section;
@end

@interface FNLayout : NSObject

@property (nonatomic, weak) id <FNLayoutDelegate> delegate;
// 容器大小 默认0 required
@property (nonatomic, assign) CGSize containerSize;
// item距离 默认0
@property (nonatomic, assign) CGFloat itemSpace;
// 行距 默认0
@property (nonatomic, assign) CGFloat LineSpacing;
// 组距 默认0
@property (nonatomic, assign) CGFloat sectionSpacing;
// 在自动计算section宽高的时候这是一个固定值，在实现了- (CGFloat)layout:(XER_NoReuseLayout*)layout absoluteSideForSection:(NSUInteger)section;方法固定了每个section的一边长度时，这是一个比例inset，会将剩余空间按照inset的比例进行分配。
@property (nonatomic, assign) UIEdgeInsets sectionInset;

// 自动换行 默认NO
@property (nonatomic, assign) BOOL lineBreak;
// 在换行开启的情况下开启这个属性 可以使所有的item按照排列方向居中
@property (nonatomic, assign) BOOL alignCenter;
// 排列方向 默认FNLayoutDirecionVertical
@property (nonatomic, assign) FNLayoutDirection layoutDirection;
// 换行为YES时此属性有效，值为YES时item按照布局方向相反方向居中
@property (nonatomic, assign) BOOL verticleAlignCenter;
// 绝对尺寸，使用绝对尺寸，而不是根据滑动方向自动计算item排列方向一边的值，在值为NO的情况下item与布局方向相反的边的长度会根据容器宽度与组数平均分配，然后按照代理中给定的itemSize按照长宽比例重新计算，而值为YES时会认为item不想要平分容器宽度，而是给自计算 default NO
@property (nonatomic, assign) BOOL absoluteSize;

@property (nonatomic, assign, readonly) CGFloat contentWidth;
@property (nonatomic, assign, readonly) CGFloat contentHeight;

// 计算每一个item的位置
- (NSMutableArray<UICollectionViewLayoutAttributes*>*)calculateAttributes;

@end
