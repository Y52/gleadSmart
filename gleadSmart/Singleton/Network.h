//
//  Network.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

NS_ASSUME_NONNULL_BEGIN

@interface Network : NSObject

///@brief TCPSocket
@property (nonatomic, strong) GCDAsyncSocket *mySocket;


@end

NS_ASSUME_NONNULL_END
