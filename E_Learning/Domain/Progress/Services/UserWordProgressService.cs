using E_Learning.Data;
using E_Learning.Domain.Progress.Dtos;
using E_Learning.Domain.Progress.Interface;
using E_Learning.Entity;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Progress.Services
{
    public class UserWordProgressService : IUserWordProgressService
    {
        private readonly AppDbContext _context;

        // Rule tạm: đúng 3 lần thì xem là learned
        private const int LearnedThreshold = 3;

        public UserWordProgressService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<ProgressSummaryDto> GetSummaryAsync(Guid userId)
        {
            var totalWords = await _context.VocabularyWords
                .CountAsync(w => w.IsActive);

            var learnedWords = await _context.UserWordProgresses
                .Where(p => p.UserId == userId && p.IsLearned)
                .Join(
                    _context.VocabularyWords.Where(w => w.IsActive),
                    p => p.WordId,
                    w => w.WordId,
                    (p, w) => p
                )
                .CountAsync();

            var aggregate = await _context.UserWordProgresses
                .Where(p => p.UserId == userId)
                .GroupBy(_ => 1)
                .Select(g => new
                {
                    TotalCorrect = g.Sum(x => x.CorrectCount),
                    TotalIncorrect = g.Sum(x => x.IncorrectCount),
                    LastStudiedAt = g.Max(x => x.LastStudiedAt)
                })
                .FirstOrDefaultAsync();

            var notLearnedWords = totalWords - learnedWords;
            if (notLearnedWords < 0) notLearnedWords = 0;

            return new ProgressSummaryDto
            {
                TotalWords = totalWords,
                LearnedWords = learnedWords,
                NotLearnedWords = notLearnedWords,
                TotalCorrectCount = aggregate?.TotalCorrect ?? 0,
                TotalIncorrectCount = aggregate?.TotalIncorrect ?? 0,
                LastStudiedAt = aggregate?.LastStudiedAt,
                CompletionRate = totalWords == 0 ? 0 : Math.Round((double)learnedWords / totalWords * 100, 2)
            };
        }

        public async Task<WordProgressDto> GetWordProgressAsync(Guid userId, Guid wordId)
        {
            var word = await _context.VocabularyWords
                .Join(
                    _context.VocabularyTopics,
                    w => w.TopicId,
                    t => t.TopicId,
                    (w, t) => new
                    {
                        w.WordId,
                        w.WordText,
                        w.Meaning,
                        w.TopicId,
                        TopicName = t.TopicName,
                        w.IsActive
                    }
                )
                .FirstOrDefaultAsync(x => x.WordId == wordId);

            if (word == null || !word.IsActive)
                throw new KeyNotFoundException("Word not found.");

            var progress = await _context.UserWordProgresses
                .FirstOrDefaultAsync(p => p.UserId == userId && p.WordId == wordId);

            return new WordProgressDto
            {
                ProgressId = progress?.ProgressId,
                WordId = word.WordId,
                WordText = word.WordText,
                Meaning = word.Meaning,
                TopicId = word.TopicId,
                TopicName = word.TopicName,
                HasProgress = progress != null,
                IsLearned = progress?.IsLearned ?? false,
                CorrectCount = progress?.CorrectCount ?? 0,
                IncorrectCount = progress?.IncorrectCount ?? 0,
                LastStudiedAt = progress?.LastStudiedAt
            };
        }

        public async Task<WordProgressDto> UpdateWordProgressAsync(Guid userId, Guid wordId, UpdateWordProgressRequest request)
        {
            var word = await _context.VocabularyWords
                .Join(
                    _context.VocabularyTopics,
                    w => w.TopicId,
                    t => t.TopicId,
                    (w, t) => new
                    {
                        Word = w,
                        TopicName = t.TopicName
                    }
                )
                .FirstOrDefaultAsync(x => x.Word.WordId == wordId);

            if (word == null || !word.Word.IsActive)
                throw new KeyNotFoundException("Word not found.");

            var progress = await _context.UserWordProgresses
                .FirstOrDefaultAsync(p => p.UserId == userId && p.WordId == wordId);

            if (progress == null)
            {
                progress = new UserWordProgress
                {
                    UserId = userId,
                    WordId = wordId,
                    IsLearned = false,
                    CorrectCount = 0,
                    IncorrectCount = 0,
                    CreatedAt = DateTime.UtcNow
                };

                _context.UserWordProgresses.Add(progress);
            }

            if (request.IsCorrect)
            {
                progress.CorrectCount += 1;
            }
            else
            {
                progress.IncorrectCount += 1;
            }

            progress.LastStudiedAt = DateTime.UtcNow;
            progress.UpdatedAt = DateTime.UtcNow;

            if (request.MarkLearned.HasValue)
            {
                progress.IsLearned = request.MarkLearned.Value;
            }
            else
            {
                progress.IsLearned = progress.CorrectCount >= LearnedThreshold;
            }

            await _context.SaveChangesAsync();

            return new WordProgressDto
            {
                ProgressId = progress.ProgressId,
                WordId = word.Word.WordId,
                WordText = word.Word.WordText,
                Meaning = word.Word.Meaning,
                TopicId = word.Word.TopicId,
                TopicName = word.TopicName,
                HasProgress = true,
                IsLearned = progress.IsLearned,
                CorrectCount = progress.CorrectCount,
                IncorrectCount = progress.IncorrectCount,
                LastStudiedAt = progress.LastStudiedAt
            };
        }

        public async Task<TopicProgressDto> GetTopicProgressAsync(Guid userId, Guid topicId)
        {
            var topic = await _context.VocabularyTopics
                .FirstOrDefaultAsync(t => t.TopicId == topicId && t.IsActive);

            if (topic == null)
                throw new KeyNotFoundException("Topic not found.");

            var totalWords = await _context.VocabularyWords
                .CountAsync(w => w.TopicId == topicId && w.IsActive);

            var progressRows = await _context.UserWordProgresses
                .Where(p => p.UserId == userId)
                .Join(
                    _context.VocabularyWords.Where(w => w.TopicId == topicId && w.IsActive),
                    p => p.WordId,
                    w => w.WordId,
                    (p, w) => p
                )
                .ToListAsync();

            var learnedWords = progressRows.Count(x => x.IsLearned);
            var notLearnedWords = totalWords - learnedWords;
            if (notLearnedWords < 0) notLearnedWords = 0;

            return new TopicProgressDto
            {
                TopicId = topic.TopicId,
                TopicName = topic.TopicName,
                TotalWords = totalWords,
                LearnedWords = learnedWords,
                NotLearnedWords = notLearnedWords,
                TotalCorrectCount = progressRows.Sum(x => x.CorrectCount),
                TotalIncorrectCount = progressRows.Sum(x => x.IncorrectCount),
                LastStudiedAt = progressRows
                    .Where(x => x.LastStudiedAt.HasValue)
                    .OrderByDescending(x => x.LastStudiedAt)
                    .Select(x => x.LastStudiedAt)
                    .FirstOrDefault(),
                CompletionRate = totalWords == 0 ? 0 : Math.Round((double)learnedWords / totalWords * 100, 2)
            };
        }

        public async Task UpdateFromQuizAsync(Guid attemptId, Guid userId)
        {
            var answerDetails = await
                (from a in _context.QuizAttemptAnswers
                 join q in _context.QuizQuestions
                     on a.QuestionId equals q.QuestionId
                 where a.AttemptId == attemptId
                       && q.WordId != null
                 select new
                 {
                     WordId = q.WordId.Value,
                     a.IsCorrect
                 })
                .ToListAsync();

            if (!answerDetails.Any())
                return;

            foreach (var item in answerDetails)
            {
                var progress = await _context.UserWordProgresses
                    .FirstOrDefaultAsync(x => x.UserId == userId && x.WordId == item.WordId);

                if (progress == null)
                {
                    progress = new UserWordProgress
                    {
                        ProgressId = Guid.NewGuid(),
                        UserId = userId,
                        WordId = item.WordId,
                        IsLearned = false,
                        CorrectCount = 0,
                        IncorrectCount = 0,
                        LastStudiedAt = DateTime.UtcNow,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = null
                    };

                    _context.UserWordProgresses.Add(progress);
                }

                if (item.IsCorrect)
                    progress.CorrectCount++;
                else
                    progress.IncorrectCount++;

                progress.LastStudiedAt = DateTime.UtcNow;
                progress.UpdatedAt = DateTime.UtcNow;

                // Rule tạm: đúng 3 lần thì coi như đã học
                if (progress.CorrectCount >= 3)
                    progress.IsLearned = true;
            }

            await _context.SaveChangesAsync();
        }
    }
}
