//
//  SyncManager.m
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "SyncManager.h"
#import <AVOSCloud.h>
#import "FileHelper.h"

@interface SyncManager()
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;
@property (nonatomic, readonly) NSManagedObjectContext * context;
@end

@implementation SyncManager
{
    __weak SyncManager * weakSelf;
    NSTimeInterval _syncTime;
}
+ (instancetype)sharedManager
{
    static dispatch_once_t onceQueue;
    static SyncManager *syncManager = nil;
    
    dispatch_once(&onceQueue, ^{ syncManager = [[self alloc] init]; });
    return syncManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastUpdateTime = [[NSUserDefaults standardUserDefaults] doubleForKey:@"lastUpdateTime"];
        weakSelf = self;
    }
    return self;
}

-(void)setLastUpdateTime:(NSTimeInterval)lastUpdateTime{
    _lastUpdateTime = lastUpdateTime;
    [[NSUserDefaults standardUserDefaults] setDouble:lastUpdateTime forKey:@"lastUpdateTime"];
}

-(void)sync{

    if([AVUser currentUser] == nil){
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        _syncTime = [[NSDate date] timeIntervalSince1970];
        _context = [APP_DELEGATE createContext];
        [weakSelf downloadNotes];
        [weakSelf downloadLinks];
        [weakSelf downloadImages];
        [weakSelf downloadProducts];
        
        [weakSelf uploadNotes];
        [weakSelf uploadLinks];
        [weakSelf uploadImages];
        [weakSelf uploadProducts];
        
        weakSelf.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
        
        NSLog(@"Sync Finished.");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([weakSelf.delegate respondsToSelector:@selector(syncManagerDidFinishSync:)]) {
                [weakSelf.delegate syncManagerDidFinishSync:weakSelf];
            }
            
        });
    });

    
}

-(BOOL)uploadNotes{

    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    request.predicate = [NSPredicate predicateWithFormat:@"updateTime > %@", [NSDate dateWithTimeIntervalSince1970:self.lastUpdateTime]];
    NSArray * result = [self.context executeFetchRequest:request error:nil];
    
    NSMutableArray * objectArray = [[NSMutableArray alloc] initWithCapacity:result.count];
    for (Note * note in result) {
        
        AVObject * noteObject;
        if (note.uuid) {
            noteObject = [AVObject objectWithoutDataWithClassName:@"Note" objectId:note.uuid];
        }else{
            noteObject = [AVObject objectWithClassName:@"Note"];
            note.uuid = noteObject.objectId;
        }
        
        [noteObject setObject:note.content forKey:@"content"];
        [noteObject setObject:note.title forKey:@"title"];
        [noteObject setObject:@(note.updateTime) forKey:@"updateTime"];
        [noteObject setObject:@(note.deleted) forKey:@"deleted"];
        [noteObject setObject:note.productId forKey:@"productId"];
        [noteObject setObject:[[AVUser currentUser] objectId] forKey:@"userId"];
        
        [objectArray addObject:noteObject];
    }
    
    BOOL saved = [AVObject saveAll:objectArray];
    return saved;
    
}

-(BOOL)downloadNotes{

    AVQuery * query = [AVQuery queryWithClassName:@"Note"];
    [query whereKey:@"userId" equalTo:[[AVUser currentUser] objectId]];
    [query whereKey:@"updateTime" greaterThan:@(self.lastUpdateTime)];
    NSError * error;
    NSArray * result = [query findObjects:&error];
    
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    request.fetchLimit = 1;
    for (AVObject * noteObject in result) {
        NSString * uuid = noteObject.objectId;
        
        NSTimeInterval remoteUpdateTime = [[noteObject objectForKey:@"updateTime"] doubleValue];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
        request.predicate = predicate;
        
        Note * note = [[self.context executeFetchRequest:request error:nil] firstObject];
        if (!note) {
            note = [Note new];
            [self.context insertObject:note];
            note.uuid = uuid;
        }else if (note.updateTime > remoteUpdateTime){
            //如果本地更新时间比服务器更近现在，则保留本地更新，忽略服务器的
            continue;
        }
        
        note.content = [noteObject objectForKey:@"content"];
        note.title = [noteObject objectForKey:@"title"];
        note.updateTime = _syncTime;
        note.deleted = [[noteObject objectForKey:@"deleted"] boolValue];
        note.productId = [noteObject objectForKey:@"productId"];
        
        NSLog(@"Downloaded Note:%@",note.title);
    }
    
    return [self.context save:nil];

}



-(BOOL)uploadLinks{

    NSString * EntityName = @"Link";
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"updateTime > %@", [NSDate dateWithTimeIntervalSince1970:self.lastUpdateTime]];
    NSArray * result = [self.context executeFetchRequest:request error:nil];
    
    NSMutableArray * objectArray = [[NSMutableArray alloc] initWithCapacity:result.count];
    for (Link * link in result) {
        
        AVObject * avObject;
        if (link.uuid) {
            avObject = [AVObject objectWithoutDataWithClassName:EntityName objectId:link.uuid];
        }else{
            avObject = [AVObject objectWithClassName:EntityName];
            link.uuid = avObject.objectId;
        }
        
        [avObject setObject:link.url forKey:@"url"];
        [avObject setObject:link.title forKey:@"title"];
        [avObject setObject:@(link.updateTime) forKey:@"updateTime"];
        [avObject setObject:@(link.deleted) forKey:@"deleted"];
        [avObject setObject:link.productId forKey:@"productId"];
        [avObject setObject:[[AVUser currentUser] objectId] forKey:@"userId"];
        
        
        [objectArray addObject:avObject];
    }
    
    BOOL saved = [AVObject saveAll:objectArray];
    return saved;
    
}

-(BOOL)downloadLinks{
    NSString * EntityName = @"Link";
    AVQuery * query = [AVQuery queryWithClassName:EntityName];
    [query whereKey:@"userId" equalTo:[[AVUser currentUser] objectId]];
    [query whereKey:@"updateTime" greaterThan:@(self.lastUpdateTime)];
    NSError * error;
    NSArray * result = [query findObjects:&error];
    
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.fetchLimit = 1;
    for (AVObject * noteObject in result) {
        NSString * uuid = noteObject.objectId;
        NSTimeInterval remoteUpdateTime = [[noteObject objectForKey:@"updateTime"] doubleValue];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
        request.predicate = predicate;
        
        Link * link = [[self.context executeFetchRequest:request error:nil] firstObject];
        if (!link) {
            link = [Link new];
            [self.context insertObject:link];
            link.uuid = uuid;
        }else if (link.updateTime > remoteUpdateTime){
            //如果本地更新时间比服务器更近现在，则保留本地更新，忽略服务器的
            continue;
        }
        
        link.url = [noteObject objectForKey:@"url"];
        link.title = [noteObject objectForKey:@"title"];
        link.updateTime = [[noteObject objectForKey:@"updateTime"] doubleValue];
        link.deleted = [[noteObject objectForKey:@"deleted"] boolValue];
        link.productId = [noteObject objectForKey:@"productId"];
        
        NSLog(@"Downloaded Link:%@",link.title);
    }
    
    return [self.context save:nil];
    
}

-(BOOL)uploadImages{
    NSString * EntityName = @"Image";
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"updateTime > %@", [NSDate dateWithTimeIntervalSince1970:self.lastUpdateTime]];
    NSArray * result = [self.context executeFetchRequest:request error:nil];
    
    NSMutableArray * objectArray = [[NSMutableArray alloc] initWithCapacity:result.count];
    for (Image * image in result) {
        
        NSString * path = [image filePath];
        NSData * data = [NSData dataWithContentsOfFile:path];
        AVFile * file = [AVFile fileWithData:data];
        NSError * error;
        [file save:&error];
        
        AVObject * avObject;
        if (image.uuid) {
            avObject = [AVObject objectWithoutDataWithClassName:EntityName objectId:image.uuid];
        }else{
            avObject = [AVObject objectWithClassName:EntityName];
            image.uuid = avObject.objectId;
        }
        
        [avObject setObject:file.objectId forKey:@"remoteFileId"];
//        [avObject setObject:image.filename forKey:@"filename"];
        [avObject setObject:@(image.height) forKey:@"height"];
        [avObject setObject:@(image.width) forKey:@"width"];
        [avObject setObject:@(image.updateTime) forKey:@"updateTime"];
        [avObject setObject:@(image.deleted) forKey:@"deleted"];
        [avObject setObject:image.productId forKey:@"productId"];
        [avObject setObject:[[AVUser currentUser] objectId] forKey:@"userId"];
        
        
        [objectArray addObject:avObject];
    }
    
    BOOL saved = [AVObject saveAll:objectArray];
    return saved;
}

-(BOOL)downloadImages{
    NSString * EntityName = @"Image";
    AVQuery * query = [AVQuery queryWithClassName:EntityName];
    [query whereKey:@"userId" equalTo:[[AVUser currentUser] objectId]];
    [query whereKey:@"updateTime" greaterThan:@(self.lastUpdateTime)];
    NSError * error;
    NSArray * result = [query findObjects:&error];
    
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.fetchLimit = 1;
    for (AVObject * noteObject in result) {
        NSString * uuid = noteObject.objectId;
        NSString * remoteFileId = [noteObject objectForKey:@"remoteFileId"];
        NSTimeInterval remoteUpdateTime = [[noteObject objectForKey:@"updateTime"] doubleValue];
        
        NSString * path = [[FileHelper imageFolder] stringByAppendingPathComponent:remoteFileId];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
            [AVFile getFileWithObjectId:remoteFileId withBlock:^(AVFile *file, NSError *error) {
                NSData * data = [file getData];
                [data writeToFile:path atomically:YES];
                NSLog(@"File downloaded:%@",path);
            }];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
        request.predicate = predicate;
        
        Image * image = [[self.context executeFetchRequest:request error:nil] firstObject];
        if (!image) {
            image = [Image new];
            [self.context insertObject:image];
            image.uuid = uuid;
        }else if (image.updateTime > remoteUpdateTime){
            //如果本地更新时间比服务器更近现在，则保留本地更新，忽略服务器的
            continue;
        }
        
        image.filename = remoteFileId;
        image.height = [[noteObject objectForKey:@"height"] floatValue];
        image.width = [[noteObject objectForKey:@"width"] floatValue];
        image.updateTime = [[noteObject objectForKey:@"updateTime"] doubleValue];
        image.deleted = [[noteObject objectForKey:@"deleted"] boolValue];
        image.productId = [noteObject objectForKey:@"productId"];
        
        NSLog(@"Downloaded Image:%@",image.filename);
    }
    
    return [self.context save:nil];
}

-(BOOL)uploadProducts{

    NSString * EntityName = @"Product";
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"updateTime > %@", [NSDate dateWithTimeIntervalSince1970:self.lastUpdateTime]];
    NSArray * result = [self.context executeFetchRequest:request error:nil];
    
    NSMutableArray * objectArray = [[NSMutableArray alloc] initWithCapacity:result.count];
    for (Product * product in result) {
        
        AVObject * avObject;
        if (product.remoteId) {
            avObject = [AVObject objectWithoutDataWithClassName:EntityName objectId:product.remoteId];
        }else{
            avObject = [AVObject objectWithClassName:EntityName];
            product.remoteId = avObject.objectId;
        }
        
        [avObject setObject:product.name forKey:@"name"];

        NSArray * priceDictArray = [product.price valueForKey:@"getDictionaryObject"];
        [avObject setObject:priceDictArray forKey:@"price"];
        [avObject setObject:@(product.updateTime) forKey:@"updateTime"];
        [avObject setObject:@(product.deleted) forKey:@"deleted"];
        [avObject setObject:product.uuid forKey:@"productId"];
        [avObject setObject:[[AVUser currentUser] objectId] forKey:@"userId"];
        
        
        [objectArray addObject:avObject];
    }
    
    BOOL saved = [AVObject saveAll:objectArray];
    return saved;
    
}

-(BOOL)downloadProducts{

    NSString * EntityName = @"Product";
    AVQuery * query = [AVQuery queryWithClassName:EntityName];
    [query whereKey:@"userId" equalTo:[[AVUser currentUser] objectId]];
    [query whereKey:@"updateTime" greaterThan:@(self.lastUpdateTime)];
    NSError * error;
    NSArray * result = [query findObjects:&error];
    
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.fetchLimit = 1;
    for (AVObject * noteObject in result) {
        NSString * uuid = noteObject.objectId;
        NSTimeInterval remoteUpdateTime = [[noteObject objectForKey:@"updateTime"] doubleValue];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
        request.predicate = predicate;
        
        Product * product = [[self.context executeFetchRequest:request error:nil] firstObject];
        if (!product) {
            product = [Product new];
            [self.context insertObject:product];
            product.remoteId = uuid;
        }else if (product.updateTime > remoteUpdateTime){
            //如果本地更新时间比服务器更近现在，则保留本地更新，忽略服务器的
            continue;
        }
        
        product.name = [noteObject objectForKey:@"name"];
        NSArray * priceDictArray = [noteObject objectForKey:@"price"];
        NSMutableArray * priceArray = [[NSMutableArray alloc] initWithCapacity:priceDictArray.count];
        for (NSDictionary *dict in priceDictArray) {
            AKPrice * price = [[AKPrice alloc] initWithDictionary:dict];
            [priceArray addObject:price];
        }
        product.price = priceArray;
        product.updateTime = [[noteObject objectForKey:@"updateTime"] doubleValue];
        product.deleted = [[noteObject objectForKey:@"deleted"] boolValue];
        product.uuid = [noteObject objectForKey:@"productId"];
        
        NSLog(@"Downloaded Product:%@",product.name);
    }
    
    return [self.context save:nil];
}

@end
