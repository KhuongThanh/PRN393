using E_Learning.Domain.Quiz.Dtos;
using E_Learning.Domain.Quiz.Dtos.QuizCatalog;

namespace E_Learning.Domain.Quiz.Interface
{
    public interface IQuizCatalogService
    {
        Task<List<QuizListItemResponse>> GetQuizzesByTopicAsync(Guid topicId);
    }
}
