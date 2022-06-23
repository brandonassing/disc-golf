
typealias AllDependencies = HasFileManagerService

class GlobalDependencyContainer: AllDependencies {
	
	static let shared = GlobalDependencyContainer()
	
	lazy var fileManagerService: FileManagerService = {
		ApplicationFileManagerService()
	}()
	
	private init() {}
}
