#import "FlutterFullpdfviewPlugin.h"
#import "FlutterFullPDFView.h"

@implementation FlutterFullpdfviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FLTPDFViewFactory* pdfViewFactory = [[FLTPDFViewFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:pdfViewFactory withId:@"plugins.arnaudelub.io/pdfview"];
}
@end
