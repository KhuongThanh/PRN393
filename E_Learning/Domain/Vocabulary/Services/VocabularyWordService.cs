using E_Learning.Data;
using E_Learning.Domain.Vocabulary.Dtos;
using E_Learning.Domain.Vocabulary.Interface;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Vocabulary.Services
{
    public class VocabularyWordService : IVocabularyWordService
    {
        private readonly AppDbContext _context;

        public VocabularyWordService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<WordListItemResponse>> GetWordsByTopicAsync(Guid topicId, string? keyword, string? difficulty)
        {
            var topicExists = await _context.VocabularyTopics
                .AsNoTracking()
                .AnyAsync(x => x.TopicId == topicId && x.IsActive == true);

            if (!topicExists)
                throw new Exception("Topic not found.");

            var query = _context.VocabularyWords
                .AsNoTracking()
                .Where(x => x.TopicId == topicId && x.IsActive == true)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                keyword = keyword.Trim();

                query = query.Where(x =>
                    x.WordText.Contains(keyword) ||
                    x.Meaning.Contains(keyword));
            }

            if (!string.IsNullOrWhiteSpace(difficulty))
            {
                difficulty = difficulty.Trim();

                query = query.Where(x => x.DifficultyLevel == difficulty);
            }

            var words = await query
                .OrderBy(x => x.WordText)
                .Select(x => new WordListItemResponse
                {
                    WordId = x.WordId,
                    TopicId = x.TopicId,
                    WordText = x.WordText,
                    Meaning = x.Meaning,
                    PartOfSpeech = x.PartOfSpeech,
                    Phonetic = x.Phonetic,
                    DifficultyLevel = x.DifficultyLevel
                })
                .ToListAsync();

            return words;
        }

        public async Task<WordDetailResponse> GetWordDetailAsync(Guid wordId)
        {
            var word = await _context.VocabularyWords
                .AsNoTracking()
                .Where(x => x.WordId == wordId && x.IsActive == true)
                .Select(x => new WordDetailResponse
                {
                    WordId = x.WordId,
                    TopicId = x.TopicId,
                    WordText = x.WordText,
                    Meaning = x.Meaning,
                    ExampleSentence = x.ExampleSentence,
                    PartOfSpeech = x.PartOfSpeech,
                    Phonetic = x.Phonetic,
                    AudioUrl = x.AudioUrl,
                    ImageUrl = x.ImageUrl,
                    DifficultyLevel = x.DifficultyLevel
                })
                .FirstOrDefaultAsync();

            if (word == null)
                throw new Exception("Word not found.");

            return word;
        }
    }
}