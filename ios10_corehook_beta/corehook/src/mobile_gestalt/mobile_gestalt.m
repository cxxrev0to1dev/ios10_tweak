#import <dlfcn.h>
#import <stdio.h>
#import "substrate.h"

#include <sys/sysctl.h>
#include <sys/types.h>
#include <sys/param.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/in.h>
#include <net/if_dl.h>
#include <pthread.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <execinfo.h>
#include <signal.h>
#include <objc/runtime.h>
#include <CoreFoundation/CFData.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreFoundation/CFString.h>
#include <Foundation/NSData.h>
#include <Foundation/Foundation.h>
#include "mobile_gestalt/mobile_gestalt.h"
#include "logger/logger.m"

OBJC_EXPORT const char *object_getClassName(id obj);

CFTypeRef GUdid(void){
  CFTypeRef value_udid = nil;
  NFLog(@"GUdid:%s-%d",__PRETTY_FUNCTION__,__LINE__);
  pthread_mutex_lock(&var_mutex);
  NFLog(@"GUdid:%s-%d",__PRETTY_FUNCTION__,__LINE__);
  kCounter = 3;
  value_udid = GetConfigValue(@"UDID");
  NFLog(@"GUdid:%s-%d",__PRETTY_FUNCTION__,__LINE__);
  pthread_mutex_unlock(&var_mutex);
  NFLog(@"GUdid:%s-%d",__PRETTY_FUNCTION__,__LINE__);
  return value_udid;
}
static BOOL IsArm64()
{
  static BOOL arm64 = NO ;
  static dispatch_once_t once ;
  dispatch_once(&once, ^{
    arm64 = sizeof(int *) == 8 ;
  });
  return arm64 ;
}
static NSData* dataFromHexString(NSString* str) {
  NSString *command = str;
  NSMutableData *commandToSend= [[NSMutableData alloc] init];
  unsigned char whole_byte;
  char byte_chars[3] = {'\0','\0','\0'};
  int i;
  for (i=0; i < [command length]/2; i++) {
    byte_chars[0] = [command characterAtIndex:i*2];
    byte_chars[1] = [command characterAtIndex:i*2+1];
    whole_byte = strtol(byte_chars, NULL, 16);
    [commandToSend appendBytes:&whole_byte length:1];
  }
  //NFLog(@"%@", commandToSend);
  //<xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx>
  NSData *immutableData = [NSData dataWithData:commandToSend];
  return immutableData;
}
static int NumberCountOfString(NSString* str,const char a){
  int count=0;
  int len = (int)[str length];
  for(int i=0;i<len;i++){
    unsigned char c = [str characterAtIndex:0];
    if(c==a){
      count++;
    }
  }
  return count;
}
//////////////////////////////////////////////////////////
//MGCopyAnswer
//////////////////////////////////////////////////////////
static CFTypeRef (*HookNextMGCopyAnswer)(CFTypeRef prop,unsigned long);
static CFTypeRef (*HookMGCopyAnswer)(CFTypeRef prop);
static CFTypeRef CallHookFunc(CFTypeRef prop,unsigned long value){
  CFTypeRef result = nil;
  if (IsArm64()) {
    result = HookNextMGCopyAnswer(prop,value);
    if (result != nil) {
      NFLog(@"hook_FN_MGCopyAnswer_prop_arm64:%@---value:%@-type:%s",
          prop,result,object_getClassName(result));
    }
  }
  else{
    result = HookMGCopyAnswer(prop);
    if (result != nil) {
      NFLog(@"hook_FN_MGCopyAnswer_prop_armv7:%@---value:%@-type:%s",
          prop,result,object_getClassName(result));
    }
  }
  NFLog(@"%s-%d",__PRETTY_FUNCTION__,__LINE__);
  return result;
}
static void CFShowType(CFTypeRef err_test){
  if (err_test) {
    NFLog(@"CFShowType:%@!!!!!!!!!!!!!!!!",
          CFCopyTypeIDDescription(CFGetTypeID(err_test)));
  }
}
static bool IsNil(NSString* aString) {
  return !(aString && aString.length);
}
static bool IsCFData(CFTypeRef data){
  return (CFGetTypeID(data)==CFDataGetTypeID());
}
static bool IsCFString(CFTypeRef data){
  return (CFGetTypeID(data)==CFStringGetTypeID());
}
static CFStringRef ComToStrRef(CFTypeRef data){
  CFStringRef va = nil;
  if (data) {
    va = CFStringCreateWithFormat(NULL,NULL,CFSTR("%@"),data);
  }
  return va;
}
static int GetIdLength(CFTypeRef data){
  NFLog(@"%s-%d",__PRETTY_FUNCTION__,__LINE__);
  CFShowType(data);
  if (!data) {
    NFLog(@"%s-%d",__PRETTY_FUNCTION__,__LINE__);
    return 0;
  }
  if (CFGetTypeID(data)==CFStringGetTypeID()){
    NFLog(@"%s-%d",__PRETTY_FUNCTION__,__LINE__);
    CFIndex len = CFStringGetLength((__bridge CFStringRef)data);
    return (int)len;
  }
  else if (CFGetTypeID(data) == CFDataGetTypeID()){
    NFLog(@"%s-%d",__PRETTY_FUNCTION__,__LINE__);
    CFIndex len = CFDataGetLength((__bridge CFDataRef)data);
    return (int)len;
  }
  else{
    NFLog(@"%s-%d",__PRETTY_FUNCTION__,__LINE__);
    return 0;
  }
}
static CFTypeRef MobileDeviceProp(NSString* ns_prop,
                                  CFTypeRef result){
  NFLog(@"hook_device_info: %@--->%@",ns_prop,result);
  bool is_eq = [ns_prop isEqual:@"SerialNumber"];
  bool is_eq_a = [ns_prop isEqual:@"VasUgeSzVyHdB27g2XpN0g"];
  NFLog(@"CFProp:%s-%d",__PRETTY_FUNCTION__,__LINE__);
  if (is_eq||is_eq_a) {
    NFLog(@"CFProp:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    CFStringRef data = nil;
    NFLog(@"CFProp:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    data = ComToStrRef(GSerialNumber());
    NFLog(@"CFProp:%s-%d-%@",__PRETTY_FUNCTION__,__LINE__,
          data);
    CFShowType(data);
    NFLog(@"CFProp:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    if (data&&GetIdLength(data)>0) {
      NFLog(@"hook_serial_number:%@--->%@!!!!!!",result,data);
      CFRelease(result);
      result = data;
    }
    else{
      NFLog(@"CFProp:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    }
    
    return result;
  }
  NFLog(@"CFProp:%s-%d",__PRETTY_FUNCTION__,__LINE__);
  is_eq = [ns_prop isEqual:@"TF31PAB6aO8KAbPyNKSxKA"];
  if (is_eq) {
    int64_t i1 = 0;
    CFNumberRef chip = nil;
    chip = GChip();
    CFShowType(chip);
    if (chip) {
      CFNumberGetValue(chip, kCFNumberSInt64Type, &i1);
      if (i1>0) {
        NFLog(@"hook_chip_identificati:%@--->%@!!!!",result,chip);
        CFRelease(result);
        result = chip;
      }
    }
    
    return result;
  }
  NFLog(@"CFProp:%s-%d",__PRETTY_FUNCTION__,__LINE__);
  is_eq = [ns_prop isEqual:@"gI6iODv8MZuiP0IA+efJCw"];
  if (is_eq) {
    CFStringRef data = nil;
    data = ComToStrRef(GMacAddr());
    CFShowType(data);
    if (data&&GetIdLength(data)>0) {
      NFLog(@"hook_wifi_address:%@--->%@!!!!!!",result,data);
      CFRelease(result);
      result = data;
    }
    
    return result;
  }
  NFLog(@"CFProp:%s-%d",__PRETTY_FUNCTION__,__LINE__);
  is_eq = [ns_prop isEqual:@"k5lVWbXuiZHLA17KGiVUAA"];
  if (is_eq) {
    CFStringRef data = nil;
    data = ComToStrRef(GBlueAddr());
    CFShowType(data);
    if (data&&GetIdLength(data)>0) {
      NFLog(@"hook_blue_address:%@--->%@!!!!!!",result,data);
      CFRelease(result);
      result = data;
    }
    
    return result;
  }
  else{
    NFLog(@"%s-%d",__PRETTY_FUNCTION__,__LINE__);
    return result;
  }
}
static CFTypeRef FiltedDeviceProp(CFTypeRef prop,
                                  unsigned long value){
  /*if (prop==nil) {
    return CallHookFunc(prop,value);
  }
  if (CFGetTypeID(prop)!=CFStringGetTypeID()) {
    return CallHookFunc(prop,value);
  }*/
  CFTypeRef result = CallHookFunc(prop,value);
  if(!result||!(IsCFString(result)||(IsCFData(result)))){
    if (result) {
      NFLog(@"failed:%s-%d-%@-%@",__PRETTY_FUNCTION__,__LINE__,result,
            CFCopyTypeIDDescription(CFGetTypeID(result)));
    }
    else{
      NFLog(@"failed:%s-%d-%@",__PRETTY_FUNCTION__,__LINE__,result);
    }
    return result;
  }
  NFLog(@"parameter check ok:%@-%@-%@",result,prop,CFCopyTypeIDDescription(CFGetTypeID(result)));
  const char* ns_prop_1 = CFStringGetCStringPtr(prop,kCFStringEncodingUTF8);
  NSString* ns_prop = @(ns_prop_1);
  if(IsCFString(result)&&IsRequireUdidString(ns_prop)){
    NFLog(@"CFString:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    CFTypeRef udid_ref = GUdid();
    if (!udid_ref) {
      NFLog(@"failed:%s-%d",__PRETTY_FUNCTION__,__LINE__);
      return result;
    }
    const char* ss = CFStringGetCStringPtr(udid_ref,kCFStringEncodingUTF8);
    if (!ss||!ss[0]) {
      NFLog(@"failed:%s-%d",__PRETTY_FUNCTION__,__LINE__);
      CFRelease(udid_ref);
      return result;
    }
    NFLog(@"hook_udid success: %@--->%s",result,ss);
    NFLog(@"CFString:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    if (udid_ref) {
      CFRelease(udid_ref);
    }
    result = __CFStringMakeConstantString(ss);
    return result;
  }
  if (IsCFData(result)&&IsRequireUdidData(ns_prop)){
    NFLog(@"CFData:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    CFTypeRef udid_ref = nil;
    udid_ref = GUdid();
    NFLog(@"CFData:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    if (!udid_ref) {
      NFLog(@"failed:%s-%d",__PRETTY_FUNCTION__,__LINE__);
      return result;
    }
    NFLog(@"CFData:%s-%d-%@",__PRETTY_FUNCTION__,__LINE__,udid_ref);
    const char* ss = CFStringGetCStringPtr(udid_ref,kCFStringEncodingUTF8);
    if (!ss||!ss[0]) {
      NFLog(@"failed:%s-%d",__PRETTY_FUNCTION__,__LINE__);
      CFRelease(udid_ref);
      return result;
    }
    NFLog(@"CFData:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    NSString* s1 = @(ss);
    if (s1&&[s1 length]<=0) {
      NFLog(@"failed:%s-%d",__PRETTY_FUNCTION__,__LINE__);
      CFRelease(udid_ref);
      return result;
    }
    NSData* d1 = dataFromHexString(s1);
    if (d1&&[d1 length]>0) {
      CFRelease(result);
      const UInt8 *bytes = [d1 bytes];
      const CFIndex length = [d1 length];
      result = CFDataCreate(NULL,bytes,length);
    }
    NFLog(@"hook_udid_nsdata_a1: %@--->%@",result,d1);
    NFLog(@"CFData:%s-%d",__PRETTY_FUNCTION__,__LINE__);
    if (udid_ref){
      CFRelease(udid_ref);
    }
    return result;
  }
  return result;
  return MobileDeviceProp(prop,result);
}
static CFTypeRef FN_NextMGCopyAnswer(
                                     CFTypeRef prop,
                                     unsigned long value){
  CFTypeRef result = nil;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  if (prop==nil) {
    result = HookNextMGCopyAnswer(prop,value);
  }
  else{
    result = FiltedDeviceProp(prop,value);
  }
  [pool release];
  return result;
}
static CFTypeRef FN_MGCopyAnswer(CFTypeRef prop){
  CFTypeRef result = nil;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  if (prop==nil) {
    result = HookMGCopyAnswer(prop);
  }
  else{
    result = FiltedDeviceProp(prop,0);
  }
  [pool release];
  return result;
}
//////////////////////////////////////////////////////////
//MGCopyMultipleAnswers
//////////////////////////////////////////////////////////
static CFPropertyListRef (*HookMGCopyMultipleAnswers)(CFArrayRef questions, int unknown0);
static CFPropertyListRef FnMGCopyMultipleAnswers(
                                                 CFArrayRef questions, int unknown0){
  NFLog(@"FnMGCopyMultipleAnswers!!!!");
  return HookMGCopyMultipleAnswers(questions,unknown0);
}
//////////////////////////////////////////////////////////
//hook function impl
//////////////////////////////////////////////////////////
static void MGCopyAnswerHookImpl(const void* ptr){
  HookMGCopyAnswer = NULL;
  HookNextMGCopyAnswer = NULL;
  if (IsArm64()) {
    MSHookFunction(((void*)((unsigned long)ptr + 8)),
                   (void*)FN_NextMGCopyAnswer,
                   (void**)&HookNextMGCopyAnswer);
    if(HookNextMGCopyAnswer!=NULL){
      NFLog(@"HookNextMGCopyAnswer success.");
    }
    else{
      NFLog(@"HookNextMGCopyAnswer failed.");
    }
  }
  else{
    MSHookFunction((void*)((unsigned long)ptr),
                   (void*)FN_MGCopyAnswer,
                   (void**)&HookMGCopyAnswer);
    if(HookMGCopyAnswer!=NULL){
      NFLog(@"HookMGCopyAnswer success.");
    }
    else{
      NFLog(@"HookMGCopyAnswer failed.");
    }
  }
}
static void MGCopyMultipleAnswersImpl(const void* ptr){
  HookMGCopyMultipleAnswers = NULL;
  MSHookFunction((void*)((unsigned long)ptr),
                 (void*)FnMGCopyMultipleAnswers,
                 (void**)&HookMGCopyMultipleAnswers);
  if(HookMGCopyMultipleAnswers!=NULL){
    NFLog(@"HookMGCopyMultipleAnswers success.");
  }
  else{
    NFLog(@"HookMGCopyMultipleAnswers failed.");
  }
}
//////////////////////////////////////////////////////////
//hook method impl
//////////////////////////////////////////////////////////
static void* (*old_dlsym)(void* handle,const char* symbol);
static void* newdlsym(void* handle,const char* symbol)
{
  //NFLog(@"debug:%s!!!!!!!!!!!!!!!!",__func__);
  void *p = NULL;
  if (old_dlsym!=NULL) {
    p = old_dlsym(handle,symbol);
  }
  if (p==NULL||symbol==NULL) {
    return p;
  }
  else if(!strcmp(symbol,"MGCopyAnswer")){
    NFLog(@"OK:%p!!!!!!!!!!!!!!!!!!",p);
    MGCopyAnswerHookImpl(p);
  }
  return p;
}
static void HookDlsym(){
  NFLog(@"OK_dlsym!!!!!!!!!!!!!!!!!!");
  MSHookFunction((void*)dlsym,
                 (void*)newdlsym,
                 (void**)&old_dlsym);
}
static void HookerForMGCopyAnswer(){
  const char* name = "MGCopyAnswer";
  MSImageRef image = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
  const void* ptr = MSFindSymbol(image, name);
  if (!ptr) {
    ptr = MSFindSymbol(image, "_MGCopyAnswer");
    if (!ptr) {
      ptr = MSFindSymbol(NULL, "_MGCopyAnswer");
    }
  }
  if (ptr!=NULL) {
    NFLog(@"MGCopyAnswer found:%p",ptr);
    NFAddr(ptr);
    MGCopyAnswerHookImpl(ptr);
    return;
  }
  else{
    NFLog(@"MGCopyAnswer failed:%p",ptr);
    HookDlsym();
    return;
  }
}
static void HookerForMGCopyMultipleAnswers(){
  NFLog(@"%s-%d",__PRETTY_FUNCTION__,__LINE__);
  const char* name = "_MGCopyMultipleAnswers";
  const void* ptr = MSFindSymbol(NULL, name);
  if (ptr!=NULL) {
    NFLog(@"_MGCopyMultipleAnswers found:%p",ptr);
    MGCopyMultipleAnswersImpl(ptr);
    return;
  }
  HookDlsym();
}
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

void MobileGestaltHooker(int arg_warring){
  NFLog(@"%s-%d",__PRETTY_FUNCTION__,__LINE__);
  HookerForMGCopyAnswer();
}
