using E_Learning.Domain.Progress.Dtos;

namespace E_Learning.Domain.Progress.Interface
{
    public interface IUserWordProgressService
    {
    Task<ProgressSummaryDto> GetSummaryAsync(Guid userId);
    Task<WordProgressDto> GetWordProgressAsync(Guid userId, Guid wordId);
    Task<WordProgressDto> UpdateWordProgressAsync(Guid userId, Guid wordId, UpdateWordProgressRequest request);
    Task<TopicProgressDto> GetTopicProgressAsync(Guid userId, Guid topicId);
}
}
