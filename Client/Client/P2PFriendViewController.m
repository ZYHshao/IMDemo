//
//  P2PFriendViewController.m
//  Client
//
//  Created by 珲少 on 2019/11/29.
//  Copyright © 2019 jaki. All rights reserved.
//

#import "P2PFriendViewController.h"
#import "IMProtocol.h"
#import <netinet/in.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import "P2PViewController.h"

@interface P2PFriendViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation P2PFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendList:) name:kIMProtocolHeaderFriendList object:nil];
    [self.view addSubview:self.tableView];
    NSString *msg = [NSString stringWithFormat:@"%@:", kIMProtocolHeaderFriendList];
    send(self.server, [msg cStringUsingEncoding:NSUTF8StringEncoding], 1024, 0);
}

- (void)friendList:(NSNotification *)notification {
    NSArray *list = [(NSString *)notification.object componentsSeparatedByString:@":"];
    [self.dataArray removeAllObjects];
    for (NSString *s in list) {
        if ([s isEqualToString:self.userName]) {
            continue;
        }
        [self.dataArray addObject:s];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
         [self.tableView reloadData];
    });
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    P2PViewController *controller = [[P2PViewController alloc] init];
    controller.from = self.userName;
    controller.to = self.dataArray[indexPath.row];
    controller.server = self.server;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
