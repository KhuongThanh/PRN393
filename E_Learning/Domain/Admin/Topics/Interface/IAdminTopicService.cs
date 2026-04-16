using E_Learning.Domain.Admin.Topics.Dtos;

namespace E_Learning.Domain.Admin.Topics.Interface
{
    public interface IAdminTopicService
    {
        Task<List<TopicListItemDto>> GetAllAsync();
        Task<TopicDetailDto> GetByIdAsync(Guid topicId);
        Task<TopicDetailDto> CreateAsync(CreateTopicRequest request);
        Task<TopicDetailDto> UpdateAsync(Guid topicId, UpdateTopicRequest request);
        Task ToggleActiveAsync(Guid topicId, bool isActive);
        Task DeleteAsync(Guid topicId);
    }
}
