import Foundation

@MainActor
final class OrdersStore: ObservableObject {
    @Published var orders: [WorkOrder] {
        didSet {
            scheduleSave()
        }
    }

    private let storageURL: URL
    private var saveTask: Task<Void, Never>?

    init(orders: [WorkOrder]? = nil) {
        self.storageURL = Self.makeStorageURL()

        if let orders, orders.isEmpty == false {
            self.orders = orders
        } else if let storedOrders = Self.loadOrders(from: storageURL), storedOrders.isEmpty == false {
            self.orders = storedOrders
        } else {
            self.orders = WorkOrder.sampleOrders
        }
    }

    func createOrder(clientName: String, address: String, jobType: String) {
        let cleanedName = clientName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedJob = jobType.trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleanedName.isEmpty == false, cleanedJob.isEmpty == false else { return }

        let order = WorkOrder(clientName: cleanedName, address: cleanedAddress, jobType: cleanedJob)
        orders.insert(order, at: 0)
    }

    func deleteOrder(id: UUID) {
        orders.removeAll { $0.id == id }
    }

    func updateOrderStatus(id: UUID, to status: OrderStatus) {
        guard let index = orders.firstIndex(where: { $0.id == id }) else { return }
        orders[index].setStatus(status)
    }

    func resetToSampleData() {
        orders = WorkOrder.sampleOrders
    }

    func clientHistory(for order: WorkOrder) -> [WorkOrder] {
        orders
            .filter {
                $0.id != order.id &&
                $0.clientName.caseInsensitiveCompare(order.clientName) == .orderedSame
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func scheduleSave() {
        saveTask?.cancel()

        let snapshot = orders
        let destination = storageURL
        saveTask = Task.detached(priority: .utility) {
            try? await Task.sleep(nanoseconds: 220_000_000)
            guard Task.isCancelled == false else { return }

            do {
                let data = try JSONEncoder().encode(snapshot)
                try data.write(to: destination, options: [.atomic])
            } catch {
                print("OrdersStore save failed: \(error.localizedDescription)")
            }
        }
    }
}

private extension OrdersStore {
    static func makeStorageURL() -> URL {
        let manager = FileManager.default
        let base = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directory = base.appendingPathComponent("WorkProof", isDirectory: true)
        try? manager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("orders.json")
    }

    static func loadOrders(from url: URL) -> [WorkOrder]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([WorkOrder].self, from: data)
    }
}
