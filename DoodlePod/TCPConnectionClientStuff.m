//
//  TCPConnectionClientStuff.m
//  DoodlePod
//
//  Created by beacomni on 6/23/17.
//  Copyright © 2017 beacomni. All rights reserved.
//

#import "TCPConnectionClientStuff.h"

@implementation TCPConnectionClientStuff

- (void)openTCPConnection:(NSString*)ipAddress WithPort:(int)portp
{
    uint16_t port = portp;
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    NSError *error = nil;
    
    if (![_tcpSocket connectToHost:ipAddress onPort:port error:&error])
    {
        NSLog(@"Error connecting: %@", error);
        return;
    }
    
    NSLog(@"tcp socket opened");
    
    [_tcpSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    
    return;
}

/*- (void)setRemoteArray:(NSMutableArray *)remoteArray{
    _remoteArray = remoteArray;
}*/

- (void)set_completionHandler:(void (^)(NSString *))completionHandler{
    __completionHandler = completionHandler;
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}


- (void)sendMessage:(NSString *)message
{
    //NSString *strValue = [NSString stringWithFormat:@"%@\r\n", sendTextField.text ];
    NSData *msgData = [message
                       dataUsingEncoding:NSUTF8StringEncoding];
    
    [_tcpSocket writeData:msgData withTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [_tcpSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}


- (NSString *)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    
    __completionHandler(msg);
    [_tcpSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    return msg;
}


- (void) CloseTCPConnection
{
    [_tcpSocket disconnect];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"tcp socket disconnected");
}

@end
