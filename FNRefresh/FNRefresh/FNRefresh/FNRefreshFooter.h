//
//  XER_isLoadingMoreFooter.h
//  XER
//
//  Created by 冯宁 on 12/10/15.
//  Copyright © 2015 xfenzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNRefreshFooter : UIView

// 在到达页面底部的时候，是否隐藏footer
@property (nonatomic, assign) BOOL hideLoadingMoreFooterWhenToEnd;

// 手动设置到达底部
- (void)setIsNoMoreToLoad:(BOOL)isNoMoreToLoad;
// footer开始loading
- (void)startLoading;
// footer结束loading
- (void)endLoading;

@end
