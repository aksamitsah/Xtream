//
//  HomeFeedCell.swift
//  xtream
//
//  Created by Amit Shah on 19/12/24.
//

import UIKit
import Lottie

class HomeFeedCell: UICollectionViewCell, ReusableView {
    
    var timer: Timer?
    var playerView: VideoPlayerView!
    
    private(set) var isPlaying = false
    
    @IBOutlet weak var commentTV: UITableView!
    @IBOutlet weak var likesAnimation: LottieAnimationView!
    @IBOutlet weak var doubleTapLikesAnimation: LottieAnimationView!
    
    @IBOutlet weak var roseStackView: UIStackView!
    @IBOutlet weak var giftStackView: UIStackView!
    @IBOutlet weak var shareStackView: UIStackView!
    @IBOutlet weak var shareCountLbl: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var likesCountLbl: UILabel!
    @IBOutlet weak var viewerCountLbl: UILabel!
    @IBOutlet weak var topicLbl: UILabel!
    
    @IBOutlet weak var followButton: CustomUIButton!
    
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var bottomSheetConst: NSLayoutConstraint!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pauseImageView: UIImageView! {
        didSet {
            pauseImageView.alpha = 0
        }
    }
    
    var error: ((HandleError) -> Void)?
    
    private var comments: [CommentModel] = []
    var backupComments: [CommentModel] = []
    
    var data: FeedModel? {
        didSet {
            guard let data else { return }
            guard let url = URL(string: data.video) else { return }
            
            userNameLbl.text = data.username
            likesCountLbl.text = "\(data.likes)"
            shareCountLbl.text = "\(data.shareCount)"
            viewerCountLbl.text = "\(data.viewers)"
            topicLbl.text = "\(data.topic)"
            
            playerView.configure(videoURL: url)
            
            ImageCacheManager.shared.loadImage(from: data.profilePicURL) { image, error in
                if let error = error {
                    Log.error("Error loading image: \(error)")
                } else if let image = image {
                    DispatchQueue.main.async { [weak self] in
                        self?.profileImage.image = image
                        self?.profileImage.layer.cornerRadius = 6
                    }
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        playerView.cancelAllLoadingRequest()
        pauseImageView.alpha = 0
        likesAnimation?.stop()
        stopAddingComments()
        comments.removeAll()
        backupComments.removeAll()
        commentTV.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commentTF.delegate = self
        setupKeyboardNotifications()
        
        playerView = VideoPlayerView(frame: .zero)
        contentView.addSubview(playerView)
        contentView.sendSubviewToBack(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            playerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        
        doubleTapGesture.numberOfTapsRequired = 2
        singleTapGesture.require(toFail: doubleTapGesture)
        
        contentView.addGestureRecognizer(doubleTapGesture)
        contentView.addGestureRecognizer(singleTapGesture)
        
        setupAnimationView()
        setupTableView()
        initilizeAction()
    }
    
    func initilizeAction() {
        
        roseStackView.addTapGesture { [weak self] in
            self?.autoLikes()
        }
        
        giftStackView.addTapGesture { [weak self] in
            self?.autoLikes()
        }
        
        shareStackView.addTapGesture { [weak self] in
            self?.error?(.custom("Not implemented"))
        }
        
        followButton.addTapGesture { [weak self] in
            let isFollowing = self?.followButton.tag
            self?.followButton.setTitle(isFollowing == 1 ? "+ Follow" : "Following", for: .normal)
            self?.followButton.tag = isFollowing == 1 ? 0 : 1
        }
    }
    
    // Lottie Animation Setup
    private func setupAnimationView() {
        
        [likesAnimation, doubleTapLikesAnimation].compactMap { $0 }.forEach { animation in
            animation.alpha = 0
            animation.stop()
            animation.loopMode = .playOnce
            animation.animationSpeed = 1.0
            animation.contentMode = .scaleAspectFit
            animation.translatesAutoresizingMaskIntoConstraints = false
        }
        
    }
    
    private func doubleTapLikes() {
        doubleTapLikesAnimation.currentFrame = 0
        doubleTapLikesAnimation.alpha = 1
        doubleTapLikesAnimation.play { [weak self] (finished) in
            if finished {
                self?.stopDoubleTapLikes()
            }
        }
    }
    
    private func stopDoubleTapLikes() {
        doubleTapLikesAnimation.alpha = 0
        doubleTapLikesAnimation.stop()
    }
    
    private func autoLikes() {
        likesAnimation.currentFrame = 0
        likesAnimation.alpha = 1
        likesAnimation.play { [weak self] (finished) in
            if finished {
                self?.stopAutoLikes()
            }
        }
    }

    private func stopAutoLikes() {
       likesAnimation.alpha = 0
       likesAnimation.stop()
    }

    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        doubleTapLikes()
    }
    
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
        if isPlaying {
            UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                guard let self = self else { return }
                self.pauseImageView.alpha = 1
                self.pauseImageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }, completion: { [weak self] _ in
                self?.pause()
            })
        } else {
            UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let self = self else { return }
                self.pauseImageView.alpha = 0
            }, completion: { [weak self] _ in
                self?.play()
                self?.pauseImageView.transform = .identity
            })
        }
    }
    
    func replay() {
        if !isPlaying {
            playerView.replay()
            play()
            autoLikes()
            startAddingComments()
        }
    }
    
    func play() {
        if !isPlaying {
            playerView.play()
            isPlaying = true
            startAddingComments()
        }
    }
    
    func pause() {
        if isPlaying {
            playerView.pause()
            isPlaying = false
            stopAddingComments()
        }
    }
}

extension HomeFeedCell: UITextFieldDelegate {
    
    // Dismiss the keyboard when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // send comment if not empty if empty than close Keyboard UI
        if let text = textField.text, !text.isEmpty {
            
            textField.text = ""
            
            let user = CONSTRAINT.UserInfo()
            comments.insert(
                CommentModel(
                    id: user.id,
                    username: user.username,
                    picURL: user.picURL,
                    comment: text
                ), at: 0)
            commentTV.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            
            return false
            
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // Listen for keyboard show and hide notifications
    func setupKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
    }

    @objc func keyboardWillShow(notification: Notification) {
        
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            bottomSheetConst.constant = keyboardFrame.height
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        bottomSheetConst.constant = 20
        
    }
    
}

extension HomeFeedCell: UITableViewDataSource, UITableViewDelegate {
    
    func startAddingComments() {
        
        timer?.invalidate()
        timer = nil
        
        timer = Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(addComment),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func addComment() {
        
        if backupComments.isEmpty {
            stopAddingComments()
        } else {
            let comment = backupComments.removeFirst()
            comments.insert(comment, at: 0)
            commentTV.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            
            // Scroll the newly added comment into view with animation
            // commentTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
    }

    func stopAddingComments() {
        
        timer?.invalidate()
        timer = nil
        
    }
    
    func setupTableView() {
        
        commentTV.registerFromXib(name: CommentCell.reuseIdentifier)
        commentTV.dataSource = self
        commentTV.delegate = self
        commentTV.separatorStyle = .none
        commentTV.isUserInteractionEnabled = true
        commentTV.transform = CGAffineTransform(scaleX: 1, y: -1)
        commentTV.showsVerticalScrollIndicator = false
        commentTV.showsHorizontalScrollIndicator = false
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CommentCell.reuseIdentifier,
            for: indexPath
        ) as? CommentCell else {
            return UITableViewCell()
        }
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.data = comments[indexPath.row]
        return cell
        
    }
    
    // Scroll down or up top last element 40% opacity
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let visibleCells = commentTV.visibleCells as? [CommentCell] else { return }

        visibleCells.forEach { $0.alpha = 1.0 }
        guard let visibleRows = commentTV.indexPathsForVisibleRows else { return }
        let sortedVisibleRows = visibleRows.sorted(by: { $0.row > $1.row })
        
        if let lastVisibleRow = sortedVisibleRows.first {
            if let lastVisibleCell = commentTV.cellForRow(at: lastVisibleRow) {
                lastVisibleCell.alpha = 0.4
            }
        }
    }
    
}
