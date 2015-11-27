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
#import "Private.h"
#import <DZNPhotoPickerController/Classes/DZNPhotoPickerController.h>

//#import <UIImagePickerController+Edit.h>


typedef NS_ENUM(NSUInteger, DetailSection) {
    DetailSectionImage,
    DetailSectionPrice,
    DetailSectionLink,
    DetailSectionNote
};

NSInteger const numberOfImagesPerRow = 4;

#define TAG_TITLE_FIELD 10000
#define TAG_PRICE_FIELD 10001

@interface ItemDetailViewController ()<UIImagePickerControllerDelegate, UITableViewDataSource,
UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic,readonly) NSManagedObjectContext * manageObjectContext;
@property (nonatomic) UITableView * tableView;
@end

@implementation ItemDetailViewController{
    NSArray * _images;
    NSArray * _urls;
    NSArray * _notes;
    
    UIImageView * _mainImageView;
    
//    UIEdgeInsets _originalContentOffset;
    
    UIToolbar * _inputToolBar;
    
    __weak UIView * _firstResponder;
    
    UITextView * _titleField;
}


+ (void)initialize
{
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerService500px
                                      consumerKey:k500pxConsumerKey
                                   consumerSecret:k500pxConsumerSecret
     subscription:(DZNPhotoPickerControllerSubscriptionFree)];
    
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceFlickr
                                      consumerKey:kFlickrConsumerKey
                               consumerSecret:kFlickrConsumerSecret
                                 subscription:(DZNPhotoPickerControllerSubscriptionFree)];
    
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceInstagram
                                      consumerKey:kInstagramConsumerKey
                               consumerSecret:kInstagramConsumerSecret
                                 subscription:(DZNPhotoPickerControllerSubscriptionFree)];
    
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceGoogleImages
                                      consumerKey:kGoogleImagesConsumerKey
                               consumerSecret:kGoogleImagesSearchEngineID
                                 subscription:(DZNPhotoPickerControllerSubscriptionFree)];
    
    //Bing does not require a secret. Rather just an "Account Key"
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceBingImages
                                      consumerKey:kBingImagesAccountKey
                               consumerSecret:nil
                                 subscription:(DZNPhotoPickerControllerSubscriptionFree)];
    
/*
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceGettyImages
                                      consumerKey:kGettyImagesConsumerKey
                               consumerSecret:kGettyImagesConsumerSecret
                                 subscription:(DZNPhotoPickerControllerSubscriptionFree)];

*/
}

-(NSManagedObjectContext *)manageObjectContext{

    return [APP_DELEGATE managedObjectContext];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = self.thing.name;
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIBarButtonItem * addImageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemCamera) target:self action:@selector(addImageButtonTapped:)];
//    UIBarButtonItem * addUrlButton = [[UIBarButtonItem alloc] initWithTitle:@"Url" style:(UIBarButtonItemStylePlain) target:self action:@selector(addUrlButtonTapped:)];
//    UIBarButtonItem * addNoteButton = [[UIBarButtonItem alloc] initWithTitle:@"Note" style:(UIBarButtonItemStylePlain) target:self action:@selector(addNoteButtonTapped:)];
//    self.navigationItem.rightBarButtonItems = @[addImageButton, addUrlButton, addNoteButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemAdd) target:self action:@selector(addButtonTapped:)];

    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self registerForKeyboardNotifications];
    
    [self updateView];
    
}

-(void)addButtonTapped:(id)sender{

    UIAlertController * alertController = [[UIAlertController alloc] init];
    UIAlertAction * imageItem = [UIAlertAction actionWithTitle:@"Image" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self addImageButtonTapped:nil];
    }];
    [alertController addAction:imageItem];
    
    UIAlertAction * urlItem = [UIAlertAction actionWithTitle:@"Link" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self addUrlButtonTapped:nil];
    }];
    [alertController addAction:urlItem];
    
    UIAlertAction * noteItem = [UIAlertAction actionWithTitle:@"Note" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self addNoteButtonTapped:nil];
    }];
    [alertController addAction:noteItem];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:NULL];
    
}

-(void)dealloc{

    [_titleField removeObserver:self forKeyPath:@"contentSize"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _titleField) {
        UITextView *textView = object;
        CGFloat topCorrect = ([textView bounds].size.height - [textView contentSize].height * [textView zoomScale])/2.0;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
        textView.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    }

}

-(void)prepareToolBar{

    if (!_inputToolBar) {
        _inputToolBar = [[UIToolbar alloc] initWithFrame:(CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44))];
        UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace) target:nil action:nil];
        UIBarButtonItem * doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:(UIBarButtonItemStylePlain) target:self action:@selector(doneButtonTapped:)];
        _inputToolBar.items = @[spaceItem, doneItem];
        [self.view addSubview:_inputToolBar];
    }
}


-(void)doneButtonTapped:(id)sender{

    [_firstResponder resignFirstResponder];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShown:(NSNotification*)aNotification
{
    
    [self prepareToolBar];
    
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;


//    _originalContentOffset = self.tableView.contentInset;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, kbSize.height, 0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect toolbarFrame = _inputToolBar.frame;
        toolbarFrame.origin.y = CGRectGetHeight(self.view.frame) - kbSize.height - CGRectGetHeight(toolbarFrame);
        _inputToolBar.frame = toolbarFrame;
        _inputToolBar.alpha = 1;
    }];
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    //    CGRect aRect = self.view.frame;
    //    aRect.size.height -= kbSize.height;
    //    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
    //        [_textView scrollRectToVisible:activeField.frame animated:YES];
    //    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 0, 0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect toolbarFrame = _inputToolBar.frame;
        toolbarFrame.origin.y = CGRectGetHeight(self.view.frame);
        _inputToolBar.frame = toolbarFrame;
        _inputToolBar.alpha = 1;
    }];
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
    
    if (!_titleField) {
        UITextView * titleLabel = [[UITextView alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200))];
        titleLabel.tag = TAG_TITLE_FIELD;
        titleLabel.text = self.thing.name;
        titleLabel.delegate = self;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:42];
        
        [titleLabel addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
     
        
        _titleField = titleLabel;
    }
    
    [headerView addSubview:_titleField];

    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(_titleField.frame), CGRectGetWidth(self.view.frame), 200))];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
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
        headerViewRect.size.height = CGRectGetMaxY(_titleField.frame);
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

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancel];
    
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:takePhoto];
    
    UIAlertAction * chooseImage = [UIAlertAction actionWithTitle:@"Choose from Library" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    [alertController addAction:chooseImage];
    
    UIAlertAction * searchImage = [UIAlertAction actionWithTitle:@"Search Online" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        [self presentPhotoSearch:nil];
    }];
    [alertController addAction:searchImage];
    

    [self presentViewController:alertController animated:YES completion:nil];
    

    
}

- (void)dismissController:(UIViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


- (void)updateImageWithPayload:(NSDictionary *)payload
{
//    _photoPayload = payload;
    
    NSLog(@"OriginalImage : %@", payload[UIImagePickerControllerOriginalImage]);
    NSLog(@"EditedImage : %@", payload[UIImagePickerControllerEditedImage]);
    NSLog(@"MediaType : %@", payload[UIImagePickerControllerMediaType]);
    NSLog(@"CropRect : %@", NSStringFromCGRect([ payload[UIImagePickerControllerCropRect] CGRectValue]));
    NSLog(@"ZoomScale : %f", [ payload[DZNPhotoPickerControllerCropZoomScale] floatValue]);
    
    NSLog(@"CropMode : %@", payload[DZNPhotoPickerControllerCropMode]);
    NSLog(@"PhotoAttributes : %@", payload[DZNPhotoPickerControllerPhotoMetadata]);
    
    UIImage *image = payload[UIImagePickerControllerEditedImage];
    if (!image) image = payload[UIImagePickerControllerOriginalImage];
    
    
    [self saveImage:image];
    [self updateView];
    
//    self.imageView.image = image;

    
    //    [self saveImage:image];
}


- (void)presentPhotoSearch:(id)sender
{
    DZNPhotoPickerController *picker = [DZNPhotoPickerController new];
//    picker.supportedServices = DZNPhotoPickerControllerServiceFlickr | DZNPhotoPickerControllerServiceGoogleImages | DZNPhotoPickerControllerServiceBingImages;
    picker.supportedServices = DZNPhotoPickerControllerServiceBingImages;
    picker.allowsEditing = NO;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    picker.initialSearchTerm = self.thing.name;
    picker.enablePhotoDownload = YES;
    picker.allowAutoCompletedSearch = YES;
    
    [picker setFinalizationBlock:^(DZNPhotoPickerController *picker, NSDictionary *info){
        [self updateImageWithPayload:info];
        [self dismissController:picker];
    }];
    
    [picker setFailureBlock:^(DZNPhotoPickerController *picker, NSError *error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    [picker setCancellationBlock:^(DZNPhotoPickerController *picker){
        [self dismissController:picker];
    }];
    
//    [self presentController:picker sender:sender];
    [self presentViewController:picker animated:YES completion:NULL];
}

/*- (void)presentController:(UIViewController *)controller sender:(id)sender
{
    if (_popoverController.isPopoverVisible) {
        [_popoverController dismissPopoverAnimated:YES];
        _popoverController = nil;
    }
    
    if (_actionSheet.isVisible) {
        _actionSheet = nil;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.preferredContentSize = CGSizeMake(320.0, 520.0);
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        [_popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}*/


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

    [self saveImage:image];
    [self updateView];
    
}

-(void)saveImage:(UIImage *)image{
    
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
    
    
}

#pragma mark - Table View Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case DetailSectionImage:
            return (_images.count / numberOfImagesPerRow)+1;
            break;
        case DetailSectionLink:
            return _urls.count;
            break;
        case DetailSectionNote:
            return _notes.count;
            break;
        case DetailSectionPrice:
            return 1;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{


    if (indexPath.section == DetailSectionImage ) {
        ImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
        if (!cell) {
            cell = [[ImageTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"ImageCell"];

            cell.numberOfImagesPerRow = numberOfImagesPerRow;
        }
        cell.images = [self imagesAtRow:indexPath.row];
        return cell;
    }else if (indexPath.section == DetailSectionLink){
    
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UrlCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"UrlCell"];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        
        Url * url = [self urlAtIndexPath:indexPath];
        cell.textLabel.text = url.title;
        cell.detailTextLabel.text = url.url;
        
        return cell;
    }else if (indexPath.section == DetailSectionNote){
    
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
    }else if (indexPath.section == DetailSectionPrice){
    
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PriceCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"PriceCell"];
//            UITextField * priceField = [[UITextField alloc] initWithFrame:(CGRectMake(80, 0, CGRectGetWidth(cell.frame) - 80, CGRectGetHeight(cell.frame)))];
            UITextField * priceField = [[UITextField alloc] initWithFrame:cell.bounds];
            priceField.tag = TAG_PRICE_FIELD;
            priceField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            priceField.keyboardType = UIKeyboardTypeDecimalPad;
            priceField.textAlignment = NSTextAlignmentCenter;
            priceField.delegate = self;
            [cell.contentView addSubview:priceField];
        }
        

        UITextField * priceField = (UITextField *)[cell viewWithTag:TAG_PRICE_FIELD];
        priceField.text = ([self.thing.price integerValue]==0)?@"":[NSString stringWithFormat:@"%@", self.thing.price];
        
        return cell;
        
    }
    return nil;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == DetailSectionImage) {
        return 74;
    }
    
    return 74;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UILabel * label = [[UILabel alloc] initWithFrame:(CGRectMake(10, 0, 100, 40))];
    switch (section) {
        case DetailSectionImage:
            label.text = @"Image";
            break;
        case DetailSectionLink:
            label.text = @"Link";
            break;
        case DetailSectionNote:
            label.text = @"Note";
            break;
        case DetailSectionPrice:
            label.text = @"Price";
            break;
        default:
            return nil;
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

    if (indexPath.section != DetailSectionLink) {
        return nil;
    }
    return [_urls objectAtIndex:indexPath.row];
    
}

-(Note *)noteAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section != DetailSectionNote) {
        return nil;
    }
    return [_notes objectAtIndex:indexPath.row];
}

#pragma mark - Text Field Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    _firstResponder = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

    if (textField.tag == TAG_PRICE_FIELD) {
        float price = 0;
        if (textField.text.length) {
            price = [textField.text floatValue];
            self.thing.price = [NSDecimalNumber decimalNumberWithString:textField.text];
        }else{
            self.thing.price = [NSDecimalNumber decimalNumberWithString:@"0"];
        }
        [self.manageObjectContext save:nil];
        
    }
    

    _firstResponder = nil;
}

#pragma mark - Text View Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView{
    _firstResponder = textView;
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if(textView.tag == TAG_TITLE_FIELD){
        self.thing.name = textView.text;
        [self.manageObjectContext save:nil];
    }
    
    _firstResponder = nil;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
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
