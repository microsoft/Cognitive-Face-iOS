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

#import "MPOPersonGroupListController.h"
#import "MPOPersonGroupController.h"

@interface MPOPersonGroupListController () <UITableViewDelegate, UITableViewDataSource> {
    UITableView * _groupListView;
}

@end

@implementation MPOPersonGroupListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildMainUI];
    self.navigationItem.title = @"Person Group List";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"back";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_groupListView reloadData];
}

- (void)addGroupAction: (id)sender {
    MPOPersonGroupController * controller = [[MPOPersonGroupController alloc] init];
    controller.isForVarification = self.isForVarification;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)buildMainUI {
    self.view.backgroundColor = [UIColor whiteColor];
    _groupListView = [[UITableView alloc] init];
    _groupListView.width = SCREEN_WIDTH - 20 - 20;
    _groupListView.height = (self.view.height - NAVIGATION_BAR_HEIGHT) * 3 / 4;
    _groupListView.top = 20;
    _groupListView.left = 20;
    _groupListView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [self.view addSubview:_groupListView];
    _groupListView.delegate = self;
    _groupListView.dataSource = self;
    _groupListView.tableFooterView = [[UIView alloc] init];
    
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    UIButton * addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.height = (self.view.height - NAVIGATION_BAR_HEIGHT) *3 / 32;
    addBtn.width = SCREEN_WIDTH - 40;
    [addBtn setTitle:@"Add Group" forState:UIControlStateNormal];
    [addBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    addBtn.left = 20;
    addBtn.top = _groupListView.bottom + 20;
    [addBtn addTarget:self action:@selector(addGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:addBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return GLOBAL.groups.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * showUserInfoCellIdentifier = @"ShowUserInfoCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:showUserInfoCellIdentifier];
    }
    cell.textLabel.text = ((PersonGroup*)GLOBAL.groups[indexPath.row]).groupName;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MPOPersonGroupController * controller = [[MPOPersonGroupController alloc] initWithGroup:GLOBAL.groups[indexPath.row]];
    controller.isForVarification = YES;
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
