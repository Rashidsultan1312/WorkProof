import SwiftUI

struct NewOrderSheet: View {
    @ObservedObject var store: OrdersStore
    @Environment(\.dismiss) private var dismiss

    @State private var clientName = ""
    @State private var address = ""
    @State private var jobType = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Create New Order")
                            .font(.custom("AvenirNext-Bold", size: 30))
                            .foregroundStyle(.white)

                        formField(title: "Client Name", text: $clientName, prompt: "John Appleseed")
                        formField(title: "Address (optional)", text: $address, prompt: "221B Baker Street")
                        formField(title: "Job Type", text: $jobType, prompt: "Boiler repair")

                        Button(action: createOrder) {
                            Text("Save Order")
                                .font(.custom("AvenirNext-DemiBold", size: 18))
                                .foregroundStyle(Color(red: 0.06, green: 0.14, blue: 0.2))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(isSaveDisabled)
                        .opacity(isSaveDisabled ? 0.45 : 1)

                        Text("Tip: keep job type specific, so reports stay clear for repeat clients.")
                            .font(.custom("AvenirNext-Regular", size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }

    private var isSaveDisabled: Bool {
        clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        jobType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    private func formField(title: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.custom("AvenirNext-DemiBold", size: 15))
                .foregroundStyle(.white)

            TextField("", text: text, prompt: Text(prompt).foregroundColor(Color.white.opacity(0.45)))
                .font(.custom("AvenirNext-Regular", size: 16))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppTheme.strongCardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }

    private func createOrder() {
        store.createOrder(clientName: clientName, address: address, jobType: jobType)
        dismiss()
    }
}

struct NewOrderSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewOrderSheet(store: OrdersStore())
    }
}
