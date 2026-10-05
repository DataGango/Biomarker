import AVFoundation
import Foundation

let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let topic = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "childhood-cancer"
let videoURL = root.appendingPathComponent("\(topic)-video-only.m4v")
let audioURL = root.appendingPathComponent("\(topic)-narration.m4a")
let outputURL = root.appendingPathComponent("\(topic)-short.mp4")
try? FileManager.default.removeItem(at: outputURL)
let videoAsset = AVURLAsset(url: videoURL)
let audioAsset = AVURLAsset(url: audioURL)
let composition = AVMutableComposition()
guard let videoSource = videoAsset.tracks(withMediaType: .video).first,
      let audioSource = audioAsset.tracks(withMediaType: .audio).first,
      let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
      let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    fputs("Could not read video/audio tracks\n", stderr)
    exit(1)
}
let duration = videoAsset.duration
try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: videoSource, at: .zero)
let audioDuration = min(audioAsset.duration, duration)
try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: audioDuration), of: audioSource, at: .zero)
guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough) else {
    fputs("Could not create export session\n", stderr)
    exit(1)
}
exporter.outputURL = outputURL
exporter.outputFileType = .mp4
let semaphore = DispatchSemaphore(value: 0)
exporter.exportAsynchronously { semaphore.signal() }
semaphore.wait()
if exporter.status != .completed {
    fputs("Audio mux failed: \(String(describing: exporter.error))\n", stderr)
    exit(1)
}
print("Muxed narrated video: \(outputURL.path)")
