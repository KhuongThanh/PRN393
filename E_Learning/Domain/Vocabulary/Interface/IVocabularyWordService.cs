using E_Learning.Domain.Vocabulary.Dtos;

namespace E_Learning.Domain.Vocabulary.Interface
{
    public interface IVocabularyWordService
    {
        Task<List<WordListItemResponse>> GetWordsByTopicAsync(Guid topicId, string? keyword, string? difficulty);
        Task<WordDetailResponse> GetWordDetailAsync(Guid wordId);
    }
}
