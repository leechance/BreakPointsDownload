//
//  NetAccess.h
//  BreakpointsDownLoad
//
//  Created by Visitor on 3/14/13.
//  Copyright (c) 2013 Visitor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUtil.h"
@interface NetAccess : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>


+ (NetAccess *)sharedNetAccess;
- (void)downLoad:(NSURL *)url;
- (void)stopDownload;

@end
