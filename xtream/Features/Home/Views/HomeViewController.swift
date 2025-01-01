//
//  HomeViewController.swift
//  xtream
//
//  Created by Amit Shah on 19/12/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    
    @objc dynamic var currentIndex = 0
    private var oldAndNewIndices = (0, 0)
    private var isFirstTimeLoad: Bool = true
    
    private var mainCv: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindViewModel()
        AppHelper.shared.showProgressIndicator(view: self.view)
        viewModel.getData()
    }
    
    private func bindViewModel() {
        // Observe feed updates
        viewModel.onFeedsUpdated = { [weak self] in
            DispatchQueue.main.async {
                AppHelper.shared.hideProgressIndicator(view: self?.view)
                self?.mainCv.reloadData()
            }
        }
        
        // Observe comment updates
        viewModel.onCommentsUpdated = {
            Log.info("Comments updated successfully")
        }
        
        // Observe errors
        viewModel.onErrorOccurred = { [weak self] error in
            DispatchQueue.main.async {
                AppHelper.shared.hideProgressIndicator(view: self?.view)
                AppHelper.shared.showAlert(
                    title: "Error",
                    message: error,
                    viewController: self
                )
            }
        }
    }
    
}

// Setup Functions
extension HomeViewController {
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        
        mainCv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        mainCv.translatesAutoresizingMaskIntoConstraints = false
        mainCv.backgroundColor = .black
        mainCv.isPagingEnabled = true // Enables paging behavior
        mainCv.showsVerticalScrollIndicator = false
        mainCv.contentInsetAdjustmentBehavior = .never
        
        mainCv.dataSource = self
        mainCv.delegate = self
        mainCv.registerFromXib(name: HomeFeedCell.reuseIdentifier)
        
        view.addSubview(mainCv)
        
        // Setup Auto Layout for full screen
        NSLayoutConstraint.activate([
            mainCv.topAnchor.constraint(equalTo: view.topAnchor),
            mainCv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainCv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCv.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.feeds.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: HomeFeedCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.data = viewModel.feeds[indexPath.row]
        cell.backupComments = viewModel.comments
        cell.error = { (error) in
            Log.error(error)
            DispatchQueue.main.async {
                AppHelper.shared.showAlert(
                    title: "Something went wrong",
                    message: error.localizedDescription,
                    viewController: self
                )
            }
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let cell = cell as? HomeFeedCell {
            oldAndNewIndices.1 = indexPath.row
            currentIndex = indexPath.row
            cell.pause()
            
            if isFirstTimeLoad {
                isFirstTimeLoad = false
                cell.replay()
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let cell = cell as? HomeFeedCell {
            cell.pause()
        }
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cell = self.mainCv.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) as? HomeFeedCell
        cell?.replay()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}
