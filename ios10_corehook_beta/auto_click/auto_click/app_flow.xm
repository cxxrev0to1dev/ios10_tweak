#import <AdSupport/ASIdentifierManager.h>
#import <AdSupport/AdSupport.h>
#include <sys/sysctl.h>
#import "app_flow_policy.m"
#import "substrate.h"

%group kHookIDFA
%hook ASIdentifierManager
- (NSUUID*)advertisingIdentifier {
    NSString* idfa = nil;
    idfa = GetDeviceIdfa();
    NSLog(@"hook_IDFA: %@",idfa);
    return [[NSUUID alloc] initWithUUIDString:idfa];
}
%end
%end

%ctor {
    NSLog(@"OpenUDID:%@",[OpenUDID value]);
    %init(kHookIDFA);
}
