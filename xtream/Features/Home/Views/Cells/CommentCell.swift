//
//  CommentCell.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    
    
    var data: CommentModel? {
        didSet {
            guard let data else { return }
            nameLbl.text = data.username
            msgLbl.text = data.comment
            ImageCacheManager.shared.loadImage(from: data.picURL) { image, error in
                if let error = error {
                    Log.error("Error loading image: \(error)")
                } else if let image = image {
                    DispatchQueue.main.async { [weak self] in
                        self?.imageview.image = image
                        self?.imageview.layer.cornerRadius = 28 / 2
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let data else { return }
        ImageCacheManager.shared.cancelLoad(for: data.picURL)
        imageview.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
