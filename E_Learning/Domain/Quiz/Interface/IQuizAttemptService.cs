using E_Learning.Domain.Quiz.Dtos.QuizAttempt;

namespace E_Learning.Domain.Quiz.Interface
{
    public interface IQuizAttemptService
    {
        Task<StartQuizResponse> StartQuizAsync(Guid quizId, Guid userId);
        Task<List<QuizQuestionResponse>> GetQuizQuestionsAsync(Guid attemptId, Guid userId);
        Task<SaveQuizAnswerResponse> SaveAnswerAsync(Guid attemptId, Guid userId, SaveQuizAnswerRequest request);
        Task<SubmitQuizResponse> SubmitQuizAsync(Guid attemptId, Guid userId);
    }
}
