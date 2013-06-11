//
//  HKZViewController.m
//  PictureFun
//
//  Created by zm on 5/31/13.
//  Copyright (c) 2013 Hackazach. All rights reserved.
//

#import "HKZViewController.h"
#import "Filter.h"
#import <QuartzCore/QuartzCore.h>

@interface HKZViewController ()
- (void) loadFiltersForImage:(UIImage *)image;
- (void) createPreviewViewsForFilters;
- (void) applyGesturesToFilterPreviewImageView:(UIView *)view;
- (void) applyFilter:(id)sender;
@end

@implementation HKZViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void) setup {
    [self setupAppearance];
    context = [CIContext contextWithOptions:nil];
    [self loadFiltersForImage:[UIImage imageNamed:@"business-dog.jpeg"]];
}

- (void)setupAppearance {
    filtersScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, 90)];
    [filtersScrollView setScrollEnabled:YES];
    [filtersScrollView setShowsVerticalScrollIndicator:NO];
    [filtersScrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:filtersScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"The entire dict is: %@", info);
    [self.image setImage:image];
    
    // Must dismiss or you'll be stuck at the camera view !!
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // load filters with our picked image
    [self loadFiltersForImage:image];
}

- (void) loadFiltersForImage:(UIImage *)image {
    CIImage *filterPreviewImage = [[CIImage alloc] initWithImage:image];
    
    CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey,filterPreviewImage,
                             @"inputIntensity",[NSNumber numberWithFloat:0.8],nil];
    
    
    CIFilter *colorMonochrome = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey,filterPreviewImage,
                                 @"inputColor",[CIColor colorWithString:@"Red"],
                                 @"inputIntensity",[NSNumber numberWithFloat:0.8], nil];
    
    CIFilter *colorPosterize = [CIFilter filterWithName:@"CIColorPosterize" keysAndValues:kCIInputImageKey, filterPreviewImage,
                                @"inputLevels", [NSNumber numberWithFloat:7.0], nil];

    filters = [[NSMutableArray alloc] init];
    
    [filters addObjectsFromArray:[NSArray arrayWithObjects:
                                  [[Filter alloc] initWithNameAndFilter:@"Sepia" filter:sepiaFilter],
                                  [[Filter alloc] initWithNameAndFilter:@"Mono" filter:colorMonochrome],
                                  [[Filter alloc] initWithNameAndFilter:@"Poster" filter:colorPosterize],
                                   nil]];
    
    [self createPreviewViewsForFilters];
}

- (void) createPreviewViewsForFilters {
    int offsetX = 0;
    
    for(int index = 0; index < [filters count]; index++) {
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, 60, 60)];
        
        // create a label to display the name
        UILabel *filterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, filterView.bounds.size.width, 8)];
        
        filterNameLabel.center = CGPointMake(filterView.bounds.size.width/2, filterView.bounds.size.height + filterNameLabel.bounds.size.height);
        
        Filter *filter = (Filter *) [filters objectAtIndex:index];
        
        filterNameLabel.text =  filter.name;
        filterNameLabel.backgroundColor = [UIColor clearColor];
        filterNameLabel.textColor = [UIColor whiteColor];
        filterNameLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:10];
        // filterNameLabel.textAlignment = UITextAlignmentCenter;

        // Create the sample image with each filter
        CIImage *outputImage = [filter.filter outputImage];
        CGImageRef cgimg =
        [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        UIImage *smallImage =  [UIImage imageWithCGImage:cgimg];
        /*
        if(smallImage.imageOrientation == UIImageOrientationUp) {
            smallImage = [smallImage imageRotatedByDegrees:90];
        }
         */
        
        // create filter preview image views
        UIImageView *filterPreviewImageView = [[UIImageView alloc] initWithImage:smallImage];
        
        [filterView setUserInteractionEnabled:YES];
        
        filterPreviewImageView.layer.cornerRadius = 10;
        filterPreviewImageView.opaque = NO;
        filterPreviewImageView.backgroundColor = [UIColor clearColor];
        filterPreviewImageView.layer.masksToBounds = YES;
        filterPreviewImageView.frame = CGRectMake(0, 0, 60, 60);
        
        filterView.tag = index;
        
        [self applyGesturesToFilterPreviewImageView:filterView];
        
        [filterView addSubview:filterPreviewImageView];
        [filterView addSubview:filterNameLabel];
        
      
        [filtersScrollView addSubview:filterView];
        
        offsetX += filterView.bounds.size.width + 10;
        
    }
    
    [filtersScrollView setContentSize:CGSizeMake(400, 60)];
}

- (void) applyGesturesToFilterPreviewImageView:(UIView *)view {
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applyFilter:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [view addGestureRecognizer:singleTapGestureRecognizer];
}

- (void) applyFilter:(id) sender {
    int filterIndex = [(UITapGestureRecognizer *) sender view].tag;
    Filter *filter = [filters objectAtIndex:filterIndex];
    CIImage *outputImage = [filter.filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
//  finalImage = [finalImage imageRotatedByDegrees:90];
    [self.image setImage:finalImage];
    NSLog(@"Image view now: width: %f height:%f", self.image.frame.size.width, self.image.frame.size.height);
    CGImageRelease(cgimg);
}
@end
