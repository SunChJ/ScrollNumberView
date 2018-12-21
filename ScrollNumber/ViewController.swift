//
//  ViewController.swift
//  ScrollNumber
//
//  Created by 孙超杰 on 2018/12/21.
//  Copyright © 2018年 孙超杰. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollNumberView: ScrollNumberAnimatdView!
  
    @IBAction func start(_ sender: UIButton) {
        let number = Int.random(in: 1000...3000)
        scrollNumberView.newNumber = number
        print(number)
        scrollNumberView.startAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollNumberView.font = UIFont.systemFont(ofSize: 14)
        scrollNumberView.minLength = 0
        
    }

}

