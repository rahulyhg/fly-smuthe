//
//  ThreadUtility.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 3/29/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation

class ThreadUtility {
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    class func delayCancelable(delay: Double, closure:()->()) -> dispatch_cancelable_block_t? {
        return dispatch_block_t(delay, block: closure);
    }
    
    class func cancel(block: dispatch_cancelable_block_t?){
        dispatch_cancel_block_t(block);
    }
    
    class func runOnBackgroundPriorityBackgroundThread(closure: ()->()){
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(queue, closure);
    }
    
    class func runOnDefaultPriorityBackgroundThread(closure: ()->()){
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, closure);
    }
    
    class func runOnHighPriorityBackgroundThread(closure: ()->()){
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue, closure);
    }
    
    class func runOnMainThread(closure: ()->()){
        if(!NSThread.isMainThread()){
            dispatch_async(dispatch_get_main_queue(), closure);
        } else {
            closure();
        }
    }
}