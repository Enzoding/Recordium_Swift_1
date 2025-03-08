//
//  UserSettings.swift
//  Recordium_Swift
//
//  Created for Recordium App
//

import Foundation
import SwiftData

/// UserSettings模型 - 用户设置
/// 存储用户的个人配置信息
@Model
final class UserSettings {
    // MARK: - 属性
    
    /// 设置唯一标识符
    @Attribute(.unique) var id: String
    
    /// 是否启用iCloud同步
    var isCloudSyncEnabled: Bool = true
    
    /// 默认显示模式 (light, dark, system)
    var displayMode: String = "system"
    
    /// 是否显示唱片详细信息
    var showDetailedAlbumInfo: Bool = true
    
    /// 创建时间
    var createdAt: Date
    
    /// 最后更新时间
    var updatedAt: Date
    
    // MARK: - 关系
    
    /// 设置所属的用户
    @Relationship var user: User?
    
    // MARK: - 初始化方法
    
    /// 创建用户设置
    /// - Parameter id: 设置唯一标识符
    init(id: String = UUID().uuidString) {
        self.id = id
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - 方法
    
    /// 更新iCloud同步设置
    /// - Parameter enabled: 是否启用
    func updateCloudSync(enabled: Bool) {
        self.isCloudSyncEnabled = enabled
        self.updatedAt = Date()
    }
    
    /// 更新显示模式
    /// - Parameter mode: 显示模式 (light, dark, system)
    func updateDisplayMode(mode: String) {
        self.displayMode = mode
        self.updatedAt = Date()
    }
    
    /// 更新唱片详情显示设置
    /// - Parameter show: 是否显示
    func updateAlbumDetailDisplay(show: Bool) {
        self.showDetailedAlbumInfo = show
        self.updatedAt = Date()
    }
}
