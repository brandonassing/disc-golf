
import Foundation

protocol FileManagerService {
	
	var cacheUrl: URL? { get }
	
	func read(from url: URL) -> Data?
	func write(_ data: Data?, to url: URL, withExpiration: Date?)
	func removeItem(at url: URL)

	func write(_ data: Data?, to url: URL, withExpiry: ExpirationTime)
	func setExpiry(for url: URL, to time: ExpirationTime)
}

extension FileManagerService {
	func write(_ data: Data?, to url: URL, withExpiration expirationDate: Date? = nil) {
		self.write(data, to: url, withExpiration: expirationDate)
	}
	
	func write(_ data: Data?, to url: URL, withExpiry time: ExpirationTime = .never) {
		self.write(data, to: url, withExpiry: time)
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

	func write(_ data: Data?, to url: URL, withExpiry time: ExpirationTime) {
		do {
			guard let data = data else {
				self.removeItem(at: url)
				return
			}
			try data.write(to: url, options: .atomic)
			self.setExpiry(for: url, to: time)
		} catch {
			print(error.localizedDescription)
		}
	}

	func setExpiry(for url: URL, to time: ExpirationTime) {
		do {
			if let expiryDate = time.dateFromNow {
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

enum ExpirationTime {
	case seconds(Int)
	case minutes(Int)
	case hours(Int)
	case days(Int)
	case never
	
	var timeInSeconds: Int? {
		switch self {
		case .seconds(let seconds):
			return seconds
		case .minutes(let minutes):
			return minutes * 60
		case .hours(let hours):
			return hours * 60 * 60
		case .days(let days):
			return days * 24 * 60 * 60
		case .never:
			return nil
		}
	}
	
	var dateFromNow: Date? {
		guard let timeInSeconds = self.timeInSeconds else {
			return nil
		}
		// Potential bug since we're using Date() which will update?
		// Ie: calling this twice will return different dates
		return Calendar.current.date(byAdding: .second, value: timeInSeconds, to: Date())
	}
}

extension URL {
	func appendingExpiryExtension() -> URL {
		return self.appendingPathExtension("expiry")
	}
}
