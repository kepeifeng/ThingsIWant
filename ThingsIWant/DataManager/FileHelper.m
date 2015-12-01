//
//  FileHelper.m
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import "FileHelper.h"

@implementation FileHelper\


+(NSString *)appFileFolderPath
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths lastObject];
    return documentPath;
}

+(NSString *)imageFolder{
    
    return [[self appFileFolderPath] stringByAppendingPathComponent:@"images"];
}

+(Image *)saveImage:(UIImage *)image withProductId:(NSString *)productId{
    
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
    
    return [self insertImageWithFilename:filename imageSize:imageSize productId:productId];

}

+(Image *)insertImageWithFilename:(NSString *)filename imageSize:(CGSize)imageSize productId:(NSString *)productId{
    
    
    Image * image = [Image new];
    //    image.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    image.filename = filename;
    image.width = imageSize.width;
    image.height = imageSize.height;
    image.productId = productId;
    
    [APP_DELEGATE.managedObjectContext insertObject:image];
    [APP_DELEGATE.managedObjectContext save:nil];
    
    return image;
}




@end
