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

#import "MPOFaceEmotion.h"

@implementation MPOFaceEmotion
-(instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.anger = dict[@"anger"];
        self.contempt = dict[@"contempt"];
        self.disgust = dict[@"disgust"];
        self.fear = dict[@"fear"];
        self.happiness = dict[@"happiness"];
        self.neutral = dict[@"neutral"];
        self.sadness = dict[@"sadness"];
        self.surprise = dict[@"surprise"];

        self.mostEmotion = @"anger";
        self.mostEmotionValue = self.anger;
        if ([self.contempt doubleValue] > [self.mostEmotionValue doubleValue])
        {
            self.mostEmotion = @"contempt";
            self.mostEmotionValue = self.contempt;
        }
        if ([self.disgust doubleValue] > [self.mostEmotionValue doubleValue])
        {
            self.mostEmotion = @"disgust";
            self.mostEmotionValue = self.disgust;
        }
        if ([self.fear doubleValue] > [self.mostEmotionValue doubleValue])
        {
            self.mostEmotion = @"fear";
            self.mostEmotionValue = self.fear;
        }
        if ([self.happiness doubleValue] > [self.mostEmotionValue doubleValue])
        {
            self.mostEmotion = @"happiness";
            self.mostEmotionValue = self.happiness;
        }
        if ([self.neutral doubleValue] > [self.mostEmotionValue doubleValue])
        {
            self.mostEmotion = @"neutral";
            self.mostEmotionValue = self.neutral;
        }
        if ([self.sadness doubleValue] > [self.mostEmotionValue doubleValue])
        {
            self.mostEmotion = @"sadness";
            self.mostEmotionValue = self.sadness;
        }
        if ([self.surprise doubleValue] > [self.mostEmotionValue doubleValue])
        {
            self.mostEmotion = @"surprise";
            self.mostEmotionValue = self.surprise;
        }
    }
    return self;
}
@end
