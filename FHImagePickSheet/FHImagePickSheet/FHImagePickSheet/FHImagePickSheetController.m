//
//  FHImagePickSheetController.m
//  FHImagePickSheet
//
//  Created by MADAO on 16/4/15.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import "FHImagePickSheetController.h"
#import "FHImageTableViewCell.h"
#import "FHImagePickSheetFlowLayout.h"
#import "FHImagePickCollectionViewCell.h"
#import "FHPickAnimation.h"
#import "FHPreviewMarkView.h"

#import <PhotosUI/PhotosUI.h>

@interface FHImagePickSheetController()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIViewControllerTransitioningDelegate>
{
    CGFloat _tableViewHeight;
}
@property (nonatomic, assign) BOOL imageSelected;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) FHImagePickCollectionView *imageCollectionView;

//@property (nonatomic, strong) UIView *blurView;

@property (nonatomic, strong) NSMutableArray *actionArray;

//Photo
@property (nonatomic, strong) PHFetchResult *photoResult;

@property (nonatomic, strong) PHCachingImageManager *photoManager;

//SelectedPhotoArray
@property (nonatomic, strong) NSMutableArray *selectedImageArray;

@property (nonatomic, strong) NSMutableDictionary *supplementViewDictionary;

@end

@implementation FHImagePickSheetController

#define WEAK_SELF __weak typeof(self) weakSelf = self

static CGSize FHImageThumbnailSize;

#pragma mark - Lazy Init
- (FHImagePickCollectionView *)imageCollectionView{
    if (_imageCollectionView == nil) {
        _imageCollectionView = [[FHImagePickCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.previewPhotoHeight) collectionViewLayout:[[FHImagePickSheetFlowLayout alloc] init]];
        [_imageCollectionView registerNib:[UINib nibWithNibName:@"FHImagePickCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"collectionCell"];
        [_imageCollectionView registerClass:[FHPreviewMarkView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"checkMarkView"];
        _imageCollectionView.dataSource = self;
        _imageCollectionView.delegate = self;
        _imageCollectionView.showsVerticalScrollIndicator = NO;
        _imageCollectionView.showsHorizontalScrollIndicator = NO;
        _imageCollectionView.backgroundColor = [UIColor clearColor];
    }
    return _imageCollectionView;
}

- (UITableView *)actionTableView{
    if (_actionTableView == nil) {
        _actionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _actionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _actionTableView.scrollEnabled = NO;
        _actionTableView.dataSource = self;
        _actionTableView.delegate = self;
        _actionTableView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
    return _actionTableView;
}

- (NSArray *)actionArray{
    if (_actionArray == nil) {
        _actionArray = [[NSMutableArray alloc] init];
    }
    return _actionArray;
}

//- (UIView *)blurView
//{
//    if (_blurView == nil) {
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    }
//    return _blurView;
//}

- (NSMutableArray *)selectedImageArray
{
    if (_selectedImageArray == nil){
        _selectedImageArray = [[NSMutableArray alloc] init];
    }
    return _selectedImageArray;
}

- (NSMutableDictionary *)supplementViewDictionary
{
    if(_supplementViewDictionary == nil){
        _supplementViewDictionary = [[NSMutableDictionary alloc] init];
    }
    return _supplementViewDictionary;
}

- (PHCachingImageManager *)photoManager
{
    if (_photoManager == nil) {
        _photoManager = [[PHCachingImageManager alloc] init];
    }
    return _photoManager;
}

#pragma mark - Init

- (instancetype)init
{
    if (self = [super init]){
        [self initialize];
    }
    return self;
}

- (instancetype)initWithActions:(NSArray *)actions
{
    if (self = [super init]) {
        //Set Actions
        [self.actionArray addObjectsFromArray:actions];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    //TransitionDelegate and ModelStyle
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    //CalculateArguments
    self.previewPhotoHeight = 150;
    self.selectedPhotoHeight = 240;
    self.actionCellHeight = 44;
    _imageSelected = NO;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.imageCollectionView.collectionViewLayout).itemSize;
    FHImageThumbnailSize = CGSizeMake(cellSize.width * screenScale,cellSize.height * screenScale);
    
    //Set SubViews and Gesture
    self.backView = [[UIView alloc] initWithFrame:self.view.frame];
    self.backView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3961];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.backView];
    [self.view addSubview:self.actionTableView];
//    [self.view insertSubview:self.blurView belowSubview:self.actionTableView];
//    self.blurView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self setupGestureRecognizer];
    _tableViewHeight = [self getHeightWithTableView:self.actionTableView];
    
}

- (void)setupGestureRecognizer
{
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePickSheetController)];
    [self.backView addGestureRecognizer:tapGes];
}

#pragma mark - ViewLiftCycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchPhotoAssets];
    [self.actionTableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self resetStatus];

}

- (void)resetStatus
{
    self.imageSelected = NO;
    FHImagePickSheetFlowLayout *layout = (FHImagePickSheetFlowLayout *)self.imageCollectionView.collectionViewLayout;
    [layout setShowPreview:self.imageSelected];
    [layout invalidateLayout];

    _tableViewHeight = [self getHeightWithTableView:self.actionTableView];
    self.actionTableView.frame = CGRectMake(0, self.view.frame.size.height - _tableViewHeight, self.view.frame.size.width, _tableViewHeight);
    [self.selectedImageArray removeAllObjects];
    [self.supplementViewDictionary removeAllObjects];
    self.photoManager = nil;
    self.imageCollectionView = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _tableViewHeight = [self getHeightWithTableView:self.actionTableView];
    self.actionTableView.frame = CGRectMake(0, self.view.frame.size.height - _tableViewHeight, self.view.frame.size.width, _tableViewHeight);
}

- (CGFloat)getHeightWithTableView:(UITableView *)tableView
{
    NSInteger numOfSection = tableView.numberOfSections;
    CGFloat resultHeight = 0;
    for (int count = 0 ; count < numOfSection ; count ++ ) {
        NSInteger numOfRows = [tableView numberOfRowsInSection:count];
        for (int i = 0; i < numOfRows; i ++ ) {
            resultHeight += [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:count]];
        }
    }
    return resultHeight;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
    }
    else
    {
        return self.actionArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1)
    {
        FHPickActionCell *actionCell = [tableView dequeueReusableCellWithIdentifier: kActionCellReuseIdentifier];
        if (actionCell == nil) {
            actionCell = [[FHPickActionCell alloc] initWithAction:nil];
            actionCell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        actionCell.action = self.actionArray[indexPath.row];
        return actionCell;
    }
    //SetImagePickCell
    else
    {
        CGRect cellFrame = CGRectMake(0, 0, self.view.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
        FHImageTableViewCell *imageCell = [tableView dequeueReusableCellWithIdentifier:kImageCellReuseIdentifier];
        if (imageCell == nil){
            imageCell =  [[FHImageTableViewCell alloc] initWithFrame:cellFrame];
            imageCell.backgroundColor = [UIColor clearColor];
        }
        imageCell.collectionView = self.imageCollectionView;
        return imageCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return  self.imageSelected? self.selectedPhotoHeight : self.previewPhotoHeight;
    }
    else
    {
        return self.actionCellHeight;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK_SELF;
    if (indexPath.section == 1) {
        FHPickActionCell *actionCell = [tableView cellForRowAtIndexPath:indexPath];
        if (actionCell.action.actionHandler) {
            actionCell.action.actionHandler();
        }
        if (self.pickSheetDelegate && [self.pickSheetDelegate isKindOfClass:[UIViewController class]]) {
                [self dismissViewControllerAnimated:YES completion:^{
                    //HandleDismiss
                    if ([weakSelf.pickSheetDelegate respondsToSelector:@selector(imagePickSheetDidFinishHide:)]) {
                        [weakSelf.pickSheetDelegate imagePickSheetDidFinishHide:self];
                    }
                }];
            }else
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.photoResult.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FHImagePickCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    __weak __block typeof(collectionViewCell) blockCell = collectionViewCell;
    
    //GetPhoto
    [self requestImageForAsset:self.photoResult[indexPath.section] requestHandler:^(UIImage * _Nullable result) {
        blockCell.image = result;
    }];
    return collectionViewCell;
}

//Set the check mark view
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    FHPreviewMarkView *checkMarkView = (FHPreviewMarkView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"checkMarkView" forIndexPath:indexPath];
    checkMarkView.selected = [self.selectedImageArray containsObject:indexPath];
    [self.supplementViewDictionary setObject:checkMarkView forKey:indexPath];
    return  checkMarkView;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger nextIndex = indexPath.section + 1;
    if (nextIndex < self.photoResult.count){
        [self.photoManager startCachingImagesForAssets:@[self.photoResult[indexPath.section]] targetSize:[self targetSizeForAssetSize:PHImageManagerMaximumSize] contentMode:PHImageContentModeAspectFill options:nil];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.imageSelected){
        [self showPreviewWithIndex:indexPath];
    }
    FHPreviewMarkView *markView = self.supplementViewDictionary[indexPath];
    [self selectedImageAtIndexPath:indexPath WithSelected:!markView.selected];
}

#pragma mark - UICollectionViewFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    PHAsset *asset = self.photoResult[indexPath.section];
    CGFloat proportion = (asset.pixelWidth * 1.0)/asset.pixelHeight;
    CGFloat height = self.imageSelected? self.selectedPhotoHeight : self.previewPhotoHeight;
    CGFloat width = height * proportion;
    return CGSizeMake(width, height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    UIImage *buttonImage = [UIImage imageNamed:@"PreviewSupplementaryView-Checkmark"];
    return CGSizeMake(buttonImage.size.width , buttonImage.size.height);
}

#pragma mark - Photo
- (CGSize)targetSizeForAssetSize:(CGSize)size
{
    CGFloat screenScale = [UIScreen mainScreen].scale;
    return CGSizeMake(size.width *screenScale, size.height * screenScale);
}

- (void)fetchPhotoAssets{
    NSSortDescriptor *dateDescroptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[dateDescroptor];
    self.photoResult = [PHAsset fetchAssetsWithOptions:fetchOptions];
}

- (void)requestImageForAsset:(PHAsset *)asset requestHandler:(void(^)(UIImage * _Nullable result))completion
{
    WEAK_SELF;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    CGSize targetSize = [weakSelf targetSizeForAssetSize:FHImageThumbnailSize];
    [self.photoManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            completion(result);
    }];
}

#pragma mark - Action
- (void)hidePickSheetController
{
    self.imageSelected = NO;
    [self.view setNeedsLayout];
    WEAK_SELF;
    [self dismissViewControllerAnimated:YES completion:^{
        //HandleDismiss
        if ([weakSelf.pickSheetDelegate respondsToSelector:@selector(imagePickSheetDidFinishHide:)]) {
            [weakSelf.pickSheetDelegate imagePickSheetDidFinishHide:self];
     }
    }];
}

- (void)showPreviewWithIndex:(NSIndexPath *)indexPath;
{
    WEAK_SELF;
    if (self.imageSelected)
    {
        return ;
    }
    self.imageSelected = YES;
    
    __weak __block FHImagePickSheetFlowLayout *layout = (FHImagePickSheetFlowLayout *)self.imageCollectionView.collectionViewLayout;
    layout.centerIndexPath = indexPath;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf.actionTableView beginUpdates];
        [weakSelf.actionTableView endUpdates];
        [weakSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [layout setShowPreview:self.imageSelected];
    }];
}

- (void)selectedImageAtIndexPath:(NSIndexPath *)indexPath WithSelected:(BOOL)selected{
    FHPreviewMarkView *markView = self.supplementViewDictionary[indexPath];
    //AdjustContentOffSet
    if (selected){
        FHImagePickCollectionViewCell *cell = (FHImagePickCollectionViewCell *)[self.imageCollectionView cellForItemAtIndexPath:indexPath];
        CGPoint contentOffSet = CGPointMake(CGRectGetMidX(cell.frame) - self.imageCollectionView.frame.size.width/2.0,self.imageCollectionView.contentOffset.y);
        CGFloat contentOffSetX = MAX(contentOffSet.x, -self.imageCollectionView.contentInset.left);
        contentOffSetX = MIN(contentOffSetX, self.imageCollectionView.contentSize.width - self.imageCollectionView.frame.size.width + self.imageCollectionView.contentInset.right);
        [self.imageCollectionView setContentOffset:CGPointMake(contentOffSetX ,self.imageCollectionView.contentOffset.y) animated:YES];
        [self.selectedImageArray addObject:indexPath];
    }
    else
    {
        [self.selectedImageArray removeObject:indexPath];
    }
    [markView setSelected:selected];
}

#pragma mark - Public Method

- (void)addPickSheetAction:(FHPickSheetAction *)action
{
    [self.actionArray addObject:action];
}

- (void)fetchSelectedImageWithCompleteHandle:(void (^)(NSArray *))handle
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    __block NSMutableArray *blockArray = resultArray;
    __block NSInteger count = self.selectedImageArray.count;
    for (NSIndexPath *targetIndexPath in self.selectedImageArray) {
        [self.photoManager requestImageForAsset:self.photoResult[targetIndexPath.section] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [blockArray addObject:result];
            count--;
            if (count == 0) {
                if (handle) {
                    handle(blockArray);
                }
            }
        }];
    }

}
#pragma mark - Transitioning
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.actionTableView.frame = CGRectMake(0, self.view.frame.size.height - _tableViewHeight, self.view.frame.size.width, _tableViewHeight);
    
    if ([self.pickSheetDelegate respondsToSelector:@selector(imagePickSheetDidFinishShow:)]) {
        [self.pickSheetDelegate imagePickSheetDidFinishShow:self];
    }
    return [[FHPickAnimation alloc] initWithPresentController:self presenting:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[FHPickAnimation alloc] initWithPresentController:self presenting:NO];
}

-(void)dealloc
{
    NSLog(@"dealloc");
}
@end
