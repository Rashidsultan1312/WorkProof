import Foundation

struct WorkOrder: Identifiable, Hashable, Codable {
    var id = UUID()
    var clientName: String
    var address: String
    var jobType: String
    var status: OrderStatus
    var createdAt: Date
    var updatedAt: Date
    var photos: [WorkPhoto]
    var actions: [WorkAction]
    var laborCost: Double
    var materialsCost: Double
    var trackedSeconds: TimeInterval
    var timerStartedAt: Date?

    init(
        id: UUID = UUID(),
        clientName: String,
        address: String = "",
        jobType: String,
        status: OrderStatus = .inProgress,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        photos: [WorkPhoto] = [],
        actions: [WorkAction] = [],
        laborCost: Double = 0,
        materialsCost: Double = 0,
        trackedSeconds: TimeInterval = 0,
        timerStartedAt: Date? = nil
    ) {
        self.id = id
        self.clientName = clientName
        self.address = address
        self.jobType = jobType
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.photos = photos
        self.actions = actions
        self.laborCost = laborCost
        self.materialsCost = materialsCost
        self.trackedSeconds = trackedSeconds
        self.timerStartedAt = timerStartedAt
    }

    var totalCost: Double {
        laborCost + materialsCost
    }

    var isTimerRunning: Bool {
        timerStartedAt != nil
    }

    func elapsedTime(reference: Date = .now) -> TimeInterval {
        guard let timerStartedAt else { return trackedSeconds }
        return trackedSeconds + max(0, reference.timeIntervalSince(timerStartedAt))
    }

    mutating func setStatus(_ newStatus: OrderStatus) {
        status = newStatus
        touch()
    }

    mutating func setCosts(labor: Double, materials: Double) {
        laborCost = max(0, labor)
        materialsCost = max(0, materials)
        touch()
    }

    mutating func addAction(text: String, date: Date = .now) {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.isEmpty == false else { return }
        actions.insert(WorkAction(text: cleaned, timestamp: date), at: 0)
        touch(date: date)
    }

    mutating func addPhoto(stage: PhotoStage, imageData: Data, date: Date = .now) {
        photos.insert(WorkPhoto(stage: stage, timestamp: date, imageData: imageData), at: 0)
        touch(date: date)
    }

    mutating func removeAction(id: UUID, date: Date = .now) {
        actions.removeAll { $0.id == id }
        touch(date: date)
    }

    mutating func removePhoto(id: UUID, date: Date = .now) {
        photos.removeAll { $0.id == id }
        touch(date: date)
    }

    mutating func startTimer(date: Date = .now) {
        guard timerStartedAt == nil else { return }
        timerStartedAt = date
        touch(date: date)
    }

    mutating func stopTimer(date: Date = .now) {
        guard let timerStartedAt else { return }
        trackedSeconds += max(0, date.timeIntervalSince(timerStartedAt))
        self.timerStartedAt = nil
        touch(date: date)
    }

    mutating func touch(date: Date = .now) {
        updatedAt = date
    }
}

extension WorkOrder {
    static var sampleOrders: [WorkOrder] {
        [
            WorkOrder(
                clientName: "Alex Harper",
                address: "14 Pine Street",
                jobType: "Kitchen Pipe Repair",
                status: .inProgress,
                createdAt: Date.now.addingTimeInterval(-72_000),
                updatedAt: Date.now.addingTimeInterval(-3_600),
                actions: [
                    WorkAction(text: "Replaced damaged connector", timestamp: Date.now.addingTimeInterval(-5_400)),
                    WorkAction(text: "Checked pressure stability", timestamp: Date.now.addingTimeInterval(-4_800))
                ],
                laborCost: 120,
                materialsCost: 45,
                trackedSeconds: 5_100
            ),
            WorkOrder(
                clientName: "Emma Stone",
                address: "89 River Road",
                jobType: "Boiler Maintenance",
                status: .completed,
                createdAt: Date.now.addingTimeInterval(-410_000),
                updatedAt: Date.now.addingTimeInterval(-355_000),
                actions: [
                    WorkAction(text: "Cleaned internal filter", timestamp: Date.now.addingTimeInterval(-401_000)),
                    WorkAction(text: "Adjusted valve", timestamp: Date.now.addingTimeInterval(-398_000))
                ],
                laborCost: 90,
                materialsCost: 20,
                trackedSeconds: 4_200
            ),
            WorkOrder(
                clientName: "Alex Harper",
                address: "14 Pine Street",
                jobType: "Bathroom Leak Diagnostics",
                status: .completed,
                createdAt: Date.now.addingTimeInterval(-900_000),
                updatedAt: Date.now.addingTimeInterval(-896_000),
                actions: [
                    WorkAction(text: "Detected cracked gasket", timestamp: Date.now.addingTimeInterval(-899_000))
                ],
                laborCost: 80,
                materialsCost: 15,
                trackedSeconds: 3_400
            )
        ]
    }
}
