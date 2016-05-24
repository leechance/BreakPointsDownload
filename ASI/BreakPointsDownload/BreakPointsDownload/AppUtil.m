//
//  AppUtil.m
//  BreakPointsDownload
//
//  Created by Visitor on 3/13/13.
//  Copyright (c) 2013 Visitor. All rights reserved.
//

#import "AppUtil.h"

@implementation AppUtil
+ (NSString *)getDocPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}
+ (NSString *)getDocTempPath
{
    return [NSString stringWithFormat:@"%@/temp",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
}
@end
