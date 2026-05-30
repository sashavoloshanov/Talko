import Foundation
import Observation
 
@Observable
class BaseViewModel {
    var isLoading: Bool = false
    var errorMessage: String? = nil
}
