//
//  NetAccess.m
//  BreakPointsDownload
//
//  Created by Visitor on 3/13/13.
//  Copyright (c) 2013 Visitor. All rights reserved.
//

#import "NetAccess.h"
#import "AppUtil.h"
static NetAccess *_sharedNetAccess;

@implementation NetAccess
{
    // 网络消息队列
    ASINetworkQueue *_queue;
    NSString *_docPath;
    NSString *_docTempPath;
    UIProgressView *_pv;
    ASIHTTPRequest *_request;
}


- (void)dealloc
{
    [_queue release];
    [_pv release];
    [_request release];
    [super dealloc];
}


+ (NetAccess *)sharedNetAccess
{
    if(!_sharedNetAccess)
    {
        _sharedNetAccess = [[NetAccess alloc] init];
    }
    return _sharedNetAccess;
}

- (void)downLoad:(NSURL *)url andProgressView:(UIProgressView *)pv
{
    // 实例化消息队列
//    _queue = [[ASINetworkQueue alloc] init];
//    [_queue reset];
//    [_queue setShowAccurateProgress:YES];
//    [_queue go];
    
    _pv = pv;
    
    // 实例化请求
	_request = [[ASIHTTPRequest alloc] initWithURL:url];
	_request.delegate = self;
    
    // 下载完成文件路径
    _docPath = [AppUtil getDocPath];
    // 下载临时文件路径
	_docTempPath = [AppUtil getDocTempPath];
	
    //创建文件管理器
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//判断Documents文件夹目录下的temp文件夹是否存在
	if (![fileManager fileExistsAtPath:_docTempPath])
    {
        // 如果不存,创建一个temp文件夹,因为下载时,不会自动创建文件夹
        [fileManager createDirectoryAtPath:_docTempPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
	}
    
    // 下载完成后文件保存路径
	NSString *savePath = [_docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"DownLoadData"]];
	// 下载中临时文件保存路径
	NSString *tempPath = [_docTempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"DownLoadTemp"]];
	// 设置文件保存路径
	[_request setDownloadDestinationPath:savePath];
    NSLog(@"文件保存路径:%@",savePath);
	// 设置临时文件路径
	[_request setTemporaryFileDownloadPath:tempPath];
    NSLog(@"文件临时保存路径:%@",tempPath);
    // 设置进度条的代理
	[_request setDownloadProgressDelegate:_pv];
	// 设置是是否支持断点下载
	[_request setAllowResumeForFileDownloads:YES];
	// 设置下载文件的基本信息
	[_request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"DownLoadID",nil]];
    NSLog(@"UserInfo=%@",_request.userInfo);
    
    
    [_request startAsynchronous];
	// 添加到ASINetworkQueue队列去下载
//	[_queue addOperation:request];


}

// 暂停下载
- (void)suspendDownLoad
{
//    for (ASIHTTPRequest *request in [_queue operations])
//    {
//        if([[request.userInfo objectForKey:@"DownLoadID"] intValue] == 1)
//        {
            // 暂停下载
            [_request clearDelegatesAndCancel];
//        }
//    }
}

// ASIHTTPRequestDelegate,下载之前获取信息的方法,主要获取下载内容的大小，可以显示下载进度多少字节
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
	NSLog(@"didReceiveResponseHeaders-%@",[responseHeaders valueForKey:@"Content-Length"]);
    NSLog(@"下载内容大小contentlength=%f",request.contentLength/1024.0/1024.0);
    
    int downLoadID = [[request.userInfo objectForKey:@"downLoadID"] intValue];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    float tempConLen = [[userDefaults objectForKey:[NSString stringWithFormat:@"ipaID:%d---contentLength",downLoadID]] floatValue];
    NSLog(@"tempConLen=%f",tempConLen);
    //如果没有保存,则持久化他的内容大小
    if (tempConLen == 0 ) {//如果没有保存,则持久化他的内容大小
        [userDefaults setObject:[NSNumber numberWithFloat:request.contentLength/1024.0/1024.0] forKey:[NSString stringWithFormat:@"downLoadID:%d---contentLength",downLoadID]];
        [userDefaults synchronize];
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    int downLoadID = [[request.userInfo objectForKey:@"downLoadID"] intValue];
    NSLog(@"DownLoadID:%d 下载完成",downLoadID);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"下载失败");
    _pv.progress = 0.0;
}

@end













