//
//  ViewController1.m
//  cwa
//
//  Created by zx on 11/20/15.
//  Copyright © 2015 zztx. All rights reserved.
//

#import "ViewController1.h"

@interface ViewController1 ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *amount;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sex;
@property (weak, nonatomic) IBOutlet UISegmentedControl *age;
@property (weak, nonatomic) IBOutlet UISegmentedControl *vehicle;

@end

@implementation ViewController1

- (IBAction)save:(id)sender {
    NSMutableDictionary *dic = [NSMutableDictionary new];
//    dic[@"amount"] = self.amount.selectedSegmentIndex
    dic[@"sex"] = @(self.sex.selectedSegmentIndex);
    dic[@"age"] = @(self.age.selectedSegmentIndex);
    dic[@"vehicle"] = @(self.vehicle.selectedSegmentIndex);
    dic[@"date"] = [NSDate date];
    [self saveData:dic];
}


@end
