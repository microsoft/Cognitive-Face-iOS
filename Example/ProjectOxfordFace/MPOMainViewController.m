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

#import "MPOMainViewController.h"
#import "MPODetectionViewController.h"
#import "MPOVerificationViewController.h"
#import "MPOGroupingViewController.h"
#import "MPOSimilarFaceViewController.h"
#import "MPOIdentificationViewController.h"

@interface MPOMainViewController () <UIActionSheetDelegate>

@end

@implementation MPOMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"back";
    self.navigationItem.backBarButtonItem = backItem;
    [self buildMainUI];
}

- (void)buildMainUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
    
    UIButton * detectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton * verificationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton * groupingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton * similarFaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton * identificationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UILabel * detectionLabel = [[UILabel alloc] init];
    UILabel * verificationLabel = [[UILabel alloc] init];
    UILabel * groupingLabel = [[UILabel alloc] init];
    UILabel * similarLabel = [[UILabel alloc] init];
    UILabel * identificationLabel = [[UILabel alloc] init];
    UILabel * descriptionLabel = [[UILabel alloc] init];
    
    NSString * detectionHint = @"Detect faces, face landmarks, pose, gender, and age.";
    NSString * verificationHint = @"Check if two faces belong to the same person.";
    NSString * groupingHint = @"Group faces based on similarity.";
    NSString * SimilarFaceHint = @"Search for similar-looking faces.";
    NSString * identificationHint = @"Identify the person from a face.";
    NSString * descriptionHint = @"Microsoft will receive the images you upload and may use them to improve Face API and related services. By submitting an image, you confirm that you have consent from everyone in it.";
    
    CGFloat btnWidth = SCREEN_WIDTH / 2 - 20;
    CGFloat btnHeight = btnWidth / 3;
    detectionBtn.width = verificationBtn.width = groupingBtn.width = similarFaceBtn.width = identificationBtn.width = btnWidth;
    detectionBtn.height = verificationBtn.height = groupingBtn.height = similarFaceBtn.height = identificationBtn.height = btnHeight;
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    [detectionBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [verificationBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [groupingBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [similarFaceBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [identificationBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [detectionBtn setTitle:@"DETECTION" forState:UIControlStateNormal];
    [verificationBtn setTitle:@"VERIFICATION" forState:UIControlStateNormal];
    [groupingBtn setTitle:@"GROUPING" forState:UIControlStateNormal];
    [similarFaceBtn setTitle:@"FIND SIMILAR FACES" forState:UIControlStateNormal];
    similarFaceBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [identificationBtn setTitle:@"IDENTIFICATION" forState:UIControlStateNormal];
    detectionBtn.right = verificationBtn.right = groupingBtn.right = similarFaceBtn.right = identificationBtn.right = scrollView.width - 20;
    
    detectionLabel.top = detectionBtn.top = 20;
    verificationLabel.top =  verificationBtn.top = detectionBtn.bottom + 20;
    groupingLabel.top = groupingBtn.top = verificationBtn.bottom + 20;
    similarLabel.top = similarFaceBtn.top = groupingBtn.bottom + 20;
    identificationLabel.top = identificationBtn.top = similarFaceBtn.bottom + 20;
    
    [detectionLabel setText:detectionHint];
    [verificationLabel setText:verificationHint];
    [groupingLabel setText:groupingHint];
    [similarLabel setText:SimilarFaceHint];
    [identificationLabel setText:identificationHint];
    [descriptionLabel setText:descriptionHint];
    
    descriptionLabel.numberOfLines = detectionLabel.numberOfLines = verificationLabel.numberOfLines = groupingLabel.numberOfLines = similarLabel.numberOfLines = identificationLabel.numberOfLines = 0;
    descriptionLabel.font = detectionLabel.font = verificationLabel.font = groupingLabel.font = similarLabel.font = identificationLabel.font = descriptionLabel.font = [UIFont systemFontOfSize:12];
    
    detectionLabel.width = verificationLabel.width = groupingLabel.width = similarLabel.width = identificationLabel.width = btnWidth - 10;
    detectionLabel.height = verificationLabel.height = groupingLabel.height = similarLabel.height = identificationLabel.height = btnHeight;
    detectionLabel.left = verificationLabel.left = groupingLabel.left = similarLabel.left = identificationLabel.left = 20;
    descriptionLabel.width = SCREEN_WIDTH - 20 * 2;
    [descriptionLabel sizeToFit];
    descriptionLabel.top = identificationBtn.bottom + 20;
    descriptionLabel.left = 20;
    
    [detectionBtn addTarget:self action:@selector(detectionAction:) forControlEvents:UIControlEventTouchUpInside];
    [verificationBtn addTarget:self action:@selector(verificationAction:) forControlEvents:UIControlEventTouchUpInside];
    [groupingBtn addTarget:self action:@selector(groupingAction:) forControlEvents:UIControlEventTouchUpInside];
    [similarFaceBtn addTarget:self action:@selector(similarFaceAction:) forControlEvents:UIControlEventTouchUpInside];
    [identificationBtn addTarget:self action:@selector(identificationAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:detectionBtn];
    [scrollView addSubview:verificationBtn];
    [scrollView addSubview:groupingBtn];
    [scrollView addSubview:similarFaceBtn];
    [scrollView addSubview:identificationBtn];
    [scrollView addSubview:detectionLabel];
    [scrollView addSubview:verificationLabel];
    [scrollView addSubview:groupingLabel];
    [scrollView addSubview:similarLabel];
    [scrollView addSubview:identificationLabel];
    [scrollView addSubview:descriptionLabel];
    
    scrollView.contentSize = CGSizeMake(scrollView.width, identificationBtn.bottom + 20);
    [self.view addSubview:scrollView];
    
    if ([ProjectOxfordFaceSubscriptionKey isEqualToString:@"Your Subscription Key"]) {
        detectionBtn.enabled = NO;
        verificationBtn.enabled = NO;
        groupingBtn.enabled = NO;
        similarFaceBtn.enabled = NO;
        identificationBtn.enabled = NO;
        [CommonUtil simpleDialog:@"You haven't input the subscription key. Please specify the subscription key in MPOAppDelegate.h"];
    }
}

- (void)detectionAction:(id)sender {
    UIViewController * controller = [[MPODetectionViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)verificationAction:(id)sender {
    UIActionSheet * verification_type_sheet = [[UIActionSheet alloc]
                                          initWithTitle:@"Choose verification type"
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"face and face", @"face and person",nil];
    [verification_type_sheet showInView:self.view];
}

- (void)groupingAction:(id)sender {
    UIViewController * controller = [[MPOGroupingViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)similarFaceAction:(id)sender {
    UIViewController * controller = [[MPOSimilarFaceViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)identificationAction:(id)sender {
    UIViewController * controller = [[MPOIdentificationViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIViewController * controller = [[MPOVerificationViewController alloc] initWithVerificationType:VerificationTypeFaceAndFace];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (buttonIndex == 1) {
        UIViewController * controller = [[MPOVerificationViewController alloc] initWithVerificationType:VerificationTypeFaceAndPerson];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
