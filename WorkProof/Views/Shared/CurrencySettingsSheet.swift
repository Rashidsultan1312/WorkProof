import SwiftUI

struct CurrencySettingsSheet: View {
    @AppStorage(CurrencySettings.storageKey) private var selectedCurrencyCode = CurrencySettings.defaultCode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageGradient
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Currency")
                                .font(.custom("AvenirNext-Bold", size: 30))
                                .foregroundStyle(.white)

                            Text("Choose how all prices and reports are displayed.")
                                .font(.custom("AvenirNext-Regular", size: 15))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .frostedCard(cornerRadius: 24)

                        VStack(spacing: 10) {
                            ForEach(CurrencyOption.allCases) { option in
                                currencyRow(option)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Settings")
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

    @ViewBuilder
    private func currencyRow(_ option: CurrencyOption) -> some View {
        Button {
            selectedCurrencyCode = option.rawValue
        } label: {
            HStack(spacing: 12) {
                Text(option.symbol)
                    .font(.custom("AvenirNext-Bold", size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.rawValue)
                        .font(.custom("AvenirNext-DemiBold", size: 16))
                        .foregroundStyle(.white)

                    Text(option.title)
                        .font(.custom("AvenirNext-Regular", size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                Image(systemName: selectedCurrencyCode == option.rawValue ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(selectedCurrencyCode == option.rawValue ? Color(red: 0.31, green: 0.91, blue: 0.85) : Color.white.opacity(0.34))
            }
            .padding(14)
            .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(selectedCurrencyCode == option.rawValue ? 0.35 : 0.13), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CurrencySettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySettingsSheet()
    }
}
