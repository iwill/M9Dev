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

@interface M9URLAction : NSObject

/** Decoded query key-value pairs are available in actionURL.queryDictionary. */
@property (nonatomic, readonly) NSURL *actionURL;

@end

#pragma mark -

typedef void (^M9URLActionHandleCompletion)(id result);
typedef void (^M9URLActionHandler)(M9URLAction *action, id userInfo, M9URLActionHandleCompletion completion);

typedef void (^M9URLActionCompletion)(M9URLAction *action, id result);

/**
 *  Config action with URL scheme, host/path and handler.
 *  - Parameters combination:
 *      scheme://[[host]/path]
 *      [host]/path
 *  - Handlers <#MUST#> call completion with (id)result or nil when action completed;
 *
 *  Perform action with URL, userInfo and completion.
 *  - URL format - @see NSURL > Structure of a URL:
 *      m9dev     ://  action.hello  /xxxx  ?  a=1&b=2  #  yyyy
 *      [scheme]  ://  [host]        [path] ?  [query]  #  [fragment]
 *    e.g.
 *      m9://webview.open?url=https%3A%2F%2Fgithub.com%2F
 *                            encodeURIComponent("https://github.com/")
 *  - Matching action handlers in order:
 *      scheme://[host]/path
 *      scheme
 *      [host]/path
 *  - Action result returns from action-handler is available in the completion block.
 */
@interface M9URLActionManager : NSObject

+ (instancetype)globalActionManager;

/** Case insensitive. */
@property (nonatomic, copy) NSArray<NSString *> *validSchemes;

/**
 *  Config action with block handler.
 *
 *  @param scheme   case insensitive
 *  @param host     case insensitive, use @"" if nil and path is not nil
 *  @param path     should has prefix /, e.g. @"/root";
 *  @param handler  MUST call completion with result or nil when handling action completed
 */
- (void)configWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path handler:(M9URLActionHandler)handler;
- (void)configWithScheme:(NSString *)scheme handler:(M9URLActionHandler)handler;
- (void)configWithHost:(NSString *)host path:(NSString *)path handler:(M9URLActionHandler)handler;

/**
 *  Config action with target[-instance]-action.
 *
 *  @param scheme   case insensitive
 *  @param host     case insensitive, use @"" if nil and path is not nil
 *  @param path     should has prefix /, e.g. @"/root";
 *  @param target   class or object
 *  @param instance class method selector to get instance
 *  @param action   class/instance method selector with THREE arguments, and MUST call completion with result or nil when handling action completed
 *                  e.g. +/- (void)performAction:(M9URLAction *)action userInfo:(id)userInfo completion:(M9URLActionHandleCompletion)completion;
 */
- (void)configWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path
                  target:(id)target instance:(SEL)instance action:(SEL)action;
- (void)configWithScheme:(NSString *)scheme
                  target:(id)target instance:(SEL)instance action:(SEL)action;
- (void)configWithHost:(NSString *)host path:(NSString *)path
                target:(id)target instance:(SEL)instance action:(SEL)action;

/** Remove action config. */
- (void)removeConfigWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path;

/**
 *  Perform action with URL and user info.
 *
 *  @return performed - actionURL matched an action handler
 */
- (BOOL)performActionWithURL:(NSURL *)actionURL userInfo:(id)userInfo completion:(M9URLActionCompletion)completion;
- (BOOL)performActionWithURLString:(NSString *)actionURLString completion:(M9URLActionCompletion)completion;

@end

@interface M9URLActionManager (M9Additions)

/**
 *  Perform chaining action with URL and user info.
 *
 *  Actions are chained via decoded URL-fragment.
 *  Action result returns from action-handler is pass to next action as userInfo.
 *  e.g.
 *      perform(m9://root.goto#m9%3A%2F%2Fvideos.open, userInfo-1)
 *          handle(m9://root.goto, userInfo-1)      >> result-1
 *          decode(m9%3A%2F%2Fvideos.open)          >> m9://videos.open 
 *      perform(m9://videos.open, result-1 as userInfo-2)
 *          handle(m9://videos.open, userInfo-2)    >> result-2
 *          completion(result-2)
 */
- (BOOL)performChainingActionWithURL:(NSURL *)actionURL userInfo:(id)userInfo completion:(M9URLActionCompletion)completion;

@end
