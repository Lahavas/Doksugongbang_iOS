//
//  BookLogListTableViewCell.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 21..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit

class BookLogListTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet var startPageLabel: UILabel!
    @IBOutlet var endPageLabel: UILabel!
    
    @IBOutlet var bookTitleLabel: UILabel!
    @IBOutlet var bookReadCountLabel: UILabel!
    @IBOutlet var bookLogLabel: UILabel!
    
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
