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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPOFaceSDK.h"
#import "MPOPersonGroup.h"
#import "MPOTrainingStatus.h"
#import "MPOCreatePersonResult.h"
#import "MPOPerson.h"
#import "MPOPersonFace.h"
#import "MPOAddPersistedFaceResult.h"
#import "MPOFaceList.h"
#import "MPOFaceListMetadata.h"
#import "MPOLargeFaceList.h"
#import "MPOLargePersonGroup.h"

typedef enum {
    MPOFaceAttributeTypeAge = 1,
    MPOFaceAttributeTypeGender,
    MPOFaceAttributeTypeSmile,
    MPOFaceAttributeTypeGlasses,
    MPOFaceAttributeTypeFacialHair,
    MPOFaceAttributeTypeHeadPose,
    MPOFaceAttributeTypeEmotion,
    MPOFaceAttributeTypeHair,
    MPOFaceAttributeTypeMakeup,
    MPOFaceAttributeTypeOcclusion,
    MPOFaceAttributeTypeAccessories,
    MPOFaceAttributeTypeBlur,
    MPOFaceAttributeTypeExposure,
    MPOFaceAttributeTypeNoise,
} MPOFaceAttributeType;

typedef enum {
    MPOSimilarFaceSearchingModeMatchFace = 1,
    MPOSimilarFaceSearchingModeMatchPerson
} MPOSimilarFaceSearchingMode;

typedef void (^MPOCompletionBlock)(NSError *error);
typedef void (^MPOFaceArrayCompletionBlock)(NSArray<MPOFace *> *collection, NSError *error);
typedef void (^MPOSimilarFaceArrayCompletionBlock)(NSArray<MPOSimilarFace *> *collection, NSError *error);
typedef void (^MPOSimilarPersistedFaceArrayCompletionBlock)(NSArray<MPOSimilarPersistedFace *> *collection, NSError *error);
typedef void (^MPOIdentifyResultArrayCompletionBlock)(NSArray<MPOIdentifyResult *> *collection, NSError *error);
typedef void (^MPOPersonGroupArrayCompletionBlock)(NSArray<MPOPersonGroup *> *collection, NSError *error);
typedef void (^MPOLargePersonGroupArrayCompletionBlock)(NSArray<MPOLargePersonGroup *> *collection, NSError *error);
typedef void (^MPOPersonArrayCompletionBlock)(NSArray<MPOPerson *> *collection, NSError *error);
typedef void (^MPOFaceListMetadataArrayCompletionBlock)(NSArray<MPOFaceListMetadata *> *collection, NSError *error);
typedef void (^MPOLargeFaceListArrayCompletionBlock)(NSArray<MPOLargeFaceList *> *collection, NSError *error);
typedef void (^MPOFaceMetadataArrayCompletionBlock)(NSArray<MPOFaceMetadata *> *collection, NSError *error);

@interface MPOFaceServiceClient : NSObject

/**
 *  Creates an instance of MPOFaceServiceClient with default endpoint
 *  @param key subscription key to use face api
 *  @return MPOFaceServiceClient
 */
- (id)initWithSubscriptionKey:(NSString *)key;

/**
 *  Creates an instance of MPOFaceServiceClient with specific endpoint and subscription key
 *  @param endpoint the endpoint to use the face api
 *  @param key the subscription key to use the face api
 *  @return MPOFaceServiceClient
 */
- (id)initWithEndpointAndSubscriptionKey:(NSString *)endpoint key:(NSString *)key;

#pragma mark Face Detection APIs

/**
 *  Detects faces in an URL image
 *  @param url                  url
 *  @param returnFaceId         if set to true, return faceId
 *  @param returnFaceLandmarks  if set to true, return face landmarks
 *  @param returnFaceAttributes return face attributes
 *  @param completion           completion handler
 *  @return detected faces, NSArray containing MPOFace objects
 */
- (NSURLSessionDataTask *)detectWithUrl:(NSString *)url returnFaceId:(BOOL)returnFaceId returnFaceLandmarks:(BOOL)returnFaceLandmarks returnFaceAttributes:(NSArray *)returnFaceAttributes completionBlock:(MPOFaceArrayCompletionBlock)completion;

/**
 *  Detects faces in an data stream
 *  @param data                 data
 *  @param returnFaceId         if set to true, return faceId
 *  @param returnFaceLandmarks  if set to true, return face landmarks
 *  @param returnFaceAttributes return face attributes
 *  @param completion           completion handler
 *  @return detected faces, NSArray containing MPOFace objects
 */
- (NSURLSessionDataTask *)detectWithData:(NSData *)data returnFaceId:(BOOL)returnFaceId returnFaceLandmarks:(BOOL)returnFaceLandmarks returnFaceAttributes:(NSArray *)returnFaceAttributes completionBlock:(MPOFaceArrayCompletionBlock)completion;

/**
 *  Verifies whether the specified two faces belong to the same person.
 *  @param faceId1    first face Id
 *  @param faceId2    second face Id
 *  @param completion completionHandler
 *  @return the verification result, MPOVerifyResult
 */
- (NSURLSessionDataTask *)verifyWithFirstFaceId:(NSString *)faceId1 faceId2:(NSString *)faceId2 completionBlock:(void (^) (MPOVerifyResult *verifyResult, NSError *error))completion;

/**
 *  Verifies whether the specified face belong to the specified person.
 *  @param faceId           the face Id
 *  @param personId         the person Id
 *  @param personGroupId    the person group id
 *  @param completion completionHandler
 *  @return the verification result, MPOVerifyResult
 */
- (NSURLSessionDataTask *)verifyWithFaceId:(NSString *)faceId personId:(NSString *)personId personGroupId:(NSString *)personGroupId completionBlock:(void (^) (MPOVerifyResult *verifyResult, NSError *error))completion;

/**
 *  Verifies whether the specified face belong to the specified person in large person group.
 *  @param faceId                the face Id
 *  @param personId              the person Id
 *  @param largePersonGroupId    the large person group id
 *  @param completion completionHandler
 *  @return the verification result, MPOVerifyResult
 */
- (NSURLSessionDataTask *)verifyWithFaceId:(NSString *)faceId personId:(NSString *)personId largePersonGroupId:(NSString *)largePersonGroupId completionBlock:(void (^) (MPOVerifyResult *verifyResult, NSError *error))completion;

/**
 *  Finds the similar faces.
 *  @param faceId     The face identifier.
 *  @param faceIds    The list of face identifiers.
 *  @param completion completionHandler
 *  @return the similar faces, NSArray containg MPOSimilarFace
 */
- (NSURLSessionDataTask *)findSimilarWithFaceId:(NSString *)faceId faceIds:(NSArray *)faceIds completionBlock:(MPOSimilarFaceArrayCompletionBlock)completion;

/**
 *  Finds the similar faces.
 *  @param faceId     The face identifier.
 *  @param faceListId The face list identifier.
 *  @param completion completionHandler
 *  @return the similar faces, NSArray containg MPOSimilarFace
 */
- (NSURLSessionDataTask *)findSimilarWithFaceId:(NSString *)faceId faceListId:(NSString *)faceListId completionBlock:(MPOSimilarPersistedFaceArrayCompletionBlock)completion;

/**
 *  Finds the similar faces.
 *  @param faceId                     The face identifier.
 *  @param faceIds                    The list of face identifiers.
 *  @param maxNumOfCandidatesReturned The number of top similar faces returned. The valid range is [1, 1000]. It defaults to 20.
 *  @param mode                       Similar face searching mode. It can be "matchPerson" or "matchFace". It defaults to "matchPerson".
 *  @param completion                 completionHandler
 *  @return the similar faces, NSArray containg MPOSimilarFace
 */
- (NSURLSessionDataTask *)findSimilarWithFaceId:(NSString *)faceId faceIds:(NSArray *)faceIds maxNumOfCandidatesReturned:(NSInteger)maxNumOfCandidatesReturned mode:(MPOSimilarFaceSearchingMode)mode completionBlock:(MPOSimilarFaceArrayCompletionBlock)completion;

/**
 *  Finds the similar faces.
 *  @param faceId                     The face identifier.
 *  @param faceListId                 The face list identifier.
 *  @param maxNumOfCandidatesReturned The number of top similar faces returned. The valid range is [1, 1000]. It defaults to 20.
 *  @param mode                       Similar face searching mode. It can be "matchPerson" or "matchFace". It defaults to "matchPerson".
 *  @param completion                 completionHandler
 *  @return the similar faces, NSArray containg MPOSimilarFace
 */
- (NSURLSessionDataTask *)findSimilarWithFaceId:(NSString *)faceId faceListId:(NSString *)faceListId maxNumOfCandidatesReturned:(NSInteger)maxNumOfCandidatesReturned mode:(MPOSimilarFaceSearchingMode)mode completionBlock:(MPOSimilarPersistedFaceArrayCompletionBlock)completion;

/**
 *  Finds the similar faces.
 *  @param faceId          The face identifier.
 *  @param largeFaceListId The large face list identifier.
 *  @param completion completionHandler
 *  @return the similar faces, NSArray containg MPOSimilarFace
 */
- (NSURLSessionDataTask *)findSimilarWithFaceId:(NSString *)faceId largeFaceListId:(NSString *)largeFaceListId completionBlock:(MPOSimilarPersistedFaceArrayCompletionBlock)completion;

/**
 *  Finds the similar faces.
 *  @param faceId                     The face identifier.
 *  @param largeFaceListId            The large face list identifier.
 *  @param maxNumOfCandidatesReturned The number of top similar faces returned. The valid range is [1, 1000]. It defaults to 20.
 *  @param mode                       Similar face searching mode. It can be "matchPerson" or "matchFace". It defaults to "matchPerson".
 *  @param completion                 completionHandler
 *  @return the similar faces, NSArray containg MPOSimilarPersistedFace
 */
- (NSURLSessionDataTask *)findSimilarWithFaceId:(NSString *)faceId largeFaceListId:(NSString *)largeFaceListId maxNumOfCandidatesReturned:(NSInteger)maxNumOfCandidatesReturned mode:(MPOSimilarFaceSearchingMode)mode completionBlock:(MPOSimilarPersistedFaceArrayCompletionBlock)completion;

/**
 *  Groups the faces.
 *  @param faceIds    the face ids.
 *  @param completion completionHandler
 *  @return group result, MPOGroupResult
 */
- (NSURLSessionDataTask *)groupWithFaceIds:(NSArray *)faceIds completionBlock:(void (^) (MPOGroupResult *groupResult, NSError *error))completion;

/**
 *  Identities the faces in a given person group with a default confidence threshold.
 *  @param personGroupId         the person group id
 *  @param faceIds               the face ids
 *  @param maxNumberOfCandidates The maximum number of candidates returned for each face.
 *  @param completion            completionHandler
 *  @return the identification results, NSArray containing MPOIdentifyResult objects
 */
- (NSURLSessionDataTask *)identifyWithPersonGroupId:(NSString *)personGroupId faceIds:(NSArray *)faceIds maxNumberOfCandidates:(NSInteger)maxNumberOfCandidates completionBlock:(MPOIdentifyResultArrayCompletionBlock)completion;

/**
 *  Identities the faces in a given person group.
 *  @param personGroupId         the person group id
 *  @param faceIds               the face ids
 *  @param maxNumberOfCandidates The maximum number of candidates returned for each face.
 *  @param confidenceThreshold   The confidence threshold of identification.
 *  @param completion            completionHandler
 *  @return the identification results, NSArray containing MPOIdentifyResult objects
 */
- (NSURLSessionDataTask *)identifyWithPersonGroupId:(NSString *)personGroupId faceIds:(NSArray *)faceIds maxNumberOfCandidates:(NSInteger)maxNumberOfCandidates confidenceThreshold:(CGFloat)confidenceThreshold completionBlock:(MPOIdentifyResultArrayCompletionBlock)completion;
/**
 *  Identities the faces in a given large person group with a default confidence threshold.
 *  @param largePersonGroupId    the large person group id
 *  @param faceIds               the face ids
 *  @param maxNumberOfCandidates The maximum number of candidates returned for each face.
 *  @param completion            completionHandler
 *  @return the identification results, NSArray containing MPOIdentifyResult objects
 */
- (NSURLSessionDataTask *)identifyWithLargePersonGroupId:(NSString *)largePersonGroupId faceIds:(NSArray *)faceIds maxNumberOfCandidates:(NSInteger)maxNumberOfCandidates completionBlock:(MPOIdentifyResultArrayCompletionBlock)completion;

/**
 *  Identities the faces in a given large person group.
 *  @param largePersonGroupId    the large person group id
 *  @param faceIds               the face ids
 *  @param maxNumberOfCandidates The maximum number of candidates returned for each face.
 *  @param confidenceThreshold   The confidence threshold of identification.
 *  @param completion            completionHandler
 *  @return the identification results, NSArray containing MPOIdentifyResult objects
 */
- (NSURLSessionDataTask *)identifyWithLargePersonGroupId:(NSString *)largePersonGroupId faceIds:(NSArray *)faceIds maxNumberOfCandidates:(NSInteger)maxNumberOfCandidates confidenceThreshold:(CGFloat)confidenceThreshold completionBlock:(MPOIdentifyResultArrayCompletionBlock)completion;

#pragma mark Person Groups APIs

/**
 *  Creates the person group
 *  @param personGroupId the group identifier.
 *  @param name          the name of the person group
 *  @param userData      the user data
 *  @param completion    completionHandler
 *  @return boolean representing success or failure of creation
 */
- (NSURLSessionDataTask *)createPersonGroupWithId:(NSString *)personGroupId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets a person group
 *  @param personGroupId the person group id
 *  @param completion    completionHandler
 *  @return The person group, MPOPersonGroup
 */
- (NSURLSessionDataTask *)getPersonGroupWithPersonGroupId:(NSString *)personGroupId completionBlock:(void (^) (MPOPersonGroup *personGroup, NSError *error))completion;

/**
 *  Updates a person group.
 *  @param personGroupId the person group id
 *  @param name          the name
 *  @param userData      the user data
 *  @param completion    completionHandler
 *  @return boolean representing success or failure of update
 */
- (NSURLSessionDataTask *)updatePersonGroupWithPersonGroupId:(NSString *)personGroupId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Deletes a person group.
 *  @param personGroupId the person group id
 *  @param completion    completionHandler
 *  @return boolean representing success or failure of deletion
 */
- (NSURLSessionDataTask *)deletePersonGroupWithPersonGroupId:(NSString *)personGroupId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets first 1000 person groups
 *  @param completion completionHandler
 *  @return person group entities, NSArray of MPOPersonGroup objects
 */
- (NSURLSessionDataTask *)getPersonGroupsWithCompletion:(MPOPersonGroupArrayCompletionBlock)completion NS_DEPRECATED_IOS(7.0, 7.0);

/**
 *  Lists first 1000 person groups
 *  @param completion completionHandler
 *  @return person group entities, NSArray of MPOPersonGroup objects
 */
- (NSURLSessionDataTask *)listPersonGroupsWithCompletion:(MPOPersonGroupArrayCompletionBlock)completion;

/**
 *  Lists a certain number of person groups starting from a certain person group identifier
 *  @start List person groups from the least personGroupId greater than the "start". It contains no more than 64 characters. Default is empty.
 *  @top   The number of person groups to list, ranging in [1, 1000]. Default is 1000.
 *  @param completion completionHandler
 *  @return person group entities, NSArray of MPOPersonGroup objects
 */
- (NSURLSessionDataTask *)listPersonGroupsWithStart:(NSString*)start top:(NSInteger)top completionBlock:(MPOPersonGroupArrayCompletionBlock)completion;

/**
 *  Trains the person group
 *  @param personGroupId the person group id
 *  @param completion    completionHandler
 *  @return boolean representing success or failure of starting train operation
 */
- (NSURLSessionDataTask *)trainPersonGroupWithPersonGroupId:(NSString *)personGroupId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets person group training status
 *  @param personGroupId the person group id
 *  @param completion    completionHandler
 *  @return the person group training status, MPOTrainingStatus
 */
- (NSURLSessionDataTask *)getPersonGroupTrainingStatusWithPersonGroupId:(NSString *)personGroupId completionBlock:(void (^) (MPOTrainingStatus *trainingStatus, NSError *error))completion;

#pragma mark Large Person Groups APIs

/**
 *  Creates the large person group
 *  @param largePersonGroupId the large person group id
 *  @param name               the name of the person group
 *  @param userData           the user data
 *  @param completion         completionHandler
 *  @return boolean representing success or failure of creation
 */
- (NSURLSessionDataTask *)createLargePersonGroup:(NSString *)largePersonGroupId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Deletes the large person group.
 *  @param largePersonGroupId the large person group id
 *  @param completion         completionHandler
 *  @return boolean representing success or failure of deletion
 */
- (NSURLSessionDataTask *)deleteLargePersonGroup:(NSString *)largePersonGroupId completionBlock:(MPOCompletionBlock)completion;


/**
 *  Updates the large person group
 *  @param largePersonGroupId the large person group id
 *  @param name               the name of the person group
 *  @param userData           the user data
 *  @param completion         completionHandler
 *  @return boolean representing success or failure of update
 */
- (NSURLSessionDataTask *)updateLargePersonGroup:(NSString *)largePersonGroupId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets a large person group
 *  @param largePersonGroupId the large person group id
 *  @param completion         completionHandler
 *  @return The large person group, MPOLargePersonGroup
 */
- (NSURLSessionDataTask *)getLargePersonGroup:(NSString *)largePersonGroupId completionBlock:(void (^) (MPOLargePersonGroup *largePersonGroup, NSError *error))completion;
/**
 *  Lists first 1000 large person groups
 *  @param completion completionHandler
 *  @return person group entities, NSArray of MPOLargePersonGroup objects
 */
- (NSURLSessionDataTask *)listLargePersonGroupsWithCompletion:(MPOLargePersonGroupArrayCompletionBlock)completion;

/**
 *  Lists a certain number of large person groups starting from a certain large person group identifier
 *  @start List large person groups from the least personGroupId greater than the "start". It contains no more than 64 characters. Default is empty.
 *  @top   The number of large person groups to list, ranging in [1, 1000]. Default is 1000.
 *  @param completion completionHandler
 *  @return person group entities, NSArray of MPOLargePersonGroup objects
 */
- (NSURLSessionDataTask *)listLargePersonGroupsWithStartAndTop:(NSString*)start top:(NSInteger)top completionBlock:(MPOLargePersonGroupArrayCompletionBlock)completion;

/**
 *  Trains the large person group
 *  @param largePersonGroupId the large person group id
 *  @param completion         completionHandler
 *  @return boolean representing success or failure of starting train operation
 */
- (NSURLSessionDataTask *)trainLargePersonGroup:(NSString *)largePersonGroupId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets large person group training status
 *  @param largePersonGroupId the large person group id
 *  @param completion         completionHandler
 *  @return the person group training status, MPOTrainingStatus
 */
- (NSURLSessionDataTask *)getLargePersonGroupTrainingStatus:(NSString *)largePersonGroupId completionBlock:(void (^) (MPOTrainingStatus *trainingStatus, NSError *error))completion;

#pragma mark Person APIs

/**
 *  Creates a person
 *  @param personGroupId the person group id
 *  @param name          the name
 *  @param userData      the user data
 *  @param completion    completionHandler
 *  @return the create person result, MPOCreatePersonResult
 */
- (NSURLSessionDataTask *)createPersonWithPersonGroupId:(NSString *)personGroupId name:(NSString *)name userData:(NSString *)userData completionBlock:(void (^) (MPOCreatePersonResult *createPersonResult, NSError *error))completion;

/**
 *  Gets a person
 *  @param personGroupId the person group id
 *  @param personId      the person id
 *  @param completion    completionHandler
 *  @return the person, MPOPerson
 */
- (NSURLSessionDataTask *)getPersonWithPersonGroupId:(NSString *)personGroupId personId:(NSString *)personId completionBlock:(void (^) (MPOPerson *person, NSError *error))completion;

/**
 *  Updates person.
 *  @param personGroupId the person group id
 *  @param personId      the person id
 *  @param name          the name
 *  @param userData      the user data
 *  @param completion    completionHandler
 *  @return boolean representing success or failure of update person operation
 */
- (NSURLSessionDataTask *)updatePersonWithPersonGroupId:(NSString *)personGroupId personId:(NSString *)personId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Deletes a person.
 *  @param personGroupId the person group id
 *  @param personId      the person id
 *  @param completion    completionHandler
 *  @return boolean representing success or failure of delete person operation
 */
- (NSURLSessionDataTask *)deletePersonWithPersonGroupId:(NSString *)personGroupId personId:(NSString *)personId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets all persons inside a person group
 *  @param personGroupId the person group id
 *  @param completion    completion handler
 *  @return the persons, NSArray containing MPOPerson objects
 */
- (NSURLSessionDataTask *)getPersonsWithPersonGroupId:(NSString *)personGroupId completionBlock:(MPOPersonArrayCompletionBlock)completion NS_DEPRECATED_IOS(7.0, 7.0);

/**
 *  Lists all persons inside a person group
 *  @param personGroupId the person group id
 *  @param completion    completion handler
 *  @return the persons, NSArray containing MPOPerson objects
 */
- (NSURLSessionDataTask *)listPersonsWithPersonGroupId:(NSString *)personGroupId completionBlock:(MPOPersonArrayCompletionBlock)completion;

#pragma mark Person in Large Person Group APIs

/**
 *  Creates a person in a Large Person Group
 *  @param largePersonGroupId the large person group id
 *  @param name               the name
 *  @param userData           the user data
 *  @param completion         completionHandler
 *  @return the create person result, MPOCreatePersonResult
 */
- (NSURLSessionDataTask *)createPersonWithLargePersonGroupId:(NSString *)largePersonGroupId name:(NSString *)name userData:(NSString *)userData completionBlock:(void (^) (MPOCreatePersonResult *createPersonResult, NSError *error))completion;

/**
 *  Deletes a person.
 *  @param largePersonGroupId the large person group id
 *  @param personId           the person id
 *  @param completion         completionHandler
 *  @return boolean representing success or failure of delete person operation
 */
- (NSURLSessionDataTask *)deletePersonWithLargePersonGroupId:(NSString *)largePersonGroupId personId:(NSString *)personId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Updates person.
 *  @param largePersonGroupId the large person group id
 *  @param personId           the person id
 *  @param name               the name
 *  @param userData           the user data
 *  @param completion         completionHandler
 *  @return boolean representing success or failure of update person operation
 */
- (NSURLSessionDataTask *)updatePersonWithLargePersonGroupId:(NSString *)largePersonGroupId personId:(NSString *)personId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets a person
 *  @param largePersonGroupId the large person group id
 *  @param personId           the person id
 *  @param completion         completionHandler
 *  @return the person, MPOPerson
 */
- (NSURLSessionDataTask *)getPersonWithLargePersonGroupId:(NSString *)largePersonGroupId personId:(NSString *)personId completionBlock:(void (^) (MPOPerson *person, NSError *error))completion;

/**
 *  Lists all persons inside a large person group
 *  @param largePersonGroupId the large person group id
 *  @param completion         completion handler
 *  @return the persons, NSArray containing MPOPerson objects
 */
- (NSURLSessionDataTask *)listPersonsWithLargePersonGroupId:(NSString *)largePersonGroupId completionBlock:(MPOPersonArrayCompletionBlock)completion;

/**
 *  Lists a certain number of large persons starting from a certain person identifier
 *  @start List persons from the least personId greater than the "start". It contains no more than 64 characters. Default is empty.
 *  @top   The number of persons to list, ranging in [1, 1000]. Default is 1000.
 *  @param completion completionHandler
 *  @return person group entities, NSArray of MPOPerson objects
 */
- (NSURLSessionDataTask *)listPersonsWithLargePersonGroupIdWithStartAndTop:(NSString *)largePersonGroupId start:(NSString*)start top:(NSInteger)top completionBlock:(MPOPersonArrayCompletionBlock)completion;

#pragma mark Person Face APIs

/**
 *  Gets a face of a person
 *  @param personGroupId   the person group id
 *  @param personId        the person id
 *  @param persistedFaceId the persisted face id
 *  @param completion       completionHandler
 *  @return the person face, MPOPersonFace
 */
- (NSURLSessionDataTask *)getPersonFaceWithPersonGroupId:(NSString *)personGroupId personId:(NSString *)personId persistedFaceId:(NSString *)persistedFaceId completionBlock:(void (^) (MPOPersonFace *personFace, NSError *error))completion;

/**
 *  Updates a face of a person
 *  @param personGroupId   the person group id
 *  @param personId        the person id
 *  @param persistedFaceId the persisted face id
 *  @param userData        the user data
 *  @param completion      completionHandler
 *  @return boolean representing success or failure of update person face operation
 */
- (NSURLSessionDataTask *)updatePersonFaceWithPersonGroupId:(NSString *)personGroupId personId:(NSString *)personId persistedFaceId:(NSString *)persistedFaceId userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Deletes a face of a person
 *  @param personGroupId   The person group id
 *  @param personId        The person id
 *  @param persistedFaceId The persisted face id
 *  @param completion      completionHandler
 *  @return boolean representing success or failure of delete person face operation
 */
- (NSURLSessionDataTask *)deletePersonFaceWithPersonGroupId:(NSString *)personGroupId personId:(NSString *)personId persistedFaceId:(NSString *)persistedFaceId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Adds a face to a person.
 *  @param personGroupId The person group id
 *  @param personId      The person id
 *  @param url           The face image URL.
 *  @param userData      The user data.
 *  @param faceRectangle The face rectangle.
 *  @param completion    completionHandler
 *  @return Add Persisted Face Result, MPOAddPersistedFaceResult
 */
- (NSURLSessionDataTask *)addPersonFaceWithPersonGroupId:(NSString *)personGroupId personId:(NSString *)personId url:(NSString *)url userData:(NSString *)userData faceRectangle:(MPOFaceRectangle *)faceRectangle completionBlock:(void (^) (MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error))completion;

/**
 *  Adds a face to a person.
 *  @param personGroupId The person group id
 *  @param personId      The person id
 *  @param data          The face data.
 *  @param userData      The user data.
 *  @param faceRectangle The face rectangle.
 *  @param completion    completionHandler
 *  @return Add Persisted Face Result, MPOAddPersistedFaceResult
 */
- (NSURLSessionDataTask *)addPersonFaceWithPersonGroupId:(NSString *)personGroupId personId:(NSString *)personId data:(NSData *)data userData:(NSString *)userData faceRectangle:(MPOFaceRectangle *)faceRectangle completionBlock:(void (^) (MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error))completion;

#pragma mark Person Face in Large Person Group APIs

/**
 *  Adds a face to a person.
 *  @param largePersonGroupId The large person group id
 *  @param personId           The person id
 *  @param url                The face image URL.
 *  @param userData           The user data.
 *  @param faceRectangle      The face rectangle.
 *  @param completion         completionHandler
 *  @return Add Persisted Face Result, MPOAddPersistedFaceResult
 */
- (NSURLSessionDataTask *)addPersonFaceWithLargePersonGroupId:(NSString *)largePersonGroupId personId:(NSString *)personId url:(NSString *)url userData:(NSString *)userData faceRectangle:(MPOFaceRectangle *)faceRectangle completionBlock:(void (^) (MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error))completion;

/**
 *  Adds a face to a person.
 *  @param largePersonGroupId The large person group id
 *  @param personId           The person id
 *  @param data               The face data.
 *  @param userData           The user data.
 *  @param faceRectangle      The face rectangle.
 *  @param completion         completionHandler
 *  @return Add Persisted Face Result, MPOAddPersistedFaceResult
 */
- (NSURLSessionDataTask *)addPersonFaceWithLargePersonGroupId:(NSString *)largePersonGroupId personId:(NSString *)personId data:(NSData *)data userData:(NSString *)userData faceRectangle:(MPOFaceRectangle *)faceRectangle completionBlock:(void (^) (MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error))completion;

/**
 *  Deletes a face of a person
 *  @param largePersonGroupId   The large person group id
 *  @param personId             The person id
 *  @param persistedFaceId      The persisted face id
 *  @param completion           completionHandler
 *  @return boolean representing success or failure of delete person face operation
 */
- (NSURLSessionDataTask *)deletePersonFaceWithLargePersonGroupId:(NSString *)largePersonGroupId personId:(NSString *)personId persistedFaceId:(NSString *)persistedFaceId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Updates a face of a person
 *  @param largePersonGroupId   the large person group id
 *  @param personId             the person id
 *  @param persistedFaceId      the persisted face id
 *  @param userData             the user data
 *  @param completion           completionHandler
 *  @return boolean representing success or failure of update person face operation
 */
- (NSURLSessionDataTask *)updatePersonFaceWithLargePersonGroupId:(NSString *)largePersonGroupId personId:(NSString *)personId persistedFaceId:(NSString *)persistedFaceId userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets a face of a person
 *  @param largePersonGroupId   the large person group id
 *  @param personId             the person id
 *  @param persistedFaceId      the persisted face id
 *  @param completion           completionHandler
 *  @return the person face, MPOPersonFace
 */
- (NSURLSessionDataTask *)getPersonFaceWithLargePersonGroupId:(NSString *)largePersonGroupId personId:(NSString *)personId persistedFaceId:(NSString *)persistedFaceId completionBlock:(void (^) (MPOPersonFace *personFace, NSError *error))completion;

#pragma mark Face List APIs

/**
 *  Creates the face list
 *  @param faceListId The face list identifier.
 *  @param name       The name
 *  @param userData   The user data.
 *  @param completion completionHandler
 *  @return boolean representing success or failure of create face list operation
 */
- (NSURLSessionDataTask *)createFaceListWithFaceListId:(NSString *)faceListId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets the face list
 *  @param faceListId The face list identifier.
 *  @param completion completionHandler
 *  @return The face list, MPOFaceList
 */
- (NSURLSessionDataTask *)getFaceListWithFaceListId:(NSString *)faceListId completionBlock:(void (^) (MPOFaceList *addPersistedFaceResult, NSError *error))completion;

/**
 *  Lists all face lists
 *  @param completion completionHandler
 *  @return face lists, NSArray containing MPOFaceListMetadata objects
 */
- (NSURLSessionDataTask *)listFaceListsWithCompletion:(MPOFaceListMetadataArrayCompletionBlock)completion;

/**
 *  Updates a face list.
 *  @param faceListId The face list identifier.
 *  @param name       the name
 *  @param userData   the user data
 *  @param completion the completionHandler
 *  @return boolean representing success or failure of update face list operation
 */
- (NSURLSessionDataTask *)updateFaceListWithFaceListId:(NSString *)faceListId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Deletes a face list.
 *  @param faceListId The face list identifier.
 *  @param name       the name
 *  @param userData   the user data.
 *  @param completion the completionHandler.
 *  @return boolean representing success or failure of delete face list operation
 */
- (NSURLSessionDataTask *)deleteFaceListWithFaceListId:(NSString *)faceListId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Deletes faces from a face list
 *  @param faceListId      the face list identifier.
 *  @param name            the name
 *  @param persistedFaceId the face identifier.
 *  @param completion      completionHandler
 *  @return boolean representing success or failure of delete face from face list operation
 */
- (NSURLSessionDataTask *)deleteFaceFromFaceListWithFaceListId:(NSString *)faceListId name:(NSString *)name persistedFaceId:(NSString *)persistedFaceId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Adds the face to the face list.
 *  @param faceListId    the face list identifier.
 *  @param url           the face image URL.
 *  @param userData      the user data.
 *  @param faceRectangle the face rectangle.
 *  @param completion    completionHandler
 *  @return the persisted face result, MPOAddPersistedFaceResult
 */
- (NSURLSessionDataTask *)addFaceToFaceListWithFaceListId:(NSString *)faceListId url:(NSString *)url userData:(NSString *)userData faceRectangle:(MPOFaceRectangle *)faceRectangle completionBlock:(void (^) (MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error))completion;

/**
 *  Adds the face to the face list.
 *  @param faceListId    the face list identifier.
 *  @param data          the face image data.
 *  @param userData      the user data.
 *  @param faceRectangle the face rectangle.
 *  @param completion    completionHandler
 *  @return the persisted face result, MPOAddPersistedFaceResult
 */
- (NSURLSessionDataTask *)addFacesToFaceListWithFaceListId:(NSString *)faceListId data:(NSData *)data userData:(NSString *)userData faceRectangle:(MPOFaceRectangle *)faceRectangle completionBlock:(void (^) (MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error))completion;

#pragma mark Large Face List APIs

/**
 *  Creates the large face list
 *  @param largeFaceListId The face list identifier.
 *  @param name            The name
 *  @param userData        The user data.
 *  @param completion completionHandler
 *  @return boolean representing success or failure of create face list operation
 */
- (NSURLSessionDataTask *)createLargeFaceList:(NSString *)largeFaceListId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Deletes a large face list.
 *  @param largeFaceListId The large face list identifier.
 *  @param name       the name
 *  @param userData   the user data.
 *  @param completion the completionHandler.
 *  @return boolean representing success or failure of delete face list operation
 */
- (NSURLSessionDataTask *)deleteLargeFaceList:(NSString *)largeFaceListId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets the large face list
 *  @param largeFaceListId The large face list identifier.
 *  @param completion completionHandler
 *  @return The large face list, MPOLargeFaceList
 */
- (NSURLSessionDataTask *)getLargeFaceList:(NSString *)largeFaceListId completionBlock:(void (^) (MPOLargeFaceList *largeFaceList, NSError *error))completion;

/**
 *  Lists all large face lists
 *  @param completion completionHandler
 *  @return large face lists, NSArray containing MPOLargeFaceList objects
 */
- (NSURLSessionDataTask *)listLargeFaceListsWithCompletion:(MPOLargeFaceListArrayCompletionBlock)completion;

/**
 *  Lists a certain number of large face lists starting from a certain large face list identifier
 *  @start List large face lists from the least largeFaceListId greater than the "start". It contains no more than 64 characters. Default is empty.
 *  @top   The number of large face lists to list, ranging in [1, 1000]. Default is 1000.
 *  @param completion completionHandler
 *  @return large face lists, NSArray of MPOLargeFaceList objects
 */
- (NSURLSessionDataTask *)listLargeFaceListsWithStartAndTop:(NSString*)start top:(NSInteger)top completionBlock:(MPOLargeFaceListArrayCompletionBlock)completion;

/**
 *  Updates a large face list.
 *  @param largeFaceListId The face list identifier.
 *  @param name            the name
 *  @param userData        the user data
 *  @param completion      the completionHandler
 *  @return boolean representing success or failure of update face list operation
 */
- (NSURLSessionDataTask *)updateLargeFaceList:(NSString *)largeFaceListId name:(NSString *)name userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Trains the large face list
 *  @param largeFaceListId the large face list id
 *  @param completion      completionHandler
 *  @return boolean representing success or failure of starting train operation
 */
- (NSURLSessionDataTask *)trainLargeFaceList:(NSString *)largeFaceListId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets large face list training status
 *  @param largeFaceListId the large face list id
 *  @param completion      completionHandler
 *  @return the person group training status, MPOTrainingStatus
 */
- (NSURLSessionDataTask *)getLargeFaceListTrainingStatus:(NSString *)largeFaceListId completionBlock:(void (^) (MPOTrainingStatus *trainingStatus, NSError *error))completion;

#pragma mark Face in Large Face List APIs

/**
 *  Adds the face to the large face list.
 *  @param largeFaceListId    the large face list identifier.
 *  @param url                the face image URL.
 *  @param userData           the user data.
 *  @param faceRectangle      the face rectangle.
 *  @param completion         completionHandler
 *  @return the persisted face result, MPOAddPersistedFaceResult
 */
- (NSURLSessionDataTask *)addFaceInLargeFaceList:(NSString *)largeFaceListId url:(NSString *)url userData:(NSString *)userData faceRectangle:(MPOFaceRectangle *)faceRectangle completionBlock:(void (^) (MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error))completion;

/**
 *  Adds the face to the large face list.
 *  @param largeFaceListId    the large face list identifier.
 *  @param data               the face image data.
 *  @param userData           the user data.
 *  @param faceRectangle      the face rectangle.
 *  @param completion         completionHandler
 *  @return the persisted face result, MPOAddPersistedFaceResult
 */
- (NSURLSessionDataTask *)addFaceInLargeFaceList:(NSString *)largeFaceListId data:(NSData *)data userData:(NSString *)userData faceRectangle:(MPOFaceRectangle *)faceRectangle completionBlock:(void (^) (MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error))completion;

/**
 *  Deletes faces from a large face list
 *  @param largeFaceListId    the large face list identifier.
 *  @param persistedFaceId    the face identifier.
 *  @param completion         completionHandler
 *  @return boolean representing success or failure of delete face from face list operation
 */
- (NSURLSessionDataTask *)deleteFaceFromLargeFaceList:(NSString *)largeFaceListId persistedFaceId:(NSString *)persistedFaceId completionBlock:(MPOCompletionBlock)completion;

/**
 *  Updates faces from a large face list
 *  @param largeFaceListId    the large face list identifier.
 *  @param persistedFaceId    the face identifier.
 *  @param userData           the user data.
 *  @param completion         completionHandler
 *  @return boolean representing success or failure of update face from face list operation
 */
- (NSURLSessionDataTask *)updateFaceInLargeFaceList:(NSString *)largeFaceListId persistedFaceId:(NSString *)persistedFaceId userData:(NSString *)userData completionBlock:(MPOCompletionBlock)completion;

/**
 *  Gets the face from a large face list
 *  @param largeFaceListId   the large face list identifier.
 *  @param persistedFaceId   the face identifier.
 *  @param completion        completionHandler
 *  @return the person face, MPOPersonFace
 */
- (NSURLSessionDataTask *)getFaceInLargeFaceList:(NSString *)largeFaceListId persistedFaceId:(NSString *)persistedFaceId completionBlock:(void (^) (MPOPersonFace *personFace, NSError *error))completion;

/**
 *  Lists the persisted faces from a large face list
 *  @param largeFaceListId   the large face list identifier.
 *  @param completion        completionHandler
 *  @return an array of persisted faces
 */
- (NSURLSessionDataTask *)listFacesInLargeFaceListWithCompletion:(NSString *)largeFaceListId completionBlock:(MPOFaceMetadataArrayCompletionBlock)completion;

/**
 *  Lists a certain number of faces in large face list starting from a certain large face list identifier
 *  @start List large face lists from the least persistedFaceId greater than the "start". It contains no more than 64 characters. Default is empty.
 *  @top   The number of faces in large face lists to list, ranging in [1, 1000]. Default is 1000.
 *  @param completion completionHandler
 *  @return an array of persisted faces
 */
- (NSURLSessionDataTask *)listFacesInLargeFaceListWithStartAndTop:(NSString *)largeFaceListId start:(NSString*)start top:(NSInteger)top completionBlock:(MPOFaceMetadataArrayCompletionBlock)completion;

@end
