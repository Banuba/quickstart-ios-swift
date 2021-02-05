//
//  ARCloudManager.swift
//  quickstart-ios-swift
//
//  Created by Pavel Sakhanko on 03/02/2021.
//  Copyright © 2021 Ivan Gulidov. All rights reserved.
//

import Foundation
import BanubaARCloudSDK

import BanubaSdk

class ARCloudManager {
    
    fileprivate static let banubaARCloud = BanubaARCloud(uuidString: cloudMasksToken)

    static func fetchAREffects(complition: @escaping ([AREffectModel]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            var array: [AREffectModel] = []

            ARCloudManager.banubaARCloud.getAREffects {(effectsArray, _) in
                effectsArray?.forEach({ effect in
                    let effectModel = AREffectModel(title: effect.title,
                                                    previewImage: effect.previewImage.absoluteString)
                    array.append(effectModel)
                })
                
                DispatchQueue.main.async {
                    complition(array)
                }
            }
        }
    }
    
    static func loadTappedEffect(effectName: String, complition: @escaping (URL) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            ARCloudManager.banubaARCloud.getAREffects {(effectsArray, _) in
                effectsArray?.forEach({ effect in
                    if effectName == effect.title {
                        var currentProgress: Double?
                        banubaARCloud.downloadArEffect(effect) {(progress) in
                            currentProgress = progress
                        } completion: {(url, error) in
                            DispatchQueue.main.async {
                                if currentProgress == 1.0 {
                                    complition(url!)
                                }
                            }
                        }
                    }
                })
            }
        }
    }

}


