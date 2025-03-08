//
//  RecordBox.swift
//  Recordium_Swift
//
//  Created for Recordium App
//

import Foundation
import SwiftData

/// RecordBox模型 - 唱片盒
/// 用于组织和管理用户收藏的唱片
@Model
final class RecordBox {
    // MARK: - 属性
    
    /// 唱片盒唯一标识符
    @Attribute(.unique) var id: String
    
    /// 唱片盒名称
    var name: String
    
    /// 创建时间
    var createdAt: Date
    
    /// 最后更新时间
    var updatedAt: Date
    
    // MARK: - 关系
    
    /// 唱片盒所属的Space
    @Relationship(inverse: \Space.recordBoxes) var space: Space?
    
    /// 唱片盒中包含的唱片
    @Relationship var albums: [Album] = []
    
    // MARK: - 初始化方法
    
    /// 创建新的唱片盒
    /// - Parameters:
    ///   - id: 唱片盒唯一标识符
    ///   - name: 唱片盒名称
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - 方法
    
    /// 更新唱片盒信息
    /// - Parameter name: 新的唱片盒名称
    func updateInfo(name: String) {
        self.name = name
        self.updatedAt = Date()
    }
    
    /// 添加唱片到唱片盒
    /// - Parameter album: 要添加的唱片
    func addAlbum(_ album: Album) {
        if !albums.contains(where: { $0.id == album.id }) {
            albums.append(album)
            updatedAt = Date()
        }
    }
    
    /// 从唱片盒中移除唱片
    /// - Parameter album: 要移除的唱片
    func removeAlbum(_ album: Album) {
        albums.removeAll(where: { $0.id == album.id })
        updatedAt = Date()
    }
}
