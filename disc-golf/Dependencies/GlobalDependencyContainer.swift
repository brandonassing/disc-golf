
typealias AllDependencies = HasFileManagerService & HasCourseRepository

class GlobalDependencyContainer: AllDependencies {
	
	static let shared = GlobalDependencyContainer()
	
	lazy var fileManagerService: FileManagerService = {
		ApplicationFileManagerService()
	}()
	
	lazy var courseRepository: CourseRepository = {
		ApplicationCourseRepository(dependencies: self)
	}()
	
	private init() {}
}
