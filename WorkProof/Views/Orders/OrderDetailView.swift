import SwiftUI

struct OrderDetailView: View {
    @ObservedObject var store: OrdersStore
    let orderID: UUID

    var body: some View {
        Group {
            if let orderBinding {
                OrderDetailContent(order: orderBinding, store: store)
            } else {
                ZStack {
                    AppTheme.pageGradient.ignoresSafeArea()
                    Text("Order was not found")
                        .font(.custom("AvenirNext-DemiBold", size: 20))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var orderBinding: Binding<WorkOrder>? {
        guard let index = store.orders.firstIndex(where: { $0.id == orderID }) else {
            return nil
        }

        return $store.orders[index]
    }
}

private struct OrderDetailContent: View {
    @Binding var order: WorkOrder
    @ObservedObject var store: OrdersStore

    @AppStorage(CurrencySettings.storageKey) private var selectedCurrencyCode = CurrencySettings.defaultCode
    @State private var manualActionText = ""
    @State private var laborInput = ""
    @State private var materialsInput = ""
    @State private var showReportSheet = false
    @State private var now = Date.now

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let quickTemplates: [String] = [
        "Replaced pipe",
        "Cleaned filter",
        "Adjusted pressure",
        "Installed valve",
        "Checked leak points"
    ]

    private var history: [WorkOrder] {
        store.clientHistory(for: order)
    }

    var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    headerCard
                    statusCard
                    photosCard
                    actionsCard
                    costsCard
                    timerCard
                    historyCard
                    reportCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReportSheet) {
            ReportPreviewSheet(order: order, history: history)
        }
        .onAppear {
            laborInput = order.laborCost > 0 ? String(format: "%.0f", order.laborCost) : ""
            materialsInput = order.materialsCost > 0 ? String(format: "%.0f", order.materialsCost) : ""
        }
        .onChange(of: laborInput) { _ in
            applyCostChanges()
        }
        .onChange(of: materialsInput) { _ in
            applyCostChanges()
        }
        .onReceive(ticker) { date in
            now = date
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(order.clientName)
                .font(.custom("AvenirNext-Bold", size: 30))
                .foregroundStyle(.white)

            Text(order.jobType)
                .font(.custom("AvenirNext-Regular", size: 17))
                .foregroundStyle(AppTheme.secondaryText)

            if order.address.isEmpty == false {
                Label(order.address, systemImage: "mappin.and.ellipse")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            HStack(spacing: 14) {
                metric(title: "Created", value: AppFormatters.shortDate.string(from: order.createdAt))
                metric(title: "Updated", value: AppFormatters.shortTime.string(from: order.updatedAt))
            }
        }
        .frostedCard(cornerRadius: 24)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Status")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(OrderStatus.allCases) { status in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                order.setStatus(status)
                            }
                        } label: {
                            StatusChip(status: status, isSelected: order.status == status)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frostedCard(cornerRadius: 22)
    }

    private var photosCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Smart Work Capture")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            ForEach(PhotoStage.allCases) { stage in
                PhotoStageCard(stage: stage, photos: order.photos.filter { $0.stage == stage }) { data in
                    let optimizedData = ImageOptimizationService.optimizedImageData(from: data)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        order.addPhoto(stage: stage, imageData: optimizedData)
                    }
                } onDeletePhoto: { photoID in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        order.removePhoto(id: photoID)
                    }
                }
            }
        }
        .frostedCard(cornerRadius: 22)
    }

    private var actionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mini Work Log")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickTemplates, id: \.self) { template in
                        Button(template) {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                order.addAction(text: template)
                            }
                        }
                        .font(.custom("AvenirNext-DemiBold", size: 13))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(AppTheme.strongCardBackground, in: Capsule(style: .continuous))
                    }
                }
            }

            HStack(spacing: 10) {
                TextField(
                    "Add custom action",
                    text: $manualActionText,
                    prompt: Text("Describe what was done").foregroundColor(Color.white.opacity(0.44))
                )
                .font(.custom("AvenirNext-Regular", size: 15))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button(action: addManualAction) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.06, green: 0.14, blue: 0.2))
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                }
                .buttonStyle(.plain)
            }

            if order.actions.isEmpty {
                Text("No actions yet. Tap a template to add one instantly.")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.top, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(order.actions) { action in
                        HStack(alignment: .top, spacing: 9) {
                            Circle()
                                .fill(Color.white.opacity(0.75))
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(action.text)
                                    .font(.custom("AvenirNext-DemiBold", size: 14))
                                    .foregroundStyle(.white)
                                Text(AppFormatters.shortDateTime.string(from: action.timestamp))
                                    .font(.custom("AvenirNext-Regular", size: 12))
                                    .foregroundStyle(AppTheme.secondaryText)
                            }

                            Spacer()
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                    order.removeAction(id: action.id)
                                }
                            } label: {
                                Label("Delete Action", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .frostedCard(cornerRadius: 22)
    }

    private var costsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                priceField(title: "Labor", text: $laborInput)
                priceField(title: "Materials", text: $materialsInput)
            }

            HStack {
                Text("Total")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundStyle(AppTheme.secondaryText)

                Spacer()

                Text(ReportComposer.formattedMoney(order.totalCost, currencyCode: selectedCurrencyCode))
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundStyle(.white)
            }
            .padding(.top, 2)
        }
        .frostedCard(cornerRadius: 22)
    }

    private var timerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Timer")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            Text(ReportComposer.formattedDuration(order.elapsedTime(reference: now)))
                .font(.custom("AvenirNext-Bold", size: 32))
                .foregroundStyle(.white)

            Button(order.isTimerRunning ? "Stop" : "Start") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    if order.isTimerRunning {
                        order.stopTimer()
                    } else {
                        order.startTimer()
                    }
                }
            }
            .font(.custom("AvenirNext-DemiBold", size: 16))
            .foregroundStyle(Color(red: 0.06, green: 0.14, blue: 0.2))
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color.white, in: Capsule(style: .continuous))
        }
        .frostedCard(cornerRadius: 22)
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Client History")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            if history.isEmpty {
                Text("No previous jobs for this client yet.")
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundStyle(AppTheme.secondaryText)
            } else {
                ForEach(history.prefix(3)) { previous in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(previous.jobType)
                            .font(.custom("AvenirNext-DemiBold", size: 14))
                            .foregroundStyle(.white)
                        Text(AppFormatters.shortDate.string(from: previous.createdAt))
                            .font(.custom("AvenirNext-Regular", size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .frostedCard(cornerRadius: 22)
    }

    private var reportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Report")
                .font(.custom("AvenirNext-DemiBold", size: 18))
                .foregroundStyle(.white)

            Text("Generate one consistent report with photos, actions, date, price and time.")
                .font(.custom("AvenirNext-Regular", size: 14))
                .foregroundStyle(AppTheme.secondaryText)

            Button {
                showReportSheet = true
            } label: {
                HStack {
                    Text("Generate Report")
                    Spacer()
                    Image(systemName: "arrow.up.right.circle.fill")
                }
                .font(.custom("AvenirNext-DemiBold", size: 15))
                .foregroundStyle(Color(red: 0.06, green: 0.14, blue: 0.2))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .frostedCard(cornerRadius: 22)
    }

    @ViewBuilder
    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("AvenirNext-Regular", size: 12))
                .foregroundStyle(AppTheme.secondaryText)
            Text(value)
                .font(.custom("AvenirNext-DemiBold", size: 13))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private func priceField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("AvenirNext-Regular", size: 13))
                .foregroundStyle(AppTheme.secondaryText)

            HStack {
                Text(currencySymbol)
                    .font(.custom("AvenirNext-DemiBold", size: 16))
                    .foregroundStyle(.white)
                TextField("0", text: text)
                    .keyboardType(.decimalPad)
                    .font(.custom("AvenirNext-DemiBold", size: 17))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func addManualAction() {
        let trimmed = manualActionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
            order.addAction(text: trimmed)
        }
        manualActionText = ""
    }

    private func applyCostChanges() {
        let laborValue = parseAmount(laborInput)
        let materialsValue = parseAmount(materialsInput)
        order.setCosts(labor: laborValue, materials: materialsValue)
    }

    private func parseAmount(_ value: String) -> Double {
        let normalized = value
            .replacingOccurrences(of: ",", with: ".")
            .filter { "0123456789.".contains($0) }
        return Double(normalized) ?? 0
    }

    private var currencySymbol: String {
        CurrencyOption(rawValue: selectedCurrencyCode)?.symbol ?? CurrencyOption.rub.symbol
    }
}

struct OrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrderDetailView(store: OrdersStore(), orderID: WorkOrder.sampleOrders[0].id)
        }
    }
}
