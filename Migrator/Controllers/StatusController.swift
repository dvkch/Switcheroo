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

class StatusController {
    
    // MARK: Init
    init(urls: [URL], scheme: String, host: String, delegate: StatusControllerDelegate?) {
        self.urls = urls
        self.scheme = scheme
        self.host = host
        self.delegate = delegate
    }
    
    // MARK: Properties
    weak var delegate: StatusControllerDelegate?
    let urls: [URL]
    let scheme: String
    let host: String
    
    // MARK: Internal properties
    private var isRunning: Bool = false
    private var session = URLSession(configuration: .ephemeral)
    private var queue = [URL]()
    
    // MARK: Actions
    func start() {
        guard !isRunning else { return }
        isRunning = true
        queue = urls
        dequeueNext()
    }
    
    func stop() {
        queue = []
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
                self.delegate?.statusController(self, didUpdateStatusFor: url, status: PathStatus(response: (response as? HTTPURLResponse), error: error))
                self.dequeueNext()
            }
        }
        request.resume()
    }
}
