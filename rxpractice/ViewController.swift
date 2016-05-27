//
//  ViewController.swift
//  rxpractice
//
//  Created by Fujiki Takeshi on 5/27/16.
//  Copyright © 2016 takecian. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var textlabel: UILabel!
    
    let bag       = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        textfield.rx_text.subscribeNext { (text) in
//            self.textlabel.text = text
//        }.addDisposableTo(bag)
        
        textfield.rx_text.bindTo(textlabel.rx_text).addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

