import UIKit

protocol URLSessionProtocol: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

actor BadgeImageClient {
    static let shared = BadgeImageClient()

    private let session: URLSessionProtocol
    private var memoryCache: [String: UIImage] = [:]
    private var inFlightTasks: [String: Task<Data, Error>] = [:]
    private let cacheDirectory: URL?

    private static let baseURL = "https://cdn.jsdelivr.net/gh/sashavoloshanov/Talko-content@main/Badges/"

    init(session: URLSessionProtocol = URLSession.shared, cacheDirectory: URL? = nil) {
        self.session = session
        self.cacheDirectory = cacheDirectory ?? FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("BadgeImages")
    }

    func image(named imageName: String) async throws -> UIImage {
        if let cached = memoryCache[imageName] {
            return cached
        }

        if let diskImage = loadFromDisk(named: imageName) {
            memoryCache[imageName] = diskImage
            return diskImage
        }

        if let existing = inFlightTasks[imageName] {
            let data = try await existing.value
            guard let image = UIImage(data: data) else { throw BadgeImageError.invalidData }
            memoryCache[imageName] = image
            return image
        }

        let session = self.session
        let urlString = "\(Self.baseURL)\(imageName).png"
        let task = Task<Data, Error> {
            guard let url = URL(string: urlString) else { throw BadgeImageError.invalidURL }
            let (data, _) = try await session.data(from: url)
            return data
        }

        inFlightTasks[imageName] = task

        do {
            let data = try await task.value
            inFlightTasks.removeValue(forKey: imageName)
            guard let image = UIImage(data: data) else { throw BadgeImageError.invalidData }
            memoryCache[imageName] = image
            saveToDisk(named: imageName, data: data)
            return image
        } catch {
            inFlightTasks.removeValue(forKey: imageName)
            throw error
        }
    }

    private func loadFromDisk(named imageName: String) -> UIImage? {
        guard let url = diskURL(for: imageName),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private func saveToDisk(named imageName: String, data: Data) {
        guard let dir = cacheDirectory else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        guard let url = diskURL(for: imageName) else { return }
        try? data.write(to: url)
    }

    private func diskURL(for imageName: String) -> URL? {
        cacheDirectory?.appendingPathComponent("\(imageName).png")
    }
}

enum BadgeImageError: Error, Equatable {
    case invalidURL
    case invalidData
}
