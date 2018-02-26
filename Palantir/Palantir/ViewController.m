//
//  ViewController.m
//  Palantir
//
//  Created by Albert Borges on 2/26/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
   [super viewDidLoad];

   // Do any additional setup after loading the view.
   
   NSDateComponents *components = [[NSDateComponents alloc] init];
   [components setYear:2018];
   [components setMonth:2];
   [components setDay:26];
   [components setHour:22];
   [components setMinute:00];
   [components setSecond:00];
}


- (void)setRepresentedObject:(id)representedObject {
   [super setRepresentedObject:representedObject];

   // Update the view, if already loaded.
}


@end
