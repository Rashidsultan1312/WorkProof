import SwiftUI
import UIKit

struct MainTabView: View {
    @ObservedObject var store: OrdersStore
    @State private var selection: Tab = .orders

    enum Tab {
        case orders
        case clients
        case insights
    }

    var body: some View {
        TabView(selection: $selection) {
            OrdersDashboardView(store: store)
                .tabItem {
                    Label("Orders", systemImage: "tray.full.fill")
                }
                .tag(Tab.orders)

            ClientsHubView(store: store)
                .tabItem {
                    Label("Clients", systemImage: "person.2.fill")
                }
                .tag(Tab.clients)

            InsightsView(store: store)
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(Tab.insights)
        }
        .tint(Color(red: 0.33, green: 0.86, blue: 0.96))
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.09, blue: 0.17, alpha: 1)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.55)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.55)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.33, green: 0.86, blue: 0.96, alpha: 1)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.33, green: 0.86, blue: 0.96, alpha: 1)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(store: OrdersStore())
    }
}
