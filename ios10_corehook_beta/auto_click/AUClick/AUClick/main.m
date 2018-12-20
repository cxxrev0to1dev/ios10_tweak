//
//  main.m
//  AUClick
//
//  Created by 紫贝壳 on 2017/4/26.
//  Copyright © 2017年 紫贝壳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "substrate.h"
#import "UIDevice-IOKitExtensions.h"
#import "NSTask.h"

NSString* TASK_API = @"http://aso.25fz.com/index.php?m=Bang&c=Keep&a=job&imei=";
static const CFStringRef kMGIMEI = CFSTR("InternationalMobileEquipmentIdentity");

static CFStringRef ForMGCopyAnswer(CFTypeRef prop){
  static CFStringRef (*MGCopyAnswer)(CFTypeRef prop);
  if (!MGCopyAnswer) {
    const char* name = "MGCopyAnswer";
    MSImageRef image = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
    void* ptr = MSFindSymbol(image, name);
    if (!ptr) {
      ptr = MSFindSymbol(image, "_MGCopyAnswer");
      if (!ptr) {
        ptr = MSFindSymbol(NULL, "_MGCopyAnswer");
      }
    }
    MGCopyAnswer = (CFTypeRef(*)(CFTypeRef))ptr;
  }
  return MGCopyAnswer(prop);
}
static NSString* GET(NSString* url){
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setHTTPMethod:@"GET"];
  [request setURL:[NSURL URLWithString:url]];
  NSError *error = nil;
  NSHTTPURLResponse *responseCode = nil;
  NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
  if([responseCode statusCode] != 200){
    NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
    return nil;
  }
  return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

void Open(const char* bundle_id){
  NSArray *args = nil;
  NSString* sss = @(bundle_id);
  NSString* open = @"/usr/bin/open";
  args = [NSArray arrayWithObjects:sss,nil];
  [[NSTask launchedTaskWithLaunchPath:open arguments:
    args] waitUntilExit];
}

int main(int argc, char * argv[]) {
  @autoreleasepool {
    //Open("com.apple.Preferences");
    setuid(0);
    setgid(0);
    //CFStringRef s1 = ForMGCopyAnswer(kMGIMEI);
    NSString* imei;
    //imei = @(CFStringGetCStringPtr(s1,kCFStringEncodingUTF8));
    NSString* aaa = TASK_API;
    //aaa = [aaa stringByAppendingString:imei];
    NSString* ss = GET(TASK_API);
    if ([ss length]) {
      NSData *data = [ss dataUsingEncoding:NSUTF8StringEncoding];
      id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
      NSLog(@"Read IDFA OK:%@\r\n",json);
    }
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
