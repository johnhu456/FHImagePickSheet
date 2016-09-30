//
//  FHImagePickSheetFlowLayout.m
//  FHImagePickSheet
//
//  Created by MADAO on 16/4/18.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import "FHImagePickSheetFlowLayout.h"

@interface FHImagePickSheetFlowLayout() {
    NSInteger _photoCount;
    CGSize _contentSize;
}

@property (nonatomic, strong) NSMutableArray *attributesArray;

@end

@implementation FHImagePickSheetFlowLayout

- (instancetype)init
{
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        self.minimumLineSpacing = 5;
        self.minimumInteritemSpacing = 5;
    }
    return self;
}

- (void)setShowPreview:(BOOL)showPreview
{
    _showPreview = showPreview;
    [self invalidateLayout];
}

- (NSMutableArray *)attributesArray
{
    if (_attributesArray == nil) {
        _attributesArray = [[NSMutableArray alloc] initWithCapacity:_photoCount];
    }
    return _attributesArray;
}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    [self.attributesArray removeAllObjects];
    _photoCount = [self.collectionView numberOfSections];
    
    id<UICollectionViewDelegateFlowLayout> collectionLayoitDelegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    CGPoint origin = CGPointMake(self.sectionInset.left, self.sectionInset.top);
    for (int index = 0; index < _photoCount; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        CGSize itemSize;
        if ([collectionLayoitDelegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
            itemSize = [collectionLayoitDelegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            itemSize = CGSizeMake(itemSize.width, itemSize.height - self.sectionInset.top - self.sectionInset.bottom);
        }
        else
        {
            itemSize = CGSizeZero;
        }
        UICollectionViewLayoutAttributes *newAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        newAttributes.frame = (CGRect){origin, itemSize};
        origin = CGPointMake(CGRectGetMaxX(newAttributes.frame) + self.sectionInset.right, origin.y);
        [self.attributesArray addObject:newAttributes];
    }
    _contentSize = CGSizeMake(origin.x, self.collectionView.frame.size.height);
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    CGPoint contentOffset = proposedContentOffset;
    NSIndexPath *indexPath = self.centerIndexPath;
    UICollectionViewLayoutAttributes *attribute = self.attributesArray[indexPath.section];
    contentOffset.x = CGRectGetMidX(attribute.frame) - self.collectionView.frame.size.width/2.0;
    contentOffset.x = MAX(contentOffset.x, - self.collectionView.contentInset.left);
    contentOffset.x = MIN(contentOffset.x, [self collectionViewContentSize].width - self.collectionView.frame.size.width + self.collectionView.contentInset.right);
    self.centerIndexPath = nil;
    return [super targetContentOffsetForProposedContentOffset:contentOffset];
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (UICollectionViewLayoutAttributes *att in self.attributesArray) {
        if (CGRectIntersectsRect(rect,att.frame)) {
            UICollectionViewLayoutAttributes *supplementArributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:att.indexPath];
            [array addObject:att];
            [array addObject:supplementArributes];
        }
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.attributesArray[indexPath.section];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    id<UICollectionViewDelegateFlowLayout> collectionLayoitDelegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    CGRect visibleFrame = (CGRect){[self reallyContentOffSet:self.collectionView], [self visibleSize:self.collectionView]};
    
    CGSize itemSize;
    if ([collectionLayoitDelegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        itemSize = [collectionLayoitDelegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath.section];
    }else
    {
        itemSize = CGSizeZero;
    }
    CGFloat originX = MAX(CGRectGetMinX(itemAttributes.frame) + self.minimumInteritemSpacing, MIN(CGRectGetMaxX(itemAttributes.frame) - itemSize.width - self.minimumInteritemSpacing, CGRectGetMaxX(visibleFrame) - itemSize.width));
    
    UICollectionViewLayoutAttributes *supplementaryAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    supplementaryAttributes.zIndex = 1;
    supplementaryAttributes.hidden = !self.showPreview;
    supplementaryAttributes.frame = (CGRect){CGPointMake(originX, CGRectGetMaxY(itemAttributes.frame) - itemSize.height - 5.f),itemSize};
    return supplementaryAttributes;
}

- (CGPoint )reallyContentOffSet:(UICollectionView *)collectionView{
    CGPoint contentOffSet = collectionView.contentOffset;
    UIEdgeInsets insets = collectionView.contentInset;
    contentOffSet = CGPointMake(contentOffSet.x += insets.left, contentOffSet.y += insets.top);
    return contentOffSet;
}

- (CGSize)visibleSize:(UICollectionView *)collectionView
{
    UIEdgeInsets insets = collectionView.contentInset;
    CGSize collectionSize = collectionView.bounds.size;
    collectionSize = CGSizeMake(collectionSize.width -= (insets.left + insets.right), collectionSize.height);
    return  collectionSize;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}
@end
