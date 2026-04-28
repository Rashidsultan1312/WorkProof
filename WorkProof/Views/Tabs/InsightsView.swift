import SwiftUI

struct InsightsView: View {
    @ObservedObject var store: OrdersStore
    @AppStorage(CurrencySettings.storageKey) private var selectedCurrencyCode = CurrencySettings.defaultCode
    @State private var showCurrencySheet = false

    private var totalRevenue: Double {
        store.orders.reduce(0) { $0 + $1.totalCost }
    }

    private var totalLabor: Double {
        store.orders.reduce(0) { $0 + $1.laborCost }
    }

    private var totalMaterials: Double {
        store.orders.reduce(0) { $0 + $1.materialsCost }
    }

    private var totalTrackedTime: TimeInterval {
        store.orders.reduce(0) { $0 + $1.elapsedTime() }
    }

    private var averageTime: TimeInterval {
        guard store.orders.isEmpty == false else { return 0 }
        return totalTrackedTime / Double(store.orders.count)
    }

    private var totalPhotos: Int {
        store.orders.reduce(0) { $0 + $1.photos.count }
    }

    private var statusItems: [(status: OrderStatus, count: Int)] {
        OrderStatus.allCases.map { status in
            (status, store.orders.filter { $0.status == status }.count)
        }
    }

    private var maxStatusCount: Int {
        statusItems.map(\.count).max() ?? 0
    }

    private var topJobType: String {
        let grouped = Dictionary(grouping: store.orders, by: { $0.jobType })
        return grouped.max(by: { $0.value.count < $1.value.count })?.key ?? "No data yet"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageGradient
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        headerCard
                        totalsCard
                        timeAndPhotosCard
                        topJobCard
                        statusCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showCurrencySheet) {
            CurrencySettingsSheet()
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Insights")
                        .font(.custom("AvenirNext-Bold", size: 30))
                        .foregroundStyle(.white)

                    Text("Live overview of performance, workload and results.")
                        .font(.custom("AvenirNext-Regular", size: 15))
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                Button {
                    showCurrencySheet = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(red: 0.06, green: 0.14, blue: 0.2))
                        .frame(width: 36, height: 36)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(.plain)
            }

            Text("Currency: \(selectedCurrencyCode)")
                .font(.custom("AvenirNext-DemiBold", size: 13))
                .foregroundStyle(Color.white.opacity(0.78))
        }
        .frostedCard(cornerRadius: 26)
    }

    private var totalsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Revenue")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            Text(ReportComposer.formattedMoney(totalRevenue, currencyCode: selectedCurrencyCode))
                .font(.custom("AvenirNext-Bold", size: 32))
                .foregroundStyle(.white)

            moneyRow(title: "Labor", value: totalLabor, tint: Color(red: 0.36, green: 0.74, blue: 1.0))
            moneyRow(title: "Materials", value: totalMaterials, tint: Color(red: 0.98, green: 0.69, blue: 0.26))
        }
        .frostedCard(cornerRadius: 24)
    }

    private var timeAndPhotosCard: some View {
        VStack(spacing: 10) {
            metricCard(
                title: "Avg Time / Order",
                value: ReportComposer.formattedDuration(averageTime),
                icon: "timer"
            )

            metricCard(
                title: "Captured Photos",
                value: "\(totalPhotos)",
                icon: "camera.fill"
            )
        }
    }

    private var topJobCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Most Frequent Job Type")
                .font(.custom("AvenirNext-Regular", size: 14))
                .foregroundStyle(AppTheme.secondaryText)

            Text(topJobType)
                .font(.custom("AvenirNext-Bold", size: 22))
                .foregroundStyle(.white)
        }
        .frostedCard(cornerRadius: 20)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Distribution")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            ForEach(statusItems, id: \.status.id) { item in
                statusRow(status: item.status, count: item.count)
            }
        }
        .frostedCard(cornerRadius: 24)
    }

    @ViewBuilder
    private func statusRow(status: OrderStatus, count: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(status.rawValue, systemImage: status.symbol)
                    .font(.custom("AvenirNext-DemiBold", size: 13))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(count)")
                    .font(.custom("AvenirNext-DemiBold", size: 13))
                    .foregroundStyle(.white)
            }

            GeometryReader { proxy in
                let ratio = maxStatusCount == 0 ? 0 : CGFloat(count) / CGFloat(maxStatusCount)
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 8)

                    Capsule(style: .continuous)
                        .fill(status.color)
                        .frame(width: max(8, proxy.size.width * ratio), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    @ViewBuilder
    private func moneyRow(title: String, value: Double, tint: Color) -> some View {
        HStack {
            Text(title)
                .font(.custom("AvenirNext-Regular", size: 14))
                .foregroundStyle(Color.white.opacity(0.8))

            Spacer()

            Text(ReportComposer.formattedMoney(value, currencyCode: selectedCurrencyCode))
                .font(.custom("AvenirNext-DemiBold", size: 16))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(tint.opacity(0.22), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func metricCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.custom("AvenirNext-Regular", size: 12))
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(1)

            Text(value)
                .font(.custom("AvenirNext-Bold", size: 22))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frostedCard(cornerRadius: 20)
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView(store: OrdersStore())
    }
}
