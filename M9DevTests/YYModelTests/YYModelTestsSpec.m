//
//  YYModelTestsSpec.m
//  TestPodSpec
//
//  Created by MingLQ on 2015-11-27.
//  Copyright 2015年 __MyCompanyName__. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#if !defined(EXP_SHORTHAND)
#define EXP_SHORTHAND
#endif

#import <YYModel/YYModel.h>

#import "NSDictionary+M9.h"

@interface User : NSObject
@property UInt64 uid;
@property NSString *name;
@property NSDate *created;
@end
@implementation User
@end

@interface Author : NSObject
@property NSString *name;
@property NSDate *birthday;
@end
@implementation Author
@end

@interface Book : NSObject
@property NSString *name;
@property NSInteger page;
@property NSString *desc;
@property Author *author;
@end
@implementation Book
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"name": @"n",
              @"page": @"p",
              @"desc": @"ext.desc" };
}
@end

@interface Shadow : NSObject
@property CGPoint offset;
@end
@implementation Shadow
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSDictionary *offset = [dic dictionaryForKey:@"offset"];
    self.offset = CGPointMake([offset doubleForKey:@"x"], [offset doubleForKey:@"y"]);
    return YES;
}
@end

@interface Border : NSObject
@property CGFloat width;
@end
@implementation Border
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.width = [dic doubleForKey:@"width"];
    return YES;
}
@end

@interface Attachment : NSObject
@property NSString *imageURL;
@end
@implementation Attachment
@end

@interface Attributes : NSObject
@property NSString *name;
@property NSArray *shadows; // NSArray<Shadow>
@property NSSet *borders; // NSSet<Border>
@property NSMutableDictionary *attachments; // NSMutableDictionary<NSString, Attachment>
@end
@implementation Attributes
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"shadows": [Shadow class],
              @"borders": [Border class],
              @"attachments": NSStringFromClass([Attachment class]) };
}
@end

@interface Bug : NSObject
@property BOOL          b1, b2, b3, b4, b5;
@property NSInteger     i1, i2, i3, i4, i5;
@property NSString      *s1, *s2, *s3, *s4, *s5;
@property NSArray       *a1, *a2, *a3, *a4, *a5;
@property NSDictionary  *d1, *d2, *d3, *d4, *d5;
@end
@implementation Bug
@end

@interface Bug2 : NSObject
@property BOOL b;
@end
@implementation Bug2
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    return NO;
}
@end

SpecBegin(YYModelTests)

describe(@"Expecta", ^{
    beforeAll(^{
    });
    
    beforeEach(^{
    });
    
    it(@"should work", ^{
        expect(nil).beNil();
        // expect(nil).notTo.beNil();
    });
    
    afterEach(^{
    });
    
    afterAll(^{
    });
    
});

describe(@"YYModel", ^{
    
    it(@"should be a User", ^{
        User *user = [User yy_modelWithJSON:@{ @"uid":      @123456,
                                               @"name":     @"Harry",
                                               @"created":  @"1965-07-31T00:00:00+0000" }];
        expect(user).notTo.beNil();
        expect(user.uid).equal(123456);
        expect(user.name).equal(@"Harry");
        expect(user.created).notTo.beNil();
        NSLog(@"user.created: %@", user.created);
    });
    
    it(@"should be a Book", ^{
        Book *book = [Book yy_modelWithJSON:@{ @"n": @"Harry Pottery",
                                               @"p": @256,
                                               @"ext" : @{ @"desc": @"A book written by J.K.Rowing." } }];
        expect(book).notTo.beNil();
        expect(book.name).equal(@"Harry Pottery");
        expect(book.page).equal(256);
        expect(book.desc).equal(@"A book written by J.K.Rowing.");
    });
    
    it(@"should has an Author", ^{
        Book *book = [Book yy_modelWithJSON:@{ @"author": @{ @"name": @"J.K.Rowling",
                                                             @"birthday": @"1965-07-31T00:00:00+0000" },
                                               @"name": @"Harry Potter",
                                               @"pages": @256 }];
        expect(book).notTo.beNil();
        expect(book.author).notTo.beNil();
        expect(book.author.name).equal(@"J.K.Rowling");
        expect(book.author.birthday).notTo.beNil();
    });
    
    it(@"should has shadows, borders and attachments", ^{
        Attributes *attributes = [Attributes yy_modelWithJSON:@{ @"name": @"div",
                                                                 @"shadows": @[ @{ @"offset": @{ @"x": @2, @"y": @2 } },
                                                                                @{ @"offset": @{ @"x": @4, @"y": @4 } } ],
                                                                 @"borders": @[ @{ @"width": @0.5 },
                                                                                @{ @"width": @1.0 } ],
                                                                 @"attachments": @{ @"avatar":      @{ @"imageURL": @"http://gen.sx/6f78dsf78ds6" },
                                                                                    @"background":  @{ @"imageURL": @"http://gen.sx/8f9ds89f789d" } } }];
        expect(attributes).notTo.beNil();
        expect(attributes.name).equal(@"div");
        
        expect(attributes.shadows.count).equal(2);
        Shadow *shadow1 = attributes.shadows[0];
        Shadow *shadow2 = attributes.shadows[1];
        expect(shadow1.offset).equal(CGPointMake(2, 2));
        expect(shadow2.offset).equal(CGPointMake(4, 4));
        
        expect(attributes.borders.count).equal(2);
        NSArray *borders = [attributes.borders allObjects];
        Border *border1 = borders[0];
        Border *border2 = borders[1];
        expect(border1.width).beGreaterThanOrEqualTo(0.5);
        expect(border1.width).beLessThanOrEqualTo(1.0);
        expect(border2.width).beGreaterThanOrEqualTo(0.5);
        expect(border2.width).beLessThanOrEqualTo(1.0);
        
        expect(attributes.attachments.count).equal(2);
        Attachment *attachment1 = attributes.attachments[@"avatar"];
        Attachment *attachment2 = attributes.attachments[@"background"];
        expect(attachment1.imageURL).equal(@"http://gen.sx/6f78dsf78ds6");
        expect(attachment2.imageURL).equal(@"http://gen.sx/8f9ds89f789d");
    });
    
    // NOTE: https://github.com/ibireme/YYModel/pull/12
    it(@"别玩坏了 🙏", ^{
        Bug *bug = [Bug yy_modelWithJSON:@{ @"b1": @YES,            // 1
                                            @"b2": @123,            // 1
                                            @"b3": @"true",         // 1
                                            @"b4": @"string",       // 0
                                            @"b5": @[],             // 0
                                            @"i1": @YES,            // 1
                                            @"i2": @123,            // 123
                                            @"i3": @"123",          // 123
                                            @"i4": [NSNull null],   // 0
                                            @"i5": @{},             // 0
                                            @"s1": @YES,            // 1
                                            @"s2": @123,            // 123
                                            @"s3": @"string",       // string
                                            @"s4": [NSNull null],   // nil
                                            @"s5": @[],             // nil
                                            @"a1": @YES,            // nil
                                            @"a2": @123,            // nil
                                            @"a3": @"string",       // nil
                                            @"a4": [NSNull null],   // nil
                                            @"a5": @[ @1, @2, @3 ], // [ 1, 2, 3 ]
                                            @"d1": @YES,            // nil
                                            @"d2": @123,            // nil
                                            @"d3": @"string",       // nil
                                            @"d4": [NSNull null],   // nil
                                            @"d5": @{ @"a": @1, @"b": @2, @"c": @3 } // { a: 1, b: 2, c: 3 }
                                            }];
        expect(bug).notTo.beNil();
    });
    
    it(@"别玩坏了 🙏🙏", ^{
        NSArray *bugs = [NSArray yy_modelArrayWithClass:[Bug class] json:@[ @{}, @{} ]];
        expect(bugs.count).equal(2);
    });
    
    // TODO: https://github.com/ibireme/YYModel/issues/13
    /* it(@"真的玩坏了 🙏🙏🙏", ^{
        Bug2 *bug = [Bug2 yy_modelWithJSON:@{ @"b": @YES }];
        expect(bug).beNil();
        NSArray *bugs = [NSArray yy_modelArrayWithClass:[Bug2 class] json:@[ @{}, @{ @"b": @YES } ]];
        expect(bugs.count).equal(1);
    }); */
    
});

SpecEnd
