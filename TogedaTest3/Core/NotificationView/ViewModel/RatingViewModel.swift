//
//  RatingViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.06.24.
//

import SwiftUI

class RatingViewModel: ObservableObject {
    struct RateParticipant: Hashable {
        var postId: String
        var userId: String
        var rating: Components.Schemas.ParticipationRatingDto
    }
    @Published var openReviewSheet: Bool = false
    @Published var reviewAlertBody: Components.Schemas.AlertBodyReviewEndedPost?
    @Published var post: Components.Schemas.PostResponseDto?
    @Published var ratePostParticipants: [RateParticipant] = []
    
    @Published var showUserLike = false
    @Published var showUserReport = false
    @Published var selectedExtendedUser: Components.Schemas.ExtendedMiniUser?
    
    func resetAll() {
        selectedExtendedUser = nil
        showUserReport = false
        showUserLike = false
        reviewAlertBody = nil
        post = nil
        ratePostParticipants = []
    }
    
    func submitAllLikes() async {
        guard !ratePostParticipants.isEmpty else { return }

        await withTaskGroup(of: Void.self) { group in
            for rating in ratePostParticipants {
                group.addTask {
                    // Each rating submission is run as a separate async task.
                    do {
                        // Adjust the API call to match your implementation
                        _ = try await APIClient.shared.giveRatingToParticipant(
                            postId: rating.postId,
                            userId: rating.userId,
                            ratingBody: rating.rating
                        )
                    } catch {
                        print("Error submitting like for user \(rating.userId): \(error)")
                    }
                }
            }
        }

        // Clear the array after submission to prevent duplicate submissions
        DispatchQueue.main.async {
            self.ratePostParticipants.removeAll()
        }
    }
}
