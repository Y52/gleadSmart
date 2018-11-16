//
//  Network.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "Network.h"

static Network *_network = nil;

@implementation Network

+ (instancetype)shareNetwork{
    if (_network == nil) {
        _network = [[self alloc] init];
    }
    return _network;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        if (_network == nil) {
            _network = [super allocWithZone:zone];
        }
    });
    return _network;
}

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

@end
