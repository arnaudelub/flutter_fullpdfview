// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import "FlutterFullPDFView.h"

@implementation FLTPDFViewFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
    FLTPDFViewController* pdfviewController = [[FLTPDFViewController alloc] initWithFrame:frame
                                                                           viewIdentifier:viewId
                                                                                arguments:args
                                                                          binaryMessenger:_messenger];
    return pdfviewController;
}

@end

@implementation FLTPDFViewController {
    PDFView* _pdfView;
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    NSNumber* _pageCount;
    NSNumber* _currentPage;
    NSNumber* _zoom;
    NSNumber* _pageWidth;
    NSNumber* _pageHeight;
    CGFloat scale;
    BOOL _pageFling;
    BOOL _enableSwipe;
    BOOL _dualPage;
    CGSize pageSize;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if ([super init]) {
        _viewId = viewId;
        NSString* channelName = [NSString stringWithFormat:@"plugins.arnaudelub.io/pdfview_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];

        _pdfView = [[PDFView alloc] initWithFrame:frame];

        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            [weakSelf onMethodCall:call result:result];
        }];

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter]
           addObserver:self selector:@selector(orientationChanged:)
           name:UIDeviceOrientationDidChangeNotification
           object:[UIDevice currentDevice]];
        BOOL autoSpacing = [args[@"autoSpacing"] boolValue];
        BOOL dualPage = [args[@"dualPageMode"] boolValue];
        BOOL pageFling = [args[@"pageFling"] boolValue];
        BOOL enableSwipe = [args[@"enableSwipe"] boolValue];
        NSInteger defaultPage = [args[@"defaultPage"] integerValue];
        NSString* filePath = args[@"filePath"];
        NSString *backgroundColor = args[@"backgroundColor"];
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeLeft];

        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(didSwipe:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipeRight];
        if ([filePath isKindOfClass:[NSString class]]) {
            NSURL * sourcePDFUrl = [NSURL fileURLWithPath:filePath];
            PDFDocument * document = [[PDFDocument alloc] initWithURL: sourcePDFUrl];

            if (document == nil) {
                [_channel invokeMethod:@"onError" arguments:@{@"error" : @"cannot create document: File not in PDF format or corrupted."}];
            } else {
                _pdfView.autoresizesSubviews = YES;
                //_pdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

                _pdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //                | UIViewAutoresizingFlexibleHeight
   //                 | UIViewAutoresizingFlexibleTopMargin
   //                 | UIViewAutoresizingFlexibleBottomMargin;
                BOOL swipeHorizontal = [args[@"swipeHorizontal"] boolValue];
                if (swipeHorizontal) {
                    _pdfView.displayDirection = kPDFDisplayDirectionHorizontal;
                } else {
                    _pdfView.displayDirection = kPDFDisplayDirectionVertical;
                }

                if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
                {
                             // code for landscape orientation
                  _pdfView.displayMode = dualPage ? kPDFDisplayTwoUp: kPDFDisplaySinglePageContinuous ;
                  _pdfView.displaysAsBook = dualPage ? YES : NO;

                  NSLog(@"In landscape mode");           //
                }
                if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
                {
                             // code for Portrait orientation
                    _pdfView.displayMode = enableSwipe  ? kPDFDisplaySinglePageContinuous : kPDFDisplaySinglePage;
                [_pdfView usePageViewController:pageFling withViewOptions:nil];
                 NSLog(@"In portrait mode");            //
                }
                _pdfView.autoScales = autoSpacing;
                _pdfView.document = document;
                if([backgroundColor isEqual:  @"black"]) {
                    _pdfView.backgroundColor =[UIColor blackColor ];
                }else if([backgroundColor isEqual:  @"white"]){
                    _pdfView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
                }else {
                    _pdfView.backgroundColor = [UIColor blackColor];
                }


                NSUInteger pageCount = [document pageCount];

                if (pageCount <= defaultPage) {
                    defaultPage = pageCount - 1;
                }

                PDFPage* page = [document pageAtIndex: defaultPage];
                [_pdfView goToPage: page];
                CGRect pageRect = [page boundsForBox:[_pdfView displayBox]];
                pageSize = CGSizeMake(pageRect.size.width, pageRect.size.height);
                CGRect parentRect = [[UIScreen mainScreen] bounds];

                if (frame.size.width > 0 && frame.size.height > 0) {
                    NSLog(@"Frame size is not 0.....");
                    parentRect = frame;
                }else {
                    NSLog(@"FRAME size is 0....");
                }

                scale = 1.0f;

                if(!dualPage){
                if (parentRect.size.width / parentRect.size.height >= pageRect.size.width / pageRect.size.height) {
                    scale = parentRect.size.height / pageRect.size.height;
                } else {
                    scale = parentRect.size.width / pageRect.size.width;
                }
                }else{
                if (parentRect.size.width / parentRect.size.height >= pageRect.size.width / pageRect.size.height) {
                    scale = parentRect.size.height / pageRect.size.height;
                } else {
                    NSLog(@"Es dual Page!!!!!");
                    scale = parentRect.size.width / (parentRect.size.width *2 )  ;
                }
                }

                NSLog(@"scale %f, parent width: %f, page width: %f, parent height: %f, page height: %f", scale, parentRect.size.width, pageRect.size.width, parentRect.size.height, pageRect.size.height);

                _pdfView.scaleFactor = scale;

                _pdfView.minScaleFactor = _pdfView.scaleFactorForSizeToFit;
                _pdfView.maxScaleFactor = 4.0;

                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf handleRenderCompleted:[NSNumber numberWithUnsignedLong: [document pageCount]]];
                });


                NSString* password = args[@"password"];
                if ([password isKindOfClass:[NSString class]] && [_pdfView.document isEncrypted]) {
                    [_pdfView.document unlockWithPassword:password];
                }
            }
        }



        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePageChanged:) name:PDFViewPageChangedNotification object:_pdfView];

    }
    return self;
}

- (UIView*)view {
    return _pdfView;
}

- (void)didSwipe:(UISwipeGestureRecognizer*)swipe{
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Swipe Left");
        if ([_pdfView canGoToNextPage]){
            [_pdfView goToNextPage:nil];
        }
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Swipe Right");
        if ([_pdfView canGoToPreviousPage]){
            [_pdfView goToPreviousPage:nil];
        }
   }
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([[call method] isEqualToString:@"pageCount"]) {
        [self getPageCount:call result:result];
    } else if ([[call method] isEqualToString:@"currentPage"]) {
        [self getCurrentPage:call result:result];
    } else if ([[call method] isEqualToString:@"resetZoom"]) {
        [self resetZoom:call result:result];
    } else if ([[call method] isEqualToString:@"setPage"]) {
        [self setPage:call result:result];
    } else if ([[call method] isEqualToString:@"pageWidth"]) {
        [self getPageWidth:call result:result];
    } else if ([[call method] isEqualToString:@"pageHeight"]) {
        [self getPageHeight:call result:result];
    } else if ([[call method] isEqualToString:@"updateSettings"]) {
        [self onUpdateSettings:call result:result];
    } else if ([[call method] isEqualToString:@"currentZoom"]) {
        [self getZoom:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)getZoom:(FlutterMethodCall*)call result:(FlutterResult)result {
    _zoom = [NSNumber numberWithFloat: _pdfView.scaleFactor];
    result(_zoom);
}

- (void)resetZoom:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"Scale factore was %f" , _pdfView.scaleFactor);
    _pdfView.scaleFactor=_pdfView.scaleFactorForSizeToFit;

    NSLog(@"Now it's %f" , _pdfView.scaleFactor);
    result(nil);
}
- (void)getPageWidth:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary<NSString*, NSNumber*>* arguments = [call arguments];
    NSNumber* page = arguments[@"page"];
    _pageWidth = [NSNumber numberWithFloat: pageSize.width*_pdfView.scaleFactor];
    result(_pageWidth);
}

- (void)getPageHeight:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary<NSString*, NSNumber*>* arguments = [call arguments];
    NSNumber* page = arguments[@"page"];
    _pageHeight = [NSNumber numberWithFloat: pageSize.height*_pdfView.scaleFactor];
    result(_pageHeight);
}
- (void)getPageCount:(FlutterMethodCall*)call result:(FlutterResult)result {
    _pageCount = [NSNumber numberWithUnsignedLong: [[_pdfView document] pageCount]];
    result(_pageCount);
}

- (void)getCurrentPage:(FlutterMethodCall*)call result:(FlutterResult)result {
    _currentPage = [NSNumber numberWithUnsignedLong: [_pdfView.document indexForPage: _pdfView.currentPage]];
    result(_currentPage);
}

- (void)setPage:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary<NSString*, NSNumber*>* arguments = [call arguments];
    NSNumber* page = arguments[@"page"];

    [_pdfView goToPage: [_pdfView.document pageAtIndex: page.unsignedLongValue ]];
    result(_currentPage);
}

- (void)onUpdateSettings:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(nil);
}

-(void)handlePageChanged:(NSNotification*)notification {
    [_channel invokeMethod:@"onPageChanged" arguments:@{@"page" : [NSNumber numberWithUnsignedLong: [_pdfView.document indexForPage: _pdfView.currentPage]], @"total" : [NSNumber numberWithUnsignedLong: [_pdfView.document pageCount]]}];
}

-(void)handleRenderCompleted: (NSNumber*)pages {
    [_channel invokeMethod:@"onRender" arguments:@{@"pages" : pages}];
}

- (void) orientationChanged:(NSNotification *)note
{
       UIDevice * device = note.object;
        _pdfView.autoScales = YES;
       NSLog(@"orientation changed");
          switch(device.orientation)
          {
             case UIDeviceOrientationPortrait:
                            /* start special animation */
                 break;
             case UIDeviceOrientationPortraitUpsideDown:
                                      /* start special animation */
                 break;
             default:
             break;

          };

}
@end
