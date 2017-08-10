//
//  DemoOneViewController.m
//  FNCollectionViewLayoutDemo
//
//  Created by 冯宁 on 2017/8/10.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "DemoOneViewController.h"
#import "FNCollectionViewLayout.h"
#import "DemoCollectionViewCell.h"
#import "DemoModel.h"
#import "FNRefresh.h"

@interface DemoOneViewController () <FNCollectionViewLayoutDelegate, UICollectionViewDataSource, FNRefreshDelegate>

@property (nonatomic, strong) UICollectionView* collection;
@property (nonatomic, strong) FNCollectionViewLayout* layout;
@property (nonatomic, strong) FNRefresh* refresh;
@property (nonatomic, strong) NSArray<DemoModel*>* modelArray;
@property (nonatomic, strong) NSNumber* nowPage;

@end

#define kCellDemo @"kCellDemo"

@implementation DemoOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.nowPage = @(0);
    self.title = @"RefreshDemo";
    [self setupSubviews];
    [self.refresh pretendStartRefresh];
    [self loadData];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setupSubviews {
    self.layout = [FNCollectionViewLayout new];
    self.layout.layoutDirection = FNLayoutDirectionVertical;
    self.layout.itemSpace = 12;
    self.layout.LineSpacing = 12;
    self.layout.sectionSpacing = 12;
    self.layout.absoluteSize = YES;
    self.layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
    self.layout.delegate = self;
    
    self.collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64) collectionViewLayout:self.layout];
    [self.collection registerClass:[DemoCollectionViewCell class] forCellWithReuseIdentifier:kCellDemo];
    self.collection.dataSource = self;
    self.collection.backgroundView = [UIView new];
    self.collection.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collection];
    
    self.refresh = [[FNRefresh alloc] initWithScrollView:self.collection];
    self.refresh.delegate = self;
}

#pragma mark - refresh delegate
- (BOOL)shouldBeginRefreshWithRefreshView:(FNRefreshHeader *)refreshView withEventType:(FNRefreshEventType)type {
    if (type == FNRefreshEventTypeUpDrag) {
        [self loadData];
        return YES;
    } else {
        self.nowPage = @(0);
        [self loadData];
        return YES;
    }
}

#pragma mark - other delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger n = self.modelArray.count % 2;
    NSInteger i = self.modelArray.count / 3 + ((n - section) > 0 ? 1 : 0);
    return i;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DemoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellDemo forIndexPath:indexPath];
    
    cell.model = self.modelArray[indexPath.item * 3 + indexPath.section];
    
    return cell;
}

- (CGSize)layout:(FNCollectionViewLayout *)layout sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(floor(([UIScreen mainScreen].bounds.size.width - (12 * 4)) / 3) , 100 + self.modelArray[indexPath.item * 3 + indexPath.section].randomNumber.integerValue % 100);
}

- (CGFloat)layout:(FNCollectionViewLayout *)layout absoluteSideForSection:(NSUInteger)section{
    return ([UIScreen mainScreen].bounds.size.width - 48) / 3;
}

#pragma mark - data
- (void)loadData {
    __weak typeof(self) weakSelf = self;
    NSNumber* page = @(self.nowPage.integerValue + 1);
    [DemoModel loadDataWithPage:page withCallBack:^(NSArray<DemoModel *> *modelArray) {
        [weakSelf.refresh concatOldArray:weakSelf.modelArray newArray:modelArray withoutSortWithCompareBlock:^NSComparisonResult(DemoModel* model1, DemoModel* model2) {
            return [model1.index compare:model2.index];
        } isUpDragRefresh:page.integerValue != 1 concatResultBlock:^(NSArray *resultArray) {
            weakSelf.modelArray = resultArray;
            weakSelf.nowPage = page;
        } complete:nil];
    }];
}

- (void)dealloc {
    if (_refresh) {
        [_refresh viewDealloc];
    }
}

@end
