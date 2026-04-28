import SwiftUI

struct ReportPreviewSheet: View {
    let order: WorkOrder
    let history: [WorkOrder]

    @AppStorage(CurrencySettings.storageKey) private var selectedCurrencyCode = CurrencySettings.defaultCode
    @Environment(\.dismiss) private var dismiss

    private var reportText: String {
        ReportComposer.reportText(for: order, history: history, currencyCode: selectedCurrencyCode)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageGradient
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        summaryCard
                        actionsCard
                        totalsCard
                        ReportSendActions(reportText: reportText)
                            .frostedCard(cornerRadius: 20)

                        Text(reportText)
                            .font(.custom("AvenirNext-Regular", size: 13))
                            .foregroundStyle(Color.white.opacity(0.86))
                            .lineSpacing(3)
                            .frostedCard(cornerRadius: 20)
                    }
                    .padding(16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Generated Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(order.clientName)
                .font(.custom("AvenirNext-Bold", size: 24))
                .foregroundStyle(.white)

            Text(order.jobType)
                .font(.custom("AvenirNext-Regular", size: 15))
                .foregroundStyle(AppTheme.secondaryText)

            HStack(spacing: 10) {
                photoMetric(title: "Before", value: "\(order.photos.filter { $0.stage == .before }.count)")
                photoMetric(title: "In Progress", value: "\(order.photos.filter { $0.stage == .inProgress }.count)")
                photoMetric(title: "After", value: "\(order.photos.filter { $0.stage == .after }.count)")
            }
        }
        .frostedCard(cornerRadius: 22)
    }

    private var actionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Work Log")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            if order.actions.isEmpty {
                Text("No actions were added.")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundStyle(AppTheme.secondaryText)
            } else {
                ForEach(order.actions) { action in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(action.text)
                                .font(.custom("AvenirNext-DemiBold", size: 14))
                                .foregroundStyle(.white)
                            Text(AppFormatters.shortDateTime.string(from: action.timestamp))
                                .font(.custom("AvenirNext-Regular", size: 12))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                }
            }
        }
        .frostedCard(cornerRadius: 22)
    }

    private var totalsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Price & Time")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            metricRow(title: "Labor", value: ReportComposer.formattedMoney(order.laborCost, currencyCode: selectedCurrencyCode))
            metricRow(title: "Materials", value: ReportComposer.formattedMoney(order.materialsCost, currencyCode: selectedCurrencyCode))
            metricRow(title: "Total", value: ReportComposer.formattedMoney(order.totalCost, currencyCode: selectedCurrencyCode))
            metricRow(title: "Spent", value: ReportComposer.formattedDuration(order.elapsedTime()))

            if history.isEmpty == false {
                Text("Client has \(history.count) previous order(s)")
                    .font(.custom("AvenirNext-Regular", size: 13))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .frostedCard(cornerRadius: 22)
    }

    @ViewBuilder
    private func metricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("AvenirNext-Regular", size: 14))
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.custom("AvenirNext-DemiBold", size: 14))
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private func photoMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("AvenirNext-Regular", size: 12))
                .foregroundStyle(AppTheme.secondaryText)
            Text(value)
                .font(.custom("AvenirNext-Bold", size: 20))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct ReportPreviewSheet_Previews: PreviewProvider {
    static var previews: some View {
        ReportPreviewSheet(order: WorkOrder.sampleOrders[0], history: [WorkOrder.sampleOrders[1]])
    }
}
