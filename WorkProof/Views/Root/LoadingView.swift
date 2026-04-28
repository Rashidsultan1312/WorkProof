import SwiftUI

struct LoadingView: View {
    @State private var rotate = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.14))
                .frame(width: pulse ? 250 : 180, height: pulse ? 250 : 180)
                .blur(radius: 24)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 14)
                        .frame(width: 98, height: 98)

                    Circle()
                        .trim(from: 0.1, to: 0.85)
                        .stroke(AppTheme.accentGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 98, height: 98)
                        .rotationEffect(.degrees(rotate ? 360 : 0))
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: rotate)

                    Image(systemName: "wrench.adjustable.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("Preparing your workspace")
                    .font(.custom("AvenirNext-DemiBold", size: 22))
                    .foregroundStyle(.white)

                Text("Collecting orders, history and tools")
                    .font(.custom("AvenirNext-Regular", size: 15))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            rotate = true
            pulse = true
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
