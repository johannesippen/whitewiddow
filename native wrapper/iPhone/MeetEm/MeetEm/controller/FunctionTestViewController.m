//
//  FunctionTestViewController.m
//  whitewidow
//
//  Created by Paul Schmidt on 27.10.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "FunctionTestViewController.h"

#import "LocationController.h"
#import "SocialModel.h"
#import <Foundation/Foundation.h>
#import "PushController.h"

@interface FunctionTestViewController ()
@end

@implementation FunctionTestViewController
LocationController* localCtrl;
SocialModel* social;

UIAlertView *alert;

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
    self.navigationController.navigationBarHidden = NO;
    alert = [[UIAlertView alloc] init];
    
    localCtrl = [[LocationController alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://maps.googleapis.com/maps/api/directions/json?origin=Berlin&destination=Potsdam&sensor=false&departure_time=1343605500&mode=transit"]];
     NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
     NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];*/
    int row = indexPath.row;
    if(indexPath.section == 0)
    {
        switch (row) {
            case 0:
                [localCtrl setCallback:self withSelector:@selector(fooIsDone:) andIdentifier:@"authorizationState"];
                [localCtrl authorize];
                [alert setTitle:@"CoreLocation - getAuthorizationState()"];
                [alert addButtonWithTitle:@"OK"];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                break;
                
            case 1:
                [localCtrl setCallback:self withSelector:@selector(fooIsDone:) andIdentifier:@"getLocation"];
                [localCtrl getLocation];
                [alert setTitle:@"CoreLocation - getLocation()"];
                [alert addButtonWithTitle:@"OK"];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                break;
                
            case 2:
                [localCtrl setCallback:self withSelector:@selector(fooIsDone:) andIdentifier:@"authorizationState"];
                [localCtrl getAuthorizationState];
                [alert setTitle:@"CoreLocation - getAuthorizationState()"];
                [alert addButtonWithTitle:@"OK"];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                break;
            case 3:
                
                // Perform request and get JSON back as a NSData object
                
                
                /*[social getUserData];
                 [alert setTitle:@"CoreLocation - getAuthorizationState()"];
                 [alert addButtonWithTitle:@"OK"];
                 alert.alertViewStyle = UIAlertViewStyleDefault;*/
                break;
                
            default:
                break;
        }
    }else if(indexPath.section == 2)
    {
        [PushController enablePushNotification];
    }
}


- (void)fooIsDone: (NSString*) identifier
{
    if([identifier isEqualToString:@"authorizationState"])
    {
        [alert setMessage:[[NSString alloc] initWithData:[localCtrl getAuthorizationState]
                                                encoding:NSUTF8StringEncoding]];
    }
    [alert show];
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
