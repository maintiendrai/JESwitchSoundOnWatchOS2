//
//  InterfaceController.m
//  watchos Extension
//
//  Created by Diana on 10/20/15.
//  Copyright © 2015 maintiendrai. All rights reserved.
//

#import "InterfaceController.h"


#import "MMWormhole.h"
#import "MMWormholeSession.h"

@interface InterfaceController()<NSURLSessionDelegate> {
    NSURLSessionDataTask *_task;
    NSFileManager *_fileManager;
}

@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic, strong) MMWormholeSession *listeningWormhole;
@property (nonatomic, strong) NSString* audioUrl;

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *selectionLabel;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    _fileManager = [NSFileManager defaultManager];
    
    // You are required to initialize the shared listening wormhole before creating a
    // WatchConnectivity session transiting wormhole, as we are below.
    self.listeningWormhole = [MMWormholeSession sharedListeningSession];
    
    // Initialize the wormhole
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.lilkr.lilkrtest"
                                                         optionalDirectory:@"wormhole"
                                                            transitingType:MMWormholeTransitingTypeSessionContext];
    
    // Obtain an initial value for the selection message from the wormhole
    id messageObject = [self.wormhole messageWithIdentifier:@"selection"];
    NSString *string = [messageObject valueForKey:@"selectionString"];
    
    if (string != nil) {
        [self.selectionLabel setText:string];
    }
    
    // Listen for changes to the selection message. The selection message contains a string value
    // identified by the selectionString key. Note that the type of the key is included in the
    // name of the key.
    [self.listeningWormhole listenForMessageWithIdentifier:@"selection" listener:^(id messageObject) {
        NSString *string = [messageObject valueForKey:@"selectionString"];
        
        if (string != nil) {
            [self.selectionLabel setText:string];
        }
        [self saveFileURL:string];
    }];
    
    // Make sure we are activating the listening wormhole so that it will receive new messages from
    // the WatchConnectivity framework.
    [self.listeningWormhole activateSessionListening];
}


- (void)willActivate {
    
    if (!_audioUrl) {
        NSLog(@"click.........11");
        _audioUrl = [self originalURL].absoluteString;
        [self saveFileURL:_audioUrl];
        return;
    }
    
    if ([_fileManager fileExistsAtPath:[self currentSaveAudioURL].absoluteString]) {
        if ([[self currentAudioURL] isEqualToString:_audioUrl] && [_audioUrl isEqualToString:[self originalURL].absoluteString]) {
            NSLog(@"...................2");
            [self playBtnTapped];
        } else {
            NSLog(@".....................3");
            [self saveFileURL:[self currentAudioURL]];
        }
    }
    

}


- (void)saveFileURL:(NSString *)url {
    
    _audioUrl = url;
    
    NSURL *saveUrl = [self currentSaveAudioURL];
    
    if ([_fileManager fileExistsAtPath:saveUrl.absoluteString]) {
        [_fileManager removeItemAtURL:saveUrl error:nil];
    }
    
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    _task = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [data writeToURL:saveUrl atomically:YES];
        });
        [self playBtnTapped];
    }];
    [_task resume];
    
}


- (NSString *)currentAudioURL {
    // Initialize the wormhole
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.lilkr.lilkrtest"
                                                         optionalDirectory:@"wormhole"
                                                            transitingType:MMWormholeTransitingTypeSessionContext];
    
    // Obtain an initial value for the selection message from the wormhole
    id messageObject = [self.wormhole messageWithIdentifier:@"selection"];
    return [messageObject valueForKey:@"selectionString"];
}


- (NSURL *)currentSaveAudioURL {
    return [[_fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.lilkr.lilkrtest"]
            URLByAppendingPathComponent:@"aaa.mp3"];
}


- (IBAction)playBtnPressed:(id)sender {
    [self playBtnTapped];
}

- (NSURL *)originalURL {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"original" ofType:@"mp3"]];
}

- (void)playBtnTapped {
    NSLog(@"............  %@", [self currentSaveAudioURL]);
    [self presentMediaPlayerControllerWithURL:[self currentSaveAudioURL] options:nil completion:^(BOOL didPlayToEnd, NSTimeInterval endTime, NSError * _Nullable error) {
        
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);
        [self dismissMediaPlayerController];
    });
}

@end



