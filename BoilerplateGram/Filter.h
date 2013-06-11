//
//  Filter.h
//  PictureFun
//
//  Created by zm on 6/3/13.
//  Copyright (c) 2013 Hackazach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Filter : NSObject
- (id) initWithNameAndFilter:(NSString *) theName filter:(CIFilter *) theFilter;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) CIFilter *filter;

@end
