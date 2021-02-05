//
//  ARCloudManager.swift
//  quickstart-ios-swift
//
//  Created by Pavel Sakhanko on 05/02/2021.
//  Copyright © 2021 Ivan Gulidov. All rights reserved.
//

import Foundation
import BanubaARCloudSDK

struct ARCloudManager {
    
    fileprivate static let banubaARCloud = BanubaARCloud(uuidString: cloudMasksToken)

    static func fetchAREffects(completion: @escaping ([AREffectModel]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            var array: [AREffectModel] = []

            banubaARCloud.getAREffects {(effectsArray, _) in
                effectsArray?.forEach({ effect in
                    let effectModel = AREffectModel(
                        title: effect.title,
                        previewImage: effect.previewImage.absoluteString)
                    array.append(effectModel)
                })
                
                DispatchQueue.main.async {
                    completion(array)
                }
            }
        }
    }
    
    static func loadTappedEffect(effectName: String, completion: @escaping (URL) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            banubaARCloud.getAREffects {(effectsArray, _) in
                effectsArray?.forEach({ effect in
                    guard effectName != effect.title else {
                        var currentProgress: Double?
                        banubaARCloud.downloadArEffect(effect) {(progress) in
                            currentProgress = progress
                        } completion: {(url, error) in
                            DispatchQueue.main.async {
                                guard currentProgress != 1 else {
                                    completion(url!)
                                    return
                                }
                            }
                        }
                        return
                    }
                })
            }
        }
    }

}


