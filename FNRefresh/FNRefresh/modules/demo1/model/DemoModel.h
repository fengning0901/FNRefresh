//
//  DemoModel.h
//  FN_Demo
//
//  Created by 冯宁 on 2017/8/8.
//  Copyright © 2017年 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoModel : NSObject

@property (nonatomic, strong) NSNumber* index;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) UIImage* banner;
@property (nonatomic, strong) NSNumber* price;
@property (nonatomic, strong) NSNumber* ori_price;
@property (nonatomic, strong) NSNumber* randomNumber;

+ (void)loadDataWithPage:(NSNumber*)page withCallBack:(void (^)(NSArray<DemoModel*>* modelArray))callBack;
@end
