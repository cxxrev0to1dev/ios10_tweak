#include <Foundation/Foundation.h>
#include "HookUtil.h"
#include "Macro.h"
#include <Foundation/NSJSONSerialization.h>

@interface IKAppDocument
- (NSMutableDictionary*)impressions;
@end
@interface IKDOMDocument
- (void)setItmlIDSequence:(unsigned long long)arg1;
@end

HOOK_MESSAGE(NSMutableDictionary*,IKAppDocument,impressions)
{
  NSMutableDictionary* result;
  //result = _IKAppDocument_impressions(self,sel);
  result = [[NSMutableDictionary alloc] init];
  return result;
}
//- (void)setITMLIDForNode:(id)arg1;
HOOK_MESSAGE(void,IKDOMDocument,setItmlIDSequence,
             unsigned long long arg1)
{
  _IKDOMDocument_setItmlIDSequence(self,sel,0);
}
