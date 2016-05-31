//
//  ViewController.swift
//  rxpractice
//
//  Created by Fujiki Takeshi on 5/27/16.
//  Copyright © 2016 takecian. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var textlabel: UILabel!
    @IBOutlet weak var tableview: UITableView!

    private let refresh = UIRefreshControl()
    let disposeBag = DisposeBag()
    let viewModel = ViewModel(client: DefaultHttpClient())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.addSubview(refresh)
        tableview.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        textfield.rx_text.bindTo(textlabel.rx_text).addDisposableTo(disposeBag)
        
        rx_sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)

        viewModel.loading.asDriver()
            .drive(refresh.rx_refreshing)
            .addDisposableTo(disposeBag)
        
        refresh.rx_controlEvent(.ValueChanged).subscribeNext { [unowned self] x -> Void in
            self.viewModel.refreshTrigger.onNext()
            }.addDisposableTo(disposeBag)
        
        tableview.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)
        
        tableview.rx_itemSelected.subscribeNext { (indexPath) in
            self.tableview.deselectRowAtIndexPath(indexPath, animated: false)
        }.addDisposableTo(disposeBag)

        viewModel.elements.asDriver()
            .drive(tableview.rx_itemsWithCellIdentifier("Cell")) { _, user, cell in
                cell.textLabel?.text = user.name
                cell.detailTextLabel?.text = user.url
            }
            .addDisposableTo(disposeBag)
    }

}
