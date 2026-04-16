using E_Learning.Domain.Quiz.Dtos.QuizResult;

namespace E_Learning.Domain.Quiz.Interface
{
    public interface IQuizResultService
    {
        Task<QuizResultResponse> GetQuizResultAsync(Guid attemptId, Guid userId);
        Task<List<QuizAttemptHistoryItemResponse>> GetMyQuizHistoryAsync(Guid userId);
    }
}
