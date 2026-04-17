using E_Learning.Domain.Admin.Options.Dtos;

namespace E_Learning.Domain.Admin.Options.Interface
{
    public interface IAdminOptionService
    {
        Task<List<AdminOptionListItemDto>> GetByQuestionAsync(Guid questionId);
        Task<AdminOptionDetailDto> GetByIdAsync(Guid optionId);
        Task<AdminOptionDetailDto> CreateAsync(Guid questionId, CreateOptionRequest request);
        Task<AdminOptionDetailDto> UpdateAsync(Guid optionId, UpdateOptionRequest request);
        Task DeleteAsync(Guid optionId);
    }
}
