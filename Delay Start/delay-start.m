//
//  delay-start.m
//  Delay Start
//
//  Created by Joseph Markham on 12/25/12.
//  Copyright (c) 2012 Joseph Markham. All rights reserved.
//

// Feature list
// willNotBeDone have delay-start launch an AppleScript (not actually possible)
// TODO Delay-Start does not launch Dropbox or Path Finder
// done a “Launch Now” button to skip the timer
// done say which app failed to launch
//

#import "delay-start.h"

NSTimer *mainTimer;
NSTimer *updateTimer;


@implementation delay_start

@synthesize delayTimeValue;
@synthesize startupApps;
@synthesize quitAfterStartup;

- (id)init
{
   
    ////NSLog(@"Hello world");

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
            ////NSLog(@"Error reading plist: %@, format: %ld", errorDesc, format);
        }
        self.delayTimeValue = [NSMutableArray arrayWithArray:[temp objectForKey:@"Time"]];
        self.startupApps = [NSMutableArray arrayWithArray:[temp objectForKey:@"Apps"]];
        self.quitAfterStartup = [NSMutableArray arrayWithArray:[temp objectForKey:@"Quit"]];

        //[setTime   setStringValue:[delayTimeValue objectAtIndex:0]];
        //[setTime setStringValue:@"xxx"];
        ////NSLog(@"%@",[delayTimeValue objectAtIndex:0]);
        
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
    ////NSLog(@"displaying log text");
    [updateTimer invalidate];
    [mainTimer invalidate];
    [updateTime setStringValue:@"Cancelled"];
    
}

- (IBAction)bumpUp:(id)sender;
{
    NSInteger selectedItemIndex = [appListTableView selectedRow];
    if (selectedItemIndex < 1) {
        return;
    }
    NSLog(@"bump up %li",(long)selectedItemIndex);
    NSLog(@"items %li", self.startupApps.count);
    [startupApps exchangeObjectAtIndex:selectedItemIndex withObjectAtIndex:(selectedItemIndex -1)];
    [appListTableView reloadData];
}



- (IBAction)bumpDown:(id)sender;
{
    NSInteger selectedItemIndex = [appListTableView selectedRow];
    if ((selectedItemIndex == -1) || (selectedItemIndex > (self.startupApps.count - 2))) {
        return;
    }
    NSLog(@"bump down %li",(long)selectedItemIndex);
    [startupApps exchangeObjectAtIndex:selectedItemIndex withObjectAtIndex:(selectedItemIndex +1)];
    [appListTableView reloadData];
}


- (IBAction)launchNow:(id)sender;
{
    NSLog(@"launchNow clicked");
    [self launchy];
}

- (void)timerDone:(id)sender {
    ////NSLog(@"timer done");
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
    ////NSLog(@"%@",dateDescription);
    //////NSLog(@"time diff = %f",dateDiff);
    ////NSLog(@"time diff = %d",dateDiffInt);
    //sprintf(dateRemaining,"%d", dateDiffInt);
    NSString *dateRemaining = [NSString stringWithFormat:@"%d",dateDiffInt];
    [updateTime setStringValue:dateRemaining];
    ////NSLog(@"tick");
    
}

- (void)launchy  {
    ////NSLog(@"launching...");
    NSInteger i ;
    NSString *app;
    NSString *errorMessage;
    for (i=0; i< self.startupApps.count; i++) {
        
        //Boolean appResult = [[NSWorkspace sharedWorkspace]launchApplication:@"Calculator"];
        //NSLog(@"%@",[self.startupApps objectAtIndex:i]);
        app =  [self.startupApps objectAtIndex:i];
        Boolean appResult = [[NSWorkspace sharedWorkspace]launchApplication:[self.startupApps objectAtIndex:i]];
        if (!appResult) {
            errorMessage = [@"Failed to launch " stringByAppendingString:app];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:errorMessage ];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            //[alert release];
        }
    }
    //kill the app here if the checkbox is set
    NSInteger shouldQuit = [quitStart state];
    if (shouldQuit == 1) {
        [NSApp terminate:self];
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
    NSString *delayTest;
    BOOL found;
    for (i=0; i<[fileNames count]; i++) {
        found = NO;
        delayTest = [[fileNames objectAtIndex:i] substringToIndex:2];
        NSLog(delayTest);
        if (![delayTest isEqualToString:@"--"]) {
            for (j=0; j<self.startupApps.count; j++) {
                //TODO fix path for delay timers
                if ([[self.startupApps objectAtIndex:j] isEqualToString:[[[fileNames objectAtIndex:i] path] lastPathComponent]]) {
                    //if ([self.startupApps objectAtIndex:j]==[[[fileNames objectAtIndex:i] path] lastPathComponent]) {
                    found = YES;
                }
                //////NSLog(@"i = %d %@  j=%d %@", i, [[[fileNames objectAtIndex:i] path] lastPathComponent], j, [self.startupApps objectAtIndex:j]);
            }
        }
        if (!found) {
            if (![delayTest isEqualToString:@"--"]) {
                appName = [[[fileNames objectAtIndex:i] path] lastPathComponent];
            }else{
                appName = [fileNames objectAtIndex:i];
            }
            //////NSLog(@"checking names %@ %@",appName , [[[fileNames objectAtIndex:i] path] lastPathComponent]);
            [appsToAdd addObject:appName];
            //////NSLog(@"No Match, adding %@",appName);
            //////NSLog(@"array length is %ld", [appsToAdd count]);
        }
    }
    
    //////////////////////////////////////
    //add it if not in list
    //////////////////////////////////////
    for (i=0; i<[appsToAdd count]; i++) {
        ////NSLog(@"add %@",[appsToAdd objectAtIndex:i]);
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
                               [NSArray arrayWithObjects: delayTimeValue, startupApps, quitAfterStartup, nil]
                                                          forKeys:[NSArray arrayWithObjects: @"Time", @"Apps", @"Quit", nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else {
        ////NSLog(@"%@",error);
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

- (IBAction)updatePreset:(id)sender{
    NSInteger checkForInt = [[setTime stringValue] integerValue];
    //NSLog(@"%@",[setTime stringValue]);
    if (checkForInt == 0) {
        //NSLog(@"%li", checkForInt);
        //change checkForInt to original value, then update the field
        checkForInt = [[self.delayTimeValue objectAtIndex:0] integerValue];
        [setTime setStringValue:[self.delayTimeValue objectAtIndex:0]];
    }
    
    [self.delayTimeValue replaceObjectAtIndex:0 withObject:[setTime stringValue]];
}

- (IBAction)updateQuitStart:(id)sender{
    NSLog(@"Updating the checkbox");
    NSLog(@"state %ld", (long)[sender state]);
    NSNumber *updateValue = [[NSNumber alloc] initWithLong:[sender state]];
    //NSInteger updateValue = [sender state];
    //NSInteger *updateValue = [[NSInteger alloc] init];
    [self.quitAfterStartup replaceObjectAtIndex:0 withObject:updateValue];
    
}

- (IBAction)addDelay:(id)sender{
    NSString *delayTime = [self input:@"add test" defaultValue:@"default"];
    NSInteger *intTime;
    NSArray *files;
    NSString *tempString;
    
    NSLog(@"Delay the item %@", delayTime);
    if (stringIsNumeric(delayTime)) {
        intTime = [delayTime intValue];
        tempString = [NSString stringWithFormat:@"--delay %li seconds", (long)intTime];
        NSLog(tempString);
        //[files addObject: tempString];
        files = [NSArray arrayWithObjects:tempString, nil];

        [self addNewItemsToAppList:files];
    } else {
        intTime = 0;
    }
    NSLog(@"delay time %li", (long)intTime);
}




- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    //[input autorelease];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        NSAssert1(NO, @"Invalid input dialog button %li", (long)button);
        return nil;
    }
}

BOOL stringIsNumeric(NSString *str) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    //[formatter release];
    return !!number; // If the string is not numeric, number will be nil
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
            //////NSLog(@"File path: %@", [[files objectAtIndex:i] path]);
            //////NSLog(@"File %@", [[[files objectAtIndex:i] path] lastPathComponent]);
            [self addNewItemsToAppList:files];
            
        }
        
    }
    
}

- (IBAction)menuAbout:(id)sender{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Delay Start"];
    [alert setInformativeText:@"As small a tool as it can be"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert runModal];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    ////////NSLog(@"Quitting...");
    return YES;
}


- (void)awakeFromNib {
    [setTime setStringValue:[delayTimeValue objectAtIndex:0]];
    //[quitStart setState:[quitAfterStartup objectAtIndex:0]];
    NSNumber *updateValue = [quitAfterStartup objectAtIndex:0];
    NSInteger updateValueNumber = [updateValue integerValue];
    NSLog(@"initializing the checkbox %li",(long)updateValueNumber);
    [quitStart setState:updateValueNumber];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

}

- (IBAction)displayTheHelp:(id)sender{
    //NSLog(@"Trying to display help");
    
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"Delay Start" withExtension:@"html"];
    BOOL result =  [[NSWorkspace sharedWorkspace] openURL:(url)];
    
    url = [[NSBundle mainBundle] URLForResource:@"icon_32x32" withExtension:@"png"];
    //NSLog(@"%@",url);
}

@end
