//
//  ViewController.m
//  JESwitchSoundOnWatchOS2
//
//  Created by Diana on 10/20/15.
//  Copyright © 2015 maintiendrai. All rights reserved.
//

#import "ViewController.h"

#import "MMWormhole.h"
#import "MMWormholeSession.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) MMWormhole *traditionalWormhole;
@property (nonatomic, strong) MMWormhole *watchConnectivityWormhole;
@property (nonatomic, strong) MMWormholeSession *watchConnectivityListeningWormhole;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the wormhole
    self.traditionalWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.lilkr.lilkrtest"
                                                                    optionalDirectory:@"wormhole"];
    
    // Initialize the MMWormholeSession listening wormhole.
    // You are required to do this before creating a Wormhole with the Session Transiting Type, as we are below.
    self.watchConnectivityListeningWormhole = [MMWormholeSession sharedListeningSession];
    
    // Initialize the wormhole using the WatchConnectivity framework's application context transiting type
    self.watchConnectivityWormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.lilkr.lilkrtest"
                                                                          optionalDirectory:@"wormhole"
                                                                             transitingType:MMWormholeTransitingTypeSessionContext];
    
    // Become a listener for changes to the wormhole for the button message
    [self.traditionalWormhole listenForMessageWithIdentifier:@"button" listener:^(id messageObject) {
        // The number is identified with the buttonNumber key in the message object
        NSNumber *number = [messageObject valueForKey:@"buttonNumber"];
        self.numberLabel.text = [number stringValue];
    }];
    
    // Become a listener for changes to the wormhole for the button message
    [self.watchConnectivityListeningWormhole listenForMessageWithIdentifier:@"button" listener:^(id messageObject) {
        // The number is identified with the buttonNumber key in the message object
        NSNumber *number = [messageObject valueForKey:@"buttonNumber"];
        self.numberLabel.text = [number stringValue];
    }];
    
    // Make sure we are activating the listening wormhole so that it will receive new messages from
    // the WatchConnectivity framework.
    [self.watchConnectivityListeningWormhole activateSessionListening];
    
    [self segmentedControlValueDidChange:self.segmentedControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Obtain an initial message from the wormhole
    id messageObject = [self.traditionalWormhole messageWithIdentifier:@"button"];
    NSNumber *number = [messageObject valueForKey:@"buttonNumber"];
    
    self.numberLabel.text = [number stringValue];
    
    // Obtain an initial message from the wormhole
    messageObject = [self.watchConnectivityWormhole messageWithIdentifier:@"button"];
    number = [messageObject valueForKey:@"buttonNumber"];
    
    self.numberLabel.text = [number stringValue];
}

- (IBAction)segmentedControlValueDidChange:(UISegmentedControl *)segmentedControl {
    NSString *title = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    
    // Pass a message for the selection identifier. The message itself is a NSCoding compliant object
    // with a single value and key called selectionString.
    //    if (segmentedControl.selectedSegmentIndex == 1) {
    //        title = @"http://7vzmkg.com1.z0.glb.clouddn.com/wave/1AAD605ED1A5EDEB.mp3";
    title = @"http://data.wei-ju.com.cn/wave/vcrmsdlkj2w8508uiq7l2.mp3";
    //    }
    [self.traditionalWormhole passMessageObject:@{@"selectionString" : title} identifier:@"selection"];
    [self.watchConnectivityWormhole passMessageObject:@{@"selectionString" : title} identifier:@"selection"];
}


@end
