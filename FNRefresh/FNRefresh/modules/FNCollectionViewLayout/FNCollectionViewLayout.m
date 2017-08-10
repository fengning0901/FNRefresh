//
//  FNCollectionViewLayout.m
//  FNCollectionViewLayoutDemo
//
//  Created by 冯宁 on 2017/8/10.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "FNCollectionViewLayout.h"

@interface FNCollectionViewLayout () <FNLayoutDelegate>
@property (nonatomic, strong) NSArray* cache;
@property (nonatomic, strong) NSArray* oldCache;
@property (nonatomic, assign) BOOL absoluteItemSize;
@property (nonatomic, assign) BOOL hasColculateInset;
@property (nonatomic, strong) FNLayout* layout;
@end

@implementation FNCollectionViewLayout
#pragma mark - override
- (instancetype)init{
    if (self = [super init]) {
        self.containerSize = CGSizeZero;
        self.layout = [FNLayout new];
        self.layout.delegate = self;
        self.bounces = NO;
    }
    return self;
}

- (NSMutableArray*)calculateAttributes {
    self.layout.containerSize = self.collectionView.bounds.size;
    return [[self.layout calculateAttributes] mutableCopy];
}

-(void)prepareLayout{
    [super prepareLayout];
    self.oldCache = self.cache;
    self.cache = [self calculateAttributes].copy;
}

- (CGFloat)contentWidth {
    return self.layout.contentWidth;
}

- (CGFloat)contentHeight {
    return self.layout.contentHeight;
}

- (UICollectionViewLayoutAttributes*)recalculeteLayoutAttributesForIndexPath:(NSIndexPath*)indexPath{
    NSMutableArray* mArray = [self calculateAttributes];
    for (UICollectionViewLayoutAttributes* attr in mArray) {
        if (attr.representedElementKind == nil && attr.indexPath.row == indexPath.row && attr.indexPath.section == indexPath.section) {
            return attr;
        }
    }
    return nil;
}

- (CGRect)expectRect{
    if (self.containerSize.width != 0 && self.containerSize.height != 0) {
        return CGRectMake(0, 0, self.containerSize.width, self.containerSize.height);
    }else{
        return self.collectionView.bounds;
    }
}

- (CGSize)collectionViewContentSize{
    if (self.lineBreak) {
        if (self.layoutDirection == FNLayoutDirectionVertical) {
            if (self.bounces) {
                return CGSizeMake(self.contentWidth > self.expectRect.size.width ? self.contentWidth : self.expectRect.size.width + 1, self.contentHeight );
            }else{
                return CGSizeMake(self.contentWidth, self.contentHeight);
            }
        }else{
            if (self.bounces) {
                return CGSizeMake(self.contentWidth, self.contentHeight > self.expectRect.size.height ? self.contentHeight : self.expectRect.size.height + 1);
            }else{
                return CGSizeMake(self.contentWidth, self.contentHeight);
            }
        }
    }
    if (self.layoutDirection == FNLayoutDirectionVertical) {
        if (self.bounces) {
            return CGSizeMake(self.expectRect.size.width, self.contentHeight > self.expectRect.size.height ? self.contentHeight : self.expectRect.size.height + 1);
        }
        return CGSizeMake(self.expectRect.size.width, self.contentHeight);
    }else if (self.layoutDirection == FNLayoutDirectionHorizontal){
        if (self.bounces) {
            return CGSizeMake(self.contentWidth > self.expectRect.size.width ? self.contentWidth : self.expectRect.size.width + 1, self.expectRect.size.height);
        }
        CGSize contentSize = CGSizeMake(self.contentWidth, self.expectRect.size.height);
        NSLog(@"%@",NSStringFromCGSize(contentSize));
        return contentSize;
    }
    CGSize contentSize = CGSizeMake(self.contentWidth, self.contentHeight);
    return contentSize;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray* tempArray = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes* attr in self.cache) {
        if (CGRectIntersectsRect(attr.frame, rect)) {
            [tempArray addObject:attr];
        }
    }
    return tempArray.copy;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    for (UICollectionViewLayoutAttributes* attr in self.cache) {
        if (attr.representedElementKind == nil && attr.indexPath.row == indexPath.row && attr.indexPath.section == indexPath.section) {
            return attr;
        }
    }
    return nil;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    for (UICollectionViewLayoutAttributes* attr in self.cache) {
        if ([attr.representedElementKind isEqualToString:elementKind] && attr.indexPath.row == indexPath.row && attr.indexPath.section == indexPath.section) {
            return attr;
        }
    }
    return nil;
}

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems{
    [super prepareForCollectionViewUpdates:updateItems];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    UICollectionViewLayoutAttributes* attr = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath].copy;
    attr.frame = ((UICollectionViewLayoutAttributes*)[self collectionViewLayoutAttributesForIndexPath:itemIndexPath onOld:NO]).frame;
    attr.alpha = 1;
    return attr;
}
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    UICollectionViewLayoutAttributes* attr = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath].copy;
    attr.alpha = 1;
    return attr;
}

- (UICollectionViewLayoutAttributes*)collectionViewLayoutAttributesForIndexPath:(NSIndexPath*)indexPath onOld:(BOOL)onOld{
    if (onOld) {
        for (UICollectionViewLayoutAttributes* attr in self.oldCache) {
            if (attr.indexPath.item == indexPath.item) {
                if (attr.indexPath.section == indexPath.section) {
                    return attr;
                }
            }
        }
    }else{
        for (UICollectionViewLayoutAttributes* attr in self.cache) {
            if (attr.indexPath.item == indexPath.item) {
                if (attr.indexPath.section == indexPath.section) {
                    return attr;
                }
            }
        }
    }
    return nil;
}

#pragma mark - layout setter
- (void)setItemSpace:(CGFloat)itemSpace {
    _itemSpace = itemSpace;
    self.layout.itemSpace = itemSpace;
}
- (void)setLineSpacing:(CGFloat)LineSpacing {
    _LineSpacing = LineSpacing;
    self.layout.LineSpacing = LineSpacing;
}
- (void)setSectionSpacing:(CGFloat)sectionSpacing {
    _sectionSpacing = sectionSpacing;
    self.layout.sectionSpacing = sectionSpacing;
}
- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    _sectionInset = sectionInset;
    self.layout.sectionInset = sectionInset;
}
- (void)setLineBreak:(BOOL)lineBreak {
    _lineBreak = lineBreak;
    self.layout.lineBreak = lineBreak;
}
- (void)setAlignCenter:(BOOL)alignCenter {
    _alignCenter = alignCenter;
    self.layout.alignCenter = alignCenter;
}
- (void)setLayoutDirection:(FNLayoutDirection)layoutDirection {
    _layoutDirection = layoutDirection;
    self.layout.layoutDirection = layoutDirection;
}
- (void)setVerticleAlignCenter:(BOOL)verticleAlignCenter {
    _verticleAlignCenter = verticleAlignCenter;
    self.layout.verticleAlignCenter = verticleAlignCenter;
}
- (void)setAbsoluteSize:(BOOL)absoluteSize {
    _absoluteSize = absoluteSize;
    self.layout.absoluteSize = absoluteSize;
}

#pragma mark - layout delegate

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(layoutNumberOfSection:)) {
        if ([self.delegate respondsToSelector:@selector(layoutNumberOfSection:)]) {
            return YES;
        } else {
            return self.collectionView ? YES : NO;
        }
    }
    if (aSelector == @selector(layout:numberOfItemsForSection:)) {
        if ([self.delegate respondsToSelector:@selector(layout:numberOfItemsForSection:)]) {
            return YES;
        } else {
            return self.collectionView ? YES : NO;
        }
    }
    if (aSelector == @selector(layout:sizeForCellAtIndexPath:)) {
        if ([self.delegate respondsToSelector:@selector(layout:sizeForCellAtIndexPath:)]) {
            return YES;
        } else {
            return NO;
        }
    }
    if (aSelector == @selector(layout:absoluteSideForSection:)) {
        if ([self.delegate respondsToSelector:@selector(layout:absoluteSideForSection:)]) {
            return YES;
        } else {
            return NO;
        }
    }
    if (aSelector == @selector(layout:firstLinendentation:)) {
        if ([self.delegate respondsToSelector:@selector(layout:firstLinendentation:)]) {
            return YES;
        } else {
            return NO;
        }
    }
    if (aSelector == @selector(layout:sizeForHeaderForSection:)) {
        if ([self.delegate respondsToSelector:@selector(layout:sizeForHeaderForSection:)]) {
            return YES;
        } else {
            return NO;
        }
    }
    if (aSelector == @selector(layout:sizeForFooterForSection:)) {
        if ([self.delegate respondsToSelector:@selector(layout:sizeForFooterForSection:)]) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return [super respondsToSelector:aSelector];
}

- (NSInteger)layoutNumberOfSection:(FNLayout*)layout {
    if ([self.delegate respondsToSelector:@selector(layoutNumberOfSection:)]) {
        return [self.delegate layoutNumberOfSection:self];
    } else {
        return [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    }
}

- (NSInteger)layout:(FNLayout*)layout numberOfItemsForSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(layout:numberOfItemsForSection:)]) {
        return [self.delegate layout:self numberOfItemsForSection:section];
    } else {
        return [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
    }
}

- (CGSize)layout:(FNLayout*)layout sizeForCellAtIndexPath:(NSIndexPath*)indexPath {
    if ([self.delegate respondsToSelector:@selector(layout:sizeForCellAtIndexPath:)]) {
        return [self.delegate layout:self sizeForCellAtIndexPath:indexPath];
    }
    return CGSizeMake(-1, -1);
}

- (CGFloat)layout:(FNLayout*)layout absoluteSideForSection:(NSUInteger)section {
    if ([self.delegate respondsToSelector:@selector(layout:absoluteSideForSection:)]) {
        return [self.delegate layout:self absoluteSideForSection:section];
    }
    return -1;
}

- (CGFloat)layout:(FNLayout*)layout firstLinendentation:(NSUInteger)section {
    if ([self.delegate respondsToSelector:@selector(layout:firstLinendentation:)]) {
        return [self.delegate layout:self firstLinendentation:section];
    }
    return -1;
}

- (CGSize)layout:(FNLayout*)layout sizeForHeaderForSection:(NSUInteger)section {
    if ([self.delegate respondsToSelector:@selector(layout:sizeForHeaderForSection:)]) {
        return [self.delegate layout:self sizeForHeaderForSection:section];
    }
    return CGSizeMake(-1, -1);
}

- (CGSize)layout:(FNLayout*)layout sizeForFooterForSection:(NSUInteger)section {
    if ([self.delegate respondsToSelector:@selector(layout:sizeForFooterForSection:)]) {
        return [self.delegate layout:self sizeForFooterForSection:section];
    }
    return CGSizeMake(-1, -1);
}

@end
