//
//  main.m
//  IMServer
//
//  Created by 珲少 on 2019/11/29.
//  Copyright © 2019 jaki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

static NSString *kIMProtocolHeaderLogin = @"login";  // userName
static NSString *kIMProtocolHeaderSendMsg = @"msg";  // content
static NSString *kIMProtocolHeaderLogout = @"logout";// userName
static NSString *kIMProtocolHeaderNotification = @"notification";
static NSString *kIMProtocolHeaderFriendList = @"firend"; // id:id:id
static int const kMaxConnectCount = 5;
void startSetupClient(int server);
void recvFromClient(int client);
void handleMsg(int client, NSString *str);
NSMutableDictionary<NSNumber *, NSString *> *loginMap;
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        loginMap = [NSMutableDictionary dictionary];
        // 协议域 类型 传输协议
        int server = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
        if (server == -1) {
            NSLog(@"创建连接失败");
        } else {
            // 绑定地址和端口
            struct sockaddr_in server_addr;
            server_addr.sin_len = sizeof(struct sockaddr_in);
            server_addr.sin_family = AF_INET;
            server_addr.sin_port = htons(1201);
            server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
            bzero(&(server_addr.sin_zero), 8);
            
            int bind_res = bind(server, (struct sockaddr*)(&server_addr), sizeof(server_addr));
            if (bind_res == -1) {
                NSLog(@"绑定端口失败");
            } else {
                int listen_res = listen(server, kMaxConnectCount);
                if (listen_res == -1) {
                    NSLog(@"监听端口失败");
                } else {
                    for (int i = 0; i < kMaxConnectCount; i++) {
                        // 创建线程接收客户端的连接
                        startSetupClient(server);
                    }
                }
            }
        }
    }
    [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop]run];
    return 0;
}

void startSetupClient(int server) {
    __block struct sockaddr_in client_address;
    __block socklen_t address_len = 0;
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        while (1) {
            int client = accept(server, (struct sockaddr*)&client_address, &address_len);
            if (client == -1) {
                NSLog(@"接收客户端连接失败");
            } else {
                NSLog(@"客户端 in,socket:%d连接成功", client);
                recvFromClient(client);
            }
        }
    }];
    [thread start];
}

void recvFromClient(int client) {
    while (1) {
        char buf[1024] = {0};
        long iReturn = recv(client, buf, 1024, 0);
        if (iReturn > 0) {
            NSString *str = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
            NSLog(@"客户端来消息了:%@",str);
            handleMsg(client, str);
         } else if (iReturn == -1) {
             NSLog(@"读取消息失败");
             break;
         } else if (iReturn == 0) {
             NSLog(@"客户端走了");
             close(client);
            break;
         }
    }
}

void handleMsg(int client, NSString *str) {
    NSArray *result = [str componentsSeparatedByString:@":"];
    NSString *header = result.firstObject;
    NSString *content = [[result subarrayWithRange:NSMakeRange(1, result.count - 1)] componentsJoinedByString:@":"];
    if ([header isEqualToString:kIMProtocolHeaderLogin]) {
        // 客户端登录请求
        [loginMap setObject:content forKey:@(client)];
        NSString *msg = [NSString stringWithFormat:@"%@:", kIMProtocolHeaderLogin];
        send(client, [msg cStringUsingEncoding:NSUTF8StringEncoding], 1024, 0);
    }
    if ([header isEqualToString:kIMProtocolHeaderLogout]) {
        // 客户端注销请求
        [loginMap removeObjectForKey:@(client)];
        NSString *msg = [NSString stringWithFormat:@"%@:", kIMProtocolHeaderLogout];
        send(client, [msg cStringUsingEncoding:NSUTF8StringEncoding], 1024, 0);
    }
    if ([header isEqualToString:kIMProtocolHeaderFriendList]) {
        // 客户端请求在线用户
        NSString *msg = [NSString stringWithFormat:@"%@:%@", kIMProtocolHeaderFriendList, [loginMap.allValues componentsJoinedByString:@":"]];
        send(client, [msg cStringUsingEncoding:NSUTF8StringEncoding], 1024, 0);
    }
    if ([header isEqualToString:kIMProtocolHeaderSendMsg]) {
        // 客户端发消息请求
        NSArray *array = [content componentsSeparatedByString:@":"];
        NSString *to = array[1];
        for (NSNumber *user in loginMap.allKeys) {
            if ([loginMap[user] isEqualToString:to]) {
                send(user.intValue, [str cStringUsingEncoding:NSUTF8StringEncoding], 1024, 0);
            }
        }
    }
    if ([header isEqualToString:kIMProtocolHeaderNotification]) {
        // 客户端发广播请求
        NSArray *array = [content componentsSeparatedByString:@":"];
        NSString *from = array[0];
        for (NSNumber *user in loginMap.allKeys) {
            if ([loginMap[user] isEqualToString:from]) {
                continue;
            }
            send(user.intValue, [str cStringUsingEncoding:NSUTF8StringEncoding], 1024, 0);
        }
    }
}
