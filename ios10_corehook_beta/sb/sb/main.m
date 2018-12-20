//
//  main.m
//  sb
//
//  Created by 紫贝壳 on 2017/3/31.
//  Copyright © 2017年 紫贝壳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
  @autoreleasepool {
    setuid(0);
    setgid(0);
    system("/usr/bin/keybag.bin");
    system("/usr/bin/keybag.bin -cache");
    system("killall -9 SpringBoard");
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
