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

#import "MPODetectionViewController.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Crop.h"
#import "ImageHelper.h"
#import "PersonFace.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>
#import "MBProgressHUD.h"
#import "CommonUtil.h"
#import "MPODetectionCell.h"

@interface MPODetectionFaceObject : NSObject
@property (nonatomic, strong) UIImage *croppedFaceImage;
@property (nonatomic, strong) NSString *genderText;
@property (nonatomic, strong) NSString *ageText;
@property (nonatomic, strong) NSString *hairText;
@property (nonatomic, strong) NSString *facialHairText;
@property (nonatomic, strong) NSString *makeupText;
@property (nonatomic, strong) NSString *emotionText;
@property (nonatomic, strong) NSString *occlusionText;
@property (nonatomic, strong) NSString *exposureText;
@property (nonatomic, strong) NSString *headPoseText;
@property (nonatomic, strong) NSString *accessoriesText;
@end

@implementation MPODetectionFaceObject
@end

@interface MPODetectionViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource> {
    UIImage * _selectedImage;
    UIView * _imageContainer;
    UIButton * _detectBtn;
    UITableView * _resultTableView;
    NSMutableArray * _detectionFaces;
}

@end

@implementation MPODetectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Detection";
    _selectedImage = nil;
    _detectionFaces = [[NSMutableArray alloc] init];
    [self buildMainUI];
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

- (void)detectAction: (id)sender {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    
    NSData *data = UIImageJPEGRepresentation(_selectedImage, 0.8);
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"detecting faces";
    [HUD show: YES];
    
    [client detectWithData:data returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[@(MPOFaceAttributeTypeGender), @(MPOFaceAttributeTypeAge), @(MPOFaceAttributeTypeHair), @(MPOFaceAttributeTypeFacialHair), @(MPOFaceAttributeTypeMakeup), @(MPOFaceAttributeTypeEmotion), @(MPOFaceAttributeTypeOcclusion), @(MPOFaceAttributeTypeExposure), @(MPOFaceAttributeTypeHeadPose), @(MPOFaceAttributeTypeAccessories)] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"detection failed" forController:self.navigationController];
            return;
        }
        
        [_detectionFaces removeAllObjects];
        for (MPOFace *face in collection) {
            UIImage *croppedImage = [_selectedImage crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
            MPODetectionFaceObject *obj = [[MPODetectionFaceObject alloc] init];
            obj.croppedFaceImage = croppedImage;
            obj.genderText = [NSString stringWithFormat:@"Gender: %@", face.attributes.gender];
            obj.ageText = [NSString stringWithFormat:@"Age: %@", face.attributes.age.stringValue];
            obj.hairText = [NSString stringWithFormat:@"Hair: %@", face.attributes.hair.hair];
            obj.facialHairText = [NSString stringWithFormat:@"Facial Hair: %@", face.attributes.facialHair.mustache.doubleValue + face.attributes.facialHair.beard.doubleValue + face.attributes.facialHair.sideburns.doubleValue > 0.0 ? @"Yes" : @"No"];
            obj.makeupText = [NSString stringWithFormat:@"Makeup: %@", face.attributes.makeup.eyeMakeup.boolValue || face.attributes.makeup.lipMakeup.boolValue ? @"Yes" : @"No"];
            obj.emotionText = [NSString stringWithFormat:@"Emotion: %@", face.attributes.emotion.mostEmotion];
            obj.occlusionText = [NSString stringWithFormat:@"Occlusion: %@", face.attributes.occlusion.foreheadOccluded || face.attributes.occlusion.eyeOccluded || face.attributes.occlusion.mouthOccluded ? @"Yes" : @"No"];
            obj.exposureText = [NSString stringWithFormat:@"Exposure: %@", face.attributes.exposure.exposureLevel];
            obj.headPoseText = [NSString stringWithFormat:@"HeadPose: roll(%@), yaw(%@)", face.attributes.headPose.roll.stringValue, face.attributes.headPose.yaw.stringValue];
            obj.accessoriesText = [NSString stringWithFormat:@"Accessories: %@", face.attributes.accessories.accessoriesString];
            [_detectionFaces addObject:obj];
        }
        [_resultTableView reloadData];
        if (collection.count == 0) {
            [CommonUtil showSimpleHUD:@"No face detected." forController:self.navigationController];
        }
    }];
}

- (void)buildMainUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
    
    UILabel * label = [[UILabel alloc] init];
    label.text = @"Image:";
    label.left = 20;
    label.top = 20;
    [label sizeToFit];
    [scrollView addSubview:label];
    
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    UIButton * selectImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectImgBtn.titleLabel.numberOfLines = 0;
    [selectImgBtn setTitle:@"Select Image" forState:UIControlStateNormal];
    selectImgBtn.width = SCREEN_WIDTH / 3 - 20;
    selectImgBtn.height = selectImgBtn.width * 3 / 7;
    selectImgBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    selectImgBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [selectImgBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [selectImgBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    
    _imageContainer = [[UIView alloc] init];
    _imageContainer.width = SCREEN_WIDTH - selectImgBtn.width - 20 - 10 - 20;
    _imageContainer.height = _imageContainer.width * 4 / 5;
    _imageContainer.top = 20;
    _imageContainer.right = SCREEN_WIDTH - 20;
    _imageContainer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
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
    
    _detectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _detectBtn.height = selectImgBtn.height;
    _detectBtn.width = SCREEN_WIDTH - 40;
    [_detectBtn setTitle:@"Detect" forState:UIControlStateNormal];
    [_detectBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    _detectBtn.left = 20;
    _detectBtn.bottom = self.view.height - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - 20;
    [_detectBtn addTarget:self action:@selector(detectAction:) forControlEvents:UIControlEventTouchUpInside];
    _detectBtn.enabled = NO;
    [scrollView addSubview:_detectBtn];
    
    _resultTableView = [[UITableView alloc] init];
    _resultTableView.width = SCREEN_WIDTH - 20 - 20;
    _resultTableView.top = label.bottom + 5;
    _resultTableView.left = 20;
    _resultTableView.height = _detectBtn.top - _resultTableView.top - 20;
    _resultTableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    _resultTableView.delegate = self;
    _resultTableView.dataSource = self;
    _resultTableView.tableFooterView = [[UIView alloc] init];
    [_resultTableView registerClass:[MPODetectionCell class] forCellReuseIdentifier:@"detectionCell"];
    [scrollView addSubview:_resultTableView];
    
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _detectBtn.bottom + 20);
    [self.view addSubview:scrollView];
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
    if (info[UIImagePickerControllerEditedImage])
        _selectedImage = info[UIImagePickerControllerEditedImage];
    else
        _selectedImage = info[UIImagePickerControllerOriginalImage];
    [_selectedImage fixOrientation];
    if ([_imageContainer viewWithTag:5])
        [[_imageContainer viewWithTag:5] removeFromSuperview];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_selectedImage];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = _imageContainer.frame;
    imageView.top = 0;
    imageView.left = 0;
    imageView.tag = 5;
    imageView.clipsToBounds = YES;
    [_imageContainer addSubview:imageView];
    [picker dismissViewControllerAnimated:YES completion:nil];
    _detectBtn.enabled = YES;
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


#pragma mark - UITableViewDelegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _detectionFaces.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 168;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"detectionCell";
    MPODetectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MPODetectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    MPODetectionFaceObject * obj = _detectionFaces[indexPath.row];
    cell.genderText = obj.genderText;
    cell.ageText = obj.ageText;
    cell.hairText = obj.hairText;
    cell.facialHairText = obj.facialHairText;
    cell.makeupText = obj.makeupText;
    cell.emotionText = obj.emotionText;
    cell.occlusionText = obj.occlusionText;
    cell.exposureText = obj.exposureText;
    cell.headPoseText = obj.headPoseText;
    cell.accessoriesText = obj.accessoriesText;
    cell.faceImage = obj.croppedFaceImage;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
