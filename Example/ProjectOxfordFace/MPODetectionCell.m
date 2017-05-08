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

#import "MPODetectionCell.h"

@implementation MPODetectionCell {
    UILabel * genderLabel;
    UILabel * ageLabel;
    UILabel * hairLabel;
    UILabel * facialHairLabel;
    UILabel * makeupLabel;
    UILabel * emotionLabel;
    UILabel * occlusionLabel;
    UILabel * exposureLabel;
    UILabel * headPoseLabel;
    UILabel * accessoriesLabel;
    UIImageView * faceImageView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        genderLabel.textColor = [UIColor grayColor];
        genderLabel.textAlignment = NSTextAlignmentLeft;
        genderLabel.font = [UIFont systemFontOfSize:12];
        ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        ageLabel.textColor = [UIColor grayColor];
        ageLabel.textAlignment = NSTextAlignmentLeft;
        ageLabel.font = [UIFont systemFontOfSize:12];
        hairLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        hairLabel.textColor = [UIColor grayColor];
        hairLabel.textAlignment = NSTextAlignmentLeft;
        hairLabel.font = [UIFont systemFontOfSize:12];
        facialHairLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        facialHairLabel.textColor = [UIColor grayColor];
        facialHairLabel.textAlignment = NSTextAlignmentLeft;
        facialHairLabel.font = [UIFont systemFontOfSize:12];
        makeupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        makeupLabel.textColor = [UIColor grayColor];
        makeupLabel.textAlignment = NSTextAlignmentLeft;
        makeupLabel.font = [UIFont systemFontOfSize:12];
        emotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        emotionLabel.textColor = [UIColor grayColor];
        emotionLabel.textAlignment = NSTextAlignmentLeft;
        emotionLabel.font = [UIFont systemFontOfSize:12];
        occlusionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        occlusionLabel.textColor = [UIColor grayColor];
        occlusionLabel.textAlignment = NSTextAlignmentLeft;
        occlusionLabel.font = [UIFont systemFontOfSize:12];
        exposureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        exposureLabel.textColor = [UIColor grayColor];
        exposureLabel.textAlignment = NSTextAlignmentLeft;
        exposureLabel.font = [UIFont systemFontOfSize:12];
        headPoseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        headPoseLabel.textColor = [UIColor grayColor];
        headPoseLabel.textAlignment = NSTextAlignmentLeft;
        headPoseLabel.font = [UIFont systemFontOfSize:12];
        accessoriesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        accessoriesLabel.textColor = [UIColor grayColor];
        accessoriesLabel.textAlignment = NSTextAlignmentLeft;
        accessoriesLabel.font = [UIFont systemFontOfSize:12];
        faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        faceImageView.center = self.center;
        faceImageView.top = 10;
        faceImageView.left = 10;
        faceImageView.clipsToBounds = YES;
        faceImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:genderLabel];
        [self.contentView addSubview:ageLabel];
        [self.contentView addSubview:hairLabel];
        [self.contentView addSubview:facialHairLabel];
        [self.contentView addSubview:makeupLabel];
        [self.contentView addSubview:emotionLabel];
        [self.contentView addSubview:occlusionLabel];
        [self.contentView addSubview:exposureLabel];
        [self.contentView addSubview:headPoseLabel];
        [self.contentView addSubview:accessoriesLabel];
        [self.contentView addSubview:faceImageView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (_genderText) {
        genderLabel.text = _genderText;
    }
    [genderLabel sizeToFit];
    genderLabel.left = faceImageView.right + 20;
    genderLabel.top = 10;
    if (_ageText) {
        ageLabel.text = _ageText;
    }
    [ageLabel sizeToFit];
    ageLabel.left = genderLabel.right + 10;
    ageLabel.top = 10;
    if (_hairText) {
        hairLabel.text = _hairText;
    }
    [hairLabel sizeToFit];
    hairLabel.left = faceImageView.right + 20;
    hairLabel.top = ageLabel.bottom + 5;
    if (_facialHairText) {
        facialHairLabel.text = _facialHairText;
    }
    [facialHairLabel sizeToFit];
    facialHairLabel.left = hairLabel.right + 10;
    facialHairLabel.top = ageLabel.bottom + 5;
    if (_makeupText) {
        makeupLabel.text = _makeupText;
    }
    [makeupLabel sizeToFit];
    makeupLabel.left = faceImageView.right + 20;
    makeupLabel.top = hairLabel.bottom + 5;
    if (_emotionText) {
        emotionLabel.text = _emotionText;
    }
    [emotionLabel sizeToFit];
    emotionLabel.left = makeupLabel.right + 10;
    emotionLabel.top = hairLabel.bottom + 5;
    if (_occlusionText)
    {
        occlusionLabel.text = _occlusionText;
    }
    [occlusionLabel sizeToFit];
    occlusionLabel.left = faceImageView.right + 20;
    occlusionLabel.top = makeupLabel.bottom + 5;
    if (_exposureText)
    {
        exposureLabel.text = _exposureText;
    }
    [exposureLabel sizeToFit];
    exposureLabel.left = occlusionLabel.right + 10;
    exposureLabel.top = makeupLabel.bottom + 5;
    if (_headPoseText) {
        headPoseLabel.text = _headPoseText;
    }
    [headPoseLabel sizeToFit];
    headPoseLabel.left = faceImageView.right + 20;
    headPoseLabel.top = occlusionLabel.bottom + 5;
    if (_accessoriesText) {
        accessoriesLabel.text = _accessoriesText;
    }
    [accessoriesLabel sizeToFit];
    accessoriesLabel.left = faceImageView.right + 20;
    accessoriesLabel.top = headPoseLabel.bottom + 5;
    if (_faceImage) {
        faceImageView.image = _faceImage;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
