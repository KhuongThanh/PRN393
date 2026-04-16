using E_Learning.Data;
using E_Learning.Domain.Vocabulary.Dtos;
using E_Learning.Domain.Vocabulary.Interface;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Vocabulary.Services
{
    public class VocabularyTopicService : IVocabularyTopicService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;


        public VocabularyTopicService(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        public async Task<List<TopicItemResponse>> GetTopicsAsync()
        {
            var defaultTopicImageUrl =
                _configuration["DefaultImages:TopicImageUrl"] ?? "/images/default-topic.jpg";

            var topics = await _context.VocabularyTopics
                .AsNoTracking()
                .Where(x => x.IsActive == true)
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new TopicItemResponse
                {
                    TopicId = x.TopicId,
                    TopicName = x.TopicName,
                    Description = x.Description,
                    ImageUrl = string.IsNullOrWhiteSpace(x.ImageUrl)
                        ? defaultTopicImageUrl
                        : x.ImageUrl,
                    DisplayOrder = x.DisplayOrder
                })
                .ToListAsync();

            return topics;
        }
    }
}
