#ifndef MOBILE_GESTALT_H_
#define MOBILE_GESTALT_H_

#include <pthread.h>


static NSString* kPref =
  @"/private/var/preferences/corehook.plist";
static const char* kInitDylib =
  "/Library/MobileSubstrate/MobileSubstrate.dylib";
static const char* kLibMobileGestalt =
  "/usr/lib/libMobileGestalt.dylib";

static FILE* log_file = NULL;
static NSDictionary *fake_device;
static NSArray* executables = nil;
static CFBooleanRef add_executables_filter;
static pthread_mutex_t config_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t var_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t thread_safe_mg = PTHREAD_MUTEX_INITIALIZER;
static NSString* executable = nil;
static int kCounter = 3;

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
  while (result==nil&&kCounter>0){
    result = GetConfigValue(key);
    kCounter = kCounter - 1;
  }
  return result;
}
static bool IsTargetProcess(){
  if (add_executables_filter) {
    if ([executables indexOfObject:executable]!=NSNotFound){
      return true;
    }
    else{
      return false;
    }
  }
  return true;
}
static void Initialize(){
  static bool is_initia = false;
  if (!is_initia) {
    add_executables_filter = kCFBooleanFalse;
    dlopen(kInitDylib, RTLD_LAZY);
    dlopen(kLibMobileGestalt, RTLD_LAZY);
    //pthread_mutex_init(&config_mutex,NULL);
    //pthread_mutex_init(&var_mutex,NULL);
    //pthread_mutex_init(&thread_safe_mg,NULL);
    executable = [[NSBundle mainBundle] bundleIdentifier];
    executables = GetConfigValue(@"Executables");
    CFBooleanRef b = GetConfigValue(@"AddExecutablesFilter");
    add_executables_filter = b;
    is_initia = true;
  }
}

static bool IsRequireUdidString(NSString* data){
  return (data&&[data isEqual:@"UniqueDeviceID"]);
}

static bool IsRequireUdidData(NSString* data){
  bool is_b = [data isEqual:@"UniqueDeviceIDData"];
  bool is_c = [data isEqual:@"nFRqKto/RuQAV1P+0/qkBA"];
  return (data&&(is_b||is_c));
}

CFTypeRef GUdid(void);
static CFTypeRef GSerialNumber(){
  CFTypeRef value = nil;
  pthread_mutex_lock(&var_mutex);
  kCounter = 3;
  value = GetConfigValue(@"SERIAL");
  pthread_mutex_unlock(&var_mutex);
  return value;
}
static CFTypeRef GChip(){
  CFTypeRef value = nil;
  pthread_mutex_lock(&var_mutex);
  kCounter = 3;
  value = GetConfigValue(@"CHIP");
  pthread_mutex_unlock(&var_mutex);
  return value;
}
static CFTypeRef GMacAddr(){
  CFTypeRef value = nil;
  pthread_mutex_lock(&var_mutex);
  kCounter = 3;
  value = GetConfigValue(@"MACADDRESS");
  pthread_mutex_unlock(&var_mutex);
  return value;
}
static CFTypeRef GBlueAddr(){
  CFTypeRef value = nil;
  pthread_mutex_lock(&var_mutex);
  kCounter = 3;
  value = GetConfigValue(@"BLUEADDRESS");
  pthread_mutex_unlock(&var_mutex);
  return value;
}
void MobileGestaltHooker(int arg_warring);

#endif
