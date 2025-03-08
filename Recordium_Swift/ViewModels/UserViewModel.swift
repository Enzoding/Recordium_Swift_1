//
//  UserViewModel.swift
//  Recordium_Swift
//
//  Created for Recordium App
//

import Foundation
import SwiftUI
import SwiftData
import CloudKit

/// 用户视图模型 - 负责用户数据的管理和操作
/// 遵循MVVM架构模式，处理用户相关的业务逻辑
class UserViewModel: ObservableObject {
    // MARK: - 属性
    
    /// 当前用户
    @Published var currentUser: User?
    
    /// 当前选中的Space
    @Published var selectedSpace: Space?
    
    /// 是否正在加载
    @Published var isLoading = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 模型上下文
    private var modelContext: ModelContext?
    
    // MARK: - 初始化方法
    
    init(modelContext: ModelContext?) {
        self.modelContext = modelContext
    }
    
    // MARK: - 用户管理方法
    
    /// 检查并初始化当前用户
    /// 如果用户不存在，则创建新用户
    func checkAndInitializeCurrentUser() async {
        guard let modelContext = modelContext else {
            self.errorMessage = "模型上下文不可用"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 在实际应用中，这里应该获取当前iCloud用户信息
            // 暂时使用模拟数据
            let appleId = "current_user_apple_id"
            let userName = "测试用户"
            
            // 查询是否已存在用户
            let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.appleId == appleId })
            let existingUsers = try modelContext.fetch(descriptor)
            
            if let existingUser = existingUsers.first {
                // 用户已存在，加载用户数据
                self.currentUser = existingUser
                
                // 如果用户有Space，选择第一个Space作为当前Space
                if let firstSpace = existingUser.spaces.first {
                    self.selectedSpace = firstSpace
                }
            } else {
                // 创建新用户
                let newUser = User(appleId: appleId, name: userName)
                
                // 创建默认Space
                let defaultSpace = newUser.createDefaultSpace()
                
                // 创建用户设置
                let settings = UserSettings()
                settings.user = newUser
                
                // 保存到数据库
                modelContext.insert(newUser)
                modelContext.insert(settings)
                
                self.currentUser = newUser
                self.selectedSpace = defaultSpace
            }
        } catch {
            self.errorMessage = "初始化用户失败: \(error.localizedDescription)"
        }
    }
    
    /// 创建新的Space
    /// - Parameter name: Space名称
    func createNewSpace(name: String) {
        guard let user = currentUser else {
            self.errorMessage = "用户未初始化"
            return
        }
        
        let newSpace = Space(name: name)
        user.spaces.append(newSpace)
        self.selectedSpace = newSpace
    }
    
    /// 创建新的唱片盒
    /// - Parameters:
    ///   - name: 唱片盒名称
    ///   - inSpace: 所属Space，默认为当前选中的Space
    func createNewRecordBox(name: String, inSpace: Space? = nil) {
        guard let space = inSpace ?? selectedSpace else {
            self.errorMessage = "未选择Space"
            return
        }
        
        // 使用下划线忽略返回值，因为Space已经自动将其添加到了recordBoxes数组中
        _ = space.createRecordBox(name: name)
        // 触发UI更新
        self.objectWillChange.send()
    }
    
    /// 添加测试唱片数据
    /// - Parameter toRecordBox: 目标唱片盒
    func addTestAlbum(toRecordBox: RecordBox) {
        guard let user = currentUser, let modelContext = modelContext else {
            self.errorMessage = "用户未初始化"
            return
        }
        
        // 创建测试唱片
        let testAlbum = Album(
            name: "测试唱片",
            artists: ["测试艺术家"],
            imageUrl: nil,
            releaseDate: "2025-01-01",
            albumType: "album",
            totalTracks: 10,
            popularity: 80,
            source: "测试",
            sourceId: "test_id_\(UUID().uuidString)"
        )
        
        // 添加到用户的唱片集合
        user.albums.append(testAlbum)
        
        // 添加到唱片盒
        toRecordBox.addAlbum(testAlbum)
        
        // 保存到数据库
        modelContext.insert(testAlbum)
        
        // 触发UI更新
        self.objectWillChange.send()
    }
}
