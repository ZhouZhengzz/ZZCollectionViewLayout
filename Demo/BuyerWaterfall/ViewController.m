//
//  ViewController.m
//  BuyerWaterfall
//
//  Created by zhouzheng on 16/11/9.
//  Copyright © 2016年 zhouzheng. All rights reserved.
//

#import "ViewController.h"
#import "MyCell.h"
#import "Model.h"
#import "ZZCollectionViewLayout.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
static NSString *CELL_ID = @"cellId";
static NSString *HEADER_ID = @"headerId";
static NSString *FOOTER_ID = @"footerId";

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ZZCollectionViewLayoutDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *_dataArray;
    BOOL _isVertical;//是否纵向滑动
    NSInteger _columnCount;//纵向滑动时列数
    NSInteger _rowCount;//横向滑动时行数
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [NSMutableArray array];
    _isVertical = YES;
    _columnCount = 2;
    _rowCount = 4;

    ZZCollectionViewLayout * layout = [[ZZCollectionViewLayout alloc] init];
    if (_isVertical) {
        layout.columnCount = _columnCount;
        layout.scrollDirection = ZZCollectionViewScrollDirectionVertical;
    }else {
        layout.rowCount = _rowCount;
        layout.scrollDirection = ZZCollectionViewScrollDirectionHorizontal;
    }
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor lightGrayColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"MyCell" bundle:nil] forCellWithReuseIdentifier:CELL_ID];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:ZZCollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:ZZCollectionElementKindSectionFooter withReuseIdentifier:FOOTER_ID];

    
    [self getData];
}


- (void)getData {
    
    for (int i=0; i<20; i++) {
        Model *model = [Model new];
        model.height = arc4random()%100 + 100;
        [_dataArray addObject:model];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSLog(@"%@",[NSString stringWithFormat:@"选中第%zd段第%zd个",indexPath.section,indexPath.item]);
}


#pragma mark - itemSize

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Model *model = _dataArray[indexPath.item];
    
    if (_isVertical) {
        //纵向
        return CGSizeMake((ScreenWidth-(_columnCount+1)*10)/_columnCount, model.height);
    }else {
        //横向
        return CGSizeMake(model.height, (ScreenHeight-(_rowCount+1)*10)/_rowCount);
    }
}

#pragma mark - header & footer
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    CGRect frame = CGRectZero;
    if (_isVertical) {
        frame = CGRectMake(0, 0, ScreenWidth, 60);
    }else {
        frame = CGRectMake(0, 0, 60, ScreenHeight);
    }
    
    if ([kind isEqualToString:ZZCollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:ZZCollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
        
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor orangeColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"header";
        [headerView addSubview:label];
        
        return headerView;
    
    }else {
    
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:ZZCollectionElementKindSectionFooter withReuseIdentifier:FOOTER_ID forIndexPath:indexPath];
        
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor brownColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"footer";
        [footerView addSubview:label];
        
        return footerView;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if (_isVertical) {
        //纵向
        return CGSizeMake(ScreenWidth, 60);

    }else {
        //横向
        return CGSizeMake(60, ScreenHeight);
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if (_isVertical) {
        //纵向
        return CGSizeMake(ScreenWidth, 60);

    }else {
        //横向
        return CGSizeMake(60, ScreenHeight);
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
