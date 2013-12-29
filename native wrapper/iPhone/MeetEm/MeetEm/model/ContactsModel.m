//
//  ContactsModel.m
//  Whitewidow
//
//  Created by Paul Schmidt on 15.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "ContactsModel.h"
#import <AddressBook/AddressBook.h>
#import "ContactVO.h"

@implementation ContactsModel

-(BOOL)hasABPermission
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error)
                                                 {
                                                     NSLog(@"first access to AB");
                                                 });
        return YES;
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        NSLog(@"access to AB already there");
        return YES;
    }
    else
    {
        NSLog(@"no access to AB");
        return NO;
    }
}

-(NSData *)hasABPermisionAsJSON
{
    NSDictionary *access = [[NSDictionary alloc] init];
    if ([self hasABPermission]) {
        [access setValue:@"true" forKey:@"access"];
    }
    else
    {
        [access setValue:@"false" forKey:@"access"];
    }
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    [jsonData setValue:@"hasAccessToContacts" forKey:@"messageType"];
    [jsonData setValue:access forKey:@"data"];
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONReadingAllowFragments error:nil];
    return json;
}

-(NSData *)getABContactsAsJSON
{
    // Request authorization to Address Book
    if(self.hasABPermission)
    {
        CFErrorRef *error = NULL;
        NSMutableArray *arrayofAddressClassObjects =[[NSMutableArray alloc]init];
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,error);
        
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef sortedPeople =ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);
        
        //RETRIEVING THE FIRST NAME AND PHONE NUMBER FROM THE ADDRESS BOOK
        
        CFIndex number = CFArrayGetCount(sortedPeople);
        
        NSString *firstName;
        NSString *phoneNumber;
        
        NSMutableDictionary *contact;
        
        for( int i=0;i<number;i++)
        {
            
            ABRecordRef person = CFArrayGetValueAtIndex(sortedPeople, i);
            firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            //ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonLastNameProperty);
            phoneNumber = (__bridge NSString *) ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if(firstName != NULL)
            {
                contact = [[NSMutableDictionary alloc] init];
                [contact setValue:firstName forKey:@"firstname"];
                [contact setValue:phoneNumber forKey:@"lastname"];
                NSLog(@"%@ %@", firstName, phoneNumber);
                [arrayofAddressClassObjects addObject:contact];
                
            }
            
            
        }
        NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
        [jsonData setValue:@"getContacts" forKey:@"messageType"];
        [jsonData setValue:arrayofAddressClassObjects forKey:@"data"];
        
        NSData *json = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONReadingAllowFragments error:nil];
        return json;
    }
    
    return nil;
}
@end
