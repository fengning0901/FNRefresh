//
//  DemoModel.m
//  FN_Demo
//
//  Created by 冯宁 on 2017/8/8.
//  Copyright © 2017年 test. All rights reserved.
//

#import "DemoModel.h"

@implementation DemoModel

+ (void)loadDataWithPage:(NSNumber*)page withCallBack:(void (^)(NSArray<DemoModel*>* modelArray))callBack {
    if (!callBack) {
        return;
    }
    if (page.integerValue < 5) {
        NSMutableArray* mArray = [NSMutableArray array];
        for (int i = 0; i < 20; i++) {
            DemoModel* model = [DemoModel new];
            model.index = @((page.integerValue - 1) * 20 + i);
            model.title = @"测试商品标题";
            model.banner = [self imageWithColor:([UIColor colorWithRed:(arc4random() % 255 / 255.0) green:(arc4random() % 255 / 255.0) blue:(arc4random() % 255 / 255.0) alpha:1.0]) size:CGSizeMake(1, 1)];
            model.price = @(arc4random() % 100);
            model.ori_price = @(model.price.integerValue * 0.8);
            model.randomNumber = @(arc4random());
            [mArray addObject:model];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callBack(mArray.copy);
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callBack([NSArray array]);
        });
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
