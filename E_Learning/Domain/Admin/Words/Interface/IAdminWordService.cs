using E_Learning.Domain.Admin.Words.Dtos;

namespace E_Learning.Domain.Admin.Words.Interface
{
    public interface IAdminWordService
    {
        Task<List<AdminWordListItemDto>> GetByTopicAsync(Guid topicId);
        Task<AdminWordDetailDto> GetByIdAsync(Guid wordId);
        Task<AdminWordDetailDto> CreateAsync(Guid topicId, CreateWordRequest request);
        Task<AdminWordDetailDto> UpdateAsync(Guid wordId, UpdateWordRequest request);
        Task ToggleActiveAsync(Guid wordId, bool isActive);
        Task DeleteAsync(Guid wordId);
    }
}
