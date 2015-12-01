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
#import "Link.h"
#import "Note.h"
#import "Private.h"
#import <DZNPhotoPickerController/Classes/DZNPhotoPickerController.h>
#import "PriceEditorViewController.h"
#import "LinkEditorViewController.h"
#import "NoteEditorViewController.h"
#import <QuickDialog/QWebViewController.h>
//#import <UIImagePickerController+Edit.h>
#import <SwipeView.h>
#import "SyncManager.h"
#import "FileHelper.h"



typedef NS_ENUM(NSUInteger, DetailSection) {
    DetailSectionMainInfo,
    DetailSectionPrice,
    DetailSectionLink,
    DetailSectionNote
};

NSInteger const numberOfImagesPerRow = 4;

#define TAG_TITLE_FIELD 10000
#define TAG_PRICE_FIELD 10001

@interface ItemDetailViewController ()<UIImagePickerControllerDelegate, UITableViewDataSource,
UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, PriceEditorViewControllerDelegate,
LinkEditorViewControllerDelegate,NoteEditorViewControllerDelegate, SwipeViewDataSource, SwipeViewDelegate>
@property (nonatomic,readonly) NSManagedObjectContext * manageObjectContext;
@property (nonatomic) UITableView * tableView;
@end

@implementation ItemDetailViewController{
    NSMutableArray * _images;
    NSMutableArray * _urls;
    NSMutableArray * _notes;
    
    SwipeView * _mainImageView;
    
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
//    UIBarButtonItem * addUrlButton = [[UIBarButtonItem alloc] initWithTitle:@"Link" style:(UIBarButtonItemStylePlain) target:self action:@selector(addUrlButtonTapped:)];
//    UIBarButtonItem * addNoteButton = [[UIBarButtonItem alloc] initWithTitle:@"Note" style:(UIBarButtonItemStylePlain) target:self action:@selector(addNoteButtonTapped:)];
//    self.navigationItem.rightBarButtonItems = @[addImageButton, addUrlButton, addNoteButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemAdd) target:self action:@selector(addButtonTapped:)];

    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
//    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self registerForKeyboardNotifications];
    
    [self updateView];
    
}

-(void)addButtonTapped:(id)sender{

    UIAlertController * alertController = [[UIAlertController alloc] init];
    
    UIAlertAction * priceItem = [UIAlertAction actionWithTitle:@"Price" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self addPriceButtonTapped:nil];
    }];
    [alertController addAction:priceItem];
    
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

-(void)addPriceButtonTapped:(id)sender{

    PriceEditorViewController * priceEditorVC = [[PriceEditorViewController alloc] init];
    priceEditorVC.delegate = self;
    [self.navigationController pushViewController:priceEditorVC animated:YES];
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
    
    LinkEditorViewController * linkEditorVC = [LinkEditorViewController new];
    linkEditorVC.delegate = self;
    [self.navigationController pushViewController:linkEditorVC animated:YES];
    
    /*
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
            
            
            Url * urlEntity = (Url *)[NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
            
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
*/
}

-(void)addNoteButtonTapped:(id)sender{
    
    NoteEditorViewController * noteEditorVC = [[NoteEditorViewController alloc] init];
    noteEditorVC.delegate = self;
    [self.navigationController pushViewController:noteEditorVC animated:YES];
/*
    
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
*/
}


-(void)fetchImages{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:self.manageObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", self.thing.uuid];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Link" inManagedObjectContext:self.manageObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", self.thing.uuid];
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
        Link * note = (Link *)object;
        NSLog(@"note: %@", note.url);
    }
    
}


-(void)fetchNote{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.manageObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", self.thing.uuid];
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


-(void)setThing:(Product *)thing{
    _thing = thing;
    [self updateView];
}

-(void)updateView{

    self.title = _thing.name;
    [self fetchImages];
    [self fetchUrl];
    [self fetchNote];
    
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 280)];
/*
 
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
*/

    
    if (_images.count) {

        _mainImageView = [[SwipeView alloc] initWithFrame:headerView.bounds];
        _mainImageView.dataSource = self;
        _mainImageView.delegate = self;
        [headerView addSubview:_mainImageView];
//        headerViewRect.size.height = CGRectGetMaxY(_mainImageView.frame);
    }else{
        
        UIButton * addImageButton = [[UIButton alloc] initWithFrame:headerView.bounds];
//        [addImageButton setTitle:@"Add Image" forState:(UIControlStateNormal)];
        addImageButton.tintColor = [UIColor lightGrayColor];
        [addImageButton setImage:[[UIImage imageNamed:@"add_photo"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)] forState:(UIControlStateNormal)];
        [addImageButton addTarget:self action:@selector(addImageButtonTapped:) forControlEvents:(UIControlEventTouchUpInside)];
        [headerView addSubview:addImageButton];
    }

    
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
    
    
    [FileHelper saveImage:image withProductId:self.thing.uuid];
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





#pragma mark - ImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];

    [FileHelper saveImage:image withProductId:self.thing.uuid];
    [self updateView];
    
}




#pragma mark - Table View Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat y = scrollView.contentOffset.y+64;
    
    if (y<0) {
        CGFloat scale = (280 - y)/280;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, y/2);
        transform = CGAffineTransformScale(transform, scale, scale);

        _mainImageView.transform = transform;
    }else{
        if (CGAffineTransformIsIdentity(_mainImageView.transform) == NO ) {
            
            _mainImageView.transform = CGAffineTransformIdentity;
        }
    }

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
            
        case DetailSectionMainInfo:
            return 1;
            break;
        case DetailSectionLink:
            return (_urls.count)?:1;
            break;
        case DetailSectionNote:
            return _notes.count?:1;
            break;
        case DetailSectionPrice:
            return self.thing.price.count?:1;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)emptyCellWithTitle:(NSString *)title forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{

    static NSString * EmptyCellIdentity = @"EmptyCellIdentity";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:EmptyCellIdentity];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:EmptyCellIdentity];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    cell.textLabel.text = title;
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{


    if (indexPath.section == DetailSectionMainInfo ) {
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"TitleCell"];
            cell.textLabel.numberOfLines = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = self.thing.name;
        return cell;
        
    }else if (indexPath.section == DetailSectionLink){
    
        if (_urls.count == 0) {
            return [self emptyCellWithTitle:@"Add Link" forTableView:tableView atIndexPath:indexPath];
        }
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UrlCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"UrlCell"];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        
        Link * url = [self linkAtIndexPath:indexPath];
        cell.textLabel.text = url.title;
        cell.detailTextLabel.text = url.url;
        
        return cell;
    }else if (indexPath.section == DetailSectionNote){
        
        if (_notes.count == 0) {
            return [self emptyCellWithTitle:@"Add Note" forTableView:tableView atIndexPath:indexPath];
        }
    
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
    
        if (self.thing.price.count == 0) {
            return [self emptyCellWithTitle:@"Add Price" forTableView:tableView atIndexPath:indexPath];
        }
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PriceCell"];
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"PriceCell"];
/*
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"PriceCell"];
//            UITextField * priceField = [[UITextField alloc] initWithFrame:(CGRectMake(80, 0, CGRectGetWidth(cell.frame) - 80, CGRectGetHeight(cell.frame)))];
            UITextField * priceField = [[UITextField alloc] initWithFrame:cell.bounds];
            priceField.tag = TAG_PRICE_FIELD;
            priceField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            priceField.keyboardType = UIKeyboardTypeDecimalPad;
            priceField.textAlignment = NSTextAlignmentCenter;
            priceField.delegate = self;
            [cell.contentView addSubview:priceField];
*/
        }
        

        AKPrice * price = [self.thing.price objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%.2f", price.value];
        cell.detailTextLabel.text = price.note;
        
//        UITextField * priceField = (UITextField *)[cell viewWithTag:TAG_PRICE_FIELD];
//        priceField.text = ([self.thing.price integerValue]==0)?@"":[NSString stringWithFormat:@"%@", self.thing.price];
        
        return cell;
        
    }
    return nil;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == DetailSectionMainInfo) {
//        return 74;
        CGRect boundingSize = [self.thing.name boundingRectWithSize:(CGSizeMake(CGRectGetWidth(self.view.bounds) - 16 * 2, 9999)) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                             context:nil];
        return MAX(44.0,boundingSize.size.height + 10);
    }
    
    return 74;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeaderView"];
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 40))];
        UILabel * label = [[UILabel alloc] initWithFrame:(CGRectMake(10, 0, 100, 40))];
        [headerView addSubview:label];
        label.tag = 763083;
    }
    
    UILabel * label = (UILabel *)[headerView viewWithTag:763083];
    
    switch (section) {
        case DetailSectionMainInfo:
//            label.text = @"Image";
            return nil;
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
    return headerView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (section == DetailSectionMainInfo) {
        return 0.01;
    }
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == DetailSectionLink) {
        
        if(_urls.count == 0){
            [self addUrlButtonTapped:nil];
            return;
        }
        
        Link * link = [self linkAtIndexPath:indexPath];
        QWebViewController * webController = [[QWebViewController alloc] initWithUrl:link.url];
        [self.navigationController pushViewController:webController animated:YES];
    }else if (indexPath.section == DetailSectionNote){
        
        if (_notes.count == 0) {
            [self addNoteButtonTapped:nil];
            return;
        }
        
        Note * note = [self noteAtIndexPath:indexPath];
        NoteEditorViewController * noteViewController = [[NoteEditorViewController alloc] init];
        noteViewController.note = note;
        [self.navigationController pushViewController: noteViewController animated:YES];
    }else if (indexPath.section == DetailSectionPrice){
    
        if (self.thing.price.count == 0) {
            [self addPriceButtonTapped:nil];
            return;
        }
    }
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
        UIImage * image = [UIImage imageWithContentsOfFile:[[FileHelper imageFolder] stringByAppendingPathComponent:imageEntity.filename]];
        [images addObject:image];
    }
    return images;
}

-(Link *)linkAtIndexPath:(NSIndexPath *)indexPath{

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


-(void)priceEditorViewController:(PriceEditorViewController *)viewController didSavedPrice:(AKPrice *)price{

    NSMutableArray * priceArray = [[NSMutableArray alloc] initWithArray:self.thing.price];
    self.thing.price = priceArray;

    self.thing.updateTime = [[NSDate date] timeIntervalSince1970];
//    price.updateTime = [[NSDate date] timeIntervalSince1970];
    NSUInteger index = [priceArray indexOfObject:price];
    if (index != NSNotFound) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:DetailSectionPrice]] withRowAnimation:(UITableViewRowAnimationAutomatic)];

    }else{
        [priceArray addObject:price];
        if (priceArray.count == 1) {
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:DetailSectionPrice] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        }else{
            
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:priceArray.count - 1 inSection:DetailSectionPrice]] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        }
    }
    

    
    [[APP_DELEGATE managedObjectContext] save:nil];
    [self.navigationController popToViewController:self animated:YES];
}

-(void)linkEditorViewController:(LinkEditorViewController *)viewController didSavedLink:(Link *)link{

    if (!_urls) {
        _urls = [[NSMutableArray alloc] init];
    }
    
    link.updateTime = [[NSDate date] timeIntervalSince1970];
    
    NSUInteger index = [_urls indexOfObject:link];
    if (index == NSNotFound) {
        link.productId = self.thing.uuid;
//        link.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        [[APP_DELEGATE managedObjectContext] insertObject:link];
        [_urls addObject:link];
        if (_urls.count == 1) {
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:DetailSectionLink] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        }else{
            
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_urls.count - 1 inSection:DetailSectionLink]] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        }
    }else{
        
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:DetailSectionLink]] withRowAnimation:(UITableViewRowAnimationAutomatic)];
    }

    [[APP_DELEGATE managedObjectContext] save:nil];


    [self.navigationController popToViewController:self animated:YES];
}

-(void)noteEditorViewController:(NoteEditorViewController *)viewController didSavedNote:(Note *)note{

    if (!_notes) {
        _notes = [[NSMutableArray alloc] init];
    }
    note.updateTime = [[NSDate date] timeIntervalSince1970];
    NSUInteger index = [_notes indexOfObject:note];
    if (index == NSNotFound) {
        
//        note.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        [_notes addObject:note];
        note.productId = self.thing.uuid;
        [self.manageObjectContext insertObject:note];
        if (_notes.count == 1) {
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:DetailSectionNote] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        }else{
            
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_notes.count - 1 inSection:DetailSectionNote]] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        }
        
    }

    [self.manageObjectContext save:nil];
    [self.navigationController popToViewController:self animated:YES];
    
    
    
}

-(NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView{
    return _images.count;
}

-(UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view{

    UIImageView * imageView = (UIImageView *)view;
    if(!imageView){
        imageView = [[UIImageView alloc] initWithFrame:swipeView.bounds];
    }
    
    Image * imageItem = _images[index];
    imageView.image = [UIImage imageWithContentsOfFile:[[FileHelper imageFolder] stringByAppendingPathComponent:imageItem.filename]];
    return imageView;
}
@end
