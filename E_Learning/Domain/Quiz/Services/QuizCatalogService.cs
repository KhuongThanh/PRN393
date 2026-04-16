using E_Learning.Data;
using E_Learning.Domain.Quiz.Dtos.QuizCatalog;
using E_Learning.Domain.Quiz.Interface;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Quiz.Services
{
    public class QuizCatalogService : IQuizCatalogService
    {
        private readonly AppDbContext _context;

        public QuizCatalogService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<QuizListItemResponse>> GetQuizzesByTopicAsync(Guid topicId)
        {
            var topicExists = await _context.VocabularyTopics
                .AnyAsync(x => x.TopicId == topicId && x.IsActive);

            if (!topicExists)
                throw new Exception("Topic not found or inactive.");

            var quizzes = await _context.Quizzes
                .Where(x => x.TopicId == topicId && x.IsActive)
                .OrderBy(x => x.QuizTitle)
                .Select(x => new QuizListItemResponse
                {
                    QuizId = x.QuizId,
                    TopicId = x.TopicId,
                    QuizTitle = x.QuizTitle,
                    Description = x.Description,
                    TimeLimitMinutes = x.TimeLimitMinutes,
                    IsActive = x.IsActive,
                    TotalQuestions = x.QuizQuestions.Count()
                })
                .ToListAsync();

            return quizzes;
        }
    }
}
