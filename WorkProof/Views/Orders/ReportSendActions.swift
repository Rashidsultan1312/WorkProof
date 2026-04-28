import SwiftUI

struct ReportSendActions: View {
    let reportText: String

    @Environment(\.openURL) private var openURL
    @State private var showShareSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Send Report")
                .font(.custom("AvenirNext-DemiBold", size: 16))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                channelButton(title: "WhatsApp", icon: "message.fill", tint: Color(red: 0.29, green: 0.82, blue: 0.41)) {
                    openChannel(urlString: "whatsapp://send?text=\(encodedText)")
                }

                channelButton(title: "Telegram", icon: "paperplane.fill", tint: Color(red: 0.29, green: 0.70, blue: 0.98)) {
                    openChannel(urlString: "tg://msg?text=\(encodedText)")
                }

                channelButton(title: "Email", icon: "envelope.fill", tint: Color(red: 0.93, green: 0.53, blue: 0.27)) {
                    openChannel(urlString: "mailto:?subject=WorkProof%20Report&body=\(encodedText)")
                }
            }

            Button {
                showShareSheet = true
            } label: {
                Label("Open Share Sheet", systemImage: "square.and.arrow.up")
                    .font(.custom("AvenirNext-DemiBold", size: 14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(items: [reportText])
        }
    }

    private var encodedText: String {
        reportText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    @ViewBuilder
    private func channelButton(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.custom("AvenirNext-DemiBold", size: 12))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(tint.opacity(0.25), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(tint.opacity(0.45), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func openChannel(urlString: String) {
        guard let url = URL(string: urlString) else {
            showShareSheet = true
            return
        }

        openURL(url) { accepted in
            if accepted == false {
                showShareSheet = true
            }
        }
    }
}
