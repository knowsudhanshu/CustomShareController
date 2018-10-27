//
//  ViewController.swift
//  CustomShareController
//
//  Created by Sudhanshu Sudhanshu on 27/10/18.
//  Copyright © 2018 Sudhanshu Sudhanshu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let openShareButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Open Share", for: .normal)
        button.addTarget(self, action: #selector(openShareAction), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return button
    }()
    
    @objc private func openShareAction () {
        let shareController = ShareViewController()
        shareController.modalPresentationStyle = .overFullScreen
        shareController.modalTransitionStyle = .crossDissolve
        shareController.show()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(openShareButton)
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
