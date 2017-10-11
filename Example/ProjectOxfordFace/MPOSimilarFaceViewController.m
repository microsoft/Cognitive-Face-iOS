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

#import "MPOSimilarFaceViewController.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Crop.h"
#import "ImageHelper.h"
#import "PersonFace.h"
#import "PersistedFace.h"
#import "MPOSimpleFaceCell.h"
#import "MBProgressHUD.h"
#import "PersonFace.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>

@interface MPOSimilarFaceViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource> {
    NSMutableArray<PersistedFace*> * _selectedFaces;
    NSMutableArray<PersonFace*> * _baseFaces;
    UICollectionView * _imageContainer0;
    UICollectionView * _imageContainer1;
    UIScrollView * _resultContainer;
    UIButton * _findBtn;
    UILabel * _imageCountLabel;
    NSInteger _selectIndex;
    NSInteger _selectedTargetIndex;
    NSString * _largrFaceListId;
}

@end

@implementation MPOSimilarFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Find Similar Faces";
    [self buildMainUI];
    _baseFaces = [[NSMutableArray alloc] init];
    _selectedFaces = [[NSMutableArray alloc] init];
    _selectedTargetIndex = -1;
}

- (void)chooseImage: (id)sender {
    _selectIndex = [(UIView*)sender tag];
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

- (void)createLargeFaceList {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Creating Large Face List";
    [HUD show: YES];
    
    NSString * largeFaceListId = [[[NSUUID UUID] UUIDString] lowercaseString];
    
    [client createLargeFaceList:largeFaceListId name:@"name" userData:nil completionBlock:^(NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil simpleDialog:@"Failed in creating large face list."];
            NSLog(@"%@", error);
            return;
        }
        _largrFaceListId = largeFaceListId;
        [CommonUtil showSimpleHUD:@"Large face list created" forController:self.navigationController];
    }];
}

- (void)deleteLargeFaceList {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    [client deleteLargeFaceList:_largrFaceListId name:@"name" userData:nil completionBlock:^(NSError *error) {
       if (error) {
            NSLog(@"%@", error);
            return;
        }
    }];
}

- (void)addFace:data image:(UIImage *) image{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Adding faces";
    [HUD show: YES];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    
    [client addFaceInLargeFaceList:_largrFaceListId data:data userData:nil faceRectangle:nil  completionBlock:^(MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Failed in adding face" forController:self.navigationController];
            return;
        }
        [CommonUtil showSimpleHUD:@"Successed in adding face" forController:self.navigationController];
        
        PersistedFace *obj = [[PersistedFace alloc] init];
        obj.image = image;
        obj.persistedFaceId = addPersistedFaceResult.persistedFaceId;
        
        [_selectedFaces addObject:obj];
        
        _imageCountLabel.text =  [NSString stringWithFormat:@"%d faces in total", (int32_t)_selectedFaces.count];
        [_imageContainer0 reloadData];
        [_imageContainer1 reloadData];
        
    }];
}

- (void)trainLargeFaceList {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Training large face list";
    [HUD show: YES];
    
    [client trainLargeFaceList:_largrFaceListId completionBlock:^(NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Failed in training large face list." forController:self.navigationController];
        } else {
            [self findSimilarFace];
        }
    }];
}

- (void)findSimilarFace {
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Finding similar faces";
    [HUD show: YES];
    
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    
    [client findSimilarWithFaceId:_baseFaces[_selectedTargetIndex].face.faceId largeFaceListId:_largrFaceListId completionBlock:^(NSArray<MPOSimilarPersistedFace *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        
        if (error) {
            [CommonUtil showSimpleHUD:@"Failed to find similar faces" forController:self.navigationController];
            return;
        }
        
        for (UIView * v in _resultContainer.subviews) {
            [v removeFromSuperview];
        }
        for (int i = 0; i < collection.count; i++) {
            MPOSimilarPersistedFace * result = collection[i];
            UIImageView * imageView = [[UIImageView alloc] initWithImage:((PersistedFace*)[self faceForId:result.persistedFaceId]).image];
            imageView.width = _resultContainer.width / 6;
            imageView.height = imageView.width;
            imageView.left = 5;
            imageView.top = 5 + (imageView.height + 5) * i;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            UILabel * label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"confidence: %f", result.confidence.floatValue];
            [label sizeToFit];
            label.center = imageView.center;
            label.left = imageView.right + 30;
            
            [_resultContainer addSubview:imageView];
            [_resultContainer addSubview:label];
        }
        _resultContainer.contentSize = CGSizeMake(_resultContainer.width, 5 + collection.count * (5 + _resultContainer.width / 6));
        if (collection.count == 0) {
            [CommonUtil showSimpleHUD:@"No similar faces." forController:self.navigationController];
        }
    }];
}

- (PersistedFace*)faceForId:(NSString*)faceId {
    for (PersistedFace * face in _selectedFaces) {
        if ([face.persistedFaceId isEqualToString:faceId]) {
            return face;
        }
    }
    return nil;
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
    UIButton * addFacesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addFacesBtn.titleLabel.numberOfLines = 0;
    [addFacesBtn setTitle:@"Add Faces" forState:UIControlStateNormal];
    addFacesBtn.width = SCREEN_WIDTH / 3 - 20;
    addFacesBtn.height = addFacesBtn.width * 3 / 7;
    addFacesBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    addFacesBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addFacesBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    label.width = addFacesBtn.width;
    label.adjustsFontSizeToFitWidth = YES;
    
    _imageCountLabel = [[UILabel alloc] init];
    _imageCountLabel.text = @"0 faces in total";
    _imageCountLabel.left = 20;
    _imageCountLabel.top = label.bottom;
    [scrollView addSubview:_imageCountLabel];
    [_imageCountLabel sizeToFit];
    _imageCountLabel.width = addFacesBtn.width;
    _imageCountLabel.adjustsFontSizeToFitWidth = YES;
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    _imageContainer0 = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _imageContainer0.width = SCREEN_WIDTH - addFacesBtn.width - 20 - 10 - 20;
    _imageContainer0.height = _imageContainer0.width * 3 / 5;
    _imageContainer0.top = 20;
    _imageContainer0.right = SCREEN_WIDTH - 20;
    _imageContainer0.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_imageContainer0 registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _imageContainer0.dataSource = self;
    _imageContainer0.delegate = self;
    
    addFacesBtn.center = _imageContainer0.center;
    addFacesBtn.left = 20;
    addFacesBtn.tag = 0;
    [addFacesBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:addFacesBtn];
    [scrollView addSubview:_imageContainer0];
    
    label = [[UILabel alloc] init];
    label.text = @"Target face:";
    label.left = 20;
    label.top = _imageContainer0.bottom + 10;
    [scrollView addSubview:label];
    [label sizeToFit];
    
    UIButton * selectImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectImgBtn.titleLabel.numberOfLines = 0;
    [selectImgBtn setTitle:@"Select Image" forState:UIControlStateNormal];
    selectImgBtn.width = SCREEN_WIDTH / 3 - 20;
    selectImgBtn.height = selectImgBtn.width * 3 / 7;
    selectImgBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    selectImgBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [selectImgBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    selectImgBtn.tag = 1;
    [selectImgBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    label.width = selectImgBtn.width;
    label.adjustsFontSizeToFitWidth = YES;
    
    flowLayout =[[UICollectionViewFlowLayout alloc] init];
    _imageContainer1 = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _imageContainer1.width = SCREEN_WIDTH - selectImgBtn.width - 20 - 10 - 20;
    _imageContainer1.height = _imageContainer1.width * 1 / 2;
    _imageContainer1.top = label.top;
    _imageContainer1.right = SCREEN_WIDTH - 20;
    _imageContainer1.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_imageContainer1 registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _imageContainer1.dataSource = self;
    _imageContainer1.delegate = self;
    
    selectImgBtn.center = _imageContainer1.center;
    selectImgBtn.left = 20;
    [scrollView addSubview:selectImgBtn];
    [scrollView addSubview:_imageContainer1];
    
    label = [[UILabel alloc] init];
    label.text = @"Result:";
    [label sizeToFit];
    label.left = 20;
    label.top = _imageContainer1.bottom + 10;
    [scrollView addSubview:label];
    
    _resultContainer = [[UIScrollView alloc] init];
    _resultContainer.width = SCREEN_WIDTH - 20 - 20;
    _resultContainer.height = _imageContainer0.width * 5 / 7;
    _resultContainer.top = label.bottom + 5;
    _resultContainer.left = 20;
    _resultContainer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [scrollView addSubview:_resultContainer];
    
    _findBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _findBtn.height = selectImgBtn.height;
    _findBtn.width = SCREEN_WIDTH - 40;
    [_findBtn setTitle:@"Find Similar Faces" forState:UIControlStateNormal];
    [_findBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    _findBtn.left = 20;
    _findBtn.top = _resultContainer.bottom + 30;
    _findBtn.enabled = NO;
    [_findBtn addTarget:self action:@selector(trainLargeFaceList) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:_findBtn];
    
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _findBtn.bottom + 20);
    [self.view addSubview:scrollView];
    
    [self deleteLargeFaceList];
    [self createLargeFaceList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        [self pickImage];
    else if (buttonIndex == 1)
        [self snapImage];
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
    
   
    NSData *data = UIImageJPEGRepresentation(_selectedImage, 0.8);
    if(_selectIndex != 0){
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.labelText = @"Detecting faces";
        [HUD show: YES];
        MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    
            [client detectWithData:data returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
            [HUD removeFromSuperview];
            if (error) {
                [CommonUtil showSimpleHUD:@"Detection failed" forController:self.navigationController];
                return;
            }
            
            NSMutableArray * faces = [[NSMutableArray alloc] init];
            
            for (MPOFace *face in collection) {
                UIImage *croppedImage = [_selectedImage crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
                PersonFace *obj = [[PersonFace alloc] init];
                obj.image = croppedImage;
                obj.face = face;
                [faces addObject:obj];
            }
            
            [_baseFaces removeAllObjects];
            [_baseFaces addObjectsFromArray:faces];
            _findBtn.enabled = NO;
            _selectedTargetIndex = -1;
            
            _imageCountLabel.text =  [NSString stringWithFormat:@"%d faces in total", (int32_t)_selectedFaces.count];
            [_imageContainer0 reloadData];
            [_imageContainer1 reloadData];
            if (collection.count == 0) {
                [CommonUtil showSimpleHUD:@"No face detected." forController:self.navigationController];
            }
        }];
    }else {
        [self addFace:data image:_selectedImage];
    }
    
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return collectionView == _imageContainer0 ? _selectedFaces.count : _baseFaces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPOSimpleFaceCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    cell.layer.borderWidth = 0;
    NSArray * faces;
    if(collectionView == _imageContainer0){
        cell.imageView.image = _selectedFaces[indexPath.row].image;
    }else{
        faces = _baseFaces;
        cell.imageView.image = ((PersonFace*)faces[indexPath.row]).image;
    }
    if (collectionView == _imageContainer1 && indexPath.row == _selectedTargetIndex) {
        cell.layer.borderWidth = 2;
        cell.layer.borderColor = [[UIColor redColor] CGColor];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.width / 3 - 10, collectionView.width / 3 - 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedTargetIndex = indexPath.row;
    [_imageContainer1 reloadData];
    if (_selectedFaces.count > 0) {
        _findBtn.enabled = YES;
    }
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
