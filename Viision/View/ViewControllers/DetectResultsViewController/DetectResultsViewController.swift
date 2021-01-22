//
//  DetectResultsViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import MoneyDetector

// MARK: - Properties
class DetectResultsViewController: UIViewController {
    private var selectedImage: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsTableView: IntrinsicTableView!
    @IBOutlet weak var polygonViewsContainerView: UIView!
    @IBOutlet weak var tableViewContainerView: UIView!
    @IBOutlet weak var tableViewHeigtConstant: NSLayoutConstraint!
    @IBOutlet weak var tableContainerHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var safeAreaBlurView: UIView!
    private var hidePan: UIPanGestureRecognizer!
    private var isTableViewShown = false    

    var results: [DetectResult] = []
    var buttons: [String: UIButton] = [:]
    var polygonViews: [DetectResult: [PolygonView]] = [:]
}

// MARK: - View Lifecycle
extension DetectResultsViewController {
    convenience init(withImage image: UIImage) {
        self.init()
        self.selectedImage = image
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.register(UINib(nibName: String(describing: DetectResultTableViewCell.self), bundle: nil),
                                  forCellReuseIdentifier: String(describing: DetectResultTableViewCell.self))
        navigationController?.navigationBar.isHidden = false
        updateUI()
        detectMoneyInImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if results.count > 0 {
            configureSettings()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if tableViewHeigtConstant.constant != getTableContainerMaxHeight() {
            tableViewHeigtConstant.constant = getTableContainerMaxHeight()
        }
    }
}

// MARK: - IBActions
extension DetectResultsViewController {
    @objc func shareButtonAction() {
        let shareVC = ShareViewController(selectedImage: selectedImage, results: results)
        navigationController?.pushViewController(shareVC, animated: true)                
    }
    
    @objc func gearButtonAction() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }

    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began ||
            gestureRecognizer.state == UIGestureRecognizer.State.changed {
            let translation = gestureRecognizer.translation(in: self.view)
            let newHeight = tableContainerHeightConstant.constant - translation.y
            if newHeight <= getTableContainerMaxHeight() + UIConstants.defaultSwipeViewHeight &&
                newHeight >= UIConstants.defaultSwipeViewHeight {
                tableContainerHeightConstant.constant -= translation.y
                view.layoutIfNeeded()
            }
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        }
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            animateTableContainerView()
        }
    }
    
    @objc func buttonClicked(sender: UIButton) {
        animateTableView(newHeight: getTableContainerMinHeight())
        guard !sender.isSelected else {            
            return
        }
        buttons.values.forEach {
            $0.isSelected = false
        }
        sender.isSelected = true
        if let key = buttons.key(for: sender) {
            animateResult(detectMoneyId: key)
        }
    }
}

// MARK: - Private methods realted to UI
extension DetectResultsViewController {
    private func updateUI() {
        imageView.image = selectedImage
        configureAspectRatioConstraint()
        hidePan = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        swipeView.addGestureRecognizer(hidePan)
        configureBlurView()
    }

    private func configureBlurView() {
//        blurView.addBlurEffect(style: .light)
//        safeAreaBlurView.addBlurEffect(style: .light)
        blurView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurView.layer.cornerRadius = 35.0
    }

    private func updateUIOnNewResults() {
        resultsTableView.reloadData()
        tableViewContainerView.isHidden = results.count == 0
        safeAreaBlurView.isHidden = results.count == 0
        swipeView.isHidden = results.count < 2
        if results.count > 0 {
            configurePointsViews()
            view.layoutIfNeeded()
            animateTableView(newHeight: getTableContainerMaxHeight() + UIConstants.defaultSwipeViewHeight)
        } else {
            let errorVC = ErrorResultViewController()
            errorVC.modalPresentationStyle = .overFullScreen
            errorVC.modalTransitionStyle = .crossDissolve
            errorVC.onAction = {
                self.navigationController?.popToRootViewController(animated: true)
            }
            navigationController?.present(errorVC, animated: true)
        }
    }

    private func configureRightBarButtonItem() {
        let shareButton =  UIButton(type: .custom)
        shareButton.setBackgroundImage(UIImage(named: UIConstants.shareIconName), for: .normal)
        shareButton.addTarget(self, action: #selector(self.shareButtonAction), for: .touchUpInside)
        shareButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 21.0).isActive = true
        let shareBarButton = UIBarButtonItem(customView: shareButton)
        
        let gearButton =  UIButton(type: .custom)
        gearButton.setBackgroundImage(UIImage(named: UIConstants.gearIconName), for: .normal)
        gearButton.addTarget(self, action: #selector(self.gearButtonAction), for: .touchUpInside)
        gearButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        gearButton.heightAnchor.constraint(equalToConstant: 21.0).isActive = true
        let gearBarButton = UIBarButtonItem(customView: gearButton)
        
        navigationItem.rightBarButtonItems = [shareBarButton, gearBarButton]
    }

    private func configureAspectRatioConstraint() {        
        imageView.addConstraint(NSLayoutConstraint(item: imageView!,
                                                   attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: imageView,
                                                   attribute: NSLayoutConstraint.Attribute.width,
                                                   multiplier: selectedImage.size.height / selectedImage.size.width,
                                                   constant: 0))
    }
    
    private func animateResult(detectMoneyId: String) {
        for result in results where result.detectedMoney.id == detectMoneyId {
            sendCellToFront(detectResult: result)
            return
        }
    }
}

// MARK: - Private methods realted to UITableView
extension DetectResultsViewController {
    private func animateTableContainerView() {
        var newConstant: CGFloat = 0
        let minHeight = getTableContainerMinHeight()
        if isTableViewShown {
            let tableHeight = getTableContainerMaxHeight() - UIConstants.defaultSwipeViewHeight
            if tableContainerHeightConstant.constant < tableHeight {
                newConstant = minHeight
            } else {
                newConstant = getTableContainerMaxHeight() + UIConstants.defaultSwipeViewHeight
            }
        } else {
            if tableContainerHeightConstant.constant < minHeight + 20.0 {
                newConstant = minHeight
            } else {
                newConstant = getTableContainerMaxHeight() + UIConstants.defaultSwipeViewHeight
            }
        }
        animateTableView(newHeight: newConstant)
    }

    private func animateTableView(newHeight: CGFloat) {
        guard newHeight != tableContainerHeightConstant.constant else {
            return
        }
        isTableViewShown = newHeight != getTableContainerMinHeight()
        tableContainerHeightConstant.constant = newHeight
        if !isTableViewShown {
            resultsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (_) in
            self.resultsTableView.isScrollEnabled = self.isTableViewShown
        })
    }

    private func getTableContainerMaxHeight() -> CGFloat {
        let height = resultsTableView.intrinsicContentSize.height > UIConstants.defaultOpenedTableViewHeight ?
            UIConstants.defaultOpenedTableViewHeight : resultsTableView.intrinsicContentSize.height
        return height
    }

    private func getTableContainerMinHeight() -> CGFloat {
        let cellRect = resultsTableView.rectForRow(at: IndexPath(row: 0, section: 0))
        let height = UIConstants.defaultSwipeViewHeight + cellRect.height
        return height
    }
    
    private func sendCellToFront(detectResult: DetectResult) {
        guard let index = results.firstIndex(where: {
            $0.detectedMoney.id == detectResult.detectedMoney.id
        }), index != 0 else {
            return
        }
        resultsTableView.beginUpdates()
        UIView.transition(with: resultsTableView,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.resultsTableView.moveRow(at: IndexPath(row: index, section: 0),
                                                                      to: IndexPath(row: 0, section: 0)) })
        resultsTableView.endUpdates()
        results.remove(at: index)
        results.insert(detectResult, at: 0)
    }
    
    private func configureSettings() {
        let isFeelEnabled = UserDefaults.standard.bool(forKey: Constants.fillKey)
        let isOutlineEnabled = UserDefaults.standard.bool(forKey: Constants.outlineKey)
        polygonViews.keys.forEach {
            let feelColor = Constants.colors[$0.colorIndex]
            polygonViews[$0]!.forEach {
                $0.shapeLayer.fillColor = isFeelEnabled ? feelColor.withAlphaComponent(0.7).cgColor : UIColor.clear.cgColor
                $0.shapeLayer.strokeColor = isOutlineEnabled ? feelColor.cgColor : UIColor.clear.cgColor
            }
        }
    }
}

// MARK: - Private methods realted to Polygons
extension DetectResultsViewController {
    private func configurePointsViews() {
        guard results.count > 0 else {
            return
        }
        configureRightBarButtonItem()
        let withDiff = imageView.frame.size.width / selectedImage.size.width
        let heightDiff = imageView.frame.size.height / selectedImage.size.height
        for detectMoney in results {
            if let center = detectMoney.detectedMoney.getBoundingBoxCenter() {
                let buttonSize = detectMoney.detectedMoney.getButtonSize(multiplier: withDiff)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
                button.setImage(UIImage(named: "\(UIConstants.inactiveIconPlaceholder)\(detectMoney.colorIndex)"), for: .normal)
                button.setImage(UIImage(named: "\(UIConstants.activeIconPlaceholder)\(detectMoney.colorIndex)"), for: .selected)
                polygonViewsContainerView.addSubview(button)
                button.center = CGPoint(x: center.x * withDiff, y: center.y * heightDiff)
                buttons[detectMoney.detectedMoney.id] = button
                button.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
                for polygon in detectMoney.detectedMoney.polygon {
                    let points = polygon.compactMap({
                        CGPoint(x: (CGFloat($0.x) * withDiff), y: (CGFloat($0.y) * heightDiff))
                    })
                    if polygonViews[detectMoney] == nil {
                        polygonViews[detectMoney] = [addPolygonView(points: points, color: Constants.colors[detectMoney.colorIndex])]
                    } else {
                        polygonViews[detectMoney]?.append(addPolygonView(points: points, color: Constants.colors[detectMoney.colorIndex]))
                    }
                }
            }
        }
        buttons.values.forEach {
            polygonViewsContainerView.bringSubviewToFront($0)
        }
        configureSettings()
    }
    
    private func addPolygonView(points: [CGPoint], color: UIColor) -> PolygonView {
        let polygonView = PolygonView(frame: polygonViewsContainerView.bounds)
        polygonViewsContainerView.addSubview(polygonView)
        polygonView.autopinToSuperviewEdges()
        polygonView.addRectangleFromPoints(points: points, fillColor: color, strokeColor: color)
        return polygonView
    }
}

// MARK: - Private methods realted to Models
extension DetectResultsViewController {
    private func detectMoneyInImage() {
        guard let imageData = selectedImage.pngData() else {
            return
        }
        UIApplication.showLoader()
        MoneyDetector.detectMoney(withImageData: imageData) { [weak self] (result)  in
            guard let self = self else {
                return
            }
            UIApplication.hideLoader()
            switch result {
            case .success(let response):
                if let result = response.results {
                    self.configureDetectResults(results: result)
                }
            case .failure(let errorResponse):
                print(errorResponse.localizedDescription)
                self.showErrorController(withTitle: Messages.somethingWrong,
                                         message: UtilityMethods.getMessage(error: errorResponse))
            }
        }
    }

    private func configureDetectResults(results: [MDDetectedMoney]) {
        var colorIndex = -1
        self.results = results.compactMap {
            colorIndex += 1
            if colorIndex == Constants.colors.count {
                colorIndex = 0
            }
            return DetectResult(detectedMoney: $0, colorIndex: colorIndex)
        }
        DispatchQueue.main.async {
            self.updateUIOnNewResults()
        }
    }

    private func sendFeedback(detectedMoney: MDDetectedMoney,
                              isCorrect: Bool, completion:(() -> Void)?) {
        UIApplication.showLoader()
        MoneyDetector.sendFeedback(withImageID: detectedMoney.id, isCorrect: isCorrect) {[weak self] (result) in
            guard let self = self else {
                return
            }
            UIApplication.hideLoader()
            switch result {
            case .success:                
                DispatchQueue.main.async {
                    completion?()
                }
            case .failure(let errorResponse):
                print(errorResponse.localizedDescription)
                self.showErrorController(withTitle: Messages.somethingWrong,
                                         message: UtilityMethods.getMessage(error: errorResponse))
            }
        }
    }
}

// MARK: - LeaveFeedbackViewController Delegate methods
extension DetectResultsViewController: LeaveFeedbackViewControllerDelegate {
    func feedbackDidCancel(leaveFeedbackViewController: LeaveFeedbackViewController, detectResult: DetectResult) {
        leaveFeedbackViewController.dismiss(animated: true)
    }

    func feedbackLeftSuccesfully(leaveFeedbackViewController: LeaveFeedbackViewController, detectResult: DetectResult) {
        detectResult.isFeedbackProvided = true
        guard let index = results.firstIndex(where: {
            $0.detectedMoney.id == detectResult.detectedMoney.id
        }) else {
            return
        }
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = resultsTableView.cellForRow(at: indexPath) as? DetectResultTableViewCell else {
            return
        }
        if resultsTableView.visibleCells.contains(cell) {
            cell.update(withDetectResult: detectResult)            
        }
    }
}

// MARK: - UITableView DataSource methods
extension DetectResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = String(describing: DetectResultTableViewCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? DetectResultTableViewCell else {
                                                        return UITableViewCell()
        }
        let detectResult = results[indexPath.row]
        cell.update(withDetectResult: detectResult)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detectResult = results[indexPath.row]
        if let button = buttons[detectResult.detectedMoney.id] {
            buttonClicked(sender: button)
        }
    }
}

// MARK: - DetectResultTableViewCell Delegate methods
extension DetectResultsViewController: DetectResultTableViewCellDelegate {
    func didTapCancelFeedbackButton(cell: DetectResultTableViewCell, detectResult: DetectResult) {
    }

    func didTapCorrectButton(cell: DetectResultTableViewCell, detectResult: DetectResult) {
        sendFeedback(detectedMoney: detectResult.detectedMoney, isCorrect: true) {
            detectResult.isCorrect = true
            if self.resultsTableView.visibleCells.contains(cell) {
                cell.animateViews(detectResult: detectResult)
            }
        }
    }

    func didTapIncorrectButton(cell: DetectResultTableViewCell, detectResult: DetectResult) {
        sendFeedback(detectedMoney: detectResult.detectedMoney, isCorrect: false) {
            detectResult.isCorrect = false
            if self.resultsTableView.visibleCells.contains(cell) {
                cell.animateViews(detectResult: detectResult)
            }
        }
    }

    func didTapLeaveFeedbackButton(cell: DetectResultTableViewCell, detectResult: DetectResult) {
        let leaveFeedbackVC = LeaveFeedbackViewController(withDetectResult: detectResult)
        leaveFeedbackVC.modalPresentationStyle = .overCurrentContext
        leaveFeedbackVC.modalTransitionStyle = .crossDissolve
        leaveFeedbackVC.delegate = self
        navigationController?.present(leaveFeedbackVC, animated: true)
    }

}

// MARK: - Table View Class for configuring self size
class IntrinsicTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

}

extension MDDetectedMoney {
    func getBoundingBoxCenter() -> CGPoint? {
        guard boundingBox.count > 1 else {
            return nil
        }
        return CGPoint(x: (boundingBox[0].x + boundingBox[1].x) / 2, y: (boundingBox[0].y + boundingBox[1].y) / 2)
    }
    
    func getButtonSize(multiplier: CGFloat) -> CGFloat {
        let fixedSize: CGFloat = 25
        guard boundingBox.count > 1 else {
            return fixedSize
        }
        let width = boundingBox[1].x - boundingBox[0].x
        let height = boundingBox[1].y - boundingBox[0].y
        let newSize = multiplier * 0.7 * (width > height ? CGFloat(height) : CGFloat(width))
        return newSize < fixedSize ? newSize : fixedSize
    }
}

extension Dictionary where Key == String, Value: Equatable {
    func key(for value: Value) -> Key? {
        return compactMap { value == $1 ? $0 : nil }.first
    }
}
