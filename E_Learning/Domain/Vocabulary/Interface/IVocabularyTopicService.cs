using E_Learning.Domain.Vocabulary.Dtos;

namespace E_Learning.Domain.Vocabulary.Interface
{
    public interface IVocabularyTopicService
    {
        Task<List<TopicItemResponse>> GetTopicsAsync();
    }
}
