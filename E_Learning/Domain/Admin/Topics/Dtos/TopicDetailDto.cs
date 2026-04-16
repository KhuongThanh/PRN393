namespace E_Learning.Domain.Admin.Topics.Dtos
{
    public class TopicDetailDto
    {
        public Guid TopicId { get; set; }
        public string TopicName { get; set; } = null!;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public int DisplayOrder { get; set; }
        public bool IsActive { get; set; }
    }
}
