//
//  ViewModel.swift
//  rxpractice
//
//  Created by Fujiki Takeshi on 5/31/16.
//  Copyright © 2016 takecian. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class ViewModel {
    let client: HttpClient

    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()
    let loading = Variable<Bool>(false)

    let error = PublishSubject<ErrorType>()
    let elements = Variable<[User]>([])

    private let disposeBag = DisposeBag()
    
    init(client: HttpClient) {
        self.client = client
        
        let refreshRequest = refreshTrigger
            .withLatestFrom(loading.asObservable())
            .filter { !$0 }
        
        let nextPageRequest = loadNextPageTrigger
            .withLatestFrom(loading.asObservable())
            .filter { !$0 }
        
        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .shareReplay(1)
        
        let response = request
            .flatMap { request in
                return self.client.get(NSURL(string: "https://s3-ap-northeast-1.amazonaws.com/castownframe/frame.json")!, parameters: nil, headers: nil)}.shareReplay(1)
        
        Observable
            .of(
                request.map { _ in true },
                response.map { _ in false },
                error.map { _ in false }
            )
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)
        
        response.bindTo(elements).addDisposableTo(disposeBag)
        
    }

}

extension UIScrollView {
    var rx_reachedBottom: Observable<Void> {
        return rx_contentOffset
            .flatMap { [weak self] contentOffset -> Observable<Void> in
                guard let scrollView = self else {
                    return Observable.empty()
                }
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                return y > threshold ? Observable.just() : Observable.empty()
        }
    }
}
