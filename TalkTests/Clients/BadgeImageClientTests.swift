import Testing
import UIKit
@testable import Talk

@Suite("BadgeImageClient", .serialized)
struct BadgeImageClientTests {

    private func tempDir() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("BadgeImageTests_\(UUID().uuidString)")
    }

    private func sampleImageData() -> Data {
        UIImage(systemName: "star.fill")!.pngData()!
    }

    @Test func successfulDownloadCachesInMemory() async throws {
        let data = sampleImageData()
        let session = MockURLSession(data: data)
        let client = BadgeImageClient(session: session, cacheDirectory: tempDir())

        let image = try await client.image(named: "badge_test_10")
        #expect(image != nil)
        let countAfterFirst = await session.requestCount
        #expect(countAfterFirst == 1)

        _ = try await client.image(named: "badge_test_10")
        let countAfterSecond = await session.requestCount
        #expect(countAfterSecond == 1)
    }

    @Test func diskCachePreventsDuplicateDownload() async throws {
        let data = sampleImageData()
        let dir = tempDir()
        let session1 = MockURLSession(data: data)
        let client1 = BadgeImageClient(session: session1, cacheDirectory: dir)
        _ = try await client1.image(named: "badge_test_30")

        let session2 = MockURLSession(data: Data())
        let client2 = BadgeImageClient(session: session2, cacheDirectory: dir)
        let image = try await client2.image(named: "badge_test_30")
        #expect(image != nil)

        let count = await session2.requestCount
        #expect(count == 0)
    }

    @Test func networkErrorThrows() async throws {
        let session = MockURLSession(error: URLError(.notConnectedToInternet))
        let client = BadgeImageClient(session: session, cacheDirectory: tempDir())

        await #expect(throws: (any Error).self) {
            _ = try await client.image(named: "badge_test_50")
        }
    }

    @Test func concurrentRequestsDeduplicated() async throws {
        let data = sampleImageData()
        let session = MockURLSession(data: data)
        let client = BadgeImageClient(session: session, cacheDirectory: tempDir())

        async let a = client.image(named: "badge_concurrent_10")
        async let b = client.image(named: "badge_concurrent_10")
        async let c = client.image(named: "badge_concurrent_10")

        let results = try await [a, b, c]
        #expect(results.count == 3)

        let count = await session.requestCount
        #expect(count == 1)
    }

    @Test func retryAfterNetworkErrorSucceeds() async throws {
        let session = MockURLSession(error: URLError(.notConnectedToInternet))
        let client = BadgeImageClient(session: session, cacheDirectory: tempDir())

        await #expect(throws: (any Error).self) {
            _ = try await client.image(named: "badge_retry_10")
        }

        await session.setResult(.success(sampleImageData()))
        let image = try await client.image(named: "badge_retry_10")
        #expect(image != nil)

        let count = await session.requestCount
        #expect(count == 2)
    }

    @Test func invalidDataThrowsInvalidDataError() async throws {
        let session = MockURLSession(data: Data("not a png".utf8))
        let client = BadgeImageClient(session: session, cacheDirectory: tempDir())

        await #expect(throws: BadgeImageError.invalidData) {
            _ = try await client.image(named: "badge_invalid")
        }
    }

    @Test func differentNamesAreIndependentRequests() async throws {
        let data = sampleImageData()
        let session = MockURLSession(data: data)
        let client = BadgeImageClient(session: session, cacheDirectory: tempDir())

        _ = try await client.image(named: "badge_a_10")
        _ = try await client.image(named: "badge_b_10")
        _ = try await client.image(named: "badge_a_10")

        let count = await session.requestCount
        #expect(count == 2)
    }

    @Test func diskFileIsCreatedAfterDownload() async throws {
        let data = sampleImageData()
        let dir = tempDir()
        let session = MockURLSession(data: data)
        let client = BadgeImageClient(session: session, cacheDirectory: dir)

        _ = try await client.image(named: "badge_saved_10")

        let fileURL = dir.appendingPathComponent("badge_saved_10.png")
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }
}
