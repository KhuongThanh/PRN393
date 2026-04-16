using E_Learning.Data;
using E_Learning.Domain.Admin.Topics.Dtos;
using E_Learning.Domain.Admin.Topics.Interface;
using E_Learning.Entity;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Domain.Admin.Topics.Services
{
    public class AdminTopicService : IAdminTopicService
    {
        private readonly AppDbContext _context;

        public AdminTopicService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<TopicListItemDto>> GetAllAsync()
        {
            var topics = await _context.VocabularyTopics
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.TopicName)
                .Select(x => new TopicListItemDto
                {
                    TopicId = x.TopicId,
                    TopicName = x.TopicName,
                    Description = x.Description,
                    ImageUrl = x.ImageUrl,
                    DisplayOrder = x.DisplayOrder,
                    IsActive = x.IsActive,
                    TotalWords = _context.VocabularyWords.Count(w => w.TopicId == x.TopicId),
                    TotalQuizzes = _context.Quizzes.Count(q => q.TopicId == x.TopicId)
                })
                .ToListAsync();

            return topics;
        }

        public async Task<TopicDetailDto> GetByIdAsync(Guid topicId)
        {
            var topic = await _context.VocabularyTopics
                .FirstOrDefaultAsync(x => x.TopicId == topicId);

            if (topic == null)
                throw new KeyNotFoundException("Topic not found.");

            return new TopicDetailDto
            {
                TopicId = topic.TopicId,
                TopicName = topic.TopicName,
                Description = topic.Description,
                ImageUrl = topic.ImageUrl,
                DisplayOrder = topic.DisplayOrder,
                IsActive = topic.IsActive
            };
        }

        public async Task<TopicDetailDto> CreateAsync(CreateTopicRequest request)
        {
            var normalizedName = request.TopicName.Trim();

            var exists = await _context.VocabularyTopics
                .AnyAsync(x => x.TopicName == normalizedName);

            if (exists)
                throw new InvalidOperationException("Topic name already exists.");

            var topic = new VocabularyTopic
            {
                TopicId = Guid.NewGuid(),
                TopicName = normalizedName,
                Description = request.Description?.Trim(),
                ImageUrl = request.ImageUrl?.Trim(),
                DisplayOrder = request.DisplayOrder,
                IsActive = request.IsActive,
                CreatedAt = DateTime.UtcNow
            };

            _context.VocabularyTopics.Add(topic);
            await _context.SaveChangesAsync();

            return new TopicDetailDto
            {
                TopicId = topic.TopicId,
                TopicName = topic.TopicName,
                Description = topic.Description,
                ImageUrl = topic.ImageUrl,
                DisplayOrder = topic.DisplayOrder,
                IsActive = topic.IsActive
            };
        }

        public async Task<TopicDetailDto> UpdateAsync(Guid topicId, UpdateTopicRequest request)
        {
            var topic = await _context.VocabularyTopics
                .FirstOrDefaultAsync(x => x.TopicId == topicId);

            if (topic == null)
                throw new KeyNotFoundException("Topic not found.");

            var normalizedName = request.TopicName.Trim();

            var duplicated = await _context.VocabularyTopics
                .AnyAsync(x => x.TopicId != topicId && x.TopicName == normalizedName);

            if (duplicated)
                throw new InvalidOperationException("Topic name already exists.");

            topic.TopicName = normalizedName;
            topic.Description = request.Description?.Trim();
            topic.ImageUrl = request.ImageUrl?.Trim();
            topic.DisplayOrder = request.DisplayOrder;
            topic.IsActive = request.IsActive;
            topic.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return new TopicDetailDto
            {
                TopicId = topic.TopicId,
                TopicName = topic.TopicName,
                Description = topic.Description,
                ImageUrl = topic.ImageUrl,
                DisplayOrder = topic.DisplayOrder,
                IsActive = topic.IsActive
            };
        }

        public async Task ToggleActiveAsync(Guid topicId, bool isActive)
        {
            var topic = await _context.VocabularyTopics
                .FirstOrDefaultAsync(x => x.TopicId == topicId);

            if (topic == null)
                throw new KeyNotFoundException("Topic not found.");

            topic.IsActive = isActive;
            topic.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Guid topicId)
        {
            var topic = await _context.VocabularyTopics
                .FirstOrDefaultAsync(x => x.TopicId == topicId);

            if (topic == null)
                throw new KeyNotFoundException("Topic not found.");

            var hasWords = await _context.VocabularyWords.AnyAsync(x => x.TopicId == topicId);
            var hasQuizzes = await _context.Quizzes.AnyAsync(x => x.TopicId == topicId);

            if (hasWords || hasQuizzes)
                throw new InvalidOperationException("Cannot delete topic because related words or quizzes exist.");

            _context.VocabularyTopics.Remove(topic);
            await _context.SaveChangesAsync();
        }
    }
}