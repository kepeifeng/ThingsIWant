//
//  ViewController.m
//  ThingsIWant
//
//  Created by Kent on 15/1/31.
//  Copyright (c) 2015年 Kent. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Data.h"
#import <SWTableViewCell.h>
#import "ItemDetailViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource,
SWTableViewCellDelegate>
@property (nonatomic) UITableView * tableView;
@end


@implementation ViewController{

    NSMutableArray * _objectList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _objectList = [NSMutableArray new];
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemAdd) target:self action:@selector(addButtonTapped:)];
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self refreshTableView];
    
}

-(void)refreshTableView{

    NSManagedObjectContext * context = [APP_DELEGATE managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Thing"];
    
    NSError * error;
    NSArray * result = [context executeFetchRequest:request error:&error];
    if (!error) {
        
        _objectList = [[NSMutableArray alloc] initWithCapacity:result.count];
        [_objectList addObjectsFromArray:result];
//    for (NSManagedObject * object in result) {
//        Thing * thing  = [[Thing alloc] init];
//        thing.name = [object valueForKey:@"name"];
//        thing.managedObjectId = object.objectID;
//        [_objectList addObject:thing];
//    }
    
    [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addButtonTapped:(id)sender{

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Add New Thing" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
       textField.placeholder = @"Name";
    }];
    
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        NSString * name = [(UITextField *)[alertController.textFields objectAtIndex:0] text];
        if (name.length) {
            Thing * desc = (Thing *)[NSEntityDescription insertNewObjectForEntityForName:@"Thing" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
//            [desc setValue:name forKey:@"name"];
            desc.name = name;
            desc.price = 0;
//            NSManagedObject * object = [[NSManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:[APP_DELEGATE managedObjectContext]];
            [[APP_DELEGATE managedObjectContext] insertObject:desc];
            [[APP_DELEGATE managedObjectContext] save:nil];
            [self refreshTableView];
        }
        
    }];
    
    [alertController addAction:okAction];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancelAction];
    

    [self presentViewController:alertController animated:YES completion:nil];
}

-(Thing *)thingAtIndexPath:(NSIndexPath *)indexPath{

    return [_objectList objectAtIndex:indexPath.row];
}

-(NSIndexPath *)indexPathOfThing:(Thing *)thing{

    NSUInteger index = [_objectList indexOfObject:thing];
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
    return nil;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _objectList.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString * CellIdentifier = @"Cell";
    
    SWTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[SWTableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:CellIdentifier];
        
        UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setTitle:@"DEL" forState:(UIControlStateNormal)];
        button.backgroundColor = [UIColor redColor];

        cell.rightUtilityButtons = @[button];
        
        cell.delegate = self;
        
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    Thing * thing = [self thingAtIndexPath:indexPath];
    cell.textLabel.text = thing.name;
    cell.detailTextLabel.text = ([thing.price integerValue] == 0)?@"":[NSString stringWithFormat:@"%ld",[thing.price integerValue]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Thing * thing = [self thingAtIndexPath:indexPath];
    ItemDetailViewController * itemDetailViewController= [[ItemDetailViewController alloc] init];
    itemDetailViewController.thing = thing;
    [self.navigationController pushViewController:itemDetailViewController animated:YES];
}
#pragma mark - Swipeable Table View Cell Delegate

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{

    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    Thing * thing = [self thingAtIndexPath:indexPath];
    
//    NSManagedObject * object = [[APP_DELEGATE managedObjectContext] objectWithID:thing.managedObjectId];
    [[APP_DELEGATE managedObjectContext] deleteObject:thing];
    [[APP_DELEGATE managedObjectContext] save:nil];
    [self refreshTableView];
    
}



@end
