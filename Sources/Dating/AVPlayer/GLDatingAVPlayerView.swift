//
//  GLDatingAVPlayerView.swift
//  SwiftTool
//
//  Created by galaxy on 2020/12/3.
//  Copyright © 2020 yinhe. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class GLDatingAVPlayerView: UIView {
    
    deinit {
        self.removeNotification()
    }
    
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    public private(set) var player: AVPlayer?
    
    private var videoURL: URL?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GLDatingAVPlayerView {
    private func addNotification() {
        self.removeNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlayFinishedNotification(noti:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}

extension GLDatingAVPlayerView {
    @objc private func videoPlayFinishedNotification(noti: Notification) {
        if let item = noti.object as? AVPlayerItem, item == self.playerItem {
            self.replay()
        }
    }
    
    @objc private func didEnterBackgroundNotification() {
        self.pausePlay()
    }
    
    @objc private func willEnterForegroundNotification() {
        if self.superview != nil && self.superview?.window != nil {
            self.continuePlay()
        }
    }
}

extension GLDatingAVPlayerView {
    private func replay() {
        guard let videoURL = self.videoURL else { return }
        self.stopPlay()
        let playerItem = AVPlayerItem(url: videoURL)
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        player.play()
        self.addNotification()
        self.playerLayer = playerLayer
        self.playerItem = playerItem
        self.player = player
        self.videoURL = videoURL
    }
}

extension GLDatingAVPlayerView {
    
    /// 播放一个本地视频
    public func playVideo(localVideoPath: String?) {
        self.stopPlay()
        guard let localVideoPath = localVideoPath else { return }
        let videoURL = URL(fileURLWithPath: localVideoPath)
        let playerItem = AVPlayerItem(url: videoURL)
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        player.play()
        self.addNotification()
        self.playerLayer = playerLayer
        self.playerItem = playerItem
        self.player = player
        self.videoURL = videoURL
    }
    
    /// 播放一个远程视频
    public func playVideo(remoteVideoPath: String?) {
        self.stopPlay()
        guard let remoteVideoPath = remoteVideoPath else { return }
        guard let videoURL = URL(string: remoteVideoPath) else { return }
        let playerItem = AVPlayerItem(url: videoURL)
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        player.play()
        self.addNotification()
        self.playerLayer = playerLayer
        self.playerItem = playerItem
        self.player = player
        self.videoURL = videoURL
    }
    
    /// 停止播放
    public func stopPlay() {
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        self.playerItem = nil
        self.player?.replaceCurrentItem(with: nil)
        self.player = nil
        self.videoURL = nil
        self.removeNotification()
    }
    
    /// 暂停播放
    public func pausePlay() {
        self.player?.pause()
    }
    
    /// 继续播放
    public func continuePlay() {
        self.player?.play()
    }
}
