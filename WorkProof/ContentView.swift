import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @StateObject private var flowViewModel = AppFlowViewModel()
    @StateObject private var ordersStore = OrdersStore()

    var body: some View {
        Group {
            switch flowViewModel.phase {
            case .loading:
                LoadingView()
                    .transition(.opacity)

            case .onboarding:
                OnboardingView {
                    hasSeenOnboarding = true
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                        flowViewModel.finishOnboarding()
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .dashboard:
                MainTabView(store: ordersStore)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: flowViewModel.phase)
        .onAppear {
            flowViewModel.startIfNeeded(hasSeenOnboarding: hasSeenOnboarding)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingView()
                .previewDisplayName("Loading")

            OnboardingView(onFinish: {})
                .previewDisplayName("Onboarding")

            MainTabView(store: OrdersStore())
                .previewDisplayName("Tabs")
        }
    }
}
