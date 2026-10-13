import AVFoundation
import AppKit
import CoreText
import CoreVideo
import ImageIO

let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let topic = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "childhood-cancer"
let silentMovie = root.appendingPathComponent("\(topic)-silent.mov")
let imageName = topic == "age-groups" ? "age-groups-poster.png" : "childhood-cancer-hope-progress.png"
let imageURL = root.appendingPathComponent(imageName)
let width = 1080
let height = 1920
let fps: Int32 = 12
let scenes: [(String, String, String, Double, CGColor)] = [
    ("A FAMILY-CENTERED RESEARCH SHORT", "Childhood cancer,\nin context.", "Every diagnosis is different. Every child deserves care shaped around their needs.", 6.0, CGColor(red: 0.075, green: 0.20, blue: 0.18, alpha: 1)),
    ("THE U.S. PICTURE · NCI ESTIMATE", "14,910", "Estimated cancer diagnoses among people ages 0–19 in the United States in 2024. An estimate, not a final count.", 8.0, CGColor(red: 0.10, green: 0.31, blue: 0.27, alpha: 1)),
    ("OUTCOMES NEED CONTEXT", "One statistic\ncannot tell one story.", "Survival rates describe groups diagnosed in earlier years. Cancer type and clinical factors matter; population figures are not an individual prognosis.", 9.0, CGColor(red: 0.14, green: 0.25, blue: 0.34, alpha: 1)),
    ("INHERITED RISK · NCI ESTIMATE", "About 8–10%", "Inherited cancer-predisposition variants account for this estimated share of childhood cancers overall. The proportion varies by cancer type.", 8.0, CGColor(red: 0.33, green: 0.22, blue: 0.18, alpha: 1)),
    ("CARE IS A TEAM EFFORT", "Ask. Learn.\nStay supported.", "Talk with a pediatric oncology team about diagnosis, testing, treatment options, trials, family support, and follow-up after treatment.", 9.0, CGColor(red: 0.075, green: 0.20, blue: 0.18, alpha: 1)),
    ("RESEARCH · CARE · HOPE", "For families,\nwith facts.", "NCI: Cancer in Children and Adolescents. ACS: Childhood Leukemia Survival Rates; Genetics and Cancer Risk. Educational information, not medical advice.", 9.0, CGColor(red: 0.12, green: 0.23, blue: 0.30, alpha: 1))
]
let nanorobotScenes: [(String, String, String, Double, CGColor)] = [
    ("EMERGING RESEARCH · NOT A TREATMENT", "Tiny robots.\nBig questions.", "Researchers are studying whether micro- and nanorobots could guide medicine toward childhood tumors.", 7.0, CGColor(red: 0.075, green: 0.20, blue: 0.18, alpha: 1)),
    ("NEUROBLASTOMA · LAB STUDY", "Tested in vitro.", "A magnetic diatom microrobot carried drug formulations in laboratory experiments. This is not evidence of benefit in children.", 8.0, CGColor(red: 0.10, green: 0.31, blue: 0.27, alpha: 1)),
    ("RETINOBLASTOMA · BENCHTOP", "Navigation\nprototype.", "A microrobotic catheter was navigated in vascular phantoms. It was an engineering demonstration, not a treatment trial.", 8.0, CGColor(red: 0.14, green: 0.25, blue: 0.34, alpha: 1)),
    ("THE CLINICAL GAP", "Promising is not\nproven.", "The review did not identify an interventional pediatric cancer trial of the robotic platforms it examined.", 7.0, CGColor(red: 0.33, green: 0.22, blue: 0.18, alpha: 1)),
    ("WHAT RESEARCH MUST SHOW", "Guide. Track.\nClear safely.", "Studies must test added benefit, reliable imaging and navigation, safe material clearance, and reproducible manufacturing.", 7.0, CGColor(red: 0.075, green: 0.20, blue: 0.18, alpha: 1)),
    ("RESEARCH · NOT MEDICAL ADVICE", "Evidence first.", "Source: 2026 literature-based narrative review. Discuss treatment with a pediatric oncology team.", 7.0, CGColor(red: 0.12, green: 0.23, blue: 0.30, alpha: 1))
]
let ageGroupScenes: [(String, String, String, Double, CGColor)] = [
    ("CHILDHOOD CANCER · AGE-GROUP SNAPSHOT", "One number\ncan't tell every story.", "A different look at U.S. childhood and adolescent cancer estimates.", 6.0, CGColor(red: 0.06, green: 0.11, blue: 0.23, alpha: 1)),
    ("NCI ESTIMATE · UNITED STATES · 2024", "14,910", "Estimated cancer diagnoses among people ages 0 to 19. This is an estimate, not a final count.", 7.0, CGColor(red: 0.09, green: 0.17, blue: 0.34, alpha: 1)),
    ("CHILDREN · AGES 0–14", "9,620", "Estimated diagnoses among U.S. children ages 0 to 14 in 2024.", 7.0, CGColor(red: 0.12, green: 0.22, blue: 0.41, alpha: 1)),
    ("ADOLESCENTS · AGES 15–19", "5,290", "Estimated diagnoses among U.S. adolescents ages 15 to 19 in 2024.", 7.0, CGColor(red: 0.08, green: 0.28, blue: 0.34, alpha: 1)),
    ("CONTEXT MATTERS", "Population\nestimates aren't\npersonal predictions.", "Cancer types and care needs vary. Bring questions about diagnosis, tests, options, and follow-up to the pediatric oncology team.", 8.0, CGColor(red: 0.12, green: 0.18, blue: 0.35, alpha: 1)),
    ("SOURCE · NATIONAL CANCER INSTITUTE", "Bring questions.\nGet answers\nin context.", "NCI: Cancer in Children and Adolescents, updated August 27, 2024. General education only; not medical advice.", 8.0, CGColor(red: 0.05, green: 0.13, blue: 0.25, alpha: 1))
]
let fundraisingScenes: [(String, String, String, Double, CGColor)] = [
    ("DMV COMMUNITY FUNDRAISING", "Care starts\nwith community.", "A local invitation to learn about a verified childhood-cancer fundraiser.", 6.0, CGColor(red: 0.13, green: 0.16, blue: 0.25, alpha: 1)),
    ("CHILDREN'S CANCER FOUNDATION", "42nd Annual\nGala", "The Foundation lists its 2026 gala for November 7, 2026. Check the organizer's page for current event details.", 7.0, CGColor(red: 0.17, green: 0.21, blue: 0.30, alpha: 1)),
    ("A REGIONAL COMMUNITY GATHERING", "Researchers.\nFamilies. Allies.", "The Foundation describes its gala as bringing researchers, patients, survivors, donors, and allies together around its mission.", 7.0, CGColor(red: 0.13, green: 0.28, blue: 0.27, alpha: 1)),
    ("CHECK BEFORE YOU GO", "Venue. Tickets.\nOfficial details.", "Confirm the latest location, ticket availability, and sponsorship details directly with the organizer.", 7.0, CGColor(red: 0.25, green: 0.21, blue: 0.30, alpha: 1)),
    ("GIVE WITH CLARITY", "Use official\nchannels.", "Verify the recipient and terms. No donation guarantees a particular treatment or outcome.", 7.0, CGColor(red: 0.20, green: 0.27, blue: 0.23, alpha: 1)),
    ("INDEPENDENT COMMUNITY DRAFT", "Learn more.\nShare with care.", "Official event details: childrenscancerfoundation.org/events/gala. Not an official event announcement. General education only; not medical advice.", 8.0, CGColor(red: 0.12, green: 0.16, blue: 0.23, alpha: 1))
]

func drawText(_ text: String, context: CGContext, rect: CGRect, size: CGFloat, color: CGColor, fontName: String = "AvenirNext-DemiBold", alignment: CTTextAlignment = .left) {
    let font = CTFontCreateWithName(fontName as CFString, size, nil)
    var alignmentValue = alignment
    let paragraph = withUnsafePointer(to: &alignmentValue) { pointer -> CTParagraphStyle in
        var setting = CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: pointer)
        return CTParagraphStyleCreate(&setting, 1)
    }
    let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
        NSAttributedString.Key(kCTParagraphStyleAttributeName as String): paragraph,
        NSAttributedString.Key(kCTKernAttributeName as String): 0.2
    ]
    let attributed = NSAttributedString(string: text, attributes: attributes)
    let setter = CTFramesetterCreateWithAttributedString(attributed)
    let path = CGPath(rect: rect, transform: nil)
    let frame = CTFramesetterCreateFrame(setter, CFRange(location: 0, length: attributed.length), path, nil)
    context.saveGState()
    context.textMatrix = .identity
    CTFrameDraw(frame, context)
    context.restoreGState()
}

func drawImage(_ image: CGImage, context: CGContext, rect: CGRect) {
    let scale = min(rect.width / CGFloat(image.width), rect.height / CGFloat(image.height))
    let targetWidth = CGFloat(image.width) * scale
    let targetHeight = CGFloat(image.height) * scale
    let target = CGRect(x: rect.midX - targetWidth / 2, y: rect.midY - targetHeight / 2, width: targetWidth, height: targetHeight)
    context.draw(image, in: target)
}

func makeFrame(scene: (String, String, String, Double, CGColor), index: Int, poster: CGImage?) throws -> CVPixelBuffer {
    var pixelBuffer: CVPixelBuffer?
    let attributes = [kCVPixelBufferCGImageCompatibilityKey: true, kCVPixelBufferCGBitmapContextCompatibilityKey: true] as CFDictionary
    let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attributes, &pixelBuffer)
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else { throw NSError(domain: "Video", code: Int(status)) }
    CVPixelBufferLockBaseAddress(buffer, [])
    defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
    let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
    guard let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo) else { throw NSError(domain: "Video", code: 2) }
    let background = scene.4
    context.setFillColor(background)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    let accent = topic == "fundraising-gala"
        ? CGColor(red: 0.84, green: 0.75, blue: 0.38, alpha: 1)
        : CGColor(red: 0.83, green: 0.39, blue: 0.29, alpha: 1)
    context.setFillColor(accent)
    context.fill(CGRect(x: 70, y: 0, width: 9, height: height))
    let white = CGColor(gray: 1, alpha: 1)
    let pale = CGColor(red: 0.82, green: 0.89, blue: 0.85, alpha: 1)
    let seriesTitle = topic == "age-groups"
        ? "CHILDHOOD CANCER  /  AGE-GROUP SNAPSHOT"
        : topic == "fundraising-gala" ? "CHILDHOOD CANCER  /  DMV COMMUNITY" : "CHILDHOOD CANCER  /  FIELD NOTES"
    drawText(seriesTitle, context: context, rect: CGRect(x: 112, y: 1750, width: 850, height: 45), size: 25, color: pale)
    drawText(scene.0, context: context, rect: CGRect(x: 112, y: 1535, width: 850, height: 70), size: 27, color: accent)
    if topic == "fundraising-gala" && index == 0 {
        let boxColors = [
            CGColor(red: 0.84, green: 0.75, blue: 0.38, alpha: 1),
            CGColor(red: 0.39, green: 0.67, blue: 0.59, alpha: 1),
            CGColor(red: 0.87, green: 0.87, blue: 0.79, alpha: 1)
        ]
        let labels = ["COMMUNITY", "VERIFIED\nORGANIZER", "CLEAR\nDETAILS"]
        for node in 0..<3 {
            let x = CGFloat(128 + node * 300)
            let box = CGRect(x: x, y: 800, width: 260, height: 190)
            context.setFillColor(boxColors[node])
            context.addPath(CGPath(roundedRect: box, cornerWidth: 14, cornerHeight: 14, transform: nil))
            context.fillPath()
            drawText(labels[node], context: context, rect: CGRect(x: x + 16, y: 858, width: 228, height: 74), size: 24, color: node == 2 ? CGColor(red: 0.13, green: 0.16, blue: 0.25, alpha: 1) : white, alignment: .center)
            if node < 2 {
                drawText("→", context: context, rect: CGRect(x: x + 264, y: 858, width: 32, height: 60), size: 32, color: white, alignment: .center)
            }
        }
        drawText(scene.1, context: context, rect: CGRect(x: 112, y: 1320, width: 850, height: 160), size: 70, color: white)
        drawText(scene.2, context: context, rect: CGRect(x: 112, y: 480, width: 850, height: 190), size: 36, color: pale, fontName: "AvenirNext-Regular")
    } else if index == 0, let poster {
        drawImage(poster, context: context, rect: CGRect(x: 150, y: 520, width: 780, height: 780))
        drawText(scene.1, context: context, rect: CGRect(x: 112, y: 1360, width: 850, height: 150), size: 62, color: white)
        drawText(scene.2, context: context, rect: CGRect(x: 112, y: 390, width: 850, height: 120), size: 34, color: pale, fontName: "AvenirNext-Regular")
    } else {
        let headlineSize: CGFloat = scene.1.count > 18 ? 64 : 92
        drawText(scene.1, context: context, rect: CGRect(x: 112, y: 1000, width: 850, height: 390), size: headlineSize, color: white)
        context.setFillColor(accent.copy(alpha: 0.5) ?? accent)
        context.fill(CGRect(x: 112, y: 880, width: 190, height: 7))
        drawText(scene.2, context: context, rect: CGRect(x: 112, y: 500, width: 850, height: 320), size: 38, color: pale, fontName: "AvenirNext-Regular")
    }
    let sourceLine = topic == "age-groups"
        ? "SOURCE: NATIONAL CANCER INSTITUTE · CANCER IN CHILDREN AND ADOLESCENTS"
        : topic == "fundraising-gala" ? "VERIFY EVENT DETAILS WITH THE CHILDREN'S CANCER FOUNDATION" : "NCI · ACS  |  SOURCES LINKED ON THE WEBSITE"
    drawText(sourceLine, context: context, rect: CGRect(x: 112, y: 110, width: 850, height: 38), size: 20, color: pale, fontName: "AvenirNext-Regular")
    return buffer
}

func main() async throws {
    let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil)
    let poster = imageSource.flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) }
    try? FileManager.default.removeItem(at: silentMovie)
    let writer = try AVAssetWriter(outputURL: silentMovie, fileType: .mov)
    let settings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: width, AVVideoHeightKey: height]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB, kCVPixelBufferWidthKey as String: width, kCVPixelBufferHeightKey as String: height])
    guard writer.canAdd(input) else { throw NSError(domain: "Video", code: 3) }
    writer.add(input)
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)
    var frameNumber: Int64 = 0
    let selectedScenes = topic == "nanorobot"
        ? nanorobotScenes
        : topic == "age-groups" ? ageGroupScenes : topic == "fundraising-gala" ? fundraisingScenes : scenes
    for (index, scene) in selectedScenes.enumerated() {
        let frame = try makeFrame(scene: scene, index: index, poster: poster)
        let totalFrames = Int(scene.3 * Double(fps))
        for _ in 0..<totalFrames {
            while !input.isReadyForMoreMediaData { try await Task.sleep(nanoseconds: 2_000_000) }
            let time = CMTime(value: frameNumber, timescale: fps)
            guard adaptor.append(frame, withPresentationTime: time) else { throw writer.error ?? NSError(domain: "Video", code: 4) }
            frameNumber += 1
        }
    }
    input.markAsFinished()
    await writer.finishWriting()
    guard writer.status == .completed else { throw writer.error ?? NSError(domain: "Video", code: 5) }

    print(String(format: "Rendered %.1f-second portrait scene track: %@", Double(frameNumber) / Double(fps), silentMovie.path))
}

Task {
    do { try await main(); exit(0) }
    catch { fputs("Video render failed: \(error)\n", stderr); exit(1) }
}
RunLoop.main.run()
