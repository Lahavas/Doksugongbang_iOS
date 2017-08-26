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
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var dateUpdatedLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bookRating: RatingControl!
    @IBOutlet var bookReportLabel: UILabel!

    // MARK: Models
    
    var book: Book!
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
