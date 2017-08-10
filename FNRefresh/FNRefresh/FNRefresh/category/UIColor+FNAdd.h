//
//  UIColor+FNAdd.h
//  FNRefresh
//
//  Created by 冯宁 on 2017/8/10.
//  Copyright © 2017年 demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (FNAdd)
+ (UIColor*)colorWithHexValue:(NSString*)hex;
- (UIColor*)blackOrWhiteContrastingColor;
- (CGFloat)luminosity;
- (CGFloat)luminosityDifference:(UIColor*)otherColor;
@end
