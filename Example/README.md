Microsoft Cognitive Services Face iOS Sample
==================

This is a sample application on how to use the Microsoft Cognitive Services Face SDK 

Building and running the sample
==========

The sample app should already have the necessary Pods shipped with it. Open the `ProjectOxfordFace.xcworkspace` in Xcode and build.

1. First, you must obtain a Face API subscription key by following instructions in [Microsoft Cognitive Services subscription](<https://www.microsoft.com/cognitive-services/en-us/sign-up>).
2. Once in Xcode, under the example subdirectory, navigate to the file `MPODemoConstants.h` and insert your subscription key for the Face API
3. To run the sample app, ensure that the target on top left side of Xcode is selected as `ProjectOxfordFace-Example` and select the play button or select Product > Run on the menu bar
4. Once the app is launched, click on the buttons to try out the different scenarios.

Microsoft will receive the images you upload and may use them to improve Face API and related services. By submitting an image, you confirm you have consent from everyone in it.

<img src="SampleScreenshots/SampleScreenshot1.png" width="30%"/>
<img src="SampleScreenshots/SampleScreenshot2.png" width="30%"/>
<img src="SampleScreenshots/SampleScreenshot3.png" width="30%"/>
<img src="SampleScreenshots/SampleScreenshot4.png" width="30%"/>

Requirements
------------

iOS must be version 9.0 or higher.

Having issues?
------------

1. Make sure you have selected `ProjectOxfordFace-Example` as the target.
2. Make sure you have included the subscription key in `MPOTestConstants.h`.
3. Make sure you have opened the `.xcworkspace` file and not the `.xcodeproj` file in Xcode.
4. Make sure you have used the correct `Deployment Team` profile.
5. Make sure you are running iOS 9.0 or higher

Running and exploring the unit tests
--------------

Unit tests that demonstrate various Microsoft Cognitive Services (formerly Project Oxford) scenarios such as detection, identification, grouping, similarity, verification, and face lists are located at `Example/Tests`. 
To run the unit tests, first insert your subscription key in `MPOTestConstants.h` and then select the test navigator pane in Xcode to display all of the tests which can be run.

License
=======

All Microsoft Cognitive Services SDKs and samples are licensed with the MIT License. For more details, see
[LICENSE](</LICENSE.md>).

Sample images are licensed separately, please refer to [LICENSE-IMAGE](</LICENSE-IMAGE.md>).
