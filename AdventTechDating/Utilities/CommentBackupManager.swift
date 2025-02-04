import Foundation

class CommentBackupManager {
    static let shared = CommentBackupManager()
    
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {}
    
    private var backupDirectory: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("CommentBackups")
    }
    
    func saveBackup(_ comments: [Post.Comment], for postId: UUID) {
        guard let directory = backupDirectory else { return }
        
        do {
            // Create backup directory if it doesn't exist
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            
            let backupURL = directory.appendingPathComponent("\(postId.uuidString).backup")
            let data = try encoder.encode(comments)
            try data.write(to: backupURL)
            
            // Keep only last 5 backups
            cleanupOldBackups()
        } catch {
            print("Failed to save backup: \(error)")
        }
    }
    
    func loadBackup(for postId: UUID) -> [Post.Comment]? {
        guard let directory = backupDirectory else { return nil }
        
        let backupURL = directory.appendingPathComponent("\(postId.uuidString).backup")
        
        do {
            let data = try Data(contentsOf: backupURL)
            return try decoder.decode([Post.Comment].self, from: data)
        } catch {
            print("Failed to load backup: \(error)")
            return nil
        }
    }
    
    private func cleanupOldBackups() {
        guard let directory = backupDirectory else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey])
            let sortedFiles = files.sorted { file1, file2 in
                let date1 = try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let date2 = try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                return date1 ?? Date.distantPast > date2 ?? Date.distantPast
            }
            
            // Remove all but the last 5 backups
            if sortedFiles.count > 5 {
                for file in sortedFiles[5...] {
                    try fileManager.removeItem(at: file)
                }
            }
        } catch {
            print("Failed to cleanup backups: \(error)")
        }
    }
} 