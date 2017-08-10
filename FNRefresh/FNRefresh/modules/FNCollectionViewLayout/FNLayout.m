//
//  FNLayout.m
//  FNCollectionViewLayoutDemo
//
//  Created by 冯宁 on 2017/8/10.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "FNLayout.h"

@interface FNLayout ()
@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;
@end

@implementation FNLayout

- (instancetype)init {
    if (self = [super init]) {
        _containerSize = CGSizeZero;
        _itemSpace = 0;
        _LineSpacing = 0;
        _sectionSpacing = 0;
        _sectionInset = UIEdgeInsetsZero;
        _lineBreak = NO;
        _layoutDirection = FNLayoutDirectionVertical;
        _alignCenter = NO;
        _absoluteSize = NO;
        _verticleAlignCenter = NO;
    }
    return self;
}

- (NSMutableArray*)calculateAttributes {
    
    self.contentWidth = 0;
    self.contentHeight = 0;
    self.xOffset = 0;
    self.yOffset = 0;
    
    NSMutableArray<UICollectionViewLayoutAttributes*>* tempArray = [NSMutableArray array];
    NSInteger sectionNum = 0;
    if ([self.delegate respondsToSelector:@selector(layoutNumberOfSection:)]) {
        sectionNum = [self.delegate layoutNumberOfSection:self];
    }
    if (sectionNum == 0) {
        return nil;
    }
    CGFloat itemHeight = 1;
    CGFloat itemWidth = 1;
    if ([self.delegate respondsToSelector:@selector(layout:absoluteSideForSection:)]) {
        if (self.lineBreak) {
            // 让sectionInset  保持原样
        }else{
            CGFloat allItemLength = 0;
            for (int i = 0; i < sectionNum; i++) {
                allItemLength += [self.delegate layout:self absoluteSideForSection:i];
            }
            if (self.layoutDirection == FNLayoutDirectionVertical) {
                CGFloat leftRight;
                leftRight = (self.containerSize.width - allItemLength - (self.LineSpacing * (sectionNum - 1)));
                CGFloat leftRate = (self.sectionInset.left ? self.sectionInset.left : 1) /( (self.sectionInset.left == 0 && self.sectionInset.right == 0) ?  (2) : (self.sectionInset.left + self.sectionInset.right ));
                CGFloat rightRate = 1.0 - leftRate;
                if (leftRate == 0 && rightRate == 0) {
                    leftRate = 0.5;
                    rightRate = 0.5;
                }
                self.sectionInset = UIEdgeInsetsMake(self.sectionInset.top, leftRight * leftRate, self.sectionInset.bottom, leftRight * rightRate);
            }else{
                CGFloat topBottom;
                topBottom = (self.containerSize.height - allItemLength - (self.LineSpacing * (sectionNum - 1)));
                CGFloat topRate =  (self.sectionInset.top ? self.sectionInset.top : 1) / ( (self.sectionInset.top == 0 && self.sectionInset.bottom == 0) ?  (2) : (self.sectionInset.top + self.sectionInset.bottom ));
                CGFloat bottomRate = 1.0 - topRate;
                if (topRate == 0 && bottomRate == 1) {
                    topRate = 0.5;
                    bottomRate = 0.5;
                }
                self.sectionInset = UIEdgeInsetsMake(topBottom * topRate, self.sectionInset.left, topBottom * bottomRate, self.sectionInset.right);
            }
        }
    }else{
        if (self.layoutDirection == FNLayoutDirectionVertical) {
            itemWidth = (self.containerSize.width - self.sectionInset.left - self.sectionInset.right - self.LineSpacing * (sectionNum - 1)) / sectionNum;
        }else{
            itemHeight = (self.containerSize.height - self.sectionInset.top - self.sectionInset.bottom - self.LineSpacing * (sectionNum - 1)) / sectionNum;
        }
    }
    if (self.layoutDirection == FNLayoutDirectionVertical) {
        self.xOffset = self.sectionInset.right;
    }else{
        self.yOffset = self.sectionInset.top;
    }
    for (NSInteger i = 0; i < sectionNum; i++) {
        if ([self.delegate respondsToSelector:@selector(layout:absoluteSideForSection:)]){
            if (self.layoutDirection == FNLayoutDirectionVertical) {
                itemWidth = [self.delegate layout:self absoluteSideForSection:i];;
            }else{
                itemHeight = [self.delegate layout:self absoluteSideForSection:i];;
            }
        }
        NSInteger rowNum = 0;
        if ([self.delegate respondsToSelector:@selector(layout:numberOfItemsForSection:)]) {
            rowNum = [self.delegate layout:self numberOfItemsForSection:i];
        }
        if (self.layoutDirection == FNLayoutDirectionVertical) {
            self.yOffset = self.sectionInset.top;
        }else{
            self.xOffset = self.sectionInset.left;
        }
        if ([self.delegate respondsToSelector:@selector(layout:sizeForHeaderForSection:)]) {
            CGSize headerSize = [self.delegate layout:self sizeForHeaderForSection:i];
            if (headerSize.width != 0 && headerSize.height != 0) {
                UICollectionViewLayoutAttributes* attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                if (self.layoutDirection == FNLayoutDirectionVertical) {
                    itemHeight = itemWidth * (headerSize.height / headerSize.width);
                }else{
                    itemWidth = itemHeight * (headerSize.width / headerSize.height);
                }
                attrs.frame = CGRectMake(self.xOffset, self.yOffset, itemWidth, itemHeight);
                if (self.layoutDirection == FNLayoutDirectionVertical) {
                    self.yOffset += self.itemSpace + itemHeight;
                }else{
                    self.xOffset += self.itemSpace + itemWidth;
                }
                [tempArray addObject:attrs];
            }
        }
        for (NSInteger r = 0; r < rowNum; r ++) {
            UICollectionViewLayoutAttributes* attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:r inSection:i]];
            if (r == 0) {
                if ([self.delegate respondsToSelector:@selector(layout:firstLinendentation:)]) {
                    if (self.layoutDirection == FNLayoutDirectionVertical) {
                        self.yOffset += [self.delegate layout:self firstLinendentation:i];
                    }else{
                        self.xOffset += [self.delegate layout:self firstLinendentation:i];
                    }
                }
            }
            CGFloat x = self.xOffset;
            CGFloat y = self.yOffset;
            
            CGSize size = [self.delegate layout:self sizeForCellAtIndexPath:[NSIndexPath indexPathForItem:r inSection:i]];
            if (size.width == 0 || size.height == 0) {
                if (self.layoutDirection == FNLayoutDirectionVertical) {
                    size = CGSizeMake(itemWidth, itemWidth);
                }else{
                    size = CGSizeMake(itemHeight, itemHeight);
                }
            }
            if (!self.absoluteSize) {
                if (self.layoutDirection == FNLayoutDirectionVertical) {
                    itemHeight = itemWidth * (size.height / size.width);
                }else{
                    itemWidth = itemHeight * (size.width / size.height);
                }
            }else{
                itemHeight = size.height;
                itemWidth = size.width;
            }
            
            attrs.frame = CGRectMake(x, y, itemWidth, itemHeight);
            if (self.lineBreak) {
                if (self.layoutDirection == FNLayoutDirectionVertical) {
                    if (y + itemHeight + self.sectionInset.right > self.containerSize.height) {
                        self.yOffset = self.sectionInset.top;
                        y = self.yOffset;
                        CGFloat maxX = 0;
                        for (UICollectionViewLayoutAttributes* attr in tempArray) {
                            if (maxX < CGRectGetMaxX(attr.frame)) {
                                maxX = CGRectGetMaxX(attr.frame);
                            }
                        }
                        self.xOffset = maxX + self.LineSpacing;
                        x = self.xOffset;
                        attrs.frame = CGRectMake(x, y, itemWidth, itemHeight);
                    }
                }else{
                    if (x + itemWidth + self.sectionInset.right > self.containerSize.width) {
                        self.xOffset = self.sectionInset.left;
                        x = self.xOffset;
                        CGFloat maxY = 0;
                        for (UICollectionViewLayoutAttributes* attr in tempArray) {
                            if (maxY < CGRectGetMaxY(attr.frame)) {
                                maxY = CGRectGetMaxY(attr.frame);
                            }
                        }
                        self.yOffset = maxY + self.LineSpacing;
                        y = self.yOffset;
                        attrs.frame = CGRectMake(x, y, itemWidth, itemHeight);
                    }
                }
            }
            
            if (self.layoutDirection == FNLayoutDirectionVertical) {
                self.yOffset += self.itemSpace + itemHeight;
            }else{
                self.xOffset += self.itemSpace + itemWidth;
            }
            [tempArray addObject:attrs];
        }
        
        if ([self.delegate respondsToSelector:@selector(layout:sizeForFooterForSection:)]) {
            CGSize footerSize = [self.delegate layout:self sizeForFooterForSection:i];
            if (footerSize.width != 0 && footerSize.height != 0) {
                UICollectionViewLayoutAttributes* attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                if (self.layoutDirection == FNLayoutDirectionVertical) {
                    itemHeight = itemWidth * (footerSize.height / footerSize.width);
                }else{
                    itemWidth = itemHeight * (footerSize.width / footerSize.height);
                }
                attrs.frame = CGRectMake(self.xOffset, self.yOffset, itemWidth, itemHeight);
                if (self.layoutDirection == FNLayoutDirectionVertical) {
                    self.yOffset += self.itemSpace + itemHeight;
                }else{
                    self.xOffset += self.itemSpace + itemWidth;
                }
                [tempArray addObject:attrs];
            }
        }
        if (self.lineBreak) {
            if (self.layoutDirection == FNLayoutDirectionVertical) {
                self.contentHeight = self.containerSize.height;
                self.xOffset += itemWidth + self.sectionSpacing;
            }else{
                self.contentWidth = self.containerSize.width;
                self.yOffset += itemHeight + self.sectionSpacing;
            }
        }else{
            if (self.layoutDirection == FNLayoutDirectionVertical) {
                self.contentHeight = self.contentHeight > (self.yOffset - self.itemSpace + self.sectionInset.bottom) ? self.contentHeight : self.yOffset - self.itemSpace + self.sectionInset.bottom;
                self.xOffset += itemWidth + self.sectionSpacing;
            }else{
                self.contentWidth = self.contentWidth > self.xOffset - self.itemSpace + self.sectionInset.right ? self.contentWidth : self.xOffset - self.itemSpace + self.sectionInset.right;
                self.yOffset += itemHeight + self.sectionSpacing;
            }
        }
    }
    if (self.layoutDirection == FNLayoutDirectionVertical) {
        self.contentWidth = self.xOffset + self.sectionInset.right - self.sectionSpacing;
    }else{
        self.contentHeight = self.yOffset + self.sectionInset.bottom - self.sectionSpacing;
    }
    if (self.alignCenter && (self.lineBreak || (self.layoutDirection == FNLayoutDirectionVertical ? self.contentHeight < self.containerSize.height : self.contentWidth < self.containerSize.width)) && tempArray.count) {
        if (self.layoutDirection == FNLayoutDirectionVertical) {
            NSUInteger nowIndex = 0;
            while (1) {
                NSMutableArray<UICollectionViewLayoutAttributes*>* mCenterArray = [NSMutableArray array];
                CGFloat nowX = tempArray[nowIndex].frame.origin.x;
                while (1) {
                    if (tempArray[nowIndex].frame.origin.x == nowX) {
                        [mCenterArray addObject:tempArray[nowIndex]];
                    }else{
                        break;
                    }
                    if (nowIndex == tempArray.count - 1) {
                        break;
                    }
                    nowIndex++;
                }
                CGFloat startY= mCenterArray[0].frame.origin.y;
                CGFloat endY = mCenterArray[mCenterArray.count - 1].frame.origin.y + mCenterArray[mCenterArray.count - 1].frame.size.height;
                CGFloat offset = (self.containerSize.height - (endY-startY) - self.sectionInset.bottom - self.sectionInset.top)/2;
                for (UICollectionViewLayoutAttributes* attr in mCenterArray) {
                    attr.frame = CGRectMake(attr.frame.origin.x, attr.frame.origin.y + offset, attr.frame.size.width, attr.frame.size.height);
                }
                if (nowIndex == tempArray.count - 1) {
                    break;
                }
            }
        }else{
            NSUInteger nowIndex = 0;
            while (1) {
                NSMutableArray<UICollectionViewLayoutAttributes*>* mCenterArray = [NSMutableArray array];
                CGFloat nowY = tempArray[nowIndex].frame.origin.y;
                while (1) {
                    if (nowIndex == tempArray.count) {
                        break;
                    }
                    if (tempArray[nowIndex].frame.origin.y == nowY) {
                        [mCenterArray addObject:tempArray[nowIndex]];
                    }else{
                        break;
                    }
                    nowIndex++;
                }
                CGFloat startX= mCenterArray[0].frame.origin.x;
                CGFloat endX = mCenterArray[mCenterArray.count - 1].frame.origin.x + mCenterArray[mCenterArray.count - 1].frame.size.width;
                CGFloat offset = (self.containerSize.width - (endX-startX) - self.sectionInset.left - self.sectionInset.right)/2;
                for (UICollectionViewLayoutAttributes* attr in mCenterArray) {
                    attr.frame = CGRectMake(attr.frame.origin.x + offset, attr.frame.origin.y, attr.frame.size.width, attr.frame.size.height);
                }
                if (nowIndex == tempArray.count) {
                    break;
                }
            }
        }
    }
    if (self.verticleAlignCenter && self.lineBreak) {
        if (self.layoutDirection == FNLayoutDirectionVertical) {
            if (self.contentWidth < self.containerSize.width) {
                UICollectionViewLayoutAttributes* minAttr = tempArray.firstObject;
                UICollectionViewLayoutAttributes* maxAttr = tempArray.lastObject;
                for (UICollectionViewLayoutAttributes* attr in tempArray) {
                    if (CGRectGetMaxX(attr.frame) > CGRectGetMaxX(maxAttr.frame)) {
                        maxAttr = attr;
                    }
                    if (CGRectGetMinX(attr.frame) < CGRectGetMinX(minAttr.frame)) {
                        minAttr = attr;
                    }
                }
                CGFloat offset = (self.containerSize.width - (CGRectGetMaxX(maxAttr.frame) - CGRectGetMinX(minAttr.frame))) / 2 - CGRectGetMinX(minAttr.frame);
                for (UICollectionViewLayoutAttributes* attr in tempArray) {
                    attr.frame = CGRectMake(attr.frame.origin.x + offset, attr.frame.origin.y, attr.frame.size.width, attr.frame.size.height);
                }
            }
        }else{
            if (self.contentHeight < self.containerSize.height) {
                UICollectionViewLayoutAttributes* minAttr = tempArray.firstObject;
                UICollectionViewLayoutAttributes* maxAttr = tempArray.lastObject;
                for (UICollectionViewLayoutAttributes* attr in tempArray) {
                    if (CGRectGetMaxY(attr.frame) > CGRectGetMaxY(maxAttr.frame)) {
                        maxAttr = attr;
                    }
                    if (CGRectGetMinY(attr.frame) < CGRectGetMinY(minAttr.frame)) {
                        minAttr = attr;
                    }
                }
                CGFloat offset = (self.containerSize.height - (CGRectGetMaxY(maxAttr.frame) - CGRectGetMinY(minAttr.frame))) / 2 - CGRectGetMinY(minAttr.frame);
                for (UICollectionViewLayoutAttributes* attr in tempArray) {
                    attr.frame = CGRectMake(attr.frame.origin.x, attr.frame.origin.y + offset, attr.frame.size.width, attr.frame.size.height);
                }
            }
        }
    }
    
    return tempArray;
}


@end
