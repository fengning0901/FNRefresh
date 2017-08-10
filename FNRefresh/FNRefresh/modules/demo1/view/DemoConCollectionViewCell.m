//
//  DemoConCollectionViewCell.m
//  FNCollectionViewLayoutDemo
//
//  Created by 冯宁 on 2017/8/10.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "DemoConCollectionViewCell.h"
#import "DemoCollectionViewCell.h"
#import "FNCollectionViewLayout.h"
#import "DemoModel.h"

@interface DemoConCollectionViewCell () <FNCollectionViewLayoutDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView* collection;
@property (nonatomic, strong) FNCollectionViewLayout* layout;
@property (nonatomic, strong) NSArray<DemoModel*>* modelArray;
@end

#define kCellDemo @"kCellDemo"

@implementation DemoConCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 1;
        [self setupSubviews];
        [self loadData];
    }
    return self;
}

- (void)setupSubviews {
    self.layout = [FNCollectionViewLayout new];
    self.layout.layoutDirection = FNLayoutDirectionHorizontal;
    self.layout.itemSpace = 12;
    self.layout.sectionInset = UIEdgeInsetsMake(12,12,12,12);
    self.layout.delegate = self;
    
    self.collection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
    [self.collection registerClass:[DemoCollectionViewCell class] forCellWithReuseIdentifier:kCellDemo];
    self.collection.dataSource = self;
    self.collection.backgroundView = [UIView new];
    self.collection.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.collection];
    
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DemoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellDemo forIndexPath:indexPath];
    cell.model = self.modelArray[indexPath.item];
    return cell;
}

- (CGSize)layout:(FNCollectionViewLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bounds.size.width / 3, self.bounds.size.height - 24);
}

#pragma mark - data
- (void)loadData {
    __weak typeof(self) weakSelf = self;
    [DemoModel loadDataWithPage:@(1) withCallBack:^(NSArray<DemoModel *> *modelArray) {
        weakSelf.modelArray = modelArray;
        [weakSelf.collection reloadData];
    }];
}


@end
