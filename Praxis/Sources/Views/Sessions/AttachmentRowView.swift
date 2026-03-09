import SwiftUI
import AVFoundation

struct AttachmentRowView: View {
    let attachment: Attachment
    @State private var showingImage = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioDelegate: AudioPlayerDelegate?
    @State private var isPlaying = false

    var body: some View {
        Button {
            if attachment.type == .image {
                showingImage = true
            } else {
                togglePlayback()
            }
        } label: {
            HStack {
                Image(systemName: iconName)
                    .foregroundStyle(isPlaying ? .red : .accent)

                VStack(alignment: .leading) {
                    Text(attachment.type == .image ? "Image" : "Voice Note")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(attachment.createdAt, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if attachment.type == .image {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.caption)
                        .foregroundStyle(.accent)
                }
            }
        }
        .fullScreenCover(isPresented: $showingImage) {
            ImageViewerView(data: attachment.data)
        }
    }

    private var iconName: String {
        if attachment.type == .image {
            return "photo"
        }
        return isPlaying ? "waveform" : "waveform"
    }

    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.stop()
            audioPlayer = nil
            audioDelegate = nil
            isPlaying = false
        } else {
            do {
                let player = try AVAudioPlayer(data: attachment.data)
                let delegate = AudioPlayerDelegate {
                    isPlaying = false
                    audioPlayer = nil
                    audioDelegate = nil
                }
                player.delegate = delegate
                audioDelegate = delegate
                audioPlayer = player
                player.play()
                isPlaying = true
            } catch {
                print("Failed to play audio: \(error)")
            }
        }
    }
}

// MARK: - Image Viewer

struct ImageViewerView: View {
    let data: Data
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero

    private var currentOffset: CGSize {
        CGSize(
            width: offset.width + dragOffset.width,
            height: offset.height + dragOffset.height
        )
    }

    private var opacity: Double {
        guard scale <= 1.0 else { return 1.0 }
        let progress = abs(dragOffset.height) / 300.0
        return max(1.0 - progress, 0.3)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(opacity).ignoresSafeArea()

            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(currentOffset)
                    .gesture(magnification)
                    .gesture(drag)
                    .onTapGesture(count: 2) {
                        withAnimation(.spring) {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                                offset = .zero
                            } else {
                                scale = 3.0
                                lastScale = 3.0
                            }
                        }
                    }
            } else {
                ContentUnavailableView("Unable to load image", systemImage: "photo")
            }

            // Close button
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .white.opacity(0.3))
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }

    private var magnification: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                scale = max(lastScale * value.magnification, 0.5)
            }
            .onEnded { value in
                lastScale = scale
                if scale < 1.0 {
                    withAnimation(.spring) {
                        scale = 1.0
                        lastScale = 1.0
                        offset = .zero
                    }
                }
            }
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                // If zoomed out and dragged down enough, dismiss
                if scale <= 1.0 && abs(value.translation.height) > 150 {
                    dismiss()
                } else {
                    if scale > 1.0 {
                        offset = currentOffset
                    }
                    withAnimation(.spring) {
                        dragOffset = .zero
                    }
                }
            }
    }
}

// MARK: - Audio Player Delegate

final class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [self] in
            onFinish()
        }
    }
}
