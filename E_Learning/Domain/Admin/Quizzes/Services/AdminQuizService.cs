using Microsoft.EntityFrameworkCore;
using E_Learning.Data;
using E_Learning.Domain.Admin.Quizzes.Dtos;
using E_Learning.Domain.Admin.Quizzes.Interface;
using QuizEntity = E_Learning.Entity.Quiz;

namespace E_Learning.Domain.Admin.Quizzes.Services
{
    public class AdminQuizService : IAdminQuizService
    {
        private readonly AppDbContext _context;

        public AdminQuizService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<AdminQuizListItemDto>> GetByTopicAsync(Guid topicId)
        {
            var topicExists = await _context.VocabularyTopics
                .AnyAsync(x => x.TopicId == topicId);

            if (!topicExists)
                throw new KeyNotFoundException("Topic not found.");

            var quizzes = await _context.Quizzes
                .Where(x => x.TopicId == topicId)
                .OrderBy(x => x.QuizTitle)
                .Select(x => new AdminQuizListItemDto
                {
                    QuizId = x.QuizId,
                    TopicId = x.TopicId,
                    QuizTitle = x.QuizTitle,
                    Description = x.Description,
                    TimeLimitMinutes = x.TimeLimitMinutes,
                    IsActive = x.IsActive,
                    TotalQuestions = _context.QuizQuestions.Count(q => q.QuizId == x.QuizId),
                    TotalAttempts = _context.QuizAttempts.Count(a => a.QuizId == x.QuizId)
                })
                .ToListAsync();

            return quizzes;
        }

        public async Task<AdminQuizDetailDto> GetByIdAsync(Guid quizId)
        {
            var quiz = await _context.Quizzes
                .FirstOrDefaultAsync(x => x.QuizId == quizId);

            if (quiz == null)
                throw new KeyNotFoundException("Quiz not found.");

            return MapToDetailDto(quiz);
        }

        public async Task<AdminQuizDetailDto> CreateAsync(Guid topicId, CreateQuizRequest request)
        {
            var topicExists = await _context.VocabularyTopics
                .AnyAsync(x => x.TopicId == topicId);

            if (!topicExists)
                throw new KeyNotFoundException("Topic not found.");

            var normalizedTitle = request.QuizTitle.Trim();

            var duplicated = await _context.Quizzes
                .AnyAsync(x => x.TopicId == topicId && x.QuizTitle == normalizedTitle);

            if (duplicated)
                throw new InvalidOperationException("Quiz title already exists in this topic.");

            var quiz = new QuizEntity
            {
                QuizId = Guid.NewGuid(),
                TopicId = topicId,
                QuizTitle = normalizedTitle,
                Description = request.Description?.Trim(),
                TimeLimitMinutes = request.TimeLimitMinutes,
                IsActive = request.IsActive,
                CreatedAt = DateTime.UtcNow
            };

            _context.Quizzes.Add(quiz);
            await _context.SaveChangesAsync();

            return MapToDetailDto(quiz);
        }

        public async Task<AdminQuizDetailDto> UpdateAsync(Guid quizId, UpdateQuizRequest request)
        {
            var quiz = await _context.Quizzes
                .FirstOrDefaultAsync(x => x.QuizId == quizId);

            if (quiz == null)
                throw new KeyNotFoundException("Quiz not found.");

            var normalizedTitle = request.QuizTitle.Trim();

            var duplicated = await _context.Quizzes
                .AnyAsync(x => x.QuizId != quizId
                            && x.TopicId == quiz.TopicId
                            && x.QuizTitle == normalizedTitle);

            if (duplicated)
                throw new InvalidOperationException("Quiz title already exists in this topic.");

            quiz.QuizTitle = normalizedTitle;
            quiz.Description = request.Description?.Trim();
            quiz.TimeLimitMinutes = request.TimeLimitMinutes;
            quiz.IsActive = request.IsActive;
            quiz.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToDetailDto(quiz);
        }

        public async Task ToggleActiveAsync(Guid quizId, bool isActive)
        {
            var quiz = await _context.Quizzes
                .FirstOrDefaultAsync(x => x.QuizId == quizId);

            if (quiz == null)
                throw new KeyNotFoundException("Quiz not found.");

            quiz.IsActive = isActive;
            quiz.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Guid quizId)
        {
            var quiz = await _context.Quizzes
                .FirstOrDefaultAsync(x => x.QuizId == quizId);

            if (quiz == null)
                throw new KeyNotFoundException("Quiz not found.");

            var hasQuestions = await _context.QuizQuestions.AnyAsync(x => x.QuizId == quizId);
            var hasAttempts = await _context.QuizAttempts.AnyAsync(x => x.QuizId == quizId);

            if (hasQuestions || hasAttempts)
                throw new InvalidOperationException("Cannot delete quiz because related questions or attempts exist.");

            _context.Quizzes.Remove(quiz);
            await _context.SaveChangesAsync();
        }

        private static AdminQuizDetailDto MapToDetailDto(QuizEntity quiz)
        {
            return new AdminQuizDetailDto
            {
                QuizId = quiz.QuizId,
                TopicId = quiz.TopicId,
                QuizTitle = quiz.QuizTitle,
                Description = quiz.Description,
                TimeLimitMinutes = quiz.TimeLimitMinutes,
                IsActive = quiz.IsActive
            };
        }
    }
}