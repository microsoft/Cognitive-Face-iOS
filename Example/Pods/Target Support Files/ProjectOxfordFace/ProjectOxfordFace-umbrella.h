#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MPOAddPersistedFaceResult.h"
#import "MPOCandidate.h"
#import "MPOCreatePersonResult.h"
#import "MPOFace.h"
#import "MPOFaceAttributes.h"
#import "MPOFaceFeatureCoordinate.h"
#import "MPOFaceHeadPose.h"
#import "MPOFaceLandmarks.h"
#import "MPOFaceList.h"
#import "MPOFaceListMetadata.h"
#import "MPOFaceMetadata.h"
#import "MPOFaceRectangle.h"
#import "MPOFaceSDK.h"
#import "MPOFaceServiceClient.h"
#import "MPOFacialHair.h"
#import "MPOGroupResult.h"
#import "MPOIdentifyResult.h"
#import "MPOPerson.h"
#import "MPOPersonFace.h"
#import "MPOPersonGroup.h"
#import "MPOSimilarFace.h"
#import "MPOTrainingStatus.h"
#import "MPOVerifyResult.h"

FOUNDATION_EXPORT double ProjectOxfordFaceVersionNumber;
FOUNDATION_EXPORT const unsigned char ProjectOxfordFaceVersionString[];

