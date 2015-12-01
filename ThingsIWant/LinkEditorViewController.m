//
//  LinkEditorViewController.m
//  ThingsIWant
//
//  Created by Kent on 11/27/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "LinkEditorViewController.h"

@interface LinkEditorViewController ()

@end

@implementation LinkEditorViewController{
    QEntryElement * titleElement;
    QEntryElement * linkElement;
    
}

- (instancetype)init
{
    QRootElement * root = [[QRootElement alloc] init];
    root.grouped = YES;
    
    self = [super initWithRoot:root];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_link) {
        _link = [[Link alloc] init];
    }
    [self setupRootElement];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:(UIBarButtonItemStylePlain) target:self action:@selector(okButtonTapped:)];
    // Do any additional setup after loading the view.
}

-(void)okButtonTapped:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(linkEditorViewController:didSavedLink:)]) {
        [self.delegate linkEditorViewController:self didSavedLink:self.link];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupRootElement{
    
    QRootElement * root = self.root;
    QSection * section = [[QSection alloc] init];
    [root addSection:section];
    __weak LinkEditorViewController * weakSelf = self;
    titleElement = [[QEntryElement alloc] initWithTitle:@"Title" Value:self.link.title Placeholder:nil];
    [titleElement setOnValueChanged:^(id element) {
        QEntryElement * entryElement = element;
        weakSelf.link.title = entryElement.textValue;
    }];
    [section addElement:titleElement];
    
//    QSection * additionSection = [[QSection alloc] init];
//    [root addSection:additionSection];
    
    linkElement = [[QEntryElement alloc] initWithTitle:@"Link" Value:self.link.url Placeholder:nil];
    [linkElement setOnValueChanged:^(id element) {
        
        QEntryElement * entryElement = element;
        weakSelf.link.title = entryElement.textValue;
    }];
    [section addElement:linkElement];
    
}


@end
