//
//  CreateProductPage.m
//
//
//  Created by Kevin Zhang on 11/16/14.
//  Copyright (c) 2014 Kevin Zhang. All rights reserved.
//

#import "CreateProductPage.h"
#import "ListValuePickerView.h"
#import "UnitedStatesCities.h"
#import "ListPickerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ImageViewController.h"
#import "APBAlertView.h"

@interface CreateProductPage() <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>
@property(strong, nonatomic)CLLocationManager* locationManager;
@end


@implementation CreateProductPage

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.images = [[NSMutableArray alloc] init];
    
    self.textFieldSubject = [[FullWidthField alloc] initWithPlaceHolder:@"Subject"];
    self.textFieldSubject.y = FormTopMargin;
    [self.scrollView addSubview:self.textFieldSubject];
    
    self.textFieldContent = [[NSUITextView alloc] initWithFrame:CGRectMake(PagePadding, 100*[UIView scale], FullWidthExcludePadding, 150)];
    self.textFieldContent.placeholder = @"Details";
    self.textFieldContent.textContainer.lineFragmentPadding = PagePadding;
    [self.scrollView addSubviewV:self.textFieldContent margin:FieldVMargin];
    
    self.labelLocation = [[LabelWithCaption alloc] initWithCaption:@"Location"];
    [self.scrollView addSubview:self.labelLocation];
    [self.labelLocation belowView:self.textFieldContent withMargin:FieldVMargin];
    self.labelLocation.width = [UIView screenWidth] - 2 * PagePadding;
    self.labelLocation.x = PagePadding;
    
    self.cameraView = [[UIImageView alloc] initWithFrame:CGRectMake(PagePadding, self.labelLocation.bottom+PagePadding*2, 40, 40)];
    self.cameraView.image = [UIImage imageNamed:@"attachment"];
    self.cameraView.contentMode = UIViewContentModeCenter;
    [self.scrollView addSubview:self.cameraView];

    self.labelAttachment = [[UILabel alloc] initWithFrame:CGRectMake(self.cameraView.right, self.cameraView.y, 100, 40)];
    self.labelAttachment.text = @"Attach a photo";
    [self.labelAttachment styleTableViewRowTag];
    [self.scrollView addSubview:self.labelAttachment];
    
    containerView = [self maskViews:[NSArray arrayWithObjects:self.textFieldSubject, self.textFieldContent, self.labelLocation, nil]];
    [self.scrollView addSubview:containerView];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *loc = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:loc
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       for (CLPlacemark *placemark in placemarks) {
                           NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                           NSLog(@"placemark.country %@",placemark.country);
                           NSLog(@"placemark.postalCode %@",placemark.postalCode);
                           NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                           NSLog(@"placemark.locality %@",placemark.locality);
                           NSLog(@"placemark.subLocality %@",placemark.subLocality);
                           NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);

                           self.city = placemark.locality;
                           self.state = placemark.administrativeArea;
                           self.labelLocation.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                           break;
                       }
                   }];
}

-(void)addImage:(UIImage *)img {
    CGFloat imgSize = ([UIView screenWidth] - 4 * PagePadding)/3;
    
    CGFloat x = (self.images.count%3) * (imgSize + PagePadding) + PagePadding;
    CGFloat y = self.cameraView.bottom + PagePadding;
    y += (self.images.count/3 * (imgSize + PagePadding));
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, imgSize, imgSize)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.image = img;
    imgView.tag = self.images.count;
    [self.images addObject:imgView];
    [imgView addTarget:self action:@selector(editImage:)];
    
    [self.scrollView addSubview:imgView];
    self.scrollView.contentSize = CGSizeMake(self.width, imgView.bottom);
}

-(void)editImage:(UITapGestureRecognizer*) ges {
    if ([UIAlertController class])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"View" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ImageViewController* controller = [[ImageViewController alloc] init];
            controller.image = ((UIImageView*)ges.view).image;
            [[AppDelegate getInstance] presentViewController:controller completion:^{
            }];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            for (UIView* view in self.images) {
                [view removeFromSuperview];
            }
            [self.images removeObjectAtIndex:ges.view.tag];
            NSMutableArray* array = [[NSMutableArray alloc] initWithArray:self.images];
            [self.images removeAllObjects];
            for (UIImageView* img in array) {
                [self addImage:img.image];
            }
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        
        [[AppDelegate getInstance] presentViewController:alert completion:^{
        }];
    }
    else
    {
        APBAlertView *alertView = [[APBAlertView alloc]
                                   initWithTitle:nil
                                   message:nil
                                   cancelButtonTitle:@"Cancel"
                                   otherButtonTitles:@[@"View", @"Remove"]
                                   cancelHandler:^{
                                   }
                                   confirmationHandler:^(NSInteger otherButtonIndex) {
                                       if (otherButtonIndex == 0) {
                                           ImageViewController* controller = [[ImageViewController alloc] init];
                                           controller.image = ((UIImageView*)ges.view).image;
                                           [[AppDelegate getInstance] presentViewController:controller completion:^{
                                           }];
                                       }
                                       if (otherButtonIndex == 1) {
                                           for (UIView* view in self.images) {
                                               [view removeFromSuperview];
                                           }
                                           [self.images removeObjectAtIndex:ges.view.tag];
                                           NSMutableArray* array = [[NSMutableArray alloc] initWithArray:self.images];
                                           [self.images removeAllObjects];
                                           for (UIImageView* img in array) {
                                               [self addImage:img.image];
                                           }
                                       }
                                       if (otherButtonIndex == 2) {
                                           
                                       }
                                   }];
        [alertView show];
    }
}
@end
