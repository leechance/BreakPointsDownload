//
//  NetAccess.h
//  BreakPointsDownload
//
//  Created by Visitor on 3/13/13.
//  Copyright (c) 2013 Visitor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
@interface NetAccess : NSObject<ASIHTTPRequestDelegate>
+ (NetAccess *)sharedNetAccess;
- (void)downLoad:(NSURL *)url andProgressView:(UIProgressView *)pv;
- (void)suspendDownLoad;
@end
