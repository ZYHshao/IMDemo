//
//  ViewController.h
//  Client
//
//  Created by 珲少 on 2019/11/29.
//  Copyright © 2019 jaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <arpa/inet.h>

@interface ViewController : UITableViewController

@property (nonatomic,assign)int server_socket;

@end

