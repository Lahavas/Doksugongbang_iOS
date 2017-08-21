//
//  ReportBeforeReadViewController.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 20..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit
import RealmSwift

class ReportBeforeReadViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var reportTextView: UITextView!
    
    let realm = try! Realm()
    
    var book: Book!
    
    let animator: Animator = Animator()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func readingAction(_ sender: UIButton) {
        
        try! realm.write {
            self.book.bookStateEnum = .reading
            self.book.dateUpdatedBookState = Date()
            self.book.bookReadCount += 1
            
            let bookInfo = BookInfo()
            bookInfo.bookReadCount = self.book.bookReadCount
            bookInfo.bookTotalPage = self.book.page
            bookInfo.reportBeforeReading = self.reportTextView.text
            
            bookInfo.parentBook = self.book
            self.book.bookInfos.append(bookInfo)
            
            realm.add(self.book, update: true)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: -

extension ReportBeforeReadViewController: UIViewControllerTransitioningDelegate {
    
    // MARK: - View Controller Transitioning Delegate
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.animator.transitionType = .pushFromBottom
        self.animator.insets = UIEdgeInsets(top: 100, left: 30, bottom: 100, right: 30)
        self.animator.duration = 0.3
        return self.animator
    }
    
    func animationController(forDismissed dismissed: UIViewController)-> UIViewControllerAnimatedTransitioning? {
        
        return self.animator
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        
        let presentationController = NNBackDropController(presentedViewController: presented,
                                                          presentingViewController: source,
                                                          dismissPresentedControllerOnTap : true)
        return presentationController
    }
}
