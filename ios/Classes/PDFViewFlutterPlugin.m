#import "PDFViewFlutterPlugin.h"
#import "FlutterFullPDFView.h"

@implementation FLTPDFViewFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FLTPDFViewFactory* pdfViewFactory = [[FLTPDFViewFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:pdfViewFactory withId:@"plugins.arnaudelub.io/pdfview"];
}
@end
