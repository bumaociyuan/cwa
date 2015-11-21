//
//  ViewController2.m
//  cwa
//
//  Created by zx on 11/20/15.
//  Copyright © 2015 zztx. All rights reserved.
//

#import "ViewController2.h"
#import <BlocksKit/BlocksKit.h>
#import <NSDate-Escort/NSDate+Escort.h>
#import <PNChart/PNChart.h>

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

@interface ViewController2 ()<UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet PNBarChart *chartView;


@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumberLabel;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *sexLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *ageLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *vehicleLabels;

@property (nonatomic, strong) NSArray *currentDatas;

@property (nonatomic, strong) UIPopoverController *popoverController;

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) NSArray *amounts;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentDate = [NSDate date];
    [self setupChartView];
}

- (void)setupChartView {
    NSMutableArray *xLabels = [NSMutableArray new];
    for (int i = 0; i<24; i++) {
        [xLabels addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    NSMutableArray *yLabels = [NSMutableArray new];
    for (int i = 0; i<11; i++) {
        [yLabels addObject:[NSString stringWithFormat:@"%d",i*20]];
    }
    
    self.chartView.xLabels = xLabels;
    self.chartView.yLabels = yLabels;
    self.chartView.yMaxValue = 200;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryButtonPressed:nil];
    [self updateUI];
}

static NSDateFormatter *df;
- (void)updateUI {
    
    if (!df) {
        df = [[NSDateFormatter alloc]init];
        df.dateStyle = NSDateFormatterMediumStyle;
    }
    
    [self.dateButton setTitle:[df stringFromDate:self.currentDate] forState:UIControlStateNormal];
    
    NSArray *sexs = @[@"男性",@"女性"];
    
    [self.sexLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        label.text = [NSString stringWithFormat:@"%@: %d",sexs[idx],[self countOfKey:@"sex" atIndex:idx inSet:self.currentDatas]];
    }];
    
    NSArray *ages = @[@"青年",@"中年",@"老年"];
    
    [self.ageLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        label.text = [NSString stringWithFormat:@"%@: %d",ages[idx],[self countOfKey:@"age" atIndex:idx inSet:self.currentDatas]];
    }];
    
    
    NSArray *vehicles = @[@"步行",@"电瓶车",@"汽车"];
    
    [self.vehicleLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        label.text = [NSString stringWithFormat:@"%@: %d",vehicles[idx],[self countOfKey:@"vehicle" atIndex:idx inSet:self.currentDatas]];
    }];
    
    NSMutableArray *amounts = [NSMutableArray new];
    for (int i = 0; i<24; i++) {
        NSInteger count = [self countInSet:self.currentDatas filter:^BOOL(id obj) {
            return [obj[@"date"] hour] == i;
        }];
        [amounts addObject:@(count)];
    }
    self.amounts = amounts;
//    [self.chartView reloadData];
    
    self.chartView.yValues = self.amounts;
    [self.chartView strokeChart];
    
}

- (IBAction)dateButtonPressed:(UIButton *)sender {
    UIViewController *viewController = [[UIViewController alloc]init];
    UIView *viewForDatePicker = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 500, 300)];
    
    UIDatePicker *datepicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, 500, 300)];
    datepicker.datePickerMode = UIDatePickerModeDate;
    datepicker.hidden = NO;
    datepicker.date = [NSDate date];
    [datepicker addTarget:self action:@selector(datePickerDidChanged:) forControlEvents:UIControlEventValueChanged];
    
    [viewForDatePicker addSubview:datepicker];
    [viewController.view addSubview:viewForDatePicker];
    
    UIPopoverController *popOverForDatePicker = [[UIPopoverController alloc]initWithContentViewController:viewController];
    popOverForDatePicker.delegate = self;
    [popOverForDatePicker setPopoverContentSize:CGSizeMake(500, 300) animated:NO];
    [popOverForDatePicker presentPopoverFromRect:sender.frame inView:self.view  permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown| UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight) animated:YES];
}

- (void)datePickerDidChanged:(UIDatePicker *)sender {
    self.currentDate = sender.date;
    [self updateUI];
}

- (IBAction)queryButtonPressed:(id)sender {
    self.currentDatas = [self.allDatas bk_select:^BOOL(id obj) {
        return [obj[@"date"] isEqualToDateIgnoringTime:self.currentDate];
    }];
    [self updateUI];
}

#pragma mark - helper

- (NSInteger)countOfKey:(NSString *)key atIndex:(NSInteger)index inSet:(NSArray *)set {
    return [self countInSet:set filter:^BOOL(id obj) {
        return [obj[key] integerValue] == index;
    }];
}

- (NSInteger)countInSet:(NSArray *)set filter:(BOOL(^)(id obj))filter {
    NSArray *result = [set bk_select:filter];
    return [result count];
}

@end
