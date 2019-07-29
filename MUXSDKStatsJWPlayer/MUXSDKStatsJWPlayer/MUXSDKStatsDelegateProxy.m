//
//  MUXSDKStatsDelegateProxy.m
//  TestbedObjc
//
//  Created by Ruslan Sokolov on 7/11/19.
//  Copyright © 2019 Ruslan Sokolov. All rights reserved.
//

#import <objc/runtime.h>
#import "MUXSDKStatsDelegateProxy.h"

@interface MUXJWPlayerSDKDelegateProxy ()

@property (nonatomic, copy) NSHashTable * delegates;

@end

@implementation MUXJWPlayerSDKDelegateProxy

- (void)addDelegate:(id<JWPlayerDelegate>)delegate {
    if (!self.delegates) {
        self.delegates = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
    }
    [self.delegates addObject:delegate];
}

- (BOOL)respondsToSelector:(SEL)selector {
    for (id delegate in self.delegates.allObjects) {
        if ([delegate respondsToSelector:selector]) {
            return YES;
        }
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    struct objc_method_description method =
        protocol_getMethodDescription(@protocol(JWPlayerDelegate), selector, NO, YES);
    return [NSMethodSignature signatureWithObjCTypes:method.types];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    for (id delegate in self.delegates.allObjects) {
        if ([delegate respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegate];
        }
    }
}

@end
