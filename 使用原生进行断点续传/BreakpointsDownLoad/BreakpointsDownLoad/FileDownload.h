//
//  FileDownload.h
//  broadcast
//
//  Created by he lin on 09-6-12.
//  Copyright 2009 zzvcom. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MovieList;
@interface FileDownload : NSOperation {
	 
	NSString *savedPath;
	 MovieList *info;
	NSFileHandle *fhandle;
	
	NSURLResponse *downloadResponse;
	unsigned long long bytesReceived;
	unsigned long long start;
	
	int primaryKey;
	double percentComplete;
	id delegate;
	SEL downloadComplete;
	NSURLConnection *urlConnection;
	parseclass *pc;
	NSURL *url1;
	NSString *MovieName;
	bool complete;
	int ID;
}
@property(nonatomic,assign)double percentComplete;
@property(nonatomic,assign)int ID;
@property(nonatomic,retain)NSString *MovieName;
@property(nonatomic,retain)NSURL *url1;
@property(nonatomic,retain)parseclass *pc;
-(id)initWithMovieInfo:(MovieList *)minfo;
- (void)setDelegate:(id)aDelegate operation:(SEL)anOperation;
-(void)startDownload;
-(void)stopDownload;
-(NSString*)getDocumentPath;

@property (nonatomic,retain) MovieList *info;
@property (nonatomic,retain) NSString *savedPath;
@property (nonatomic,retain) NSURLResponse *downloadResponse;
@property int primaryKey;
@end
