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

#import "MPOPersonGroupController.h"
#import "UIViewController+DismissKeyboard.h"
#import "MPOPersonFacesController.h"
#import "PersonGroup.h"
#import "MPOPersonFaceCell.h"
#import "PersonFace.h"
#import "MBProgressHUD.h"
#import "CommonUtil.h"
#import "MPOVerificationViewController.h"

#define INTENSION_SAVE_GROUP   0
#define INTENSION_ADD_PERSON   1

@interface MPOPersonGroupController () <UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate> {
    UITextField * _groupNameField;
    UICollectionView *_facesCollectionView;
    
    NSInteger _selectedPersonIndex;
    BOOL _shouldExit;
    int _intension;
}

@end

@implementation MPOPersonGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildMainUI];
    self.navigationItem.title = @"Person Group";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"back";
    self.needTraining = (BOOL*)malloc(sizeof(BOOL));
    *self.needTraining = NO;
    self.navigationItem.backBarButtonItem = backItem;
    [self setupForDismissKeyboard];
}

- (instancetype) initWithGroup: (PersonGroup*) group {
    self = [super init];
    self.group = group;
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_facesCollectionView reloadData];
}

- (void)longPressAction: (UIGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _selectedPersonIndex = gestureRecognizer.view.tag;
        UIActionSheet * confirm_sheet = [[UIActionSheet alloc]
                                         initWithTitle:@"Do you want to remove all of this person's faces?"
                                         delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                         otherButtonTitles:@"Yes",nil];
        confirm_sheet.tag = 0;
        [confirm_sheet showInView:self.view];
    }
}

- (void)addPerson: (id)sender {
    if (!self.group && _groupNameField.text.length == 0) {
        [CommonUtil simpleDialog:@"please input the group name"];
        return;
    }
    if (!self.group) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hint"
                                                            message:@"Do you want to create this new group?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        _intension = INTENSION_ADD_PERSON;
        alertView.tag = 0;
        [alertView show];
        return;
    }
    MPOPersonFacesController * controller = [[MPOPersonFacesController alloc] initWithGroup:self.group];
    controller.needTraining = self.needTraining;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)save: (id)sender {
    if (_groupNameField.text.length == 0) {
        [CommonUtil simpleDialog:@"please input the group name"];
        return;
    }
    
    if (!self.group) {
        [self createNewGroup];
    } else {
        MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.labelText = @"saving group";
        [HUD show: YES];
        
        [client updateLargePersonGroup:self.group.groupId name:_groupNameField.text userData:nil completionBlock:^(NSError *error) {
            [HUD removeFromSuperview];
            if (error) {
                [CommonUtil simpleDialog:@"Failed in updating group."];
                return;
            }
            self.group.groupName = _groupNameField.text;
            _shouldExit = NO;
            [self trainGroup];
        }];
    }
}

- (void)buildMainUI {
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel * label = [[UILabel alloc] init];
    label.text = @"Person group name:";
    label.font = [UIFont systemFontOfSize:14];
    label.left = 10;
    label.top = 30;
    [label sizeToFit];
    [self.view addSubview:label];
    _groupNameField = [[UITextField alloc] init];
    _groupNameField.width = SCREEN_WIDTH - label.right - 20;
    _groupNameField.height = label.height * 2;
    _groupNameField.center = label.center;
    _groupNameField.left = label.right + 10;
    _groupNameField.borderStyle = UITextBorderStyleLine;
    if (self.group)
        _groupNameField.text = self.group.groupName;
    [self.view addSubview:_groupNameField];
    
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
    [addBtn setTitle:@"Add Person" forState:UIControlStateNormal];
    [saveBtn setTitle:@"Save" forState:UIControlStateNormal];
    [addBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addPerson:) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    [self.view addSubview:addBtn];
    
    label = [[UILabel alloc] init];
    label.text = @"- Long press to delete.";
    label.font = [UIFont systemFontOfSize:12];
    [label sizeToFit];
    label.bottom = addBtn.top - 10;
    label.left = addBtn.left;
    CGFloat temp = label.top;
    [self.view addSubview:label];
    label = [[UILabel alloc] init];
    label.text = @"- Tap on a person to edit";
    label.font = [UIFont systemFontOfSize:12];
    [label sizeToFit];
    label.left = addBtn.left;
    label.bottom = temp - 2;
    [self.view addSubview:label];
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
    _facesCollectionView =[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _facesCollectionView.width = SCREEN_WIDTH - 20;
    _facesCollectionView.height = label.top - _groupNameField.bottom - 30;
    _facesCollectionView.left = 10;
    _facesCollectionView.top = _groupNameField.bottom + 10;
    _facesCollectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_facesCollectionView registerNib:[UINib nibWithNibName:@"MPOPersonFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _facesCollectionView.dataSource = self;
    _facesCollectionView.delegate = self;
    [self.view addSubview:_facesCollectionView];
}

- (void)createNewGroup {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Creating group";
    [HUD show: YES];
    
    NSString * uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
    
    [client createLargePersonGroup:uuid name:_groupNameField.text userData:nil completionBlock:^(NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil simpleDialog:@"Failed in creating group."];
            NSLog(@"%@", error);
            return;
        }
        self.group = [[PersonGroup alloc] init];
        self.group.groupName = _groupNameField.text;
        self.group.groupId = uuid;
        [GLOBAL.groups addObject:self.group];
        if (_intension == INTENSION_ADD_PERSON) {
            MPOPersonFacesController * controller = [[MPOPersonFacesController alloc] initWithGroup:self.group];
            controller.needTraining = self.needTraining;
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [CommonUtil showSimpleHUD:@"Group created" forController:self.navigationController];
        }
    }];
}

- (void)trainGroup {
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Training group";
    [HUD show: YES];
    
    [client trainLargePersonGroup:self.group.groupId completionBlock:^(NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Failed in training group." forController:self.navigationController];
        } else {
            [CommonUtil showSimpleHUD:@"This group is trained." forController:self.navigationController];
        }
        if (_shouldExit) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (BOOL)navigationShouldPopOnBackButton {
    if (*self.needTraining) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hint"
                                                            message:@"Do you want to train this group?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        alertView.tag = 1;
        _shouldExit = YES;
        [alertView show];
        return NO;
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertViewCancel:(UIAlertView *)alertView {
    if (alertView.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            [self createNewGroup];
        }
    } else {
        if (buttonIndex == 1) {
            [self trainGroup];
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.labelText = @"Deleting this person";
            [HUD show: YES];
            
            [client deletePersonWithLargePersonGroupId:self.group.groupId personId:((GroupPerson*)self.group.people[_selectedPersonIndex]).personId completionBlock:^(NSError *error) {
                [HUD removeFromSuperview];
                if (error) {
                    [CommonUtil showSimpleHUD:@"Failed in deleting this person" forController:self.navigationController];
                    return;
                }
                [self.group.people removeObjectAtIndex:_selectedPersonIndex];
                [_facesCollectionView reloadData];
            }];
        }
    } else {
        if (buttonIndex == 0) {
            UIViewController * verificationController = nil;
            for (UIViewController * controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[MPOVerificationViewController class]]) {
                    verificationController = controller;
                    [(MPOVerificationViewController *)controller didSelectPerson: (GroupPerson*)self.group.people[_selectedPersonIndex] inGroup:self.group];
                }
            }
            [self.navigationController popToViewController:verificationController animated:YES];
        } else if (buttonIndex == 1) {
            MPOPersonFacesController * controller = [[MPOPersonFacesController alloc] initWithGroup:self.group andPerson:self.group.people[_selectedPersonIndex]];
            controller.needTraining = self.needTraining;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark -CollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.group ? self.group.people.count : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[(GroupPerson*)self.group.people[section] faces] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPOPersonFaceCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    GroupPerson * person = self.group.people[indexPath.section];
    [cell.faceImageView setImage: [(PersonFace*)person.faces[indexPath.row] image]];
    cell.faceImageView.tag = indexPath.section;
    [cell.personName setText:person.personName];
    cell.faceImageView.userInteractionEnabled = YES;
    if (cell.faceImageView.gestureRecognizers.count == 0) {
        [cell.faceImageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_facesCollectionView.width / 3 - 10, (_facesCollectionView.width / 3 - 10) * 4 / 3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedPersonIndex = indexPath.section;
    if (self.isForVarification) {
        UIActionSheet * use_person_sheet = [[UIActionSheet alloc]
                                         initWithTitle:@"Hint"
                                         delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                         otherButtonTitles:@"Use this person for verification", @"Edit this person", nil];
        use_person_sheet.tag = 1;
        [use_person_sheet showInView:self.view];
        return;
    }
    MPOPersonFacesController * controller = [[MPOPersonFacesController alloc] initWithGroup:self.group andPerson:self.group.people[indexPath.section]];
    controller.needTraining = self.needTraining;
    [self.navigationController pushViewController:controller animated:YES];
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
