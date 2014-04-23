//
//  HistoryViewController.m
//  CCNV
//
//  Created by  Linksware Inc. on 1/18/2013.
//
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.title=@"History";
     arrHistory=[[NSMutableArray alloc] init];
    [super viewDidLoad];
   
      // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [ApplicationDelegate.HUD setHidden:FALSE];
    
    
    /// popluating array from database ////////////////////////
    arrHistory=[ApplicationDelegate loadHistory];
  
    ///sorting arrary in Des order////////////////////////////
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                                   ascending:NO];
    
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    arrHistory =(NSMutableArray *)[arrHistory sortedArrayUsingDescriptors:sortDescriptors];
    
    //refresh data////////////////////////////////////////////
    [tblview reloadData];
   
    //hide activity indicator ///////////////////////////////
    [ApplicationDelegate.HUD setHidden:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

// custom view for header. will be adjusted to default or specified header height
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
   
    return [arrHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
       
    cell.textLabel.text=[NSString stringWithFormat:@"%@",[[arrHistory objectAtIndex:indexPath.row] objectForKey:@"name"]];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[[arrHistory objectAtIndex:indexPath.row] objectForKey:@"time"]];
    cell.backgroundColor=[UIColor clearColor];
    
    return cell;
}

@end