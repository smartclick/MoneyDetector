//
//  DetectResultsViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import MoneyDetector

//MARK:- Properties
class DetectResultsViewController: BaseViewController {
    @IBOutlet weak var aspectRatioConstraint: NSLayoutConstraint!
    private var selectedImage: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsStackView: UIStackView!
    @IBOutlet weak var polygonViewsContainerView: UIView!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var tryAnotherPictureButton: UIButton!
    @IBOutlet weak var noResultLabel: UILabel!
    
    private typealias ResultAndPolygonViews = (ResultView, [PolygonView])
    private var polygonResultViewsDict: [String: ResultAndPolygonViews] = [:]
    
    var results: [MDDetectedMoney] = [] {
        didSet {
            DispatchQueue.main.async {
                self.configurePointsViews()
            }
        }
    }    
}

//MARK:- View Lifecycle
extension DetectResultsViewController {
    convenience init(withImage image: UIImage) {
        self.init()
        self.selectedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        navigationController?.navigationBar.isHidden = false
        detectMoneyInImage()
    }
    
}

//MARK:- IBActions
extension DetectResultsViewController {
    @IBAction func tryAgainButtonAction(_ sender: Any) {
        detectMoneyInImage()
    }
    
    @IBAction func tryAnotherPictureButtonAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}

//MARK:- Private methods
extension DetectResultsViewController {
    private func detectMoneyInImage() {
        guard let imageData = selectedImage.pngData() else {
            return
        }
        activityIndicatorView.startAnimating()
        updateTryButtons()
        MoneyDetector.detectMoney(withImageData: imageData) { [weak self] (result)  in
            guard let self = self else {
                return
            }
            var isSuccess = false
            switch result{
            case .success(let response):
                isSuccess = true
                if let result = response.results {
                    self.results = result
                }
            case .failure(let errorResponse):
                print(errorResponse.localizedDescription)
                self.showAlert(withMessage: UtilityMethods.getMessage(error: errorResponse))
            }
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.updateTryButtons(isSuccess: isSuccess)
            }
        }
    }
    
    private func updateUI() {
        imageView.image = selectedImage
        configureAspectRatioConstraint()        
    }        
    
    private func updateTryButtons(isSuccess: Bool? = nil) {
        tryAgainButton.isHidden = isSuccess ?? true
        tryAnotherPictureButton.isHidden = !(isSuccess ?? false)
        noResultLabel.isHidden = tryAnotherPictureButton.isHidden || results.count != 0
    }
    
    
    func configureRightBarButtonItem() {
        let button =  UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "share_icon"), for:.normal)
        button.addTarget(self, action: #selector(self.shareButtonAction), for: .touchUpInside)
        button.frame = CGRect(x:0, y:0, width:25, height:25)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func shareButtonAction() {
        guard let image = UIImage.imageWithView(polygonViewsContainerView) else {
            return
        }
        shareImageAndText(image: image, text: "Money detected from ai")
    }
    
    private func configureAspectRatioConstraint() {
        aspectRatioConstraint.isActive = false
        imageView.addConstraint(NSLayoutConstraint(item: imageView!,
                                                   attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: imageView,
                                                   attribute: NSLayoutConstraint.Attribute.width,
                                                   multiplier: selectedImage.size.height / selectedImage.size.width,
                                                   constant: 0))
        view.layoutIfNeeded()
    }
    
    private func configureResultView(detectMoney: MDDetectedMoney,withColor color: UIColor) -> ResultView {
        let resultView = ResultView(frame: CGRect.zero, detectedMoney: detectMoney, polygonColor: color)
        resultsStackView.addArrangedSubview(resultView)
        resultView.delegate = self
        return resultView
    }
    
    private func configurePointsViews() {
        resetValues()
        guard results.count > 0 else {
            return
        }
        configureRightBarButtonItem()
        let withDiff = imageView.frame.size.width / selectedImage.size.width
        let heightDiff = imageView.frame.size.height / selectedImage.size.height        
        var colorIndex = 0        
        for detectMoney in results {
            var polygonViews: [PolygonView] = []
            for polygon in detectMoney.polygon {
                let points = polygon.compactMap({
                    CGPoint(x:(CGFloat($0.x) * withDiff), y: (CGFloat($0.y) * heightDiff))
                })
                polygonViews.append(addPolygonView(points: points, color: Constants.colors[colorIndex]))
            }
            if polygonViews.count > 0 {
                let resultView = configureResultView(detectMoney: detectMoney, withColor: Constants.colors[colorIndex])
                polygonResultViewsDict[detectMoney.id] = (resultView, polygonViews)
            }
            colorIndex = colorIndex == Constants.colors.count - 1 ? 0 : colorIndex + 1            
        }
    }    
    
    private func addPolygonView(points: [CGPoint], color: UIColor) -> PolygonView {
        let polygonView = PolygonView(frame: polygonViewsContainerView.bounds)
        polygonViewsContainerView.addSubview(polygonView)
        polygonView.autopinToSuperviewEdges()
        polygonView.addRectangleFromPoints(points: points, strokeColor: color)
        return polygonView
    }
    
    private func resetValues() {
        polygonResultViewsDict.removeAll()
        for view in resultsStackView.arrangedSubviews {
            if let resultView = view as? ResultView {
                resultView.delegate = nil
                resultsStackView.removeArrangedSubview(view)
            }
        }
    }
    
    private func sendFeedback(detectedMoney: MDDetectedMoney, isCorrect: Bool, completion:(()->())?) {        
        activityIndicatorView.startAnimating()        
        MoneyDetector.sendFeedback(withImageID: detectedMoney.id, isCorrect: isCorrect) {[weak self] (result) in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }
            switch result {
            case .success(let response):
                print(response.message ?? "")
                DispatchQueue.main.async {
                    completion?()
                }
            case .failure(let errorResponse):
                print(errorResponse.localizedDescription)
                self.showAlert(withMessage: UtilityMethods.getMessage(error: errorResponse))
            }
        }
    }
    
    private func changeResultStackviewOrder(resultView: ResultView) {
        guard resultsStackView.arrangedSubviews.count > 1, resultView != resultsStackView.arrangedSubviews.last else {
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            resultView.isHidden = true
        }, completion: { (_) in
            resultView.removeFromSuperview()
            self.resultsStackView.addArrangedSubview(resultView)
            UIView.animate(withDuration: 0.3) {
                resultView.isHidden = false
            }
        })
    }
}

//MARK:- ResultView Delegate methods
extension DetectResultsViewController: ResultViewDelegate {
    func didTapCorrectButton(resultView: ResultView, detectedMoney: MDDetectedMoney) {
        sendFeedback(detectedMoney: detectedMoney, isCorrect: true) {
            resultView.correctButton.disableButton()
            resultView.incorrectButton.isHidden = true
            self.changeResultStackviewOrder(resultView: resultView)
        }
    }
    
    func didTapIncorrectButton(resultView: ResultView, detectedMoney: MDDetectedMoney) {
        sendFeedback(detectedMoney: detectedMoney, isCorrect: false) {
            resultView.incorrectButton.disableButton()
            resultView.correctButton.isHidden = true
            self.changeResultStackviewOrder(resultView: resultView)
        }
    }
    
    func didTapLeaveFeedbackButton(resultView: ResultView, detectedMoney: MDDetectedMoney) {
        let leaveFeedbackVC = LeaveFeedbackViewController(withImageId: detectedMoney.id)
        leaveFeedbackVC.modalPresentationStyle = .overCurrentContext
        leaveFeedbackVC.modalTransitionStyle = .crossDissolve
        leaveFeedbackVC.delegate = self
        navigationController?.present(leaveFeedbackVC, animated: true)
    }
}

//MARK:- LeaveFeedbackViewController Delegate methods
extension DetectResultsViewController: LeaveFeedbackViewControllerDelegate {
    func feedbackLeftSuccesfully(leaveFeedbackViewController: LeaveFeedbackViewController, imageId: String) {
        if let resultView = polygonResultViewsDict[imageId]?.0 {
            resultView.leaveFeedbackButtonHeightConstant.constant = 0
            UIView.animate(withDuration: 0.5) {                
                resultView.leaveFeedbackButton.alpha = 0.0
                self.view.layoutIfNeeded()
            }
        }
    }
}
