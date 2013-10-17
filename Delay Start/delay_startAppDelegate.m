//
//  delay_startAppDelegate.m
//  Delay Start
//
//  Created by Joseph Markham on 12/25/12.
//  Copyright (c) 2012 Joseph Markham. All rights reserved.
//

#import "delay_startAppDelegate.h"

@implementation delay_startAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //NSLog(@"Starting...");
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    //NSLog(@"Quitting...");
    return YES;
}

@end
