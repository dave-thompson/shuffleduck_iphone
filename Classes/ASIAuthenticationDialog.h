//
//  ASIAuthenticationDialog.h
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 21/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ASIHTTPRequest;

@interface ASIAuthenticationDialog : NSObject <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	ASIHTTPRequest *request;
	id delegate;
	UIActionSheet *loginDialog;
	NSString *username;
	BOOL repeatAttempt;
}

@property (retain) ASIHTTPRequest *request;
@property (nonatomic, assign) id delegate;
@property (retain) UIActionSheet *loginDialog;
@property (retain) NSString *username;
@property (nonatomic, assign) BOOL repeatAttempt;

+ (void)presentAuthenticationDialogForRequest:(ASIHTTPRequest *)request delegate:(id)aDelegate username:(NSString *)aUsername repeatAttempt:(BOOL)aRepeatAttempt;

@end


@interface NSObject (ASIAuthenticationDialog)

- (void)credentialsEntered;

@end