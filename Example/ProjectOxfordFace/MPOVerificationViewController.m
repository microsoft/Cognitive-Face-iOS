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

#import "MPOVerificationViewController.h"
#import "MPOPersonGroupListController.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Crop.h"
#import "ImageHelper.h"
#import "MPOSimpleFaceCell.h"
#import "MBProgressHUD.h"
#import "PersonFace.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>

@interface MPOVerificationViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    UICollectionView * _imageContainer0;
    UIView * _imageContainer1;
    UIButton * _verifyBtn;
    UILabel * _personNameLabel;
    NSInteger _selectIndex;
    
    NSMutableArray * _faces0;
    NSMutableArray * _faces1;
    
    NSInteger _selectedFaceIndex0;
    NSInteger _selectedFaceIndex1;
    
    PersonGroup * _selectedGroup;
    GroupPerson * _selectedPerson;
}

@end

@implementation MPOVerificationViewController

- (instancetype) initWithVerificationType: (VerificationType) type {
    self = [super init];
    if (self) {
        self.verificationType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Verification";
    
    _faces0 = [[NSMutableArray alloc] init];
    _faces1 = [[NSMutableArray alloc] init];
    
    _selectedFaceIndex0 = -1;
    _selectedFaceIndex1 = -1;
    _selectedGroup = nil;
    _selectedPerson = nil;
    
    [self buildMainUI];
}

- (void)buildMainUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
    
    UILabel * label = [[UILabel alloc] init];
    label.text = @"Face1:";
    label.left = 20;
    label.top = 20;
    [label sizeToFit];
    [scrollView addSubview:label];
    
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    UIButton * selectImgBtn0 = [UIButton buttonWithType:UIButtonTypeCustom];
    selectImgBtn0.titleLabel.numberOfLines = 0;
    [selectImgBtn0 setTitle:@"Select Image" forState:UIControlStateNormal];
    selectImgBtn0.width = SCREEN_WIDTH / 3 - 20;
    selectImgBtn0.height = selectImgBtn0.width * 3 / 7;
    selectImgBtn0.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    selectImgBtn0.titleLabel.font = [UIFont systemFontOfSize:14];
    selectImgBtn0.tag = 0;
    [selectImgBtn0 addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    [selectImgBtn0 setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    _imageContainer0 = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _imageContainer0.width = SCREEN_WIDTH - selectImgBtn0.width - 20 - 10 - 20;
    _imageContainer0.height = _imageContainer0.width * 4 / 5;
    _imageContainer0.top = label.top;
    _imageContainer0.right = SCREEN_WIDTH - 20;
    _imageContainer0.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_imageContainer0 registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _imageContainer0.dataSource = self;
    _imageContainer0.delegate = self;
    
    selectImgBtn0.center = _imageContainer0.center;
    selectImgBtn0.left = 20;
    [scrollView addSubview:selectImgBtn0];
    [scrollView addSubview:_imageContainer0];
    
    label = [[UILabel alloc] init];
    label.text = (_verificationType == VerificationTypeFaceAndFace) ? @"Face2:" : @"Person2:";
    [label sizeToFit];
    label.left = 20;
    label.top = _imageContainer0.bottom + 10;
    [scrollView addSubview:label];
    
    UIButton * selectImgBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    selectImgBtn1.titleLabel.numberOfLines = 0;
    [selectImgBtn1 setTitle: (_verificationType == VerificationTypeFaceAndFace) ? @"Select Image" : @"Select Person"
                   forState:UIControlStateNormal];
    selectImgBtn1.width = SCREEN_WIDTH / 3 - 20;
    selectImgBtn1.height = selectImgBtn1.width * 3 / 7;
    selectImgBtn1.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    selectImgBtn1.titleLabel.font = [UIFont systemFontOfSize:13];
    selectImgBtn1.tag = 1;
    [selectImgBtn1 addTarget:self action: (_verificationType == VerificationTypeFaceAndFace) ? @selector(chooseImage:) : @selector(choosePerson:)
            forControlEvents:UIControlEventTouchUpInside];
    [selectImgBtn1 setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    
    if (_verificationType == VerificationTypeFaceAndFace) {
        flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _imageContainer1 = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _imageContainer1.width = SCREEN_WIDTH - selectImgBtn1.width - 20 - 10 - 20;
        _imageContainer1.height = _imageContainer1.width * 4 / 5;
        _imageContainer1.top = label.top;
        _imageContainer1.right = SCREEN_WIDTH - 20;
        _imageContainer1.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [(UICollectionView*)_imageContainer1 registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
        ((UICollectionView*)_imageContainer1).dataSource = self;
        ((UICollectionView*)_imageContainer1).delegate = self;
        
        selectImgBtn1.center = _imageContainer1.center;
        selectImgBtn1.left = 20;
    } else {
        _imageContainer1 = [[UIView alloc] init];
        _imageContainer1.width = SCREEN_WIDTH - selectImgBtn1.width - 20 - 10 - 20;
        _imageContainer1.height = selectImgBtn1.height;
        _imageContainer1.top = label.top;
        _imageContainer1.right = SCREEN_WIDTH - 20;
        _imageContainer1.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        
        _personNameLabel = [[UILabel alloc] init];
        _personNameLabel.font = [UIFont systemFontOfSize:14];
        _personNameLabel.left = 10;
        _personNameLabel.top = 10;
        [_imageContainer1 addSubview:_personNameLabel];
        
        selectImgBtn1.center = _imageContainer1.center;
        selectImgBtn1.left = 20;
    }
    
    [scrollView addSubview:selectImgBtn1];
    [scrollView addSubview:_imageContainer1];
    
    _verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _verifyBtn.height = selectImgBtn0.height;
    _verifyBtn.width = SCREEN_WIDTH - 40;
    [_verifyBtn setTitle:@"Verify" forState:UIControlStateNormal];
    [_verifyBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    _verifyBtn.left = 20;
    _verifyBtn.enabled = NO;
    [_verifyBtn addTarget:self action:@selector(verify:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:_verifyBtn];
    
    _verifyBtn.top = _imageContainer1.bottom + 30;    
    
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _verifyBtn.bottom + 20);
    [self.view addSubview:scrollView];
}

- (void)didSelectPerson: (GroupPerson*)person inGroup: (PersonGroup*)group {
    _selectedGroup = group;
    _selectedPerson = person;
    _personNameLabel.text = person.personName;
    [_personNameLabel sizeToFit];
    if (_selectedFaceIndex0 >= 0) {
        _verifyBtn.enabled = YES;
    }
}

- (void)choosePerson: (id)sender {
    MPOPersonGroupListController * controller = [[MPOPersonGroupListController alloc] init];
    controller.isForVarification = YES;
    [self.navigationController pushViewController:controller animated:YES];
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

- (void)verify: (id)sender {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"verifying faces";
    [HUD show: YES];
    
    void (^completionBlock)(MPOVerifyResult *, NSError *) = ^(MPOVerifyResult *verifyResult, NSError *error){
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"verification failed" forController:self.navigationController];
            return;
        }
        if (verifyResult.isIdentical) {
            NSString * message = nil;
            if (self.verificationType == VerificationTypeFaceAndFace) {
                message = [NSString stringWithFormat:@"Two faces are from one person. The confidence is %@.", verifyResult.confidence];
            } else {
                message = [NSString stringWithFormat:@"This face is belong to this person. The confidence is %@.", verifyResult.confidence];
            }
            [CommonUtil simpleDialog:message];
        } else {
            NSString * message = nil;
            if (self.verificationType == VerificationTypeFaceAndFace) {
                message = @"Two faces are not from one person.";
            } else {
                message = @"This face is not belong to this person.";
            }
            [CommonUtil simpleDialog:message];
        }
    };
    
    PersonFace *firstSelectedFaceObject = _faces0[_selectedFaceIndex0];
    if (self.verificationType == VerificationTypeFaceAndFace) {
        PersonFace *secondSelectedFaceObject = _faces1[_selectedFaceIndex1];
        [client verifyWithFirstFaceId:firstSelectedFaceObject.face.faceId faceId2:secondSelectedFaceObject.face.faceId completionBlock:completionBlock];
    } else {
        [client verifyWithFaceId:firstSelectedFaceObject.face.faceId personId:_selectedPerson.personId largePersonGroupId:_selectedGroup.groupId completionBlock:completionBlock];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (info[UIImagePickerControllerEditedImage]) {
        _selectedImage = info[UIImagePickerControllerEditedImage];
    } else {
        _selectedImage = info[UIImagePickerControllerOriginalImage];
    }
    
    [_selectedImage fixOrientation];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray * faceArray = (_selectIndex == 0) ? _faces0 : _faces1;
    
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
        [faceArray removeAllObjects];
        for (MPOFace *face in collection) {
            UIImage *croppedImage = [_selectedImage crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
            
            PersonFace * personFace = [[PersonFace alloc] init];
            personFace.image = croppedImage;
            personFace.face = face;
            [faceArray addObject:personFace];
        }
        [_imageContainer0 reloadData];
        if (_verificationType == VerificationTypeFaceAndFace) {
            [(UICollectionView*)_imageContainer1 reloadData];
        }
        _verifyBtn.enabled = NO;
        _selectedFaceIndex0 = -1;
        _selectedFaceIndex1 = -1;
        
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _imageContainer0) {
        return _faces0.count;
    } else {
        return _faces1.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPOSimpleFaceCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    cell.layer.borderWidth = 0;
    
    if (collectionView == _imageContainer0) {
        cell.imageView.image = ((PersonFace*)_faces0[indexPath.row]).image;
        if (indexPath.row == _selectedFaceIndex0) {
            cell.layer.borderColor = [[UIColor redColor] CGColor];
            cell.layer.borderWidth = 2;
        }
    } else {
        cell.imageView.image = ((PersonFace*)_faces1[indexPath.row]).image;
        if (indexPath.row == _selectedFaceIndex1) {
            cell.layer.borderColor = [[UIColor redColor] CGColor];
            cell.layer.borderWidth = 2;
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_imageContainer0.width / 3 - 10, _imageContainer0.width / 3 - 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    collectionView == _imageContainer0 ? (_selectedFaceIndex0 = indexPath.row) : (_selectedFaceIndex1 = indexPath.row);
    if (_selectedFaceIndex0 >= 0 && (_selectedFaceIndex1 >= 0 || _selectedPerson)) {
        _verifyBtn.enabled = YES;
    }
    [collectionView reloadData];
}

@end
