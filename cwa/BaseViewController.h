//
//  BaseViewController.h
//  cwa
//
//  Created by zx on 11/20/15.
//  Copyright © 2015 zztx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *allDatas;

- (void)saveData:(NSDictionary *)data;

@end
