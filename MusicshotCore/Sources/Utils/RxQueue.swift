//
//  RxQueue.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/20.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift

final class FIFOQueue<E> {
    enum Result {
        case success(E)
        case failure(Error)
    }
    private let publisher = PublishSubject<Result>()
    private let operationQueue = OperationQueue()
    private var keys: ArraySlice<AnyHashable> = []
    private var buffer: [AnyHashable: Result] = [:]

    init(maxConcurrentOperationCount: Int = 2) {
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    func append(_ item: Single<E>) {
        let key = UUID()
        keys.append(key)
        operationQueue.addOperation(RxOperation(item, completion: { [weak self] result in
            self?.buffer[key] = result
            for k in self?.keys ?? [] {
                guard let value = self?.buffer[k] else { return }
                _ = self?.keys.popFirst()
                self?.buffer[k] = nil
                self?.publisher.onNext(value)
            }
        }))
    }

    func asObservable() -> Observable<Result> {
        return publisher.asObservable()
    }
}

// MARK: -
private final class RxOperation<E>: Operation {
    typealias Result = FIFOQueue<E>.Result

    override var isConcurrent: Bool { return true }

    private var _isExecuting = false
    override var isExecuting: Bool {
        get { return _isExecuting }
        set {
            guard _isExecuting != newValue else { return }
            willChangeValue(for: \.isExecuting)
            _isExecuting = newValue
            didChangeValue(for: \.isExecuting)
        }
    }
    private var _isFinished = false
    override var isFinished: Bool {
        get { return _isFinished }
        set {
            guard _isFinished != newValue else { return }
            willChangeValue(for: \.isFinished)
            _isFinished = newValue
            didChangeValue(for: \.isFinished)
        }
    }

    private enum State {
        case ready, executing, finished
    }
    private var state: State = .ready {
        didSet {
            switch state {
            case .ready: break
            case .executing:
                isExecuting = true
            case .finished:
                isExecuting = false
                isFinished = true
            }
        }
    }
    private let task: Single<E>
    private let completion: (Result) -> Void
    private let disposeBag = DisposeBag()

    init(_ task: Single<E>, completion: @escaping (Result) -> Void) {
        self.task = task
        self.completion = completion
    }

    override func start() {
        guard !isCancelled else {
            state = .finished
            return
        }

        state = .executing

        task.observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(
                onSuccess: { [weak self] value in
                    self?.completion(.success(value))
                    self?.state = .finished
                },
                onError: { [weak self] error in
                    self?.completion(.failure(error))
                    self?.state = .finished
                }
            )
            .disposed(by: disposeBag)
    }
}
