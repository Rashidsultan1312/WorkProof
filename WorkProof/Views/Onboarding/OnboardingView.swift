import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var selectedIndex = 0
    @State private var reveal = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "One Job. One Screen.",
            subtitle: "Open an order and keep photos, actions, costs and status in one place.",
            icon: "rectangle.stack.fill.badge.person.crop",
            color: Color(red: 0.31, green: 0.91, blue: 0.85)
        ),
        OnboardingPage(
            title: "Capture Work Proof",
            subtitle: "Add before, in-progress and after photos with automatic time labels.",
            icon: "camera.aperture",
            color: Color(red: 0.36, green: 0.74, blue: 1.0)
        ),
        OnboardingPage(
            title: "Share Clear Reports",
            subtitle: "Generate a polished report and send it through WhatsApp, Telegram or Email.",
            icon: "paperplane.circle.fill",
            color: Color(red: 0.50, green: 0.86, blue: 0.49)
        )
    ]

    var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            VStack(spacing: 28) {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageView(page)
                            .tag(index)
                            .padding(.horizontal, 24)
                            .opacity(reveal ? 1 : 0.2)
                            .scaleEffect(reveal ? 1 : 0.92)
                            .animation(.spring(response: 0.55, dampingFraction: 0.82), value: reveal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: 520)

                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule(style: .continuous)
                            .fill(index == selectedIndex ? Color.white : Color.white.opacity(0.28))
                            .frame(width: index == selectedIndex ? 26 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.25), value: selectedIndex)
                    }
                }

                Button(action: nextTap) {
                    Text(selectedIndex == pages.count - 1 ? "Start Working" : "Continue")
                        .font(.custom("AvenirNext-DemiBold", size: 18))
                        .foregroundStyle(Color(red: 0.06, green: 0.14, blue: 0.2))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .padding(.top, 36)
        }
        .onAppear {
            reveal = true
        }
    }

    @ViewBuilder
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.22))
                    .frame(width: 180, height: 180)
                    .blur(radius: 6)

                Image(systemName: page.icon)
                    .font(.system(size: 66, weight: .bold))
                    .foregroundStyle(page.color)
            }

            Text(page.title)
                .font(.custom("AvenirNext-Bold", size: 34))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(.custom("AvenirNext-Regular", size: 18))
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)
        }
        .frostedCard(cornerRadius: 30)
    }

    private func nextTap() {
        if selectedIndex < pages.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                selectedIndex += 1
            }
        } else {
            onFinish()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onFinish: {})
    }
}
