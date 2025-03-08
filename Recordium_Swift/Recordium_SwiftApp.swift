//
//  Recordium_SwiftApp.swift
//  Recordium_Swift
//
//  Created by 龙龙 on 2025/2/23.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct Recordium_SwiftApp: App {
    // MARK: - 属性
    
    /// SwiftData模型容器
    /// 注册所有数据模型并配置iCloud同步
    var sharedModelContainer: ModelContainer = {
        // 注册所有数据模型到Schema
        let schema = Schema([
            User.self,
            Space.self,
            RecordBox.self,
            Album.self,
            UserSettings.self
        ])
        
        // 配置SwiftData，启用持久化存储
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic // 启用iCloud同步
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法创建ModelContainer: \(error)")
        }
    }()

    // MARK: - 视图构建
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 应用启动时检查并初始化当前用户
                    checkAndInitializeCurrentUser()
                    
                    // 输出数据库文件地址
                    let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                    print("\n数据库文件可能在: \(appSupport.path)")
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - 方法
    
    /// 检查并初始化当前用户
    /// 如果用户不存在，则创建新用户并关联到当前iCloud账户
    private func checkAndInitializeCurrentUser() {
        // 这里将在后续实现iCloud用户自动识别和初始化
        // 暂时使用占位代码
        print("应用启动，检查当前用户...")
    }
}
