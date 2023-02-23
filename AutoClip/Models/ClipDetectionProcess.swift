//
//  ClipDetectionProcess.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/10.
//

import UIKit
import AVFoundation
import opencv2
import Combine

class ClipDetectionProcess {
    /// ゲームの種類
    let game: GameKind
    /// ゲームシーン
    let scene: GameSceneKind
    /// しきい値
    let threshold: Float
    /// マッチング処理を行う間隔
    let matchSeconds: Int
    /// 動画のURL
    let videoUrl: URL
    /// 処理進捗度をsendするsubject
    let progressPublisher = PassthroughSubject<Float, Never>()
    /// progressPublisherのcancellable
    var progressPublisherCancellable: AnyCancellable?
    var player: AVPlayer
    /// processPublisherのcancellable
    //var processPublisherCancellable: AnyCancellable?
    
    init(game: GameKind, scene: GameSceneKind, threshold: Float, matchSeconds: SecondsKind, videoUrl: URL) {
        self.game = game
        self.scene = scene
        self.threshold = threshold
        self.matchSeconds = matchSeconds.value
        self.videoUrl = videoUrl
        
        // CMTimeRangeを作成するときに、timescaleが必要なので取得する
        let avplayerItem = AVPlayerItem(url: self.videoUrl)
        self.player = .init(playerItem: avplayerItem)
    }
    
    func fetch() -> AnyPublisher<[CMTimeRange], Never> {
        Publishers.CombineLatest(detectClipPublisher(), timeScalePublisher(player: player))
            .map { detectedSeconds, timescale -> [CMTimeRange] in
                // 最後にこれを作って返す
                var ranges: [CMTimeRange] = []
                
                // 下の処理で使用する変数
                var startSeconds = 0.0
                var endSeconds = 0.0
                
                // 連続でマッチングした場合は、はじめから終わりまでをCMTimeRangeにする
                // 例: マッチングした時間(秒) -> 3, 6, 9, 15, 30, 300, 303, 600
                // 上記の場合は、"3, 6, 9"と"300, 303"のところが連続でマッチングされているので、
                // CMTimeRangeのinitのstartに3を、endに9を指定して作成する。300, 303も同様。
                // それ以外は、startとendに同じ秒数を指定して作成する。
                for i in 0..<detectedSeconds.count {
                    if i == 0 {
                        startSeconds = detectedSeconds[i]
                    }
                    
                    if i != detectedSeconds.count - 1 {
                        if detectedSeconds[i] + Double(self.matchSeconds) == detectedSeconds[i + 1] {
                            continue
                        } else {
                            endSeconds = detectedSeconds[i]
                            
                            ranges.append(.init(start: .init(seconds: startSeconds, preferredTimescale: timescale), end: .init(seconds: endSeconds, preferredTimescale: timescale)))
                            startSeconds = detectedSeconds[i + 1]
                        }
                    } else {
                        endSeconds = detectedSeconds[i]
                        ranges.append(.init(start: .init(seconds: startSeconds, preferredTimescale: timescale), end: .init(seconds: endSeconds, preferredTimescale: timescale)))
                    }
                }
                
                DispatchQueue.main.async {
                    // 処理完了のため、進行度を100%にする
                    self.progressPublisher.send(100.0)
                }
                
                return ranges
            }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    
    private func detectClipPublisher() -> AnyPublisher<[Double], Never> {
        Deferred {
            Future<[Double], Never> { promise in
                DispatchQueue.global().async {
                    // 特徴点検出をするのに使う
                    let akaze = AKAZE.create()
                    // 特徴点マッチングをするのに使う
                    let matcher = BFMatcher(normType: NormTypes.NORM_HAMMING, crossCheck: false)
                    
                    // テンプレート画像
                    let tmp = Mat(uiImage: UIImage(named: "\(self.scene == .kill ?   self.game.killTemplateImageName : self.game.deathTemplateImageName)")!)
                    // 画像の色をグレースケールに変更する。これをするとマッチング処理が少し早くなる
                    Imgproc.cvtColor(src: tmp, dst: tmp, code: ColorConversionCodes.COLOR_BGR2GRAY)
                    // 画像に白で縁取りをする。マッチング精度が向上する。
                    Core.copyMakeBorder(src: tmp, dst: tmp, top: 30, bottom: 30, left: 30, right: 30, borderType: BorderTypes.BORDER_CONSTANT, value: Scalar(255, 255, 255))
                    
                    // url先にある動画をもとに、VideoCaptureインスタンスを作成する
                    let video = VideoCapture(filename: self.videoUrl.absoluteString.replacingOccurrences(of: "file://", with: ""))
                    
                    // 読み込まれた動画のサイズを取得するために、動画の最初のフレームを読み込む
                    let img = Mat()
                    video.read(image: img)
                    
                    // 縦のサイズ
                    let imgRows = img.rows()
                    // 横のサイズ
                    let imgCols = img.cols()
                    
                    // 特徴点を格納する
                    var kp1: [KeyPoint] = []
                    // 特徴点をもとにした特徴量データを格納する
                    let desc1 = Mat()
                    // 特徴点抽出をする
                    akaze.detectAndCompute(image: tmp, mask: Mat(), keypoints: &kp1, descriptors: desc1)
                    // 動画の全体のフレーム数
                    let frameCount = video.get(propId: VideoCaptureProperties.CAP_PROP_FRAME_COUNT.rawValue)
                    // 動画のフレームレート
                    let frameRate = video.get(propId: VideoCaptureProperties.CAP_PROP_FPS.rawValue)
                    
                    // 特徴点マッチングによって目標のシーンだと判定された秒数
                    var detectedSeconds: [Double] = []
                    
                    // キル、デス時に文字が表示される場所は決まっているため、マスクを作成して、必要なところだけを特徴点マッチングする
                    let mask = Mat(uiImage: UIImage(named: "\(self.scene == .kill ?  self.game.killMaskImageName : self.game.deathMaskImageName)")!)
                    Imgproc.resize(src: mask, dst: mask, dsize: Size2i(width: 1920, height: 1080))
                    Imgproc.cvtColor(src: mask, dst: mask, code: ColorConversionCodes.COLOR_BGR2GRAY)
                    Core.bitwise_not(src: mask, dst: mask)
                    Imgproc.threshold(src: mask, dst: mask, thresh: 128, maxval: 255, type: .THRESH_BINARY)
                    mask.convert(to: mask, rtype: CvType.CV_8UC1)
                    Core.copyMakeBorder(src: mask, dst: mask, top: 50, bottom: 50, left: 50, right: 50, borderType: BorderTypes.BORDER_CONSTANT, value: Scalar(0, 0, 0))
                    
                    
                    // matchSecondsに指定された秒数ごとにマッチング処理を実行する
                    for i in 0..<Int(frameCount / frameRate) / self.matchSeconds {
                        if frameCount < frameRate * Double(self.matchSeconds) {
                            break
                        }

                        // VideoCaptureを操作して、動画の再生位置を変更する
                        video.set(propId: VideoCaptureProperties.CAP_PROP_POS_MSEC.rawValue, value: Double(1000 * i * self.matchSeconds))
                        
                        // 動画のフレーム画像
                        let frameImg = Mat(rows: imgRows, cols: imgCols, type: CvType.CV_8UC4)
                        video.read(image: frameImg)
                        // 1920x1080にリサイズする。この処理を加えるともとが1280x720の動画でも検出が可能になる
                        Imgproc.resize(src: frameImg, dst: frameImg, dsize: .init(width: 1920, height: 1080))
                        // 画像の色をグレースケールに変更する。これをするとマッチング処理が少し早くなる
                        Imgproc.cvtColor(src: frameImg, dst: frameImg, code: ColorConversionCodes.COLOR_BGR2GRAY)
                        // 画像に白で縁取りをする。マッチング精度が向上する。
                        Core.copyMakeBorder(src: frameImg, dst: frameImg, top: 50, bottom: 50, left: 50, right: 50, borderType: BorderTypes.BORDER_CONSTANT, value: Scalar(255, 255, 255))
                        
                        // 特徴点を格納する
                        var kp2: [KeyPoint] = []
                        // 特徴点をもとにした特徴量データを格納する
                        let desc2 = Mat()
                        // 特徴点抽出をする
                        akaze.detectAndCompute(image: frameImg, mask: mask, keypoints: &kp2, descriptors: desc2)
                        
                        // [DMatch]には類似している特徴点の情報が2つずつ(テンプレート画像と動画のフレーム画像)入っていく
                        var dMatch: [[DMatch]] = []
                        // 特徴点マッチングを実行する
                        matcher.knnMatch(queryDescriptors: desc1, trainDescriptors: desc2, matches: &dMatch, k: 2)
                        
                        var goodMatches: [DMatch] = []
                        let goodMatchThreshold: Float = 0.9
                        let distanceThreshold: Float = self.threshold
                        for match in dMatch {
                            // マッチング結果が1以下であればその結果を無視する(マッチング不成立)
                            if match.count <= 1 {
                                continue
                            }
                            
                            // しきい値を使って、信用度の高い情報だけをgoodMatchesに入れていく
                            if match[0].distance < match[1].distance * goodMatchThreshold {
                                goodMatches.append(match[0])
                            }
                        }
                        
                        // goodMatchesの中で一番小さなdistanceを求める
                        let minDistance: Float = { () -> Float in
                            let distances: [Float] = goodMatches.map({ match -> Float in
                                return match.distance
                            })
                            return distances.min() ?? 999.0
                        }()
                        
                        print("minDistance:", minDistance)
                        
                        // minDistanceがしきい値以下であれば、目標のシーンだとみなす
                        if minDistance <= distanceThreshold {
                            detectedSeconds.append(Double(i * self.matchSeconds))
                        }
                        print("\((floor((Double(i * Int(frameRate) * self.matchSeconds) / Double(frameCount)) * 100 * 10) / 10))%")
                        DispatchQueue.main.async {
                            // 進行度をsendする
                            self.progressPublisher.send((floor((Float(i * Int(frameRate) * self.matchSeconds) / Float(frameCount)) * 100 * 10) / 10))
                        }
                    }
                    
                    promise(.success(detectedSeconds))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    private func timeScalePublisher(player: AVPlayer) -> AnyPublisher<CMTimeScale, Never> {
        Deferred {
            Future<CMTimeScale, Never> { promise in
                var playerStatusObserver: NSKeyValueObservation?
                playerStatusObserver = player.observe(\.currentItem!.status) { data, status in
                    switch data.status {
                    case .unknown:
                        break
                    case .readyToPlay:
                        print("readyToPlay!")
                        promise(.success(data.currentItem!.duration.timescale))
                    case .failed:
                        print("failed")
                    @unknown default:
                        break
                    }
                    
                    playerStatusObserver?.invalidate()
                    player.replaceCurrentItem(with: nil)
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

