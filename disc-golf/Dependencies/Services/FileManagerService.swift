
import Foundation

protocol FileManagerService {
	
	var cacheUrl: URL? { get }
	
	func read(from url: URL) -> Data?
	func write(_ data: Data?, to url: URL, withExpiration: Date?)
	func removeItem(at url: URL)
	func setExpiry(for url: URL, to expiration: Date?)
}

extension FileManagerService {
	func write(_ data: Data?, to url: URL, withExpiration expirationDate: Date? = nil) {
		self.write(data, to: url, withExpiration: expirationDate)
	}
}

class ApplicationFileManagerService: FileManagerService {
	
	private var manager: FileManager
	
	var cacheUrl: URL? {
		return self.manager.urls(for: .cachesDirectory, in: .userDomainMask).first
	}
	
	func read(from url: URL) -> Data? {
		
		if let dateData = try? Data(contentsOf: url.appendingExpiryExtension()) {
			guard
				let date = try? JSONDecoder().decode(Date.self, from: dateData),
				date > Date()
			else {
				self.removeItem(at: url)
				return nil
			}
		}
		
		let data = try? Data(contentsOf: url)
		return data
	}
	
	func write(_ data: Data?, to url: URL, withExpiration date: Date?) {
		do {
			guard let data = data else {
				self.removeItem(at: url)
				return
			}
			
			try data.write(to: url, options: .atomic)
			
			if let date = date, let dateData = try? JSONEncoder().encode(date) {
				try dateData.write(to: url.appendingExpiryExtension(), options: .atomic)
			} else {
				self.removeItem(at: url.appendingExpiryExtension())
			}
			
		} catch {
			print(error.localizedDescription)
		}
	}
	
	func removeItem(at url: URL) {
		do {
			try self.manager.removeItem(at: url)
			try self.manager.removeItem(at: url.appendingExpiryExtension())
		} catch {
			print(error.localizedDescription)
		}
	}

	func setExpiry(for url: URL, to expiration: Date?) {
		do {
			if let expiryDate = expiration {
				try JSONEncoder().encode(expiryDate).write(to: url.appendingExpiryExtension(), options: .atomic)
			} else {
				self.removeItem(at: url.appendingExpiryExtension())
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	
	init(fileManager: FileManager = .default) {
		self.manager = fileManager
	}
	
}

extension URL {
	func appendingExpiryExtension() -> URL {
		return self.appendingPathExtension("expiry")
	}
}
