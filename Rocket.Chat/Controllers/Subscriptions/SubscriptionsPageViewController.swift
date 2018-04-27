//
//  SubscriptionsPageViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class SubscriptionsPageViewController: UIPageViewController {

    var serversController: ServersViewController?
    var subscriptionsController: SubscriptionsViewController?

    weak var pageControl: UIPageControl?

    static var shared: SubscriptionsPageViewController? {
        if let main = UIApplication.shared.delegate?.window??.rootViewController as? MainChatViewController {
            if let nav = main.sideViewController as? UINavigationController {
                return nav.viewControllers.first as? SubscriptionsPageViewController
            }
        }

        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
        
        //FIX-ME Changed
        view.backgroundColor = .white

        // Setup page control
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.currentPage = 1
        pageControl.isHidden = !AppManager.supportsMultiServer
        view.addSubview(pageControl)

        pageControl.addTarget(self, action: #selector(SubscriptionsPageViewController.dotTapped(pageControl:)), for: .touchUpInside)

        self.pageControl = pageControl

        // Setup ViewControllers
        let storyboard = UIStoryboard(name: "SubscriptionsMain", bundle: Bundle.main)

        guard
            let subscriptionsController = storyboard.instantiateViewController(withIdentifier: "SubscriptionsViewController") as? SubscriptionsViewController,
            let serversController = storyboard.instantiateViewController(withIdentifier: "ServersViewController") as? ServersViewController
        else {
            return assert(false, "controllers won't load")
        }

        self.subscriptionsController = subscriptionsController
        self.serversController = serversController

        setViewControllers([subscriptionsController], direction: .reverse, animated: false, completion: nil)
    }
    
    //FIX-ME Changed code
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let pageControlHeight = CGFloat(44)
        var safeAreaBottomConstraint = CGFloat(0)

        if #available(iOS 11.0, *) {
            safeAreaBottomConstraint = view.safeAreaInsets.bottom
        }

        pageControl?.frame = CGRect(
            x: 0,
            y: view.frame.height - pageControlHeight - safeAreaBottomConstraint,
            width: view.frame.width,
            height: pageControlHeight
        )
    }

    // MARK: Change controllers externally

    func showServersList(animated: Bool = true) {
        guard AppManager.supportsMultiServer else { return }
        guard let serversController = self.serversController else { return }
        setViewControllers([serversController], direction: .reverse, animated: animated, completion: nil)
        pageControl?.currentPage = 0
    }

    func showSubscriptionsList(animated: Bool = true) {
        guard let subscriptionsController = self.subscriptionsController else { return }
        setViewControllers([subscriptionsController], direction: .forward, animated: animated, completion: nil)
        pageControl?.currentPage = 1
    }

    @objc private func dotTapped(pageControl: UIPageControl) {
        if pageControl.currentPage == 0 {
            showServersList()
        } else if pageControl.currentPage == 1 {
            showSubscriptionsList()
        }
    }

}

extension SubscriptionsPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if previousViewControllers.first == serversController {
                pageControl?.currentPage = 1
            } else {
                pageControl?.currentPage = 0
            }
        }
    }

}

extension SubscriptionsPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard AppManager.supportsMultiServer else { return nil }

        if viewController == subscriptionsController {
            return serversController
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard AppManager.supportsMultiServer else { return nil }

        if viewController == serversController {
            return subscriptionsController
        }

        return nil
    }

}
