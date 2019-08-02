import Foundation

protocol ReithConfigurer {
  func configureForReith() -> Void
  
  var reithStatus: ReithStatus { get set }
}
