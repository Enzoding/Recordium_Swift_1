//
//  Space.swift
//  Recordium_Swift
//
//  Created for Recordium App
//

import Foundation
import SwiftData

/// Space模型 - 用户可创建的空间
/// 每个Space可以包含多个唱片盒(RecordBox)
@Model
final class Space {
    // MARK: - 属性
    
    /// Space唯一标识符
    @Attribute(.unique) var id: String
    
    /// Space名称
    var name: String
    
    /// 创建时间
    var createdAt: Date
    
    /// 最后更新时间
    var updatedAt: Date
    
    // MARK: - 关系
    
    /// Space所属的用户
    @Relationship(inverse: \User.spaces) var user: User?
    
    /// Space包含的所有唱片盒
    @Relationship(deleteRule: .cascade) var recordBoxes: [RecordBox] = []
    
    // MARK: - 初始化方法
    
    /// 创建新的Space
    /// - Parameters:
    ///   - id: Space唯一标识符
    ///   - name: Space名称
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - 方法
    
    /// 更新Space信息
    /// - Parameter name: 新的Space名称
    func updateInfo(name: String) {
        self.name = name
        self.updatedAt = Date()
    }
    
    /// 创建新的唱片盒
    /// - Parameter name: 唱片盒名称
    /// - Returns: 新创建的唱片盒
    func createRecordBox(name: String) -> RecordBox {
        let newRecordBox = RecordBox(name: name)
        recordBoxes.append(newRecordBox)
        return newRecordBox
    }
}
