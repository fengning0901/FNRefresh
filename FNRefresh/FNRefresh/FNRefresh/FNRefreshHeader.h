//
//  XER_PullDownRefresh.h
//  XER_PullDownRefresh
//
//  Created by 冯宁 on 1/4/16.
//  Copyright © 2016 xfenzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FNRefreshHeaderDelegate <NSObject>

- (BOOL)shouldBeginRefresh;

@end

@interface FNRefreshHeader : UIControl

@property (nonatomic, assign) BOOL isDowning;
@property (nonatomic, weak) id <FNRefreshHeaderDelegate> delegate;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign, readonly) BOOL refreshing;

- (void)startRefresh;
- (void)endRefresh;
- (void)updateAnimationWithOffset:(CGFloat)offset;

@end
