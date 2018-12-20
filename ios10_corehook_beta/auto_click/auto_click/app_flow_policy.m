#import <AdSupport/ASIdentifierManager.h>
#import <AdSupport/AdSupport.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSProcessInfo.h>
#import <sqlite3.h>
#import <pthread.h>
#import "OpenUDID.h"
#import "NSTask.h"
#import "app_clear_policy.h"
#import "UIDevice-IOKitExtensions.h"
#include <substrate.h>
#include <pthread.h>
#import <CoreFoundation/CFString.h>


#define IDFA_API @"http://aso.25fz.com/index.php?m=Bang&c=Keep&a=get_idfa&imei="
static const CFStringRef kMGInternationalMobileEquipmentIdentity = CFSTR("InternationalMobileEquipmentIdentity");

static pthread_mutex_t req_lock = PTHREAD_MUTEX_INITIALIZER;
static void* ForMGCopyAnswer(){
  const char* name = "MGCopyAnswer";
  MSImageRef image = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
  void* ptr = MSFindSymbol(image, name);
  if (!ptr) {
    ptr = MSFindSymbol(image, "_MGCopyAnswer");
    if (!ptr) {
      ptr = MSFindSymbol(NULL, "_MGCopyAnswer");
    }
  }
  return ptr;
}
static NSString* GetIMEI(){
  static NSString *imei_str = @"";
  static CFStringRef (*MGCopyAnswer)(CFTypeRef prop);
  if (![imei_str length]) {
    MGCopyAnswer = (CFStringRef(*)(CFTypeRef))ForMGCopyAnswer();
    CFStringRef IMEI;
    IMEI = MGCopyAnswer(kMGInternationalMobileEquipmentIdentity);
    imei_str = @(CFStringGetCStringPtr(IMEI,kCFStringEncodingUTF8));
    NSLog(@"imei:%@",imei_str);
  }
  return imei_str;
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
static NSString* kPref = @"/private/var/preferences/auto_click.plist";
static NSDictionary *fake_device;
static pthread_mutex_t config_mutex = PTHREAD_MUTEX_INITIALIZER;


static CFTypeRef GetConfigValue(NSString* key){
  CFTypeRef result = nil;
  pthread_mutex_lock(&config_mutex);
  while ([fake_device count]==0) {
    NSString *path = kPref;
    fake_device =[NSDictionary dictionaryWithContentsOfFile:path];
  }
  id ssss = [fake_device objectForKey:key];
  if (!ssss) {
    pthread_mutex_unlock(&config_mutex);
    return result;
  }
  result = CFBridgingRetain(ssss);
  pthread_mutex_unlock(&config_mutex);
  return result;
}

static NSString* GetDeviceIdfa(){
  static NSString *idfa_str = @"";
  pthread_mutex_lock(&req_lock);
  if (![idfa_str length]) {
    CFTypeRef aaa;
    aaa = GetConfigValue(@"IDFA");
    idfa_str = @(CFStringGetCStringPtr((CFStringRef)aaa, kCFStringEncodingUTF8));
    NSLog(@"IDFA:%@",idfa_str);
  }
  pthread_mutex_unlock(&req_lock);
  return idfa_str;
}
