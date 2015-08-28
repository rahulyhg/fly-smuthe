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
        
        pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PagedViewControllerContainer")! as! UIPageViewController;
        pageViewController.dataSource = self;
        let firstPage = self.viewControllerAtIndex(0);
        let pageArr = [firstPage];
        pageViewController.setViewControllers(pageArr, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil);
        pageViewController.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height - 30);
        self.addChildViewController(pageViewController);
        self.view.addSubview(pageViewController.view);
        pageViewController.didMoveToParentViewController(self);
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
        var pageViewController: PagedViewControllerBase!;
        //pageViewController.delegate = self;
        switch(index){
        case findSmoothAirIdx:
            pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FindSmoothAirViewController") as! PagedViewControllerBase;
            break;
        case reportAirConditionIdx:
            pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ReportConditionsViewController") as! PagedViewControllerBase;
            break;
            default:
                pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("FindSmoothAirViewController") as! PagedViewControllerBase;
                break;
        }
        pageViewController.pageIndex = index;
        return pageViewController;
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return totalPages;
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return currentIdx;
    }
}
