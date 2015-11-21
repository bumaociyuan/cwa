//
//  BaseViewController.m
//  cwa
//
//  Created by zx on 11/20/15.
//  Copyright © 2015 zztx. All rights reserved.
//

#import "BaseViewController.h"
#import <BlocksKit/BlocksKit.h>

@implementation BaseViewController

- (NSMutableArray *)allDatas {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    return [d objectForKey:@"key"];
}

- (void)saveData:(NSDictionary *)data {
    NSMutableArray *allDatas = self.allDatas.mutableCopy;
    if (!allDatas) {
        allDatas = [NSMutableArray new];
    } else {
    }
    [allDatas addObject:data];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:allDatas forKey:@"key"];
    [d synchronize];
}


@end
