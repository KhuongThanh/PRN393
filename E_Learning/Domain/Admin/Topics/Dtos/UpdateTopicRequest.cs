using System.ComponentModel.DataAnnotations;

namespace E_Learning.Domain.Admin.Topics.Dtos
{
    public class UpdateTopicRequest
    {
        [Required]
        [MaxLength(200)]
        public string TopicName { get; set; } = null!;

        [MaxLength(1000)]
        public string? Description { get; set; }

        [MaxLength(500)]
        public string? ImageUrl { get; set; }

        public int DisplayOrder { get; set; }
        public bool IsActive { get; set; }
    }
}
