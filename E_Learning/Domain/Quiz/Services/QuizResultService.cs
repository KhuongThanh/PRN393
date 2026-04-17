using E_Learning.Data;
using E_Learning.Domain.Quiz.Dtos.QuizResult;
using E_Learning.Domain.Quiz.Interface;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Quiz.Services
{
    public class QuizResultService : IQuizResultService
    {
        private readonly AppDbContext _context;

        public QuizResultService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<QuizResultResponse> GetQuizResultAsync(Guid attemptId, Guid userId)
        {
            var attempt = await _context.QuizAttempts
                .Join(_context.Quizzes,
                    a => a.QuizId,
                    q => q.QuizId,
                    (a, q) => new
                    {
                        Attempt = a,
                        Quiz = q
                    })
                .FirstOrDefaultAsync(x => x.Attempt.AttemptId == attemptId && x.Attempt.UserId == userId);

            if (attempt == null)
                throw new Exception("Attempt not found.");

            if (attempt.Attempt.SubmittedAt == null)
                throw new Exception("Quiz has not been submitted yet.");

            var questions = await _context.QuizQuestions
                .Where(x => x.QuizId == attempt.Attempt.QuizId)
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new
                {
                    x.QuestionId,
                    x.QuestionText,
                    x.WordId,
                    x.Explanation,
                    x.DisplayOrder
                })
                .ToListAsync();

            var questionIds = questions.Select(x => x.QuestionId).ToList();

            var options = await _context.QuizQuestionOptions
                .Where(x => questionIds.Contains(x.QuestionId))
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new
                {
                    x.QuestionId,
                    x.OptionId,
                    x.OptionText,
                    x.IsCorrect,
                    x.DisplayOrder
                })
                .ToListAsync();

            var answers = await _context.QuizAttemptAnswers
                .Where(x => x.AttemptId == attemptId)
                .Select(x => new
                {
                    x.QuestionId,
                    x.SelectedOptionId,
                    x.IsCorrect
                })
                .ToListAsync();

            var answerDict = answers.ToDictionary(x => x.QuestionId, x => x);
            var correctOptionDict = options
                .Where(x => x.IsCorrect)
                .GroupBy(x => x.QuestionId)
                .ToDictionary(g => g.Key, g => g.First().OptionId);

            var result = new QuizResultResponse
            {
                AttemptId = attempt.Attempt.AttemptId,
                QuizId = attempt.Attempt.QuizId,
                QuizTitle = attempt.Quiz.QuizTitle,
                StartedAt = attempt.Attempt.StartedAt,
                SubmittedAt = attempt.Attempt.SubmittedAt,
                TotalQuestions = attempt.Attempt.TotalQuestions,
                CorrectAnswers = attempt.Attempt.CorrectAnswers,
                Score = attempt.Attempt.Score ?? 0m
            };

            foreach (var question in questions)
            {
                answerDict.TryGetValue(question.QuestionId, out var answer);
                correctOptionDict.TryGetValue(question.QuestionId, out var correctOptionId);

                var questionResponse = new QuizResultQuestionResponse
                {
                    QuestionId = question.QuestionId,
                    QuestionText = question.QuestionText,
                    WordId = question.WordId,
                    SelectedOptionId = answer?.SelectedOptionId,
                    CorrectOptionId = correctOptionId == Guid.Empty ? null : correctOptionId,
                    IsCorrect = answer?.IsCorrect ?? false,
                    Explanation = question.Explanation
                };

                questionResponse.Options = options
                    .Where(x => x.QuestionId == question.QuestionId)
                    .OrderBy(x => x.DisplayOrder)
                    .Select(x => new QuizQuestionOptionResultResponse
                    {
                        OptionId = x.OptionId,
                        OptionText = x.OptionText,
                        IsCorrect = x.IsCorrect,
                        DisplayOrder = x.DisplayOrder
                    })
                    .ToList();

                result.Questions.Add(questionResponse);
            }

            return result;
        }

        public async Task<List<QuizAttemptHistoryItemResponse>> GetMyQuizHistoryAsync(Guid userId)
        {
            var history = await
                (from a in _context.QuizAttempts
                 join q in _context.Quizzes on a.QuizId equals q.QuizId
                 join t in _context.VocabularyTopics on q.TopicId equals t.TopicId
                 where a.UserId == userId
                 orderby a.SubmittedAt descending, a.StartedAt descending
                 select new QuizAttemptHistoryItemResponse
                 {
                     AttemptId = a.AttemptId,
                     QuizId = a.QuizId,
                     QuizTitle = q.QuizTitle,
                     TopicId = t.TopicId,
                     TopicName = t.TopicName,
                     StartedAt = a.StartedAt,
                     SubmittedAt = a.SubmittedAt,
                     TotalQuestions = a.TotalQuestions,
                     CorrectAnswers = a.CorrectAnswers,
                     Score = a.Score
                 })
                .ToListAsync();

            return history;
        }
    }
}
