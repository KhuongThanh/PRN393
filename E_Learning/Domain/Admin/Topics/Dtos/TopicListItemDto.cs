namespace E_Learning.Domain.Admin.Topics.Dtos
{
    public class TopicListItemDto
    {
        public Guid TopicId { get; set; }
        public string TopicName { get; set; } = null!;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public int DisplayOrder { get; set; }
        public bool IsActive { get; set; }
        public int TotalWords { get; set; }
        public int TotalQuizzes { get; set; }
    }
}
