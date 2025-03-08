//
//  User.swift
//  Recordium_Swift
//
//  Created for Recordium App
//

import Foundation
import SwiftData
import CloudKit

/// 用户模型 - 应用的顶层数据模型
/// 用于存储用户信息及其关联的Space集合
@Model
final class User {
    // MARK: - 属性
    
    /// 用户唯一标识符
    @Attribute(.unique) var id: String
    
    /// 用户的Apple ID (iCloud账户标识)
    var appleId: String
    
    /// 用户名称
    var name: String
    
    /// 是否已授权Spotify
    var isSpotifyAuthorized: Bool = false
    
    /// 是否已授权Apple Music
    var isAppleMusicAuthorized: Bool = false
    
    /// 用户创建时间
    var createdAt: Date
    
    /// 用户信息最后更新时间
    var updatedAt: Date
    
    // MARK: - 关系
    
    /// 用户拥有的所有Space
    @Relationship(deleteRule: .cascade) var spaces: [Space] = []
    
    /// 用户收藏的所有唱片
    @Relationship(deleteRule: .cascade) var albums: [Album] = []
    
    // MARK: - 初始化方法
    
    /// 创建新用户
    /// - Parameters:
    ///   - id: 用户唯一标识符
    ///   - appleId: 用户的Apple ID
    ///   - name: 用户名称
    init(id: String = UUID().uuidString, appleId: String, name: String) {
        self.id = id
        self.appleId = appleId
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - 方法
    
    /// 创建默认Space
    /// - Returns: 新创建的默认Space
    func createDefaultSpace() -> Space {
        let defaultSpace = Space(name: "默认空间")
        spaces.append(defaultSpace)
        return defaultSpace
    }
    
    /// 更新用户信息
    /// - Parameter name: 新的用户名
    func updateUserInfo(name: String) {
        self.name = name
        self.updatedAt = Date()
    }
    
    /// 更新Spotify授权状态
    /// - Parameter isAuthorized: 是否已授权
    func updateSpotifyAuth(isAuthorized: Bool) {
        self.isSpotifyAuthorized = isAuthorized
        self.updatedAt = Date()
    }
    
    /// 更新Apple Music授权状态
    /// - Parameter isAuthorized: 是否已授权
    func updateAppleMusicAuth(isAuthorized: Bool) {
        self.isAppleMusicAuthorized = isAuthorized
        self.updatedAt = Date()
    }
}
