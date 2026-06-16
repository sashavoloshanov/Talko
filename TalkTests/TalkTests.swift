import Testing

// Serialize all tests in this target to prevent parallel access to UserDefaultsClient.defaults.
// Multiple test suites modify the shared static, and parallel execution causes data races.
@Suite(.serialized)
struct AllTests {}
