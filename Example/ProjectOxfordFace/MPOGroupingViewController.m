// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license.
//
// Microsoft Cognitive Services (formerly Project Oxford): https://www.microsoft.com/cognitive-services
//
// Microsoft Cognitive Services (formerly Project Oxford) GitHub:
// https://github.com/Microsoft/Cognitive-Face-iOS
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MPOGroupingViewController.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Crop.h"
#import "ImageHelper.h"
#import "MBProgressHUD.h"
#import "PersonFace.h"
#import "MPOSimpleFaceCell.h"
#import "MPOGroupSectionHeaderView.h"
#import "PersonFace.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>

@interface MPOGroupingViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource> {
    NSMutableArray * _faces;
    UICollectionView * _imageContainer;
    UICollectionView * _resultContainer;
    UIButton * _groupBtn;
    UILabel * _imageCountLabel;
    BOOL _messyGroupExists;
    
    NSMutableArray<NSArray *> * _resultGroups;
}

@end

@implementation MPOGroupingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Grouping";
    [self buildMainUI];
    _faces = [[NSMutableArray alloc] init];
    _resultGroups = [[NSMutableArray alloc] init];
    _messyGroupExists = FALSE;
}

- (void)chooseImage: (id)sender {
    UIActionSheet * choose_photo_sheet = [[UIActionSheet alloc]
                                          initWithTitle:@"Select Image"
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"Select from album", @"Take a photo",nil];
    [choose_photo_sheet showInView:self.view];
}

- (void)pickImage {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)snapImage {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)groupFaces: (id)sender {
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Grouping faces";
    [HUD show: YES];
    
    NSMutableArray *faceIds = [[NSMutableArray alloc] init];
    
    for (PersonFace *obj in _faces) {
        [faceIds addObject:obj.face.faceId];
    }
    
    [_resultGroups removeAllObjects];
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    [client groupWithFaceIds:faceIds completionBlock:^(MPOGroupResult *groupResult, NSError *error) {
        //add all of the normal group members if they exist
        
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Grouping failed" forController:self.navigationController];
            return;
        }
        
        for (NSArray *group in groupResult.groups) {
            NSMutableArray *currentGroup = [[NSMutableArray alloc] init];
            for (NSString *faceId in group) {
                [currentGroup addObject:[self faceForId:faceId]];
            }
            [_resultGroups addObject:currentGroup.copy];
        }
        
        //add all of the messey group members if they exist
        if (groupResult.messeyGroup.count != 0) {
            NSMutableArray *allGroupsMessyGroup = [[NSMutableArray alloc] init];
            for (NSString *faceId in groupResult.messeyGroup) {
                [allGroupsMessyGroup addObject:[self faceForId:faceId]];
            }
            [_resultGroups addObject:allGroupsMessyGroup.copy];
            _messyGroupExists = TRUE;
        }
        else {
            _messyGroupExists = FALSE;
        }
        
        [_resultContainer reloadData];
    }];
}

- (PersonFace*)faceForId:(NSString*)faceId {
    for (PersonFace * face in _faces) {
        if ([face.face.faceId isEqualToString:faceId]) {
            return face;
        }
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildMainUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
    
    UILabel * label = [[UILabel alloc] init];
    label.text = @"Face database:";
    label.left = 20;
    label.top = 20;
    [scrollView addSubview:label];
    [label sizeToFit];
    
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    UIButton * selectImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectImgBtn.titleLabel.numberOfLines = 0;
    [selectImgBtn setTitle:@"Add Faces" forState:UIControlStateNormal];
    selectImgBtn.width = SCREEN_WIDTH / 3 - 20;
    selectImgBtn.height = selectImgBtn.width * 3 / 7;
    selectImgBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    selectImgBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [selectImgBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [selectImgBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    label.width = selectImgBtn.width;
    label.adjustsFontSizeToFitWidth = YES;
    
    _imageCountLabel = [[UILabel alloc] init];
    _imageCountLabel.text = @"0 faces in total";
    _imageCountLabel.left = 20;
    _imageCountLabel.top = label.bottom + 2;
    [scrollView addSubview:_imageCountLabel];
    [_imageCountLabel sizeToFit];
    _imageCountLabel.width = selectImgBtn.width;
    _imageCountLabel.adjustsFontSizeToFitWidth = YES;
    
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    _imageContainer = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _imageContainer.width = SCREEN_WIDTH - selectImgBtn.width - 20 - 10 - 20;
    _imageContainer.height = _imageContainer.width * 4 / 5;
    _imageContainer.top = 20;
    _imageContainer.right = SCREEN_WIDTH - 20;
    _imageContainer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_imageContainer registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _imageContainer.dataSource = self;
    _imageContainer.delegate = self;
    
    selectImgBtn.center = _imageContainer.center;
    selectImgBtn.left = 20;
    [scrollView addSubview:selectImgBtn];
    [scrollView addSubview:_imageContainer];
    
    label = [[UILabel alloc] init];
    label.text = @"Result:";
    [label sizeToFit];
    label.left = 20;
    label.top = _imageContainer.bottom + 10;
    [scrollView addSubview:label];
    
    flowLayout =[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setSectionInset:UIEdgeInsetsMake(5, 5, 5, 5)];
    _resultContainer = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _resultContainer.width = SCREEN_WIDTH - 20 - 20;
    _resultContainer.top = label.bottom + 5;
    _resultContainer.left = 20;
    _resultContainer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_resultContainer registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    [_resultContainer registerClass:[MPOGroupSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"faceSectionHeader"];
    _resultContainer.dataSource = self;
    _resultContainer.delegate = self;
    [scrollView addSubview:_resultContainer];
    
    _groupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _groupBtn.height = selectImgBtn.height;
    _groupBtn.width = SCREEN_WIDTH - 40;
    [_groupBtn setTitle:@"Grouping" forState:UIControlStateNormal];
    [_groupBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    _groupBtn.left = 20;
    _groupBtn.bottom = self.view.height - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - 20;
    _groupBtn.enabled = NO;
    [_groupBtn addTarget:self action:@selector(groupFaces:) forControlEvents:UIControlEventTouchUpInside];
    _resultContainer.height = _groupBtn.top - _resultContainer.top - 20;
    [scrollView addSubview:_groupBtn];
    
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _groupBtn.bottom + 20);
    [self.view addSubview:scrollView];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self pickImage];
    } else if (buttonIndex == 1) {
        [self snapImage];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage * _selectedImage;
    if (info[UIImagePickerControllerEditedImage])
        _selectedImage = info[UIImagePickerControllerEditedImage];
    else
        _selectedImage = info[UIImagePickerControllerOriginalImage];
    [_selectedImage fixOrientation];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"detecting faces";
    [HUD show: YES];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    NSData *data = UIImageJPEGRepresentation(_selectedImage, 0.8);
    [client detectWithData:data returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"detection failed" forController:self.navigationController];
            return;
        }
        for (MPOFace *face in collection) {
            UIImage *croppedImage = [_selectedImage crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
            PersonFace *obj = [[PersonFace alloc] init];
            obj.image = croppedImage;
            obj.face = face;
            [_faces addObject:obj];
        }
        [_imageContainer reloadData];
        if (_faces.count > 0) {
            _groupBtn.enabled = YES;
        }
        _imageCountLabel.text =  [NSString stringWithFormat:@"%d faces in total", (int32_t)_faces.count];
        
        if (collection.count == 0) {
            [CommonUtil showSimpleHUD:@"No face detected." forController:self.navigationController];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:image forKey:@"UIImagePickerControllerOriginalImage"];
    [self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error){
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:@"Image written to photo album" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }else{
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Error writing to photo album: %@",[error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

#pragma mark -CollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == _imageContainer) {
        return 1;
    } else {
        return _resultGroups.count;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _imageContainer) {
        return _faces.count;
    } else {
        return _resultGroups[section].count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPOSimpleFaceCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    if (collectionView == _imageContainer) {
        cell.imageView.image = ((PersonFace*)_faces[indexPath.row]).image;
    } else {
        cell.imageView.image = ((PersonFace*)_resultGroups[indexPath.section][indexPath.row]).image;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _imageContainer) {
        return CGSizeMake(_imageContainer.width / 3 - 10, _imageContainer.width / 3 - 10);
    } else {
        return CGSizeMake(_resultContainer.width / 5 - 10, _resultContainer.width / 5 - 10);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (collectionView == _imageContainer) {
        return CGSizeMake(0, 0);
    }
    return CGSizeMake(_resultContainer.width, 30);
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView * reusableview = nil;
    if (collectionView == _imageContainer) {
        return nil;
    }
    if (kind == UICollectionElementKindSectionHeader) {
        MPOGroupSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"faceSectionHeader" forIndexPath:indexPath];
        
        if (indexPath.section == _resultGroups.count - 1 && _messyGroupExists) {
            headerView.title = @"Messy Group:";
        } else {
            headerView.title = [NSString stringWithFormat:@"Group %ld:", indexPath.section + 1];
        }
        
        reusableview = headerView;
    }
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
