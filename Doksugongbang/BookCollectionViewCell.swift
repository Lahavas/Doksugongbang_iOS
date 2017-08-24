//
//  BookCollectionViewCell.swift
//  Doksugongbang
//
//  Created by Yeon on 2017. 8. 16..
//  Copyright © 2017년 yeon. All rights reserved.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpBookImage()
        update(with: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setUpBookImage()
        update(with: nil)
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
