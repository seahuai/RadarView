//
//  ViewController.m
//  RadarView
//
//  Created by 张思槐 on 2019/1/14.
//  Copyright © 2019 张思槐. All rights reserved.
//

#import "ViewController.h"
#import "RadarView.h"

@interface ViewController ()

@property (nonatomic, strong) RadarView *radarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _radarView = [RadarView new];
    _radarView.backgroundColor = [UIColor whiteColor];
    
    [_radarView setOutLineColor:[[UIColor orangeColor] colorWithAlphaComponent:0.8]
                    shadowColor:[[UIColor redColor] colorWithAlphaComponent:0.3]
                beginInnerColor:[[UIColor orangeColor] colorWithAlphaComponent:0.1]
                  endInnerColor:[[UIColor orangeColor] colorWithAlphaComponent:0.9]];
    
    _radarView.regionCount = 5;
    _radarView.values = @[@(0.6), @(0.25), @(0.5), @(0.8), @(0.3)];
    
    _radarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
    _radarView.center = self.view.center;
    
    [self.view addSubview:_radarView];
    
}


@end
