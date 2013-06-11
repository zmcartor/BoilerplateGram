//
//  Filter.m
//  PictureFun
//
//  Created by zm on 6/3/13.
//  Copyright (c) 2013 Hackazach. All rights reserved.
//

#import "Filter.h"

@implementation Filter

-(id) initWithNameAndFilter:(NSString *)theName filter:(CIFilter *)theFilter {
    self = [super init];
    
    self.name = theName;
    self.filter = theFilter;
    
    return self;
}

@end
