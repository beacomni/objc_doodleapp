//
//  TCPConnectionClientStuff.h
//  DoodlePod
//
//  Created by beacomni on 6/23/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface TCPConnectionClientStuff : NSObject <GCDAsyncSocketDelegate>

@property GCDAsyncSocket *tcpSocket;
- (void)openTCPConnection:(NSString*)ipAddress WithPort:(int)portp;
- (void)socketDidSecure:(GCDAsyncSocket *)sock;
- (void)sendMessage:(NSString *)message;
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag;
- (NSString *)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
- (void) CloseTCPConnection;
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
- (void)set_completionHandler:(void (^)(NSString *))completionHandler;

@property(strong,nonatomic) void (^_completionHandler)(NSString *);

@end
