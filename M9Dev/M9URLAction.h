//
//  M9URLAction.h
//  M9Dev
//
//  Created by MingLQ on 2015-06-12.
//  Copyright (c) 2015 MingLQ <minglq.9@gmail.com>.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>

#import "M9Utilities.h"
#import "NSURL+M9.h"

@class M9URLAction, M9URLActionHandlerWrapper;

typedef void (^M9URLActionHandlerCompletion)(NSDictionary *result);
typedef void (^M9URLActionHandler)(M9URLAction *action, M9URLActionHandlerCompletion completion);

typedef void (^M9URLActionCompletion)(M9URLAction *action, NSDictionary *result);

/**
 *  1. Config action with url host/path and handler:
 *  !!!: handler MUST call completion with (NSDictionary *)result or nil when action completed
 *      [actionManager configActionWithURLHost:@"profile.update" path:@"/avatar" handler:^void(M9URLAction *action, M9URLActionHandlerCompletion completion) {
 *          NSLog(@"perform: %@ + %@", action, action.prevActionResult);
 *          if (completion) completion(@{ @"x": @1, @"y": @2 });
 *      }];
 *      [actionManager configActionWithURLHost:@"webview.open" path:nil handler:^void(M9URLAction *action, M9URLActionHandlerCompletion completion) {
 *          NSString *urlString = [action.parameters stringForKey:@"url"];
 *          // ...
 *          if (completion) completion(nil);
 *      }];
 *  2. Perform action with url:
 *      NSURL *actionURL = url;
 *      BOOL performed = [actionManager performActionWithURL:actionURL completion:^(M9URLAction *action, NSDictionary *result) {
 *          NSLog(@"completed: %@ >> %@", action.originalAction, result);
 *      }];
 *      NSLog(@"performed: %d", performed);
 *  3. Actions are chained via url-fragment, @see NSURL > Structure of a URL.
 *      m9dev     ://  action.hello  /xxxx  ?  a=1&b=2  #  m9://action.test?...#...
 *      [scheme]  ://  [host]        [path] ?  [query]  #  [fragment]
 *  e.g.
 *      m9://webview.open?url=https%3A%2F%2Fgithub.com%2F
 *                           =encodeURIComponent("https://github.com/")
 *  	m9://root.goto#m9%3A%2F%2Fvideos.open
 *                    #encodeURIComponent("m9://videos.open")
 *  4. Access M9URLAction properties in action-handler.
 */
@interface M9URLActionManager : NSObject

+ (instancetype)globalActionManager;

@property (nonatomic, copy) NSArray<NSString *> *validSchemes;
// @property (nonatomic, copy) NSDictionary<NSString *, M9URLActionHandlerWrapper *> *actionHandlers;

#pragma mark handler

/**
 *  ignore target[-instance]-action if has handler
 *  call completion with result or nil when action completed
 *      if (completion) completion((NSDictionary *)result);
 */
- (void)configActionWithURLHost:(NSString *)host path:(NSString *)path handler:(M9URLActionHandler)handler;

/**
 *  host                host of action url
 *  path                path of action url, path should has prefix /, e.g. @"/root"
 *  target              class or object
 *  instanceSelector    selector of class method to get instance, or @selector(self) for target itself
 *  actionSelector      selector of method with two parameters M9URLAction *action and M9URLActionHandlerCompletion completion
 *  e.g.
 *      + (void)performAction:(M9URLAction *)action completion:(M9URLActionHandlerCompletion)completion;
 *      - (void)performAction:(M9URLAction *)action completion:(M9URLActionHandlerCompletion)completion;
 *  call completion with result or nil when action completed
 *      if (completion) completion((NSDictionary *)result);
 */
- (void)configActionWithURLHost:(NSString *)host
                           path:(NSString *)path
                         target:(id)target
                 actionSelector:(SEL)actionSelector;
- (void)configActionWithURLHost:(NSString *)host
                           path:(NSString *)path
                         target:(id)target
               instanceSelector:(SEL)instanceSelector
                 actionSelector:(SEL)actionSelector;

- (void)removeActionWithURLHost:(NSString *)host path:(NSString *)path;

#pragma mark action

/**
 *  @return YES if action is performed - actionURL is valid && action handler is matched
 */
- (BOOL)performActionWithURL:(NSURL *)actionURL completion:(M9URLActionCompletion)completion;
- (BOOL)performActionWithURLString:(NSString *)actionURLString completion:(M9URLActionCompletion)completion;

@end

#pragma mark -

@interface M9URLAction : NSObject

// actionURL properties: scheme, host, path, queryDictionary - decoded, fragment
@property (nonatomic, readonly, copy) NSURL *actionURL, *nextActionURL; // NSURL with decoded actionURL.fragment

@property (nonatomic, readonly) M9URLAction *originalAction;
@property (nonatomic, readonly) M9URLAction *prevAction;
@property (nonatomic, readonly, copy) NSDictionary *prevActionResult;

+ (M9URLAction *)actionWithURL:(NSURL *)actionURL;

@end
