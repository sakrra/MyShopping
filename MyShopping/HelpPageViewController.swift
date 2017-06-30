//
//  HelpPageViewController.swift
//  MyShopping
//
//  Created by Sami Rämö on 28/06/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import UIKit

class HelpPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    let imageNames = ["help-screen1", "help-screen2", "help-screen3", "help-screen4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        if let firstVC = viewController(atIndex: 0) {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
    private func viewController(atIndex index: Int) -> HelpViewController? {
        if imageNames.count == 0 || index >= imageNames.count {
            return nil
        }
        
        guard let helpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "helpScreen") as? HelpViewController else {
            return nil
        }
        
        helpVC.imageName = imageNames[index]
        helpVC.pageIndex = index
        return helpVC
    }
    
    // MARK: - UIPageViewController Delegate and Data Source
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return imageNames.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let helpViewController = viewController as? HelpViewController {
            let index = helpViewController.pageIndex
            let previousIndex = index - 1
            guard previousIndex >= 0 else {
                return self.viewController(atIndex: imageNames.count-1)
            }
            guard imageNames.count > previousIndex else {
                return nil
            }
            return self.viewController(atIndex: previousIndex)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let helpViewController = viewController as? HelpViewController {
            let index = helpViewController.pageIndex
            let nextIndex = index + 1
            guard nextIndex < imageNames.count else {
                return self.viewController(atIndex: 0)
            }
            guard imageNames.count >= nextIndex else {
                return nil
            }
            return self.viewController(atIndex: nextIndex)
        }
        return nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
