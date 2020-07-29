
## 1.1.4
Adding setZoom to controller to be able to set the zoom programatically

## 1.1.2
revert plugin declaration with platforms
## 1.1.1
Fixing iOS NSNotificationScaleChangedNotification listener

## 1.1.0
Adding zoom listener to be able to know the scale at every moment.
APV updated to version 1.5.2 and link issue has been fixed

## 1.0.11
Updating APV version to 1.4.1

## 1.0.10
Updating APV version to 1.4.0

## 1.0.9+3
Adding dualPageWithBreak that will displays or not a break between the 2 pages in dualPage mode

## 1.0.9+2
Fixing ios viewer

## 1.0.9+1
Adding displayAsBook capabalitity, se to true to show the first and last page as cover (alone)

## 1.0.8+1
Fixing IOS Class, view is now rendered correctly

## 1.0.7+8
Update apv version

## 1.0.7+7
Fix resetZoom to take snapEdge in account, using zoomToWithAnimation to do so

## 1.0.7+6
Updating apv version

## 1.0.7+5
Updating apv version

## 1.0.7+4
Updating apv version

## 1.0.7+3
Fixing ios default Page

## 1.0.7+2
Fixing dualPageMode for ios, scale calculation wasn't accurate

## 1.0.7+1
Updating APV version to 1.3.1, snapEdge was missing in startXAnimation so the page is centered in screen when using jumpTo()

## 1.0.6+7
Android resetZoom

## 1.0.6+6
Adding fit policy to both on ios

## 1.0.6+5
Adding reset zoom for iOS

## 1.0.6+4
Fixing default page issue

## 1.0.6+3
Fixing android get page size, scalefactor was missing in the returned value!

## 1.0.6+2
Updating APV version to 1.3.0

## 1.0.6+1
Adding getPageWidth and getPAgeHeight with the scale to controller

## 1.0.5+5
Fixing scale on ios in dual page mode

## 1.0.5+4
Fixing scale on ios in dual page mode

## 1.0.5+3
Adding LICENSE

## 1.0.5+2
Fixing typo

## 1.0.5+1
Adding fitPolicy selector and possility to get the actual zoom

## 1.0.4+1
Adding setPageWithAnimation and resetZoom to the controller

## 1.0.3+2
Fixing vertical scroll on iOS

## 1.0.3+1
Updating with apv version 1.2.0
Adding backgroundColor support
Adding dualPageMode support on IOS

## 1.0.2+9
Updating with apv version 1.1.0

## 1.0.2+8
Updating with apv version 1.0.12

## 1.0.2+7
Updating apv version to 1.0.9

## 1.0.2+6
Updating README

## 1.0.2+5
Added dualpage mode based on the orientation of the device

## 1.0.1+4

Updating the README file

## 1.0.1+3

Adding analisys_options.yaml

## 1.0.1+2
New release fixing the channel id for the invoke method and renaming java and objc files


## 1.0.0+1

First release of the updated plugin flutter_pdfview from endigo
Fitpolicy from AndroidPdfView is now set to BOTH and the option fitEachPage has been added.
The plugin AndroidPdfView from barteksc is not maintained anymore, so flutter_fullpdfview is now using apv => https://github.com/arnaudelub/apv
