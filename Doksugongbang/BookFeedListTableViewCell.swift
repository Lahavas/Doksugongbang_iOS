//
//  BookFeedListTableViewCell.swift
//  Doksugongbang
//
//  Created by Jaeho on 2017. 8. 26..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit

class BookFeedListTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    // MARK: Outlets
    
    // User Config and Date
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var dateUpdatedLabel: UILabel!
    
    // Main View
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var publisherLabel: UILabel!
    @IBOutlet var pubdateLabel: UILabel!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var bookButton: UIButton!
    
    // Book Report
    @IBOutlet var bookRating: RatingControl!
    @IBOutlet var bookReportLabel: UILabel!

    // MARK: Models
    
    var book: Book!
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setUpBookImage()
        self.update(with: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.setUpBookImage()
        self.update(with: nil)
    }

    // MARK: - Methods
    
    func update(with image: UIImage?) {
        
        if let imageToDisplay = image {
            self.spinner.stopAnimating()
            self.coverImageView.image = imageToDisplay
        } else {
            self.spinner.startAnimating()
            self.coverImageView.image = nil
        }
    }
    
    func setUpBookImage() {
        
        self.coverImageView.layer.shadowColor = UIColor.gray.cgColor
        self.coverImageView.layer.shadowOffset = CGSize(width: 3, height: 5)
        self.coverImageView.layer.shadowOpacity = 1
        self.coverImageView.layer.shadowRadius = 1.0
    }
}
