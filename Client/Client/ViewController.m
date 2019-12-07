//
//  ViewController.m
//  Client
//
//  Created by 珲少 on 2019/11/29.
//  Copyright © 2019 jaki. All rights reserved.
//

#import "ViewController.h"
#import "IMProtocol.h"
#import "P2PFriendViewController.h"
#import "GroupViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonItem;

@property (copy, nonatomic) NSString *userName;

@property (assign, nonatomic) BOOL isLogin;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int server_socket = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    if (server_socket == -1) {
     NSLog(@"创建失败");
    }else{
     //绑定地址和端口
     struct sockaddr_in server_addr;
     server_addr.sin_len = sizeof(struct sockaddr_in);
     server_addr.sin_family = AF_INET;
     server_addr.sin_port = htons(1201);
     server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
     bzero(&(server_addr.sin_zero), 8);
    
     //接受客户端的链接
     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_async(queue, ^{
      //创建新的socket
      int aResult = connect(server_socket, (struct sockaddr*)&server_addr, sizeof(struct sockaddr_in));
      if (aResult == -1) {
       NSLog(@"链接失败");
      }else{
       self.server_socket = server_socket;
       [self acceptFromServer];
      }
     });
    }
}

//从服务端接受消息
- (void)acceptFromServer{
 while (1) {
  //接受服务器传来的数据
  char buf[1024];
  long iReturn = recv(self.server_socket, buf, 1024, 0);
  if (iReturn>0) {
      NSString *str = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
      NSArray *result = [str componentsSeparatedByString:@":"];
      NSString *header = result.firstObject;
      NSString *content = [[result subarrayWithRange:NSMakeRange(1, result.count - 1)] componentsJoinedByString:@":"];
      if ([header isEqualToString:kIMProtocolHeaderLogin]) {
          // 登录成功
          dispatch_async(dispatch_get_main_queue(), ^{
              self.buttonItem.title = self.userName;
              self.isLogin = YES;
          });
      }
      if ([header isEqualToString:kIMProtocolHeaderLogout]) {
          // 注销成功
          dispatch_async(dispatch_get_main_queue(), ^{
                self.buttonItem.title = @"登录";
                self.isLogin = NO;
          });
      }
      if ([header isEqualToString:kIMProtocolHeaderFriendList]) {
          // 接收到在线用户消息
          [[NSNotificationCenter defaultCenter] postNotificationName:kIMProtocolHeaderFriendList object:content];
      }
      if ([header isEqualToString:kIMProtocolHeaderSendMsg]) {
          // 接收到服务端消息
          [[NSNotificationCenter defaultCenter] postNotificationName:kIMProtocolHeaderSendMsg object:content];
      }
      if ([header isEqualToString:kIMProtocolHeaderNotification]) {
          // 接收到服务端广播
          [[NSNotificationCenter defaultCenter] postNotificationName:kIMProtocolHeaderNotification object:content];
      }
  }else if (iReturn == -1){
      NSLog(@"接收失败-1");
      break;
  }
 }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            if (!self.isLogin) {
                return;
            }
            P2PFriendViewController *controller = P2PFriendViewController.new;
            controller.server = self.server_socket;
            controller.userName = self.userName;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 1:
        {
            if (!self.isLogin) {
                return;
            }
            GroupViewController *group = [[GroupViewController alloc] init];
            group.server = self.server_socket;
            group.from = self.userName;
            [self.navigationController pushViewController:group animated:YES];
        }
            
        default:
            break;
    }
}

- (IBAction)itemAction:(UIBarButtonItem *)sender {
    if (self.isLogin) {
        [self logout];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"登录" message:@"输入用户名" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入用户名";
            textField.delegate = self;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.userName.length) {
                [self login];
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.userName = textField.text;
    return YES;
}

- (void)login {
    NSString *msg = [NSString stringWithFormat:@"%@:%@", kIMProtocolHeaderLogin, self.userName];
    send(self.server_socket, [msg cStringUsingEncoding:NSUTF8StringEncoding], 1024, 0);
}

- (void)logout {
    NSString *msg = [NSString stringWithFormat:@"%@:%@", kIMProtocolHeaderLogout, self.userName];
    send(self.server_socket, [msg cStringUsingEncoding:NSUTF8StringEncoding], 1024, 0);
}

@end
