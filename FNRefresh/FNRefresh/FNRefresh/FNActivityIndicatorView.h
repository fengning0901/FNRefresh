//
//  XER_ActivityIndicatorView.h
//  XER
//
//  Created by 冯宁 on 12/26/15.
//  Copyright © 2015 xfenzi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XER_ActivityIndicatorViewType) {
    XER_ActivityIndicatorViewTypeScaleAnimate = 0,
    XER_ActivityIndicatorViewTypeRotateAnimate   = 1
};

@interface FNActivityIndicatorView : UIView
// 两种预设动画方式，弧形旋转（1），原点缩放（0）
@property (nonatomic, assign) XER_ActivityIndicatorViewType animateType;
// 图形填充色
@property (nonatomic, strong) UIColor* color;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
@end
