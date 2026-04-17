using E_Learning.Data;
using E_Learning.Domain.Admin.Questions.Dtos;
using E_Learning.Domain.Admin.Questions.Interface;
using E_Learning.Entity;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Admin.Questions.Services
{
    public class AdminQuestionService : IAdminQuestionService
    {
        private readonly AppDbContext _context;

        public AdminQuestionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<AdminQuestionListItemDto>> GetByQuizAsync(Guid quizId)
        {
            var quizExists = await _context.Quizzes
                .AnyAsync(x => x.QuizId == quizId);

            if (!quizExists)
                throw new KeyNotFoundException("Quiz not found.");

            var questions = await _context.QuizQuestions
                .Where(x => x.QuizId == quizId)
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new AdminQuestionListItemDto
                {
                    QuestionId = x.QuestionId,
                    QuizId = x.QuizId,
                    WordId = x.WordId,
                    QuestionText = x.QuestionText,
                    Explanation = x.Explanation,
                    DisplayOrder = x.DisplayOrder,
                    TotalOptions = _context.QuizQuestionOptions.Count(o => o.QuestionId == x.QuestionId)
                })
                .ToListAsync();

            return questions;
        }

        public async Task<AdminQuestionDetailDto> GetByIdAsync(Guid questionId)
        {
            var question = await _context.QuizQuestions
                .FirstOrDefaultAsync(x => x.QuestionId == questionId);

            if (question == null)
                throw new KeyNotFoundException("Question not found.");

            return MapToDetailDto(question);
        }

        public async Task<AdminQuestionDetailDto> CreateAsync(Guid quizId, CreateQuestionRequest request)
        {
            var quizExists = await _context.Quizzes
                .AnyAsync(x => x.QuizId == quizId);

            if (!quizExists)
                throw new KeyNotFoundException("Quiz not found.");

            if (request.WordId.HasValue)
            {
                var wordExists = await _context.VocabularyWords
                    .AnyAsync(x => x.WordId == request.WordId.Value);

                if (!wordExists)
                    throw new KeyNotFoundException("Word not found.");
            }

            var normalizedQuestionText = request.QuestionText.Trim();

            var duplicatedOrder = await _context.QuizQuestions
                .AnyAsync(x => x.QuizId == quizId && x.DisplayOrder == request.DisplayOrder);

            if (duplicatedOrder)
                throw new InvalidOperationException("DisplayOrder already exists in this quiz.");

            var question = new QuizQuestion
            {
                QuestionId = Guid.NewGuid(),
                QuizId = quizId,
                WordId = request.WordId,
                QuestionText = normalizedQuestionText,
                Explanation = request.Explanation?.Trim(),
                DisplayOrder = request.DisplayOrder,
                CreatedAt = DateTime.UtcNow
            };

            _context.QuizQuestions.Add(question);
            await _context.SaveChangesAsync();

            return MapToDetailDto(question);
        }

        public async Task<AdminQuestionDetailDto> UpdateAsync(Guid questionId, UpdateQuestionRequest request)
        {
            var question = await _context.QuizQuestions
                .FirstOrDefaultAsync(x => x.QuestionId == questionId);

            if (question == null)
                throw new KeyNotFoundException("Question not found.");

            if (request.WordId.HasValue)
            {
                var wordExists = await _context.VocabularyWords
                    .AnyAsync(x => x.WordId == request.WordId.Value);

                if (!wordExists)
                    throw new KeyNotFoundException("Word not found.");
            }

            var normalizedQuestionText = request.QuestionText.Trim();

            var duplicatedOrder = await _context.QuizQuestions
                .AnyAsync(x => x.QuestionId != questionId
                            && x.QuizId == question.QuizId
                            && x.DisplayOrder == request.DisplayOrder);

            if (duplicatedOrder)
                throw new InvalidOperationException("DisplayOrder already exists in this quiz.");

            question.WordId = request.WordId;
            question.QuestionText = normalizedQuestionText;
            question.Explanation = request.Explanation?.Trim();
            question.DisplayOrder = request.DisplayOrder;

            await _context.SaveChangesAsync();

            return MapToDetailDto(question);
        }

        public async Task DeleteAsync(Guid questionId)
        {
            var question = await _context.QuizQuestions
                .FirstOrDefaultAsync(x => x.QuestionId == questionId);

            if (question == null)
                throw new KeyNotFoundException("Question not found.");

            var hasAnswers = await _context.QuizAttemptAnswers
                .AnyAsync(x => x.QuestionId == questionId);

            if (hasAnswers)
                throw new InvalidOperationException("Cannot delete question because quiz answers already exist.");

            _context.QuizQuestions.Remove(question);
            await _context.SaveChangesAsync();
        }

        private static AdminQuestionDetailDto MapToDetailDto(QuizQuestion question)
        {
            return new AdminQuestionDetailDto
            {
                QuestionId = question.QuestionId,
                QuizId = question.QuizId,
                WordId = question.WordId,
                QuestionText = question.QuestionText,
                Explanation = question.Explanation,
                DisplayOrder = question.DisplayOrder
            };
        }
    }
}