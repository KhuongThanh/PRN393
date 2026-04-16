using E_Learning.Data;
using E_Learning.Domain.Dashboard.Dtos;
using E_Learning.Domain.Dashboard.Interface;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Dashboard.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly AppDbContext _context;

        public DashboardService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<UserDashboardDto> GetUserDashboardAsync(Guid userId)
        {
            var today = DateTime.UtcNow.Date;
            var tomorrow = today.AddDays(1);

            var profile = await _context.UserProfiles
                .FirstOrDefaultAsync(x => x.UserId == userId);

            var learnedWordIds = await _context.UserWordProgresses
                .Where(x => x.UserId == userId && x.IsLearned)
                .Select(x => x.WordId)
                .Distinct()
                .ToListAsync();

            var learnedWordCount = learnedWordIds.Count;

            var learnedTopicCount = await _context.VocabularyWords
                .Where(x => learnedWordIds.Contains(x.WordId))
                .Select(x => x.TopicId)
                .Distinct()
                .CountAsync();

            var favoriteWordCount = await _context.UserFavoriteWords
                .Where(x => x.UserId == userId)
                .CountAsync();

            var todayStudiedWordCount = await _context.UserWordProgresses
                .Where(x => x.UserId == userId
                            && x.LastStudiedAt != null
                            && x.LastStudiedAt >= today
                            && x.LastStudiedAt < tomorrow)
                .Select(x => x.WordId)
                .Distinct()
                .CountAsync();

            var targetDailyWords = profile?.TargetDailyWords ?? 10;

            var dailyProgressPercent = targetDailyWords <= 0
                ? 0
                : Math.Min(100, (int)Math.Round((double)todayStudiedWordCount * 100 / targetDailyWords));

            var latestQuiz = await (
                from a in _context.QuizAttempts
                join q in _context.Quizzes on a.QuizId equals q.QuizId
                where a.UserId == userId && a.SubmittedAt != null
                orderby a.SubmittedAt descending
                select new LatestQuizResultDto
                {
                    AttemptId = a.AttemptId,
                    QuizId = a.QuizId,
                    QuizTitle = q.QuizTitle,
                    SubmittedAt = a.SubmittedAt,
                    TotalQuestions = a.TotalQuestions,
                    CorrectAnswers = a.CorrectAnswers,
                    Score = a.Score
                }
            ).FirstOrDefaultAsync();

            return new UserDashboardDto
            {
                LearnedTopicCount = learnedTopicCount,
                LearnedWordCount = learnedWordCount,
                FavoriteWordCount = favoriteWordCount,
                TargetDailyWords = targetDailyWords,
                TodayStudiedWordCount = todayStudiedWordCount,
                DailyProgressPercent = dailyProgressPercent,
                LatestQuiz = latestQuiz
            };
        }

        public async Task<AdminDashboardDto> GetAdminDashboardAsync()
        {
            var totalUsers = await _context.Users.CountAsync();
            var totalTopics = await _context.VocabularyTopics.CountAsync();
            var totalWords = await _context.VocabularyWords.CountAsync();
            var totalQuizzes = await _context.Quizzes.CountAsync();
            var totalFlashcardSessions = await _context.StudySessions.CountAsync();
            var totalQuizAttempts = await _context.QuizAttempts.CountAsync();

            return new AdminDashboardDto
            {
                TotalUsers = totalUsers,
                TotalTopics = totalTopics,
                TotalWords = totalWords,
                TotalQuizzes = totalQuizzes,
                TotalFlashcardSessions = totalFlashcardSessions,
                TotalQuizAttempts = totalQuizAttempts
            };
        }
    }
}