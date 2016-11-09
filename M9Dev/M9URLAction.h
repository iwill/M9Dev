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

typedef void (^M9URLActionHandlerCompletion)(id result);
typedef void (^M9URLActionHandler)(M9URLAction *action, id userInfo, M9URLActionHandlerCompletion completion);

typedef void (^M9URLActionCompletion)(M9URLAction *action, id result);

#pragma mark -

@interface M9URLAction : NSObject

// actionURL.queryDictionary - decoded query key-value pairs
@property (nonatomic, readonly, copy) NSURL *actionURL;

@end

#pragma mark -

/**
 *  1. Config action with url host/path and handler:
 *  !!!: handler MUST call completion with (id)result or nil when action completed
 *      [actionManager configActionWithURLHost:@"profile.update" path:@"/avatar" handler:^void(M9URLAction *action, id userInfo, M9URLActionHandlerCompletion completion) {
 *          NSLog(@"perform: %@ + %@", action, userInfo);
 *          if (completion) completion(@{ @"x": @1, @"y": @2 });
 *      }];
 *      [actionManager configActionWithURLHost:@"webview.open" path:nil handler:^void(M9URLAction *action, id userInfo, M9URLActionHandlerCompletion completion) {
 *          NSString *urlString = [action.parameters stringForKey:@"url"];
 *          // ...
 *          if (completion) completion(nil);
 *      }];
 *  2. Perform action with url:
 *      NSURL *actionURL = url;
 *      BOOL performed = [actionManager performActionWithURL:actionURL userInfo:nil completion:^(M9URLAction *action, id userInfo, id result) {
 *          NSLog(@"completed: %@ >> %@", action, result);
 *      }];
 *      NSLog(@"performed: %d", performed);
 *  3. @see NSURL > Structure of a URL.
 *      m9dev     ://  action.hello  /xxxx  ?  a=1&b=2  #  yyyy
 *      [scheme]  ://  [host]        [path] ?  [query]  #  [fragment]
 *  e.g.
 *      m9://webview.open?url=https%3A%2F%2Fgithub.com%2F
 *                            encodeURIComponent("https://github.com/")
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
 *      if (completion) completion((id)result);
 */
- (void)configActionWithURLHost:(NSString *)host path:(NSString *)path handler:(M9URLActionHandler)handler;

/**
 *  host                host of action url
 *  path                path of action url, path should has prefix /, e.g. @"/root"
 *  target              class or object
 *  instanceSelector    selector of class method to get instance, or @selector(self) for target itself
 *  actionSelector      selector of method with THREE parameters: (M9URLAction *)action, (id)userInfo, (M9URLActionHandlerCompletion)completion
 *  e.g.
 *      +/- (void)performAction:(M9URLAction *)action userInfo:(id)userInfo completion:(M9URLActionHandlerCompletion)completion;
 *  call completion with result or nil when action completed
 *      if (completion) completion((id)result);
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
- (BOOL)performActionWithURLString:(NSString *)actionURLString completion:(M9URLActionCompletion)completion;
- (BOOL)performActionWithURL:(NSURL *)actionURL completion:(M9URLActionCompletion)completion;
- (BOOL)performActionWithURL:(NSURL *)actionURL userInfo:(id)userInfo completion:(M9URLActionCompletion)completion;

@end

/**
 *  Actions are chained via encoded url-fragment, the result is pass to next action as userInfo.
 *  e.g.
 *  	m9://root.goto#m9%3A%2F%2Fvideos.open
 *                     encodeURIComponent("m9://videos.open")
 */
@interface M9URLActionManager (M9ChainingViaURLFragment)

- (BOOL)performChainingActionWithURL:(NSURL *)actionURL userInfo:(id)userInfo completion:(M9URLActionCompletion)completion;

@end
