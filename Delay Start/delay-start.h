//
//  delay-start.h
//  Delay Start
//
//  Created by Joseph Markham on 12/25/12.
//  Copyright (c) 2012 Joseph Markham. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface delay_start : NSObject{
    IBOutlet NSTextField *updateTime;
    IBOutlet NSTextField *setTime;
    IBOutlet NSTableView *appListTableView;
    
    NSMutableArray *delayTimeValue;
    NSMutableArray *startupApps;
    
}


@property  (retain, nonatomic) NSMutableArray *delayTimeValue;
@property  (retain, nonatomic) NSMutableArray *startupApps;

- (IBAction)displaySomeText:(id)sender;
- (void)addNewItemsToAppList:(NSArray *)files;
- (IBAction)getApps:(id)sender;
- (IBAction)removeApp:(id)sender;

- (IBAction)menuAbout:(id)sender;
- (IBAction)updatePreset:(id)sender;

- (void)timerDone:(id)sender;
- (void)launchy;


- (IBAction)displayTheHelp:(id)sender;


@end
