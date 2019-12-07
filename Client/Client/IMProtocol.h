//
//  IMProtocol.h
//  IMProtocol
//
//  Created by 珲少 on 2019/11/29.
//  Copyright © 2019 jaki. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kIMProtocolHeaderLogin = @"login";  // userName
static NSString *kIMProtocolHeaderSendMsg = @"msg";  // content
static NSString *kIMProtocolHeaderLogout = @"logout";// userName
static NSString *kIMProtocolHeaderNotification = @"notification"; //content
static NSString *kIMProtocolHeaderFriendList = @"firend"; // id:id:id

@interface IMProtocol : NSObject



@end
