import SwiftUI
import AVKit

struct VideoPlayerView: View {
    private let player: AVPlayer?
    private let viewModel = VideoPlayerViewModel()

    init(videoName: String, fileExtension: String) {
        self.player = viewModel.createPlayer(forResource: videoName, withExtension: fileExtension)
    }

    var body: some View {
        VStack {
            if let player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                        viewModel.setupLoop(for: player)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 145, height: 145)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(.white)
                Text("Video tutorial")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .center)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .overlay(
            Color.black.opacity(0.01)
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .center)
        )
    }
}

#Preview {
    VideoPlayerView(videoName: "bicep-curl-video", fileExtension: "mp4")
}
