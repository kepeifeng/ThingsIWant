//
//  ItemDetailViewController.m
//  ThingsIWant
//
//  Created by Kent on 15/2/4.
//  Copyright (c) 2015年 Kent. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "Image.h"
#import "ImageTableViewCell.h"
#import "Url.h"
#import "Note.h"

NSInteger const numberOfImagesPerRow = 4;

@interface ItemDetailViewController ()<UIImagePickerControllerDelegate, UITableViewDataSource,
UITableViewDelegate>
@property (nonatomic,readonly) NSManagedObjectContext * manageObjectContext;
@property (nonatomic) UITableView * tableView;
@end

@implementation ItemDetailViewController{
    NSArray * _images;
    NSArray * _urls;
    NSArray * _notes;
    
    UIImageView * _mainImageView;
}

-(NSManagedObjectContext *)manageObjectContext{

    return [APP_DELEGATE managedObjectContext];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.thing.name;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem * addImageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemCamera) target:self action:@selector(addImageButtonTapped:)];
    UIBarButtonItem * addUrlButton = [[UIBarButtonItem alloc] initWithTitle:@"Url" style:(UIBarButtonItemStylePlain) target:self action:@selector(addUrlButtonTapped:)];
    UIBarButtonItem * addNoteButton = [[UIBarButtonItem alloc] initWithTitle:@"Note" style:(UIBarButtonItemStylePlain) target:self action:@selector(addNoteButtonTapped:)];
    self.navigationItem.rightBarButtonItems = @[addImageButton, addUrlButton, addNoteButton];

    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    
    [self updateView];
    
}

-(void)addUrlButtonTapped:(id)sender{
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"New URL" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Title";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"URL";
    }];
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        NSString * title = [(UITextField *)[alertController.textFields objectAtIndex:0] text];
        NSString * url = [(UITextField *)[alertController.textFields objectAtIndex:1] text];
        if (title.length || url.length) {
            
            
            Url * urlEntity = (Url *)[NSEntityDescription insertNewObjectForEntityForName:@"Url" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
            
            urlEntity.url = url;
            urlEntity.title = title;
            urlEntity.item = self.thing;
            //            NSManagedObject * object = [[NSManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:[APP_DELEGATE managedObjectContext]];
            [[APP_DELEGATE managedObjectContext] insertObject:urlEntity];
            [[APP_DELEGATE managedObjectContext] save:nil];
            [self updateView];
        }
        
    }];
    
    [alertController addAction:okAction];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)addNoteButtonTapped:(id)sender{
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"New Note" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Title";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Note";
    }];
    
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        NSString * title = [(UITextField *)[alertController.textFields objectAtIndex:0] text];
        NSString * note = [(UITextField *)[alertController.textFields objectAtIndex:1] text];
        
        if (title.length || note.length) {
            
            NSEntityDescription * desc = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.manageObjectContext];
            
            Note * noteEntity = (Note *)[[NSManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:self.manageObjectContext];
    
            
//            Note * noteEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
            noteEntity.title = title;
            noteEntity.content = note;
            noteEntity.item = self.thing;
            //            NSManagedObject * object = [[NSManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:[APP_DELEGATE managedObjectContext]];
            [self.manageObjectContext insertObject:noteEntity];
            [self.manageObjectContext save:nil];
            [self updateView];
        }
        
    }];
    
    [alertController addAction:okAction];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)fetchImages{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:self.manageObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item == %@", self.thing];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"<#key#>"
    //ascending:YES];
    //[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.manageObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }
    
    NSMutableArray * images = [[NSMutableArray alloc] initWithCapacity:fetchedObjects.count];
    [images addObjectsFromArray:fetchedObjects];
    
    _images = images;
    
    for (NSManagedObject * object in fetchedObjects){
        Image * image = (Image *)object;
        NSLog(@"filename: %@", image.filename);
    }
    
}
-(void)fetchUrl{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Url" inManagedObjectContext:self.manageObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item == %@", self.thing];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"<#key#>"
    //ascending:YES];
    //[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.manageObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }
    
    NSMutableArray * notes = [[NSMutableArray alloc] initWithCapacity:fetchedObjects.count];
    [notes addObjectsFromArray:fetchedObjects];
    
    _urls = notes;
    
    for (NSManagedObject * object in fetchedObjects){
        Url * note = (Url *)object;
        NSLog(@"note: %@", note.url);
    }
    
}


-(void)fetchNote{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.manageObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item == %@", self.thing];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"<#key#>"
    //ascending:YES];
    //[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.manageObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }
    
    NSMutableArray * notes = [[NSMutableArray alloc] initWithCapacity:fetchedObjects.count];
    [notes addObjectsFromArray:fetchedObjects];
    
    _notes = notes;
    
    for (NSManagedObject * object in fetchedObjects){
        Note * note = (Note *)object;
        NSLog(@"note: %@", note.content);
    }
    
}


-(void)setThing:(Thing *)thing{
    _thing = thing;
    [self updateView];
}

-(void)updateView{

    self.title = _thing.name;
    [self fetchImages];
    [self fetchUrl];
    [self fetchNote];
    
    
    UIView * headerView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200))];
    titleLabel.text = self.thing.name;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:42];
    [headerView addSubview:titleLabel];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(self.view.frame), 200))];
    [headerView addSubview:imageView];
    _mainImageView = imageView;
    
    CGRect headerViewRect = headerView.frame;
    if (_images.count) {
        Image * image = [_images firstObject];
        _mainImageView.image = [UIImage imageWithContentsOfFile:[[self imageFolder] stringByAppendingPathComponent:image.filename]];
        headerViewRect.size.height = CGRectGetMaxY(_mainImageView.frame);
    }else{
        _mainImageView.image = nil;
        [_mainImageView removeFromSuperview];
        headerViewRect.size.height = CGRectGetMaxY(titleLabel.frame);
    }
    headerView.frame = headerViewRect;
    
    self.tableView.tableHeaderView = nil;
    self.tableView.tableHeaderView = headerView;
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addImageButtonTapped:(id)sender{

    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

-(NSString *)imageFolder{

    return [[self appFileFolderPath] stringByAppendingPathComponent:@"images"];
}

-(NSString *)appFileFolderPath
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths lastObject];
    return documentPath;
}

#pragma mark - ImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _mainImageView.image = image;
    
    NSData * data = UIImageJPEGRepresentation(image, 0.8);
    
    NSString *guid = [[NSUUID new] UUIDString];
    
    NSString * fileFormat = @"jpg";
    NSString * filename =[NSString stringWithFormat:@"%@.%@", guid, fileFormat];
    NSString * imagePath = [[self imageFolder] stringByAppendingPathComponent:filename];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[self imageFolder]] == NO){
    
        [[NSFileManager defaultManager] createDirectoryAtPath:[self imageFolder] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [data writeToFile:imagePath atomically:YES];
    
    CGSize imageSize = [image size];
    
    [self insertImageWithFilename:filename imageSize:imageSize];
    
}

-(void)insertImageWithFilename:(NSString *)filename imageSize:(CGSize)imageSize{

    NSEntityDescription * desc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:self.manageObjectContext];
    
    Image * image = (Image *)[[NSManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:self.manageObjectContext];
    image.filename = filename;
    image.width = @(imageSize.width);
    image.height = @(imageSize.height);
    image.item = self.thing;
    
    [self.manageObjectContext insertObject:image];
    [self.manageObjectContext save:nil];
    
    [self updateView];
    
}

#pragma mark - Table View Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return (_images.count / numberOfImagesPerRow)+1;
            break;
        case 1:
            return _urls.count;
            break;
        case 2:
            return _notes.count;
            break;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{


    if (indexPath.section == 0 ) {
        ImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
        if (!cell) {
            cell = [[ImageTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"ImageCell"];

            cell.numberOfImagesPerRow = numberOfImagesPerRow;
        }
        cell.images = [self imagesAtRow:indexPath.row];
        return cell;
    }else if (indexPath.section == 1){
    
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UrlCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"UrlCell"];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        
        Url * url = [self urlAtIndexPath:indexPath];
        cell.textLabel.text = url.title;
        cell.detailTextLabel.text = url.url;
        
        return cell;
    }else if (indexPath.section == 2){
    
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"NoteCell"];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        
        Note * note = [self noteAtIndexPath:indexPath];
        cell.textLabel.text = note.title;
        cell.detailTextLabel.text = note.content;
        
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        return cell;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        return 74;
    }
    
    return 74;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UILabel * label = [[UILabel alloc] initWithFrame:(CGRectMake(10, 0, 100, 40))];
    switch (section) {
        case 0:
            label.text = @"Image";
            break;
        case 1:
            label.text = @"Link";
            break;
        case 2:
            label.text = @"Note";
        default:
            break;
    }
    return label;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSArray *)imagesAtRow:(NSInteger)row{


    NSInteger startIndex = row * numberOfImagesPerRow;
    NSInteger endIndex = (row + 1) * numberOfImagesPerRow - 1;
    if (endIndex >= _images.count) {
        endIndex = _images.count - 1;
    }
    
    
    
    NSMutableArray * images = [NSMutableArray new];
    for (NSInteger i = startIndex; i<=endIndex; i++) {
        Image * imageEntity = [_images objectAtIndex:i];
        UIImage * image = [UIImage imageWithContentsOfFile:[[self imageFolder] stringByAppendingPathComponent:imageEntity.filename]];
        [images addObject:image];
    }
    return images;
}

-(Url *)urlAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section != 1) {
        return nil;
    }
    return [_urls objectAtIndex:indexPath.row];
    
}

-(Note *)noteAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section != 2) {
        return nil;
    }
    return [_notes objectAtIndex:indexPath.row];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
