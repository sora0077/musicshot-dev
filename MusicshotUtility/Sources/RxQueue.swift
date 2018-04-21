//
//  RxQueue.swift
//  MusicshotCore
//
//  Created by 林達也 on 2018/03/20.
//  Copyright © 2018年 林達也. All rights reserved.
//

import Foundation
import RxSwift

public final class FIFOQueue<E> {
    public enum Result {
        case success(E)
        case failure(Error)

        public func value() throws -> E {
            switch self {
            case .success(let value): return value
            case .failure(let error): throw error
            }
        }
    }
    private let publisher = PublishSubject<Result>()
    private let operationQueue = OperationQueue()
    private var keys: ArraySlice<AnyHashable> = []
    private var buffer: [AnyHashable: Result] = [:]
    private let executor = DispatchQueue(label: "fifo-queue")
    private let disposeBag = RxSwift.DisposeBag()

    public init(maxConcurrentOperationCount: Int = 3) {
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    }

    public func append(_ item: Single<E>) {
        let key = UUID()
        let operation = RxOperation(item, disposeBag: disposeBag, on: executor, completion: { [weak self] result in
            self?.buffer[key] = result
            let keys = self?.keys ?? []
            for k in keys {
                guard let value = self?.buffer[k], self?.keys[0] == k else { return }
                self?.keys.remove(at: 0)
                self?.buffer.removeValue(forKey: k)
                self?.publisher.onNext(value)
            }
        })
        executor.async {
            self.keys.append(key)
            self.operationQueue.addOperation(operation)
        }
    }

    public func asObservable() -> Observable<Result> {
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
    private let disposeBag: RxSwift.DisposeBag
    private let queue: DispatchQueue
    private let completion: (Result) -> Void

    init(_ task: Single<E>, disposeBag: RxSwift.DisposeBag, on queue: DispatchQueue, completion: @escaping (Result) -> Void) {
        self.task = task
        self.disposeBag = disposeBag
        self.queue = queue
        self.completion = completion
        super.init()
    }

    override func start() {
        guard !isCancelled else {
            state = .finished
            return
        }

        state = .execute

        task.subscribe(
            onSuccess: { [weak self] value in
                self?.queue.async {
                    self?.completion(.success(value))
                    self?.state = .finished
                }
            },
            onError: { [weak self] error in
                self?.queue.async {
                    self?.completion(.failure(error))
                    self?.state = .finished
                }
            }
        ).disposed(by: disposeBag)
    }
}
