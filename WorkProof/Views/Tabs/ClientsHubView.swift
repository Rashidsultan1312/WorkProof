import SwiftUI

private struct ClientSnapshot: Identifiable {
    let id = UUID()
    let name: String
    let totalOrders: Int
    let completedOrders: Int
    let totalSpent: Double
    let lastJobType: String
    let lastSeen: Date
}

struct ClientsHubView: View {
    @ObservedObject var store: OrdersStore
    @State private var query = ""
    @AppStorage(CurrencySettings.storageKey) private var selectedCurrencyCode = CurrencySettings.defaultCode

    private var snapshots: [ClientSnapshot] {
        let grouped = Dictionary(grouping: store.orders, by: { $0.clientName })
        let mapped = grouped.compactMap { key, value -> ClientSnapshot? in
            guard let latest = value.max(by: { $0.updatedAt < $1.updatedAt }) else { return nil }
            return ClientSnapshot(
                name: key,
                totalOrders: value.count,
                completedOrders: value.filter { $0.status == .completed }.count,
                totalSpent: value.reduce(0) { $0 + $1.totalCost },
                lastJobType: latest.jobType,
                lastSeen: latest.updatedAt
            )
        }

        let sorted = mapped.sorted { $0.lastSeen > $1.lastSeen }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmed.isEmpty == false else { return sorted }
        return sorted.filter {
            $0.name.lowercased().contains(trimmed) ||
            $0.lastJobType.lowercased().contains(trimmed)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageGradient
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        headerCard
                        searchCard
                        content
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Client History")
                .font(.custom("AvenirNext-Bold", size: 30))
                .foregroundStyle(.white)

            Text("See repeat clients, previous jobs and spending at a glance.")
                .font(.custom("AvenirNext-Regular", size: 15))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frostedCard(cornerRadius: 26)
    }

    private var searchCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.secondaryText)

            TextField(
                "Search client or recent job",
                text: $query,
                prompt: Text("Search client or recent job").foregroundColor(Color.white.opacity(0.45))
            )
            .font(.custom("AvenirNext-Regular", size: 15))
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var content: some View {
        if snapshots.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.7))

                Text("No clients found")
                    .font(.custom("AvenirNext-DemiBold", size: 20))
                    .foregroundStyle(.white)

                Text("Try another search query.")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .frostedCard(cornerRadius: 22)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(snapshots) { client in
                    NavigationLink {
                        ClientOrdersView(store: store, clientName: client.name)
                    } label: {
                        clientCard(client)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func clientCard(_ client: ClientSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(client.name)
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundStyle(.white)
                Spacer()
                Text(ReportComposer.formattedMoney(client.totalSpent, currencyCode: selectedCurrencyCode))
                    .font(.custom("AvenirNext-DemiBold", size: 15))
                    .foregroundStyle(Color(red: 0.31, green: 0.91, blue: 0.85))
            }

            Text(client.lastJobType)
                .font(.custom("AvenirNext-Regular", size: 14))
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(1)

            HStack {
                miniMetric(title: "Orders", value: "\(client.totalOrders)")
                miniMetric(title: "Completed", value: "\(client.completedOrders)")
                miniMetric(title: "Last Seen", value: AppFormatters.shortDate.string(from: client.lastSeen))
            }

            HStack(spacing: 7) {
                Image(systemName: "clock.arrow.circlepath")
                Text("Open history")
            }
            .font(.custom("AvenirNext-DemiBold", size: 13))
            .foregroundStyle(Color.white.opacity(0.82))
        }
        .frostedCard(cornerRadius: 24)
    }

    @ViewBuilder
    private func miniMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.custom("AvenirNext-Regular", size: 11))
                .foregroundStyle(AppTheme.secondaryText)
            Text(value)
                .font(.custom("AvenirNext-DemiBold", size: 12))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(9)
        .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ClientOrdersView: View {
    @ObservedObject var store: OrdersStore
    let clientName: String

    private var orders: [WorkOrder] {
        store.orders
            .filter { $0.clientName.caseInsensitiveCompare(clientName) == .orderedSame }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(clientName)
                            .font(.custom("AvenirNext-Bold", size: 30))
                            .foregroundStyle(.white)

                        Text("\(orders.count) order(s) in history")
                            .font(.custom("AvenirNext-Regular", size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .frostedCard(cornerRadius: 24)

                    ForEach(orders) { order in
                        NavigationLink {
                            OrderDetailView(store: store, orderID: order.id)
                        } label: {
                            OrderCardView(order: order)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ClientsHubView_Previews: PreviewProvider {
    static var previews: some View {
        ClientsHubView(store: OrdersStore())
    }
}
