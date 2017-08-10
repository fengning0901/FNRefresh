//
//  DemoCollectionViewCell.m
//  FNCollectionViewLayoutDemo
//
//  Created by 冯宁 on 2017/8/10.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "DemoCollectionViewCell.h"


@implementation DemoCollectionViewCell {
    UIImageView* _imageView;
    UILabel* _label;
}

- (void)layoutSubviews {
    _imageView.frame = self.bounds;
}

- (void)setModel:(DemoModel *)model {
    if ([_model isEqual:model]) {
        return;
    }
    _model = model;
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        [self addSubview:_imageView];
    }
    _imageView.image = _model.banner;
    if (!_label) {
        _label = [UILabel new];
        _label.font = [UIFont systemFontOfSize:12];
        _label.frame = CGRectMake(5, 5, 40, 40);
        _label.textColor = [UIColor blackColor];
        [self addSubview:_label];
    }
    _label.text = [NSString stringWithFormat:@"%ld",_model.index.integerValue];
}

@end
