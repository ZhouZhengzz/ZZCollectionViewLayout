//
//  ZZCollectionViewLayout.h
//  GHS
//
//  Created by zhouzheng on 16/12/4.
//  Copyright © 2016年 zhouzheng. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString * const ZZCollectionElementKindSectionHeader;
FOUNDATION_EXTERN NSString * const ZZCollectionElementKindSectionFooter;


typedef enum : NSUInteger {
    ZZCollectionViewScrollDirectionVertical,
    ZZCollectionViewScrollDirectionHorizontal
} ZZCollectionViewScrollDirection;


@class ZZCollectionViewLayout;
@protocol ZZCollectionViewLayoutDelegate <UICollectionViewDelegate>

@required

//返回每个item的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

//返回header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;

//返回footer的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

@end

@interface ZZCollectionViewLayout : UICollectionViewLayout <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<ZZCollectionViewLayoutDelegate>delegate;


@property (nonatomic, assign) CGSize itemSize;
//滑动方向 默认纵向
@property (nonatomic, assign) ZZCollectionViewScrollDirection scrollDirection;
//列数 如果方向是纵向，默认2列
@property (nonatomic, assign) NSInteger columnCount;
//行数 如果方向是横向，默认4行
@property (nonatomic, assign) NSInteger rowCount;
//行间距 默认10
@property (nonatomic, assign) CGFloat minimumLineSpacing;
//列间距 默认10
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
//默认(10,10,10,10)
@property (nonatomic, assign) UIEdgeInsets sectionInsets;


@end
