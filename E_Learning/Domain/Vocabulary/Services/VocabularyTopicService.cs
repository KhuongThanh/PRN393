using E_Learning.Data;
using E_Learning.Domain.Vocabulary.Dtos;
using E_Learning.Domain.Vocabulary.Interface;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Vocabulary.Services
{
    public class VocabularyTopicService : IVocabularyTopicService
    {
        private readonly AppDbContext _context;

        public VocabularyTopicService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<TopicItemResponse>> GetTopicsAsync()
        {
            var topics = await _context.VocabularyTopics
                .AsNoTracking()
                .Where(x => x.IsActive == true)
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new TopicItemResponse
                {
                    TopicId = x.TopicId,
                    TopicName = x.TopicName,
                    Description = x.Description,
                    ImageUrl = x.ImageUrl,
                    DisplayOrder = x.DisplayOrder
                })
                .ToListAsync();

            return topics;
        }
    }
}
