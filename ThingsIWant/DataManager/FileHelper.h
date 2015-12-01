//
//  FileHelper.h
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModel.h"

@interface FileHelper : NSObject

+(NSString *)imageFolder;
+(NSString *)appFileFolderPath;
+(Image *)saveImage:(UIImage *)image withProductId:(NSString *)productId;

@end
