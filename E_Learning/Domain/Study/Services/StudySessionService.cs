using E_Learning.Data;
using E_Learning.Domain.Study.Dtos;
using E_Learning.Domain.Study.Interface;
using E_Learning.Entity;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Study.Services
{
    public class StudySessionService : IStudySessionService
    {
        private readonly AppDbContext _context;

        // giữ cùng rule với progress
        private const int LearnedThreshold = 3;

        public StudySessionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<StudySessionStartResponseDto> StartSessionAsync(Guid userId, StartStudySessionRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.SourceType))
                throw new InvalidOperationException("SourceType is required.");

            var sourceType = request.SourceType.Trim();

            if (sourceType != "Topic" && sourceType != "Favorite")
                throw new InvalidOperationException("SourceType must be either 'Topic' or 'Favorite'.");

            List<FlashcardWordDto> words;
            Guid? topicId = null;
            string? topicName = null;
            string? sourceName = null;

            if (sourceType == "Topic")
            {
                if (!request.TopicId.HasValue)
                    throw new InvalidOperationException("TopicId is required when SourceType = 'Topic'.");

                var topic = await _context.VocabularyTopics
                    .FirstOrDefaultAsync(t => t.TopicId == request.TopicId.Value && t.IsActive);

                if (topic == null)
                    throw new KeyNotFoundException("Topic not found.");

                topicId = topic.TopicId;
                topicName = topic.TopicName;
                sourceName = topic.TopicName;

                var query = _context.VocabularyWords
                    .Where(w => w.TopicId == topic.TopicId && w.IsActive)
                    .OrderBy(w => w.WordText)
                    .Select(w => new FlashcardWordDto
                    {
                        WordId = w.WordId,
                        WordText = w.WordText,
                        Meaning = w.Meaning,
                        ExampleSentence = w.ExampleSentence,
                        PartOfSpeech = w.PartOfSpeech,
                        Phonetic = w.Phonetic,
                        AudioUrl = w.AudioUrl,
                        ImageUrl = w.ImageUrl,
                        DifficultyLevel = w.DifficultyLevel
                    });

                words = request.TakeCount.HasValue && request.TakeCount.Value > 0
                    ? await query.Take(request.TakeCount.Value).ToListAsync()
                    : await query.ToListAsync();
            }
            else
            {
                sourceName = "Favorite Words";

                var query = _context.UserFavoriteWords
                    .Where(f => f.UserId == userId)
                    .Join(
                        _context.VocabularyWords.Where(w => w.IsActive),
                        f => f.WordId,
                        w => w.WordId,
                        (f, w) => new FlashcardWordDto
                        {
                            WordId = w.WordId,
                            WordText = w.WordText,
                            Meaning = w.Meaning,
                            ExampleSentence = w.ExampleSentence,
                            PartOfSpeech = w.PartOfSpeech,
                            Phonetic = w.Phonetic,
                            AudioUrl = w.AudioUrl,
                            ImageUrl = w.ImageUrl,
                            DifficultyLevel = w.DifficultyLevel
                        }
                    )
                    .OrderBy(w => w.WordText);

                words = request.TakeCount.HasValue && request.TakeCount.Value > 0
                    ? await query.Take(request.TakeCount.Value).ToListAsync()
                    : await query.ToListAsync();
            }

            if (!words.Any())
                throw new InvalidOperationException("No words available for this flashcard session.");

            var session = new StudySession
            {
                UserId = userId,
                TopicId = topicId,
                SessionType = "Flashcard",
                SourceType = sourceType,
                SourceName = sourceName,
                StartedAt = DateTime.UtcNow,
                TotalWords = words.Count,
                RememberedCount = 0,
                NotRememberedCount = 0
            };

            _context.StudySessions.Add(session);
            await _context.SaveChangesAsync();

            return new StudySessionStartResponseDto
            {
                SessionId = session.SessionId,
                SourceType = session.SourceType,
                SourceName = session.SourceName,
                TopicId = session.TopicId,
                TopicName = topicName,
                SessionType = session.SessionType,
                StartedAt = session.StartedAt,
                TotalWords = session.TotalWords,
                Words = words
            };
        }

        public async Task<StudySessionReviewResponseDto> ReviewWordAsync(Guid userId, Guid sessionId, ReviewFlashcardRequest request)
        {
            if (request.ReviewOrder < 0)
                throw new InvalidOperationException("ReviewOrder must be >= 0.");

            var session = await _context.StudySessions
                .FirstOrDefaultAsync(s => s.SessionId == sessionId && s.UserId == userId);

            if (session == null)
                throw new KeyNotFoundException("Study session not found.");

            if (session.EndedAt.HasValue)
                throw new InvalidOperationException("This study session has already been finished.");

            VocabularyWord? word;

            if (session.SourceType == "Topic")
            {
                if (!session.TopicId.HasValue)
                    throw new InvalidOperationException("This topic session does not have a valid topic.");

                word = await _context.VocabularyWords
                    .FirstOrDefaultAsync(w =>
                        w.WordId == request.WordId &&
                        w.TopicId == session.TopicId.Value &&
                        w.IsActive);

                if (word == null)
                    throw new KeyNotFoundException("Word not found in this topic session.");
            }
            else if (session.SourceType == "Favorite")
            {
                word = await _context.UserFavoriteWords
                    .Where(f => f.UserId == userId && f.WordId == request.WordId)
                    .Join(
                        _context.VocabularyWords.Where(w => w.IsActive),
                        f => f.WordId,
                        w => w.WordId,
                        (f, w) => w
                    )
                    .FirstOrDefaultAsync();

                if (word == null)
                    throw new KeyNotFoundException("Word not found in favorite list.");
            }
            else
            {
                throw new InvalidOperationException("Unsupported SourceType.");
            }

            var exists = await _context.StudySessionDetails
                .AnyAsync(d => d.SessionId == sessionId && d.WordId == request.WordId);

            if (exists)
                throw new InvalidOperationException("This word has already been reviewed in the session.");

            var reviewedCountBefore = await _context.StudySessionDetails
                .CountAsync(d => d.SessionId == sessionId);

            if (reviewedCountBefore >= session.TotalWords)
                throw new InvalidOperationException("All words in this session have already been reviewed.");

            await using var transaction = await _context.Database.BeginTransactionAsync();

            var detail = new StudySessionDetail
            {
                SessionId = sessionId,
                WordId = request.WordId,
                IsRemembered = request.IsRemembered,
                ReviewOrder = request.ReviewOrder,
                ReviewedAt = DateTime.UtcNow
            };

            _context.StudySessionDetails.Add(detail);

            await UpsertWordProgressAsync(userId, request.WordId, request.IsRemembered);

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            var reviewedCount = reviewedCountBefore + 1;

            var rememberedCount = await _context.StudySessionDetails
                .CountAsync(d => d.SessionId == sessionId && d.IsRemembered);

            var notRememberedCount = await _context.StudySessionDetails
                .CountAsync(d => d.SessionId == sessionId && !d.IsRemembered);

            return new StudySessionReviewResponseDto
            {
                SessionId = sessionId,
                WordId = request.WordId,
                IsRemembered = request.IsRemembered,
                ReviewOrder = request.ReviewOrder,
                ReviewedAt = detail.ReviewedAt,
                ReviewedCount = reviewedCount,
                RemainingCount = Math.Max(0, session.TotalWords - reviewedCount),
                RememberedCount = rememberedCount,
                NotRememberedCount = notRememberedCount,
                TotalWords = session.TotalWords,
                IsCompleted = reviewedCount >= session.TotalWords
            };
        }

        public async Task<StudySessionFinishResponseDto> FinishSessionAsync(Guid userId, Guid sessionId)
        {
            var session = await _context.StudySessions
                .GroupJoin(
                    _context.VocabularyTopics,
                    s => s.TopicId,
                    t => t.TopicId,
                    (s, topics) => new { s, topics }
                )
                .SelectMany(
                    x => x.topics.DefaultIfEmpty(),
                    (x, t) => new
                    {
                        Session = x.s,
                        TopicName = t != null ? t.TopicName : null
                    }
                )
                .FirstOrDefaultAsync(x => x.Session.SessionId == sessionId && x.Session.UserId == userId);

            if (session == null)
                throw new KeyNotFoundException("Study session not found.");

            if (session.Session.EndedAt.HasValue)
                throw new InvalidOperationException("This study session has already been finished.");

            var details = await _context.StudySessionDetails
                .Where(d => d.SessionId == sessionId)
                .Join(
                    _context.VocabularyWords,
                    d => d.WordId,
                    w => w.WordId,
                    (d, w) => new StudySessionDetailItemDto
                    {
                        SessionDetailId = d.SessionDetailId,
                        WordId = w.WordId,
                        WordText = w.WordText,
                        Meaning = w.Meaning,
                        IsRemembered = d.IsRemembered,
                        ReviewOrder = d.ReviewOrder,
                        ReviewedAt = d.ReviewedAt
                    }
                )
                .OrderBy(x => x.ReviewOrder)
                .ThenBy(x => x.ReviewedAt)
                .ToListAsync();

            var rememberedCount = details.Count(x => x.IsRemembered);
            var notRememberedCount = details.Count(x => !x.IsRemembered);

            session.Session.RememberedCount = rememberedCount;
            session.Session.NotRememberedCount = notRememberedCount;
            session.Session.EndedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return new StudySessionFinishResponseDto
            {
                SessionId = session.Session.SessionId,
                SourceType = session.Session.SourceType,
                SourceName = session.Session.SourceName,
                TopicId = session.Session.TopicId,
                TopicName = session.TopicName,
                StartedAt = session.Session.StartedAt,
                EndedAt = session.Session.EndedAt.Value,
                TotalWords = session.Session.TotalWords,
                ReviewedCount = details.Count,
                RememberedCount = rememberedCount,
                NotRememberedCount = notRememberedCount,
                CompletionRate = session.Session.TotalWords == 0
                    ? 0
                    : Math.Round((double)details.Count / session.Session.TotalWords * 100, 2),
                DurationSeconds = (int)(session.Session.EndedAt.Value - session.Session.StartedAt).TotalSeconds,
                Details = details
            };
        }

        public async Task<List<StudySessionHistoryItemDto>> GetHistoryAsync(Guid userId)
        {
            var sessions = await _context.StudySessions
                .Where(s => s.UserId == userId)
                .GroupJoin(
                    _context.VocabularyTopics,
                    s => s.TopicId,
                    t => t.TopicId,
                    (s, topics) => new { s, topics }
                )
                .SelectMany(
                    x => x.topics.DefaultIfEmpty(),
                    (x, t) => new
                    {
                        Session = x.s,
                        TopicName = t != null ? t.TopicName : null
                    }
                )
                .OrderByDescending(x => x.Session.StartedAt)
                .ToListAsync();

            var sessionIds = sessions.Select(x => x.Session.SessionId).ToList();

            var reviewedCounts = await _context.StudySessionDetails
                .Where(d => sessionIds.Contains(d.SessionId))
                .GroupBy(d => d.SessionId)
                .Select(g => new
                {
                    SessionId = g.Key,
                    ReviewedCount = g.Count()
                })
                .ToListAsync();

            var reviewedLookup = reviewedCounts.ToDictionary(x => x.SessionId, x => x.ReviewedCount);

            return sessions.Select(x =>
            {
                var reviewedCount = reviewedLookup.ContainsKey(x.Session.SessionId)
                    ? reviewedLookup[x.Session.SessionId]
                    : 0;

                return new StudySessionHistoryItemDto
                {
                    SessionId = x.Session.SessionId,
                    SourceType = x.Session.SourceType,
                    SourceName = x.Session.SourceName,
                    TopicId = x.Session.TopicId,
                    TopicName = x.TopicName,
                    SessionType = x.Session.SessionType,
                    StartedAt = x.Session.StartedAt,
                    EndedAt = x.Session.EndedAt,
                    TotalWords = x.Session.TotalWords,
                    RememberedCount = x.Session.RememberedCount,
                    NotRememberedCount = x.Session.NotRememberedCount,
                    ReviewedCount = reviewedCount,
                    IsFinished = x.Session.EndedAt.HasValue,
                    CompletionRate = x.Session.TotalWords == 0
                        ? 0
                        : Math.Round((double)reviewedCount / x.Session.TotalWords * 100, 2),
                    DurationSeconds = x.Session.EndedAt.HasValue
                        ? (int)(x.Session.EndedAt.Value - x.Session.StartedAt).TotalSeconds
                        : null
                };
            }).ToList();
        }

        public async Task<StudySessionDetailResponseDto> GetSessionDetailAsync(Guid userId, Guid sessionId)
        {
            var session = await _context.StudySessions
                .GroupJoin(
                    _context.VocabularyTopics,
                    s => s.TopicId,
                    t => t.TopicId,
                    (s, topics) => new { s, topics }
                )
                .SelectMany(
                    x => x.topics.DefaultIfEmpty(),
                    (x, t) => new
                    {
                        Session = x.s,
                        TopicName = t != null ? t.TopicName : null
                    }
                )
                .FirstOrDefaultAsync(x => x.Session.SessionId == sessionId && x.Session.UserId == userId);

            if (session == null)
                throw new KeyNotFoundException("Study session not found.");

            var details = await _context.StudySessionDetails
                .Where(d => d.SessionId == sessionId)
                .Join(
                    _context.VocabularyWords,
                    d => d.WordId,
                    w => w.WordId,
                    (d, w) => new StudySessionDetailItemDto
                    {
                        SessionDetailId = d.SessionDetailId,
                        WordId = w.WordId,
                        WordText = w.WordText,
                        Meaning = w.Meaning,
                        IsRemembered = d.IsRemembered,
                        ReviewOrder = d.ReviewOrder,
                        ReviewedAt = d.ReviewedAt
                    }
                )
                .OrderBy(x => x.ReviewOrder)
                .ThenBy(x => x.ReviewedAt)
                .ToListAsync();

            var reviewedCount = details.Count;

            return new StudySessionDetailResponseDto
            {
                SessionId = session.Session.SessionId,
                SourceType = session.Session.SourceType,
                SourceName = session.Session.SourceName,
                TopicId = session.Session.TopicId,
                TopicName = session.TopicName,
                SessionType = session.Session.SessionType,
                StartedAt = session.Session.StartedAt,
                EndedAt = session.Session.EndedAt,
                TotalWords = session.Session.TotalWords,
                RememberedCount = session.Session.RememberedCount,
                NotRememberedCount = session.Session.NotRememberedCount,
                ReviewedCount = reviewedCount,
                IsFinished = session.Session.EndedAt.HasValue,
                CompletionRate = session.Session.TotalWords == 0
                    ? 0
                    : Math.Round((double)reviewedCount / session.Session.TotalWords * 100, 2),
                DurationSeconds = session.Session.EndedAt.HasValue
                    ? (int)(session.Session.EndedAt.Value - session.Session.StartedAt).TotalSeconds
                    : null,
                Details = details
            };
        }

        private async Task UpsertWordProgressAsync(Guid userId, Guid wordId, bool isRemembered)
        {
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

            if (isRemembered)
            {
                progress.CorrectCount += 1;
            }
            else
            {
                progress.IncorrectCount += 1;
            }

            progress.LastStudiedAt = DateTime.UtcNow;
            progress.UpdatedAt = DateTime.UtcNow;
            progress.IsLearned = progress.CorrectCount >= LearnedThreshold;
        }
    }
}

