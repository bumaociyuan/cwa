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
#import <JBChartView/JBBarChartView.h>
#import <PNChart/PNChart.h>

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]
#define kJBColorBarChartBarGreen UIColorFromHex(0x34b234)
#define kJBColorBarChartBarBlue UIColorFromHex(0x08bcef)


@interface ViewController2 ()<UIPopoverControllerDelegate,JBBarChartViewDataSource,JBBarChartViewDelegate>

@property (weak, nonatomic) IBOutlet JBBarChartView *chartView;


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
    self.chartView.dataSource = self;
    self.chartView.delegate = self;
    
    [self setupTimeLabels];
}

- (void)setupTimeLabels {
    CGFloat width = CGRectGetWidth(self.chartView.frame)/24;
    for (int i = 0; i<24; i++) {
        UILabel *label = [UILabel new];
        label.text = [NSString stringWithFormat:@"%d:00",i];
        label.font = [UIFont systemFontOfSize:8];
        CGRect frame = CGRectMake(CGRectGetMinX(self.chartView.frame)+i*width, CGRectGetMaxY(self.chartView.frame)+8, width, 20);
        label.frame = frame;
        [self.view addSubview:label];
    }
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
    [self.chartView reloadData];
    
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

#pragma mark - JBBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return 24; // number of bars in chart
}

- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index {
    return (index % 2 == 0) ? kJBColorBarChartBarBlue : kJBColorBarChartBarGreen;
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
{
    CGFloat count = [self.amounts[index] floatValue];
    if (!count) {
        count = 1.00f;
    }
    return 20 * count; // height of bar at index
}

#pragma mark - JBBarChartViewDelegate

- (CGFloat)barPaddingForBarChartView:(JBBarChartView *)barChartView {
    return 5;
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
