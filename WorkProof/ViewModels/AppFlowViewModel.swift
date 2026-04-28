import Foundation

@MainActor
final class AppFlowViewModel: ObservableObject {
    enum Phase {
        case loading
        case onboarding
        case dashboard
    }

    @Published private(set) var phase: Phase = .loading
    private var hasStarted = false
    private var loadingTask: Task<Void, Never>?

    func startIfNeeded(hasSeenOnboarding: Bool) {
        guard hasStarted == false else { return }
        hasStarted = true
        start(hasSeenOnboarding: hasSeenOnboarding)
    }

    func start(hasSeenOnboarding: Bool) {
        loadingTask?.cancel()
        phase = .loading

        loadingTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard Task.isCancelled == false else { return }
            phase = hasSeenOnboarding ? .dashboard : .onboarding
        }
    }

    func finishOnboarding() {
        loadingTask?.cancel()
        phase = .dashboard
    }
}
