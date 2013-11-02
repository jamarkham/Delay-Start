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
    IBOutlet NSButton *quitStart;
    
    
    NSMutableArray *delayTimeValue;
    NSMutableArray *startupApps;
    NSMutableArray *quitAfterStartup;
    
}


@property  (retain, nonatomic) NSMutableArray *delayTimeValue;
@property  (retain, nonatomic) NSMutableArray *startupApps;
@property  (retain, nonatomic) NSMutableArray *quitAfterStartup;

- (IBAction)displaySomeText:(id)sender;
- (IBAction)launchNow:(id)sender;
- (void)addNewItemsToAppList:(NSArray *)files;
- (IBAction)getApps:(id)sender;
- (IBAction)removeApp:(id)sender;

- (IBAction)menuAbout:(id)sender;
- (IBAction)updatePreset:(id)sender;
- (IBAction)updateQuitStart:(id)sender;
- (IBAction)bumpUp:(id)sender;
- (IBAction)bumpDown:(id)sender;

- (IBAction)addDelay:(id)sender;
- (IBAction)removeDelay:(id)sender;

- (void)timerDone:(id)sender;
- (void)launchy;


- (IBAction)displayTheHelp:(id)sender;


@end
