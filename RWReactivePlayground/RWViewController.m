//
//  RWViewController.m
//  RWReactivePlayground
//
//  Created by Colin Eberhardt on 18/12/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "RWViewController.h"
#import "RWDummySignInService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RWViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signInFailureText;

@property (strong, nonatomic) RWDummySignInService *signInService;

@end

@implementation RWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signInService = [RWDummySignInService new];

    // initially hide the failure message
    self.signInFailureText.hidden = YES;
    
    // This creates a signal called validUsernameSignal that takes the current text from the usernameTextField and, using a map function that takes a string called 'username', returns the boolean value of isValidUsername as it pertains to the passed 'username' string.
    RACSignal *validUsernameSignal = [self.usernameTextField.rac_textSignal map:^id(NSString *username) {return @([self isValidUsername:username]);}];
    
    // This creates a signal called validPasswordSignal that takes the current text from the passwordTextField and, using a map function that takes a string called 'password', returns the boolean value of isValidPassword as it pertains to the passed 'password' string.
    RACSignal *validPasswordSignal = [self.passwordTextField.rac_textSignal map:^id(NSString *password) {return @([self isValidPassword:password]);}];
    
    // This macro takes the boolean value of validUsernameSignal and returns the appropriate UIColor to set to the backgroundColor property of usernameTextField. By wrapping validUsernameSignal as an NSNumber and then calling boolValue, the macro is able to pass a boolean value to the map function, determine the boolean state, and select an action based on that state.
    RAC(self.usernameTextField, backgroundColor) = [validUsernameSignal map:^id(NSNumber *usernameValid) {return [usernameValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];}];

    // This macro takes the boolean value of validPasswordSignal and returns the appropriate UIColor to set to the backgroundColor property of passwordTextField. By wrapping validPasswordSignal as an NSNumber and then calling boolValue, the macro is able to pass a boolean value to the map function, determine the boolean state, and select an action based on that state.
    RAC(self.passwordTextField, backgroundColor) = [validPasswordSignal map:^id(NSNumber *passwordValid) {return [passwordValid boolValue] ? [UIColor clearColor]: [UIColor yellowColor];}];
    
    // This creates a signal that takes the boolean values of validUsernameSignal and validPasswordSignal and, after wrapping them in NSNumbers, combines/reduces them to one boolean value called 'signUpButtonEnabledSignal'
    RACSignal *signUpButtonEnabledSignal = [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal] reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid) {return @([usernameValid boolValue] && [passwordValid boolValue]);}];
    
    // This is simply a subscription to signUpButtonEnabledSignal to link the signal's boolean value to the enabled property of the signInButton
    [signUpButtonEnabledSignal subscribeNext:^(NSNumber *signUpActive){self.signInButton.enabled = [signUpActive boolValue];}];

}


// This boolean takes a string called 'username' and returns YES if the string is longer than 3 characters. Otherwise it returns NO
- (BOOL)isValidUsername:(NSString *)username {
  return username.length > 3;
}

// This boolean takes a string called 'password' and returns YES if the string is longer than 3 characters. Otherwise it returns NO
- (BOOL)isValidPassword:(NSString *)password {
  return password.length > 3;
}

- (IBAction)signInButtonTouched:(id)sender {
  // disable all UI controls
  self.signInButton.enabled = NO;
  self.signInFailureText.hidden = YES;
  
  // sign in
  [self.signInService signInWithUsername:self.usernameTextField.text
                            password:self.passwordTextField.text
                            complete:^(BOOL success) {
                              self.signInButton.enabled = YES;
                              self.signInFailureText.hidden = success;
                              if (success) {
                                [self performSegueWithIdentifier:@"signInSuccess" sender:self];
                              }
                            }];
}

@end
