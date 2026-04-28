import PhotosUI
import SwiftUI

struct PhotoStageCard: View {
    let stage: PhotoStage
    let photos: [WorkPhoto]
    let onAddPhoto: (Data) -> Void
    let onDeletePhoto: (UUID) -> Void

    @State private var pickedItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(stage.rawValue)
                    .font(.custom("AvenirNext-DemiBold", size: 15))
                    .foregroundStyle(.white)

                Spacer()

                PhotosPicker(selection: $pickedItem, matching: .images) {
                    HStack(spacing: 6) {
                        Image(systemName: "camera.fill")
                        Text("Add")
                    }
                    .font(.custom("AvenirNext-DemiBold", size: 13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppTheme.strongCardBackground, in: Capsule(style: .continuous))
                }
            }

            if photos.isEmpty {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 110)
                    .overlay {
                        Text("No \(stage.rawValue.lowercased()) photos yet")
                            .font(.custom("AvenirNext-Regular", size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(photos) { photo in
                            photoItem(photo)
                        }
                    }
                }
            }
        }
        .onChange(of: pickedItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        onAddPhoto(data)
                    }
                }
                await MainActor.run {
                    pickedItem = nil
                }
            }
        }
    }

    @ViewBuilder
    private func photoItem(_ photo: WorkPhoto) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let image = UIImage(data: photo.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 126, height: 126)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 126, height: 126)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(photo.stage.rawValue)
                    .font(.custom("AvenirNext-DemiBold", size: 11))
                    .foregroundStyle(.white)
                Text(AppFormatters.shortDateTime.string(from: photo.timestamp))
                    .font(.custom("AvenirNext-Regular", size: 10))
                    .foregroundStyle(Color.white.opacity(0.88))
                    .lineLimit(1)
            }
            .padding(7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(7)
        }
        .frame(width: 126, height: 126)
        .contextMenu {
            Button(role: .destructive) {
                onDeletePhoto(photo.id)
            } label: {
                Label("Delete Photo", systemImage: "trash")
            }
        }
    }
}

struct PhotoStageCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppTheme.pageGradient.ignoresSafeArea()
            PhotoStageCard(stage: .before, photos: [], onAddPhoto: { _ in }, onDeletePhoto: { _ in })
                .padding()
        }
    }
}
