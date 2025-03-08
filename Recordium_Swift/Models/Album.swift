//
//  Album.swift
//  Recordium_Swift
//
//  Created for Recordium App
//

import Foundation
import SwiftData

/// Album模型 - 音乐唱片
/// 参考Spotify API的Album结构设计
/// 参考文档: https://peter-schorn.github.io/SpotifyAPI/documentation/spotifywebapi/album
@Model
final class Album {
    // MARK: - 属性
    
    /// 唱片唯一标识符
    @Attribute(.unique) var id: String
    
    /// 唱片名称
    var name: String
    
    /// 唱片艺术家
    var artists: [String]
    
    /// 唱片封面图片URL
    var imageUrl: String?
    
    /// 发行日期
    var releaseDate: String
    
    /// 唱片类型 (例如: album, single, compilation)
    var albumType: String
    
    /// 总曲目数
    var totalTracks: Int
    
    /// 流行度指数 (0-100)
    var popularity: Int?
    
    /// 来源平台 (例如: Spotify, Apple Music)
    var source: String
    
    /// 原始平台ID
    var sourceId: String
    
    /// 添加到收藏的时间
    var addedAt: Date
    
    /// 最后更新时间
    var updatedAt: Date
    
    // MARK: - 关系
    
    /// 唱片所属的用户
    @Relationship(inverse: \User.albums) var user: User?
    
    /// 包含此唱片的唱片盒集合
    @Relationship(inverse: \RecordBox.albums) var recordBoxes: [RecordBox]? = []
    
    // MARK: - 初始化方法
    
    /// 创建新的唱片记录
    /// - Parameters:
    ///   - id: 唱片唯一标识符
    ///   - name: 唱片名称
    ///   - artists: 艺术家列表
    ///   - imageUrl: 封面图片URL
    ///   - releaseDate: 发行日期
    ///   - albumType: 唱片类型
    ///   - totalTracks: 总曲目数
    ///   - popularity: 流行度
    ///   - source: 来源平台
    ///   - sourceId: 原始平台ID
    init(
        id: String = UUID().uuidString,
        name: String,
        artists: [String],
        imageUrl: String? = nil,
        releaseDate: String,
        albumType: String,
        totalTracks: Int,
        popularity: Int? = nil,
        source: String,
        sourceId: String
    ) {
        self.id = id
        self.name = name
        self.artists = artists
        self.imageUrl = imageUrl
        self.releaseDate = releaseDate
        self.albumType = albumType
        self.totalTracks = totalTracks
        self.popularity = popularity
        self.source = source
        self.sourceId = sourceId
        self.addedAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - 方法
    
    /// 更新唱片信息
    func updateInfo(
        name: String? = nil,
        artists: [String]? = nil,
        imageUrl: String? = nil,
        popularity: Int? = nil
    ) {
        if let name = name {
            self.name = name
        }
        
        if let artists = artists {
            self.artists = artists
        }
        
        if let imageUrl = imageUrl {
            self.imageUrl = imageUrl
        }
        
        if let popularity = popularity {
            self.popularity = popularity
        }
        
        self.updatedAt = Date()
    }
    
    /// 获取主要艺术家名称
    /// - Returns: 主要艺术家名称或"未知艺术家"
    func primaryArtist() -> String {
        return artists.first ?? "未知艺术家"
    }
    
    /// 获取所有艺术家名称（以逗号分隔）
    /// - Returns: 艺术家名称字符串
    func artistsString() -> String {
        return artists.joined(separator: ", ")
    }
}
