//
//  GIFImageEditorViewModel.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI
import Combine

final class GIFImageEditorViewModel: ObservableObject {
    @Published var selectedResolution: ResolutionOption?
    @Published var selectedFrameRate: Int = 15
    @Published var selectedNumberOfCycles: Int = 0
    @Published var timeRangeStart: Double = 4.0
    @Published var timeRangeEnd: Double = 9.0
    @Published var currentTime: Double = 30.0
    @Published var isEditingTimeRange = false
    @Published var openNumberOfCycles = false
    @Published var openFrameRate = false
    @Published var openResolution = false
    @Published var generatedGIFURL: URL?
    @Published var hasProAcces: Bool = false

    let duration: Double = 216.0
    let image: UIImage?

    private var cachedResizedImage: UIImage?

    private var cancellables = Set<AnyCancellable>()
    private let gifGenerationTrigger = PassthroughSubject<Void, Never>()

    init(image: UIImage?) {
        self.image = image
        if let img = image {
            selectedResolution = ResolutionOption(size: img.size)
        }

        Publishers.CombineLatest4(
            $selectedResolution,
            $selectedFrameRate,
            $selectedNumberOfCycles,
            Publishers.CombineLatest($timeRangeStart, $timeRangeEnd)
        )
        .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        .sink { [weak self] _, _, _, range in
            self?.generateGIFIfNeeded()
        }
        .store(in: &cancellables)

        $isEditingTimeRange
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.generateGIFIfNeeded()
            }
            .store(in: &cancellables)

        updateResizedImage()
        gifGenerationTrigger.send()
    }

    private func updateResizedImage() {
        guard let image = image else {
            cachedResizedImage = nil
            return
        }
        let resolution = selectedResolution?.cgSizeGIF ?? CGSize(width: 480, height: 720)
        cachedResizedImage = UIImage.resizedImage(image, targetSize: resolution)
    }

    func generateGIFIfNeeded() {
        guard !isEditingTimeRange else { return }
        generateGIF()
    }

    func generateGIF() {
        guard let image = image else { return }
        let resolution = selectedResolution?.cgSizeGIF ?? CGSize(width: 480, height: 720)
        guard let resizedImage = UIImage.resizedImage(image, targetSize: resolution) else { return }

        let frameRate = selectedFrameRate
        let frameDuration = 1.0 / Double(frameRate)
        let loopCount = selectedNumberOfCycles
        let frameCount = Int((timeRangeEnd - timeRangeStart) * Double(frameRate))
        guard frameCount > 0 else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let gifURL = GIFExporter.createGIF(
                from: resizedImage,
                frameCount: frameCount,
                frameDuration: frameDuration,
                loopCount: loopCount,
                size: resolution
            )
            DispatchQueue.main.async {
                self?.generatedGIFURL = gifURL
            }
        }
    }

    var numberOfCyclesText: String {
        selectedNumberOfCycles == 0 ? "Endless looping" : "\(selectedNumberOfCycles)"
    }
    
    func saveEditedImageToDB(selectedImage: UIImage?) {
        guard let image = selectedImage else {
            print("No image to save")
            return
        }
        
        let imageData = image.jpegData(compressionQuality: 1.0)
        let fileSizeValue = UInt64(imageData?.count ?? 0)
        guard let generatedGIFURL = generatedGIFURL else { return }
        
        CoreDataManager.shared.addSavedFile(
            fileURL: generatedGIFURL,
            fileName: generatedGIFURL.absoluteString,
            type: "Image",
            fileSize: fileSizeValue,
            duration: String(duration),
            image: image,
            imageFileExtension: "gif"
        )
    }
}
