//
//  StatusController.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Foundation

protocol StatusControllerDelegate: NSObjectProtocol {
    func statusController(_ statusController: StatusController, didUpdateStatusFor url: URL, status: PathStatus)
    func statusControllerDidFinish(_ statusController: StatusController)
}

class StatusController: NSObject {
    
    // MARK: Init
    init(urls: [URL], scheme: String, host: String, delegate: StatusControllerDelegate?) {
        self.urls = urls
        self.scheme = scheme
        self.host = host
        super.init()

        self.session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        self.delegate = delegate
    }
    
    // MARK: Properties
    weak var delegate: StatusControllerDelegate?
    let urls: [URL]
    let scheme: String
    let host: String
    
    // MARK: Internal properties
    private var isRunning: Bool = false
    private var session: URLSession!
    private var queue = [URL]()
    private var redirects = [URL: HTTPURLResponse]()
    
    // MARK: Actions
    func start() {
        guard !isRunning else { return }
        isRunning = true
        queue = urls
        dequeueNext()
    }
    
    func stop() {
        queue = []
        redirects = [:]
        delegate?.statusControllerDidFinish(self)
        isRunning = false
    }
    
    // MARK: Internal actions
    private func dequeueNext() {
        guard !queue.isEmpty else {
            stop()
            return
        }

        let url = queue.removeFirst()
        let updatedURL = url.updatingHost(host, scheme: scheme)
        let request = session.dataTask(with: updatedURL) { _, response, error in
            DispatchQueue.main.async {
                let status = PathStatus(
                    originalURL: url,
                    response: (response as? HTTPURLResponse),
                    redirect: self.redirects[updatedURL],
                    error: error
                )
                self.delegate?.statusController(self, didUpdateStatusFor: url, status: status)
                self.dequeueNext()
            }
        }
        request.resume()
    }
}

extension StatusController: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let originalURL = task.originalRequest?.url {
            self.redirects[originalURL] = response
        }
        completionHandler(request)
    }
}
