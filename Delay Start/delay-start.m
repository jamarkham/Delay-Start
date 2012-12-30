//
//  delay-start.m
//  Delay Start
//
//  Created by Joseph Markham on 12/25/12.
//  Copyright (c) 2012 Joseph Markham. All rights reserved.
//

#import "delay-start.h"
NSTimer *mainTimer;
NSTimer *updateTimer;


@implementation delay_start

@synthesize delayTimeValue;
@synthesize startupApps;

- (id)init
{
   
    NSLog(@"Hello world");

    if (self) {
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];
        if (!temp) {
            NSLog(@"Error reading plist: %@, format: %ld", errorDesc, format);
        }
        self.delayTimeValue = [NSMutableArray arrayWithArray:[temp objectForKey:@"Time"]];
        self.startupApps = [NSMutableArray arrayWithArray:[temp objectForKey:@"Apps"]];
        //[setTime   setStringValue:[delayTimeValue objectAtIndex:0]];
        //[setTime setStringValue:@"xxx"];
        NSLog(@"%@",[delayTimeValue objectAtIndex:0]);
        
    }
    
    //mainTimer =[NSTimer scheduledTimerWithTimeInterval:5.0
    mainTimer =[NSTimer scheduledTimerWithTimeInterval:[[delayTimeValue objectAtIndex:0] doubleValue]
                                                target:self
                                              selector:@selector(timerDone:)
                                              userInfo:nil
                                               repeats:NO];
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerUpdate:)
                                                userInfo:nil
                                                 repeats:YES];

    
    return self;
}

- (IBAction)displaySomeText:(id)sender;
{
    NSLog(@"displaying log text");
    [updateTimer invalidate];
    [mainTimer invalidate];
    [updateTime setStringValue:@"Cancelled"];
    
}


- (void)timerDone:(id)sender {
    NSLog(@"timer done");
    [updateTimer invalidate];
    [updateTime setStringValue:@"Done"];
    [self launchy];
    
}
- (void)timerUpdate:(id)sender {
    NSDate *mainFireDate = [mainTimer fireDate];
    NSDate *timeNow = [[NSDate alloc] init];
    NSString *dateDescription;
    //NSString *dateRemaining;
    int dateDiffInt;
    //double dateDiff = [timeNow timeIntervalSinceDate:mainFireDate];
    double dateDiff = [mainFireDate timeIntervalSinceDate:timeNow];

    dateDiffInt = round(dateDiff);
    dateDescription = [mainFireDate description];
    NSLog(@"%@",dateDescription);
    //NSLog(@"time diff = %f",dateDiff);
    NSLog(@"time diff = %d",dateDiffInt);
    //sprintf(dateRemaining,"%d", dateDiffInt);
    NSString *dateRemaining = [NSString stringWithFormat:@"%d",dateDiffInt];
    [updateTime setStringValue:dateRemaining];
    NSLog(@"tick");
    
}

- (void)launchy  {
    NSLog(@"launching...");
    NSInteger i ;
    for (i=0; i< self.startupApps.count; i++) {
        
        //Boolean appResult = [[NSWorkspace sharedWorkspace]launchApplication:@"Calculator"];
        NSLog(@"%@",[self.startupApps objectAtIndex:i]);
        Boolean appResult = [[NSWorkspace sharedWorkspace]launchApplication:[self.startupApps objectAtIndex:i]];
        if (!appResult) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Failed to launch the app"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            //[alert release];
        }
    }
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.startupApps.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [startupApps objectAtIndex:row];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    [startupApps replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndex:row] withObjects:[NSArray arrayWithObject:object]];
}

- (void)addNewItemsToAppList:(NSArray *)fileNames{
    //////////////////////////////////////
    //check to see if it is already there
    //////////////////////////////////////
    int i;
    int j;
    //NSMutableArray *appsToAdd;
    NSMutableArray *appsToAdd = [[NSMutableArray alloc] initWithCapacity:100];
    NSString *appName;
    BOOL found;
    for (i=0; i<[fileNames count]; i++) {
        found = NO;
        for (j=0; j<self.startupApps.count; j++) {
            if ([[self.startupApps objectAtIndex:j] isEqualToString:[[[fileNames objectAtIndex:i] path] lastPathComponent]]) {
            //if ([self.startupApps objectAtIndex:j]==[[[fileNames objectAtIndex:i] path] lastPathComponent]) {
                found = YES;
            }
            //NSLog(@"i = %d %@  j=%d %@", i, [[[fileNames objectAtIndex:i] path] lastPathComponent], j, [self.startupApps objectAtIndex:j]);
        }
        if (!found) {
            appName = [[[fileNames objectAtIndex:i] path] lastPathComponent];
            //NSLog(@"checking names %@ %@",appName , [[[fileNames objectAtIndex:i] path] lastPathComponent]);
            [appsToAdd addObject:appName];
            //NSLog(@"No Match, adding %@",appName);
            //NSLog(@"array length is %ld", [appsToAdd count]);
        }
    }
    
    //////////////////////////////////////
    //add it if not in list
    //////////////////////////////////////
    for (i=0; i<[appsToAdd count]; i++) {
        NSLog(@"add %@",[appsToAdd objectAtIndex:i]);
        [self.startupApps addObject:[appsToAdd objectAtIndex:i]];
    }
    //[NSTableView reloadData];
    [appListTableView reloadData];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:
                               [NSArray arrayWithObjects: delayTimeValue, startupApps, nil]
                                                          forKeys:[NSArray arrayWithObjects: @"Time", @"Apps", nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"%@",error);
        //[error release];
    }
    return NSTerminateNow;
}

- (IBAction)removeApp:(id)sender{
    NSInteger selectedItemIndex = [appListTableView selectedRow];
    if (selectedItemIndex == -1) {
        return;
    }
    [self.startupApps removeObjectAtIndex:selectedItemIndex];
    [appListTableView reloadData];
}

- (IBAction)getApps:(id)sender{
    
    // Loop counter.
    int i;
    
    // Create a File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Set array of file types
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"app", nil];
    
    // Enable options in the dialog.
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:TRUE];
    
    // Display the dialog box.  If the OK pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        
        // Gets list of all files selected
        NSArray *files = [openDlg URLs];
        
        // Loop through the files and process them.
        for( i = 0; i < [files count]; i++ ) {
            
            // Do something with the filename.
            //NSLog(@"File path: %@", [[files objectAtIndex:i] path]);
            //NSLog(@"File %@", [[[files objectAtIndex:i] path] lastPathComponent]);
            [self addNewItemsToAppList:files];
            
        }
        
    }
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    NSLog(@"Quitting...");
    return YES;
}


- (void)awakeFromNib {
    [setTime setStringValue:[delayTimeValue objectAtIndex:0]];
}
@end
