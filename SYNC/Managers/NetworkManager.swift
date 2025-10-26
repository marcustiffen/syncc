import Network
import Combine


class NetworkManager: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isDisconnected: Bool = false

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isDisconnected = (path.status != .satisfied)

                if path.status == .satisfied {} else {}

                if path.usesInterfaceType(.wifi) {} else if path.usesInterfaceType(.cellular) {}
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

