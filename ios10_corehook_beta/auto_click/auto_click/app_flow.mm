#line 1 "/Users/zibeike/Desktop/workspace/ZBK/ios10_corehook_beta/auto_click/auto_click/app_flow.xm"
#import <AdSupport/ASIdentifierManager.h>
#import <AdSupport/AdSupport.h>
#include <sys/sysctl.h>
#import "app_flow_policy.m"
#import "substrate.h"


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class ASIdentifierManager; 


#line 7 "/Users/zibeike/Desktop/workspace/ZBK/ios10_corehook_beta/auto_click/auto_click/app_flow.xm"
static NSUUID* (*_logos_orig$kHookIDFA$ASIdentifierManager$advertisingIdentifier)(_LOGOS_SELF_TYPE_NORMAL ASIdentifierManager* _LOGOS_SELF_CONST, SEL); static NSUUID* _logos_method$kHookIDFA$ASIdentifierManager$advertisingIdentifier(_LOGOS_SELF_TYPE_NORMAL ASIdentifierManager* _LOGOS_SELF_CONST, SEL); 

static NSUUID* _logos_method$kHookIDFA$ASIdentifierManager$advertisingIdentifier(_LOGOS_SELF_TYPE_NORMAL ASIdentifierManager* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    NSString* idfa = nil;
    idfa = GetDeviceIdfa();
    NSLog(@"hook_IDFA: %@",idfa);
    return [[NSUUID alloc] initWithUUIDString:idfa];
}



static __attribute__((constructor)) void _logosLocalCtor_f982ec33(int __unused argc, char __unused **argv, char __unused **envp) {
    NSLog(@"OpenUDID:%@",[OpenUDID value]);
    {Class _logos_class$kHookIDFA$ASIdentifierManager = objc_getClass("ASIdentifierManager"); MSHookMessageEx(_logos_class$kHookIDFA$ASIdentifierManager, @selector(advertisingIdentifier), (IMP)&_logos_method$kHookIDFA$ASIdentifierManager$advertisingIdentifier, (IMP*)&_logos_orig$kHookIDFA$ASIdentifierManager$advertisingIdentifier);}
}
