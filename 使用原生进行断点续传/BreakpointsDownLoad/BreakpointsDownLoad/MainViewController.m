//
//  MainViewController.m
//  BreakpointsDownLoad
//
//  Created by Visitor on 3/14/13.
//  Copyright (c) 2013 Visitor. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    NetAccess *_netAccess;
    BOOL _isSuspend;
    UIButton *_suspendBtn;
    UIProgressView *_downLoadProgressView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _netAccess = [NetAccess sharedNetAccess];
    _isSuspend = NO;
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    startBtn.frame = CGRectMake(10, 10, 100, 30);
    [startBtn setTitle:@"开始下载" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    startBtn.tag = 0;
    [self.view addSubview:startBtn];
    
    _suspendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _suspendBtn.frame = CGRectMake(10, 50, 100, 30);
    [_suspendBtn setTitle:@"暂停下载" forState:UIControlStateNormal];
    [_suspendBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _suspendBtn.tag = 1;
    [self.view addSubview:_suspendBtn];
    
    _downLoadProgressView = [[UIProgressView alloc] init];
    _downLoadProgressView.frame = CGRectMake(10, 100, 300, 30);
    [self.view addSubview:_downLoadProgressView];
}

- (void)btnClick:(UIButton *)btn
{
    
    if(btn.tag == 0)
    {
        NSLog(@"开始下载");
        [_netAccess downLoad:[NSURL URLWithString:@"http://192.168.88.8/download/cityprotector.tar.bz2"]];
    }
    else if(btn.tag == 1)
    {
        if(_isSuspend)
        {
            NSLog(@"继续下载");
            [_suspendBtn setTitle:@"暂停下载" forState:UIControlStateNormal];
            [_netAccess downLoad:[NSURL URLWithString:@"http://192.168.88.8/download/cityprotector.tar.bz2"]];
        }
        else
        {
            NSLog(@"暂停下载");
            [_suspendBtn setTitle:@"继续下载" forState:UIControlStateNormal];
            //[_netAccess suspendDownLoad];
            [_netAccess stopDownload];
        }
        _isSuspend = !_isSuspend;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
