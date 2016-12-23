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
    UILabel * ageLabel;
    UILabel * genderLabel;
    UILabel * smileLabel;
    UILabel * glassesLabel;
    UILabel * emotionLabel;
    UILabel * moustacheLabel;
    UILabel * headPoseLabel;
    UIImageView * faceImageView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        ageLabel.textColor = [UIColor grayColor];
        ageLabel.textAlignment = NSTextAlignmentLeft;
        ageLabel.font = [UIFont systemFontOfSize:14];
        genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        genderLabel.textColor = [UIColor grayColor];
        genderLabel.textAlignment = NSTextAlignmentLeft;
        genderLabel.font = [UIFont systemFontOfSize:14];
        smileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        smileLabel.textColor = [UIColor grayColor];
        smileLabel.textAlignment = NSTextAlignmentLeft;
        smileLabel.font = [UIFont systemFontOfSize:14];
        glassesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        glassesLabel.textColor = [UIColor grayColor];
        glassesLabel.textAlignment = NSTextAlignmentLeft;
        glassesLabel.font = [UIFont systemFontOfSize:14];
        emotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        emotionLabel.textColor = [UIColor grayColor];
        emotionLabel.textAlignment = NSTextAlignmentLeft;
        emotionLabel.font = [UIFont systemFontOfSize:14];
        moustacheLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        moustacheLabel.textColor = [UIColor grayColor];
        moustacheLabel.textAlignment = NSTextAlignmentLeft;
        moustacheLabel.font = [UIFont systemFontOfSize:14];
        headPoseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        headPoseLabel.textColor = [UIColor grayColor];
        headPoseLabel.textAlignment = NSTextAlignmentLeft;
        headPoseLabel.font = [UIFont systemFontOfSize:12];
        faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        faceImageView.center = self.center;
        faceImageView.top = 10;
        faceImageView.left = 10;
        faceImageView.clipsToBounds = YES;
        faceImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:ageLabel];
        [self.contentView addSubview:genderLabel];
        [self.contentView addSubview:smileLabel];
        [self.contentView addSubview:glassesLabel];
        [self.contentView addSubview:emotionLabel];
        [self.contentView addSubview:moustacheLabel];
        [self.contentView addSubview:headPoseLabel];
        [self.contentView addSubview:faceImageView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (_ageText) {
        ageLabel.text = _ageText;
    }
    [ageLabel sizeToFit];
    ageLabel.left = faceImageView.right + 20;
    ageLabel.top = 10;
    if (_genderText) {
        genderLabel.text = _genderText;
    }
    [genderLabel sizeToFit];
    genderLabel.left = faceImageView.right + 20;
    genderLabel.top = ageLabel.bottom + 5;
    if (_smileText) {
        smileLabel.text = _smileText;
    }
    [smileLabel sizeToFit];
    smileLabel.left = faceImageView.right + 20;
    smileLabel.top = genderLabel.bottom + 5;
    if (_glassesText) {
        glassesLabel.text = _glassesText;
    }
    [glassesLabel sizeToFit];
    glassesLabel.left = faceImageView.right + 20;
    glassesLabel.top = smileLabel.bottom + 5;
    if (_emotionText) {
        emotionLabel.text = _emotionText;
    }
    [emotionLabel sizeToFit];
    emotionLabel.left = faceImageView.right + 20;
    emotionLabel.top = glassesLabel.bottom + 5;
    if (_facialHairText) {
        moustacheLabel.text = _facialHairText;
    }
    [moustacheLabel sizeToFit];
    moustacheLabel.left = faceImageView.right + 20;
    moustacheLabel.top = emotionLabel.bottom + 5;
    if (_headPoseText) {
        headPoseLabel.text = _headPoseText;
    }
    [headPoseLabel sizeToFit];
    headPoseLabel.left = faceImageView.right + 20;
    headPoseLabel.top = moustacheLabel.bottom + 5;
    if (_faceImage) {
        faceImageView.image = _faceImage;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
