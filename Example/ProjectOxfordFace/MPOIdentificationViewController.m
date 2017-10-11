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

#import "MPOIdentificationViewController.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Crop.h"
#import "ImageHelper.h"
#import "MPOPersonGroupListController.h"
#import "PersonGroup.h"
#import "GroupPerson.h"
#import "PersonFace.h"
#import "MPOSimpleFaceCell.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>
#import "MBProgressHUD.h"

#define MAX_RESULT_COUNT 20

@interface MPOIdentificationViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource> {
    UITableView * _groupListView;
    UITableView * _resultListView;
    UICollectionView * _imageContainer;
    UIButton * _identifyBtn;
    NSMutableArray * _faces;
    NSMutableArray * _results;
}

@end

@implementation MPOIdentificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Identification";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"back";
    self.navigationItem.backBarButtonItem = backItem;
    [self buildMainUI];
    _results = [[NSMutableArray alloc] init];
    _faces = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_groupListView reloadData];
}

- (void)identify:(id)sender {
    NSIndexPath * indexPath = _groupListView.indexPathForSelectedRow;
    
    if (indexPath == nil) {
        [CommonUtil simpleDialog:@"please select a group"];
        return;
    }
    
    NSMutableArray *faceIds = [[NSMutableArray alloc] init];
    
    for (PersonFace *obj in _faces) {
        [faceIds addObject:obj.face.faceId];
    }
    
    PersonGroup * group = GLOBAL.groups[indexPath.row];
    //NSArray * results = [FaceSdkUtil getFaceIndentificationResultsFromPeople:groupPeople andFace:_faces[_selectedTargetIndex]];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Identifying faces";
    [HUD show: YES];
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    [client identifyWithLargePersonGroupId:group.groupId faceIds:faceIds maxNumberOfCandidates:group.people.count completionBlock:^(NSArray<MPOIdentifyResult *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Failed in Indentification" forController:self.navigationController];
            return;
        }
        [_results removeAllObjects];
        for (MPOIdentifyResult * idRestult in collection) {
            
            PersonFace * face = [self getFaceByFaceId:idRestult.faceId];
            
            for (MPOCandidate * candidate in idRestult.candidates) {
                GroupPerson * person = [self getPersonInGroup:group withPersonId:candidate.personId];
                [_results addObject:@{@"face" : face, @"personName": person.personName, @"confidence" : candidate.confidence}];
            }
        }
        
        if (collection.count == 0) {
            [CommonUtil showSimpleHUD:@"No result." forController:self.navigationController];
        }
        
        [_resultListView reloadData];
    }];
}


- (PersonFace*) getFaceByFaceId: (NSString*) faceId {
    for (PersonFace * face in _faces) {
        if ([face.face.faceId isEqualToString:faceId]) {
            return face;
        }
    }
    return nil;
}

- (GroupPerson*) getPersonInGroup:(PersonGroup*)group withPersonId: (NSString*) personId {
    for (GroupPerson * person in group.people) {
        if ([person.personId isEqualToString:personId]) {
            return person;
        }
    }
    return nil;
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

- (void)ManagePersonGroupAction:(id)sender {
    MPOPersonGroupListController * controller = [[MPOPersonGroupListController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildMainUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
    
    UILabel * label = [[UILabel alloc] init];
    label.text = @"Target Image:";
    label.left = 20;
    label.top = 20;
    [scrollView addSubview:label];
    [label sizeToFit];
    
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    UIButton * addFacesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addFacesBtn.titleLabel.numberOfLines = 0;
    [addFacesBtn setTitle:@"Select Image" forState:UIControlStateNormal];
    addFacesBtn.width = SCREEN_WIDTH / 3 - 20;
    addFacesBtn.height = addFacesBtn.width * 3 / 7;
    addFacesBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    addFacesBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addFacesBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [addFacesBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    label.width = addFacesBtn.width;
    label.adjustsFontSizeToFitWidth = YES;
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    _imageContainer = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _imageContainer.width = SCREEN_WIDTH - addFacesBtn.width - 20 - 10 - 20;
    _imageContainer.height = _imageContainer.width * 3 / 5;
    _imageContainer.top = 20;
    _imageContainer.right = SCREEN_WIDTH - 20;
    _imageContainer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_imageContainer registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _imageContainer.dataSource = self;
    _imageContainer.delegate = self;
    
    addFacesBtn.center = _imageContainer.center;
    addFacesBtn.left = 20;
    [scrollView addSubview:addFacesBtn];
    [scrollView addSubview:_imageContainer];
    
    label = [[UILabel alloc] init];
    label.text = @"Person group to use:";
    label.left = 20;
    label.top = _imageContainer.bottom + 10;
    [scrollView addSubview:label];
    [label sizeToFit];
    
    UIButton * manageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    manageBtn.titleLabel.numberOfLines = 0;
    [manageBtn setTitle:@"Manage Person Groups" forState:UIControlStateNormal];
    manageBtn.width = SCREEN_WIDTH / 3 - 20;
    manageBtn.height = manageBtn.width * 4 / 7;
    manageBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    manageBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [manageBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [manageBtn addTarget:self action:@selector(ManagePersonGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    label.width = manageBtn.width;
    label.adjustsFontSizeToFitWidth = YES;
    
    _groupListView = [[UITableView alloc] init];
    _groupListView.width = SCREEN_WIDTH - manageBtn.width - 20 - 10 - 20;
    _groupListView.height = _groupListView.width * 1 / 2;
    _groupListView.top = label.top;
    _groupListView.right = SCREEN_WIDTH - 20;
    _groupListView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    _groupListView.tableFooterView = [[UIView alloc] init];
    _groupListView.dataSource = self;
    _groupListView.delegate = self;
    
    manageBtn.center = _groupListView.center;
    manageBtn.left = 20;
    manageBtn.top += 10;
    [scrollView addSubview:manageBtn];
    [scrollView addSubview:_groupListView];
    
    label = [[UILabel alloc] init];
    label.text = @"Result:";
    [label sizeToFit];
    label.left = 20;
    label.top = _groupListView.bottom + 10;
    [scrollView addSubview:label];
    
    _resultListView = [[UITableView alloc] init];
    _resultListView.width = SCREEN_WIDTH - 20 - 20;
    _resultListView.height = _imageContainer.width * 5 / 7;
    _resultListView.top = label.bottom + 5;
    _resultListView.left = 20;
    _resultListView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    _resultListView.tableFooterView = [[UIView alloc] init];
    _resultListView.dataSource = self;
    _resultListView.delegate = self;
    _resultListView.allowsSelection = NO;
    [scrollView addSubview:_resultListView];
    
    _identifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _identifyBtn.height = addFacesBtn.height;
    _identifyBtn.width = SCREEN_WIDTH - 40;
    [_identifyBtn setTitle:@"Identify" forState:UIControlStateNormal];
    [_identifyBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    _identifyBtn.left = 20;
    _identifyBtn.top = _resultListView.bottom + 30;
    _identifyBtn.enabled = NO;
    [_identifyBtn addTarget:self action:@selector(identify:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:_identifyBtn];

    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _identifyBtn.bottom + 20);
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
    UIImage * image;
    if (info[UIImagePickerControllerEditedImage]) {
        image = info[UIImagePickerControllerEditedImage];
    } else {
        image = info[UIImagePickerControllerOriginalImage];
    }
    [image fixOrientation];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"detecting faces";
    [HUD show: YES];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    [client detectWithData:data returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"detection failed" forController:self.navigationController];
            return;
        }
        [_faces removeAllObjects];
        for (MPOFace *face in collection) {
            UIImage *croppedImage = [image crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
            PersonFace *obj = [[PersonFace alloc] init];
            obj.image = croppedImage;
            obj.face = face;
            [_faces addObject:obj];
        }
        _identifyBtn.enabled = NO;
        [_imageContainer reloadData];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _groupListView)
        return GLOBAL.groups.count;
    else
        return _results.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _groupListView)
        return 35;
    else
        return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * groupCellIdentifier = @"groupCell";
    static NSString * resultCellIdentifier = @"resultCell";
    if (tableView == _groupListView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:groupCellIdentifier];
        }
        cell.textLabel.text = ((PersonGroup*)GLOBAL.groups[indexPath.row]).groupName;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:resultCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupCellIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", _results[indexPath.row][@"personName"], _results[indexPath.row][@"confidence"]];
        cell.imageView.image = ((PersonFace*)_results[indexPath.row][@"face"]).image;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _groupListView && _faces.count > 0) {
        _identifyBtn.enabled = YES;
    }
}

#pragma mark -CollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _faces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPOSimpleFaceCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    cell.imageView.image = ((PersonFace*)_faces[indexPath.row]).image;
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
