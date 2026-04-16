using E_Learning.Data;
using E_Learning.Domain.Admin.Words.Dtos;
using E_Learning.Domain.Admin.Words.Interface;
using E_Learning.Entity;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Admin.Words.Services
{
    public class AdminWordService : IAdminWordService
    {
        private readonly AppDbContext _context;

        public AdminWordService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<AdminWordListItemDto>> GetByTopicAsync(Guid topicId)
        {
            var topicExists = await _context.VocabularyTopics
                .AnyAsync(x => x.TopicId == topicId);

            if (!topicExists)
                throw new KeyNotFoundException("Topic not found.");

            var words = await _context.VocabularyWords
                .Where(x => x.TopicId == topicId)
                .OrderBy(x => x.WordText)
                .Select(x => new AdminWordListItemDto
                {
                    WordId = x.WordId,
                    TopicId = x.TopicId,
                    WordText = x.WordText,
                    Meaning = x.Meaning,
                    PartOfSpeech = x.PartOfSpeech,
                    Phonetic = x.Phonetic,
                    DifficultyLevel = x.DifficultyLevel,
                    IsActive = x.IsActive
                })
                .ToListAsync();

            return words;
        }

        public async Task<AdminWordDetailDto> GetByIdAsync(Guid wordId)
        {
            var word = await _context.VocabularyWords
                .FirstOrDefaultAsync(x => x.WordId == wordId);

            if (word == null)
                throw new KeyNotFoundException("Word not found.");

            return MapToDetailDto(word);
        }

        public async Task<AdminWordDetailDto> CreateAsync(Guid topicId, CreateWordRequest request)
        {
            var topicExists = await _context.VocabularyTopics
                .AnyAsync(x => x.TopicId == topicId);

            if (!topicExists)
                throw new KeyNotFoundException("Topic not found.");

            var normalizedWordText = request.WordText.Trim();
            var normalizedMeaning = request.Meaning.Trim();

            var duplicated = await _context.VocabularyWords
                .AnyAsync(x => x.TopicId == topicId && x.WordText == normalizedWordText);

            if (duplicated)
                throw new InvalidOperationException("Word already exists in this topic.");

            var word = new VocabularyWord
            {
                WordId = Guid.NewGuid(),
                TopicId = topicId,
                WordText = normalizedWordText,
                Meaning = normalizedMeaning,
                ExampleSentence = request.ExampleSentence?.Trim(),
                PartOfSpeech = request.PartOfSpeech?.Trim(),
                Phonetic = request.Phonetic?.Trim(),
                AudioUrl = request.AudioUrl?.Trim(),
                ImageUrl = request.ImageUrl?.Trim(),
                DifficultyLevel = request.DifficultyLevel?.Trim(),
                IsActive = request.IsActive,
                CreatedAt = DateTime.UtcNow
            };

            _context.VocabularyWords.Add(word);
            await _context.SaveChangesAsync();

            return MapToDetailDto(word);
        }

        public async Task<AdminWordDetailDto> UpdateAsync(Guid wordId, UpdateWordRequest request)
        {
            var word = await _context.VocabularyWords
                .FirstOrDefaultAsync(x => x.WordId == wordId);

            if (word == null)
                throw new KeyNotFoundException("Word not found.");

            var normalizedWordText = request.WordText.Trim();
            var normalizedMeaning = request.Meaning.Trim();

            var duplicated = await _context.VocabularyWords
                .AnyAsync(x => x.WordId != wordId
                            && x.TopicId == word.TopicId
                            && x.WordText == normalizedWordText);

            if (duplicated)
                throw new InvalidOperationException("Word already exists in this topic.");

            word.WordText = normalizedWordText;
            word.Meaning = normalizedMeaning;
            word.ExampleSentence = request.ExampleSentence?.Trim();
            word.PartOfSpeech = request.PartOfSpeech?.Trim();
            word.Phonetic = request.Phonetic?.Trim();
            word.AudioUrl = request.AudioUrl?.Trim();
            word.ImageUrl = request.ImageUrl?.Trim();
            word.DifficultyLevel = request.DifficultyLevel?.Trim();
            word.IsActive = request.IsActive;
            word.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToDetailDto(word);
        }

        public async Task ToggleActiveAsync(Guid wordId, bool isActive)
        {
            var word = await _context.VocabularyWords
                .FirstOrDefaultAsync(x => x.WordId == wordId);

            if (word == null)
                throw new KeyNotFoundException("Word not found.");

            word.IsActive = isActive;
            word.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Guid wordId)
        {
            var word = await _context.VocabularyWords
                .FirstOrDefaultAsync(x => x.WordId == wordId);

            if (word == null)
                throw new KeyNotFoundException("Word not found.");

            var usedInFavorites = await _context.UserFavoriteWords.AnyAsync(x => x.WordId == wordId);
            var usedInProgress = await _context.UserWordProgresses.AnyAsync(x => x.WordId == wordId);
            var usedInStudy = await _context.StudySessionDetails.AnyAsync(x => x.WordId == wordId);
            var usedInQuiz = await _context.QuizQuestions.AnyAsync(x => x.WordId == wordId);

            if (usedInFavorites || usedInProgress || usedInStudy || usedInQuiz)
                throw new InvalidOperationException("Cannot delete word because related data exists.");

            _context.VocabularyWords.Remove(word);
            await _context.SaveChangesAsync();
        }

        private static AdminWordDetailDto MapToDetailDto(VocabularyWord word)
        {
            return new AdminWordDetailDto
            {
                WordId = word.WordId,
                TopicId = word.TopicId,
                WordText = word.WordText,
                Meaning = word.Meaning,
                ExampleSentence = word.ExampleSentence,
                PartOfSpeech = word.PartOfSpeech,
                Phonetic = word.Phonetic,
                AudioUrl = word.AudioUrl,
                ImageUrl = word.ImageUrl,
                DifficultyLevel = word.DifficultyLevel,
                IsActive = word.IsActive
            };
        }
    }
}