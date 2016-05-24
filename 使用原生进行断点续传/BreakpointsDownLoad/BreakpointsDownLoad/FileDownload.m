//
//  FileDownload.m
//  broadcast
//
//  Created by he lin on 09-6-12.
//  Copyright 2009 zzvcom. All rights reserved.
//

#import "FileDownload.h"
#import "xiazai.h"

@implementation FileDownload
@synthesize primaryKey,info,savedPath,downloadResponse;
@synthesize pc,url1,MovieName,ID,percentComplete;

-(id)initWithMovieInfo:(MovieList *)minfo{
	if (self = [super init]) {
		self.downloadResponse=nil;
		//设置文件下载到保存到指定的文件夹中
		self.savedPath=[NSString stringWithFormat:@"%@/downloads/",[self getDocumentPath]];
		self.info=minfo;
		start=0;
		//启动下载
		
	}
	return self;
}
-(void)main{
	[self startDownload];
	while (!complete) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]; 
	}
	NSLog(@"wwwwwwwdwwwwwwwwwwwwwwwww");
}
-(NSString*)getDocumentPath{ 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
			return nil;
	}
	return documentsDirectory;	
}
//启动下载
-(void)startDownload{
		//如果下载目录（文件夹）不存在，就创建文件准备下载数据
	if(![[NSFileManager defaultManager] fileExistsAtPath:self.savedPath]){
		//创建一个指定目录（文件夹）
		//[[NSFileManager defaultManager] createDirectoryAtPath:self.savedPath attributes:nil];
		[[NSFileManager defaultManager] createDirectoryAtPath:savedPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	BOOL fileAvalible;
	//请求服务器的资源的地址
	NSURL *url=[NSURL URLWithString:pc.PlayURL];
	//创建请求方式
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
	
	//指定下载文件的文件名（绝对路径）
	NSString *fullPath=[NSString stringWithFormat:@"%@%@",self.savedPath,@"乡村.m4v"];
	
	//如果下载的文件已经存在，表示之前没有下载完
	if([[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
		//如果想接着下，则首先从文件属性字典中取出此文件已经下载的数据长度，以备断点续传
		//取出本文件的“属性字典”
		//NSDictionary *attrib=[[NSFileManager defaultManager] fileAttributesAtPath:fullPath traverseLink:YES];
		NSDictionary *attrib=[[NSFileManager defaultManager]  attributesOfItemAtPath:fullPath error:nil];
		if(attrib!=nil){
			NSNumber *size;
			//取得文件的大小，NSFileSize是文件默认大小KEY
			if (size=[attrib objectForKey:NSFileSize]) {
				fileAvalible=YES;
				//记录从哪个位置开始接着下载数据
				start=[size unsignedLongLongValue];
			}       
		}
	}else{
		[[Database creat]edit:[NSString stringWithFormat:@"insert into movie (MovieName,state,percentComplete,savePath) values ('%@',0,'%g','%@')",pc.MovieName,percentComplete,savedPath]];
		self.ID=[[Database creat]selectMaxId];
		//文件不存在，就创建此文件，直接装载数据
		[[NSFileManager defaultManager] createFileAtPath:fullPath contents:nil attributes:nil];
		fileAvalible=NO;
	}
    //如果要写文件，首先要创建“文件写入对象”，主要目的是将来要追加数据用的
	fhandle=[[NSFileHandle fileHandleForWritingAtPath:fullPath] retain];
	//针对于已经有数据的文件，希望接着下，才追加下面的信息
	if(fileAvalible){
		//给“请求方式对象“追加信息，告诉服务器从哪里开始下,%qu表示longlongvalue
		[theRequest addValue:[NSString stringWithFormat:@"bytes=%qu-",start] forHTTPHeaderField:@"RANGE"];
	}
	//用指定的请求方式(theRequest)来正式启动连接的
	
	//这样连接请求方式内部实现就是"异步方式"
	urlConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	NSLog(@"11111111111111");
}
//在开始下载之前，客户端会首先接受到服务器的响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSLog(@"接受连接响应。。。。。");
	
	bytesReceived=start;
    self.downloadResponse=response;//downloadResponse保存http服务器响应的数据信息，在下面的方法中用到
} 

//系统方法，接收数据时响应（反复调用）
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSLog(@"接受数据。。。。。。");
	//start为已经接收的，加上http响应头中预期要接收的=文件总大小
	unsigned long long expectedLength=[self.downloadResponse expectedContentLength]+start;
	//之前已经接收的+新接收的数据=已经接受的数据
	bytesReceived=bytesReceived+[data length];
	if (expectedLength != NSURLResponseUnknownLength) {
		//已经接收的/要接受的= 比例（可以计算进度条）
        percentComplete=bytesReceived/(double)expectedLength;
				//跳转到文件最后
		[fhandle seekToEndOfFile];
		//将刚接受的数据写入到文件
		[fhandle writeData:data];
		//int a=[[Database creat]selectMaxId];
		[[Database creat]edit:[NSString stringWithFormat:@"update movie set percentComplete='%g'  where ID=%d;",percentComplete,self.ID]];
        NSLog(@"Percent complete - %f",percentComplete);
    }
	
}

//系统方法，连接失败的处理
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[connection release];
	[fhandle closeFile];
	[fhandle release];
	[self startDownload];
}
	
//系统方法，连接完成时处理
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
		[[Database creat]edit:[NSString stringWithFormat:@"update movie set state=2 where ID=%d;",self.ID]];
	[delegate performSelector:@selector(downloadComplete:) withObject:self];
	complete=YES;
	//UINavigationController *nav=(UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:3];
//	xiazai *xz=[nav.viewControllers objectAtIndex:0];
//	[xz.tab reloadData];
	
	[fhandle closeFile];
	[fhandle release];
	[connection release];
	NSLog(@"%@",@"downloadDidFinish");
}

- (void)setDelegate:(id)aDelegate operation:(SEL)anOperation{
	 
	delegate = aDelegate;
	downloadComplete = anOperation;
}

-(void)stopDownload{
	//[myRequest cancel];
	//[myRequest release];
	
	[fhandle closeFile];
	[fhandle release];
}

-(void)dealloc{
	self.downloadResponse=nil;
	self.savedPath=nil;
	self.info=nil;
	[super dealloc];
}
@end
