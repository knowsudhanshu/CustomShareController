//
//  ViewController.swift
//  CustomShareController
//
//  Created by Sudhanshu Sudhanshu on 27/10/18.
//  Copyright © 2018 Sudhanshu Sudhanshu. All rights reserved.
//

import UIKit
import Photos
import MessageUI

let optionViewHeight: CGFloat = 300

enum ShareItemKey: String {
    case message, attachment
}

class ShareViewController: UIViewController {
    var presenter: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    var selectedItem: ShareItem?
    var shareItemType: String = ""
    
    var cancelFullButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        return button
    }()
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: optionViewHeight), collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    var viewTopConstraint: NSLayoutConstraint!
    
    let titleLabel: UILabel = {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width:
            UIScreen.main.bounds.width, height: 40))
        label.text = "Share to"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        label.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        
        let cornerRadius : CGFloat = 8
        let path = UIBezierPath(roundedRect: label.bounds, byRoundingCorners:[.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = label.bounds
        maskLayer.path = path.cgPath
        label.layer.mask = maskLayer
        label.layer.masksToBounds = true
        
        return label
    }()
    
    let cancelView: UIView = {
        let view = UIView()
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70))
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitle("CANCEL", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.8823529412, green: 0.3215686275, blue: 0.1176470588, alpha: 1), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .white
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        return view
    }()
    
    var shareItem: [ShareItemKey: Any] = [:]
    
    var isVisible: Bool = true
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(with shareItem: [ShareItemKey: Any]) {
        self.shareItem = shareItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.15)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        populateOptions()
        
        setupView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOptions()
    }
    
    fileprivate func setupView() {
        //        let width: CGFloat = view.bounds.size.width
        view.addSubview(cancelFullButton)
        
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: "ItemCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        //        view.addSubview(collectionView)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, collectionView, cancelView])
        //        let stackView = UIStackView(arrangedSubviews: [collectionView])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        //
        
        let heightConstraint = NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: optionViewHeight)
        
        viewTopConstraint = NSLayoutConstraint(item: stackView, attribute: .topMargin, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 40)
        
        NSLayoutConstraint.activate([viewTopConstraint, heightConstraint])
    }
    
    
    @objc fileprivate func showOptions() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            self?.viewTopConstraint.constant = -optionViewHeight + 40//(UIScreen.main.bounds.height - 300)
            
            self?.view.layoutIfNeeded()
        })
    }
    
    @objc fileprivate func hideOptions(dismiss: Bool = false) {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.viewTopConstraint.constant = 40//UIScreen.main.bounds.height
            
            self.view.layoutIfNeeded()
        }, completion: { finished in
            if dismiss == true {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    // Actions
    func show() {
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        UIApplication.shared.keyWindow?.topMostWindowController()?.present(self, animated: true)
    }
    
    @objc fileprivate func cancelAction(_ sender: UIButton) {
        hideOptions(dismiss: true)
    }
    
    @objc fileprivate func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        hideOptions(dismiss: true)
    }
    
    fileprivate func dismiss() {
        hideOptions()
    }
    
    var optionsArr: [ShareItem] = []
    private func populateOptions() {
        // Instagram
        // Stories
        // WhatsApp
        // Twitter
        // SMS
        // Others
        
        if schemeAvailable(scheme: "instagram://") {
            optionsArr.append(ShareItem(title: "Instagram", image: #imageLiteral(resourceName: "share_icon_instagram"), type: .instagram))
        }else if schemeAvailable(scheme: "stories://") {
            optionsArr.append(ShareItem(title: "Stories", image: #imageLiteral(resourceName: "share_icon_stories"), type: .stories))
        }else if schemeAvailable(scheme: "whatsapp://") {
            optionsArr.append(ShareItem(title: "WhatsApp", image: #imageLiteral(resourceName: "share_icon_whatsapp"), type: .whatsapp))
        }else if schemeAvailable(scheme: "twitter://") {
            optionsArr.append(ShareItem(title: "Twitter", image: #imageLiteral(resourceName: "share_icon_twitter"), type: .twitter))
        }
        
        optionsArr.append(ShareItem(title: "SMS", image: #imageLiteral(resourceName: "share_icon_imessage"), type: .sms))
        optionsArr.append(ShareItem(title: "Others", image: #imageLiteral(resourceName: "share_icon_other"), type: .others))
        
    }
    func schemeAvailable(scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    fileprivate func openTwitterShare() {
        
        if UIApplication.shared.canOpenURL(URL(string: "twitter://")!) {
            let messageTextEncoded: String = (shareItem[.message] as! String).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? ""
            let urlString: String = "twitter://post?message=\(messageTextEncoded)"
            let twitterPostURL : URL? = URL(string: urlString)
            
            if twitterPostURL != nil {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(twitterPostURL!)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(twitterPostURL!)
                }
            }
        }
        else {
            // TODO: app not installed
        }
    }
    
    fileprivate func shareOnWhatsApp() {
        // Can share a text only
        let messageText = shareItem[.message] as! String
        let messageTextEncoded: String = messageText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? ""
        let urlString: String = "whatsapp://send?text=\(messageTextEncoded)"
        guard let url : URL = URL(string: urlString) else {return}
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    fileprivate func shareOnInstaStories() {
        //             add instagram-stories to the LSApplicationQueriesSchemes
        
        // Verify app can open custom URL scheme, open if able
        let urlScheme: URL = URL(string: "instagram-stories://share")!
        if UIApplication.shared.canOpenURL(urlScheme) {
            guard let image = self.shareItem[.attachment] as? UIImage else { return }
            
            // Assign background image asset and attribution link URL to pasteboard
            let pasteboardItems: Array = [["com.instagram.sharedSticker.backgroundImage" : image.pngData()!,
                                           "com.instagram.sharedSticker.contentURL" : "longwalks://"]]
            let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : Date().addingTimeInterval(60*5)]
            
            // This call is iOS 10+, can use 'setItems' depending on what versions you support
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            
            UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
        }
    }
    
    fileprivate func shareOnInstagram() {
        // Ref: https://www.instagram.com/developer/mobile-sharing/iphone-hooks/
        let urlScheme: URL = URL(string: "instagram://")!
        if UIApplication.shared.canOpenURL(urlScheme) {
            guard let image = self.shareItem[.attachment] as? UIImage else { return }
            saveImage(image: image) { (asset) in
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                if let lastAsset = fetchResult.firstObject {
                    let localIdentifier = lastAsset.localIdentifier
                    let u = "instagram://library?LocalIdentifier=" + localIdentifier
                    let url = URL(string: u)!
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)//openURL(NSURL(string: u)!)
                        } else {
                            // TODO: Show message if app is not installed
                        }
                    }
                    
                }
            }
            
        }
    }
    
    fileprivate func openEmailComposer(messageText: String) {
        guard MFMailComposeViewController.canSendMail() else {
            // TODO: app not available
            return
        }
        
        let messageText = shareItem[.message] as! String
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setMessageBody(messageText, isHTML: false)
        self.present(mailComposerVC, animated: true, completion: nil)
    }
    
    fileprivate func openMessageComposer() {
        let messageText = shareItem[.message] as! String
        
        guard MFMessageComposeViewController.canSendText() else {
            // TODO: app not available
            return
        }
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate  = self
        messageController.body = messageText
        
        if let attachment = shareItem[.attachment] as? UIImage {
            let imageData = attachment.jpegData(compressionQuality: 1)
            messageController.addAttachmentData(imageData!, typeIdentifier: "image/JPEG", filename: "invitation.png")
        }
        
        
        self.present(messageController, animated: true)
    }
    
}

protocol StorableAsset{}
extension StorableAsset where Self: UIImage {
    func saveToPhotoLibrary(completion: ((PHAsset?)->())? = nil) {
        var placeholder: PHObjectPlaceholder!
        let collection = PHAssetCollection.init()
        
        PHPhotoLibrary.shared().performChanges({
            let assetCreateRequest = PHAssetChangeRequest.creationRequestForAsset(from: self)
            
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection), let photoPlaceholder = assetCreateRequest.placeholderForCreatedAsset else{ return }
            
            placeholder = photoPlaceholder
            let fastEnumeration: NSFastEnumeration = Array([photoPlaceholder]) as NSFastEnumeration
            albumChangeRequest.addAssets(fastEnumeration)
            
        }, completionHandler: ({ (success, error) in
            guard let placeholder = placeholder else {
                completion?(nil)
                return
            }
            if success {
                let assets:PHFetchResult<PHAsset> =  PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                
                completion?(assets.firstObject)
            }else {
                
            }
        }))
    }
}

extension UIImage: StorableAsset{}
extension ShareViewController: UIImagePickerControllerDelegate {
    
    fileprivate func saveImage(image: UIImage, completion: ((PHAsset?)->())? = nil) {
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            image.saveToPhotoLibrary { (asset) in
                completion?(asset)
            }
        }else {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    image.saveToPhotoLibrary { (asset) in
                        completion?(asset)
                    }
                }
            }
        }
    }
}

extension ShareViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        let item = optionsArr[indexPath.item]
        collectionCell.imageView.image = item.image
        collectionCell.titleLabel.text = item.title
        return collectionCell
    }
    /*
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
     switch kind {
     case UICollectionElementKindSectionHeader:
     
     let headerView = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 40))
     let headerLabel = UILabel()
     headerLabel.text = "Share to"
     headerLabel.textAlignment = .center
     headerLabel.font = UIFont(name: n.medium.rawValue, size: 20)
     headerLabel.textColor = .black
     headerLabel.backgroundColor = .white
     headerView.addSubview(headerLabel)
     return headerView
     case UICollectionElementKindSectionFooter:
     let footerView = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 40))
     let button = UIButton(type: .custom)
     button.setTitle("CANCEL", for: .normal)
     button.backgroundColor = .white
     button.setTitleColor(.red, for: .normal)
     button.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
     
     footerView.addSubview(button)
     return footerView
     default: break
     
     }
     return UICollectionReusableView
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
     return CGSize(width: collectionView.bounds.width, height: 40)
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
     return CGSize(width: collectionView.bounds.width, height: 40)
     }
     */
    
    fileprivate func openNativeShare() {
        
        var activityItems: [Any] = []
        if let message = shareItem[.message] as? String {
            activityItems.append(message)
        }
        if let attachment = shareItem[.attachment] as? UIImage {
            activityItems.append(attachment)
        }
        
        let activityViewController = UIActivityViewController(activityItems: activityItems , applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {
            (activity, success, item, error) in
            if (success && error == nil) {
                
            }else if (error != nil)  {
                // Error
                
            }
            self.hideOptions(dismiss: true)
        }
        
        if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
            
            let window = UIApplication.shared.keyWindow
            activityViewController.popoverPresentationController?.sourceView = window
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: (window?.bounds.width ?? 2)/2, y: (window?.bounds.height ?? 64), width: 0, height: 0)
            self.present(activityViewController, animated: true)
            
        } else {
            self.present(activityViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = optionsArr[indexPath.item]
        switch item.type {
        case .instagram?:
            shareOnInstagram()
            
            break
        case .stories?:
            shareOnInstaStories()
            
            break
        case .whatsapp?:
            shareOnWhatsApp()
            
            break
        case .twitter?:
            openTwitterShare()
            
            break
        case .sms?:
            openMessageComposer()
            
            break
        case .others?:
            
            openNativeShare()
            
            break
        case .none:
            break
        }
        hideOptions()
    }
    
    @objc func appMovedToBackground() {
        self.hideOptions(dismiss: true)
    }
}

extension ShareViewController: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            break

        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
        self.hideOptions(dismiss: true)
    }
}

extension ShareViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
        case .sent:
            break
        default:
            break
        }
        self.hideOptions(dismiss: true)
    }
}

enum ShareCustomScheme: String {
    case instagram = "instagram-stories://share"
    case twitter = "twitter://"
    case whatsapp = "whatsapp://"
}

enum ShareItemType: String {
    case instagram, stories, whatsapp, twitter, sms, others
}


struct ShareItem {
    var title: String?
    var image: UIImage?
    var type: ShareItemType?
}

class ItemCell: UICollectionViewCell {
    var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    var stackView : UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public extension UIWindow {
    
    /** @return Returns the current Top Most ViewController in hierarchy.   */
    public func topMostWindowController()->UIViewController? {
        
        var topController = rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
}
