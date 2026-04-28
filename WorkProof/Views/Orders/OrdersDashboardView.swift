import SwiftUI

private enum OrderScreenFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case inProgress = "In Progress"
    case waiting = "Waiting"
    case completed = "Completed"

    var id: String { rawValue }

    var status: OrderStatus? {
        switch self {
        case .all:
            return nil
        case .inProgress:
            return .inProgress
        case .waiting:
            return .waiting
        case .completed:
            return .completed
        }
    }
}

struct OrdersDashboardView: View {
    @ObservedObject var store: OrdersStore

    @State private var query = ""
    @State private var showCreateSheet = false
    @State private var showCurrencySheet = false
    @State private var selectedFilter: OrderScreenFilter = .all
    @State private var pendingDeleteOrder: WorkOrder?

    private var filteredOrders: [WorkOrder] {
        var base = store.orders.sorted { $0.updatedAt > $1.updatedAt }

        if let status = selectedFilter.status {
            base = base.filter { $0.status == status }
        }

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return base
        }

        let text = trimmed.lowercased()
        return base.filter {
            $0.clientName.lowercased().contains(text) ||
            $0.jobType.lowercased().contains(text) ||
            $0.address.lowercased().contains(text)
        }
    }

    private var completedCount: Int {
        store.orders.filter { $0.status == .completed }.count
    }

    private var activeCount: Int {
        store.orders.filter { $0.status != .completed }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageGradient
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        headerView
                        statsView
                        searchView
                        filterView

                        if filteredOrders.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredOrders) { order in
                                    NavigationLink(value: order.id) {
                                        OrderCardView(order: order)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        statusActions(for: order)
                                        Divider()
                                        Button(role: .destructive) {
                                            pendingDeleteOrder = order
                                        } label: {
                                            Label("Delete Order", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 34)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: UUID.self) { id in
                OrderDetailView(store: store, orderID: id)
            }
            .sheet(isPresented: $showCreateSheet) {
                NewOrderSheet(store: store)
            }
            .sheet(isPresented: $showCurrencySheet) {
                CurrencySettingsSheet()
            }
            .alert(item: $pendingDeleteOrder) { order in
                Alert(
                    title: Text("Delete This Order?"),
                    message: Text("This will permanently remove the order and its photos/actions."),
                    primaryButton: .destructive(Text("Delete")) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            store.deleteOrder(id: order.id)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private var headerView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text("WorkProof")
                    .font(.custom("AvenirNext-Bold", size: 34))
                    .foregroundStyle(.white)

                Text("One order, one screen, full clarity")
                    .font(.custom("AvenirNext-Regular", size: 15))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    showCurrencySheet = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.06, green: 0.14, blue: 0.2))
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(.plain)

                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(red: 0.06, green: 0.14, blue: 0.2))
                        .frame(width: 46, height: 46)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .shadow(color: .black.opacity(0.2), radius: 12, y: 8)
        }
        .frostedCard(cornerRadius: 30)
    }

    private var statsView: some View {
        HStack(spacing: 12) {
            statCard(title: "Active", value: "\(activeCount)", tint: Color(red: 0.36, green: 0.74, blue: 1.0))
            statCard(title: "Completed", value: "\(completedCount)", tint: Color(red: 0.50, green: 0.86, blue: 0.49))
            statCard(title: "Total", value: "\(store.orders.count)", tint: Color(red: 0.98, green: 0.69, blue: 0.26))
        }
    }

    @ViewBuilder
    private func statCard(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("AvenirNext-Regular", size: 13))
                .foregroundStyle(AppTheme.secondaryText)

            Text(value)
                .font(.custom("AvenirNext-Bold", size: 25))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.32), lineWidth: 1)
        )
    }

    private var searchView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.secondaryText)
            TextField(
                "Search by client, job or address",
                text: $query,
                prompt: Text("Search by client, job or address").foregroundColor(Color.white.opacity(0.45))
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

    private var filterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(OrderScreenFilter.allCases) { filter in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                            selectedFilter = filter
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(filter.rawValue)
                                .font(.custom("AvenirNext-DemiBold", size: 13))
                            Text("\(count(for: filter))")
                                .font(.custom("AvenirNext-Bold", size: 12))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.16), in: Capsule(style: .continuous))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(
                            Capsule(style: .continuous)
                                .fill(selectedFilter == filter ? Color.white.opacity(0.24) : Color.white.opacity(0.12))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(selectedFilter == filter ? 0.35 : 0.16), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.75))

            Text("No orders found")
                .font(.custom("AvenirNext-DemiBold", size: 20))
                .foregroundStyle(.white)

            Text("Try changing your search or create a fresh order.")
                .font(.custom("AvenirNext-Regular", size: 14))
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button("Create Order") {
                showCreateSheet = true
            }
            .font(.custom("AvenirNext-DemiBold", size: 15))
            .foregroundStyle(Color(red: 0.06, green: 0.14, blue: 0.2))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white, in: Capsule(style: .continuous))
        }
        .frostedCard(cornerRadius: 24)
    }

    @ViewBuilder
    private func statusActions(for order: WorkOrder) -> some View {
        ForEach(OrderStatus.allCases) { status in
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.88)) {
                    store.updateOrderStatus(id: order.id, to: status)
                }
            } label: {
                Label(status.rawValue, systemImage: status.symbol)
            }
            .disabled(order.status == status)
        }
    }

    private func count(for filter: OrderScreenFilter) -> Int {
        guard let status = filter.status else {
            return store.orders.count
        }
        return store.orders.filter { $0.status == status }.count
    }
}

struct OrdersDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersDashboardView(store: OrdersStore())
    }
}
