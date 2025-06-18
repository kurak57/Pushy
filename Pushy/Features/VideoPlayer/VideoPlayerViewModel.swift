import Foundation
import AVFoundation

struct VideoPlayerViewModel {
    func createPlayer(forResource name: String, withExtension ext: String) -> AVPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("⚠️ Video not found: \(name).\(ext)")
            return nil
        }
        return AVPlayer(url: url)
    }

    func setupLoop(for player: AVPlayer) {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
    }
}
