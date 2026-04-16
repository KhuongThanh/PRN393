using E_Learning.Data;
using E_Learning.Domain.Progress.Interface;
using E_Learning.Domain.Quiz.Dtos.QuizAttempt;
using E_Learning.Domain.Quiz.Interface;
using E_Learning.Entity;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Quiz.Services
{
    public class QuizAttemptService : IQuizAttemptService
    {
        private readonly AppDbContext _context;
        private readonly IUserWordProgressService _userWordProgressService;

        public QuizAttemptService(
            AppDbContext context,
            IUserWordProgressService userWordProgressService)
        {
            _context = context;
            _userWordProgressService = userWordProgressService;
        }

        public async Task<StartQuizResponse> StartQuizAsync(Guid quizId, Guid userId)
        {
            var quiz = await _context.Quizzes
                .Include(x => x.QuizQuestions)
                .FirstOrDefaultAsync(x => x.QuizId == quizId && x.IsActive);

            if (quiz == null)
                throw new Exception("Quiz not found or inactive.");

            var totalQuestions = quiz.QuizQuestions.Count;
            if (totalQuestions <= 0)
                throw new Exception("Quiz has no questions.");

            var attempt = new QuizAttempt
            {
                AttemptId = Guid.NewGuid(),
                QuizId = quiz.QuizId,
                UserId = userId,
                StartedAt = DateTime.UtcNow,
                TotalQuestions = totalQuestions,
                CorrectAnswers = 0,
                Score = 0
            };

            _context.QuizAttempts.Add(attempt);
            await _context.SaveChangesAsync();

            return new StartQuizResponse
            {
                AttemptId = attempt.AttemptId,
                QuizId = quiz.QuizId,
                QuizTitle = quiz.QuizTitle,
                StartedAt = attempt.StartedAt,
                TotalQuestions = totalQuestions,
                TimeLimitMinutes = quiz.TimeLimitMinutes
            };
        }

        public async Task<List<QuizQuestionResponse>> GetQuizQuestionsAsync(Guid attemptId, Guid userId)
        {
            var attempt = await _context.QuizAttempts
                .FirstOrDefaultAsync(x => x.AttemptId == attemptId && x.UserId == userId);

            if (attempt == null)
                throw new Exception("Attempt not found.");

            if (attempt.SubmittedAt != null)
                throw new Exception("Quiz already submitted.");

            var selectedAnswers = await _context.QuizAttemptAnswers
                .Where(x => x.AttemptId == attemptId)
                .ToDictionaryAsync(x => x.QuestionId, x => x.SelectedOptionId);

            var questions = await _context.QuizQuestions
                .Where(x => x.QuizId == attempt.QuizId)
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new QuizQuestionResponse
                {
                    QuestionId = x.QuestionId,
                    QuestionText = x.QuestionText,
                    DisplayOrder = x.DisplayOrder,
                    WordId = x.WordId
                })
                .ToListAsync();

            var questionIds = questions.Select(x => x.QuestionId).ToList();

            var options = await _context.QuizQuestionOptions
                .Where(x => questionIds.Contains(x.QuestionId))
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new
                {
                    x.QuestionId,
                    Option = new QuizQuestionOptionResponse
                    {
                        OptionId = x.OptionId,
                        OptionText = x.OptionText,
                        DisplayOrder = x.DisplayOrder
                    }
                })
                .ToListAsync();

            foreach (var question in questions)
            {
                question.Options = options
                    .Where(x => x.QuestionId == question.QuestionId)
                    .Select(x => x.Option)
                    .ToList();

                if (selectedAnswers.TryGetValue(question.QuestionId, out var selectedOptionId))
                {
                    question.SelectedOptionId = selectedOptionId;
                }
            }

            return questions;
        }

        public async Task<SaveQuizAnswerResponse> SaveAnswerAsync(
            Guid attemptId,
            Guid userId,
            SaveQuizAnswerRequest request)
        {
            var attempt = await _context.QuizAttempts
                .FirstOrDefaultAsync(x => x.AttemptId == attemptId && x.UserId == userId);

            if (attempt == null)
                throw new Exception("Attempt not found.");

            if (attempt.SubmittedAt != null)
                throw new Exception("Quiz already submitted.");

            var question = await _context.QuizQuestions
                .FirstOrDefaultAsync(x => x.QuestionId == request.QuestionId && x.QuizId == attempt.QuizId);

            if (question == null)
                throw new Exception("Question does not belong to this quiz.");

            var option = await _context.QuizQuestionOptions
                .FirstOrDefaultAsync(x => x.OptionId == request.SelectedOptionId && x.QuestionId == request.QuestionId);

            if (option == null)
                throw new Exception("Option does not belong to this question.");

            var answer = await _context.QuizAttemptAnswers
                .FirstOrDefaultAsync(x => x.AttemptId == attemptId && x.QuestionId == request.QuestionId);

            if (answer == null)
            {
                answer = new QuizAttemptAnswer
                {
                    AttemptAnswerId = Guid.NewGuid(),
                    AttemptId = attemptId,
                    QuestionId = request.QuestionId,
                    SelectedOptionId = request.SelectedOptionId,
                    IsCorrect = option.IsCorrect,
                    AnsweredAt = DateTime.UtcNow
                };

                _context.QuizAttemptAnswers.Add(answer);
            }
            else
            {
                answer.SelectedOptionId = request.SelectedOptionId;
                answer.IsCorrect = option.IsCorrect;
                answer.AnsweredAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();

            return new SaveQuizAnswerResponse
            {
                AttemptId = attemptId,
                QuestionId = request.QuestionId,
                SelectedOptionId = request.SelectedOptionId,
                IsCorrect = option.IsCorrect,
                AnsweredAt = answer.AnsweredAt
            };
        }

        public async Task<SubmitQuizResponse> SubmitQuizAsync(Guid attemptId, Guid userId)
        {
            var attempt = await _context.QuizAttempts
                .FirstOrDefaultAsync(x => x.AttemptId == attemptId && x.UserId == userId);

            if (attempt == null)
                throw new Exception("Attempt not found.");

            if (attempt.SubmittedAt != null)
                throw new Exception("Quiz already submitted.");

            var answers = await _context.QuizAttemptAnswers
                .Where(x => x.AttemptId == attemptId)
                .ToListAsync();

            var correctAnswers = answers.Count(x => x.IsCorrect);
            var score = attempt.TotalQuestions == 0
                ? 0
                : Math.Round((double)correctAnswers * 10 / attempt.TotalQuestions, 2);

            attempt.SubmittedAt = DateTime.UtcNow;
            attempt.CorrectAnswers = correctAnswers;
            attempt.Score = (decimal)score;

            await _context.SaveChangesAsync();

            await _userWordProgressService.UpdateFromQuizAsync(attemptId, userId);

            return new SubmitQuizResponse
            {
                AttemptId = attempt.AttemptId,
                QuizId = attempt.QuizId,
                StartedAt = attempt.StartedAt,
                SubmittedAt = attempt.SubmittedAt.Value,
                TotalQuestions = attempt.TotalQuestions,
                CorrectAnswers = correctAnswers,
                Score = score
            };
        }
    }
}