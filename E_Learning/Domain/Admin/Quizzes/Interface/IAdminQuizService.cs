using E_Learning.Domain.Admin.Quizzes.Dtos;

namespace E_Learning.Domain.Admin.Quizzes.Interface
{
    public interface IAdminQuizService
    {
        Task<List<AdminQuizListItemDto>> GetByTopicAsync(Guid topicId);
        Task<AdminQuizDetailDto> GetByIdAsync(Guid quizId);
        Task<AdminQuizDetailDto> CreateAsync(Guid topicId, CreateQuizRequest request);
        Task<AdminQuizDetailDto> UpdateAsync(Guid quizId, UpdateQuizRequest request);
        Task ToggleActiveAsync(Guid quizId, bool isActive);
        Task DeleteAsync(Guid quizId);
    }
}
