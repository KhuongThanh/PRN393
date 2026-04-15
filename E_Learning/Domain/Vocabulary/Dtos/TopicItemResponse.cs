namespace E_Learning.Domain.Vocabulary.Dtos
{
    public class TopicItemResponse
    {
        public Guid TopicId { get; set; }
        public string TopicName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public int DisplayOrder { get; set; }
    }
}
