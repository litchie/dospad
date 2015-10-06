//
//  MongooseDaemon.m
//
//  Created by Rama McIntosh on 3/4/09.
//  Copyright Rama McIntosh 2009. All rights reserved.
//

//
// Copyright (c) 2009, Rama McIntosh All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
// * Neither the name of Rama McIntosh nor the names of its
//   contributors may be used to endorse or promote products derived
//   from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//

// MongooseDaemon is a small wrapper to make ingetrating mongoose
// with iPhone apps super easy

#import "MongooseDaemon.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
 #include <unistd.h>
#include <ifaddrs.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
//#define DOCUMENTS_FOLDER NSHomeDirectory()

@implementation MongooseDaemon

@synthesize ctx;

// ----------------------------------------------------------------------------------------------------------
- (NSString *)localIPAddress
{
	NSString *address = @"error";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0)
	{
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while(temp_addr != NULL)
		{
			if(temp_addr->ifa_addr->sa_family == AF_INET)
			{
				// Check if interface is en0 which is the wifi connection on the iPhone
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
				{
					// Get NSString from C String
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
			}
			
			temp_addr = temp_addr->ifa_next;
		}
	}
	
	// Free memory
	freeifaddrs(interfaces);
	
	return address;
}

#if 0
// Return the localized IP address - From Erica Sadun's cookbook
- (NSString *) localIPAddress
{
	char baseHostName[255];
	gethostname(baseHostName, 255);
	
	// Adjust for iPhone -- add .local to the host name
	char hn[255];
	sprintf(hn, "%s.local", baseHostName);
	
	struct hostent *host = gethostbyname(hn);
    if (host == NULL)
	{
        herror("resolv");
		return NULL;
	}
    else {
        struct in_addr **list = (struct in_addr **)host->h_addr_list;
		return [NSString stringWithCString:inet_ntoa(*list[0])];
    }
	
	return NULL;
}
#endif

- (void)startHTTP:(NSString *)ports
{
  self.ctx = mg_start();     // Start Mongoose serving thread
  mg_set_option(ctx, "root", [DOCUMENTS_FOLDER UTF8String]);  // Set document root
  mg_set_option(ctx, "ports", [ports UTF8String]);    // Listen on port XXXX
  //mg_bind_to_uri(ctx, "/foo", &bar, NULL); // Setup URI handler

  // Now Mongoose is up, running and configured.
  // Serve until somebody terminates us
  NSLog(@"Mongoose Server is running on http://%@:8080", [self localIPAddress]);
}

- (void)startMongooseDaemon:(NSString *)ports;
{
  [self startHTTP:ports];
}

- (void)stopMongooseDaemon
{
  mg_stop(ctx);
}

@end
