//
//  ShareViewController.swift
//  Viision
//
//  Created by Sevak Soghoyan on 1/18/21.
//  Copyright © 2021 Sevak Soghoyan. All rights reserved.
//

import UIKit

// MARK: - Properties and init methods
class ShareViewController: UIViewController {
    private var selectedImage: UIImage!
    private var results: [DetectResult]!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var resultsTableView: IntrinsicTableView!
    @IBOutlet weak var shareResultsImageView: UIImageView!
    @IBOutlet weak var resultsPolygonView: UIView!
    @IBOutlet weak var tableViewHeightConstant: NSLayoutConstraint!
        
    convenience init(selectedImage: UIImage, results: [DetectResult]) {
        self.init()
        self.selectedImage = selectedImage
        self.results = results
    }
}

// MARK: - View lifecycle
extension ShareViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController as? MainNavigationController {
            navigationController.changeNavColorToWhite()
            if #available(iOS 13.0, *) {
                navigationController.appPreferedStatusBarStyle = .darkContent
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = navigationController as? MainNavigationController {
            navigationController.changeNavColorToOpacity()
            navigationController.appPreferedStatusBarStyle = .lightContent
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableViewHeightConstant.constant = resultsTableView.intrinsicContentSize.height
    }
}

// MARK: - Private methods
extension ShareViewController {
    private func updateUI() {
        shareResultsImageView.image = selectedImage
        title = UIConstants.shareVCTitle
        shadowView.dropShadow(color: .black, radius: 7, opacity: 0.2)
        resultsTableView.register(UINib(nibName: String(describing: ShareTableViewCell.self), bundle: nil),
                                  forCellReuseIdentifier: String(describing: ShareTableViewCell.self))
        configureAspectRatioConstraint()
        configurePointsViews()
        configureRightBarButtonItem()
    }
    
    private func configureAspectRatioConstraint() {
        shareResultsImageView.addConstraint(NSLayoutConstraint(item: shareResultsImageView!,
                                                   attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: shareResultsImageView,
                                                   attribute: NSLayoutConstraint.Attribute.width,
                                                   multiplier: selectedImage.size.height / selectedImage.size.width,
                                                   constant: 0))
    }
    
    private func configurePointsViews() {
        let shareImageViewWidth = UIScreen.main.bounds.width - 40.0
        let shareImageViewHeight = shareImageViewWidth * selectedImage.size.height / selectedImage.size.width
        let withDiff = shareImageViewWidth / selectedImage.size.width
        let heightDiff = shareImageViewHeight / selectedImage.size.height
        for detectMoney in results {
            for polygon in detectMoney.detectedMoney.polygon {
                let points = polygon.compactMap({
                    CGPoint(x: (CGFloat($0.x) * withDiff), y: (CGFloat($0.y) * heightDiff))
                })
                addPolygonView(points: points, color: Constants.colors[detectMoney.colorIndex])
            }
        }
    }
    
    private func addPolygonView(points: [CGPoint], color: UIColor) {
        let polygonView = PolygonView(frame: resultsPolygonView.bounds)
        resultsPolygonView.addSubview(polygonView)
        polygonView.autopinToSuperviewEdges()
        polygonView.addRectangleFromPoints(points: points, fillColor: color, strokeColor: color)
        polygonView.shapeLayer.fillColor = UIColor.clear.cgColor
    }
    
    private func configureRightBarButtonItem() {
        let shareButton =  UIButton(type: .custom)
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.black, for: .normal)
        shareButton.addTarget(self, action: #selector(self.shareButtonAction), for: .touchUpInside)
        shareButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 21.0).isActive = true
        let shareBarButton = UIBarButtonItem(customView: shareButton)
        
        navigationItem.rightBarButtonItem = shareBarButton
    }
    
    @objc func shareButtonAction() {
        guard let image = UIImage.imageWithView(shareView
        ) else {
            return
        }
        shareImageAndText(image: image, text: Messages.shareText)
    }
}

// MARK: - UITableView DataSource methods
extension ShareViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = String(describing: ShareTableViewCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? ShareTableViewCell else {
                                                        return UITableViewCell()
        }
        let detectResult = results[indexPath.row]
        cell.update(withDetectResult: detectResult)
        return cell
    }        
}
