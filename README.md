# flutter_fullpdfview

Native PDF View for iOS and Android

# Use this package as a library

## 1. Depend on it

Add this to your package's pubspec.yaml file:

```
dependencies:
  flutter_fullpdfview: latest_version
```

### 2. Install it

You can install packages from the command line:

with Flutter:

```
$ flutter packages get
```

Alternatively, your editor might support pub get or `flutter pub get`. Check the docs for your editor to learn more.

### 3. Setup

#### iOS

Opt-in to the embedded views preview by adding a boolean property to the app's `Info.plist` file
with the key `io.flutter.embedded_views_preview` and the value `YES`.

### 4. Import it

Now in your Dart code, you can use:

```
import 'package:flutter_fullpdfview/flutter_fullpdfview.dart';
```

## Options

| Name               | Android | iOS |
| :----------------- | :-----: | :-: |
| onViewCreated      |   V     |  V  |
| onRender           |   V     |  V  |
| onPageChanged      |   V     |  V  |
| onError            |   V     |  V  |
| onPageError        |   V     |  X  |
| gestureRecognizers |   V     |  V  |
| filePath           |   V     |  V  |
| fitEachPage        |   V     |  V  |
| defaultPage        |   V     |  V  |
| dualPageMode       |   V     |  V  |
| displayAsBook      |   V     |  V  |
| dualPageWithBreak  |   V     |  V  |
| enableSwipe        |   V     |  V  |
| swipeHorizontal    |   V     |  V  |
| password           |   V     |  V  |
| nightMode          |   V     |  X  |
| password           |   V     |  V  |
| autoSpacing        |   V     |  V  |
| pageFling          |   V     |  V  |
| pageSnap           |   V     |  V  |
| backgroundColor    |   V     |  V  |
| fitPolicy          |   V     |  X  |

Only black and white are supported on Android and iOS at the moment!

## Controller Options

| Name                 |     Description              | Parameters     |     Return     |
| :------------------- | :------------------:         | :--------:     | :------------: |
| getPageCount         | Get total page count         |     -          | `Future<int>`  |
| getCurrentPage       |   Get current page           |     -          | `Future<int>`  |
| setPage              |    Go to/Set page            | `int page`     | `Future<bool>` |
| setPageWithAnimation |    Go to/Set page            | `int page`     | `Future<bool>` |
| resetZoom            |    Go page and fitToWidth    | `int page`     | `Future<bool>` |
| getZoom              |    Get the current zoom      | `double zoom`  | `Future<double>` |
| setZoom              |    Set the current zoom      | `double zoom`  | `Future<double>` |
| getPageWidth         |    Get the pdf width         | `double width` |  `Future<double>` |
| getPageHeight        |    Get the pdf height        | `double height`| `Future<double>` |

## Example

```dart
PDFView(
  filePath: path,
  enableSwipe: true,
  fitEachPage: true,
  swipeHorizontal: true,
  autoSpacing: false,
  pageFling: false,
  defaultPage: 8,
  dualPageMode: orientation == Orientation.landscape,
  displayAsBook: true,
  onRender: (_pages) {
    setState(() {
      pages = _pages;
      isReady = true;
    });
  },
  onError: (error) {
    print(error.toString());
  },
  onPageError: (page, error) {
    print('$page: ${error.toString()}');
  },
  onViewCreated: (PDFViewController pdfViewController) {
    _controller.complete(pdfViewController);
  },
  onPageChanged: (int page, int total) {
    print('page change: $page/$total');
  },
),
```

# For production usage

If you use proguard, you should include this line.

```
-keep class com.shockwave.**
```

# Dependencies

### Android

[apv](https://github.com/arnaudelub/apv)
Updated From:
[AndroidPdfViewer](https://github.com/barteksc/AndroidPdfViewer)

### iOS (only support> 11.0)

[PDFKit](https://developer.apple.com/documentation/pdfkit)
