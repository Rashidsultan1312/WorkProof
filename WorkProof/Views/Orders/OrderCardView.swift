import SwiftUI

struct OrderCardView: View {
    let order: WorkOrder
    @AppStorage(CurrencySettings.storageKey) private var selectedCurrencyCode = CurrencySettings.defaultCode

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.clientName)
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundStyle(AppTheme.primaryText)

                    Text(order.jobType)
                        .font(.custom("AvenirNext-Regular", size: 15))
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer(minLength: 8)
                StatusChip(status: order.status)
            }

            if order.address.isEmpty == false {
                Label(order.address, systemImage: "mappin.and.ellipse")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            HStack {
                metricTile(title: "Updated", value: AppFormatters.shortTime.string(from: order.updatedAt), icon: "clock")
                metricTile(title: "Total", value: ReportComposer.formattedMoney(order.totalCost, currencyCode: selectedCurrencyCode), icon: "creditcard.fill")
                metricTile(title: "Time", value: ReportComposer.formattedDuration(order.elapsedTime()), icon: "timer")
            }

            HStack(spacing: 7) {
                Image(systemName: "chevron.right.circle.fill")
                Text("Open order")
                    .font(.custom("AvenirNext-DemiBold", size: 15))
            }
            .foregroundStyle(Color.white.opacity(0.84))
        }
        .frostedCard(cornerRadius: 28)
    }

    @ViewBuilder
    private func metricTile(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: icon)
                .font(.custom("AvenirNext-Regular", size: 12))
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(1)

            Text(value)
                .font(.custom("AvenirNext-DemiBold", size: 13))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct OrderCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppTheme.pageGradient.ignoresSafeArea()
            OrderCardView(order: WorkOrder.sampleOrders[0])
                .padding()
        }
    }
}
