//
//  ViewController.swift
//  Spotify
//
//  Created by Hasan Sultan on 9/6/23.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        fetchData()
    }
    private func fetchData(){
        APICaller.shared.getRecommendationsGenres { result in
            switch result {
            case .success(let model):
                //print(model)
                let genres = model.genres
                var seeds = Set <String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement(){
                        seeds.insert(random)
                    }
                }
                APICaller.shared.getRecommended(genres: seeds){ _ in }
                
            case .failure(let error):
                print(error)
                break
            }
        }
    }

    @objc func didTapSettings(
    ){
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

