//
//  PageViewController.swift
//  Fly Smuthe
//
//  Created by Adam M Rivera on 8/26/15.
//  Copyright (c) 2015 Adam M Rivera. All rights reserved.
//

import Foundation
import UIKit

class PageViewController : UIViewController, UIPageViewControllerDataSource {
    
    
    let findSmoothAirIdx = 0;
    let reportAirConditionIdx = 1;
    
    var currentIdx = 0;
    var totalPages = 2;
    var pageViewController: UIPageViewController!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let pageControl = UIPageControl.appearance();
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor();
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor();
        pageControl.backgroundColor = UIColor.whiteColor();
        
        pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PageViewController")! as! UIPageViewController;
        pageViewController.dataSource = self;
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var idx = (viewController as! PagedViewControllerBase).pageIndex!;
        
        if(idx == 0) {
            return nil;
        }
        
        idx--;
        return self.viewControllerAtIndex(idx);
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var idx = (viewController as! PagedViewControllerBase).pageIndex!;
        
        idx++;
        
        if(idx == totalPages) {
            return nil;
        }
        return self.viewControllerAtIndex(idx);
    }
    
    func viewControllerAtIndex(index: Int) -> PagedViewControllerBase! {
        currentIdx = index;
        let pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PermissionNeededViewController") as! PagedViewControllerBase;
        pageViewController.pageIndex = index;
        //pageViewController.delegate = self;
        switch(index){
            default:
                break;
        }
        return pageViewController;
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return totalPages;
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return currentIdx;
    }
}
