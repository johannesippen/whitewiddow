//
//  FriendsViewController.m
//  whitewidow
//
//  Created by Paul Schmidt on 06.11.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "FriendsViewController.h"
#import "SocialModel.h" 
#import "JSONHelper.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController
SocialModel* model;
NSArray* wwFriends;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(model == nil)
        model = [[SocialModel alloc] init];
    [model getWWFriendsList];
    model.delegate = self;
}

-(void)setWWFriendList:(NSArray *)friends
{
    wwFriends = friends;
    UIAlertView* alert = [[UIAlertView alloc] init];
    alert.title = @"Result of Social.getWWFriendsList():";
    NSString* message = [NSString stringWithUTF8String:[[JSONHelper convertArrayToJSON:friends forSignal:@"getWWFriendsList"] bytes]];
    alert.message = message;
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    [self.tableView reloadData];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(wwFriends != nil)
    {
        return wwFriends.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell textLabel].text = wwFriends[indexPath.item][@"name"];
    [cell detailTextLabel].text = wwFriends[indexPath.item][@"invitationState"];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
