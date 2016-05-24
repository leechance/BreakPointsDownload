//
//  NetAccess.m
//  BreakpointsDownLoad
//
//  Created by Visitor on 3/14/13.
//  Copyright (c) 2013 Visitor. All rights reserved.
//

#import "NetAccess.h"

@implementation NetAccess
{
    // 下载文件存储目录
	NSString *_docPath;
    // 下载文件临时存储目录
    NSString *_docTempPath;
    // 写入文件对象
	NSFileHandle *_fileHandle;
	
	NSURLResponse *_downloadResponse;
	
    // 下载起始大小
	unsigned long long _downLoadStartBytes;
    // 已经下载的字节数
    unsigned long long _downLoadReceivedBytes;
	
	int _primaryKey;
    // 接收数据大小比例
	double _downLoadPercent;
	id _delegate;
	SEL _downloadComplete;
    // 请求连接
	NSURLConnection *_urlConnection;
	NSURL *_url1;
	NSString *_MovieName;
	BOOL _complete;
	int _ID;
}

static NetAccess *_sharedNetAccess;
+ (NetAccess *)sharedNetAccess
{
    if(!_sharedNetAccess)
    {
        _sharedNetAccess = [[NetAccess alloc] init];
    }
    return _sharedNetAccess;
}

- (void)downLoad:(NSURL *)url
{
    _docPath = [AppUtil getDocPath];
    _docTempPath = [AppUtil getDocTempPath];
    _downLoadStartBytes = 0;
     NSLog(@"temp文件夹位置 - %@",_docTempPath);
    // 判断临时存储文件夹是否存在，不存在就创建
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:_docTempPath])
    {
        [fileManager createDirectoryAtPath:_docTempPath withIntermediateDirectories:YES attributes:nil error:nil];
       
    }

    // 实例化一个请求：设置路径、缓存方式、超时连接准许时间
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    // 设置下载临时文件的文件名
    NSString *downLoadTempFileName = [NSString stringWithFormat:@"%@File",_docTempPath];
    
    // 判断是否有下载文件（如果有代表之前没有下载完成）
    BOOL _isHaveTempFile;
    if([fileManager fileExistsAtPath:downLoadTempFileName])
    {
        // 如果需要断点续传，首先要从文件属性字典中取出文件已下载的数据长度
        NSDictionary *fileAttribute = [fileManager attributesOfItemAtPath:downLoadTempFileName error:nil];
        if(fileAttribute != nil)
        {
            // 取得文件大小
            NSNumber *fileSize = [fileAttribute objectForKey:NSFileSize];
            // 设置本次下载起始大小
            _downLoadStartBytes = [fileSize unsignedLongLongValue];
            NSLog(@"已经下载文件大小 = %llu",_downLoadStartBytes);
        }
        _isHaveTempFile = YES;
    }
    else
    {
        // 如果没有临时下载文件，创建临时下载文件
        [fileManager createFileAtPath:downLoadTempFileName contents:nil attributes:nil];
        _isHaveTempFile = NO;
    }
    
    // 如果要写文件，首先创建”文件写入对象“，目的是将来要追加数据
    _fileHandle = [[NSFileHandle fileHandleForWritingAtPath:downLoadTempFileName] retain];
    // 如果有临时文件，需要继续下载
    if(_isHaveTempFile)
    {
        // 断点续传需要给请求头中告诉服务器从多少大小开始下载。所以需要加入文件大小于RANGE中(%qu为lonlongvalue类型)
        [request addValue:[NSString stringWithFormat:@"bytes=%qu-",_downLoadStartBytes] forHTTPHeaderField:@"RANGE"];
    }
    
    
    
    // 开始连接
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

// 开始下载前，接到的服务器响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"~~接收连接响应~~");
    _downLoadReceivedBytes = _downLoadStartBytes;
    _downloadResponse = response;
    [_downloadResponse retain];
    
}

// 接受到数据时候响应(反复刷新)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"==接收数据中==");
    
    
    
    NSLog(@"需要下载大小 = %llu",[_downloadResponse expectedContentLength]);
    // 文件总大小 = 响应头中预期要接收的 + 已经接收的
    unsigned long long expectedLength = [_downloadResponse expectedContentLength]+_downLoadStartBytes;
    // 已接收的数据大小 = 之前接收的数据大小 + 当前接收的数据大小
    _downLoadReceivedBytes = _downLoadReceivedBytes + [data length];
    // 判断一下，如果总文件大小不是未知的
    if(expectedLength != NSURLResponseUnknownLength)
    {
        // 接收比例 = 已接收数据大小 / 需要接收数据大小
        _downLoadPercent = _downLoadReceivedBytes / (double)expectedLength;
        // 跳转到文件最后
        [_fileHandle seekToEndOfFile];
        // 将刚刚接收的数据写入到文件
        [_fileHandle writeData:data];
        NSLog(@"已下载:%f",_downLoadPercent*100);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
    [_fileHandle closeFile];
    [_fileHandle release];
    NSLog(@"下载失败！");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_fileHandle closeFile];
    [_fileHandle release];
    [connection release];
    NSLog(@"下载完成!");
}

- (void)stopDownload
{
	//[myRequest cancel];
	//[myRequest release];
    [_urlConnection cancel];
	[_fileHandle closeFile];
	[_fileHandle release];
}

@end


































