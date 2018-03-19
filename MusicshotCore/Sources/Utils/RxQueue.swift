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
    private let executor = DispatchQueue(label: "fifo-queue")

    init(maxConcurrentOperationCount: Int = 2) {
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    func append(_ item: Single<E>) {
        executor.async {
            let key = UUID()
            self.keys.append(key)
            self.operationQueue.addOperation(RxOperation(item, completion: { [weak self] result in
                self?.executor.async {
                    self?.buffer[key] = result
                    for k in self?.keys ?? [] {
                        guard let value = self?.buffer[k] else { return }
                        _ = self?.keys.popFirst()
                        self?.buffer[k] = nil
                        self?.publisher.onNext(value)
                    }
                }
            }))
        }
    }

    func asObservable() -> Observable<Result> {
        return publisher.asObservable()
    }
}

// MARK: -
private final class RxOperation<E>: Operation {
    typealias Result = FIFOQueue<E>.Result

    override var isConcurrent: Bool { return true }
    override var isExecuting: Bool {
        return state == .execute ? true : false
    }
    override var isFinished: Bool {
        return state == .finished ? true : false
    }

    private enum State {
        case ready
        case execute
        case finished
    }
    private var state: State = .ready {
        willSet {
            willChangeValue(for: \.isExecuting)
            willChangeValue(for: \.isFinished)
        }
        didSet {
            didChangeValue(for: \.isExecuting)
            didChangeValue(for: \.isFinished)
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

        state = .execute

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
