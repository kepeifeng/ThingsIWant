//
//  DataManager.h
//  ThingsIWant
//
//  Created by Kent on 12/1/15.
//  Copyright © 2015 Kent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"

@interface DataManager : NSObject
-(void)saveNote:(Note *)note;

@end
