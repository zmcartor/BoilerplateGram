//
//  HKZViewController.h
//  PictureFun
//
//  Created by zm on 5/31/13.
//  Copyright (c) 2013 Hackazach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKZViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    CIContext *context;
    NSMutableArray *filters;
    CIImage *beginImage;
    UIScrollView *filtersScrollView;
}
@property (weak, nonatomic) IBOutlet UIImageView *image;
    - (IBAction)takePicture:(id)sender;
@end
