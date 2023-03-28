//
//  imageextensions.swift
//  ebac-noticias
//
//  Created by Josaphat Campos Pereira on 28/03/23.
//
import UIKit

extension UIImageView {
    func load(url:URL){
        DispatchQueue.global().async {[weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
