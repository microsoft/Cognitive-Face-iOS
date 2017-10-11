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

#import "MPOAddPersonFaceController.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>
#import "MBProgressHUD.h"
#import "MPOSimpleFaceCell.h"
#import "PersonFace.h"
#import "CommonUtil.h"

@interface MPOAddPersonFaceController () <UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate> {
    UICollectionView *_facescollectionView;
    NSInteger _selectedIndex;
}

@end

@implementation MPOAddPersonFaceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add face";
    [self buildMainUI];
    _selectedIndex = -1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)buildMainUI {
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel * label = [[UILabel alloc] init];
    label.text = @"Select faces to add to person:";
    label.font = [UIFont systemFontOfSize:14];
    label.left = 10;
    label.top = 30;
    [label sizeToFit];
    [self.view addSubview:label];
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
    _facescollectionView  =[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _facescollectionView.width = SCREEN_WIDTH - 20;
    _facescollectionView.height = self.view.height - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - label.bottom - 40;
    _facescollectionView.left = 10;
    
    _facescollectionView.top = label.bottom + 20;
    _facescollectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_facescollectionView registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _facescollectionView.dataSource = self;
    _facescollectionView.delegate = self;
    [self.view addSubview:_facescollectionView];
    [_facescollectionView reloadData];
}

- (void)addFace:(PersonFace*)face {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Adding faces";
    [HUD show: YES];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    NSData *data = UIImageJPEGRepresentation(self.image, 0.8);
    
    [client addPersonFaceWithLargePersonGroupId:self.group.groupId personId:self.person.personId data:data userData:nil faceRectangle:face.face.faceRectangle completionBlock:^(MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Failed in adding face" forController:self.navigationController];
            return;
        }
        [CommonUtil showSimpleHUD:@"Face added to this person" forController:self.navigationController];
        
        face.faceId = addPersistedFaceResult.persistedFaceId;
        [self.detectedFaces removeObject:face];
        [self.person.faces addObject:face];
        [_facescollectionView reloadData];
        *self.needTraining = YES;
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.detectedFaces == nil) {
        return 0;
    }
    return self.detectedFaces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MPOSimpleFaceCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    [cell.imageView setImage:[(PersonFace*)self.detectedFaces[indexPath.row] image]];
    cell.imageView.tag = indexPath.row;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_facescollectionView.width / 3 - 10, _facescollectionView.width / 3 - 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hint"
                                                        message:@"Do you want to add this face?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [alertView show];
    _selectedIndex = indexPath.row;
}

#pragma mark - UIAlertViewDelegate
- (void)alertViewCancel:(UIAlertView *)alertView {
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self addFace:self.detectedFaces[_selectedIndex]];
    }
}

@end
