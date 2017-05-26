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

#import "MPOPersonFacesController.h"
#import "UIViewController+DismissKeyboard.h"
#import "ImageHelper.h"
#import "UIImage+Crop.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>
#import "MBProgressHUD.h"
#import "MPOPersonFaceCell.h"
#import "PersonFace.h"
#import "MPOAddPersonFaceController.h"

#define INTENSION_SAVE_PERSON   0
#define INTENSION_ADD_FACE      1

@interface MPOPersonFacesController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate> {
    UITextField * _personNameField;
    UICollectionView *_facescollectionView;
    NSInteger _selectFaceIndex;
    
    NSMutableArray * _detectedFaces;
    int _intension;
}

@end

@implementation MPOPersonFacesController

- (void)viewDidLoad {
    [super viewDidLoad];
    _detectedFaces = [[NSMutableArray alloc] init];
    [self buildMainUI];
    self.navigationItem.title = @"Person";
    _intension = INTENSION_SAVE_PERSON;
    [self setupForDismissKeyboard];
}

- (instancetype) initWithGroup:(PersonGroup*) group {
    self = [super init];
    self.group = group;
    return self;
}

- (instancetype) initWithGroup:(PersonGroup *)group andPerson:(GroupPerson*)person {
    self = [super init];
    self.group = group;
    self.person = person;
    return self;
}

- (void)chooseImage: (id)sender {
    if (_personNameField.text.length == 0) {
        [CommonUtil simpleDialog:@"please input the person's name."];
        return;
    }
    
    if (!self.person) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hint"
                                                            message:@"Do you want to create this new person?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        _intension = INTENSION_ADD_FACE;
        [alertView show];
        return;
    }

    UIActionSheet * choose_photo_sheet = [[UIActionSheet alloc]
                                          initWithTitle:@"Select Image"
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"Select from album", @"Take a photo",nil];
    choose_photo_sheet.tag = 0;
    [choose_photo_sheet showInView:self.view];
}

- (void)longPressAction: (UIGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _selectFaceIndex = gestureRecognizer.view.tag;
        UIActionSheet * confirm_sheet = [[UIActionSheet alloc]
                                         initWithTitle:@"Do you want to remove this face?"
                                         delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                         otherButtonTitles:@"Yes",nil];
        confirm_sheet.tag = 1;
        [confirm_sheet showInView:self.view];
    }
}

- (void)save: (id)sender {
    if (_personNameField.text.length == 0) {
        [CommonUtil simpleDialog:@"please input the person's name"];
        return;
    }
    if (!self.person) {
        _intension = INTENSION_SAVE_PERSON;
        [self createPerson];
    } else {
        MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.labelText = @"Updating person";
        [HUD show: YES];
        
        [client updatePersonWithPersonGroupId:self.group.groupId personId:self.person.personId name:_personNameField.text userData:nil completionBlock:^(NSError *error) {
            [HUD removeFromSuperview];
            if (error) {
                [CommonUtil simpleDialog:@"Failed in updating person."];
                return;
            }
            self.person.personName = _personNameField.text;
            [_facescollectionView reloadData];
        }];
    }
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

- (void)buildMainUI {
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel * label = [[UILabel alloc] init];
    label.text = @"Person name:";
    label.font = [UIFont systemFontOfSize:14];
    label.left = 10;
    label.top = 30;
    [label sizeToFit];
    [self.view addSubview:label];
    _personNameField = [[UITextField alloc] init];
    _personNameField.width = SCREEN_WIDTH - label.right - 20;
    _personNameField.height = label.height * 2;
    _personNameField.center = label.center;
    _personNameField.left = label.right + 10;
    _personNameField.borderStyle = UITextBorderStyleLine;
    if (self.person)
        _personNameField.text = self.person.personName;
    [self.view addSubview:_personNameField];
    
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    UIButton * addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton * saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.height = 50;
    saveBtn.height = 50;
    addBtn.width = SCREEN_WIDTH / 2 - 25;
    saveBtn.width = addBtn.width;
    addBtn.left = 20;
    saveBtn.left = addBtn.right + 10;
    addBtn.bottom = self.view.height - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - 20;
    saveBtn.bottom = self.view.height - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - 20;
    [addBtn setTitle:@"Add Face" forState:UIControlStateNormal];
    [saveBtn setTitle:@"Save" forState:UIControlStateNormal];
    [addBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    [self.view addSubview:addBtn];
    
    label = [[UILabel alloc] init];
    label.text = @"- Long press a face to delete.";
    label.font = [UIFont systemFontOfSize:12];
    [label sizeToFit];
    label.bottom = addBtn.top - 10;
    label.left = addBtn.left;
    [self.view addSubview:label];
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
    _facescollectionView  =[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _facescollectionView.width = SCREEN_WIDTH - 20;
    _facescollectionView.height = label.top - _personNameField.bottom - 30;
    _facescollectionView.left = 10;
    _facescollectionView.top = _personNameField.bottom + 10;
    _facescollectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_facescollectionView registerNib:[UINib nibWithNibName:@"MPOPersonFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _facescollectionView.dataSource = self;
    _facescollectionView.delegate = self;
    [self.view addSubview:_facescollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_facescollectionView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (![self.group.people containsObject:self.person] && self.person.faces.count > 0) {
        [self.group.people addObject:self.person];
    }
}

- (void)createPerson {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"creating person";
    [HUD show: YES];
    
    [client createPersonWithPersonGroupId:self.group.groupId name:_personNameField.text userData:nil completionBlock:^(MPOCreatePersonResult *createPersonResult, NSError *error) {
        [HUD removeFromSuperview];
        if (error || !createPersonResult.personId) {
            [CommonUtil showSimpleHUD:@"Failed in creating person." forController:self.navigationController];
            return;
        }
        self.person = [[GroupPerson alloc] init];
        self.person.personName = _personNameField.text;
        self.person.personId = createPersonResult.personId;
        if (_intension == INTENSION_ADD_FACE) {
            [self chooseImage:nil];
        } else {
            [CommonUtil showSuccessHUD:@"Person created" forController:self.navigationController];
        }
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertViewCancel:(UIAlertView *)alertView {
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self createPerson];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            [self pickImage];
        } else if (buttonIndex == 1) {
            [self snapImage];
        }
    } else if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.labelText = @"Deleting this face";
            [HUD show: YES];
            
            [client deletePersonFaceWithPersonGroupId:self.group.groupId personId:self.person.personId persistedFaceId:((PersonFace*)self.person.faces[_selectFaceIndex]).faceId completionBlock:^(NSError *error) {
                [HUD removeFromSuperview];
                if (error) {
                    [CommonUtil showSimpleHUD:@"Failed in deleting this face" forController:self.navigationController];
                    return;
                }
                [self.person.faces removeObjectAtIndex:_selectFaceIndex];
                [_facescollectionView reloadData];
            }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage * selectedImage;
    if (info[UIImagePickerControllerEditedImage]) {
        selectedImage = info[UIImagePickerControllerEditedImage];
    } else {
        selectedImage = info[UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:^(void) {}];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"detecting faces";
    [HUD show: YES];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    NSData *data = UIImageJPEGRepresentation(selectedImage, 0.8);
    [client detectWithData:data returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Detection failed" forController:self.navigationController];
            return;
        }
        [_detectedFaces removeAllObjects];
        for (MPOFace *face in collection) {
            UIImage *croppedImage = [selectedImage crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
            PersonFace *obj = [[PersonFace alloc] init];
            obj.image = croppedImage;
            obj.face = face;
            [_detectedFaces addObject:obj];
        }
        
        if (_detectedFaces.count == 0) {
            [CommonUtil showSimpleHUD:@"No face detected" forController:self.navigationController];
        } else if (_detectedFaces.count == 1) {
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.labelText = @"Adding faces";
            [HUD show: YES];
            [client addPersonFaceWithPersonGroupId:self.group.groupId personId:self.person.personId data:data userData:nil faceRectangle:collection[0].faceRectangle completionBlock:^(MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error) {
                [HUD removeFromSuperview];
                if (error) {
                    [CommonUtil showSimpleHUD:@"Failed in adding face" forController:self.navigationController];
                    return;
                }
                ((PersonFace*)_detectedFaces[0]).faceId = addPersistedFaceResult.persistedFaceId;
                [self.person.faces addObject:_detectedFaces[0]];
                [_facescollectionView reloadData];
                *self.needTraining = YES;
            }];
        } else {
            MPOAddPersonFaceController * controller = [[MPOAddPersonFaceController alloc] init];
            controller.group = self.group;
            controller.person = self.person;
            controller.detectedFaces = _detectedFaces;
            controller.image = selectedImage;
            controller.needTraining = self.needTraining;
            [self.navigationController pushViewController:controller animated:YES];
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

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.person == nil) {
        return 0;
    }
    return self.person.faces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPOPersonFaceCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    [cell.faceImageView setImage:[(PersonFace*)self.person.faces[indexPath.row] image]];
    cell.faceImageView.tag = indexPath.row;
    if (cell.faceImageView.gestureRecognizers.count == 0) {
        [cell.faceImageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)]];
    }
    
    [cell.personName setText: self.person.personName];
    cell.faceImageView.userInteractionEnabled = YES;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_facescollectionView.width / 3 - 10, (_facescollectionView.width / 3 - 10) * 4 / 3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
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
