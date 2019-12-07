//
//  GroupViewController.m
//  Client
//
//  Created by 珲少 on 2019/12/7.
//  Copyright © 2019 jaki. All rights reserved.
//

#import "GroupViewController.h"
#import "IMProtocol.h"
#import <netinet/in.h>
#import <sys/socket.h>
#import <arpa/inet.h>

@interface GroupViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"聊天室";
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.textField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revMsg:) name:kIMProtocolHeaderNotification object:nil];
}

- (void)revMsg:(NSNotification *)notification {
    NSString *content = notification.object;
    [self.dataArray addObject:content];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)sendMsg:(NSString *)msg {
    [self.dataArray addObject:[self.from stringByAppendingFormat:@":%@", msg]];
    [self.tableView reloadData];
    msg = [NSString stringWithFormat:@"%@:%@:%@", kIMProtocolHeaderNotification,self.from, msg];
    send(self.server, [msg cStringUsingEncoding:NSUTF8StringEncoding], 1024, 0);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self sendMsg:textField.text];
    }
    self.textField.text = @"";
    return YES;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
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

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height, self.view.frame.size.width, 40)];
        _textField.borderStyle = UITextBorderStyleBezel;
        _textField.delegate = self;
        return _textField;
    }
    return _textField;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
