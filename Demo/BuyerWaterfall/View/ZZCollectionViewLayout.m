//
//  ZZCollectionViewLayout.m
//  GHS
//
//  Created by zhouzheng on 16/12/4.
//  Copyright © 2016年 zhouzheng. All rights reserved.
//

#import "ZZCollectionViewLayout.h"

NSString * const ZZCollectionElementKindSectionHeader = @"ZZCollectionElementKindSectionHeader";
NSString * const ZZCollectionElementKindSectionFooter = @"ZZCollectionElementKindSectionFooter";

@interface ZZCollectionViewLayout()
{
    CGSize _itemSize;
}

//方向为纵向时
@property (nonatomic, strong) NSMutableArray *columnHeights;//存储每列的高度
@property (nonatomic, assign) CGFloat itemWidth;
//方向为横向时
@property (nonatomic, strong) NSMutableArray *rowWidths;//存储每行的宽度
@property (nonatomic, assign) CGFloat itemHeight;

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *allItemAttributes;
@property (nonatomic, assign) UIEdgeInsets contentInset;

@end

@implementation ZZCollectionViewLayout

#pragma mark - 属性set方法
- (void)setScrollDirection:(ZZCollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    [self invalidateLayout];
}

- (void)setColumnCount:(NSInteger)columnCount {
    _columnCount = columnCount;
    [self invalidateLayout];
}

- (void)setRowCount:(NSInteger)rowCount {
    _rowCount = rowCount;
    [self invalidateLayout];
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing {
    _minimumLineSpacing = minimumLineSpacing;
    [self invalidateLayout];
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    _minimumInteritemSpacing = minimumInteritemSpacing;
    [self invalidateLayout];
}

- (void)setSectionInsets:(UIEdgeInsets)sectionInsets {
    _sectionInsets = sectionInsets;
    [self invalidateLayout];
}

#pragma mark - 懒加载
- (NSMutableArray *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray arrayWithCapacity:self.columnCount];
    }
    return _columnHeights;
}

- (NSMutableArray *)rowWidths {
    if (!_rowWidths) {
        _rowWidths = [NSMutableArray arrayWithCapacity:self.rowCount];
    }
    return _rowWidths;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

#pragma mark - 默认的属性值
- (void)defaultInit
{
    self.scrollDirection = ZZCollectionViewScrollDirectionVertical;
    self.columnCount = 2;
    self.rowCount = 4;
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.sectionInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.contentInset = self.collectionView.contentInset;
}

#pragma mark - init
- (instancetype)init {
    if (self = [super init]) {
        [self defaultInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self defaultInit];
    }
    return self;
}

#pragma mark - 自定义布局
- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    if (numberOfSections == 0) {
        return;
    }
    
    self.delegate = (id<ZZCollectionViewLayoutDelegate>)self.collectionView.delegate;
    
    [self.allItemAttributes removeAllObjects];
    [self.columnHeights removeAllObjects];
    [self.rowWidths removeAllObjects];
    
    if (self.scrollDirection == ZZCollectionViewScrollDirectionVertical) {
        CGFloat width = self.collectionView.bounds.size.width - self.sectionInsets.left - self.sectionInsets.right - self.contentInset.left - self.contentInset.right;
        self.itemWidth = floorf((width - (self.columnCount - 1) * self.minimumLineSpacing) / self.columnCount);
        _itemSize = CGSizeMake(self.itemWidth, 0);
        
        CGFloat topHeight = self.contentInset.top;
        //先存储起始位置，每列的高度
        [self resetColumnHeights:topHeight];
    
    }else if (self.scrollDirection == ZZCollectionViewScrollDirectionHorizontal) {
        CGFloat height = self.collectionView.bounds.size.height - self.sectionInsets.top - self.sectionInsets.bottom - self.contentInset.top - self.contentInset.bottom;
        self.itemHeight = floorf((height - (self.rowCount - 1) * self.minimumInteritemSpacing) / self.rowCount);
        _itemSize = CGSizeMake(0, self.itemHeight);
        
        CGFloat leftWidth = self.contentInset.left;
        [self resetRowWidths:leftWidth];
    }
    
    for (int section=0; section<numberOfSections; section++) {
        //1、section header
        UICollectionViewLayoutAttributes * headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:ZZCollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        
        [self.allItemAttributes addObject:headerAttributes];
        
        
        //2、section items
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        for (int item=0; item<items; item++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes * attriutes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.allItemAttributes addObject:attriutes];
        }
        
        //3、section footer
        UICollectionViewLayoutAttributes * footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:ZZCollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        
        [self.allItemAttributes addObject:footerAttributes];
        
    }
}


- (CGSize)collectionViewContentSize {
    if ([self.collectionView numberOfSections] == 0) {
        return CGSizeZero;
    }
    
    CGSize size = self.collectionView.bounds.size;
    
    if (self.scrollDirection == ZZCollectionViewScrollDirectionVertical) {
        CGFloat height = [self.columnHeights.firstObject floatValue];
        size.height = height;
    
    }else if (self.scrollDirection == ZZCollectionViewScrollDirectionHorizontal) {
        CGFloat width = [self.rowWidths.firstObject floatValue];
        size.width = width;
    }
    
    return size;
}

//重写header和footer布局
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes * layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    CGSize sectionSize = CGSizeZero;
    
    if ([elementKind isEqualToString:ZZCollectionElementKindSectionHeader]) {
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)])
        {
            sectionSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath.section];
        }
    }
    else if ([elementKind isEqualToString:ZZCollectionElementKindSectionFooter]) {
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
            sectionSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:indexPath.section];
        }
    }
    
    if (self.scrollDirection == ZZCollectionViewScrollDirectionVertical) {
        
        NSInteger columnIndex = [self getLongestColumnIndex];
        CGFloat header_y = [self.columnHeights[columnIndex] floatValue];
        CGFloat topHeight = 0.0;
        
        if ([elementKind isEqualToString:ZZCollectionElementKindSectionHeader]) {
            layoutAttributes.frame = CGRectMake(0, header_y, sectionSize.width, sectionSize.height);
            topHeight = CGRectGetMaxY(layoutAttributes.frame) + self.sectionInsets.top;
            
        }else if ([elementKind isEqualToString:ZZCollectionElementKindSectionFooter]) {
            header_y = header_y - self.minimumInteritemSpacing + self.sectionInsets.bottom;
            layoutAttributes.frame = CGRectMake(0, header_y, sectionSize.width, sectionSize.height);
            topHeight = CGRectGetMaxY(layoutAttributes.frame);
        }
        //更新高度
        [self resetColumnHeights:topHeight];
    
    }else if (self.scrollDirection == ZZCollectionViewScrollDirectionHorizontal) {
        
        NSInteger rowIndedx = [self getLongestRowIndex];
        CGFloat left_x = [self.rowWidths[rowIndedx] floatValue];
        CGFloat leftWidth = 0.0;
        
        if ([elementKind isEqualToString:ZZCollectionElementKindSectionHeader]) {
            layoutAttributes.frame = CGRectMake(left_x, 0, sectionSize.width, sectionSize.height);
            leftWidth = CGRectGetMaxX(layoutAttributes.frame) + self.sectionInsets.left;
            
        }else if ([elementKind isEqualToString:ZZCollectionElementKindSectionFooter]) {
            left_x = left_x - self.minimumLineSpacing + self.sectionInsets.right;
            layoutAttributes.frame = CGRectMake(left_x, 0, sectionSize.width, sectionSize.height);
            leftWidth = CGRectGetMaxX(layoutAttributes.frame);
        }
        //更新宽度
        [self resetRowWidths:leftWidth];
    }
    
    return layoutAttributes;
}

//重写item布局
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGSize item_size = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        item_size = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
    }
    
    if (self.scrollDirection == ZZCollectionViewScrollDirectionVertical) {
        
        NSInteger columnIndex = [self getShortestColumnIndex];
        CGFloat att_x = self.contentInset.left + self.sectionInsets.left + columnIndex * (self.itemWidth + self.minimumLineSpacing);
        CGFloat att_y = [self.columnHeights[columnIndex] floatValue];
        attributes.frame = CGRectMake(att_x, att_y, self.itemWidth, item_size.height);
        self.columnHeights[columnIndex] = @(CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing);
        
    }else if (self.scrollDirection == ZZCollectionViewScrollDirectionHorizontal) {
    
        NSInteger rowIndex = [self getShortesrRowIndex];
        CGFloat att_x = [self.rowWidths[rowIndex] floatValue];
        CGFloat att_y = self.contentInset.top + self.sectionInsets.top + rowIndex * (self.itemHeight + self.minimumInteritemSpacing);
        attributes.frame = CGRectMake(att_x, att_y, item_size.width, self.itemHeight);
        self.rowWidths[rowIndex] = @(CGRectGetMaxX(attributes.frame) + self.minimumLineSpacing);
    }
    
    return attributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.allItemAttributes;
}

//更新高度
- (void)resetColumnHeights:(CGFloat)top {
    BOOL isNull = YES;
    if (self.columnHeights.count > 0) {
        isNull = NO;
    }
    
    for (int i=0; i<self.columnCount; i++) {
        if (isNull) {
            [self.columnHeights addObject:@(top)];
        }else {
            self.columnHeights[i] = @(top);
        }
    }
}

//更新宽度
- (void)resetRowWidths:(CGFloat)left {
    BOOL isNull = YES;
    if (self.rowWidths.count > 0) {
        isNull = NO;
    }
    
    for (int i=0; i<self.rowCount; i++) {
        if (isNull) {
            [self.rowWidths addObject:@(left)];
        }else {
            self.rowWidths[i] = @(left);
        }
    }
}

//最长的一列
- (NSInteger)getLongestColumnIndex {
    
    __block NSInteger index = 0;
    __block CGFloat longestColumn = 0;
    [self.columnHeights enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat height = [obj floatValue];
        if (height > longestColumn) {
            longestColumn = height;
            index = idx;
        }
    }];
    return index;
}

//最短的一列
- (NSInteger)getShortestColumnIndex {
    
    __block NSInteger index = 0;
    __block CGFloat shortestColumn = MAXFLOAT;
    [self.columnHeights enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat height = [obj floatValue];
        if (height < shortestColumn) {
            shortestColumn = height;
            index = idx;
        }
    }];
    return index;
}

//最长的一行
- (NSInteger)getLongestRowIndex {
    
    __block NSInteger index = 0;
    __block CGFloat longestRow = 0;
    [self.rowWidths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat width = [obj floatValue];
        if (width > longestRow) {
            longestRow = width;
            index = idx;
        }
    }];
    return index;
}

//最短的一行
- (NSInteger)getShortesrRowIndex {
    
    __block NSInteger index = 0;
    __block CGFloat shortestRow = MAXFLOAT;
    [self.rowWidths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat width = [obj floatValue];
        if (width < shortestRow) {
            shortestRow = width;
            index = idx;
        }
    }];
    return index;
}


@end
