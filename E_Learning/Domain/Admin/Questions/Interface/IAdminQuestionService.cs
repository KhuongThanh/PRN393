using E_Learning.Domain.Admin.Questions.Dtos;

namespace E_Learning.Domain.Admin.Questions.Interface
{
    public interface IAdminQuestionService
    {
        Task<List<AdminQuestionListItemDto>> GetByQuizAsync(Guid quizId);
        Task<AdminQuestionDetailDto> GetByIdAsync(Guid questionId);
        Task<AdminQuestionDetailDto> CreateAsync(Guid quizId, CreateQuestionRequest request);
        Task<AdminQuestionDetailDto> UpdateAsync(Guid questionId, UpdateQuestionRequest request);
        Task DeleteAsync(Guid questionId);
    }
}
