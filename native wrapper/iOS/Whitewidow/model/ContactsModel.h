//
//  ContactsModel.h
//  Whitewidow
//
//  Created by Paul Schmidt on 15.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsModel : NSObject
-(BOOL)hasABPermission;
-(NSData *)hasABPermissionAsJSON;
-(NSData *)getABContactsAsJSON;
@end
